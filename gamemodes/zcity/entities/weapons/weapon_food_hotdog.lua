AddCSLuaFile()

SWEP.PrintName = "Гамбургер"
SWEP.Author = "AirPuppy"
SWEP.Category = "Food"
SWEP.Base = "weapon_food_base"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/props/cryts_food/meal_hamburger.mdl")
SWEP.ViewModelFOV = 60
SWEP.UseHands = true

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Config = {

	holdType = "slam",
	viewModel = {
		model = "models/props/cryts_food/meal_hamburger.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(90, 0, 180),
		offset = Vector(-3, 4.6, -0.2),
		scale = 0.8
	},
	worldModel = {
		model = "models/props/cryts_food/meal_hamburger.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(90, 0, 180),
		offset = Vector(-3, 4.5, -0.2),
		scale = 0.8
	},
	Animations = {
		["default"] = {
			[0] = {
				view = {
					["ValveBiped.cube"] = {	
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.cube1"] = { 
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.cube2"] = { 
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.cube3"] = { 
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(20, 0, 0)
					}
				}
			},
			[1] = {
				easing = FoodSwep.ANIMATION_EASE_IN_EASE_OUT,
				duration = 1.7,
				view = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -50, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(-45, -20, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(70, -25, -90)
					},
					["ValveBiped.Bip01_Spine4"] = {	
						pos = Vector(0, -8, -15)
					}
				},
				world = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -75, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(5, 9, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(25, 10, 20)
					}
				}
			}
		}
	}
}

function SWEP:OnAnimationEvent(id)
	if SERVER then
		local a = self.Owner
		if id == FoodSwep.ANIMATION_EVENT_HALF then 
			self:Remove()
	    	a:setDarkRPVar("Energy", a:getDarkRPVar("Energy") + 90)
        	if a:getDarkRPVar("Energy") > 100 then
        	    a:setDarkRPVar("Energy", 100)
        	end
	    	self:Remove()
	    	a:EmitSound("vo/sandwicheat09.ogg", 100, 100)
	    	DarkRP.talkToRange(a, a:Nick() .. " сьел очень вкусный бургер", "", GAMEMODE.Config.meDistance)
		end
	end
end