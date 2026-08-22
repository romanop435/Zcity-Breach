if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Кофе"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
    SWEP.WepSelectIcon = Material("nextoren/gui/new_icons/coffe.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/coffe.png"
    SWEP.Desc = "Бодрит и замораживает выносливость"
    SWEP.InvIcon = Material("nextoren/gui/new_icons/coffe.png")
end

SWEP.Primary.Wait = 1.5
SWEP.Primary.Next = 0

SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/coffe/w_coffe.mdl"
SWEP.WorldModelReal = "models/cultist/items/coffe/v_coffe.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.WorkWithFake = true


SWEP.setlh = false
SWEP.setrh = true



SWEP.HoldAng = Angle(15, 0, 0)
SWEP.HoldPos = Vector(0, 0, 0)

local viewpunch_angle = Angle(-15, 0, 0)

SWEP.CallbackTimeAdjust = 0
SWEP.showstats = false
SWEP.DistUse = 32

SWEP.AnimList = {
    ["deploy"] = {"deploy", 0.5, false},
    ["use"] = {"use", 1.25, false, false, function(self)
        
        self.IsDrinking = false
        if SERVER then
            local owner = self:GetOwner()
            if IsValid(owner) then
                
                owner:SelectWeapon("br_holster")
            end
            self:Remove()
        end
    end},
    ["idle"] = {"idle", 5, true}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.IsDrinking = false
    self.Initialzed = true
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
    timer.Remove("CoffeePunch_" .. wepID)
    timer.Remove("CoffeeDrink_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsDrinking then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsDrinking = true
    self:SetNextPrimaryFire(CurTime() + 2)
    self:PlayAnim("use")

    local wepID = self:EntIndex()

    
    timer.Create("CoffeePunch_" .. wepID, 0.5, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if SERVER then
            ply:ViewPunch(viewpunch_angle)
        end
    end)

    
    timer.Create("CoffeeDrink_" .. wepID, 1.0, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if SERVER then
            
            if ply.RemoveItemClass then
                ply:RemoveItemClass(self:GetClass())
            end

            
            if ply.organism and ply.organism.stamina then
                ply.organism.stamina[1] = math.min((ply.organism.stamina[1] or 0) + 60, ply.organism.stamina.max or 180)
            end

            
            if ply.Boosted then
                ply:Boosted(1, math.random(9, 13))
            end
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end