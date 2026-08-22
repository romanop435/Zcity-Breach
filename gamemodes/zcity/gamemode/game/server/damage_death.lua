local tonumber = tonumber
local tostring = tostring
local CurTime = CurTime
local Entity = Entity
local table = table
local pairs = pairs
local ipairs = ipairs
local concommand = concommand
local timer = timer
local ents = ents
local hook = hook
local math = math
local util = util
local net = net
local player = player



function CreateKillFeed(victim, attacker)
	if not IsValid(victim) or not IsValid(attacker) then return end
	if not attacker:IsPlayer() then return end
	if victim:GTeam() == TEAM_SPEC or attacker:GTeam() == TEAM_SPEC then return end
	if victim:GTeam() == TEAM_ARENA or attacker:GTeam() == TEAM_ARENA then return end

	local str = {}
	local clr_w = Color(255, 255, 255, 215)
	local clr_user = Color(215, 215, 215, 255)

	local at_g = attacker:GTeam()
	local vi_g = victim:GTeam()

	if victim ~= attacker then
		local dist = math.Round(victim:GetPos():Distance(attacker:GetPos()) / 52.49, 1)
		table.insert(str, clr_w)
		table.insert(str, "[" .. dist .. "m] ")
	end

	table.insert(str, gteams.GetColor(at_g))
	table.insert(str, attacker:GetRoleName() or "Unknown Role")

	table.insert(str, clr_user)

	if at_g == TEAM_SCP and not attacker.IsZombie then
		table.insert(str, " " .. attacker:Name())
	else
		table.insert(str, " " .. attacker:GetNamesurvivor() .. "(" .. attacker:Name() .. ")")
	end

	table.insert(str, clr_w)

	if attacker == victim then
		table.insert(str, " l:hud_killfeed_died")
	else
		table.insert(str, "l:hud_killfeed_killed ")
		table.insert(str, gteams.GetColor(vi_g))
		table.insert(str, victim:GetRoleName() or "Unknown Role")
		table.insert(str, clr_user)

		if vi_g == TEAM_SCP and not victim.IsZombie then
			table.insert(str, victim:Name())
		else
			table.insert(str, victim:GetNamesurvivor() .. "(" .. victim:Name() .. ")")
		end
	end

	if #str == 0 then return end

	local all_specs = {}
	for _, v in player.Iterator() do
		if v:GTeam() == TEAM_SPEC then
			table.insert(all_specs, v)
		end
	end

	net.Start("breach_killfeed")
	net.WriteTable(str)
	net.Send(all_specs)
end

concommand.Add("toggledamage", function(ply, cmd, args, argstr)
	if not ply:IsSuperAdmin() then return end
	ply.NoDamage = not ply.NoDamage
	ply:RXSENDNotify("nodamage state: " .. tostring(ply.NoDamage))
end)

function GM:HandlePlayerArmorReduction(ply, dmginfo)
	if ply:Armor() <= 0 or bit.band(dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) ~= 0 then return end

	local flBonus = 1.0 
	local flRatio = 0.2 

	local flNew = dmginfo:GetDamage() * flRatio
	local flArmor = (dmginfo:GetDamage() - flNew) * flBonus

	if flArmor > ply:Armor() then
		flArmor = ply:Armor() * (1 / flBonus)
		flNew = dmginfo:GetDamage() - flArmor
		ply:SetArmor(0)
	else
		ply:SetArmor(ply:Armor() - flArmor)
	end

	dmginfo:SetDamage(flNew)
end

concommand.Add("togglereward", function(ply, cmd, args, argstr)
	if not ply:IsSuperAdmin() then return end
	ply.NoRewardsForKill = not ply.NoRewardsForKill
	ply:RXSENDNotify("noreward state: " .. tostring(ply.NoRewardsForKill))
end)

local specialsoundnamescp = {
	["SCP8602"] = "860",
	["SCP062DE"] = "062de",
	["SCP062FR"] = "062fr",
	["SCP973"] = "937",
}

