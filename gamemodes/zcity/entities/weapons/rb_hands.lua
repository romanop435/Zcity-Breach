AddCSLuaFile()

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.PrintName = "Механические кисти"

SWEP.ViewModelFOV = 90

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/rb_hands.png" )

end

SWEP.UnDroppable = true
SWEP.UseHands = false

SWEP.ViewModel = Model( "models/jessev92/weapons/unarmed_c.mdl" )
SWEP.WorldModel = "models/imperator/rb_parts/hands.mdl"
SWEP.HoldType = "normal"


function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:CanPrimaryAttack()
	return true
end

if CLIENT then
	function SWEP:DrawWorldModel( flags )
		
		self:DrawModel( flags )
	end

	
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack( )
	return false
end

function SWEP:Reload() end

function SWEP:Deploy()
	
	
	
	
end

function SWEP:OnDrop()
	
	
end