if SERVER then AddCSLuaFile() end

SWEP.Base = "breach_medkit_base"
SWEP.PrintName = "Универсальная аптечка"
SWEP.Category = "RP"
SWEP.Spawnable = true

SWEP.ProgressIcon = "nextoren/gui/new_icons/med_1.png"

if CLIENT then
    SWEP.InvIcon = Material(SWEP.ProgressIcon)
    SWEP.IconOverride = SWEP.ProgressIcon
end

SWEP.Skin = 4
SWEP.HealPower = 4.5