concommand.Add("vstal", function(callply, cmd, args, argstr)
	if not callply:IsSuperAdmin() then return end

	callply:LagCompensation(true)
	local body = callply:GetEyeTrace().Entity
	local ply = IsValid(body) and body.GetOwner and body:GetOwner()

	if IsValid(ply) and IsValid(body) then
		timer.Remove("PlayerDeathFromBleeding" .. ply:SteamID64())

		ply:SetupNormal()
		ply:SetModel(body:GetModel())
		ply:SetSkin(body:GetSkin())
		ply:SetGTeam(body.__Team)
		ply:SetRoleName(body.Role)
		ply:SetMaxHealth(body.__Health) 
		ply:SetHealth(ply:GetMaxHealth())
		ply:SetUsingCloth(body.Cloth)
		ply:SetNamesurvivor(body.__Name)
		ply.OldSkin = body.OldSkin
		ply.OldModel = body.OldModel
		ply.OldBodygroups = body.OldBodygroups
		ply:SetWalkSpeed(body.WalkSpeed)
		ply:SetRunSpeed(body.RunSpeed)
		ply:SetupHands()
		
		timer.Remove("Death_Scene" .. ply:SteamID())
		local pos = body:GetPos()
		ply:SetPos(Vector(pos.x, pos.y, GroundPos(pos).z))
		
		if istable(body.AmmoData) then
			for ammo, amount in pairs(body.AmmoData) do
				ply:SetAmmo(amount, ammo)
			end
		end

		if body.AbilityTable then
			ply:SetNWString("AbilityName", body.AbilityTable[1])
			net.Start("SpecialSCIHUD")
				net.WriteString(body.AbilityTable[1])
				net.WriteUInt(body.AbilityTable[2], 9)
				net.WriteString(body.AbilityTable[3])
				net.WriteString(body.AbilityTable[4])
				net.WriteBool(body.AbilityTable[5])
			net.Send(ply)

			ply:SetSpecialCD(body.AbilityCD)
			ply:SetSpecialMax(body.AbilityMax)
		end
		
		if body.vtable and body.vtable.Weapons then
			for _, v in ipairs(body.vtable.Weapons) do
				if weapons.GetStored(v) then
					ply:BreachGive(v)
				end
			end
		end
		
		ply:BreachGive("br_holster")

		for _, bnmrg in ipairs(body:LookupBonemerges()) do
			local bnmrg_ent = Bonemerge(bnmrg:GetModel(), ply)
			bnmrg_ent:SetSubMaterial(0, bnmrg:GetSubMaterial(0))
			bnmrg_ent:SetSubMaterial(2, bnmrg:GetSubMaterial(2))
		end

		for i = 0, 9 do
			ply:SetBodygroup(i, body:GetBodygroup(i))
		end

		body:Remove()
	end
	callply:LagCompensation(false)
end)

function BREACH.MakeDissolver(ent, position, attacker, dissolveType)
	local Dissolver = ents.Create("env_entity_dissolver")
	timer.Simple(5, function()
		if IsValid(Dissolver) then Dissolver:Remove() end
	end)

	Dissolver.Target = "dissolve" .. ent:EntIndex()
	Dissolver:SetKeyValue("dissolvetype", dissolveType)
	Dissolver:SetKeyValue("magnitude", 0)
	Dissolver:SetPos(position)
	Dissolver:SetPhysicsAttacker(attacker)
	Dissolver:Spawn()

	ent:SetName(Dissolver.Target)
	Dissolver:Fire("Dissolve", Dissolver.Target, 0)
	Dissolver:Fire("Kill", "", 0.1)

	if ent.vtable and ent.vtable.Weapons and table.HasValue(ent.vtable.Weapons, "item_special_document") then
		local document = ents.Create("item_special_document")
		document:SetPos(ent:GetPos() + Vector(0, 0, 20))
		document:Spawn()
		
		local phys = document:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(Vector(math.random(-100, 100), math.random(-100, 100), 175))
		end
	end

	return Dissolver
end

concommand.Add("annihilatornaya_pushka", function(ply, cmd, arg)
	if not ply:IsSuperAdmin() then return end

	ply:LagCompensation(true)
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent) then ply:LagCompensation(false) return end 
	
	if ent:IsPlayer() then
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(ply)
		dmginfo:SetDamageType(DMG_DISSOLVE)
		dmginfo:SetDamage(9999999999)
		ent:TakeDamageInfo(dmginfo)
	else
		BREACH.MakeDissolver(ent, ent:GetPos(), ply, 0)
	end
	ply:LagCompensation(false)
end)

