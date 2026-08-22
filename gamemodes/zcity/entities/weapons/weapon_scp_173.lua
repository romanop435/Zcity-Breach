AddCSLuaFile()

SWEP.AbilityIcons = {

	{

		["Name"] = "Blind",
		["Description"] = "Using this ability, you temporarily blind all the players standing next to you. ( Around 300 meters )",
		["Cooldown"] = 110,
		["CooldownTime"] = 0,
		["KEY"] = _G[ "KEY_F" ],
		["Using"] = false,
		["Icon"] = "nextoren/gui/special_abilities/scp173_stun.png"

	},
	{

		["Name"] = "Eye Indicator",
		["Description"] = "This indicator shows whether another player is looking at you or not.",
		["Cooldown"] = "Passive",
		["CooldownTime"] = 0,
		["KEY"] = "",
		["Using"] = false,
		["Icon"] = "nextoren/gui/special_abilities/scp173_eye.png"

	},

	{

		["Name"] = "Return to statue",
		["Description"] = "Teleports you back to your statue entity.",
		["Cooldown"] = 15,
		["CooldownTime"] = 0,
		["KEY"] = _G[ "KEY_B" ],
		["Using"] = false,
		["Icon"] = "nextoren/gui/special_abilities/scp173_invisibility.png"

	},

}

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/vinrax/props/keycard.mdl"
SWEP.WorldModel		= "models/vinrax/props/keycard.mdl"
SWEP.PrintName		= "SCP-173"
SWEP.Slot			= 0
SWEP.SlotPos		= 0
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false
SWEP.Base = "breach_scp_base"

SWEP.StatueModel = Model( "models/cultist/scp/173.mdl" )
SWEP.StatueEntity = nil
SWEP.AttackDelay			= 0.3

SWEP.droppable				= false
SWEP.CColor					= Color(0,255,0)
SWEP.SnapSound				= Sound( "snap.wav" )

SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false

SWEP.SpecialDelay			= 80
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.NextAttackW			= 0
SWEP.IsLooking = false
SWEP.CustomRemoveFunc = true

SWEP.watching = 0
SWEP.UsingFirstAbility = true
SWEP.UsingSecondAbility = false

function SWEP:DrawWorldModel()

	return false

end

function SWEP:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Statue" )

	self:NetworkVar( "Float", 0, "Watching" )

end

function SWEP:OnRemove()
	timer.Remove("BlinkTimer")
end

local w = 64
local h = 64
local padding = 133

local SCP173Mat = Material( "nextoren/gui/special_abilities/scp173_eye.png", "smooth" )

local function DrawHUD()
end

function SWEP:Initialize()
	if player.GetCount() < 10 then return end
	self.AbilityIcons[1].CooldownTime = CurTime() + 45
end



function SWEP:Deploy()

	self.Owner:SetNoDraw(true)

	self.Owner:SetRunSpeed(250)

	self.Owner:SetWalkSpeed(250)

