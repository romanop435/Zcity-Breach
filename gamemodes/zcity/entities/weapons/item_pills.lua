if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Болеутоляющие таблетки"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/pills.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/pills.png"
    SWEP.Desc = "Уменьшает болевые ощущения в два раза"
end

SWEP.droppable = true
SWEP.teams = {2,3,5,6,10}

SWEP.Primary.Wait = 2.5
SWEP.Primary.Next = 0

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/painpills/w_painpills.mdl"
SWEP.WorldModelReal = "models/cultist/items/painpills/v_painpills.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true

SWEP.HoldAng = Angle(15, 0, 0)
SWEP.HoldPos = Vector(0, 0, 0)

SWEP.CallbackTimeAdjust = 0
SWEP.showstats = false

SWEP.AnimList = {
    ["deploy"] = {"painpills_draw", 0.75, false},
    ["use"] = {"eq_painpills_use", 2.5, false, false, function(self)
        
        self.IsInjecting = false
        if SERVER then
            local owner = self:GetOwner()
            if IsValid(owner) then
                owner:SelectWeapon("br_holster")
            end
            self:Remove()
        end
    end},
    ["idle"] = {"painpills_idle", 5, true}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.IsInjecting = false
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    if SERVER then
        self:GetOwner():EmitSound("weapons/universal/uni_weapon_draw_02.wav", 75, 80, 1, CHAN_WEAPON)
    end

    return true
end

function SWEP:Holster()
    
    if self.IsInjecting then return false end
    return true
end

function SWEP:OnRemove()
    
    local wepID = self:EntIndex()
    timer.Remove("PillsEffect_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsInjecting then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsInjecting = true
    self:SetNextPrimaryFire(CurTime() + 3.0)
    
    
    self:PlayAnim("use", 2.5)

    local wepID = self:EntIndex()

    
    timer.Create("PillsEffect_" .. wepID, 2.0, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if SERVER then
            
            if ply.RemoveItemClass then
                ply:RemoveItemClass(self:GetClass())
            end

            
            
                
				
				ply.organism.painadd = -4570
            
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end