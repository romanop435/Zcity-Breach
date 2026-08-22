if SERVER then AddCSLuaFile() end




local sndpath = "nextoren/weapons/items/gasmask/"

sound.Add({
    name = "GASMASK_OnOff",
    channel = CHAN_WEAPON,
    volume = 1,
    level = 80,
    pitch = 75,
    sound = {"weapons/universal/uni_weapon_draw_02.wav"}
})

sound.Add({
    name = "GASMASK_Foley",
    channel = CHAN_AUTO,
    volume = 0.35,
    level = 80,
    pitch = 100,
    sound = sndpath.."goprone_03.wav"
})

sound.Add({
    name = "GASMASK_Inhale",
    channel = CHAN_WEAPON,
    volume = 1,
    level = 120,
    pitch = { 98, 102 },
    sound = { sndpath.."focus_inhale_01.wav", sndpath.."focus_inhale_02.wav", sndpath.."focus_inhale_03.wav", sndpath.."focus_inhale_04.wav" }
})

sound.Add({
    name = "GASMASK_Exhale",
    channel = CHAN_WEAPON,
    volume = 1,
    level = 120,
    pitch = { 98, 102 },
    sound = { sndpath.."focus_exhale_01.wav", sndpath.."focus_exhale_02.wav", sndpath.."focus_exhale_03.wav", sndpath.."focus_exhale_04.wav", sndpath .. "focus_exhale_05.wav" }
})

sound.Add({
    name = "GASMASK_BreathingLoop",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = "nextoren/weapons/items/gasmask/gasmask_breathing_loop.wav"
})

sound.Add({
    name = "GASMASK_BreathingLoop2",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = "nextoren/weapons/items/gasmask/gasmask_breathing_loop.wav"
})




SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Противогаз"
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/gasmask.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/gasmask.png"
end

SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/gmod4phun/w_contagion_gasmask.mdl"
SWEP.WorldModelReal = "models/gmod4phun/c_contagion_gasmask.mdl" 
SWEP.WorldModelExchange = false

SWEP.Slot = 99
SWEP.SlotPos = 99
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.WorkWithFake = true


SWEP.setlh = true
SWEP.setrh = true
SWEP.UseHands = true

SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(-1, -2, -2)

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsToggling = false

local matName = "pnv_invisible_mat_fixed"
if CLIENT then
    CreateMaterial(matName, "VertexLitGeneric", {
        ["$no_draw"] = "1"
    })
end

SWEP.AnimList = {
    ["deploy"] = {"draw", 0.5, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"use", 1.8, false, false, function(self)
        self.IsToggling = false
    end}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
end

function SWEP:Deploy()
    self.Initialzed = true
    self.IsToggling = false

    local owner = self:GetOwner()
    if IsValid(owner) then
        owner.GASMASK_Ready = true
        
        if owner.GASMASK_Equiped then
            self.setrh = false
            self.setlh = false
        else
            self.setrh = true
            self.setlh = true
            self:PlayAnim("deploy")
        end
    end

    self:SetHold(self.HoldType)
    return true
end

function SWEP:Holster()
    
    if self.IsToggling then return false end
    
    local owner = self:GetOwner()
    if IsValid(owner) and owner.GASMASK_Ready == false then return false end

    return true
end

function SWEP:OnDrop()
    self.IsToggling = false
    
    local owner = self:GetOwner()
    if IsValid(owner) and owner.GASMASK_Equiped then
        owner.GASMASK_Ready = false
        if owner.GASMASK_SetEquipped then
            owner:GASMASK_SetEquipped(false)
        end
        if owner.GASMASK_RequestToggle then
            owner:GASMASK_RequestToggle()
        end
    end
end

function SWEP:OnRemove()
    local wepID = self:EntIndex()
    timer.Remove("GasmaskToggle_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsToggling then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    self:SetNextPrimaryFire(CurTime() + 1.9)
    self:SetNextSecondaryFire(CurTime() + 1.9)

    
    self.IsToggling = true
    ply.GASMASK_Ready = false

    self:PlayAnim("use")

    if SERVER then
        local isEquipping = not ply.GASMASK_Equiped

        if ply.GASMASK_SetEquipped then
            ply:GASMASK_SetEquipped(isEquipping)
        end
        if ply.GASMASK_RequestToggle then
            ply:GASMASK_RequestToggle()
        end

        local wepID = self:EntIndex()
        timer.Create("GasmaskToggle_" .. wepID, 1.8, 1, function()
            if not IsValid(self) or not IsValid(ply) then return end

            ply.GASMASK_Ready = true
            self.IsToggling = false
        end)
    end
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
    return false
end


function SWEP:ThinkAdd()
    
    
    if self:GetOwner().GASMASK_Equiped and not self.IsToggling then
        self.setlh = false
        self.setrh = false
    else
        self.setlh = true
        self.setrh = true
    end
end


function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    local owner = self:GetOwner()

    if IsValid(wm) and IsValid(owner) then
        
        local shouldHide = owner.GASMASK_Equiped or self.IsToggling

        if shouldHide then
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