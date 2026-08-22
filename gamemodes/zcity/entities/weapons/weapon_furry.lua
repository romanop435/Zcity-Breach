
AddCSLuaFile()
SWEP.Base = "breach_scp_base"
SWEP.PrintName = "Лапки"
SWEP.Author = "Imperator"
SWEP.Purpose = ""
SWEP.HoldType         = "zombie"
SWEP.droppable				= false
SWEP.UnDroppable = true

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/furry_hands.png" )

end

SWEP.AbilityIcons = {
  {

    [ "Name" ] = "Удар",
    [ "Description" ] = "Вы царапаете свою жертву",
    [ "Cooldown" ] = 1,
    [ "CooldownTime" ] = 0,
    [ "KEY" ] = "LMB",
    [ "Using" ] = false,
    [ "Icon" ] = "nextoren/gui/special_abilities/xmas/lmb.png",
    [ "Abillity" ] = nil

  },


























}

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_zombieswep.mdl" )
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 90
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 48

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )

function SWEP:Initialize()

	
	
	self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= ACT_HL2MP_IDLE_ZOMBIE
	self.ActivityTranslate[ ACT_MP_WALK ]						= ACT_HL2MP_WALK_ZOMBIE_01
	self.ActivityTranslate[ ACT_MP_RUN ]						= ACT_HL2MP_RUN_ZOMBIE
	self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ]				= ACT_HL2MP_IDLE_CROUCH_ZOMBIE
	self.ActivityTranslate[ ACT_MP_CROUCHWALK ]					= ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
	self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= ACT_GMOD_GESTURE_RANGE_ZOMBIE
	self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= ACT_GMOD_GESTURE_RANGE_ZOMBIE
	self.ActivityTranslate[ ACT_MP_JUMP ]						= ACT_ZOMBIE_LEAPING
	self.ActivityTranslate[ ACT_RANGE_ATTACK1 ]					= ACT_GMOD_GESTURE_RANGE_ZOMBIE

end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 2, "Combo" )

end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end
function SWEP:PrimaryAttack( right )

	self:SetNextPrimaryFire(CurTime() + self.AbilityIcons[1].Cooldown)
  	self.AbilityIcons[1].CooldownTime = CurTime() + self.AbilityIcons[1].Cooldown

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	
	
	
	
	if SERVER then
		local target
		for k,v in ipairs(ents.FindInSphere(self.Owner:GetPos() , 50)) do
			if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_FURRY and v != self.Owner then
				target = v
			end
		end
		if target then
			
			target:SetupNormal()
			target:ApplyRoleStats( BREACH_ROLES.MINIGAMES.minigame.roles[11] )
			target:SetPos( target:GetPos() + Vector(0,0,-20) )
			target:SetNoCollideWithTeammates(true)

			target:SetNamesurvivor(table.Random({"Пушистая обнимушка","Нежная мурчалка","Мохнатая лапуська","Мягкая жмякалка","Облачная мягонька","Сладкая кексик","Медовая плюшка","Клубничная няшка","Карамельная тянучка","Ванильная пышечка","Маленькая чихуня","Добрая бусинка","Рыжая хвостушка","Забавная мордашка","Ласковая лапочка",}))

			target:SetMoveType(MOVETYPE_WALK)
			target:EmitSound( "nextoren/toms_screams.mp3", 89, 100, 1, CHAN_WEAPON, 0, 0 )
		end
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:EmitSound( SwingSound )
	self:UpdateNextIdle()
	
	
	

end
function SWEP:SecondaryAttack()
	if true then return end
	self:SetNextSecondaryFire(CurTime() + self.AbilityIcons[2].Cooldown)
  	self.AbilityIcons[2].CooldownTime = CurTime() + self.AbilityIcons[2].Cooldown
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	if SERVER then
		local ent = ents.Create("zck_snowball_damager")
		if (not IsValid(ent)) then return end
		ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 25))
		ent:SetAngles(self.Owner:EyeAngles())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()

		if (not IsValid(phys)) then
			ent:Remove()

			return
		end

		local velocity = self.Owner:GetAimVector()
		velocity = velocity * phys:GetMass() * 2000
		velocity = velocity + (VectorRand() * 10) 
		phys:ApplyForceCenter(velocity)
	end
	

