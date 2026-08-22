hg.organism = hg.organism or {}
--local Organism = hg.organism
hg.organism.list = hg.organism.list or {}
local hook_Run = hook.Run
function hg.organism.Add(ent)
	ent.organism = {
		owner = ent
	}

	local org = ent.organism
	org.owner = ent
	hg.organism.list[ent] = org
	return org
end

function hg.organism.Clear(org)
	hook_Run("Org Clear", org)//.owner.organism_internal)
	if IsValid(org.owner) then org.owner.fullsend = true end
	hg.send_organism(org)
end

function hg.organism.Remove(ent)
	local org = hg.organism.list[ent]
	if org then org.owner = nil end
	hg.organism.list[ent] = nil
end

hook.Add("PlayerInitialSpawn", "homigrad-organism", function(ply) hg.organism.Add(ply) end)
hook.Add("Player Spawn", "homigrad-organism", function(ply) hg.organism.Clear(ply.organism) end)
hook.Add("PlayerDisconnected", "homigrad-organism", function(ply) hg.organism.Remove(ply) end)
hook.Add("PostPlayerDeath", "homigrad-organism", function(ply)
	local ragdoll = ply:GetNWEntity("RagdollDeath")
	
	if not IsValid(ragdoll) then ragdoll = ply.FakeRagdoll end

	if IsValid(ragdoll) then
		local newOrg = hg.organism.Add(ragdoll)
		table.Merge(newOrg, ply.organism)

		hook.Run("RagdollDeath", ply, ragdoll)

		table.Merge(zb.net.list[ragdoll], zb.net.list[ply])

		newOrg.alive = false
		newOrg.owner = ragdoll
		ragdoll:CallOnRemove("organism", hg.organism.Remove, ragdoll)
	end

	hg.organism.Clear(ply.organism)

	hook.Run("PostPostPlayerDeath", ply, ragdoll)
end)

local tickrate = 1 / 10
local delay = .5
local time, mulTime, start
local CurTime = CurTime
local SysTime = SysTime
hook.Add("Think", "homigrad-organism", function()
	time = CurTime()
	local tickrate2 = tickrate
	//print(delay ,time + tickrate)
	if delay + tickrate2 > time then return end

	delay = time

	if not start then
		start = SysTime()
		return
	end
	
	mulTime = (SysTime() - start) * game.GetTimeScale()

	start = SysTime()
	for owner, org in pairs(hg.organism.list) do
		if IsValid(owner) and owner:IsPlayer() and owner.GTeam and owner:GTeam() == TEAM_SPEC then continue end
		if IsValid(owner) and owner:GetModel() == "models/cultist/scp/scp_049.mdl" then continue end
		if IsValid(owner) and owner:GetModel() == "models/cultist/scp/scp_542.mdl" then continue end
		hook_Run("Org Think", owner, org, mulTime)
	end
end)

hook.Add("Org Think Call", "homigrad-organism", function(owner, org)
	time = CurTime()

	if not start then
		start = SysTime()
		return
	end

	local mulTime = SysTime() - start

	if IsValid(owner) and owner:IsPlayer() and owner.GTeam and owner:GTeam() == TEAM_SPEC then return end
	if IsValid(owner) and owner:GetModel() == "models/cultist/scp/scp_049.mdl" then return end
	if IsValid(owner) and owner:GetModel() == "models/cultist/scp/scp_542.mdl" then return end
	
	hook_Run("Org Think", owner, org, mulTime)
end)


hook.Add("Fake", "organism", function(ply, ragdoll)
	ragdoll.organism = ply.organism
	--zb.net.list[ragdoll] = zb.net.list[ply]
end)