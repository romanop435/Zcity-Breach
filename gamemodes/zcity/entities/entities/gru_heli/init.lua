AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CurrentFrame = 1
ENT.AutomaticFrameAdvance = true
ENT.IsDriving = true

ENT.HeliHealth = 1000




ENT.AnimationFrames = {
	{Vector(-8150.7016601563, -8995.3076171875, 7575.5991210938), Angle(7.284145, 360.960670, 0.000000)},
	
	
	
	
	
	
	
	
	
	
}


ENT.EscapeAnimationFrames = {
	
	
	
	
	
	
	
	
	
	
	
	
	{Vector(-8150.7016601563, -8995.3076171875, 7575.5991210938), Angle(7.284145, 340.960670, 0.000000)},
	{Vector(-7997.884765625, -8783.466796875, 7550.0073242188), Angle(7.284145, 330.960670, 0.000000)},
	{Vector(-7772.4379882813, -8515.2255859375, 7518.9565429688), Angle(7.284145, 320.960670, 0.000000)},
	{Vector(-7310.3544921875, -8164.0932617188, 7469.3701171875), Angle(7.284145, 310.960670, 0.000000)},
	{Vector(-6837.916015625, -8027.7690429688, 7432.1206054688), Angle(7.284145, 300.960670, 0.000000)},


}

function ENT:LinearMotion(endpos, speed, islast)
if !IsValid(self) then return end
	timer.Remove(self:GetClass().."_linear_motion")

	local ratio = 0
	local time = 0
	local startpos = self:GetPos()

	timer.Create(self:GetClass().."_linear_motion", FrameTime(), 9999999999999, function()
		if !IsValid(self) then return end
	    ratio = speed + ratio
	    time = time + FrameTime()
	    self:SetPos(LerpVector(ratio, startpos, endpos))

	    if self:GetPos():DistToSqr(endpos) < 1 then
	    	self:SetPos(endpos)
	    end

	    if self:GetPos() == endpos then
	    	timer.Remove(self:GetClass().."_linear_motion")
	    	if islast and !isfunction(islast) then
	    		self.PropellerSound:Stop()
	    		local physobj = self:GetPhysicsObject()
				if IsValid(physobj) then physobj:EnableMotion(false) end
	    		self.IsFlying = false
	    		self.IsDriving = false
	    		self:SetBodygroup(2,0)
	    		self:SetBodygroup(3,1)
	    		self:ChangeRotating()
	    		self:AddGestureSequence(self:LookupSequence("door_open"), false)
				
				
				
				self:EmitSound("nextoren/vo/chopper/chopper_evacuate_start_"..math.random(1,7)..".wav", 110, 100, 1.2, CHAN_VOICE, 0, 0)
			elseif isfunction(islast) then
				islast()
			end
	    end
	end)
end

function ENT:LinearAngle(endangle, speed)
if !IsValid(self) then return end
	timer.Remove(self:GetClass().."_linear_angle")

    local ratio = 0
    local startangle = self:GetAngles()
    local startangle_table = startangle:Unpack()
    local endangle_table = endangle:Unpack()
    local startangle_tovector = Vector(startangle[1], startangle[2], startangle[3])
    local endangle_tovector = Vector(endangle[1], endangle[2], endangle[3])

    timer.Create(self:GetClass().."_linear_angle", FrameTime(), 9999999999999, function()
        if !IsValid(self) then return end
        ratio = math.min(ratio + speed, 1)
        self:SetAngles(LerpAngle(ratio, startangle, endangle))

        	
        if startangle_tovector:DistToSqr(endangle_tovector) < 1 then
            self:SetAngles(endangle)
        end

        if self:GetAngles() == endangle then
            timer.Remove(self:GetClass().."_linear_angle")
            return true
        end
    end)
end

