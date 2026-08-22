


SWEP.PrintName		= "Scripted Weapon" 
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 8			
SWEP.Primary.DefaultClip	= 32		
SWEP.Primary.Automatic		= false		
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= 8			
SWEP.Secondary.DefaultClip	= 32		
SWEP.Secondary.Automatic	= false		
SWEP.Secondary.Ammo			= "Pistol"


function SWEP:Initialize()

	self:SetHoldType( "pistol" )

end


function SWEP:PrimaryAttack()

	
	if ( !self:CanPrimaryAttack() ) then return end

	
	self:EmitSound( "Weapon_AR2.Single" )

	
	self:ShootBullet( 150, 1, 0.01, self.Primary.Ammo )

	
	self:TakePrimaryAmmo( 1 )

	
	local owner = self:GetOwner()
	if ( !owner:IsNPC() ) then owner:ViewPunch( Angle( -1, 0, 0 ) ) end

end


function SWEP:SecondaryAttack()

	
	if ( !self:CanSecondaryAttack() ) then return end

	
	self:EmitSound("Weapon_Shotgun.Single")

	
	self:ShootBullet( 150, 9, 0.2, self.Secondary.Ammo )

	
	self:TakeSecondaryAmmo( 1 )

	
	local owner = self:GetOwner()
	if ( !owner:IsNPC() ) then owner:ViewPunch( Angle( -10, 0, 0 ) ) end

end


function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end


function SWEP:Think()
end


function SWEP:Holster( wep )
	return true
end


function SWEP:Deploy()
	return true
end


function SWEP:ShootEffects()

	local owner = self:GetOwner()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )		
	owner:MuzzleFlash()						
	owner:SetAnimation( PLAYER_ATTACK1 )		

end


function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )

	local owner = self:GetOwner()

	local bullet = {}
	bullet.Num		= num_bullets
	bullet.Src		= owner:GetShootPos()			
	bullet.Dir		= owner:GetAimVector()			
	bullet.Spread	= Vector( aimcone, aimcone, 0 )		
	bullet.Tracer	= tracer || 5						
	bullet.Force	= force || 1						
	bullet.Damage	= damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo

	owner:FireBullets( bullet )

	self:ShootEffects()

end


function SWEP:TakePrimaryAmmo( num )

	
	if ( self:Clip1() <= 0 ) then

		//if ( self:Ammo1() <= 0 ) then return end

		//self:GetOwner():RemoveAmmo( num, self:GetPrimaryAmmoType() )

	return end

	self:SetClip1( self:Clip1() - num )

end


function SWEP:TakeSecondaryAmmo( num )

	
	if ( self:Clip2() <= 0 ) then

		if ( self:Ammo2() <= 0 ) then return end

		self:GetOwner():RemoveAmmo( num, self:GetSecondaryAmmoType() )

	return end

	self:SetClip2( self:Clip2() - num )

end


function SWEP:CanPrimaryAttack()

	if ( self:Clip1() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:Reload()
		return false

	end

	return true

end


function SWEP:CanSecondaryAttack()

	if ( self:Clip2() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextSecondaryFire( CurTime() + 0.2 )
		return false

	end

	return true

end


function SWEP:OnRemove()
end


function SWEP:OwnerChanged()
end


function SWEP:Ammo1()
	if !self:GetOwner().GetAmmoCount then return 0 end

	return self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )
end


function SWEP:Ammo2()
	if !self:GetOwner().GetAmmoCount then return 0 end
	
	return self:GetOwner():GetAmmoCount( self:GetSecondaryAmmoType() )
end


function SWEP:DoImpactEffect( tr, nDamageType )

	return false

end