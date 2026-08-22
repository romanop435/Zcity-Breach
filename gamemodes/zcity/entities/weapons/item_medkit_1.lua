if SERVER then AddCSLuaFile() end

SWEP.Base = "breach_medkit_base"
SWEP.PrintName = "Аптечка Первой Помощи"
SWEP.Category = "RP"
SWEP.Spawnable = true

SWEP.ProgressIcon = "nextoren/gui/new_icons/med_3.png"

if CLIENT then
    SWEP.InvIcon = Material(SWEP.ProgressIcon)
    SWEP.IconOverride = SWEP.ProgressIcon
end

SWEP.Skin = 2
SWEP.HealPower = 2.0