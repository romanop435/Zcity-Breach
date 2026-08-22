local CurTime = CurTime
local table = table
local pairs = pairs
local ipairs = ipairs
local timer = timer
local ents = ents
local hook = hook
local math = math
local ErrorNoHalt = ErrorNoHalt
local util = util
local net = net
local player = player





SCPObjects = {}
SCPNoSelectObjects = {}
TransmitSCPS = {}

SCP_VALID_ENTRIES = {
	base_speed = true,
	run_speed = true,
	max_speed = true,
	base_health = true,
	max_health = true,
	jump_power = true,
	crouch_speed = true,
	no_ragdoll = true,
	deathanimation = true,
	model_scale = true,
	hands_model = true,
	prep_freeze = true,
	no_spawn = true,
	no_model = true,
	no_swep = true,
	no_strip = true,
	scaledamage = true,
	deathloop = true,
	damagemodifier = true,
	no_select = true,
	no_draw = true,
}

SCP_DYNAMIC_VARS = {}

local lua_override = false

function UpdateDynamicVars()
	if not file.Exists("breach", "DATA") then
		file.CreateDir("breach")
	end
	if not file.Exists("breach/scp.txt", "DATA") then
		util.WriteINI("breach/scp.txt", {})
	end

	if not lua_override then
		util.LoadINI("breach/scp.txt", SCP_DYNAMIC_VARS)
	end
end

UpdateDynamicVars()

function SaveDynamicVars()
	util.WriteINI("breach/scp.txt", SCP_DYNAMIC_VARS)
end

function SendSCPList(ply)
	net.Start("SCPList")
	net.WriteTable(SCPS or {})
	net.WriteTable(TransmitSCPS)
	net.Send(ply)
end

function GetSCP(name)
	return SCPObjects[name] or SCPNoSelectObjects[name]
end

function RegisterSCP(name, model, weapon, static_stats, dynamic_stats)
	if not name or not model or not weapon or not static_stats then return end

	dynamic_stats = dynamic_stats or {}

	if SCPObjects[name] then
		error("SCP " .. name .. " is already registered!")
	end

	if not ALLLANGUAGES["english"]["role"][name] then
		error("No language entry for: " .. name)
	end

	local spawn = _G["SPAWN_" .. name]
	local pos = false

	if not static_stats.no_spawn and not dynamic_stats.no_spawn then
		if spawn and (isvector(spawn) or istable(spawn)) then
			pos = spawn
		end
	end

	local scp = ObjectSCP(name, model, weapon, pos, static_stats, dynamic_stats)

	if not scp.basestats.no_select then
		SCPObjects[name] = scp
		table.insert(SCPS, name)
	else
		SCPNoSelectObjects[name] = scp
		table.insert(TransmitSCPS, name)
	end

	return true
end

ObjectSCP = {}
ObjectSCP.__index = ObjectSCP

function ObjectSCP:Create(name, model, weapon, pos, static_stats, dynamic_stats)
	local scp = setmetatable({}, ObjectSCP)
	scp.Create = function() end

	scp.name = name
	scp.model = model
	scp.swep = weapon
	scp.spawnpos = pos
	scp.basestats = {}

	scp.callback = function() end
	scp.post = function() end

	if not SCP_DYNAMIC_VARS[name] then
		SCP_DYNAMIC_VARS[name] = {}
	end

	local dv = SCP_DYNAMIC_VARS[name]

	for k, v in pairs(dynamic_stats) do
		if SCP_VALID_ENTRIES[k] then
			local istab = istable(v)
			local var = istab and v.var or v

			if dv[k] then
				var = dv[k]
			else
				dv[k] = var
			end

			if istab then
				if v.min or v.max then
					if not isnumber(var) then
						ErrorNoHalt(name .. " entry: " .. k .. ". Number expected, got " .. type(var))
						continue
					end

					if v.min then
						var = math.max(v.min, var)
					end

					if v.max then
						var = math.min(v.max, var)
					end
				end
			end

			scp.basestats[k] = var
		end
	end

	for k, v in pairs(static_stats) do
		if SCP_VALID_ENTRIES[k] then
			scp.basestats[k] = v
		end
	end

	return scp
end

function ObjectSCP:SetCallback(cb, post)
	if post then
		self.post = cb
	else
		self.callback = cb
	end
end

