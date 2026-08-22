if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Чимер"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/chemer.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/chemer.png"
    SWEP.red = "OMG"
    SWEP.BounceWeaponIcon = false
end


SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/chemers/cheemer.mdl"
SWEP.WorldModelReal = "models/chemers/v_cheemer.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = true
SWEP.setrh = true
SWEP.UseHands = true



SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(0, 0, 0)

SWEP.droppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.AnimList = {
    ["deploy"] = {"deploy", 0.5, false},
    ["idle"] = {"idle", 5, true}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PrimaryAttack()
    return false
end

function SWEP:SecondaryAttack()
    return false
end


function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) then
        if wm:GetModelScale() ~= 0.8 then
            wm:SetModelScale(0.8, 0)
        end
    end
end