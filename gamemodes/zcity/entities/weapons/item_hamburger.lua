if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Гамбургер"
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/hamburger.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/hamburger.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/hamburger/w_hamburger.mdl"
SWEP.WorldModelReal = "models/cultist/items/hamburger/v_hamburger.mdl"
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
SWEP.HoldPos = Vector(-7, -3, -3)

SWEP.droppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local viewpunch_angle = Angle(2, 2, 2)


SWEP.AnimList = {
    ["deploy"] = {"painpills_holster", 0.5, false},
    ["idle"] = {"painpills_idle", 5, true},
    ["use"] = {"eq_painpills_use", 1.5, false, false, function(self)
        self.IsEating = false
        if SERVER then
            local owner = self:GetOwner()
            if IsValid(owner) then
                
                owner:SelectWeapon("br_holster")
            end
            self:Remove()
        end
    end}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self.IsEating = false
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    timer.Simple(0.1, function()
        if IsValid(self) and IsValid(self:GetOwner()) then
            self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
        end
    end)
    return true
end

function SWEP:Holster()
    if self.IsEating then return false end
    return true
end

function SWEP:OnRemove()
    local wepID = self:EntIndex()
    timer.Remove("BurgerPunch_" .. wepID)
    timer.Remove("BurgerEat_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsEating then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsEating = true
    self:SetNextPrimaryFire(CurTime() + 3)

    self:PlayAnim("use")

    local wepID = self:EntIndex()

    timer.Create("BurgerPunch_" .. wepID, 0.7, 1, function()
        if IsValid(self) and IsValid(owner) then
            if SERVER then owner:ViewPunch(viewpunch_angle) end
        end
    end)

    timer.Create("BurgerEat_" .. wepID, 1.0, 1, function()
        if not IsValid(self) or not IsValid(owner) then return end

        if SERVER then
            if owner.RemoveItemClass then
                owner:RemoveItemClass(self:GetClass())
            end
            
            if owner.GetRoleName and owner:GetRoleName():find("Fat") then
                owner:SetHealth(owner:GetMaxHealth())
                --if owner.BrTip then
                --    owner:BrTip(0, "[ZCity Breach]", Color(255, 0, 0, 210), "l:you_ate_burger", color_white)
                --end
            else
                local clamp_health = math.Clamp(owner:Health() + (owner:GetMaxHealth() * 0.3), 0, owner:GetMaxHealth())
                local show_health = clamp_health - owner:Health()
                owner:SetHealth(clamp_health)
                --if owner.BrTip then
                --    owner:BrTip(0, "[ZCity Breach]", Color(255, 0, 0, 210), "l:you_ate_burger_hp_regenerated_pt1 " .. math.floor(show_health) .. " l:you_ate_burger_hp_regenerated_pt2", color_white)
                --end
            end
            
            if owner.organism then
                owner.organism.satiety = math.min((owner.organism.satiety or 0) + 40, 100)
                owner.organism.hungry = math.max((owner.organism.hungry or 0) - 40, 0)

                owner.organism.blood = math.min((owner.organism.blood or 5000) + 1000, 5000)
            end
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end