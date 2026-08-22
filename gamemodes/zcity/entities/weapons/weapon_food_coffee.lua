AddCSLuaFile()

SWEP.PrintName = "Вода"
SWEP.Author = "AirPuppy"
SWEP.Category = "Food"
SWEP.Base = "weapon_food_base"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/props/cryts_food/drink_nexsoda.mdl")
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
		model = "models/props/cryts_food/drink_nexsoda.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(-10, 220, 180),
		offset = Vector(4.5, 2, -1),
		scale = 0.9
	},
	worldModel = {
		model = "models/props/cryts_food/drink_nexsoda.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(0, 130, 180),
		offset = Vector(-1.5, 2, -4),
		scale = 0.9
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
						angle = Angle(0, -15, -65)
					}
				}
			},
			[1] = {
				easing = FoodSwep.ANIMATION_EASE_DRINK,
				duration = 2.5,
				view = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -50, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle( -45, -20, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(30, -25, -90)
					},
					["ValveBiped.Bip01_Spine4"] = {	
						pos = Vector(0, -8, -12)
					}
				},
				world = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -85, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(5, 25, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(35, 20, 16)
					}
				}
			}
		}
	}
}

function SWEP:OnAnimationEvent(id)
	if SERVER then
		if id == FoodSwep.ANIMATION_EVENT_HALF then 
			if self.Owner:GetUserGroup() == "user" then
				self.Owner:setDarkRPVar("Energy", self.Owner:getDarkRPVar("Energy") + 10)
            	if self.Owner:getDarkRPVar("Energy") > 20 then
            	    self.Owner:setDarkRPVar("Energy", 20)
            	end
	        	self.Owner:EmitSound("cpthazama/scp/294/cough.mp3", 100, 100)
       		elseif self.Owner:GetUserGroup() == "premium" then
				self.Owner:setDarkRPVar("Energy", self.Owner:getDarkRPVar("Energy") + 40)
            	if self.Owner:getDarkRPVar("Energy") > 80 then
            	    self.Owner:setDarkRPVar("Energy", 80)
            	end
	   		    self.Owner:EmitSound("cpthazama/scp/294/ahh.mp3", 100, 100)
       		else
				self.Owner:setDarkRPVar("Energy", self.Owner:getDarkRPVar("Energy") + 20)
            	if self.Owner:getDarkRPVar("Energy") > 40 then
            	    self.Owner:setDarkRPVar("Energy", 40)
            	end
	   		    self.Owner:EmitSound("cpthazama/scp/294/ew2.mp3", 100, 100)
       		end
			self:Remove()
		end
	end
end