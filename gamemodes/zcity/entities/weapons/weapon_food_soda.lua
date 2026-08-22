AddCSLuaFile()

SWEP.PrintName = "Странная вода"
SWEP.Author = "AirPuppy"
SWEP.Category = "Food"
SWEP.Base = "weapon_food_base"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/cultist/items/drinks/w_energy_drink.mdl")
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
SWEP.HoldType		= "items"

SWEP.Config = {
	holdType = "items",
	viewModel = {
		model = "models/cultist/items/drinks/w_energy_drink.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(-10, 40, 180),
		offset = Vector(-4.1, -2, 2),
		scale = 1
	},
	worldModel = {
		model = "models/cultist/items/drinks/w_energy_drink.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(0, 130, 180),
		offset = Vector(-1.5, -2, -4),
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
		local a = self.Owner
		if id == FoodSwep.ANIMATION_EVENT_HALF then 
			a:EmitSound("scp294/slurp.ogg", 100, 100)

  			timer.Simple( 2, function()
			
  			  if ( !( self && self:IsValid() ) || !( self.Owner && self.Owner:IsValid() ) ) then return end
			
  			  self.Owner:Boosted( 5, math.random( 10, 15 ) )
			
  			  local max_health = self.Owner:GetMaxHealth()
  			  self.Owner:SetHealth( math.Clamp( self.Owner:Health() + max_health * .25, 0, max_health ) )
			
  			  timer.Simple( .25, function()

  			    if ( self && self:IsValid() ) then
				
  			      self:Remove()
				
  			    end
			
  			  end )
		  
  			end )
		end
	end
end