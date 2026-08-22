if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "SCP-207"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/scp/207.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/scp/207.png"
    SWEP.Desc = "Бутылка колы, которая делает вас невероятно быстрым."
    SWEP.BounceWeaponIcon = false
    SWEP.red = "SCP"
end

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/drinks/w_energy_drink.mdl"
SWEP.WorldModelReal = "models/cultist/items/drinks/v_energy_drink.mdl"
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
SWEP.HoldPos = Vector(-4, -2, -1)

SWEP.droppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Skin = 3 
local viewpunch_angle = Angle(-15, 0, 0)

SWEP.AnimList = {
    ["deploy"] = {"deploy", 0.5, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"use", 1.5, false, false, function(self)
        self.IsDrinking = false
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
    self.IsDrinking = false
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    timer.Simple(0.25, function()
        if IsValid(self) and IsValid(self:GetOwner()) then
            self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
        end
    end)
    return true
end

function SWEP:Holster()
    if self.IsDrinking then return false end
    return true
end

function SWEP:OnRemove()
    local wepID = self:EntIndex()
    timer.Remove("SCP207Punch_" .. wepID)
    timer.Remove("SCP207Drink_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsDrinking then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsDrinking = true
    self:SetNextPrimaryFire(CurTime() + 4)

    self:PlayAnim("use")

    local wepID = self:EntIndex()

    timer.Create("SCP207Punch_" .. wepID, 0.5, 1, function()
        if IsValid(self) and IsValid(owner) then
            if SERVER then owner:ViewPunch(viewpunch_angle) end
        end
    end)

    timer.Create("SCP207Drink_" .. wepID, 1.0, 1, function()
        if not IsValid(self) or not IsValid(owner) then return end

        if SERVER then
            if owner.RemoveItemClass then
                owner:RemoveItemClass(self:GetClass())
            end

            owner:SetHealth(owner:GetMaxHealth())

            local time = math.random(30, 40)
            if owner.Boosted then
                owner:Boosted(2, time)
                owner:Boosted(4, time)
            end

            if owner.organism then
                local org = owner.organism
                if org.stamina then
                    org.stamina[1] = org.stamina.max or 180
                end
                org.pain = 0
                org.painadd = 0
                org.avgpain = 0
                org.shock = 0
                org.disorientation = 0
                org.adrenaline = 5
                
                owner.fullsend = true
                if hg and hg.send_organism then
                    hg.send_organism(org, owner)
                end
            end
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) and wm:GetSkin() ~= self.Skin then
        wm:SetSkin(self.Skin)
    end
end