function RemoveBonemerges(ply)
	local function SafeRemoveTbl(tbl)
		if tbl then
			for _, v in ipairs(tbl) do
				if IsValid(v) then v:Remove() end
			end
		end
	end
	
	SafeRemoveTbl(ply.BoneMergedEnts)
	SafeRemoveTbl(ply.BoneMergedHackerHat)
	SafeRemoveTbl(ply.GhostBoneMergedEnts)
end

function CalculateDamageByDistance(ply, attacker)
	if ply:GTeam() == TEAM_SCP then return 0 end
	local distsqr = ply:GetShootPos():DistToSqr(attacker:GetShootPos())
	return math.Clamp(math.ceil(distsqr * 0.00009) - 1, 0, 15)
end

function GM:EntityTakeDamage(target, dmginfo)
	if target:IsPlayer() and target:HasWeapon("item_scp_500") then
		if target:Health() <= dmginfo:GetDamage() then
			target:GetWeapon("item_scp_500"):OnUse()
			target:PrintMessage(HUD_PRINTTALK, "Using SCP 500")
		end
	end

	local at = dmginfo:GetAttacker()
	if IsValid(at) and (at:IsVehicle() or (at:IsPlayer() and at:InVehicle())) then
		dmginfo:SetDamage(0)
	end

	if target:IsPlayer() and target:Alive() then
		local dmgtype = dmginfo:GetDamageType()
		if dmgtype == 268435464 or dmgtype == 8 then
			if target:GTeam() == TEAM_SCP then
				dmginfo:SetDamage(0)
				return true
			elseif target.UsingArmor == "armor_fireproof" then
				dmginfo:ScaleDamage(0.25)
			end
		end

		if (dmgtype == DMG_SHOCK or dmgtype == DMG_ENERGYBEAM) and target.UsingArmor == "armor_electroproof" then
			dmginfo:ScaleDamage(0.1)
		end

		if dmgtype == DMG_VEHICLE then
			dmginfo:SetDamage(0)
		end
	end

	if IsValid(at) and at:IsPlayer() and target:IsPlayer() and at:GetRoleName() == SCP9571 and target:GTeam() == TEAM_SCP then
		return true
	end
end

PISTOL_AMMO = 84
PISTOL_AMMO_2 = 3
REVOLVER_AMMO = 85
REVOLVER_AMMO_2 = 5
REVOLVER_AMMO_3 = 41
REVOLVER_AMMO_4 = 109
SMG1_AMMO = 88
SMG1_AMMO_2 = 4
SHOTGUN_AMMO = 87
SHOTGUN_AMMO_2 = 7
SHOTGUN_AMMO_3 = 111
AR2_AMMO = 1
AR2_AMMO_2 = 43
GOC_AMMO = 65
GRU_AMMO = 50
SNIPER_AMMO = 1

HITGROUP_MODIFIERS = {
	[HITGROUP_HEAD] = {3, math.random(100, 110)},
	[HITGROUP_CHEST] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_LEFTARM] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_RIGHTARM] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_STOMACH] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_GEAR] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_LEFTLEG] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_RIGHTLEG] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_GENERIC] = {math.random(0.6, 0.7), math.random(20, 30)}
}

local soldier_teams = {
	[TEAM_USA] = true, [TEAM_NTF] = true, [TEAM_QRT] = true,
	[TEAM_GUARD] = true, [TEAM_SECURITY] = true, [TEAM_CHAOS] = true
}

local guard_teams = { [TEAM_GUARD] = true }
local commanders_roles = {}
local guard_model = "models/cultist/humans/mog/mog.mdl"
local stomach_hit = { [HITGROUP_STOMACH] = true, [HITGROUP_CHEST] = true, [HITGROUP_LEFTARM] = true, [HITGROUP_RIGHTARM] = true }

util.AddNetworkString("BreachFlinch")

local hitgroupfix = {}
local HEADSHOTWEPS = { ["cw_cultist_machinegun_m60"] = true, ["cw_kk_ins2_rkr"] = true }
local UNIQUEDAMAGEWEPS = { ["cw_scp_122"] = 150 }

hook.Add("EntityEmitSound", "Breach_Sound_Emit", function(t)
	local sndName = t.SoundName or ""
	if sndName == "items/ammo_pickup.wav" then return false end
	if sndName:find("player/pl_fallpain") then return false end
	if sndName:find("player/pl_drown1.wav") then return false end

	local snd = string.lower(sndName)
	--if snd:find("player/footsteps/") and not snd:find("zcity") and not snd:find("zbattle") then return false end
end)

