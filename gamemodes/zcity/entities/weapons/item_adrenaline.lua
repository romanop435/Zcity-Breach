if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Адреналин"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
    SWEP.WepSelectIcon = Material("nextoren/gui/new_icons/adrenalin.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/adrenalin.png"
    SWEP.Desc = "Восстанавливает и замораживает выносливость"
    SWEP.InvIcon = Material( "nextoren/gui/new_icons/adrenalin.png" )
end

SWEP.Primary.Wait = 1.5
SWEP.Primary.Next = 0

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/adrenalin/w_adrenaline.mdl"
SWEP.WorldModelReal = "models/cultist/items/adrenalin/v_adrenaline.mdl"
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
local adrenaline_clr = Color(0, 255, 198)

local team_flash = {
    [TEAM_CLASSD] = true,
    [TEAM_SCI] = true
}

SWEP.CallbackTimeAdjust = 0
SWEP.showstats = false
SWEP.DistUse = 32

SWEP.AnimList = {
    ["deploy"] = {"deploy", 1, false},
    ["use"] = {"use", 1.25, false, false, function(self)
        
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
    util.AddNetworkString("Adrenaline_ClientEffect")
else
    net.Receive("Adrenaline_ClientEffect", function()
        surface.PlaySound("nextoren/weapons/items/syringe/adrenaline_heartbeat.wav")
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
    return true
end

function SWEP:Holster()
    
    if self.IsInjecting then return false end
    return true
end

function SWEP:OnRemove()
    
    local wepID = self:EntIndex()
    timer.Remove("AdrenCap_" .. wepID)
    timer.Remove("AdrenNeedle_" .. wepID)
    timer.Remove("AdrenFade_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsInjecting then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsInjecting = true
    self:SetNextPrimaryFire(CurTime() + 2)
    self:PlayAnim("use")

    local wepID = self:EntIndex()

    
    timer.Create("AdrenCap_" .. wepID, 0.1, 1, function()
        if not IsValid(self) or not IsValid(self:GetOwner()) then return end
        if SERVER then self:GetOwner():EmitSound("nextoren/weapons/items/adrenaline/adrenaline_cap_off.wav") end
    end)

    
    timer.Create("AdrenNeedle_" .. wepID, 0.3, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if SERVER then
            
            if ply.RemoveItemClass then
                ply:RemoveItemClass(self:GetClass())
            end

            if not team_flash[ply:GTeam()] then
                ply:EmitSound("nextoren/weapons/items/adrenaline/adrenaline_needle_in.wav")
            else
                ply:EmitSound("nextoren/weapons/items/adrenaline/adrenaline_needle_in_orig.wav")
            end

            if ply.organism then
                ply.organism.adrenaline = (ply.organism.adrenaline or 0) + 1
            end
            
            if ply.Boosted then
                ply:Boosted(4, math.random(10, 13))
            end

            ply:ViewPunch(viewpunch_angle)
            ply:ScreenFade(SCREENFADE.IN, ColorAlpha(adrenaline_clr, 60), 0.2, 1)

            net.Start("Adrenaline_ClientEffect")
            net.Send(ply)
        end
    end)

    
    timer.Create("AdrenFade_" .. wepID, 1.0, 1, function()
        if not IsValid(self) then return end
        local ply = self:GetOwner()
        if SERVER and IsValid(ply) then
            ply:ScreenFade(SCREENFADE.IN, ColorAlpha(adrenaline_clr, 10), 10, 1)
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end