function ENT:Initialize()
	self:SetModel("models/imperator/gru_heli/heli_v2.mdl")

	self:SetMoveType( MOVETYPE_NONE )


	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetSolid( SOLID_VPHYSICS )

	self:SetTrigger(true)

	self.IsFlying = true

	self.HelicopterHealth = self.HeliHealth
	self.IsBroken = false

	local filt = RecipientFilter()
	filt:AddAllPlayers()

	self.PropellerSound = CreateSound(self, "nextoren/others/helicopter/helicopter_propeller.wav", filt)
	self.PropellerSound:Play()

	self:SetPos(self.AnimationFrames[1][1])
	self:SetAngles(self.AnimationFrames[1][2])

	self.HoverBasePos = self:GetPos()
	self.HoverBaseAng = self:GetAngles()

	self:PhysicsDestroy()

	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then physobj:EnableMotion(false) end


	self:ResetSequence(self:LookupSequence("rotating"))
	self:ResetSequenceInfo()
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	

	self.at4e = ents.Create("gru_evacuation")
	self.at4e:SetPos(Vector(-8141.7749023438, -8971.9833984375, 6652.03125))
	self.at4e:SetAngles(Angle(0, 0, 0))
	self.at4e:Spawn()
	self.at4e:SetMoveType(MOVETYPE_NONE)
	self.at4e:PhysicsInit(SOLID_NONE)
	self.at4e:SetSolid( SOLID_NONE )
	
	
	
	
	
	
	
	
	
	
	
	
	

	

	
	
	
	
	
	

	
	
	
	
	
	
	
	

end

function ENT:ChangeRotating(start)

	local unid = "change_playback_"..self:EntIndex()

	timer.Create(unid, FrameTime(), 0, function()

		if !IsValid(self) or (!start and self:GetPlaybackRate() <= 0) or (start and self:GetPlaybackRate() >= 1) then
			timer.Remove(unid)
			return
		end

		if start then
			self:SetPlaybackRate(math.Approach(self:GetPlaybackRate(), 1, FrameTime()/2))
		else
			self:SetPlaybackRate(math.Approach(self:GetPlaybackRate(), 0, FrameTime()/2))
		end

	end)

end

function ENT:Explode(tem)

	if self.Blownup then return end

	local pos = self:GetPos()
	local dmg = 625
	local dmgowner = self

	self.Blownup = true

	local r_inner = 550
	local r_outer = r_inner * 1.15

	for i = 2, #self.AnimationFrames do
		timer.Remove("helicopter__anim_"..tostring(i))
	end

	

	

	if !self.IsFlying then
		ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
		BREACH.SendClientEvent(nil, "particle_world", {effect = "gas_explosion_main", pos = self:GetPos()})
		local dmginfo = DamageInfo()
		dmginfo:SetDamageType(DMG_BLAST)
		dmginfo:SetDamage(450)
		local savepos = self:GetPos()

		sound.Play( "bullet/explode/large_4.wav", savepos, 125, 100, 1.3 )

		self:Remove()

		util.BlastDamageInfo(dmginfo, savepos, 1450)
	else

		local filt = RecipientFilter()
		filt:AddAllPlayers()

		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		self.PropellerSound:Stop()
		self.PropellerSound = CreateSound(self, "nextoren/others/helicopter/apache_damage_alarm.wav", filt)
		self.PropellerSound:Play()


		local fallpos = GroundPos(self:GetPos())
		self:LinearMotion(fallpos, 0.005, function()
			ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
			BREACH.SendClientEvent(nil, "particle_world", {effect = "gas_explosion_main", pos = self:GetPos()})
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetDamage(450)
			local savepos = self:GetPos()

			sound.Play( "bullet/explode/large_4.wav", savepos, 125, 100, 1.3 )

			self.NOMOREEXPLOSIONS = true

			self:Remove()

			util.BlastDamageInfo(dmginfo, savepos, 1450)
		end)
		self:Ignite(1000)
		if IsValid(self.at4e) then
			
			
			
			self.at4e:Remove()
		end


		local _timername = "Helicopter_Crush_Animation_"..self:EntIndex()
		timer.Create(_timername, FrameTime(), 999999, function()
			if IsValid(self) then
				local curang = self:GetManipulateBoneAngles(0)
				local curpos = self:GetManipulateBoneAngles(0)
				local yaw = math.Clamp(curang.yaw + math.random(0.5, 2), 0, 360)
				if yaw == 360 then
					yaw = -3.5
				end
				self:ManipulateBonePosition(0, Vector(curpos.x, math.Clamp(curpos.y + math.random(0.5, 2), 0, 70), curpos.z))
				self:ManipulateBoneAngles(0, Angle(0, math.Clamp(curang.yaw + math.random(0.5, 2), 0, 360), math.Clamp(curang.roll + math.random(0.5, 2), 0, 90)))
			else
				timer.Remove(_timername)
			end
		end)

		self.IsBroken = true
	end

	
	
	
	
	
	