hook.Add("EntityTakeDamage", "Hurt_Sound_Breach", function(ply, dmginfo)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	if dmginfo:IsDamageType(DMG_FALL) then
		if ply:GetPos():WithinAABox(Vector(14931.28, -10476.38, -6617), Vector(9126.84, -15756.69, -4692)) and ply:GetModel() == "models/cultist/scp/scp_860.mdl" then
			dmginfo:SetDamage(0)
		end

		if ply:GTeam() == TEAM_AR then return end
		if ply:GTeam() == TEAM_XMAS_VRAG then
			sound.Play("zpn/sfx/zpn_boss_heal0" .. math.random(1, 3) .. ".wav", ply:GetPos(), 75, 100, 2)
		else
			sound.Play("^nextoren/charactersounds/hurtsounds/fall/pldm_fallpain0" .. math.random(1, 2) .. ".wav", ply:GetPos(), 75, 100, 2)
		end
	end

	if ply:GTeam() ~= TEAM_SPEC and ply:GTeam() ~= TEAM_SCP then
		ply.LastHurtSound = ply.LastHurtSound or 0

		if ply:LastHitGroup() == HITGROUP_HEAD then return end

		local isguard = (ply:GetModel() == guard_model or ply:GTeam() == TEAM_GUARD)
		local isfemale = ply:IsFemale()
		local isrobot = (ply:GTeam() == TEAM_AR)

		local roleName = ply:GetRoleName()
		if roleName == role.Dispatcher or roleName == "Head of Facility" then isguard = false end
		if isguard and isfemale then isguard = false end

		if ply.LastHurtSound < CurTime() then
			ply.LastHurtSound = CurTime() + 5.5

			if isrobot then
			elseif ply:GTeam() == TEAM_XMAS_VRAG then
				ply:EmitSound("zpn/sfx/zpn_boss_heal0" .. math.random(1, 3) .. ".wav", 75, ply.VoicePitch or 100, 2, CHAN_VOICE)
			elseif isfemale then
				ply:EmitSound("^nextoren/charactersounds/hurtsounds/sfemale/hurt_" .. math.random(1, 66) .. ".mp3", 75, ply.VoicePitch or 100, 2, CHAN_VOICE)
			elseif isguard then
				ply:EmitSound("^nextoren/vo/mtf/mtf_hit_" .. math.random(1, 23) .. ".wav", 75, ply.VoicePitch or 100, 1, CHAN_VOICE)

				local closeguards = ents.FindInSphere(ply:GetPos(), 560)
				for _, plyy in ipairs(closeguards) do
					if IsValid(plyy) and plyy:IsPlayer() and plyy:GTeam() ~= TEAM_SPEC and plyy ~= ply then
						plyy.NextAlertSound = plyy.NextAlertSound or 0
						if (plyy:GTeam() == TEAM_GUARD or plyy:GetModel() == guard_model) then
							if plyy.NextAlertSound <= CurTime() and plyy ~= dmginfo:GetAttacker() then
								plyy.NextAlertSound = CurTime() + 45
								timer.Simple(math.random(0.0, 0.6), function()
									if IsValid(plyy) and plyy:Health() > 0 then
										plyy:EmitSound("^nextoren/vo/mtf/mtf_alert_" .. math.random(1, 5) .. ".wav", 75, plyy.VoicePitch or 100, 2, CHAN_VOICE)
									end
								end)
							end
						end
					end
				end
			else
				local rand = math.random(0, 39)
				local snd = rand == 0 and "^nextoren/charactersounds/hurtsounds/male/hurt.mp3" or ("^nextoren/charactersounds/hurtsounds/male/hurt_" .. rand .. ".wav")
				ply:EmitSound(snd, 75, ply.VoicePitch or 100, 2, CHAN_VOICE)
			end
		end
	end
end)

hook.Add("EntityTakeDamage", "SCP_457", function(ply, dmginfo)
	if dmginfo:IsDamageType(DMG_BURN) then
		dmginfo:SetDamage(math.random(5, 6))
	end
end)

function GM:PlayerDeath(victim, inflictor, attacker) end

