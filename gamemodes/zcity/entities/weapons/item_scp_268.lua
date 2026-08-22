if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "SCP-268"
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/scp/268.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/scp/268.png"
    SWEP.red = "SCP"
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/scp_items/scp268/scp268.mdl"
SWEP.WorldModelReal = "models/weapons/shaky/scp_items/scp_268/v_scp_268.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true
SWEP.UseHands = true
SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(5, 0, -3)

SWEP.droppable = true
SWEP.UnDroppable = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

local matName = "pnv_invisible_mat_fixed"
if CLIENT then
    CreateMaterial(matName, "VertexLitGeneric", {
        ["$no_draw"] = "1"
    })
end

SWEP.AnimList = {
    ["deploy"] = {"draw", 0.95, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"use", 1.5, false},
    ["unuse"] = {"unuse", 1.15, false}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:SetNWInt("HatState", 0)
end

function SWEP:Deploy()
    self.Initialzed = true
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
    self.remember_owner = self:GetOwner()
    return true
end

function SWEP:SetInvisibility(ply, state)

end


function SWEP:StartActivation()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNWInt("HatState", 1)
    self.droppable = false
    self.UnDroppable = true

    self:PlayAnim("use")

    if SERVER and hg and hg.RunZManipAnim then
        hg.RunZManipAnim(owner, "visordown", false, 1.0)
    end


    local timerName = "SCP268_EquipDelay_" .. self:EntIndex()
    timer.Create(timerName, 1.0, 1, function()
        if IsValid(self) and IsValid(self:GetOwner()) and self:GetNWInt("HatState", 0) == 1 then
            self:ActivateEffect()
        end
    end)
end


function SWEP:ActivateEffect()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNWInt("HatState", 2)
    self.remember_owner = owner

    if SERVER then
        owner:SetNWFloat("SCP268_ActiveTime", CurTime() + 20) -- Установка таймера для HUD

        if not self.Player_Tip or self.Player_Tip ~= owner:Nick() then
            self.Player_Tip = owner:Nick()
            BREACH.Players:ChatPrint(owner, true, true, "l:scp268_activated_first_pt1")
            BREACH.Players:ChatPrint(owner, true, true, "l:scp268_activated_first_pt2")
        else
            BREACH.Players:ChatPrint(owner, true, true, "l:scp268_activated")
        end

        self:SetInvisibility(owner, true)
    end
end

function SWEP:DeactivateEffect()
    local owner = self:GetOwner()
    if not IsValid(owner) then owner = self.remember_owner end

    local wasActive = (self:GetNWInt("HatState", 0) == 2)
    self:SetNWInt("HatState", 0)
    
    self.droppable = true
    self.UnDroppable = false

    if IsValid(self:GetOwner()) then
        self:PlayAnim("unuse")
    end

    if SERVER and IsValid(owner) then
        owner:SetNWFloat("SCP268_ActiveTime", 0)
        
        if wasActive then
            owner:SetNWFloat("SCP268_CD", CurTime() + 60)
            if owner:Health() > 0 then
                BREACH.Players:ChatPrint(owner, true, true, "l:scp268_end")
            end
        end
        
        self:SetInvisibility(owner, false)
    end

    timer.Remove("SCP268_EquipDelay_" .. self:EntIndex())
end

function SWEP:Holster()
    if self:GetNWInt("HatState", 0) > 0 then
        self:DeactivateEffect()
    end
    return true
end

function SWEP:OnDrop()
    if self:GetNWInt("HatState", 0) > 0 then
        self:DeactivateEffect()
    end
end

function SWEP:OnRemove()
    if self:GetNWInt("HatState", 0) > 0 then
        self:DeactivateEffect()
    end
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + 1.5)
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local state = self:GetNWInt("HatState", 0)

    if state == 1 or state == 2 then
        self:DeactivateEffect()
    else
        local cd = owner:GetNWFloat("SCP268_CD", 0)

        if cd > CurTime() then
            if SERVER then
                BREACH.Players:ChatPrint(owner, true, true, "l:scp268_reloading")
                BREACH.Players:ChatPrint(owner, true, true, "l:scp268_reload_when_pt1 " .. math.Round(cd - CurTime()) .. " l:scp268_reload_when_pt2")
            end
        else
            self:StartActivation()
        end
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:ThinkAdd()
    local state = self:GetNWInt("HatState", 0)

    if SERVER and state == 2 then
        local owner = self:GetOwner()
        if IsValid(owner) then
            self:SetInvisibility(owner, true)

            local activeTime = owner:GetNWFloat("SCP268_ActiveTime", 0)
            if activeTime > 0 and CurTime() >= activeTime then
                self:DeactivateEffect()
                return
            end

            for _, v in ipairs(ents.FindInSphere(owner:GetPos(), 25)) do
                if IsValid(v) and v:IsPlayer() and v:Alive() and v ~= owner and v:GTeam() ~= TEAM_SPEC then
                    if math.abs(v:GetPos().z - owner:GetPos().z) < 50 then
                        self:DeactivateEffect()
                        break
                    end
                end
            end
        end
    end
end

