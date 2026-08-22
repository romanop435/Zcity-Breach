AddCSLuaFile()

SWEP.PrintName		= "Цвайхендер"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.Base = "adv_melee_base"
SWEP.Category = "Advanced Melee"

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= Model("models/weapons/shaky/mordhau/v_zweihander.mdl")
SWEP.WorldModel		= Model("models/weapons/shaky/mordhau/w_zweihander.mdl")

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.droppable				= false
SWEP.UnDroppable 			= true

SWEP.SwingWindUp = 650 
SWEP.SwingRelease = 525 
SWEP.SwingRecovery = 700 

SWEP.StabWindUp = 725 
SWEP.StabRelease = 325 
SWEP.StabRecovery = 700 

SWEP.ParryCooldown = 700 
SWEP.ParryWindow = 325 

SWEP.Length = 135 

SWEP.MissCost = 10
SWEP.FeintCost = 10
SWEP.MorphCost = 7
SWEP.StaminaDrain = 19
SWEP.ParryDrainNegation = 13

SWEP.SwingDamage = 40
SWEP.SwingDamageType = DMG_CLUB
SWEP.StabDamage = 20
SWEP.StabDamageType = DMG_CLUB

SWEP.HoldType = "melee2" 
SWEP.MainHoldType = "melee2" 
SWEP.SwingHoldType = "melee2"
SWEP.StabHoldType = "knife"

SWEP.IdleAnimVM = "mordhau_idle" 

SWEP.ParryAnim = "aoc_flamberge_block"
SWEP.ParryAnimWeight = 0.9
SWEP.ParryAnimSpeed = 0.7
SWEP.ParryAnimVM = {"block"}

SWEP.SwingAnim = "aoc_flamberge_slash_02"
SWEP.SwingAnimWeight = 1
SWEP.SwingAnimWindUpMultiplier = 6
SWEP.SwingAnimVM = {"swing"}

SWEP.AttackSounds = {
	"mordhau/weapons/wooshes/bladedlarge/woosh_bladedlarge-01.wav",
	"mordhau/weapons/wooshes/bladedlarge/woosh_bladedlarge-02.wav",
	"mordhau/weapons/wooshes/bladedlarge/woosh_bladedlarge-03.wav",
	"mordhau/weapons/wooshes/bladedlarge/woosh_bladedlarge-04.wav",
	"mordhau/weapons/wooshes/bladedlarge/woosh_bladedlarge-05.wav",
	"mordhau/weapons/wooshes/bladedlarge/woosh_bladedlarge-06.wav",
}


SWEP.HitSolidSounds = {
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_01.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_02.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_03.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_04.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_05.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_06.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_07.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_08.wav",
}

SWEP.HitParry = {
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_01.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_02.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_03.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_04.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_05.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_06.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_07.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladed_huge_block_08.wav",
}


SWEP.ParrySounds = {
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_01.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_02.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_03.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_04.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_05.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_06.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_07.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_08.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_09.wav",
	"mordhau/weapons/block/combined/bladedhuge/sw_bladedhuge_wasblocked_10.wav",
}

SWEP.StabWindUpAnim = "aoc_flamberge_stab.smd"
SWEP.StabAnim = "aoc_flamberge_stab.smd"
SWEP.StabAnimWeight = 1
SWEP.StabAnimWindUpMultiplier = 3
SWEP.StabAnimVM = {"swing_sharp"}