function ObjectSCP:SetupPlayer(ply, ...)
	if self.callback then
		if self.callback(ply, self.basestats, ...) then
			return
		end
	end

	ply:SetNWInt("TASKS_Hell", 0)
	net.Start("ots_off")
	net.Send(ply) 
	ply.IsInThirdPerson = false 
	ply:UnSpectate()
	ply:GodDisable()

	if not self.basestats.no_strip then
		ply:StripWeapons()
		ply:RemoveAllAmmo()
	end

	ply.no_spawn = self.basestats.no_spawn == true

	if not self.basestats.no_spawn then
		if not SPAWN_SCP_RANDOM_COPY or #SPAWN_SCP_RANDOM_COPY <= 0 then
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
		end
		local spawn_pos = table.remove(SPAWN_SCP_RANDOM_COPY, math.random(1, #SPAWN_SCP_RANDOM_COPY))
		
		ply:Spawn()
		if isvector(spawn_pos) then
			ply:SetPos(spawn_pos)
		elseif self.spawnpos and isvector(self.spawnpos) then
			ply:SetPos(self.spawnpos)
		end
	end

	timer.Simple(10, function()
		if not IsValid(ply) then return end
		local search_name = string.Replace(self.name, "SCP", "")
		for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 1300)) do
			if v:GetClass() == "sign_n" then
				v:SetItem(search_name)
			end
		end
	end)

	ply:SetGTeam(TEAM_SCP)
	ply:SetRoleName(self.name)

	if not self.basestats.no_model then
		ply:SetModel(self.model)
	end

	if not self.basestats.damagemodifier then
		ply.DamageModifier = 0.15
	else
		ply.DamageModifier = self.basestats.damagemodifier
	end

	ply:SetModelScale(self.basestats.model_scale or 1)

	local role_name_lang = GetLangRole(self.name)
	local target_role
	
	if BREACH_ROLES and BREACH_ROLES.SCP and BREACH_ROLES.SCP.scp and BREACH_ROLES.SCP.scp.roles then
		for _, role in ipairs(BREACH_ROLES.SCP.scp.roles) do
			if role.name == role_name_lang then
				target_role = role
				break
			end
		end
	end

	if target_role and target_role.health then
		ply:SetHealth(target_role.health)
		ply:SetMaxHealth(target_role.health)
	else
		ply:SetHealth(self.basestats.base_health or 1500)
		ply:SetMaxHealth(self.basestats.max_health or 1500)
	end

	ply:SetWalkSpeed(self.basestats.base_speed or 200)
	ply:SetSlowWalkSpeed(self.basestats.base_speed or 200)
	ply:SetRunSpeed(self.basestats.run_speed or 200)
	ply:SetMaxSpeed(self.basestats.max_speed or 200)
	ply:SetCrouchedWalkSpeed(self.basestats.crouch_speed or 0.6)
	ply:SetJumpPower(0)

	if self.basestats.deathanimation then
		ply.DeathAnimation = self.basestats.deathanimation
	end

	if self.basestats.deathloop then
		ply.DeathLoop = self.basestats.deathloop
	end

	if self.basestats.scaledamage then
		ply.ScaleDamage = self.basestats.scaledamage
	end

	ply.StartedPlayAt = CurTime() + 100

	if not self.basestats.no_swep then
		for _, v in ipairs(self.swep) do
			ply.JustSpawned = true
			ply:Give(v)
			timer.Simple(0.1, function()
				if IsValid(ply) then
					ply.JustSpawned = false
				end
			end)
		end

		if self.swep[1] then
			ply:SelectWeapon(self.swep[1])
			local wep = ply:GetWeapon(self.swep[1])
			if IsValid(wep) then
				wep.ShouldFreezePlayer = self.basestats.prep_freeze == true
			end
		end
	end

	ply:SetArmor(0)
	ply:Flashlight(false)
	ply:AllowFlashlight(false)
	ply:SetNoDraw(self.basestats.no_draw == true)
	ply:SetNoTarget(true)

	ply.BaseStats = nil
	ply.UsingArmor = nil
	ply.Active = true
	ply.canblink = false
	ply.noragdoll = self.basestats.no_ragdoll == true
	ply.handsmodel = self.basestats.hands_model

	ply:SetupHands()
	hook.Run("PlayerWeaponChanged", ply, ply:GetActiveWeapon(), true)

	net.Start("RolesSelected")
	net.Send(ply)

	if ply:IsPremium() and not ply.SelectedSCPAlready then
		timer.Simple(0.65, function()
			if not IsValid(ply) then return end
			local tab = table.Copy(SCPS or {})
			for _, ply1 in player.Iterator() do
				table.RemoveByValue(tab, ply1:GetRoleName())
			end
		end)
	end

	if self.post then
		self.post(ply)
	end
end

setmetatable(ObjectSCP, { __call = ObjectSCP.Create })

timer.Simple(0, function()
	hook.Run("RegisterSCP")
	SaveDynamicVars()
	
	for _, v in player.Iterator() do
		SendSCPList(v)
	end
end)