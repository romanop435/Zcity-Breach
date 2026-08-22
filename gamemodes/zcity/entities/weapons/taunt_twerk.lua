AddCSLuaFile()

SWEP.Spawnable = true 
SWEP.AdminOnly = false 

SWEP.WeaponName = "v92_eq_unarmed" 
SWEP.PrintName = "sexy dance" 

SWEP.ViewModelFOV = 90 

SWEP.droppable				= false

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false

end

SWEP.UnDroppable = true
SWEP.UseHands = true
SWEP.ViewModel = Model( "models/jessev92/weapons/unarmed_c.mdl" )
SWEP.WorldModel = ""
SWEP.HoldType = "normal"


SWEP.Primary.ClipSize = -1

SWEP.Primary.DefaultClip = -1

SWEP.Primary.Automatic = true

SWEP.Primary.Ammo = "none"



SWEP.Secondary.ClipSize = -1

SWEP.Secondary.DefaultClip = -1

SWEP.Secondary.Automatic = true

SWEP.Secondary.Ammo = "none"

function SWEP:ShouldDrawViewModel()
	return false
end

function SWEP:Think()
	if CLIENT and self.Owner:GetNWBool("Taunt_ThirdPerson") then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.pos = self.Owner:GetPos() + Vector(0, 0, 35) + self.Owner:GetAngles():Forward() * -15
			dlight.r = 252
			dlight.g = 70
			dlight.b = 170
			dlight.brightness = 2
			dlight.Decay = 1000
			dlight.Size = 100
			dlight.DieTime = CurTime() + 1
		end
	end
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack( right )

	self:SetNextPrimaryFire(CurTime() +1)

	if SERVER then


		if self.Owner.ForceAnimSequence == self.Owner:LookupSequence("0_twerk") then

			self.Owner:StopForcedAnimation()

		elseif self.Owner.ForceAnimSequence == nil and self.Owner:GetMoveType() == MOVETYPE_WALK then

			local function stop()

				
				
				
				
				

			end

			self.Owner:EmitSound("rxsend_april_event/sexydance.ogg", 55, 100, 1, CHAN_VOICE, nil, 1)

			self.Owner:SetForcedAnimation('0_twerk', 60, function()
			end, stop, stop)
			
			
				
				
				
			

		end

	end

end


function SWEP:CanSecondaryAttack( )

	return false

end

function SWEP:Reload() end

function SWEP:Deploy( )

end

function SWEP:OnDrop( )

	if ( self && self:IsValid() ) then

		self:Remove( )

	end

end
