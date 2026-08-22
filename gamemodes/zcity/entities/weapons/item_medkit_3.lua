if SERVER then AddCSLuaFile() end

SWEP.Base = "breach_medkit_base"
SWEP.PrintName = "Аптечка спец. помощи"
SWEP.Category = "RP"
SWEP.Spawnable = true

SWEP.ProgressIcon = "nextoren/gui/new_icons/med_2.png"

if CLIENT then
    SWEP.InvIcon = Material(SWEP.ProgressIcon)
    SWEP.IconOverride = SWEP.ProgressIcon
    SWEP.Desc = "Останавливает кровотечение любой тяжести, снимает болевой шок."
end

SWEP.Skin = 1
SWEP.HealPower = 3.0