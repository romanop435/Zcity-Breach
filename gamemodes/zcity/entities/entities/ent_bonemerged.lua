AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Invisible")
    self:SetInvisible(false)
end

if SERVER then
    function ENT:Initialize()
        self:SetTransmitWithParent(true)
    end
    return
end


local function GetEntityCategory(ent)
    if not IsValid(ent) then return 0 end
    local class = ent:GetClass()
    
    if ent:IsPlayer() or ent:IsNPC() or class == "prop_ragdoll" then
        return 1
    elseif class == "class C_BaseFlex" then
        return 3
    else
        return 2
    end
end

function ENT:Initialize()
    self:DrawShadow(false)
    self:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
end

function ENT:Think()
    local parent = self:GetParent()
    if not IsValid(parent) then 
        if self:EntIndex() == -1 then self:Remove() end
        return 
    end

    local cat = GetEntityCategory(parent)

    if cat == 1 or cat == 2 then
        local parent_nodraw = parent:GetNoDraw()
        local self_nodraw = self:GetNoDraw()

        if parent_nodraw and not self_nodraw then
            self:SetNoDraw(true)
            self.no_draw = true
        elseif not parent_nodraw and self_nodraw then
            self:SetNoDraw(false)
            self.no_draw = false
        end
    elseif cat == 3 then
        if not self:GetNoDraw() then
            self:SetNoDraw(true) 
        end
        self.no_draw = false 
    end

    if not self:IsEffectActive(EF_BONEMERGE) then
        self:AddEffects(EF_BONEMERGE)
    end

    self:NextThink(CurTime() + 0.5)
    return true
end

local GlobalBoneMapCache = {}

local entityMeta = FindMetaTable("Entity")
local baseDrawModel = entityMeta.DrawModel

local FIRST_PERSON_SCALE = Vector(0.01, 0.01, 0.01)
local LOD_DISTANCE_SQR = 360000 -- 600 юнитов

function ENT:DrawModel()
    local parent = self:GetParent()
    if GetEntityCategory(parent) == 3 then
        local wasNoDraw = self:GetNoDraw()
        if wasNoDraw then self:SetNoDraw(false) end
        
        if not self:IsEffectActive(EF_BONEMERGE) then
            self:AddEffects(EF_BONEMERGE)
        end
        
        baseDrawModel(self)
        
        if wasNoDraw then self:SetNoDraw(true) end
    else
        baseDrawModel(self)
    end
end

function ENT:Draw()
    if self:GetParent():IsPlayer() and IsValid(self:GetParent():GetActiveWeapon()) and self:GetParent():GetActiveWeapon():GetNWInt("HatState", 0) == 2 then return end
    if self:GetInvisible() or self.no_draw then return end

    local parent = self:GetParent()
    if not IsValid(parent) then return end

    local cat = GetEntityCategory(parent)

    if cat ~= 1 then
        self:DrawModel()
        return
    end

    local targetEnt = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(parent) or parent
    if not IsValid(targetEnt) then targetEnt = parent end
    
    local ownerPly = targetEnt:IsPlayer() and targetEnt or targetEnt.ply
    local isLocalFP = (IsValid(ownerPly) and ownerPly == LocalPlayer() and GetViewEntity() == LocalPlayer())

    local distSqr = EyePos():DistToSqr(targetEnt:GetPos())

    if distSqr > LOD_DISTANCE_SQR and not isLocalFP then
        self:DrawModel()
        return
    end

    
    local currentFrame = FrameNumber()
    local isMainPass = (render.GetRenderTarget() == nil)

    if targetEnt.LastDrawPlayerRagdollFrame ~= currentFrame then
        if isMainPass then
            targetEnt.LastDrawPlayerRagdollFrame = currentFrame
        end

        if IsValid(ownerPly) and ownerPly.OldRagdoll then
            ownerPly:SetupBones()
        end

        targetEnt:SetupBones()

        if hg and hg.MainTPIKFunction then
            if IsValid(ownerPly) then
                local wep = ownerPly.GetActiveWeapon and ownerPly:GetActiveWeapon() or NULL
                hg.MainTPIKFunction(targetEnt, ownerPly, wep)
            end
        end

        if IsValid(ownerPly) and ownerPly.OldRagdoll and hg and hg.SmoothUnfake then
            hg.SmoothUnfake(targetEnt, ownerPly)
        end

        if IsValid(ownerPly) and ownerPly.GetNetVar and ownerPly:GetNetVar("handcuffed", false) and hg and hg.CuffedAnim then 
            hg.CuffedAnim(targetEnt, ownerPly) 
        end
    end

    self:SetupBones()

    local myModel = self:GetModel()
    if not myModel or myModel == "" then return end
    
    local plyModel = targetEnt:GetModel() or ""
    local cacheKey = myModel .. "_" .. plyModel

    if not GlobalBoneMapCache[cacheKey] then
        GlobalBoneMapCache[cacheKey] = { map = {}, isHead = {} }
        
        local lowerModel = string.lower(myModel)
        local isNVG = string.find(lowerModel, "/nightvision/") ~= nil
        
        local boneCount = self:GetBoneCount() or 0
        for i = 0, boneCount - 1 do
            local boneName = self:GetBoneName(i)
            if boneName then
                local plyBoneID = targetEnt:LookupBone(boneName)
                if plyBoneID then
                    GlobalBoneMapCache[cacheKey].map[i] = plyBoneID
                    
                    if isNVG or string.find(boneName, "Head") then
                        GlobalBoneMapCache[cacheKey].isHead[i] = true
                    end
                end
            end
        end
    end

    local cache = GlobalBoneMapCache[cacheKey]

    for myBoneID, plyBoneID in pairs(cache.map) do
        local mat = targetEnt:GetBoneMatrix(plyBoneID)
        if mat then
            if cache.isHead[myBoneID] and isLocalFP then
                mat:Scale(FIRST_PERSON_SCALE)
            else
                if IsValid(ownerPly) and ownerPly.GetManipulateBoneScale then
                    local pScale = ownerPly:GetManipulateBoneScale(plyBoneID)
                    if pScale.x < 0.99 or pScale.y < 0.99 or pScale.z < 0.99 then
                        mat:Scale(pScale)
                    end
                end
            end

            self:SetBoneMatrix(myBoneID, mat)
        end
    end

    self:DrawModel()
end