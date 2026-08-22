AddCSLuaFile()

ENT.Base = "base_anim"

ENT.PrintName		= "Scarlet_King"

ENT.Type			= "anim"

ENT.Spawnable		= true

ENT.AdminSpawnable	= true

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Owner = nil

ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

	self.Entity:SetModel( "models/cultist/scp/scarlet_king.mdl" )

	self.Entity:SetMoveType(MOVETYPE_NONE )

	self:SetCollisionGroup( COLLISION_GROUP_NONE    )

	self:SetPos(Vector(3709.1225585938, 309.02331542969, 2062.2077636719))

	self:SetModelScale(2.5, 0)

	if SERVER then
		self.ForceLook = ents.Create("point_forcelook")
		self.ForceLook:SetPos(Vector(3709.1225585938, 309.02331542969, 2062.2077636719))
		self.ForceLook:Spawn()
	end

	self:SetAngles(Angle(0, -90, 0))

	self:SetLocalVelocity( Vector( 0, 0, -150 ) )

	self:ResetSequence( "anm4" )
	
	self:SetPlaybackRate( 0.5 )

	self:EmitSound("nextoren/scp/001/laugh.mp3", 135, 100, 1.3)

	local cultist_spawns = {
		Vector(3647.24609375, 83.54029083252, 1947.03125),
		Vector(3681.4978027344, 81.765281677246, 1947.03125),
		Vector(3714.78515625, 80.040237426758, 1947.03125),
		Vector(3740.8498535156, 85.548522949219, 1947.03125),
		Vector(3738.1040039063, 32.560115814209, 1947.03125),
		Vector(3718.1416015625, 32.465251922607, 1947.03125),
		Vector(3678.7976074219, 34.455821990967, 1947.03125),
		Vector(3651.5610351563, 35.866008758545, 1947.03125),
	}

	local people_spawns = {
		Vector(2029.5684814453, 668.27288818359, 1947.03125),
		Vector(2141.5690917969, 668.45373535156, 1947.03125),
		Vector(2246.5654296875, 667.61944580078, 1947.03125),
		Vector(2358.5571289063, 666.24603271484, 1947.03125),
		Vector(2463.5163574219, 663.31372070313, 1947.03125),
		Vector(2582.4665527344, 659.84722900391, 1947.03125),
		Vector(2694.4216308594, 656.66351318359, 1947.03125),
		Vector(2813.3916015625, 653.96649169922, 1947.03125),
		Vector(2946.3762207031, 651.93402099609, 1947.03125),
		Vector(3072.3630371094, 650.14715576172, 1947.03125),
		Vector(3177.3503417969, 648.54235839844, 1947.03125),
		Vector(3275.3395996094, 647.02886962891, 1947.03125),
		Vector(3380.3286132813, 645.41925048828, 1947.03125),
		Vector(3478.3212890625, 644.21374511719, 1947.03125),
		Vector(3576.3208007813, 643.68884277344, 1947.03125),
		Vector(3667.3208007813, 643.23522949219, 1947.03125),
		Vector(3765.3190917969, 642.66400146484, 1947.03125),
		Vector(3877.3151855469, 641.98101806641, 1947.03125),
		Vector(3975.3117675781, 641.38201904297, 1947.03125),
		Vector(4087.3078613281, 640.69744873047, 1947.03125),
		Vector(4178.3076171875, 640.14123535156, 1947.03125),
		Vector(3324.2446289063, -112.58558654785, 1947.03125),
		Vector(3226.177734375, -108.87222290039, 1947.03125),
		Vector(3135.181640625, -109.82621002197, 1947.03125),
		Vector(3037.1845703125, -110.46473693848, 1947.03125),
		Vector(2946.1848144531, -110.99007415771, 1947.03125),
		Vector(2855.1848144531, -111.51113128662, 1947.03125),
		Vector(2764.1872558594, -112.07486724854, 1947.03125),
		Vector(2673.1872558594, -112.05728912354, 1947.03125),
		Vector(2575.1872558594, -111.84246826172, 1947.03125),
		Vector(2484.1872558594, -111.6303024292, 1947.03125),
		Vector(2358.1706542969, -109.35549163818, 1947.03125),
		Vector(3873.3193359375, 3.7060899734497, 1947.03125),
		Vector(3957.3386230469, 7.6984462738037, 1947.03125),
		Vector(4027.2734375, 4.6396808624268, 1947.03125),
		Vector(4090.1948242188, 1.4938833713531, 1947.03125),
		Vector(4150.3427734375, -16.977058410645, 1947.03125),
		Vector(4158.4047851563, -71.264511108398, 1947.03125),
		Vector(4101.4780273438, -115.08596038818, 1947.03125),
		Vector(4024.7780761719, -126.76725769043, 1947.03125),
		Vector(3947.7976074219, -128.93910217285, 1947.03125),
		Vector(3865.1489257813, -162.98448181152, 1947.03125),
		Vector(3845.7062988281, -192.16859436035, 1947.03125),
		Vector(3837.9638671875, -224.7809753418, 1947.03125),
		Vector(3796.82421875, -281.21838378906, 1947.03125),
		Vector(3793.9753417969, -324.00631713867, 1947.03125),
		Vector(3767.025390625, -350.98254394531, 1947.03125),
		Vector(3709.150390625, -320.5075378418, 1947.03125),
		Vector(3684.3903808594, -277.16510009766, 1947.03125),
		Vector(3680.16796875, -231.81898498535, 1947.03125),
		Vector(3656.9924316406, -175.97607421875, 1947.03125),
		Vector(3624.3896484375, -148.77499389648, 1947.03125),
	}

	if SERVER then
		for _, v in player.Iterator() do

			if v:GTeam() == TEAM_SPEC then continue end
			v:StopForcedAnimation()
			local SpawnPos = table.remove(people_spawns, math.random(1, #people_spawns))
			if v:GTeam() == TEAM_COTSK then
				SpawnPos = table.remove(cultist_spawns, math.random(1, #cultist_spawns))
				v:SetNWEntity("NTF1Entity", v)
				v:SetNWAngle("ViewAngles", Angle(0, -180, 0))
				v:SetForcedAnimation("0_cult_ritual", 6)
			end

			v:SetPos(SpawnPos)

			v:StripWeapons()

			v:SetMoveType(MOVETYPE_OBSERVER)

			if v:GTeam() != TEAM_SCP then
				v:BreachGive("br_holster")
				v:SelectWeapon("br_holster")
			end

		end
	end

	ParticleEffectAttach("mr_red_mist_big", PATTACH_ABSORIGIN_FOLLOW, self, 8 )

	timer.Simple(2, function()
		if IsValid(self) then
	
			self:ResetSequence( "idle_knife" ) 
		
			self:SetPlaybackRate( 1 )

		end
	
		timer.Simple(1, function()
			self:EmitSound("nextoren/scarlet_king_speech", 135, 100, 1.3)
			self:ResetSequence( "anm2" ) 
			
			self:SetPlaybackRate( 1 )
		end)
	
		timer.Simple(3, function() 
	
			self:ResetSequence( "anm4" )
		
			self:SetPlaybackRate( 0.5 )
			ParticleEffectAttach("core_finish", PATTACH_ABSORIGIN_FOLLOW, self, 11 )
			
			for _, ply in player.Iterator() do
				if ply:GTeam() == TEAM_COTSK && ply:Alive() && ply:Health() > 0 then
					ParticleEffectAttach("slave_finish", PATTACH_ABSORIGIN_FOLLOW, ply, 8 )
					if SERVER then

						ply:SetNWEntity("NTF1Entity", NULL)

						ply:SetNWAngle("ViewAngles", Angle(0, 0, 0))

						ply:StopForcedAnimation()

						ply:AddToStatistics("l:cotsk_summon_bonus", 100)
						ply:LevelBar()
						ply:SetSpectator()
	
					end
					
					timer.Simple(5, function()
						ply:StopParticles()
					end)
				end
			end

			timer.Simple(2, function()
				
				self:ResetSequence( "anm3" )
		
				self:SetPlaybackRate( 1 )
			end)

		end)
	
		timer.Simple(10, function()
			self:ResetSequence( "anm6" ) 
	
			self:SetPlaybackRate( 0.5 )
			
			timer.Simple(2, function()
				self:EmitSound("nextoren/ritual_end.ogg", 135, 100, 1.3)
				ParticleEffectAttach("core_finish", PATTACH_ABSORIGIN_FOLLOW, self, 11 )
				for _, ply in player.Iterator() do
					if SERVER then ply:ScreenFade(SCREENFADE.IN, Color(255,0,0,120), 2, 0) end
					if ply:GTeam() != TEAM_SPEC && ply:Alive() && ply:Health() > 0 then
						ParticleEffectAttach("infect2", PATTACH_ABSORIGIN_FOLLOW, ply, 8 )
						timer.Simple(.5,  function()
							if SERVER then
								ply:Kill()
							end
						end)
						
						timer.Simple(3, function()
							ply:StopParticles()
						end)
					end
				end
			end)
	
		end)

		timer.Simple(12.5, function()
			if SERVER then
				for _, ply in player.Iterator() do
					ply:ScreenFade(SCREENFADE.OUT, Color(255,0,0,255), 1, 3)
				end
			end
			timer.Simple(3, function()
				if CLIENT then
					surface.PlaySound("nextoren/ending/nuke.mp3")
					LocalPlayer().no_signal = true
				else
					Breach_EndRound("l:roundend_scarletking")
				end
			end)
		end)
	
		timer.Simple(19, function()
			if SERVER then
				self:StopParticles()
				self:Remove()
				self.ForceLook:Remove()
			end
		end)
	end)

end