hook.Add("PlayerDisconnected", "KillOnLeave", function(ply)
	if ply:GTeam() ~= TEAM_SPEC and ply:Health() > 0 and ply:Alive() then
		ply:Kill()
	end
end)

function GM:CheckForFriendKill(ply, attacker)
	local actHitGroup = ply:LastHitGroup()
	if ply.ZCityLastHitGroup then actHitGroup = ply.ZCityLastHitGroup end

	if IsValid(attacker) and IsValid(ply) and attacker:IsPlayer() and IsTeamKill(ply, attacker) and ply ~= attacker and attacker:GTeam() ~= TEAM_ARENA then
		local admins = {}
		for _, adm in ipairs(player.GetHumans()) do
			if adm:IsAdmin() and adm:GTeam() == TEAM_SPEC then table.insert(admins, adm) end
		end
		
		BREACH.Players:ChatPrint(admins, true, true, gteams.GetColor(attacker:GTeam()), attacker:GetRoleName(), color_white, " dont_translate:" .. attacker:Name() .. " [" .. attacker:SteamID() .. "] l:teamkill_killed", gteams.GetColor(ply:GTeam()), ply:GetRoleName(), color_white, " dont_translate:" .. ply:Name() .. " [" .. ply:SteamID() .. "]")
		BREACH.Players:ChatPrint({ply}, true, true, "l:teamkill_you_have_been_teamkilled ", gteams.GetColor(attacker:GTeam()), attacker:GetRoleName(), color_white, " dont_translate:" .. attacker:Name() .. " [" .. attacker:SteamID() .. "]l:teamkill_report_if_rulebreaker")
		
		local charname = ply:GetNamesurvivor()
		charname = (charname == "none" or charname == ply:GetRoleName()) and "" or (" " .. charname)
		
		BREACH.Players:ChatPrint({attacker}, true, true, "l:teamkill_you_teamkilled ", gteams.GetColor(ply:GTeam()), ply:GetRoleName(), color_white, " dont_translate:" .. ply:Name() .. " [" .. ply:SteamID() .. "]")
	else
		if IsValid(attacker) and IsValid(ply) and attacker:IsPlayer() and ply ~= attacker then
			if actHitGroup == HITGROUP_HEAD then
				attacker:CompleteAchievement("headshot")
			end
			BREACH.Players:ChatPrint({ply}, true, true, "l:you_have_been_killed ", gteams.GetColor(attacker:GTeam()), attacker:GetRoleName(), color_white, " dont_translate:" .. attacker:Name() .. " [" .. attacker:SteamID() .. "]")
		end
	end
end