function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) then
        local state = self:GetNWInt("HatState", 0)

        if state == 2 then
            if not wm.IsHiddenCustom then
                wm.IsHiddenCustom = true
                wm:SetRenderMode(10) 
                wm:SetMaterial("!" .. matName)
                for i = 0, 31 do
                    wm:SetSubMaterial(i, "!" .. matName)
                end
                wm:DrawShadow(false)
            end
        else
            if wm.IsHiddenCustom then
                wm.IsHiddenCustom = nil
                wm:SetRenderMode(0) 
                wm:SetMaterial("")
                for i = 0, 31 do
                    wm:SetSubMaterial(i, "")
                end
                wm:DrawShadow(true)
            end
        end
    end
end

if SERVER then
    hook.Add("EntityTakeDamage", "SCP268_BulletImmunity", function(target, dmginfo)
        if not dmginfo:IsDamageType(DMG_BULLET) and not dmginfo:IsDamageType(DMG_BUCKSHOT) then return end
        
        local ply = target
        if target:IsRagdoll() then
            ply = target:GetNWEntity("ply")
            if not IsValid(ply) and hg and hg.RagdollOwner then
                ply = hg.RagdollOwner(target)
            end
        end
        
        if IsValid(ply) and ply:IsPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_scp_268" and wep:GetNWInt("HatState", 0) == 2 then
                if math.random(1, 2) == 1 then
                    target:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav", 75, math.random(80, 100))
                    local effectdata = EffectData()
                    effectdata:SetOrigin(dmginfo:GetDamagePosition())
                    effectdata:SetNormal((dmginfo:GetDamageForce() * -1):GetNormalized())
                    effectdata:SetMagnitude(1)
                    effectdata:SetScale(1)
                    effectdata:SetRadius(2)
                    util.Effect("Sparks", effectdata, true, true)
                end
                
                dmginfo:ScaleDamage(0)
                dmginfo:SetDamage(0)
                return true
            end
        end
    end)

    hook.Add("PreHomigradDamage", "SCP268_PreHomigradImmunity", function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs, inputHole)
        if IsValid(ply) and ply:IsPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_scp_268" and wep:GetNWInt("HatState", 0) == 2 then
                if dmgInfo:IsDamageType(DMG_BULLET) or dmgInfo:IsDamageType(DMG_BUCKSHOT) then
                    dmgInfo:SetDamage(0)
                    dmgInfo:ScaleDamage(0)
                end
            end
        end
    end)

    hook.Add("PreTraceOrganBulletDamage", "SCP268_OrganImmunity", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
        local ply = org.owner
        if IsValid(ply) and ply:IsPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_scp_268" and wep:GetNWInt("HatState", 0) == 2 then
                hook_info.dmg = 0
                hook_info.restricted = true
                dmgInfo:SetDamage(0)
            end
        end
    end)
end


if CLIENT then
    local hud_lerp = 0

    function SWEP:DrawHUD()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        local w, h = ScrW(), ScrH()
        local activeTime = ply:GetNWFloat("SCP268_ActiveTime", 0)
        local time_left = activeTime - CurTime()

        if self:GetNWInt("HatState", 0) == 2 and time_left > 0 then
            hud_lerp = Lerp(FrameTime() * 8, hud_lerp, 1)
        else
            hud_lerp = math.Approach(hud_lerp, 0, FrameTime() * 4)
        end

        if hud_lerp > 0.01 then
            local rust_panel   = Color(18, 16, 15, 245 * hud_lerp)
            local rust_outline = Color(255, 255, 255, 15 * hud_lerp)
            local rust_yellow  = Color(218, 165, 32, 255 * hud_lerp)
            local rust_text    = Color(230, 230, 230, 255 * hud_lerp)
            local rust_red     = Color(188, 64, 43, 255 * hud_lerp)

            local boxW, boxH = 220, 50
            local boxX = w / 2 - boxW / 2
            local boxY = h / 1.3 - 50

            surface.SetDrawColor(rust_panel)
            surface.DrawRect(boxX, boxY, boxW, boxH)

            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 1)

            local statusColor = rust_yellow
            if time_left <= 3 then
                statusColor = rust_red
            end

            surface.SetDrawColor(statusColor.r, statusColor.g, statusColor.b, 255 * hud_lerp)
            surface.DrawRect(boxX, boxY, boxW, 2)

            local timeStr = string.format("%.1f", math.max(0, time_left)) .. " СЕК"
            draw.DrawText("НЕВИДИМОСТЬ: " .. timeStr, "MM_Exp", boxX + boxW / 2, boxY + 12, rust_text, TEXT_ALIGN_CENTER)

            local barW = boxW - 12
            local barH = 4
            local barX = boxX + 6
            local barY = boxY + boxH - 8

            surface.SetDrawColor(10, 9, 8, 200 * hud_lerp)
            surface.DrawRect(barX, barY, barW, barH)

            local max_time = 20
            local fillW = math.Clamp((time_left / max_time) * barW, 0, barW)
            
            surface.SetDrawColor(statusColor.r, statusColor.g, statusColor.b, 255 * hud_lerp)
            surface.DrawRect(barX, barY, fillW, barH)
        end
    end
end