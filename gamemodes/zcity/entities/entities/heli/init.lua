AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CurrentFrame = 1
ENT.AutomaticFrameAdvance = true
ENT.IsDriving = true
ENT.HeliHealth = 2000

ENT.AnimationFrames = {
	{Vector(332.09475708008, 4888.3051757813, 3075.1586914063), Angle(2.713623046875, 90.357055664063, -14.221801757813)},
	{Vector(-284.50988769531, 4850.2099609375, 3075.0688476563), Angle(2.713623046875, 91.0546875, -14.221801757813)},
	{Vector(-1044.5059814453, 4806.2075195313, 3075.6652832031), Angle(2.713623046875, 90.318603515625, -14.221801757813)},
	{Vector(-1411.5454101563, 4787.775390625, 3075.5754394531), Angle(2.713623046875, 90.318603515625, -14.221801757813)},
	{Vector(-1809.0645751953, 4771.603515625, 3075.3957519531), Angle(2.713623046875, 90.252685546875, -14.221801757813)},
	{Vector(-2412.2648925781, 4769.4565429688, 3072.7980957031), Angle(2.713623046875, 80.546264648438, -14.221801757813)},
	{Vector(-3129.3984375, 4670.0776367188, 3008.6701660156), Angle(8.6517333984375, 53.140869140625, -5.767822265625)},
	{Vector(-3418.9743652344, 4738.1059570313, 2967.3901367188), Angle(7.14111328125, 6.0809326171875, -1.0821533203125)},
	{Vector(-3533.8459472656, 4765.0766601563, 2886.8137207031), Angle(9.84375, -1.790771484375, -10.838012695313)},
	{Vector(-3565.6950683594, 4776.1674804688, 2613.4487304688), Angle(11.7333984375, -9.151611328125, 0.1153564453125)},
	{Vector(-3579.9892578125, 4816.9077148438, 2495.892578125), Angle(-0.19775390625, 1.043701171875, 0.0164794921875)},
}

