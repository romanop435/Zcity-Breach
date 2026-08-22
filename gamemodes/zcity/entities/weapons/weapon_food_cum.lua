AddCSLuaFile()

SWEP.PrintName = "Странная вода"
SWEP.Author = "AirPuppy"
SWEP.Category = "Food"
SWEP.Base = "weapon_food_base"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/props/cryts_food/drink_beer03.mdl")
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
		model = "models/props/cryts_food/drink_beer03.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(-10, 220, 180),
		offset = Vector(4.5, 2, -1),
		scale = 0.9
	},
	worldModel = {
		model = "models/props/cryts_food/drink_beer03.mdl",
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
		local a = self.Owner
		if id == FoodSwep.ANIMATION_EVENT_HALF then 
			if a:SteamID() == "STEAM_0:0:503174554" or a:SteamID() == "STEAM_0:1:39271377" then
				a:EmitSound("cpthazama/scp/294/ahh.mp3", 100, 100)
			else
				self:Remove()
				a:EmitSound("cpthazama/scp/294/spit.mp3", 100, 100)
        		--a:ScreenFade(SCREENFADE.IN, Color(150, 0, 0, 100), 12, 8)
        		timer.Simple(1, function()
        		a:ViewPunch( Angle( -10, 10, 10 ))
        		end)
        		self:Remove()
        		DarkRP.talkToRange(a, a:Nick() .. " выпил странное на вкус молоко.", "", GAMEMODE.Config.meDistance)
        		timer.Simple(10, function()
        		    a:ViewPunch( Angle( -50, 90, 20 ))
        		    a:ScreenFade(SCREENFADE.IN, Color(150, 0, 0, 100), 12, 8)
        		    a:EmitSound("cpthazama/scp/294/vomit.mp3", 100, 100)
        		    timer.Simple(1, function()
        		        a:TakeDamage(a:Health() * 0.1,a)
        		        timer.Simple(1, function()
        		            a:TakeDamage(a:Health() * 0.1,a)
        		            timer.Simple(1, function()
        		                a:TakeDamage(a:Health() * 0.1,a)
        		                timer.Simple(1, function()
        		                    a:TakeDamage(a:Health() * 0.1,a)       
        		                    timer.Simple(1, function()
        		                        a:TakeDamage(a:GetMaxHealth(),a)       
        		                        a:EmitSound("cpthazama/scp/294/burn.mp3", 100, 100)
        		                    end)
        		                end)
        		            end)
        		        end)
        		    end)
        		end)
			end
		end
	end
end