function MakeSCPDeathSound(rolename)
	if postround or preparing then return end

	SetGlobalInt("TASKS_TG_2", GetGlobalInt("TASKS_TG_2") + 1)
	if GetGlobalInt("TASKS_TG_2") == GetGlobalInt("TASKS_TG_2_min") then
		for _, v in player.Iterator() do
			if v:GTeam() == TEAM_GUARD then
				v:AddToStatistics("Выполение задачи", 100) 
			end
		end
	end

	timer.Simple(math.Rand(3, 6), function()
		local sound = specialsoundnamescp[rolename] or string.sub(rolename, 4)
		net.Start("ForcePlaySound")
		net.WriteString("nextoren/round_sounds/intercom/scp_contained/" .. sound .. ".ogg")
		net.Broadcast()
	end)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	local isBleedOut = false
	if not IsValid(attacker) or attacker == ply or attacker:IsWorld() then
		if IsValid(ply.ZCityLastAttacker) and ply.ZCityLastAttacker:IsPlayer() then
			if ply.ZCityLastHitTime and (CurTime() - ply.ZCityLastHitTime <= 180) then
				attacker = ply.ZCityLastAttacker
				isBleedOut = true
			end
		end
	end

	CreateKillFeed(ply, attacker)

	ply.lastkilledby = attacker
	ply.rememberteamafterdeath = ply:GTeam()

	if ply:GTeam() == TEAM_SCP and not ply.IsZombie then
		MakeSCPDeathSound(ply:GetRoleName())
	end

	if ply:GTeam() == TEAM_CLASSD and not ply.IsZombie and IsValid(attacker) and attacker:IsPlayer() and attacker:GTeam() == TEAM_GUARD then
		SetGlobalInt("TASKS_TG_3", GetGlobalInt("TASKS_TG_3") + 1)
		if GetGlobalInt("TASKS_TG_3") == GetGlobalInt("TASKS_TG_3_min") then
			for _, v in player.Iterator() do
				if v:GTeam() == TEAM_GUARD then
					v:AddToStatistics("Выполение задачи", 100) 
				end
			end
		end
	end

	if ply:GTeam() == TEAM_COMBINE then
		ply:EmitSound(Sound("npc/combine_soldier/die" .. math.random(1, 3) .. ".wav"), 80)
	elseif ply:GTeam() == TEAM_AR then
		ply:EmitSound("^nextoren/ar_death" .. math.random(1, 4) .. ".mp3", 75, ply.VoicePitch or 100, 2, CHAN_VOICE)
	elseif ply:GTeam() == TEAM_XMAS_VRAG then
		ply:EmitSound("zpn/sfx/zpn_boss_death.wav", 75, ply.VoicePitch or 100, 2, CHAN_VOICE)
	end

	for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 500)) do
		if v:IsPlayer() and v:GetRoleName() == "SCP079" then
			BREACH.SendClientEvent(v, "combine_line", {text = "Очки Полезности = OS_079 + 300 // Причина : Смерть сюбьектов", color = Color(50, 211, 77)})
			v:AddToStatistics("l:mvp_kill", 100) 
		end
	end

	BREACH.SendClientEvent(ply, "flash_window")
	ply:CompleteAchievement("death")

	if ply ~= attacker and dmginfo:IsFallDamage() and IsValid(attacker) and attacker:IsPlayer() then 
		attacker:CompleteAchievement("fallkill") 
	end

	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply and not IsTeamKill(ply, attacker) then
		if attacker:GTeam() == TEAM_SCP then
			if not ply.NoRewardsForKill then attacker:AddToMVP("scpkill", 1) end
		else
			if not ply.NoRewardsForKill then
				attacker:AddToMVP("kill", 1)
				timer.Simple(.1, function()
					if not IsValid(ply) or not IsValid(attacker) then return end
					local headGroup = isBleedOut and ply.ZCityLastHitGroup or ply:LastHitGroup()
					if headGroup == HITGROUP_HEAD then attacker:AddToMVP("headshot", 1) end
				end)
			end
		end
	end

	if ply.SetNDeaths and ply.GetNDeaths and (not IsValid(attacker) or not attacker.NoRewardsForKill) then
		ply:AddNDeaths(1)
		ply:AddElo(ply:CalculateElo(20, false))
	end

	local victim = ply
	victim:Freeze(true)

	if victim.ProgibTarget then
		victim.ProgibTarget:StopForcedAnimation()
		victim.ProgibTarget.ProgibTarget = nil
		victim:StopForcedAnimation()
		victim.ProgibTarget = nil
	end

	RemoveBonemerges(victim)

	net.Start("Effect", true) net.WriteBool(false) net.Send(victim)
	net.Start("957Effect", true) net.WriteBool(false) net.Send(victim)

	victim:SetModelScale(1)
	victim.isexplosion = dmginfo:IsDamageType(DMG_BLAST)
	victim.dmg_took = dmginfo:GetDamage()

	local actualHitGroup = isBleedOut and victim.ZCityLastHitGroup or victim:LastHitGroup()

	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
		if IsTeamKill(victim, attacker) then
			if not victim.NoRewards then
				if attacker.LastDamagePly ~= victim then
					local curK = tonumber(attacker:GetBreachData("karma")) or 0
					attacker:SetBreachData("karma", curK - math.random(15, 50)) 
					timer.Simple(math.random(3, 6), function()
						if IsValid(attacker) then attacker:SetNWInt("karma", tonumber(attacker:GetBreachData("karma")) or 0) end
					end)
				end
				if attacker:GetNLevel() > 15 then attacker:AddToStatistics("l:teamkill", -2500) end
				attacker:RemoveFromStatistics("l:pacifist")
			end
		else
			if IsNeutral(attacker, victim) then
				if attacker.LastDamagePly ~= victim then
					local curK = tonumber(attacker:GetBreachData("karma")) or 0
					attacker:SetBreachData("karma", curK - math.random(1, 20)) 
					timer.Simple(math.random(3, 6), function()
						if IsValid(attacker) then attacker:SetNWInt("karma", tonumber(attacker:GetBreachData("karma")) or 0) end
					end)
				end
			end
			if victim:GTeam() ~= TEAM_SCP or victim.IsZombie == true then
				local vSci = (victim:GTeam() == TEAM_SCI or victim:GTeam() == TEAM_SPECIAL)
				local aClassD = (attacker:GTeam() == TEAM_CLASSD)
				local aSci = (attacker:GTeam() == TEAM_SCI or attacker:GTeam() == TEAM_SPECIAL)
				local vClassD = (victim:GTeam() == TEAM_CLASSD)
				
				if not ((vSci and aClassD) or (aSci and vClassD)) then
					if not AreNeutral(victim, attacker) then
						local multiply = BREACH.KillRewardMultiply or 1
						if multiply ~= 0 and not victim.NoRewardsForKill then
							if actualHitGroup ~= HITGROUP_HEAD then
								attacker:AddToStatistics("l:enemykill", 10 * multiply)
							else
								attacker:AddToStatistics("l:headshot", 50 * multiply)
							end
						end
					end
				end
			else
				attacker:AddToStatistics("l:scpkill", 400)
			end
		end
	end

	if IsValid(attacker) and attacker:IsPlayer() and AreNeutral(victim, attacker) then
		attacker:RemoveFromStatistics("l:pacifist")
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		ServerLog("[KILL] " .. attacker:Nick() .. " [" .. (attacker:GetRoleName() or "Unk") .. "] killed " .. victim:Nick() .. " [" .. (victim:GetRoleName() or "Unk") .. "]\n")
	else
		ServerLog("[DEATH] " .. victim:Nick() .. " [" .. (victim:GetRoleName() or "Unk") .. "]\n")
	end

	GAMEMODE:CheckForFriendKill(ply, attacker)

	if IsTeamKill(ply, attacker) and IsValid(attacker) and attacker:GetRoleName() == role.ClassD_Banned then
		attacker.norewardbanned = true
	end

	local multiply = BREACH.DeathRewardMultiply or 1
	if multiply > 0 then
		if not IsValid(attacker) or not attacker.NoRewardsForKill then
			victim:AddToStatistics("l:death", -10 * multiply)
		end
		victim:LevelBar(IsValid(attacker) and attacker.NoRewardsForKill)
	end

	timer.Create("Death_Scene" .. victim:SteamID(), 14, 1, function()
		if not IsValid(victim) or victim:Alive() then return end
		victim:SetupNormal()
		victim:SetSpectator()
		hook.Run("Breach_PlayerDeathSceneFinished", victim)
	end)

	if victim.TempValues and victim.TempValues.abouttoexplode then
		local current_pos = victim:GetPos()

		local dmg_info = DamageInfo()
		dmg_info:SetDamage(2000)
		dmg_info:SetDamageType(DMG_BLAST)
		dmg_info:SetAttacker(victim)
		dmg_info:SetDamageForce(-victim:GetAimVector() * 40)

		util.BlastDamageInfo(dmg_info, current_pos, 400)

		sound.Play("nextoren/others/explosion_ambient_" .. math.random(1, 2) .. ".ogg", current_pos, 100, 100, 100)

		local trigger_ent = ents.Create("base_gmodentity")
		trigger_ent:SetPos(current_pos)
		trigger_ent:SetNoDraw(true)
		trigger_ent:DrawShadow(false)
		trigger_ent:Spawn()
		trigger_ent.Die = CurTime() + 50

		net.Start("CreateParticleAtPos", true)
			net.WriteString("pillardust")
			net.WriteVector(current_pos)
		net.Broadcast()

		net.Start("CreateParticleAtPos", true)
			net.WriteString("gas_explosion_main")
			net.WriteVector(current_pos)
		net.Broadcast()

		trigger_ent.OnRemove = function(self)
			if IsValid(victim) then victim:StopParticles() end
		end
		
		trigger_ent.Think = function(self)
			self:NextThink(CurTime() + .25)
			if self.Die < CurTime() then self:Remove() return true end

			for _, v in ipairs(ents.FindInSphere(self:GetPos(), 300)) do
				if v:IsPlayer() and v:GTeam() ~= TEAM_SPEC and (v:GTeam() ~= TEAM_SCP or not v:GetNoDraw()) then
					v:Ignite(4)
				end
			end
			return true
		end
	end

	if not IsValid(attacker) or not attacker.NoRewardsForKill then ply:AddDeaths(1) end
	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply then attacker:AddFrags(1) end

	local rag = CreateLootBox(ply, dmginfo:GetInflictor(), attacker, nil, dmginfo)
	ply.lastrag = rag
	
	if ply.LootboxDisconnectReason then BREACH.DissappearCorpse(rag) end
	
	if IsValid(rag) then
		net.Start("Death_Scene", true) 
			net.WriteBool(true)
			net.WriteEntity(rag)
		net.Send(ply)
		
		local ragphys = rag:GetPhysicsObject()
		if IsValid(ragphys) then
			ragphys:SetVelocity(dmginfo:GetDamageForce() / 5)
		end
	end

	if ply:GTeam() == TEAM_ARENA and IsValid(rag) then
		timer.Simple(8, function() if IsValid(rag) then rag:Remove() end end)
		timer.Simple(9, function()
			if not IsValid(ply) or not ply.ArenaParticipant or (ply:GTeam() ~= TEAM_SPEC and ply:Alive()) then return end
			ply:SetupNormal()
			ply:ApplyRoleStats(BREACH_ROLES.MINIGAMES.minigame.roles[3])
			BREACH.PickArenaSpawn(ply)
			ply:SetNamesurvivor(ply:Nick())
		end)
	end

	ply:DropObject() 

	for _, v in player.Iterator() do
		local obs = v:GetObserverTarget()
		if obs == ply then v:ClearSpectateTarget() end
	end

	timer.Simple(0, function()
		if IsValid(rag) then
			for _, v in player.Iterator() do
				local obs = v:GetObserverTarget()
				if obs == rag or obs == ply then v:ClearSpectateTarget() end
			end
		end
	end)

	ply.ZCityLastAttacker = nil
	ply.ZCityLastHitGroup = nil
