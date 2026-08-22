-- Compatibility layer for legacy ZCity DModelPanel:BoneMerged API.
-- The old implementation came from an external helper and is not present in
-- modern installs. Keep the API local to DModelPanel and clean up entities.

if not CLIENT then return end
if not vgui or not vgui.GetControlTable then return end

local PANEL = vgui.GetControlTable("DModelPanel")
if not PANEL or PANEL.BoneMerged then return end

function PANEL:BoneMerged(model, material, invisible, skin, color)
    if not isstring(model) or model == "" then return nil end

    self._ZCityBoneMerges = self._ZCityBoneMerges or {}
    self._ZCityBoneMergeByModel = self._ZCityBoneMergeByModel or {}

    local base = self:GetEntity()
    if not IsValid(base) then return nil end

    local merged = self._ZCityBoneMergeByModel[model]
    if not IsValid(merged) then
        merged = ClientsideModel(model, RENDERGROUP_OPAQUE)
        if not IsValid(merged) then return nil end

        merged:SetParent(base)
        merged:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL))
        merged:SetMoveType(MOVETYPE_NONE)
        merged:SetSolid(SOLID_NONE)
        merged:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self._ZCityBoneMerges[#self._ZCityBoneMerges + 1] = merged
        self._ZCityBoneMergeByModel[model] = merged
    end

    merged:SetNoDraw(invisible == true)
    if skin ~= nil then merged:SetSkin(tonumber(skin) or 0) end
    if isstring(material) and material ~= "" then
        merged:SetSubMaterial(0, material)
    end
    if IsColor(color) then
        merged:SetColor(color)
        merged:SetRenderMode(RENDERMODE_TRANSCOLOR)
    end

    return merged
end

local oldOnRemove = PANEL.OnRemove
function PANEL:OnRemove(...)
    if self._ZCityBoneMerges then
        for _, ent in ipairs(self._ZCityBoneMerges) do
            if IsValid(ent) then ent:Remove() end
        end
        self._ZCityBoneMerges = nil
        self._ZCityBoneMergeByModel = nil
    end
    if oldOnRemove then return oldOnRemove(self, ...) end
end

local oldPaint = PANEL.DrawModel
function PANEL:DrawModel(...)
    local result
    if oldPaint then result = oldPaint(self, ...) end

    if self._ZCityBoneMerges then
        for _, ent in ipairs(self._ZCityBoneMerges) do
            if IsValid(ent) and not ent:GetNoDraw() then
                ent:DrawModel()
            end
        end
    end
    return result
end