end



function ENT:Escape()
	
	
	if IsValid(self.at4e) then
		
		
		
		self.at4e:Remove()
	end
	timer.Simple(1, function()
		self.PropellerSound:Play()
		self:ManipulateBoneAngles(0, Angle(0,0,0))
		self:SetBodygroup(2, 3)
		self:SetBodygroup(4, 0)
		self.IsFlying = false
		for i = 1, #self.EscapeAnimationFrames do
			timer.Create("helicopter__anim_"..tostring(i), 1 * i, 1, function()
				self:LinearMotion(self.EscapeAnimationFrames[i][1], 0.01)
				self:LinearAngle(self.EscapeAnimationFrames[i][2], 0.01)
			end)
		end
		timer.Simple(1 * #self.EscapeAnimationFrames, function()
			self:Remove()
		end)
	end)
end


function ENT:Touch(ply)
	if !IsValid(ply) then return end
	if !ply:IsPlayer() then return end
	if ply:GTeam() == TEAM_SPEC then return end
	if !ply:Alive() or ply:Health() <= 0 then return end
	if self.IsDriving != true then return end
	ply:Kill()
end

function ENT:Think()
	
	
	
	

	local mypos = self:GetPos()
	local ang = self:GetAngles()

	
	
	
	
	
	

	local pos1, pos2 = mypos + ang:Forward()*-450 + ang:Right()*-150 + ang:Up()*-150, mypos + ang:Forward()*350 + ang:Right()*150 + ang:Up()*150

	for k, v in ipairs(ents.FindInBox(pos1, pos2)) do
		if v:GetClass():find("cw_kk_ins2_projectile_") then
			if !v.Fuse and v.selfDestruct then
				v:selfDestruct()
			end
		end
	end

	if !self.Blownup then
        
        local time = CurTime()
        local posAmp = 16      
        local angAmp = 4       

        
        local dx = math.sin(time * 1.3) * posAmp * 0.7 + math.cos(time * 2.1) * posAmp * 0.3
        local dy = math.sin(time * 1.7) * posAmp * 0.6 + math.cos(time * 2.4) * posAmp * 0.4
        local dz = math.sin(time * 2.2) * posAmp * 0.5 + math.cos(time * 1.8) * posAmp * 0.5

        local dPitch = math.sin(time * 1.1) * angAmp * 0.8 + math.cos(time * 1.9) * angAmp * 0.2
        local dYaw   = math.sin(time * 1.5) * angAmp * 0.6 + math.cos(time * 2.3) * angAmp * 0.4
        local dRoll  = math.sin(time * 1.9) * angAmp * 0.7 + math.cos(time * 1.4) * angAmp * 0.3

        local newPos = self.HoverBasePos + Vector(dx, dy, dz)
        local newAng = Angle(
            self.HoverBaseAng.p + dPitch,
            self.HoverBaseAng.y + dYaw,
            self.HoverBaseAng.r + dRoll
        )

        self:SetPos(newPos)
        self:SetAngles(newAng)
    end

    self:NextThink(CurTime() + FrameTime())
    return true
end

function ENT:OnTakeDamage( dmginfo )
	
	if self.NOMOREEXPLOSIONS or self.Blownup then return end
	
	
	

	if dmginfo:GetDamageType() == DMG_BLAST and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GTeam() != TEAM_GRU then
		self:Explode(dmginfo:GetAttacker():GTeam())
	end


	
	
	
	
	
	
	
	
	
		self.HelicopterHealth = self.HelicopterHealth - dmginfo:GetDamage()
		if self.HelicopterHealth <= 0 then
			self:Explode(dmginfo:GetAttacker():GTeam())
		end
	

	return dmginfo:GetDamage()
end

function ENT:OnRemove()

	if IsValid(self.at4e) then
		
		
		
		self.at4e:Remove()
	end

end