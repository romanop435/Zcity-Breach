if SERVER then AddCSLuaFile() end

SWEP.Base = "breach_melee_base"
SWEP.PrintName = "Топор"
SWEP.Category = "[NextOren] Melee"

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/axe.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/axe.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.HoldType = "melee2"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/breach_melee/w_fireaxe.mdl"


SWEP.WorldModelFake = "models/weapons/breach_melee/v_fireaxe.mdl"
SWEP.WorldModelExchange = false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.ismelee = true
SWEP.ismelee2 = true

SWEP.setlh = true
SWEP.setrh = true
SWEP.UseHands = true


SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(-1, 3, 1)

SWEP.PrimaryAttackDelay = 1.8
SWEP.SecondaryAttackDelay = 2.0
SWEP.PrimaryAttackImpactTime = 0.15 
SWEP.PrimaryAttackRange = 90
SWEP.PrimaryDamage = 60
SWEP.SecondaryDamage = 85
SWEP.DamageForce = 4

SWEP.PrimaryStamina = 20
SWEP.SecondaryStamina = 35

SWEP.SoundSwing = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.SoundHitFlesh = "weapons/cwc_cbar/nhit" .. math.random(1, 8) .. ".wav"
SWEP.SoundHitWorld = "weapons/cwc_cbar/wallheavy" .. math.random(1, 3) .. ".wav"


SWEP.AnimList = {
    ["deploy"] = "draw",
    ["idle"] = "idle01",
    ["hit"] = "misscenter1",
    ["hit_heavy"] = "hitcenter1"
}