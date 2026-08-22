--
util.AddNetworkString("hg_booom")
hg = hg or {}

function hg.FindOtherExplosive(inflictor,pos,radius)

end

function hg.MakeCombinedExplosion()

end

local DebrisSounds = {
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave01.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave010.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave02.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave03.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave04.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave05.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave06.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave07.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave09.wav"
}

local hg, util, ParticleEffect, IsValid, timer, coroutine, Vector = hg, util, ParticleEffect, IsValid, timer, coroutine, Vector

local vecCone = Vector(5, 5, 0)

-- One scheduler for all expensive shrapnel coroutines.
-- A zero-delay timer per grenade creates a timer callback every tick for every active explosion.
local shrapnelQueue = {}
local shrapnelQueueCount = 0

local function QueueShrapnel(co, ent)
	shrapnelQueueCount = shrapnelQueueCount + 1
	shrapnelQueue[shrapnelQueueCount] = { co, ent }
end

hook.Add("Think", "hg.ShrapnelScheduler", function()
	local write = 1
	for i = 1, shrapnelQueueCount do
		local item = shrapnelQueue[i]
		local co, ent = item[1], item[2]

		if IsValid(ent) then
			local status = coroutine.status(co)
			if status ~= "dead" then
				coroutine.resume(co)
				status = coroutine.status(co)
			end

			if status ~= "dead" then
				shrapnelQueue[write] = item
				write = write + 1
			end
		end
	end

	for i = write, shrapnelQueueCount do
		shrapnelQueue[i] = nil
	end

	shrapnelQueueCount = write - 1
end)
local ExpTypes = {
    Fire = function(Ent, Force, Mass)
		local multi = math.min(Mass / 10,20)
		Force = Force * multi
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
		local rad = (Force / 8)
        util.BlastDamage(Ent, Owner, SelfPos, rad / 0.01905, Force * 2)
		--hgWreckBuildings(Ent, SelfPos, Force / 50)
		hgBlastDoors(Ent, SelfPos, Force / 50, Force / 15)
		--ParticleEffect("pcf_jack_incendiary_ground_sm2",SelfPos + vector_up * 1,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Fire")
        net.Broadcast()

		if not IsValid(Ent) then return end
		local multi = math.min(Mass / 5, 20)
		
		local Tr = util.QuickTrace(SelfPos, -vector_up*500, {Ent})
		local fire = CreateVFire(game.GetWorld(), Tr.HitPos, Tr.HitNormal, 150 / 7 * multi, Ent)
		if IsValid(fire) then
			fire:ChangeLife(150)
		end
		for i = 1, multi / 2 do
			local randvec = VectorRand(-1000,1000)--VectorRand(-1,1) * math.random(1000)
			randvec[3] = math.random(100,1000)
			CreateVFireBall(20, 50, SelfPos + vector_up * 10, randvec)
		end

		local dis = rad / 0.01900
		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			local entPos = enta:GetPos()
			local tracePos = enta:IsPlayer() and (entPos + enta:OBBCenter()) or entPos
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end
			local force = entPos - SelfPos
			local len = force:Length()
			force:Div(len)
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 50000

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() then
					hg.ExplosionDisorientation(enta, 5 * frac / (behindwall and 3 or 1), 6 * frac / (behindwall and 3 or 1))
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if tr.Entity != enta then forceadd = forceadd / 5 continue end

			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
				hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		local bullet = {}
		bullet.Src = SelfPos
		bullet.Spread = vecCone
		bullet.Force = 0.01
		bullet.Damage = Force
		bullet.AmmoType = "Metal Debris"
		bullet.Attacker = Owner
		bullet.Distance = 15000
		bullet.DisableLagComp = true
		bullet.Filter = {Ent}
		table.Add(bullet.Filter, hg.drums2)
		local multi = math.min(Mass/5,20)

		co = coroutine.create(function()
			local LastShrapnel = SysTime()
			for i = 1, multi*3 do
				LastShrapnel = SysTime()
				if not IsValid(Ent) then return end
				bullet.Dir = Ent:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / Mass/5)
				Ent:FireLuaBullets(bullet, true)
				LastShrapnel = SysTime() - LastShrapnel
				if LastShrapnel > 0.001 then
					coroutine.yield()
				end
			end
			Ent.ShrapnelDone = true
		end)

        util.ScreenShake(SelfPos,99999,99999,1,3000)

        coroutine.resume(co)
		if not Ent.ShrapnelDone then
			QueueShrapnel(co, Ent)
		elseif IsValid(Ent) then
			SafeRemoveEntity(Ent)
		end
    end,

    Sharpnel = function(Ent,Force,Mass)
		local rad = (Force / 8)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
        util.BlastDamage(Ent, Owner, SelfPos, (Force/7.5) / 0.01905, Force * 1)
		--hgWreckBuildings(Ent, SelfPos, Force / 50)
		hgBlastDoors(Ent, SelfPos, Force / 50)

        --ParticleEffect("pcf_jack_groundsplode_medium",SelfPos + vector_up * 1,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Sharpnel")
        net.Broadcast()

		local dis = rad / 0.01900
		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			local entPos = enta:GetPos()
			local tracePos = enta:IsPlayer() and (entPos + enta:OBBCenter()) or entPos
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end
			local force = entPos - SelfPos
			local len = force:Length()
			force:Div(len)
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 50000

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() and not behindwall then
					hg.ExplosionDisorientation(enta, 5 * frac, 6 * frac)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if tr.Entity != enta then forceadd = forceadd / 5 continue end


			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
				hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		local bullet = {}
		bullet.Src = SelfPos
		bullet.Spread = vecCone
		bullet.Force = 0.01
		bullet.Damage = Force
		bullet.AmmoType = "Metal Debris"
		bullet.Attacker = Owner
		bullet.Distance = 15000
		bullet.DisableLagComp = true
		bullet.Filter = {Ent}
		table.Add(bullet.Filter, hg.drums2)
		local multi = math.min(Mass/5,20)

		co = coroutine.create(function()
			local LastShrapnel = SysTime()
			for i = 1, multi*5 do
				LastShrapnel = SysTime()
				if not IsValid(Ent) then return end
				bullet.Dir = Ent:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / Mass/5)
				Ent:FireLuaBullets(bullet, true)
				LastShrapnel = SysTime() - LastShrapnel
				if LastShrapnel > 0.001 then
					coroutine.yield()
				end
			end
			Ent.ShrapnelDone = true
		end)

        util.ScreenShake(SelfPos,99999,99999,1,3000)

        coroutine.resume(co)
		if not Ent.ShrapnelDone then
			QueueShrapnel(co, Ent)
		elseif IsValid(Ent) then
			SafeRemoveEntity(Ent)
		end
    end,
    Normal = function(Ent,Force)
		local rad = (Force / 8)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
        util.BlastDamage(Ent, Owner, SelfPos, (Force / 7.5) / 0.01905, Force * 1)
		--hgWreckBuildings(Ent, SelfPos, Force / 50)
		hgBlastDoors(Ent, SelfPos, Force / 50)

        --ParticleEffect("pcf_jack_groundsplode_small",SelfPos + vector_up * 1,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Normal")
        net.Broadcast()

		local dis = rad / 0.01900
		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			local entPos = enta:GetPos()
			local tracePos = enta:IsPlayer() and (entPos + enta:OBBCenter()) or entPos
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end
			local force = entPos - SelfPos
			local len = force:Length()
			force:Div(len)
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 50000

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() and not behindwall then
					hg.ExplosionDisorientation(enta, 5 * frac, 6 * frac)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if tr.Entity != enta then forceadd = forceadd / 5 continue end


			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
				hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(table.Random(DebrisSounds), Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		if not IsValid(Ent) then return end
		util.ScreenShake(SelfPos,99999,99999,1,3000)
		SafeRemoveEntity(Ent)
    end,
}

function hg.PropExplosion(Ent, ExpType, Force, Mass)
	if Ent.HasExploded then return end
	Ent.HasExploded = true
	
    ExpTypes[ExpType](Ent,Force, Mass)
end

local expItems = {
    ["models/props_c17/oildrum001_explosive.mdl"] = {ExpType = "Fire", Force = 75},
    ["models/props_junk/gascan001a.mdl"] = {ExpType = "Fire", Force = 40},
    ["models/props_junk/propane_tank001a.mdl"] = {ExpType = "Sharpnel", Force = 30},
    ["models/props_junk/metalgascan.mdl"] = {ExpType = "Fire", Force = 40},
    ["models/props_junk/PropaneCanister001a.mdl"] = {ExpType = "Sharpnel", Force = 40},
    ["models/props_c17/canister01a.mdl"] = {ExpType = "Sharpnel", Force = 45},
    ["models/props_c17/canister02a.mdl"] = {ExpType = "Sharpnel", Force = 45},
    ["models/props_c17/canister_propane01a.mdl"] = {ExpType = "Fire", Force = 50}
}

hg.expItems = expItems

hook.Remove("EntityTakeDamage", "ExplosiveDamage")