ENT.EscapeAnimationFrames = {
	{Vector(-3637.78125, 4794.25, 2521.03125), Angle(0.2252197265625, 8.843994140625, 2.48291015625)},
	{Vector(-3634.46875, 4853.5, 2588.59375), Angle(6.2237548828125, 2.274169921875, -3.614501953125)},
	{Vector(-3623.40625, 4914.8125, 2659), Angle(3.4442138671875, -0.5548095703125, -10.508422851563)},
	{Vector(-3634.09375, 5014.34375, 2721.84375), Angle(1.5380859375, 2.5048828125, -17.550659179688)},
	{Vector(-3630, 5177.6875, 2734.6875), Angle(0.340576171875, 1.1480712890625, -21.8408203125)},
	{Vector(-3638.09375, 5416.53125, 2759.71875), Angle(0.3350830078125, 0.9063720703125, -22.78564453125)},
	{Vector(-3619.59375, 6146, 2781.125), Angle(0.3350830078125, 0.999755859375, -22.78564453125)},
	{Vector(-3614.03125, 6931, 2804.09375), Angle(0.3350830078125, 0.999755859375, -22.78564453125)},
	{Vector(-3611.4375, 7298.3125, 2814.8125), Angle(0.3350830078125, 0.999755859375, -22.78564453125)},
	{Vector(-3623.9375, 7459.875, 2719.03125), Angle(-0.208740234375, 0, -27.789916992188)},
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
        
        timer.Simple(0, function()
            if IsValid(self) then
                self:SetCollisionGroup(COLLISION_GROUP_WORLD)
            end
        end)
		
		self.PropellerSound:Stop()
		self.PropellerSound = CreateSound(self, "nextoren/others/helicopter/apache_damage_alarm.wav", filt)
		self.PropellerSound:Play()

		local fallpos = (isfunction(GroundPos) and GroundPos(self:GetPos())) or (self:GetPos() - Vector(0,0,1000))
		self:LinearMotion(fallpos, 0.02, function()
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

		local _timername = "Helicopter_Crush_Animation_"..self:EntIndex()
		timer.Create(_timername, FrameTime(), 999999, function()
			if IsValid(self) then
				local curang = self:GetManipulateBoneAngles(0)
				local curpos = self:GetManipulateBonePosition(0)
				local yaw = math.Clamp(curang.yaw + math.random(0.5, 2), 0, 360)
				if yaw == 360 then yaw = -3.5 end
				self:ManipulateBonePosition(0, Vector(curpos.x, math.Clamp(curpos.y + math.random(0.5, 2), 0, 70), curpos.z))
				self:ManipulateBoneAngles(0, Angle(0, math.Clamp(curang.yaw + math.random(0.5, 2), 0, 360), math.Clamp(curang.roll + math.random(0.5, 2), 0, 90)))
			else
				timer.Remove(_timername)
			end
		end)
		self.IsBroken = true
	end

	for _, ply in player.Iterator() do
		if ply:GTeam() == tem then
			ply:RXSENDNotify("l:ci_choppa_down")
			ply:AddToStatistics("l:choppa_bonus", 100)
		end
	end
end

function ENT:Touch(ply)
	if !IsValid(ply) then return end
	if !ply:IsPlayer() then return end
	if ply:GTeam() == TEAM_SPEC then return end
	if !ply:Alive() or ply:Health() <= 0 then return end
	if self.IsDriving != true then return end
	ply:Kill()
end

function ENT:OnTakeDamage( dmginfo )
	if self.NOMOREEXPLOSIONS or self.Blownup then return end
	
    local attacker = dmginfo:GetAttacker()
    local inflictor = dmginfo:GetInflictor()

    if IsValid(attacker) and not attacker:IsPlayer() then
        local owner = attacker:GetOwner()
        if IsValid(owner) and owner:IsPlayer() then
            attacker = owner
        elseif IsValid(inflictor) and inflictor:IsPlayer() then
            attacker = inflictor
        end
    end

    if not IsValid(attacker) or not attacker:IsPlayer() then return dmginfo:GetDamage() end

    local team = attacker:GTeam()
    local isBlast = dmginfo:IsDamageType(DMG_BLAST) or dmginfo:GetDamageType() == DMG_CLUB

	if isBlast and team == TEAM_CHAOS then
		self:Explode(TEAM_CHAOS)
	elseif isBlast and team == TEAM_GRU then
		self:Explode(TEAM_GRU)
	elseif team == TEAM_GRU then
		if GRU_Objective != "Срыв эвакуации" then
			attacker:RXSENDNotify(Color(255,0,0), "l:gru_psycho_pt1 ", color_white, "l:gru_psycho_pt2")
			return
		end
		self.HelicopterHealth = self.HelicopterHealth - dmginfo:GetDamage()
		if self.HelicopterHealth <= 0 then
			self:Explode(TEAM_GRU)
		end
	end
	return dmginfo:GetDamage()
end

function ENT:Initialize()
    self:SetModel("models/scp_helicopter/resque_helicopter.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetTrigger(true)

    self.IsFlying = true
    self.HelicopterHealth = self.HeliHealth
    self.IsBroken = false
    self.HeliState = 0 
    
    self.Velocity = Vector(0,0,0)
    self.SmoothedDesiredVel = Vector(0,0,0) 
    
    self.CurrentAngles = self.AnimationFrames and self.AnimationFrames[1][2] or Angle(0,0,0)
    self.GhostPos = self.AnimationFrames and self.AnimationFrames[1][1] or self:GetPos()
    self.GhostIndex = 2
    
    local filt = RecipientFilter()
    filt:AddAllPlayers()
    self.PropellerSound = CreateSound(self, "nextoren/others/helicopter/helicopter_propeller.wav", filt)
    self.PropellerSound:Play()

    if self.AnimationFrames then
        self:SetPos(self.AnimationFrames[1][1])
        self:SetAngles(self.AnimationFrames[1][2])
    end

    self:ResetSequence(self:LookupSequence("rotating"))
    self:ResetSequenceInfo()
    self:SetBodygroup(2, 3)

    local physobj = self:GetPhysicsObject()
    if IsValid(physobj) then 
        physobj:EnableMotion(false) 
        physobj:Sleep()
    end

    local remembername = "Frame_Advance_"..self:EntIndex()
    timer.Create(remembername, FrameTime(), 0, function()
        if IsValid(self) then self:FrameAdvance() else timer.Remove(remembername) end
    end)
end

function ENT:Escape()
    if self.HeliState == 5 or self.Blownup or self.IsBroken then return end

    self:AddGestureSequence(self:LookupSequence("door_close"), false)
    self:ChangeRotating(true)

    timer.Simple(1.5, function()
        if not IsValid(self) then return end
        self.PropellerSound:Play()
        self:SetBodygroup(2, 3)
        self:SetBodygroup(4, 0)

        self.GhostIndex = 2 
        self.HeliState = 5 
        
        self.IsFlying = true
        
        self.GhostPos = self:GetPos() 
        self.Velocity = Vector(0,0,0)
        self.SmoothedDesiredVel = Vector(0,0,0)
    end)
end

function ENT:Think()
    if not self.CurrentAngles then self.CurrentAngles = self:GetAngles() end
    if not self.Velocity then self.Velocity = Vector(0,0,0) end
    if not self.SmoothedDesiredVel then self.SmoothedDesiredVel = Vector(0,0,0) end
    if not self.GhostPos then self.GhostPos = self:GetPos() end
    if not self.GhostIndex then self.GhostIndex = 2 end
    if not self.HeliState then self.HeliState = 0 end

    local curPos = self:GetPos()
    local ang = self:GetAngles()

    local pos1, pos2 = curPos + ang:Forward() * -450 + ang:Right() * -150 + ang:Up() * -150,
                       curPos + ang:Forward() * 350 + ang:Right() * 150 + ang:Up() * 150
                       
    for k, v in ipairs(ents.FindInBox(pos1, pos2)) do
        local cls = v:GetClass()
        if (cls:find("rpg_projectile") or cls:find("cw_kk_ins2_projectile")) and not v.HeliIntercepted then
            v.HeliIntercepted = true
            
            local owner = v:GetOwner()
            
            timer.Simple(0, function()
                if IsValid(v) then
                    if v.selfDestruct then v:selfDestruct() else v:Remove() end
                end
            end)

            local dmg = DamageInfo()
            dmg:SetDamageType(DMG_BLAST)
            dmg:SetDamage(1000)
            dmg:SetAttacker(IsValid(owner) and owner or v)
            dmg:SetInflictor(v)
            self:TakeDamageInfo(dmg)
        end
    end

    if !self.RotorWash then
        self.RotorWash = ents.Create("env_rotorwash_emitter")
        self.RotorWash:SetPos(curPos)
        self.RotorWash:SetParent(self)
        self.RotorWash:Activate()
    end

    if not self.IsBroken and not self.Blownup then
        local FT = FrameTime()
        if FT > 0.05 then FT = 0.05 end

        local activePath = (self.HeliState == 5) and self.EscapeAnimationFrames or self.AnimationFrames
        if not activePath then return true end
        
        local targetNode = activePath[self.GhostIndex]
        local prevNode = activePath[self.GhostIndex - 1] or activePath[1]
        
        local ghostTarget = curPos
        local ghostTargetYaw = self.CurrentAngles.y 
        local ghostSpeed = 0

        if targetNode then
            ghostTarget = targetNode[1]
            
            local distTotal = prevNode[1]:Distance(targetNode[1])
            local distTraveled = prevNode[1]:Distance(self.GhostPos)
            local fraction = distTotal > 0.1 and math.Clamp(distTraveled / distTotal, 0, 1) or 1
            ghostTargetYaw = LerpAngle(fraction, prevNode[2], targetNode[2]).y
            
            if self.HeliState == 0 then ghostSpeed = 200 
            elseif self.HeliState == 1 then ghostSpeed = 150 
            elseif self.HeliState == 2 then ghostSpeed = 80 
            elseif self.HeliState == 5 then ghostSpeed = 300 end

            local dir = ghostTarget - self.GhostPos
            local step = ghostSpeed * FT
            
            if dir:Length() > step then
                self.GhostPos = self.GhostPos + dir:GetNormalized() * step
            else
                self.GhostPos = ghostTarget
            end
            
            local distToNode = self.GhostPos:Distance(ghostTarget)
            
            local switchDistance = math.min(300, distTotal * 0.8)
            if self.HeliState == 2 then switchDistance = 5 end

            if distToNode <= switchDistance then
                if self.GhostIndex < #activePath then
                    self.GhostIndex = self.GhostIndex + 1
                    if self.HeliState == 0 and self.GhostIndex == #activePath then
                        self.HeliState = 1 
                    end
                elseif self.HeliState == 5 then
                    self:Remove()
                    return
                end
            end
        end

        local finalPos = activePath[#activePath][1]
        if self.HeliState == 1 and curPos:Distance(finalPos) < 200 then 
            self.HeliState = 2 
        end
        
        if self.HeliState == 2 then
            local flatDist = Vector(curPos.x, curPos.y, 0):Distance(Vector(finalPos.x, finalPos.y, 0))
            if flatDist < 30 and curPos.z <= finalPos.z + 5 then
                self.HeliState = 3
                
                self.IsFlying = false
                self.IsDriving = false
                
                self:SetPos(finalPos)
                self.Velocity = Vector(0,0,0)
                self.SmoothedDesiredVel = Vector(0,0,0)
                self.CurrentAngles = targetNode[2] 
                self.PropellerSound:Stop()
                self:SetBodygroup(1, 1)
                self:SetBodygroup(2, 0)
                self:SetBodygroup(3, 1)
                self:ChangeRotating()
                self:AddGestureSequence(self:LookupSequence("door_open"), false)
                self:EmitSound("nextoren/vo/chopper/chopper_evacuate_start_"..math.random(1,7)..".wav", 110, 100, 1.2, CHAN_VOICE, 0, 0)
            end
        end

        local posError = self.GhostPos - curPos
        local reaction = (self.HeliState == 5) and 1.2 or 1.8 
        local rawDesiredVelocity = posError * reaction 
        
        local maxHeliSpeed = (self.HeliState == 2) and 150 or 300
        if rawDesiredVelocity:Length() > maxHeliSpeed then
            rawDesiredVelocity = rawDesiredVelocity:GetNormalized() * maxHeliSpeed
        end

        self.SmoothedDesiredVel = LerpVector(FT * 1.5, self.SmoothedDesiredVel, rawDesiredVelocity)

        local damping = (self.HeliState == 2) and 2.5 or 1.5 
        local newVelocity = LerpVector(FT * damping, self.Velocity, self.SmoothedDesiredVel)
        self.Velocity = newVelocity 

        if self.HeliState ~= 3 then
            local accelVector = (self.SmoothedDesiredVel - self.Velocity)
            local flatYawAng = Angle(0, ghostTargetYaw, 0)
            
            local fwdForce = accelVector:Dot(flatYawAng:Forward())
            local rightForce = accelVector:Dot(flatYawAng:Right())

            local basePitch = targetNode and targetNode[2].p or 0
            local baseRoll = targetNode and targetNode[2].r or 0

            local dynPitch = math.Clamp(fwdForce * 0.015, -35, 35)
            local dynRoll = math.Clamp(rightForce * 0.015, -35, 35)

            local targetPitch = basePitch + dynPitch
            local targetRoll = baseRoll + dynRoll

            if self.HeliState == 1 or self.HeliState == 2 then
                targetPitch = basePitch + math.Clamp(dynPitch, -15, 10)
                targetRoll = baseRoll + math.Clamp(dynRoll, -15, 15)
            end

            local targetAng = Angle(targetPitch, ghostTargetYaw, targetRoll)
            self.CurrentAngles = LerpAngle(FT * 2.5, self.CurrentAngles, targetAng)

            local nextPos = curPos + (self.Velocity * FT)

            if (self.HeliState == 1 or self.HeliState == 2) and nextPos.z < finalPos.z then
                nextPos.z = finalPos.z
                self.Velocity.z = math.max(self.Velocity.z, 0)
            end

            self:SetPos(nextPos)
            self:SetAngles(self.CurrentAngles)
        end
    end

    self:NextThink(CurTime() + FrameTime())
    return true
end