end

function SWEP:Reload()
	if true then return end
  	if self.AbilityIcons[3].CooldownTime > CurTime() then return end
    self.AbilityIcons[3].CooldownTime = CurTime() + self.AbilityIcons[3].Cooldown
	local hand_pos = self.Owner:GetPos() + Vector(0,0,40)
	local angles = self.Owner:GetAngles()
	ParticleEffectAttach("slave_finish", PATTACH_ABSORIGIN_FOLLOW, self.Owner, 8 )
	ParticleEffect( "infect2", hand_pos, angles, self.Owner )
	if SERVER then
		self.Owner:Freeze(true)
		timer.Simple( 2, function()
			self.Owner:Freeze(false)
			for k,v in ipairs(ents.FindInSphere(self.Owner:GetPos(),200)) do
				if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:Alive() and v != self.Owner then
				local hand_pos = v:GetPos() + Vector(0,0,40)
				local angles = v:GetAngles()
				ParticleEffectAttach("slave_finish", PATTACH_ABSORIGIN_FOLLOW, v, 8 )
				ParticleEffect( "infect2", hand_pos, angles, v )
				
				timer.Simple( 0.5, function()
					v:TakeDamage(1000,self.Owner)
					v:EmitSound( "nextoren/scp/542/scp_542_finish.ogg", 120, math.random( 80, 100 ), 1, CHAN_BODY )
				end)
				end
			end
		end)
	end
end

local phys_pushscale = GetConVar( "phys_pushscale" )

function SWEP:DealDamage()

	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self.Owner:LagCompensation( true )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end

	
	if ( tr.Hit && !( game.SinglePlayer() && CLIENT ) ) then
		self:EmitSound( HitSound )
	end

	local hit = false
	local scale = phys_pushscale:GetFloat()

	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) ) then
		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( math.random( 8, 12 ) )

		if ( anim == "fists_left" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * 4912 * scale + self.Owner:GetForward() * 9998 * scale ) 
		elseif ( anim == "fists_right" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * -4912 * scale + self.Owner:GetForward() * 9989 * scale )
		elseif ( anim == "fists_uppercut" ) then
			dmginfo:SetDamageForce( self.Owner:GetUp() * 5158 * scale + self.Owner:GetForward() * 10012 * scale )
			dmginfo:SetDamage( math.random( 12, 24 ) )
		else
			dmginfo:SetDamageForce( self.Owner:GetForward() * 14910 * scale ) 
		end

		SuppressHostEvents( NULL ) 
		tr.Entity:TakeDamageInfo( dmginfo )
		SuppressHostEvents( self.Owner )

		hit = true

	end

	if ( IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * 80 * phys:GetMass() * scale, tr.HitPos )
		end
	end

	if ( SERVER ) then
		if ( hit && anim != "fists_uppercut" ) then
			self:SetCombo( self:GetCombo() + 1 )
		else
			self:SetCombo( 0 )
		end
	end

	self.Owner:LagCompensation( false )

end

function SWEP:OnDrop()

	self:Remove() 

end

function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )
	
	local vm = self.Owner:GetViewModel()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	return true

end

function SWEP:Holster()

	self:SetNextMeleeAttack( 0 )

	return true

end

function SWEP:Think()

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()

	if ( idletime > 0 && CurTime() > idletime ) then

		self:SendWeaponAnim( ACT_VM_IDLE )

		self:UpdateNextIdle()

	end

	local meleetime = self:GetNextMeleeAttack()

	if ( meleetime > 0 && CurTime() > meleetime ) then

		self:DealDamage()

		self:SetNextMeleeAttack( 0 )

	end

	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then

		self:SetCombo( 0 )

	end

end
