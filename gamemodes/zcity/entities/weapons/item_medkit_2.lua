if SERVER then AddCSLuaFile() end

SWEP.Base = "breach_medkit_base"
SWEP.PrintName = "Офисная аптечка"
SWEP.Category = "RP"
SWEP.Spawnable = true

SWEP.ProgressIcon = "nextoren/gui/new_icons/med_4.png"

if CLIENT then
    SWEP.InvIcon = Material(SWEP.ProgressIcon)
    SWEP.IconOverride = SWEP.ProgressIcon
end

SWEP.Skin = 3
SWEP.HealPower = 2.8