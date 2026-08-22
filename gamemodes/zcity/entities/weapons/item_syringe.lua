if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Усилитель"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
    SWEP.WepSelectIcon = Material("nextoren/gui/new_icons/booster.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/booster.png"
    SWEP.InvIcon = Material( "nextoren/gui/new_icons/booster.png" )
end

SWEP.Primary.Wait = 2.0
SWEP.Primary.Next = 0

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/booster/w_syringe.mdl"
SWEP.WorldModelReal = "models/cultist/items/booster/v_syringe.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true

SWEP.HoldAng = Angle(15, 40, 0)
SWEP.HoldPos = Vector(-5, 15, 0)

local viewpunch_angle = Angle(-15, 0, 0)
local effect_clr = Color(0, 0, 255)

SWEP.CallbackTimeAdjust = 0
SWEP.showstats = false
SWEP.DistUse = 32

SWEP.AnimList = {
    ["deploy"] = {"deploy", 1, false},
    ["use"] = {"use", 2.0, false, false, function(self)
        
        self.IsInjecting = false
        if SERVER then
            local owner = self:GetOwner()
            if IsValid(owner) then
                
                owner:SelectWeapon("br_holster")
            end
            self:Remove()
        end
    end},
    ["idle"] = {"idle_raw", 5, true}
}

if SERVER then
    util.AddNetworkString("Booster_ClientEffect")
    util.AddNetworkString("Booster_ClientStamina")
else
    net.Receive("Booster_ClientEffect", function()
        surface.PlaySound("nextoren/weapons/items/syringe/adrenaline_heartbeat.wav")
    end)
    net.Receive("Booster_ClientStamina", function()
        local ply = LocalPlayer()
        if IsValid(ply) then
            ply.Stamina = math.min((ply.Stamina or 0) + 30, 100)
        end
    end)
end

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
        self:GetOwner():EmitSound("nextoren/weapons/items/adrenaline/adrenaline_deploy_1.wav")
    end
    return true
end

function SWEP:Holster()
    
    if self.IsInjecting then return false end
    return true
end

function SWEP:OnRemove()
    
    local wepID = self:EntIndex()
    timer.Remove("BoosterNeedle_" .. wepID)
    timer.Remove("BoosterInject_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsInjecting then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsInjecting = true
    self:SetNextPrimaryFire(CurTime() + 2.5)
    
    
    self:PlayAnim("use", 2.0)

    local wepID = self:EntIndex()

    
    if SERVER then
        owner:EmitSound("nextoren/weapons/items/syringe/adrenaline_needle_open.wav")
    end

    
    timer.Create("BoosterNeedle_" .. wepID, 0.3, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if SERVER then
            ply:EmitSound("nextoren/weapons/items/syringe/adrenaline_needle_in.wav")
            ply:ViewPunch(viewpunch_angle)
            ply:ScreenFade(SCREENFADE.IN, ColorAlpha(effect_clr, 60), 0.2, 1)

            net.Start("Booster_ClientEffect")
            net.Send(ply)
        end
    end)

    
    timer.Create("BoosterInject_" .. wepID, 1.3, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if SERVER then
            
            if ply.RemoveItemClass then
                ply:RemoveItemClass(self:GetClass())
            end

            
            if ply.organism then
                ply.organism.adrenaline = (ply.organism.adrenaline or 0) + 3
            end
            
            
            if ply.Boosted then
                ply:Boosted(2, math.random(17, 20))
            end

            ply:ScreenFade(SCREENFADE.IN, ColorAlpha(effect_clr, 10), 0.2, 20)

            
            net.Start("Booster_ClientStamina")
            net.Send(ply)
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end