timer.Create("BlinkTimer", GetConVar("br_time_blinkdelay"):GetInt(), 0, function()
	local time = GetConVar("br_time_blink"):GetFloat()
	
	for k,v in player.Iterator() do
		local pl = v:GetTable()

		if pl.canblink and pl.blinkedby173 == false and pl.usedeyedrops == false then
			net.Start("PlayerBlink")
				net.WriteFloat(time)
			net.SendPVS(self:GetOwner():GetPos())
			pl.isblinking = true
		end
	end
	timer.Create("UnBlinkTimer", time + 0.2, 1, function()
		for k,v in player.Iterator() do
			local pl = v:GetTable()

			if pl.blinkedby173 == false then
				pl.isblinking = false
			end
		end
	end)
end)

	self.Owner:DrawViewModel( false )
	self.Owner:DrawShadow( false )
	self.Owner:SetCollisionGroup( COLLISION_GROUP_WORLD )
	

	hook.Add( "PlayerButtonDown", "SCP_173_Ability", function( activator, butt )

		if ( butt != KEY_F and butt != KEY_B ) then return end

		local wep = activator:GetActiveWeapon()
		if ( activator:GTeam() != TEAM_SCP || wep && wep:IsValid() && wep:GetClass() != "weapon_scp_173" ) then return end

		local self = wep

		if butt == KEY_B then

			if wep.AbilityIcons[3].CooldownTime > CurTime() then return end

			if SERVER then self.Owner:SetPos(self.StatueEntity:GetPos()) end
			wep.AbilityIcons[3].CooldownTime = CurTime() + wep.AbilityIcons[3].Cooldown

			return
		end

		if wep.AbilityIcons[1].CooldownTime > CurTime() then return end

		if !self.Owner:IsLZ() and !self.Owner:IsHardZone() and !self.Owner:IsEntrance() then
			self:SetNextSecondaryFire( CurTime() + 5 )
			self.AbilityIcons[1].CooldownTime = CurTime() + 5
			BREACH.SendClientEvent(self.Owner, "ability_cooldown", {index = 1, seconds = 5})
			if SERVER then self.Owner:RXSENDNotify("l:scp173_bad_zone") end
			return
		end


		local plys = ents.FindInSphere(self.Owner:GetPos(), 400)

		if SERVER then

			net.Start("ForcePlaySound")
			net.WriteString("nextoren/others/horror/horror_2.ogg")
			net.Send(activator)

			activator:ScreenFade(SCREENFADE.IN, Color(255,0,0,45), 5, 0.5)

			local tab = {}

			for i = 1, #plys do

				local ply = plys[i]

				if !ply:IsPlayer() then continue end
				if ply:GTeam() == TEAM_SPEC then continue end
				if ply:GTeam() == TEAM_SCP then continue end

				tab[#tab + 1] = ply

				ply:ScreenFade(SCREENFADE.IN, Color(0,0,0, 245), 1, 6)
				ply.SCP173Effect = true

				timer.Simple(6, function()
					if IsValid(ply.SCP173Effect) then
						ply.SCP173Effect = nil
					end
				end)

			end

			net.Start("ForcePlaySound")
			net.WriteString("nextoren/others/horror/horror_2.ogg")
			net.Send(tab)

		end

		BREACH.SendClientEvent(self.Owner, "ability_cooldown", {index = 1, seconds = wep.AbilityIcons[1].Cooldown})
		wep.AbilityIcons[1].CooldownTime = CurTime() + wep.AbilityIcons[1].Cooldown

	end )


	timer.Simple( .25, function()

		if ( self && self:IsValid() ) then

			self.Owner:SetCustomCollisionCheck( false )

		end

	end )

	if ( SERVER ) then

		local activatecd = 0

		hook.Add( "PlayerUse", "Teleport173ToLocation", function( activator, ent )

			if ( !activator:GTeam() == TEAM_SCP ) then return end

			local wep = activator:GetActiveWeapon()

			if ( wep != NULL && activator:HasWeapon( "weapon_scp_173" ) ) then

				if activatecd > CurTime() then return false end

				local ent = activator:GetEyeTrace().Entity

				activatecd = CurTime() + 1

				

				if ( wep.watching > 0 ) then return false end

				if ( wep.StatueEntity ) then

					if IsValid(ent) and ( ent:GetClass() == "func_button" or ent:GetClass() == "prop_dynamic" or ent:GetClass() == "func_door" ) then

						wep.StatueEntity:SetPos( Vector( activator:GetPos().x, activator:GetPos().y, GroundPos( activator:GetPos() ).z ) )
						wep.StatueEntity:SetAngles( Angle( 0, activator:GetAngles().y + 90, 0 ) )

					end

				end

			end

		end )

		self.Owner:DrawWorldModel( false )
		self.Owner:SetBloodColor( DONT_BLEED )

		self.StatueEntity = ents.Create( "base_gmodentity" )
		self.StatueEntity:SetPos( self.Owner:GetPos() )
		self.StatueEntity:SetModel( "models/cultist/scp/173.mdl")
		self.StatueEntity:SetAngles( self.Owner:GetAngles() )
		self.StatueEntity:SetOwner( self.Owner )
		self.StatueEntity:SetModelScale( 1.1, 0 )

		
		
		
		self.StatueEntity:SetSolid( SOLID_BBOX )
		
		

		self.StatueEntity.OnTakeDamage = function( target, dmginfo )

			if ( self.StatueEntity && self.StatueEntity:IsValid() ) then

				self.StatueEntity:GetOwner():TakeDamage( dmginfo:GetDamage() * 2, dmginfo:GetAttacker(), dmginfo:GetInflictor() )

			end

		end

		self.StatueEntity.Think = function( self )

			if ( !( self:GetOwner() && self:GetOwner():IsValid() && self:GetOwner():Health() > 0 && self:GetOwner():GTeam() == TEAM_SCP ) ) then

				self:Remove()

			end

		end

		self.StatueEntity:Spawn()
		self.StatueEntity:SetModel( "models/cultist/scp/173.mdl")
		self:SetStatue( self.StatueEntity )

	end

end

if ( SERVER ) then

	function SWEP:Holster()
		timer.Remove("BlinkTimer")
		if ( self.StatueEntity && self.StatueEntity:IsValid() ) then

			self.StatueEntity:Remove()
			self.Owner:SetNoDraw( false )
			self.Owner:SetNotSolid( false )

		end

	end

end

local vec_forward = Vector( 70 )

function SWEP:IsLookingAt( ply )

	local statue = ply:GetAimVector():Dot( ( self.StatueEntity:GetPos() - ply:GetPos() + vec_forward ):GetNormalized() )
	local ghost = ply:GetAimVector():Dot( ( self.Owner:GetPos() - ply:GetPos() + vec_forward ):GetNormalized() )

	return ( statue > .39  )

end

local team_spec_index = TEAM_SPEC

function SWEP:Think()
	local watching = self:GetWatching()
	if watching == 0 then
		self.AbilityIcons[2].CooldownTime = 0
	else
		self.AbilityIcons[2].CooldownTime = CurTime() + watching
	end

	if ( !self.StatueEntity || !self.StatueEntity:IsValid() ) then return end

	if ( SERVER && self.Owner:GetPos():DistToSqr( self.StatueEntity:GetPos() ) > 250000 && !self.UsingAbillity ) then

		

			self.StatueEntity:SetPos( Vector( self.Owner:GetPos().x, self.Owner:GetPos().y, GroundPos( self.Owner:GetPos() ).z ) )

		

	end

	if ( SERVER && self.Owner:GetPos():DistToSqr( self.StatueEntity:GetPos() ) > 90000 && !self.UsingAbillity ) then

		if !self.IsLooking and self.Owner:IsLineOfSightClear( self.StatueEntity ) then
			self:PrimaryAttack()
		else
			local vel = self.Owner:GetVelocity() * -4
			vel[2] = math.Clamp( vel[2], 0, 10 )

			self.Owner:SetVelocity( vel )

			if ( ( self.NextTip || 0 ) <= CurTime()  ) then

				self.NextTip = CurTime() + 2

				self.Owner:BrTip( 3, "[ZCity Breach]", Color( 210, 0, 0, 200 ), "l:dont_go_far_away_from_body", Color( 255, 0, 0, 180 ) )

			end
		end

	end

	self.watching = 0

	local players = player.GetAll()

	for i = 1, #players do

		local v = players[ i ]

		if ( v && v:IsValid() && v:GTeam() != team_spec_index && v:Health() > 0 && v != self.Owner && v.canblink && v:IsLineOfSightClear( self.StatueEntity ) ) then

			local tr_eyes = util.TraceLine( {

				start = v:EyePos() + v:EyeAngles():Forward() * 15,
				endpos = self.StatueEntity:EyePos(),

			} )

			local tr_center = util.TraceLine( {

				start = v:LocalToWorld( v:OBBCenter() ),
				endpos = self.StatueEntity:LocalToWorld( self.StatueEntity:OBBCenter() ),
				filter = v

			} )

			

				if ( self:IsLookingAt( v ) && !v.isblinking && !v.blinkedby173 && v.SCP173Effect != true ) then

					self.watching = self.watching + 1

				end

			

		end

	end

	if SERVER then 
		self:SetWatching(self.watching)
	end

	self.AbilityIcons[2].CooldownTime = CurTime() + self:GetWatching()

	if ( !self:GetNoDraw() ) then

		self:SetNoDraw( true )

	end

	if ( self.watching > 0 ) then

		self.IsLooking = true

	else

		self.IsLooking = false

	end

end

if ( SERVER ) then

	function SWEP:Reload()

		if ( self.StatueEntity && self.StatueEntity:IsValid() ) then

			self.Owner:SetPos( self.StatueEntity:GetPos() )

		end


	end

end

local tr_maxs = Vector( 20, 20, 20 )

function SWEP:PrimaryAttack()

	if ( SERVER ) then

		if ( self.NextAttackW >= RealTime() ) then return end
		self.NextAttackW = RealTime() + self.AttackDelay

		if ( !( self.StatueEntity && self.StatueEntity:IsValid() ) ) then return end

		if ( self.CanExitFromAbillity && !self.IsLooking ) then

			self.CanExitFromAbillity = false
			self.UsingAbillity = false
			self.StatueEntity:SetPos( Vector( self.Owner:GetPos().x, self.Owner:GetPos().y, GroundPos( self.Owner:GetPos() ).z ) )
			self.StatueEntity:SetAngles( Angle( 0, self.Owner:GetAngles().y, 0 ) )
			self.StatueEntity:SetNoDraw( false )
			self.StatueEntity:DrawShadow( true )
			self.StatueEntity:SetNotSolid( false )
			self.StatueEntity:EmitSound( "nextoren/scp/173/rattle_" .. math.random( 1, 3 ) .. ".ogg" )

			if ( !self.Owner:IsLineOfSightClear( self.StatueEntity ) ) then

				local current_angles = self.Owner:GetAngles()

				self.StatueEntity:SetPos( Vector( self.Owner:GetPos().x, self.Owner:GetPos().y, GroundPos( self.Owner:GetPos() ).z ) + current_angles:Right() * 8 + current_angles:Forward() * 16 )

			end

			return
		end

		if ( !self.Owner:IsLineOfSightClear( self.StatueEntity ) ) then

			BREACH.Players:ChatPrint( self.Owner, true, true, "l:scp173_not_in_los" )

			return
		end

		if ( self.UsingAbillity || self.IsLooking ) then return end

		self.StatueEntity:SetPos( Vector( self.Owner:GetPos().x, self.Owner:GetPos().y, GroundPos( self.Owner:GetPos() ).z ) )
		local ang = Angle( 0, self.Owner:GetAngles().y + 90, 0 )
		if self.Owner:GetVelocity() != Vector(0,0,0) then ang = Angle( 0, self.Owner:GetVelocity():Angle().y + 90, 0 ) end
		self.StatueEntity:SetAngles( ang )
		self.StatueEntity:EmitSound( "nextoren/scp/173/rattle_" .. math.random( 1, 3 ) .. ".ogg" )

		local tr = util.TraceHull( {

			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 ),
			filter = { self.Owner, self.StatueEntity },
			mins = -tr_maxs,
			maxs = tr_maxs,
			mask = MASK_SHOT_HULL

		})

		local victim = tr.Entity

		if ( victim:IsPlayer() && victim:GTeam() != TEAM_SCP && !victim:HasGodMode() ) then

			self.StatueEntity:SetPos( victim:GetPos() )
			
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(DMG_SLASH)
			dmginfo:SetDamage(30000000)
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self)
			victim:SetLastHitGroup(HITGROUP_HEAD)
			victim:TakeDamageInfo(dmginfo)
			victim:EmitSound( "nextoren/scp/173/snap_" .. math.random( 1, 3 ) .. ".ogg" )

		end

	end

end


SWEP.NextSpecial = 0
function SWEP:SecondaryAttack()

end