end

function GM:PostPlayerDeath(ply) end
function GM:PlayerDeathSound(ply) return true end
function GM:PlayerDeathThink(ply) return false end

function BREACH.DissappearCorpse(ent)
	if IsValid(ent) then
		ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
			
		for _, v in ipairs(ent:LookupBonemerges()) do
			if IsValid(v) then
				v:SetRenderMode(RENDERMODE_TRANSCOLOR)
				local index = tostring(v:EntIndex())
				hook.Add("Think", "DissolveBonemerge_" .. index, function()
					if IsValid(v) then
						local col = v:GetColor()
						local alpha = math.Approach(col.a, 0, -8)
			
						v:SetColor(Color(col.r, col.g, col.b, alpha))
			
						if alpha == 0 then
							v:Remove()
							hook.Remove("Think", "DissolveBonemerge_" .. index)
						end
					else
						hook.Remove("Think", "DissolveBonemerge_" .. index)
					end
				end)
			end
		end
			
		local ragindex = tostring(ent:EntIndex())
		hook.Add("Think", "DissolveRagdoll_" .. ragindex, function()
			if IsValid(ent) then
				local col = ent:GetColor()
				local alpha = math.Approach(col.a, 0, -8)
				
				ent:SetColor(Color(col.r, col.g, col.b, alpha))
				
				if alpha == 0 then
					ent:Remove()
					hook.Remove("Think", "DissolveRagdoll_" .. ragindex)
				end
			else
				hook.Remove("Think", "DissolveRagdoll_" .. ragindex)
			end
		end)
	end
end

hook.Add("HomigradDamage", "ZCity_TrackRealAttacker", function(victim, dmgInfo, hitgroup, ent)
	local attacker = dmgInfo:GetAttacker()

	if not IsValid(attacker) or not attacker:IsPlayer() then
		attacker = victim:GetPhysicsAttacker()
	end

	if IsValid(attacker) and attacker:GetClass() == "prop_ragdoll" and attacker.ply then
		attacker = attacker.ply
	end

	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
		victim.ZCityLastAttacker = attacker
		victim.ZCityLastHitGroup = hitgroup
		victim.ZCityLastHitTime = CurTime()
	end
end)

hook.Add("PlayerSpawn", "ZCity_ResetAttackerTracker", function(ply)
	ply.ZCityLastAttacker = nil
	ply.ZCityLastHitGroup = nil
end)