if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Батарейка"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/battery_2.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/battery_2.png"
    SWEP.BounceWeaponIcon = false
end


SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/battery/battery.mdl"
SWEP.WorldModelReal = "models/weapons/shaky/breach_items/battery/v_battery.mdl"
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
SWEP.HoldPos = Vector(1, 3, -2)

SWEP.droppable = true
SWEP.Equipableitem = true
SWEP.Charge = 8
SWEP.Skin = 1

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.AnimList = {
    ["deploy"] = {"draw", 0.5, false},
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
        if wm:GetSkin() ~= self.Skin then
            wm:SetSkin(self.Skin)
        end
    end
end