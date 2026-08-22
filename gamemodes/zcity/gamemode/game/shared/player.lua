local FindMetaTable = FindMetaTable
local CurTime = CurTime
local pairs = pairs
local ipairs = ipairs
local string = string
local table = table
local timer = timer
local hook = hook
local math = math
local pcall = pcall
local tonumber = tonumber
local tostring = tostring
local ents = ents
local ErrorNoHalt = ErrorNoHalt
local util = util
local net = net
local player = player



local mply = FindMetaTable("Player")
local ment = FindMetaTable("Entity")

function mply:IsPremium()
	if self:IsSuperAdmin() or self:IsDonator() or self:IsAdmin() or (RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[self:SteamID64()]) or self:GetUserGroup() == "premium" or self:GetNWBool("Shaky_IsPremium") then
		return true
	end
	return false
end

function mply:IsLeaning()
	return false
end

local escape_teams = {
	[TEAM_SECURITY] = true, [TEAM_GUARD] = true, [TEAM_CLASSD] = true,
	[TEAM_SCI] = true, [TEAM_SPECIAL] = true, [TEAM_OSN] = true
}

function mply:CanEscapeHand() return escape_teams[self:GTeam()] or false end
function mply:CanEscapeFBI() return escape_teams[self:GTeam()] or false end
function mply:CanEscapeChaosRadio() return self:GTeam() == TEAM_CLASSD end
function mply:CanEscapeCar() return self:GTeam() ~= TEAM_SCP end
function mply:CanEscapeO5() return true end


BREACH.RoleDataCache = BREACH.RoleDataCache or {}

function BREACH.GetRoleDataByName(roleName)
	if BREACH.RoleDataCache[roleName] then
		return BREACH.RoleDataCache[roleName].role, BREACH.RoleDataCache[roleName].team
	end

	if not BREACH_ROLES then return nil, nil end
	for _, faction in pairs(BREACH_ROLES) do
		for _, group in pairs(faction) do
			if group.roles then
				for _, role in ipairs(group.roles) do
					BREACH.RoleDataCache[role.name] = {role = role, team = group.team}
					if role.name == roleName then
						return role, group.team
					end
				end
			end
		end
	end
	return nil, nil
end

function mply:GetFreeEXP()
	if CLIENT and self.WTh_FreeEXPCache ~= nil then return self.WTh_FreeEXPCache end
	return self:GetNWInt("WTh_FreeEXP", 0)
end

function mply:GetActiveResearch()
	if CLIENT and self.WTh_ActiveResearch_Cache ~= nil then return self.WTh_ActiveResearch_Cache end
	return self:GetNW2String("WTh_ActiveResearch", "")
end

function mply:GetRoleInvestedEXP(roleName)
	if self.WTh_RolesEXPCache and self.WTh_RolesEXPCache[roleName] then
		return tonumber(self.WTh_RolesEXPCache[roleName]) or 0
	end
	return 0
end

mply.WTh_UnlockedCache = mply.WTh_UnlockedCache or {}
mply.WTh_LastUnlockedJSON = mply.WTh_LastUnlockedJSON or ""

function mply:IsRoleUnlocked(roleName)
	local roleData = BREACH.GetRoleDataByName(roleName)
	if roleData and (not roleData.req or not roleData.cost or roleData.cost <= 0) then return true end

	if roleData and roleData.cost and roleData.cost > 0 then
		local invested = self:GetRoleInvestedEXP(roleName)
		if invested >= roleData.cost then return true end
	end
	return false
end

function mply:GetActiveUpgradeResearch()
	local str = (CLIENT and self.WTh_ActiveUpgrade_Cache ~= nil) and self.WTh_ActiveUpgrade_Cache or self:GetNW2String("WTh_ActiveUpgrade", "")
	if str == "" then return nil, nil end
	local parts = string.Split(str, ":")
	return parts[1], parts[2]
end

function mply:GetUpgradeInvestedEXP(roleName, upgradeId)
	if self.WTh_UpgEXPCache and self.WTh_UpgEXPCache[roleName] and self.WTh_UpgEXPCache[roleName][upgradeId] then
		return tonumber(self.WTh_UpgEXPCache[roleName][upgradeId]) or 0
	end
	return 0
end

mply.WTh_UpgUnlockedCache = mply.WTh_UpgUnlockedCache or {}
mply.WTh_LastUpgUnlockedJSON = mply.WTh_LastUpgUnlockedJSON or ""

function mply:IsUpgradeUnlocked(roleName, upgradeId)
	local roleData = BREACH.GetRoleDataByName(roleName)
	if roleData and roleData.upgrades and roleData.upgrades[upgradeId] then
		local upgData = roleData.upgrades[upgradeId]
		if upgData.cost and upgData.cost > 0 then
			if self:GetUpgradeInvestedEXP(roleName, upgradeId) >= upgData.cost then return true end
		end
	end

	if self.WTh_UpgUnlockedCache and self.WTh_UpgUnlockedCache[roleName] and self.WTh_UpgUnlockedCache[roleName][upgradeId] then return true end

	local json = self:GetNW2String("WTh_UnlockedUpgrades", "{}")
	if self.WTh_LastUpgUnlockedJSON ~= json then
		local parsed = {}
		pcall(function() parsed = util.JSONToTable(json) or {} end)
		self.WTh_UpgUnlockedCache = parsed
		self.WTh_LastUpgUnlockedJSON = json
	end
	
	return self.WTh_UpgUnlockedCache[roleName] and self.WTh_UpgUnlockedCache[roleName][upgradeId] == true
end

function mply:AddRoleEXPWT(roleName, amount)
	if not self.WTh_DataLoaded then return end

	local roleData = BREACH.GetRoleDataByName(roleName)
	if not roleData or self:IsRoleUnlocked(roleName) then return end

	local current = self:GetRoleInvestedEXP(roleName) + amount
	local cost = roleData.cost or 0
	local is_unlocked = false

	if current >= cost then
		current = cost
		is_unlocked = true
		
		self.WTh_UnlockedCache[roleName] = true
		self:RXSENDNotify("Вы исследовали новую роль: ", Color(0, 255, 0), GetLangRole(roleName))
		
		if self:GetActiveResearch() == roleName then
			self:SetBreachData("active_research", "")
			self:SetNW2String("WTh_ActiveResearch", "")
			if SERVER then self.WTh_ActiveResearch_Cache = "" end
		end

		net.Start("WTh_SyncData") net.WriteString("role_unlocked") net.WriteString(roleName) net.Send(self)
	end

	self.WTh_RolesEXPCache = self.WTh_RolesEXPCache or {}
	self.WTh_RolesEXPCache[roleName] = current

	local sid64 = self:SteamID64()
	local rName = sql.SQLStr(roleName)
	local q_upsert = string.format([[
		INSERT OR REPLACE INTO breach_roles (steamid64, rolename, exp, unlocked) 
		VALUES ('%s', %s, %d, %d)
	]], sid64, rName, current, is_unlocked and 1 or 0)
	
	if newMysql then newMysql.query(q_upsert) end

	net.Start("WTh_SyncData") net.WriteString("update_exp") net.WriteString(roleName) net.WriteInt(current, 32) net.Send(self)
end

mply.WTh_BlacklistCache = mply.WTh_BlacklistCache or {}

function mply:GetBlacklistedRoles()
	return self.WTh_BlacklistCache or {}
end

function mply:HasAbilityModifier(effect_name)
	local roleName = self:GetRoleName()
	local roleData = BREACH.GetRoleDataByName(roleName)
	if not roleData or not roleData.upgrades then return false, 0 end

	for upg_id, upg_data in pairs(roleData.upgrades) do
		if upg_data.type == "ability_modifier" and upg_data.effect == effect_name then
			if self:IsUpgradeUnlocked(roleName, upg_id) then
				return true, upg_data.val
			end
		end
	end
	return false, 0
end

function mply:SetEscapeEXP(name, n)
	self:AddToStatistics(name, n * tonumber("1." .. tostring(self:GetNLevel() * 2)))
end

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull

local temp_attacker = NULL
local temp_attacker_team = -1
local temp_pen_ents = {}
local temp_override_team

local function MeleeTraceFilter(ent)
	if ent == temp_attacker or ent:Team() == temp_attacker_team then return false end
	return true
end

local function CheckFHB(tr)
	if tr.Entity and tr.Entity.FHB and IsValid(tr.Entity) then
		tr.Entity = tr.Entity:GetParent()
	end
end

local function InvalidateCompensatedTrace(tr, start, distance)
	if IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.HitPos:DistToSqr(start) > distance * distance + 144 then
		tr.Hit = false
		tr.HitNonWorld = false
		tr.Entity = NULL
	end
end

local melee_trace = { filter = MeleeTraceFilter, mask = MASK_SOLID, mins = Vector(), maxs = Vector() }

function mply:MeleeTrace(distance, size, start, dir, hit_team_members, override_team, override_mask)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	temp_attacker = self
	temp_attacker_team = self:Team()
	temp_override_team = override_team
	
	melee_trace.start = start
	melee_trace.endpos = start + dir * distance
	melee_trace.mask = override_mask or MASK_SOLID
	melee_trace.mins.x, melee_trace.mins.y, melee_trace.mins.z = -size, -size, -size
	melee_trace.maxs.x, melee_trace.maxs.y, melee_trace.maxs.z = size, size, size
	melee_trace.filter = self

	local tr = util_TraceLine(melee_trace)
	CheckFHB(tr)

	if tr.Hit then return tr end
	return util_TraceHull(melee_trace)
end

function mply:CompensatedMeleeTrace(distance, size, start, dir, hit_team_members, override_team)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	self:LagCompensation(true)
	local tr = self:MeleeTrace(distance, size, start, dir, hit_team_members, override_team)
	CheckFHB(tr)
	self:LagCompensation(false)

	InvalidateCompensatedTrace(tr, start, distance)
	return tr
end

function mply:PenetratingMeleeTrace(distance, size, start, dir, hit_team_members)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	temp_pen_ents = {}
	melee_trace.start = start
	melee_trace.endpos = start + dir * distance
	melee_trace.mask = MASK_SOLID
	melee_trace.mins.x, melee_trace.mins.y, melee_trace.mins.z = -size, -size, -size
	melee_trace.maxs.x, melee_trace.maxs.y, melee_trace.maxs.z = size, size, size
	melee_trace.filter = self

	local t = {}
	local onlyhitworld

	for i = 1, 50 do
		local tr = util_TraceLine(melee_trace)
		if not tr.Hit then tr = util_TraceHull(melee_trace) end
		if not tr.Hit then break end

		if tr.HitWorld then
			table.insert(t, tr)
			break
		end

		if onlyhitworld then return end

		CheckFHB(tr)
		local ent = tr.Entity

		if IsValid(ent) then
			if not ent:IsPlayer() then
				melee_trace.mask = MASK_SOLID_BRUSHONLY
				onlyhitworld = true
			end
			table.insert(t, tr)
			temp_pen_ents[ent] = true
		end
	end
	temp_pen_ents = {}
	return t, onlyhitworld
end

function mply:CompensatedZombieMeleeTrace(distance, size, start, dir, hit_team_members)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	self:LagCompensation(true)

	local hit_entities = {}
	local t, hitprop = self:PenetratingMeleeTrace(distance, size, start, dir, hit_team_members)
	local t_legs = self:PenetratingMeleeTrace(distance, size, self:WorldSpaceCenter(), dir, hit_team_members)

	if not t then self:LagCompensation(false) return end

	for _, tr in ipairs(t) do hit_entities[tr.Entity] = true end

	if not hitprop then
		for _, tr in ipairs(t_legs) do
			if not hit_entities[tr.Entity] then table.insert(t, tr) end
		end
	end

	for _, tr in ipairs(t) do
		InvalidateCompensatedTrace(tr, tr.StartPos, distance)
	end

	self:LagCompensation(false)
	return t
end

function ment:LookupBonemerges()
	local entstab = ents.FindByClassAndParent("ent_bonemerged", self)
	local newtab = {}
	if istable(entstab) then
		for _, v in ipairs(entstab) do
			if IsValid(v) then table.insert(newtab, v) end
		end
	end
	return newtab
end

function mply:GetPrimaryWeaponAmount()
	local count = 0
	for _, v in ipairs(self:GetWeapons()) do
		if not (v.UnDroppable or v.Equipableitem) then count = count + 1 end
	end
	return count
end

hook.Add("StartCommand", "LockMovement", function(ply, cmd)
	if cmd:KeyDown(IN_ALT1) or cmd:KeyDown(IN_ALT2) then
		cmd:ClearButtons()
	end
end)

function mply:RequiredEXP()
	return 680 * math.max(1, self.GetNLevel and self:GetNLevel() or 1)
end

function mply:IsFemale()
	if string.find(string.lower(self:GetModel()), "female") or self:GetFemale() then return true end
	if self:GetRoleName() == role.Dispatcher and not self:GetModel():find("dispatch_male") then return true end
	if self:GetRoleName() == role.SCI_SPECIAL_HEALER then return true end
	return false
end

function mply:CanSee(ent)
	local tr = util.TraceLine({
		start = self:GetEyeTrace().StartPos,
		endpos = ent:EyePos(),
		filter = {self, ent},
		mask = MASK_BULLET
	})
	return tr.Fraction == 1.0
end

local vec_up = Vector(0, 0, 32768)

function GroundPos(pos)
	local tr = util.TraceLine({
		start = pos,
		endpos = pos - vec_up,
		mask = MASK_BLOCKLOS
	})
	return tr.Hit and tr.HitPos or pos
end

net.Receive("hideinventory", function()
	HideEQ(net.ReadBool())
end)

BREACH = BREACH or {}
EQHUD = EQHUD or {}

function BetterScreenScale()
	return math.max(math.min(ScrH(), 1080) / 1080, .851)
end

if IsValid(BREACH.Inventory) then
	BREACH.Inventory:Remove()
	local client = LocalPlayer()
	if client.MovementLocked then client.MovementLocked = nil end
	gui.EnableScreenClicker(false)
end

local clrgreyinspect2 = Color(198, 198, 198)
local clrgreyinspect = ColorAlpha(clrgreyinspect2, 140)
local clrgreyinspectdarker = Color(94, 94, 94)

local friendstable = {
	[TEAM_GUARD]    = {TEAM_SECURITY, TEAM_SCI, TEAM_SPECIAL, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_SECURITY] = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_NTF]      = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_QRT]      = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_NTF, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_OSN]      = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_ALPHA1},
	[TEAM_ALPHA1]   = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN},
	[TEAM_SCI]      = {TEAM_SPECIAL, TEAM_SECURITY, TEAM_GUARD, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_SPECIAL]  = {TEAM_SCI, TEAM_SECURITY, TEAM_GUARD, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_SCP]      = {TEAM_DZ}, [TEAM_DZ] = {TEAM_SCP},
	[TEAM_CHAOS]    = {TEAM_CLASSD}, [TEAM_CLASSD] = {TEAM_CHAOS},
}

local enemyTable = {
	[TEAM_GUARD]    = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP},
	[TEAM_SECURITY] = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP},
	[TEAM_NTF]      = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP},
	[TEAM_QRT]      = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP},
	[TEAM_OSN]      = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP},
	[TEAM_ALPHA1]   = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP},
	[TEAM_SCI]      = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP, TEAM_USA, TEAM_DZ},
	[TEAM_SPECIAL]  = {TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP, TEAM_USA, TEAM_DZ},
	[TEAM_CLASSD]   = {TEAM_GUARD, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1, TEAM_SCI, TEAM_SPECIAL, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP, TEAM_USA, TEAM_DZ},
	[TEAM_CHAOS]    = {TEAM_GUARD, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1, TEAM_GRU},
	[TEAM_GOC]      = {TEAM_GUARD, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1, TEAM_SCI, TEAM_SPECIAL, TEAM_CLASSD, TEAM_CHAOS, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_SCP, TEAM_USA, TEAM_DZ},
	[TEAM_GRU]      = {TEAM_GUARD, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1, TEAM_CHAOS, TEAM_GOC, TEAM_AR, TEAM_CBG, TEAM_SCP, TEAM_USA, TEAM_DZ},
	[TEAM_AR]       = {TEAM_GUARD, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1},
	[TEAM_CBG]      = {TEAM_GUARD, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1, TEAM_SCI, TEAM_SPECIAL, TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_SCP, TEAM_USA, TEAM_DZ},
	[TEAM_SCP]      = {TEAM_GUARD, TEAM_SECURITY, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_ALPHA1, TEAM_SCI, TEAM_SPECIAL, TEAM_CLASSD, TEAM_CHAOS, TEAM_GOC, TEAM_GRU, TEAM_AR, TEAM_CBG, TEAM_USA},
}

local friendsgrufriendly = { TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_QRT }

function IsTeamKill(victim, attacker)
	if not IsValid(victim) or not IsValid(attacker) or not attacker:IsPlayer() then return false end
	if victim == attacker then return false end
	local vteam, ateam = victim:GTeam(), attacker:GTeam()
	if vteam == ateam then return true end
	if friendstable[ateam] and table.HasValue(friendstable[ateam], vteam) then return true end
	return false
end

function IsNeutral(attacker, victim)
	if not IsValid(attacker) or not IsValid(victim) or attacker == victim then return false end
	local ateam, vteam = attacker:GTeam(), victim:GTeam()

	if ateam == TEAM_GRU and table.HasValue(friendsgrufriendly, vteam) then return false end
	if vteam == TEAM_GRU and table.HasValue(friendsgrufriendly, ateam) then return false end
	if friendstable[ateam] and table.HasValue(friendstable[ateam], vteam) then return false end
	if enemyTable[ateam] and table.HasValue(enemyTable[ateam], vteam) then return false end
	return true
end

local neutralstable = { [TEAM_SECURITY] = true, [TEAM_SCI] = true, [TEAM_SPECIAL] = true, [TEAM_CLASSD] = true }

function AreNeutral(victim, attacker)
	if not IsValid(victim) or not IsValid(attacker) then return false end
	return neutralstable[victim:GTeam()] and neutralstable[attacker:GTeam()]
end

function CanBeNeutral(ply)
	return IsValid(ply) and neutralstable[ply:GTeam()] or false
end

function mply:GetEDP()
	if not self.GetNEscapes or not self.GetNDeaths then return "N/A" end
	local escapes, deaths = self:GetNEscapes(), self:GetNDeaths()
	local total = escapes + deaths
	if deaths == 0 then deaths = 1 end
	return (escapes / deaths) * total
end

function mply:GetUsingCloth() return self.UsingCloth or "" end
function mply:GetUsingHelmet() return self.Hat or "" end
function mply:GetUsingArmor() return self.ArmorEnt or "" end
function mply:GetUsingBag() return self.BagEnt or "" end

function mply:GetAverageElo()
	local average, count = 0, 0
	for _, v in player.Iterator() do
		if v.GetElo and v:GTeam() ~= TEAM_SPEC and v ~= self then
			average = average + v:GetElo()
			count = count + 1
		end
	end
	return average / math.max(1, count)
end

function mply:CalculateElo(k_factor, escape)
	if not self.GetElo or BREACH.DisableElo then return 0 end

	local score = escape and 1 or 0 
	if score == 0 then k_factor = k_factor / 4 end
	
	local current_rating = self:GetElo() or 0
	local average_rating = self:GetAverageElo() or 0
	local expected_score = 1 / (1 + 10^((average_rating - current_rating) / 400))
	
	return math.Round(k_factor * (score - expected_score), 1)
end

function uracos() return player.GetBySteamID("STEAM_0:0:18725400") end
function shaky() return player.GetBySteamID64("76561198869328954") end
function imper() return player.GetBySteamID64("76561198966614836") end
function impertr() return imper():GetEyeTrace().Entity end
function shakytr() return shaky():GetEyeTrace().Entity end

sound.Add({
	name = "character.inventory_interaction",
	volume = .1,
	channel = CHAN_STATIC,
	sound = "nextoren/charactersounds/inventory/nextoren_inventory_select.ogg"
})


function TakeWep(entid, weaponname)
	net.Start("LC_TakeWep", true)
		net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
		net.WriteString(weaponname)
	net.SendToServer()
end

BREACH.AmmoTranslation = {
	["AR2"] = "l:machinegun_ammo", ["GRU"] = "l:gru_ammo", ["SMG1"] = "l:smg_ammo",
	["Pistol"] = "l:pistol_ammo", ["Revolver"] = "l:revolver_ammo", ["GOC"] = "l:goc_ammo",
	["Shotgun"] = "l:shotgun_ammo", ["Sniper"] = "l:sniper_ammo",
}

local cdforuse, cdforusetime = 0, 0.2

if SERVER then
	util.AddNetworkString("tazer_load")
	net.Receive("tazer_load", function(len, ply)
		local id = net.ReadInt(8)
		local itm = ply.Inventory["Items"][id]
		if itm and itm.class and itm.class:find("battery_") and ply:IIHasWeapon("item_tazer") then
			local charge = 15
			local act = tonumber(ply:GetNWInt("ActiveSlot"))
			if ply.Inventory["Items"][act] and ply.Inventory["Items"][act].class == "item_tazer" then
				local wep = ply:GetActiveWeapon()
				if IsValid(wep) then wep:SetClip1(math.min(15, tonumber(wep:Clip1()) + charge)) end
				ply:RemoveItem(id)
			else
				for k, v in pairs(ply.Inventory["Items"]) do
					if v.class == "item_tazer" then
						ply.Inventory["Items"][k].Clip = math.min(15, tonumber(v.Clip or 0) + charge)
						ply:RemoveItem(id)
					end
				end
			end
		end
	end)
end

function HideEQ(open_inventory)
	if not open_inventory then cdforuse = CurTime() + cdforusetime end
	EQHUD.enabled = false
	gui.EnableScreenClicker(false)

	if IsValid(BREACH.Inventory) then BREACH.Inventory:Remove() end

	if open_inventory then
		net.Start("ShowEQAgain", true) net.SendToServer()
	else
		local client = LocalPlayer()
		if client.MovementLocked and not client.AttackedByBor then
			net.Start("LootEnd", true) net.SendToServer()
			client.MovementLocked = nil
		end
	end
end

function CanShowEQ()
	local client = LocalPlayer()
	local t = client:GTeam()
	return t ~= TEAM_SPEC and t ~= TEAM_SCP and client:Alive() and client:GetMoveType() ~= MOVETYPE_OBSERVER
end

function IsEQVisible() return EQHUD.enabled end

function mply:HaveSpecialAb(rolename)
	for i, v in pairs(BREACH_ROLES) do
		if i == "SCP" or i == "OTHER" then continue end
		for _, group in pairs(v) do
			for _, role in ipairs(group.roles) do
				if role.name == rolename and role.ability and self:GetNWString("AbilityName") == role.ability[1] then 
					return true 
				end
			end
		end
	end
	return false
end

hook.Add("PlayerButtonDown", "Specials", function(ply, button)
	local expectedBtn
	if SERVER then
		expectedBtn = ply.specialability
	else
		local cvar = GetConVar("breach_config_useability")
		expectedBtn = cvar and cvar:GetInt()
	end

	if not expectedBtn or button ~= expectedBtn then return end
	if ply:GetSpecialCD() > CurTime() or ply:IsFrozen() then return end

	if ply:HaveSpecialAb(role.Goc_Special) then
		if SERVER then
			if not ply.TempValues.UsedTeleporter then
				ply:SetSpecialCD(CurTime() + 3)
				if ply:GetPos():WithinAABox(Vector(-9240.08, -1075.48, 2639.84), Vector(-12292.91, 1553.17, 1209.92)) then return end
				ply.TempValues.UsedTeleporter = true
				if not ply:IsOnGround() then ply:SetSpecialCD(CurTime() + 5) return end

				local teleporter = ents.Create("ent_goc_teleporter")
				teleporter:SetOwner(ply) teleporter:SetPos(ply:GetPos() + Vector(0,0,3)) teleporter:Spawn()
				ply.teleporterentity = teleporter
			elseif IsValid(ply.teleporterentity) then
				ply:SetSpecialCD(CurTime() + 45)
				BREACH.SendClientEvent(nil, "particle_attach", {effect = "mr_portal_1a", entity = ply, attachment = "waist"})
				
				net.Start("ThirdPersonCutscene2", true) net.WriteUInt(2, 4) net.WriteBool(false) net.Send(ply)
				ply:SetMoveType(MOVETYPE_OBSERVER) ply:EmitSound("nextoren/others/introfirstshockwave.wav", 115, 100, 1.4)
				ply:ScreenFade(SCREENFADE.OUT, color_white, 1.4, 1)

				timer.Create("goc_special_teleport"..ply:SteamID64(), 2, 1, function()
					if not IsValid(ply) then return end
					ply:ScreenFade(SCREENFADE.IN, color_white, 2, 0.3) ply:StopParticles()
					ply:SetMoveType(MOVETYPE_WALK) ply:SetPos(ply.teleporterentity:GetPos())
				end)
				ply:SetForcedAnimation("MPF_Deploy")
			end
		end

	elseif ply:HaveSpecialAb(role.UIU_Agent_Specialist) then
		ply:SetSpecialCD(CurTime() + 90)
		if SERVER then
			local grenade = ents.Create("cw_uiu_wh_grenade")
			grenade:SetPos(ply:GetShootPos()) grenade:Spawn() grenade:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			local phy = grenade:GetPhysicsObject()
			if IsValid(phy) then
				phy:SetVelocity(ply:GetAimVector() * 750 + ply:GetVelocity() + Vector(0,0,200))
				phy:SetAngleVelocity(Vector(500, 200, 0)) phy:SetBuoyancyRatio(1)
			end
			timer.Simple(11, function()
				if IsValid(grenade) then grenade:EmitSound("^rxsend/wh_uiu_grenade/gren_explode.ogg") grenade:Remove() end
			end)
		end

	elseif ply:HaveSpecialAb(role.UIU_Commander) then
		ply:SetSpecialCD(CurTime() + 45)
		if SERVER then net.Start("fbi_commanderabillity", true) net.Send(ply) end

	elseif ply:HaveSpecialAb(role.ClassD_Thief) then
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({ start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply })
			ply:LagCompensation(false)
			
			local target = tr.Entity
			if not IsValid(target) or not target:IsPlayer() or target:GTeam() == TEAM_SCP then
				ply:RXSENDNotify("l:thief_look_on_them") ply:SetSpecialCD(CurTime() + 5) return
			end

			local actSlot = tonumber(target:GetNWInt("ActiveSlot", 0))
			if actSlot == 0 then ply:RXSENDNotify("l:thief_cant_steal") ply:SetSpecialCD(CurTime() + 5) return end

			local itemData = target.Inventory["Items"][actSlot]
			if not itemData or not itemData.class then ply:RXSENDNotify("l:thief_cant_steal") ply:SetSpecialCD(CurTime() + 5) return end

			local wepTbl = weapons.GetStored(itemData.class)
			if not wepTbl or wepTbl.UnDroppable or wepTbl.droppable == false then
				ply:RXSENDNotify("l:thief_cant_steal") ply:SetSpecialCD(CurTime() + 5) return
			end

			if InventoryGetFreeSlot(ply) > tonumber(ply:GetNWInt("InventoryMaxSlots", 8)) then
				ply:RXSENDNotify("l:thief_need_slot") ply:SetSpecialCD(CurTime() + 5) return
			end

			local wepClass = itemData.class
			ply:BrProgressBar("l:stealing", 1.45, "nextoren/gui/special_abilities/ability_placeholder.png", target, false, function()
				if not IsValid(target) or not IsValid(ply) then return end
				local currentSlot = tonumber(target:GetNWInt("ActiveSlot", 0))
				if currentSlot ~= actSlot or not target.Inventory["Items"][currentSlot] or target.Inventory["Items"][currentSlot].class ~= wepClass then
					ply:RXSENDNotify("l:thief_cant_steal") return
				end
				local freeSlot = InventoryGetFreeSlot(ply)
				if freeSlot > tonumber(ply:GetNWInt("InventoryMaxSlots", 8)) then ply:RXSENDNotify("l:thief_need_slot") return end

				local target_wep = target:GetActiveWeapon()
				local final_steal_data = table.Copy(target.Inventory["Items"][currentSlot])

				if IsValid(target_wep) and target_wep:GetClass() == wepClass then
					final_steal_data = GetWeaponInvData(target_wep)
					if target_wep.ActiveAttachments then table.Empty(target_wep.ActiveAttachments) end
					target_wep:Remove() 
				end

				target.Inventory["Items"][currentSlot] = {}
				target:SetNWInt("ActiveSlot", 0) target:SelectWeapon("br_holster")
				ply.Inventory["Items"][freeSlot] = final_steal_data
				
				if SendInventoryData then SendInventoryData(target) SendInventoryData(ply) end
				ply:SetSpecialCD(CurTime() + 45)
			end)
		end

	elseif ply:HaveSpecialAb(role.SCI_SpyUSA) then
		ply:SetSpecialCD(CurTime() + 7)
		if SERVER then
			if not ply.TempValues.SpyUSAINFO then
				ply:RXSENDNotify("l:spyusainfo") ply.TempValues.SpyUSAINFO = true
			end
			local all_documents = ents.FindByClass("item_special_document")
			for _, corpse in ipairs(ents.FindByClass("prop_ragdoll")) do
				if corpse.vtable and corpse.vtable.Weapons and table.HasValue(corpse.vtable.Weapons, "item_special_document") then
					table.insert(all_documents, corpse)
					corpse:SetNWBool("HasDocument", true)
				end
			end

			for _, doc in ipairs(all_documents) do
				local loc, loc_clr = "Местоположение неизвестно", color_white
				if doc:IsLZ() then loc, loc_clr = "Легкая зона", Color(0,153,230)
				elseif doc:Outside() then loc = "Поверхность"
				elseif doc:IsEntrance() then loc, loc_clr = "Офисная зона", Color(230,153,0)
				elseif doc:IsHardZone() then loc, loc_clr = "Тяжелая зона", Color(100,100,100) end

				local dist = math.Round(doc:GetPos():Distance(ply:GetPos()) / 52.49, 1)
				local dist_clr = dist < 16 and Color(255,0,0) or (dist < 60 and Color(230,153,0) or Color(0,255,0))

				ply:RXSENDNotify("l:uiuspy_doc_dist_pt1 = ", dist_clr, dist .. "m", color_white, ", l:uiuspy_doc_dist_pt2 ", loc_clr, loc)
			end
		end

	elseif ply:HaveSpecialAb(role.Chaos_Commander) then
		if ply:GetSpecialMax() == 0 then return end
		ply:SetSpecialCD(CurTime() + 4)
		local trace = util.TraceHull({
			start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 165,
			filter = ply, mins = Vector(-8, -2, -5), maxs = Vector(8, 2, 5)
		})
		local target = trace.Entity

		if IsValid(target) and target:IsPlayer() and target:Health() > 0 and (target:GetRoleName() == "CI Spy" or target:GTeam() == TEAM_CLASSD) then
			if target:GetModel():find("goose") then return end 
			if target:GetModel() == "models/cultist/humans/chaos/chaos.mdl" or target:GetModel() == "models/cultist/humans/chaos/fat/chaos_fat.mdl" then 
				ply:RXSENDNotify("l:cicommander_conscripted_already") return 
			end
			if target:GetUsingCloth() ~= "" or (target:GetRoleName() == role.ClassD_Hitman and not target:GetModel():find("class_d")) then
				ply:RXSENDNotify("l:cicommander_need_to_take_off_smth")
			end

			local count = 0
			for _, v in ipairs(target:GetWeapons()) do if not (v.UnDroppable or v.Equipableitem) then count = count + 1 end end
			if (count + 1) >= target:GetMaxSlots() then ply:RXSENDNotify("l:cicommander_no_slots") return end

			if SERVER then ply:BrProgressBar("l:giving_uniform", 8, "nextoren/gui/special_abilities/ability_placeholder.png") end
			local old_target = target

			timer.Create("Chaos_Special_Recruiting_Check" .. ply:SteamID64(), 1, 8, function()
				if not IsValid(ply) or ply:GetEyeTrace().Entity ~= old_target then
					timer.Remove("Chaos_Special_Recruiting" .. ply:SteamID64())
					ply:ConCommand("stopprogress")
					timer.Remove("Chaos_Special_Recruiting_Check" .. ply:SteamID64())
				end
			end)

			timer.Create("Chaos_Special_Recruiting" .. ply:SteamID64(), 8, 1, function()
				if IsValid(ply) and IsValid(target) then
					local cnt = 0
					for _, v in ipairs(target:GetWeapons()) do if not (v.UnDroppable or v.Equipableitem) then cnt = cnt + 1 end end
					if (cnt + 1) >= target:GetMaxSlots() then ply:RXSENDNotify("l:cicommander_no_slots") return end

					ply:SetSpecialMax(ply:GetSpecialMax() - 1)

					if SERVER then
						target:ClearBodyGroups()
						if target:GetRoleName() ~= role.ClassD_Fat then
							target:SetModel("models/cultist/humans/chaos/chaos.mdl") target:SetBodygroup(2, 1)
							target.ScaleDamage = { [HITGROUP_HEAD] = target.ScaleDamage[HITGROUP_HEAD], [HITGROUP_CHEST] = 0.7, [HITGROUP_LEFTARM] = 0.8, [HITGROUP_RIGHTARM] = 0.8, [HITGROUP_STOMACH] = 0.7, [HITGROUP_GEAR] = 0.7, [HITGROUP_LEFTLEG] = 0.8, [HITGROUP_RIGHTLEG] = 0.8 }
						else
							target:SetModel("models/cultist/humans/chaos/fat/chaos_fat.mdl")
							target.ScaleDamage = { [HITGROUP_HEAD] = 0.8, [HITGROUP_CHEST] = 0.8, [HITGROUP_LEFTARM] = 0.8, [HITGROUP_RIGHTARM] = 0.8, [HITGROUP_STOMACH] = 0.8, [HITGROUP_GEAR] = 0.8, [HITGROUP_LEFTLEG] = 0.8, [HITGROUP_RIGHTLEG] = 0.8 }
							target:SetArmor(target:Armor() + 30)
						end
						target:EmitSound("nextoren/others/cloth_pickup.wav")
						target:BreachGive("weapon_ak74") target:GiveAmmo(180, "ent_ammo_7.62x51mm", true)
						target:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1, 1) target:SetupHands()
					end
				end
			end)
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_MINE) then
		if ply:GetSpecialMax() <= 0 then return end
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply})
			ply:LagCompensation(false)
			if not tr.Hit then ply:RXSENDNotify("l:feelon_too_far") ply:SetSpecialCD(CurTime() + 5) return end
			if not IsGroundPos(tr.HitPos) then ply:RXSENDNotify("l:feelon_no_ground") ply:SetSpecialCD(CurTime() + 5) return end

			local mine = ents.Create("ent_special_trap")
			mine:SetPos(tr.HitPos) mine:SetOwner(ply) mine:Spawn()
			ply:SetSpecialMax(ply:GetSpecialMax() - 1) ply:SetSpecialCD(CurTime() + 40)
			ply:EmitSound("nextoren/vo/special_sci/trapper/trapper_" .. math.random(1, 10) .. ".mp3")
		end

	elseif ply:HaveSpecialAb(role.MTF_Engi) then
		if ply:GetSpecialMax() <= 0 then return end
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply})
			ply:LagCompensation(false)
			if not tr.HitWorld or not IsGroundPos(tr.HitPos) then ply:RXSENDNotify("l:engi_no_ground") ply:SetSpecialCD(CurTime() + 5) return end

			local mine = ents.Create("ent_engineer_turret")
			mine:SetPos(tr.HitPos) mine:SetOwner(ply) mine:Spawn()
			ply:SetSpecialMax(ply:GetSpecialMax() - 1)
		end

	elseif ply:HaveSpecialAb(role.ClassD_Hitman) then
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply})
			local target = tr.Entity
			ply:LagCompensation(false)

			local blockedTeams = {TEAM_GOC, TEAM_DZ, TEAM_COTSK, TEAM_SPECIAL, TEAM_SCP, TEAM_AR}
			local blockedRoles = {role.ClassD_Bor, role.ClassD_Fat, role.Dispatcher, role.MTF_HOF, role.MTF_Jag, role.MTF_O5, role.SCI_Head}
			local allowedRoles = {role.ClassD_GOCSpy, role.SCI_SpyDZ}

			if not IsValid(target) or not target.vtable or target:GetClass() ~= "prop_ragdoll" or target:GetModel():find("goc.mdl") or target.IsFemale then return end
			if table.HasValue(blockedTeams, target.__Team) and not table.HasValue(allowedRoles, target.Role) then return end
			if table.HasValue(blockedRoles, target.Role) or target:GetModel():find("corpse") then return end

			if ply:GetUsingArmor() ~= "" then ply:RXSENDNotify("l:hitman_take_off_helmet") return end
			if ply:GetUsingHelmet() ~= "" then ply:RXSENDNotify("l:hitman_take_off_vest") return end

			local function finish()
				if not IsValid(target) or not IsValid(ply) or not ply:Alive() or ply:Health() <= 0 or target:GetModel():find("corpse") then return end
				ply:SetSpecialCD(CurTime() + 15)

				local savemodel, saveskin, remembername = ply:GetModel(), ply:GetSkin(), ply:GetNamesurvivor()
				local bodygroups = {}
				for _, v in pairs(ply:GetBodyGroups()) do bodygroups[v.id] = ply:GetBodygroup(v.id) end
				local bnmrgs = ply:LookupBonemerges()

				ply:SetModel(target:GetModel())
				for _, v in pairs(target:GetBodyGroups()) do ply:SetBodygroup(v.id, target:GetBodygroup(v.id)) end
				ply:SetSkin(target:GetSkin())
				if ply:GetModel():find("class_d.mdl") then ply:SetSkin(0) end

				local corpse_face, havebalaclava, foundhead = "models/all_scp_models/shared/heads/head_1_1", false, false

				for _, v in ipairs(target:LookupBonemerges()) do
					local mdl = v:GetModel()
					if not mdl:find("hair") and not mdl:find("gasmask") then
						if mdl:find("male_head") or mdl:find("balaclava") then
							foundhead = true
							corpse_face = v:GetSubMaterial(CORRUPTED_HEADS[mdl] and 1 or 0)
						end
						if mdl:find("balaclava") then
							havebalaclava = true
							for _, v1 in ipairs(bnmrgs) do
								if v1:GetModel():find("male_head") then
									local remember = v:GetModel()
									if CORRUPTED_HEADS[v1:GetModel()] then v1:SetSubMaterial(0, v1:GetSubMaterial(1)) v1:SetSubMaterial(1, "") end
									ply.rememberface = v1:GetModel()
									v:SetModel("models/cultist/heads/male/male_head_1") v1:SetModel(remember)
								end
							end
						end
					end
				end

				if not foundhead then Bonemerge(PickHeadModel(), target) end

				for _, v in ipairs(target:LookupBonemerges()) do
					if not v:GetModel():find("hair") and not v:GetModel():find("male_head") and not v:GetModel():find("balaclava") then
						Bonemerge(v:GetModel(), ply, v:GetSkin()) v:Remove()
					end
				end

				for _, v in ipairs(bnmrgs) do
					local mdl = v:GetModel()
					if not mdl:find("hair") and not mdl:find("gasmask") then
						if mdl:find("balaclava") and not havebalaclava then
							for _, v1 in ipairs(target:LookupBonemerges()) do
								if v1:GetModel():find("male_head") then
									local remember = v:GetModel()
									v:SetModel(ply.rememberface or "models/cultist/heads/male/male_head_1") v1:SetModel(remember)
								end
							end
						end
						if not mdl:find("male_head") and not mdl:find("balaclava") then
							Bonemerge(mdl, target, v:GetSkin()) v:Remove()
						end
					end
				end

				for _, v in ipairs(target:LookupBonemerges()) do if v:GetModel() == "models/imperator/hands/skins/stanadart.mdl" then v:Remove() end end
				for _, v in ipairs(ply:LookupBonemerges()) do if v:GetModel() == "models/cultist/heads/gibs/gib_head.mdl" or v:GetModel() == "models/imperator/hands/skins/stanadart.mdl" then v:Remove() end end

				target:SetModel(savemodel)
				for i, v in pairs(bodygroups) do target:SetBodygroup(i, v) end
				target:SetSkin(saveskin)
				if target:GetModel():find("class_d.mdl") and corpse_face:find("black") then target:SetSkin(1) end

				for _, v in ipairs(ply:LookupBonemerges()) do v:SetInvisible(false) end

				ply:SetNamesurvivor(target.__Name) ply:SetRunSpeed(target.RunSpeed) target.__Name = remembername
				ply:RXSENDNotify("l:hitman_disguised") ply:SetupHands()
				ply:ScreenFade(SCREENFADE.IN, color_black, 1, 1)

				local hidePly = ply:GetModel():find("hazmat")
				for _, v in ipairs(ply:LookupBonemerges()) do v:SetInvisible(hidePly) end
				local hideTrg = target:GetModel():find("hazmat")
				for _, v in ipairs(target:LookupBonemerges()) do v:SetInvisible(hideTrg) end

				ply:EmitSound("nextoren/others/cloth_pickup.wav")
			end
			ply:BrProgressBar("l:changing_identity", 30, "nextoren/gui/new_icons/notifications/breachiconfortips.png", target, false, finish)
		end

	elseif ply:HaveSpecialAb(role.ClassD_Bor) and SERVER then
		ply:LagCompensation(true)
		local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply})
		local target = tr.Entity
		ply:LagCompensation(false)

		if not ply:IsOnGround() then ply:RXSENDNotify("l:strong_no_ground") ply:SetSpecialCD(CurTime() + 3) return end
		if not IsValid(target) or not target.GTeam or target:GTeam() == TEAM_SPEC or target:HasGodMode() then ply:RXSENDNotify("l:strong_look_on_them") ply:SetSpecialCD(CurTime() + 3) return end
		if not ply:IsSuperAdmin() and target:GTeam() == TEAM_SCP and not target.IsZombie then ply:RXSENDNotify("l:strong_look_on_them") ply:SetSpecialCD(CurTime() + 3) return end

		ply:Freeze(true) target:Freeze(true)
		local pos = ply:GetShootPos() + ply:GetAngles():Forward() * 44
		pos.z = ply:GetPos().z
		ply:SetMoveType(MOVETYPE_OBSERVER) target:SetMoveType(MOVETYPE_OBSERVER)
		ply:SetNWBool("IsNotForcedAnim", false) target:SetNWBool("IsNotForcedAnim", false)
		target:SetPos(pos) ply:SetSpecialCD(CurTime() + 65)

		local function startA()
			ply:Freeze(true) ply.ProgibTarget = target target.ProgibTarget = ply
			sound.Play("^nextoren/charactersounds/special_moves/bor/grab_start.wav", ply:GetPos(), 75, 100, 1)
			sound.Play("^nextoren/charactersounds/special_moves/bor/victim_struggle_6.wav", ply:GetPos(), 75, 100, 1)
			local vec_pos = target:GetShootPos() + (ply:GetShootPos() - target:EyePos()):Angle():Forward() * 1.5
			vec_pos.z = ply:GetPos().z
			target:SetPos(vec_pos)
			ply:SetNWAngle("ViewAngles", (target:GetShootPos() - ply:EyePos()):Angle())
			target:SetNWAngle("ViewAngles", (ply:GetShootPos() - target:EyePos()):Angle())
		end
		local function stopA()
			ply:SetNWEntity("NTF1Entity", NULL) ply:SetNWAngle("ViewAngles", angle_zero)
			ply:Freeze(false) ply.ProgibTarget = nil ply:SetNWBool("IsNotForcedAnim", true) ply:SetMoveType(MOVETYPE_WALK)
		end
		local function finishA()
			ply:SetNWEntity("NTF1Entity", NULL) ply:SetNWAngle("ViewAngles", angle_zero) target:SetNWAngle("ViewAngles", angle_zero)
			target:TakeDamage(1000000, ply, "КАЧОК СУКА ХУЯЧИТ")
			ply:Freeze(false) ply.ProgibTarget = nil ply:SetNWBool("IsNotForcedAnim", true) ply:SetMoveType(MOVETYPE_WALK)
			target:StopForcedAnimation()
			sound.Play("^nextoren/charactersounds/hurtsounds/fall/pldm_fallpain0" .. math.random(1, 2) .. ".wav", ply:GetShootPos(), 75, 100, 1)
		end
		local function startV() target:SetNWEntity("NTF1Entity", target) target:Freeze(true) target.ProgibTarget = ply ply.ProgibTarget = target end
		local function stopV() target:SetNWEntity("NTF1Entity", NULL) target:SetNWAngle("ViewAngles", angle_zero) target:Freeze(false) target.ProgibTarget = nil target:SetNWBool("IsNotForcedAnim", true) target:SetMoveType(MOVETYPE_WALK) end
		local function finishV() target:SetNWEntity("NTF1Entity", NULL) target:SetNWAngle("ViewAngles", angle_zero) target:Freeze(false) target.ProgibTarget = nil target:SetNWBool("IsNotForcedAnim", true) target:SetMoveType(MOVETYPE_WALK) end

		ply:SetForcedAnimation(ply:LookupSequence("1_bor_progib_attacker"), 5.5, startA, finishA, stopA)
		target:SetForcedAnimation(target:LookupSequence("1_bor_progib_resiver"), 5.5, startV, finishV, stopV)
		target:StopGestureSlot(GESTURE_SLOT_CUSTOM)

	elseif ply:HaveSpecialAb(role.Goc_Commander) then
		ply:SetSpecialCD(CurTime() + 80)
		if SERVER then
			local ef = EffectData() ef:SetEntity(ply) util.Effect("gocabilityeffect", ef)
			BREACH.SendClientEvent(nil, "effect_entity", {effect = "gocabilityeffect", entity = ply})
			ply:BrProgressBar("l:becoming_invisible", 0.8, "nextoren/gui/new_icons/notifications/breachiconfortips.png")
			timer.Simple(0.8, function()
				if IsValid(ply) and ply:HaveSpecialAb(role.Goc_Commander) then
					ply:ScreenFade(SCREENFADE.IN, gteams.GetColor(TEAM_GOC), 0.5, 0)
					ply:RXSENDNotify("l:became_invisible") ply:SetNoDraw(true) ply.CommanderAbilityActive = true
					for _, wep in ipairs(ply:GetWeapons()) do wep:SetNoDraw(true) end
					timer.Create("Goc_Commander_" .. ply:SteamID64(), 20, 1, function()
						if IsValid(ply) and ply.CommanderAbilityActive then
							ply:SetNoDraw(false) ply.CommanderAbilityActive = nil
							for _, wep in ipairs(ply:GetWeapons()) do wep:SetNoDraw(false) end
						end
					end)
				end
			end)
		else
			local hands = ply:GetHands()
			local ef = EffectData() ef:SetEntity(hands) util.Effect("gocabilityeffect", ef)
		end

	elseif ply:HaveSpecialAb(role.Chaos_Demo) then
		if SERVER then
			if ply:GetSpecialMax() <= 0 then return end
			ply:SetSpecialCD(CurTime() + 80)
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply})
			ply:LagCompensation(false)
			if not tr.Hit or not IsGroundPos(tr.HitPos) then ply:RXSENDNotify("Похоже, вы слишком далеко от точки на которой хотите поставить мину") return end

			ply:SetSpecialMax(0)
			local ang = ply:EyeAngles() ang.pitch = 0 ang.roll = 0
			local claymore = ents.Create("ent_chaos_mine")
			claymore:SetPos(tr.HitPos) claymore:SetAngles(ang - Angle(0, 90, 0)) claymore:SetOwner(ply) claymore:Spawn()
		end

	elseif ply:HaveSpecialAb(role.SCI_Recruiter) then
		if ply:GetSpecialMax() == 0 then return end
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 130, filter = ply})
			local target = tr.Entity
			ply:LagCompensation(false)
			
			if not IsValid(target) or not target:IsPlayer() or target:GTeam() == TEAM_SPEC or target:GetModel():find("goose") then
				ply:RXSENDNotify("l:commitee_look_on_them") ply:SetSpecialCD(CurTime() + 2) return
			end
			if (target:GTeam() ~= TEAM_CLASSD and target:GetRoleName() ~= role.ClassD_GOCSpy) or target:GetRoleName() == role.ClassD_Banned or target:GetUsingCloth() ~= "" or target:GetModel():find('goc') then
				ply:RXSENDNotify("l:commitee_cant_conscript") ply:SetSpecialCD(CurTime() + 2) return
			end
			if target:GetPrimaryWeaponAmount() >= target:GetMaxSlots() then ply:RXSENDNotify("l:commitee_no_slots") ply:SetSpecialCD(CurTime() + 2) return end
			if IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() ~= "br_holster" then ply:RXSENDNotify("l:commitee_active_weapon") return end

			ply:BrProgressBar("l:giving_equipment", 8, "nextoren/gui/special_abilities/ability_recruiter.png", target, false, function()
				if not IsValid(target) or not target:IsPlayer() or target:GTeam() == TEAM_SPEC then ply:RXSENDNotify("l:commitee_look_on_them") return end
				if (target:GTeam() ~= TEAM_CLASSD and target:GetRoleName() ~= role.ClassD_GOCSpy) or target:GetUsingCloth() ~= "" or target:GetModel():find('goc') then ply:RXSENDNotify("l:commitee_cant_conscript") return end
				if target:GetPrimaryWeaponAmount() >= target:GetMaxSlots() then ply:RXSENDNotify("l:commitee_no_slots") return end
				if IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() ~= "br_holster" then ply:RXSENDNotify("l:commitee_active_weapon") return end

				ply:SetSpecialMax(ply:GetSpecialMax() - 1)
				if target:GTeam() ~= TEAM_GOC then target:SetGTeam(TEAM_SCI) else
					target:SetUsingCloth("armor_sci") target.OldModel = target:GetModel() target.OldSkin = target:GetSkin() target.OldBodygroups = target:GetBodyGroupsString()
				end

				if target.BoneMergedHackerHat then for _, v in ipairs(target.BoneMergedHackerHat) do if IsValid(v) then v:Remove() end end end

				if target:GetRoleName() ~= role.ClassD_Fat and target:GetRoleName() ~= role.ClassD_Bor then
					target:SetModel(target:GetModel():find("female") and "models/cultist/humans/sci/scientist_female.mdl" or (target:GetModel() == "models/cultist/humans/class_d/shaky/class_d_fat_new.mdl" and "models/cultist/humans/sci/class_d_fat.mdl" or "models/cultist/humans/sci/scientist.mdl"))
					target:ClearBodyGroups() target:SetBodygroup(0, 2) target:SetBodygroup(2, 1) target:SetBodygroup(4, 1)
				else
					target:SetModel(target:GetRoleName() == role.ClassD_Fat and "models/cultist/humans/sci/class_d_fat.mdl" or "models/cultist/humans/sci/class_d_bor.mdl")
					if target:GetRoleName() ~= role.ClassD_Fat then target:SetBodygroup(0, 0) end
				end
				target.AbilityTAB = nil target:SetNWString("AbilityName", "")
				target:StripWeapon("item_knife") target:StripWeapon("hacking_doors") target:BreachGive("weapon_pass_sci")
				target:EmitSound("nextoren/others/cloth_pickup.wav") target:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1, 1)
				target:SetupHands() ply:AddToAchievementPoint("comitee", 1)
			end)
		end

	elseif ply:HaveSpecialAb(role.Goc_Jag) then
		ply:SetSpecialCD(CurTime() + 75)
		if SERVER then ents.Create("ent_goc_shield"):SetOwner(ply):Spawn() end

	elseif ply:HaveSpecialAb(role.UIU_Specialist) then
		local trace = util.TraceHull({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 165, filter = ply, mins = Vector(-8, -10, -5), maxs = Vector(8, 10, 5)})
		local target = trace.Entity
		if IsValid(target) and target:GetClass() == "func_button" and not target:IsPlayer() and ply:Alive() and ply:GTeam() == TEAM_USA and ply:Health() > 0 then
			local old_target_uiu = target
			if SERVER then ply:BrProgressBar("l:blocking_door", 5, "nextoren/gui/special_abilities/special_fbi_hacker.png") end
			timer.Create("Blocking_UIU_Check" .. ply:SteamID64(), 1, 5, function()
				if not IsValid(ply) or ply:GetEyeTrace().Entity ~= old_target_uiu or not ply:Alive() or ply:GTeam() ~= TEAM_USA or ply:Health() <= 0 then
					timer.Remove("Blocking_UIU" .. ply:SteamID64()) timer.Remove("Blocking_UIU_Check" .. ply:SteamID64()) ply:ConCommand("stopprogress")
				end
			end)
			timer.Create("Blocking_UIU" .. ply:SteamID64(), 5, 1, function()
				ply:SetSpecialCD(CurTime() + 30) target:Fire("Lock")
				timer.Simple(30, function() if IsValid(target) then target:Fire("Unlock") end end)
			end)
		end

	elseif ply:HaveSpecialAb(role.DZ_Commander) then
		ply:SetSpecialCD(CurTime() + 90)
		local forward_portal = ply:GetForward() forward_portal.z = 0
		local siusiakko12 = ply:EyeAngles() siusiakko12.pitch = 0 siusiakko12.roll = 0
		if SERVER then
			local por = ents.Create("dz_commander_portal")
			por:SetOwner(ply) por:SetPos(ply:GetPos() + forward_portal * 150 + Vector(0, 0, 20)) por:SetAngles(siusiakko12) por:Spawn()
		end

	elseif ply:HaveSpecialAb(role.SECURITY_Spy) then
		ply:SetSpecialCD(CurTime() + 20)
		if SERVER then net.Start("Chaos_SpyAbility", true) net.Send(ply) end

	elseif ply:HaveSpecialAb(role.Cult_Specialist) then
		ply:SetSpecialCD(CurTime() + 50)
		if SERVER then net.Start("Cult_SpecialistAbility", true) net.Send(ply) end

	elseif ply:HaveSpecialAb(role.UIU_Agent_Commander) then
		ply:SetSpecialCD(CurTime() + 45)
		if SERVER then net.Start("fbi_commanderabillity", true) net.Send(ply) end

	elseif ply:HaveSpecialAb(role.NTF_Commander) then
		ply:SetSpecialCD(CurTime() + 2)
		if CLIENT then Choose_Faction() end

	elseif ply:HaveSpecialAb(role.ALPHA1_Specialist) then
		ply:SetSpecialCD(CurTime() + 90)
		if SERVER then
			ply:SetNWBool("can_sea_gaus", true)
			timer.Simple(5, function() if IsValid(ply) then ply:SetNWBool("can_sea_gaus", false) end end)
		end

	elseif ply:HaveSpecialAb(role.UIU_Agent) then
		ply:SetSpecialCD(CurTime() + 90)
		if SERVER then
			for _, v in player.Iterator() do
				if v:GTeam() == TEAM_USA then
					v:SetNWBool("ALPHACanSea", true)
					for _, o5 in ipairs(ents.GetAll()) do
						if (o5:IsPlayer() and o5:GetRoleName() == role.MTF_O5) or o5.Role == role.MTF_O5 then
							BREACH.SendClientEvent(nil, "set_vector", {name = "O5_VECTOR", value = o5:GetPos()})
						end
					end
					timer.Simple(5, function() if IsValid(v) then v:SetNWBool("ALPHACanSea", false) end end)
				end
			end
		end

	elseif ply:HaveSpecialAb(role.UIU_Clocker) then
		if SERVER then
			ply:SetSpecialCD(CurTime() + 40)
			ply:ScreenFade(SCREENFADE.IN, Color(255,0,0,100), 1, 0.3)
			local saveresist = table.Copy(ply.ScaleDamage)
			local savespeed = ply:GetRunSpeed()
			ply.Stamina = 200 ply:SetStamina(200) ply:SetArmor(255) ply:SetRunSpeed(ply:GetRunSpeed() + 65)

			if ply:GetActiveWeapon() == ply:GetWeapon("weapon_fbi_knife") then
				ply.SafeRun = ply:LookupSequence("phalanx_b_run")
				net.Start("ChangeRunAnimation", true) net.WriteEntity(ply) net.WriteString("phalanx_b_run") net.Broadcast()
			end

			timer.Simple(15, function()
				if IsValid(ply) and ply:Health() > 0 and ply:Alive() and ply:HaveSpecialAb(role.UIU_Clocker) then
					ply.ScaleDamage = saveresist ply:SetRunSpeed(savespeed) ply:SetArmor(0)
					if ply:GetActiveWeapon() == ply:GetWeapon("weapon_fbi_knife") then
						ply.SafeRun = ply:LookupSequence("AHL_r_RunAim_KNIFE")
						net.Start("ChangeRunAnimation", true) net.WriteEntity(ply) net.WriteString("AHL_r_RunAim_KNIFE") net.Broadcast()
					end
				end
			end)
		end

	elseif ply:HaveSpecialAb(role.NTF_Specialist) then
		local trace = util.TraceHull({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 165, filter = ply, mins = Vector(-8, -10, -5), maxs = Vector(8, 10, 5)})
		local target = trace.Entity
		if IsValid(target) and target:IsPlayer() and target:GTeam() == TEAM_SCP and target:Health() > 0 and target:Alive() then
			ply:SetSpecialCD(CurTime() + 90) target:Freeze(true)
			local old_name, old_role = target:GetNamesurvivor(), target:GetRoleName()
			if SERVER then
				if target:GetModel() == "models/cultist/scp/scp_682.mdl" then target:SetForcedAnimation("0_Stun_29", false, false, 6)
				else target:SetForcedAnimation("0_SCP_542_lifedrain", false, false, 6) end
			end
			timer.Create("UnFreezeNTF_Specialist" .. target:SteamID64(), 6, 1, function()
				if IsValid(target) and target:GetNamesurvivor() == old_name and target:GetRoleName() == old_role and target:GTeam() == TEAM_SCP then target:Freeze(false) end
			end)
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_SHIELD) then
		ply:SetSpecialCD(CurTime() + 300)
		if SERVER then
			ply:EmitSound("nextoren/vo/special_sci/shield/shield_" .. math.random(1, 9) .. ".mp3")
			ents.Create("special_sphere"):SetOwner(ply):SetPos(ply:GetPos()):Spawn()
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_VISION) then
		ply:SetSpecialCD(CurTime() + 60)
		if SERVER then
			for _, v in player.Iterator() do
				if v:GTeam() == TEAM_SCP then
					v:SetNWBool("SCPCanSea", true)
					timer.Simple(5, function() if IsValid(v) then v:SetNWBool("SCPCanSea", false) end end)
				end
			end
		end

	elseif ply:HaveSpecialAb(role.ALPHA1_Commander) then
		ply:SetSpecialCD(CurTime() + 90)
		if SERVER then
			for _, v in player.Iterator() do
				if v:GTeam() == TEAM_ALPHA1 then
					v:SetNWBool("ALPHACanSea", true)
					for _, o5 in ipairs(ents.GetAll()) do
						if (o5:IsPlayer() and o5:GetRoleName() == role.MTF_O5) or o5.Role == role.MTF_O5 then
							BREACH.SendClientEvent(nil, "set_vector", {name = "O5_VECTOR", value = o5:GetPos()})
						end
					end
					timer.Simple(5, function() if IsValid(v) then v:SetNWBool("ALPHACanSea", false) end end)
				end
			end
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_SPEED) then
		ply:SetSpecialCD(CurTime() + 57)
		if SERVER then
			ply:EmitSound("nextoren/vo/special_sci/speed_booster/speed_booster_" .. math.random(1, 12) .. ".mp3")
			for _, tply in ipairs(ents.FindInSphere(ply:GetPos(), 450)) do
				if IsValid(tply) and tply:IsPlayer() and tply:GTeam() ~= TEAM_SPEC and tply:GTeam() ~= TEAM_SCP then
					tply:SetRunSpeed(tply:GetRunSpeed() + 40) tply.Shaky_SPEEDName = tply:GetNamesurvivor()
					timer.Simple(25, function() if IsValid(tply) and tply:GetNamesurvivor() == tply.Shaky_SPEEDName then tply:SetRunSpeed(tply:GetRunSpeed() - 40) end end)
				end
			end
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_INVISIBLE) then
		ply:SetSpecialCD(CurTime() + 201)
		if SERVER then
			local ef = EffectData() ef:SetEntity(ply) util.Effect("gocabilityeffect", ef)
			BREACH.SendClientEvent(nil, "effect_entity", {effect = "gocabilityeffect", entity = ply})
			timer.Simple(0.8, function()
				if IsValid(ply) then
					ply:SetNoDraw(true) for _, v in ipairs(ply:LookupBonemerges()) do v:SetNoDraw(true) end
					ply.CommanderAbilityActive = true
					for _, wep in ipairs(ply:GetWeapons()) do wep:SetNoDraw(true) end
					timer.Create("Special_invis_Commander_" .. ply:SteamID64(), 20, 1, function()
						if IsValid(ply) and ply.CommanderAbilityActive then
							for _, v in ipairs(ply:LookupBonemerges()) do v:SetNoDraw(false) end
							ply:SetNoDraw(false) ply.CommanderAbilityActive = nil
							for _, wep in ipairs(ply:GetWeapons()) do wep:SetNoDraw(false) end
						end
					end)
				end
			end)
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_HEALER) then
		ply:SetSpecialCD(CurTime() + 45)
		if SERVER then
			ply:EmitSound("nextoren/vo/special_sci/medic/medic_" .. math.random(1, 11) .. ".mp3")
			for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 250)) do
				if target:IsPlayer() then target:SetHealth(math.Clamp(target:Health() + 40, 0, target:GetMaxHealth())) end	
			end
		end

	elseif ply:HaveSpecialAb(role.Cult_Psycho) then
		ply:SetSpecialCD(CurTime() + 205)
		if SERVER then
			ply:SetHealth(ply:GetMaxHealth())
			ply.ScaleDamage = { [HITGROUP_HEAD] = .1, [HITGROUP_CHEST] = .1, [HITGROUP_LEFTARM] = .1, [HITGROUP_RIGHTARM] = .1, [HITGROUP_STOMACH] = .1, [HITGROUP_GEAR] = .1, [HITGROUP_LEFTLEG] = .1, [HITGROUP_RIGHTLEG] = .1 }
			ply:Boosted(2, 30) ply:SetArmor(255) ply.DamageModifier = 0.4
			local old_name_psycho = ply:GetNamesurvivor()
			timer.Simple(30, function()
				if IsValid(ply) and ply:GetNamesurvivor() == old_name_psycho and ply:Health() > 0 and ply:Alive() and ply:GTeam() ~= TEAM_SPEC then
					ply:AddToStatistics("l:psycho_bravery_bonus", 50) ply:Kill()
				end
			end)
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_SLOWER) then
		ply:SetSpecialCD(CurTime() + 85)
		if SERVER then
			ply:EmitSound("nextoren/vo/special_sci/scp_slower/scp_slower_" .. math.random(1, 14) .. ".mp3")
			for _, tply in ipairs(ents.FindInSphere(ply:GetPos(), 450)) do
				if IsValid(tply) and tply:IsPlayer() and tply:GTeam() == TEAM_SCP then
					tply:SetNWInt("Speed_Multiply", 0.45)
					timer.Create("ply_slower_special_" .. tply:SteamID64(), 15, 1, function()
						if IsValid(tply) then tply:SetNWInt("Speed_Multiply", 1) end
					end)
				end
			end
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_DAMAGE) then
		ply:SetSpecialCD(CurTime() + 65)
		if SERVER then
			ply:EmitSound("nextoren/vo/special_sci/buffer_damage/buffer_" .. math.random(1, 14) .. ".mp3")
			for _, tply in ipairs(ents.FindInSphere(ply:GetPos(), 450)) do
				if IsValid(tply) and tply:IsPlayer() and tply:GTeam() ~= TEAM_SPEC and tply:GTeam() ~= TEAM_SCP then
					tply.SCI_SPECIAL_DAMAGE_Active = true
					timer.Simple(25, function() if IsValid(tply) then tply.SCI_SPECIAL_DAMAGE_Active = nil end end)
				end
			end
		end

	elseif ply:HaveSpecialAb(role.ClassD_Fast) then
		ply:SetSpecialCD(CurTime() + 1)
		if SERVER then
			if ply:GetRunSpeed() == 231 or ply:GetRunSpeed() == 288 then
				local isFast = ply:GetRunSpeed() == 231
				ply:SetRunSpeed(isFast and 288 or 231)
				ply:RXSENDNotify(isFast and "l:sport_run" or "l:default_run")
				if ply:GetActiveWeapon() == ply:GetWeapon("br_holster") then
					ply.SafeRun = ply:LookupSequence("phalanx_b_run")
					net.Start("ChangeRunAnimation", true) net.WriteEntity(ply) net.WriteString(isFast and "run_all_02" or "run_all_01") net.Broadcast()
				end
			else
				ply:RXSENDNotify("l:cant_change_run")
			end
		end

	elseif ply:HaveSpecialAb(role.SCI_SPECIAL_BOOSTER) then
		ply:SetSpecialCD(CurTime() + 100)
		for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 450)) do
			if IsValid(v) and v:IsPlayer() and v:GTeam() ~= TEAM_SCP and v:GTeam() ~= TEAM_SPEC then
				v:Boosted(2, math.random(17, 20))
			end
		end

	elseif ply:HaveSpecialAb(role.GRU_Commander) then
		if SERVER then
			local trace = util.TraceHull({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 165, filter = ply, mins = Vector(-8, -10, -5), maxs = Vector(8, 10, 5)})
			local target = trace.Entity
			if IsValid(target) and target:GTeam() == TEAM_GRU then return end
			ply:BrProgressBar("l:progress_wait", 7, "nextoren/gui/special_abilities/special_gru_commander.png", target, false, function()
				if IsValid(ply) then ply:SetSpecialCD(CurTime() + 120) SetGlobalInt("TASKS_GRU_3", GetGlobalInt("TASKS_GRU_3") + 1) end
			end)
		end

	elseif ply:HaveSpecialAb(role.CBG_Com) then	
		ply:SetSpecialCD(CurTime() + 60)
		if CLIENT then 
			local hands = ply:GetHands()
			local ef = EffectData() ef:SetEntity(hands) util.Effect("gocabilityeffect", ef) return
		end
		if SERVER then
			ply:SetForcedAnimation("MPF_Deploy", false, function()
				ply:SetNWEntity("NTF1Entity", ply)
				ply:EmitSound("nextoren/scp/035/whispers1.mp3", 135, math.random(60, 150), 5)
				ply:BrProgressBar("l:becoming_invisible", 2, "nextoren/gui/new_icons/notifications/breachiconfortips.png")
				local ef = EffectData() ef:SetEntity(ply) util.Effect("gocabilityeffect", ef)
				BREACH.SendClientEvent(nil, "effect_entity", {effect = "gocabilityeffect", entity = ply})
			end, function()
				if not IsValid(ply) then return end
				ply:SetNWEntity("NTF1Entity", NULL) ply:StopParticles() ply:SetNoDraw(true)
				ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER) ply:ScreenFade(SCREENFADE.IN, gteams.GetColor(TEAM_CBG), 0.5, 0)
				ply.CBG_Shadow_Enabled = true

				local ragdoll = ents.Create("prop_ragdoll")
				ragdoll:SetModel(ply:GetModel()) ragdoll:SetSkin(ply:GetSkin()) ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
				for i = 0, 9 do ragdoll:SetBodygroup(i, ply:GetBodygroup(i)) end
				ragdoll:SetPos(ply:GetPos()) ragdoll:Spawn() ragdoll:SetColor(Color(0, 0, 0, 150))

				if IsValid(ragdoll) then
					ragdoll:SetPos(ply:GetPos()) ragdoll:SetAngles(ply:GetAngles())
					local ef = EffectData() ef:SetEntity(ragdoll) util.Effect("gocabilityeffect", ef)
					BREACH.SendClientEvent(nil, "effect_entity", {effect = "gocabilityeffect", entity = ragdoll})
					for i = 1, 67 do ragdoll:ManipulateBoneScale(i, Vector(math.random(0.5, 1.7), math.random(0.5, 1.7), math.random(0.5, 1.7))) end
					for i = 1, ragdoll:GetPhysicsObjectCount() do
						local physicsObject = ragdoll:GetPhysicsObjectNum(i)
						if IsValid(physicsObject) then
							local pos, ang = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
							physicsObject:SetPos(pos) physicsObject:SetMass(65) physicsObject:SetAngles(ang) physicsObject:EnableMotion(false) physicsObject:Wake()
						end
					end
				end

				timer.Create("CBG_Shadow_" .. ply:SteamID64(), 1, 14, function()
					if IsValid(ragdoll) then
						ragdoll:SetPos(ply:GetPos()) ragdoll:SetAngles(ply:GetAngles())
						local ef = EffectData() ef:SetEntity(ragdoll) util.Effect("gocabilityeffect", ef)
						BREACH.SendClientEvent(nil, "effect_entity", {effect = "gocabilityeffect", entity = ragdoll})
						for i = 1, 67 do ragdoll:ManipulateBoneScale(i, Vector(math.random(0.5, 1.7), math.random(0.5, 1.7), math.random(0.5, 1.7))) end
						for i = 1, ragdoll:GetPhysicsObjectCount() do
							local physicsObject = ragdoll:GetPhysicsObjectNum(i)
							if IsValid(physicsObject) then
								local pos, ang = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
								physicsObject:SetPos(pos) physicsObject:SetMass(65) physicsObject:SetAngles(ang) physicsObject:EnableMotion(false) physicsObject:Wake()
							end
						end
					end
				end)
				timer.Create("CBG_Shadow_Delete_" .. ply:SteamID64(), 15, 1, function()
					if IsValid(ragdoll) then ragdoll:Remove() end
					if IsValid(ply) then ply:SetNoDraw(false) ply.CBG_Shadow_Enabled = false ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) end
				end)
			end, nil)
		end

	elseif ply:HaveSpecialAb(role.CBG_Sold) then
		ply:SetSpecialCD(CurTime() + 70)
		ply:SetColor(color_black) ParticleEffectAttach("mr_portal_1a_ff", PATTACH_POINT_FOLLOW, ply, ply:LookupAttachment("waist"))
		ply.CBG_ReturnDamage = true
		timer.Create("CBG_ReturnDamage_" .. ply:SteamID64(), 15, 1, function()
			if IsValid(ply) then ply:SetColor(color_white) ply:StopParticles() ply.CBG_ReturnDamage = false end
		end)

	elseif ply:HaveSpecialAb(role.CBG) then
		ply:SetSpecialCD(CurTime() + 2)
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 1100, filter = ply})
			local target = tr.Entity
			ply:LagCompensation(false)
			if IsValid(target) and target:IsPlayer() then
				local hand_pos = target:GetPos() + Vector(0,0,40)
				local angles = target:GetAngles()
				timer.Simple(0.1, function()
					if not IsValid(target) then return end
					ParticleEffectAttach("slave_finish", PATTACH_ABSORIGIN_FOLLOW, target, 8)
					ParticleEffect("infect2", hand_pos, angles, target)
					timer.Simple(0.5, function()
						if IsValid(target) then target:Kill() target:EmitSound("nextoren/scp/542/scp_542_finish.ogg", 120, math.random(80, 100), 1, CHAN_BODY) end
					end)
				end)
			else
				for _, v in ipairs(ents.FindInSphere(tr.HitPos, 60)) do
					if v:GetClass() == "func_door" then v:EmitSound("nextoren/scp/096/metal_break3.wav") v:Fire("Unlock") v:Fire("Open") end
				end
			end
		end

	elseif ply:HaveSpecialAb(role.CBG_Spec) then
		ply:SetSpecialCD(CurTime() + 60)
		if SERVER then
			ply:LagCompensation(true)
			local tr = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 1100, filter = ply})
			local target = tr.Entity
			ply:LagCompensation(false)
			
			if not ply:IsOnGround() then ply:RXSENDNotify("l:strong_no_ground") ply:SetSpecialCD(CurTime() + 3) return end
			if not IsValid(target) or not target.GTeam or target:GTeam() == TEAM_SPEC or target:HasGodMode() or target:GTeam() == TEAM_CBG then
				ply:RXSENDNotify("l:strong_look_on_them") ply:SetSpecialCD(CurTime() + 3) return
			end

			if target:GTeam() == TEAM_SCP then ply:SetSpecialCD(CurTime() + 3) else
				ply:SetForcedAnimation("0_SCP_542_lifedrain", false, function()
					ply:Freeze(true) ply:GodEnable() ply:SetNWEntity("NTF1Entity", ply) ply:SetNWAngle("ViewAngles", ply:EyeAngles())
					target:GodEnable()
				end, function()
					if not IsValid(ply) or not IsValid(target) then return end
					ply:Freeze(false) ply:GodDisable() ply:SetNWEntity("NTF1Entity", NULL) ply:SetNWAngle("ViewAngles", angle_zero)
					
					ply:SetupNormal() ply:SetModel(target:GetModel()) ply:SetSkin(target:GetSkin()) ply:SetUsingCloth(target:GetUsingCloth())
					ply:SetNamesurvivor(target:GetNamesurvivor()) ply.OldSkin = target.OldSkin ply.OldModel = target.OldModel ply.OldBodygroups = target.OldBodygroups
					ply:SetWalkSpeed(target:GetWalkSpeed()) ply:SetRunSpeed(target:GetRunSpeed()) ply:SetupHands()
					ply:SetPos(Vector(target:GetPos().x, target:GetPos().y, GroundPos(target:GetPos()).z))

					for _, bnmrg in ipairs(target:LookupBonemerges()) do
						local bnmrg_ent = Bonemerge(bnmrg:GetModel(), ply)
						bnmrg_ent:SetSubMaterial(0, bnmrg:GetSubMaterial(0)) bnmrg_ent:SetSubMaterial(2, bnmrg:GetSubMaterial(2))
					end

					local abilityTable = BREACH_ROLES.CBG.cbg.roles[3].ability
					ply:SetNWString("AbilityName", abilityTable[1])
					net.Start("SpecialSCIHUD") net.WriteString(abilityTable[1]) net.WriteUInt(abilityTable[2], 9) net.WriteString(abilityTable[3]) net.WriteString(abilityTable[4]) net.WriteBool(abilityTable[5]) net.Send(ply)

					ply:SetSpecialCD(CurTime() + 60)
					if istable(target:GetAmmo()) then for ammo, amount in pairs(target:GetAmmo()) do ply:SetAmmo(amount, ammo) end end
					for _, v in ipairs(target:GetWeapons()) do ply:BreachGive(v:GetClass()) end
					ply:BreachGive("br_holster") ply:BreachGive("breach_keycard_support")
					for i = 0, 9 do ply:SetBodygroup(i, target:GetBodygroup(i)) end

					target:Freeze(false) target:LevelBar() target:SetupNormal() target:SetSpectator()
					target:SetNWEntity("NTF1Entity", NULL) target:SetNWAngle("ViewAngles", angle_zero) target:GodDisable()
				end)
			end
		end

	elseif ply:HaveSpecialAb(role.AR_Matilda) then
		ply:SetSpecialCD(CurTime() + 70)
		if SERVER then
			ply:EmitSound("nextoren/ar_matilda.mp3")
			ply.AR_Matilda = ents.Create("special_sphere")
			ply.AR_Matilda:SetOwner(ply) ply.AR_Matilda:Spawn() ply.AR_Matilda:SetPos(ply:GetPos())

			ply.AR_Matilda.Think = function(self)
				local ct = CurTime()
				if ((self.DeathTime or 0) - ct < 0) and SERVER then self:Remove() return end
				local owner = self:GetOwner()
				if not (IsValid(owner) and owner:HaveSpecialAb(role.AR_Matilda) and owner:Health() > 0 and owner:Alive()) then self:Remove() return end
				self:SetPos(owner:GetPos()) self:NextThink(ct)

				for _, target in ipairs(ents.FindInSphere(owner:GetPos(), 80)) do
					if target:IsPlayer() and target:GTeam() == TEAM_AR then
						target:SetHealth(math.Clamp(target:Health() + 2, 0, target:GetMaxHealth()))
					end
				end
				return true
			end
		end
	end
end)

local stance_exit_mins, stance_exit_maxs = Vector(-16, -16, 16), Vector(16, 16, 72)

function Stance_CanExit(ply)
	local tr = util.TraceHull({start = ply:GetPos(), endpos = ply:GetPos(), filter = ply, mins = stance_exit_mins, maxs = stance_exit_maxs})
	return not tr.Hit
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
	if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) else dmginfo:ScaleDamage(0.50) end
end

hook.Add("ScalePlayerDamage", "Damage_PEnalty", function(ply, hitgroup, dmginfo)
	ply.DamageMovePenalty = ply.DamageMovePenalty or ply:GetRunSpeed()
	if dmginfo:IsBulletDamage() then ply.DamageMovePenalty = 50 end
end)

hook.Add("SetupMove", "StanceSpeed", function(ply, mv, cmd)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.CW20Weapon and wep.dt.State == CW_AIMING then
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.5)
		mv:SetMaxSpeed(mv:GetMaxSpeed() * 0.5)
	end
end)

hook.Add("StartCommand", "DisableCrouchJump", function(ply, cmd)
	if not ply:Alive() or ply:GTeam() == TEAM_SPEC then return end
end)

local inventory_button = CreateConVar("breach_config_openinventory", KEY_Q, FCVAR_ARCHIVE, "number you will open inventory with")

function GM:PlayerButtonDown(ply, button)
	if CLIENT and IsFirstTimePredicted() then
		if LocalPlayer().cantopeninventory then 
			if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame:Remove() end
			return 
		end

		if button == inventory_button:GetInt() then
			if CanShowEQ() and not IsValid(Breach.InventoryMainFrame) then
				gui.EnableScreenClicker(true)
				ReadInventoryData()
				RestoreCursorPosition()
			elseif IsValid(Breach.InventoryMainFrame) then
				RememberCursorPosition()
				NewLegacyInventoryClose()
			end
		end
	end
end

function GM:KeyPress(ply, key)
	if ply:GTeam() == TEAM_SPEC and ply:Crouching() then ply:SetCrouching(false) end
end

function GM:PlayerButtonUp(ply, button)
	if CLIENT and IsFirstTimePredicted() then
		if input.GetKeyCode(inventory_button:GetInt()) == button and IsEQVisible() then
			HideEQ()
		end
	end
end

local hazed_special = {
	["models/cultist/humans/scp_special_scp/special_5.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_6.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_8.mdl"] = true
}

function mply:HasHazmat()
	local mdl = string.lower(self:GetModel() or "")
	if string.find(mdl, "hazmat") or mdl == "models/imperator/humans/ar/ar.mdl" or mdl == "models/scp079microcom/scp079microcom.mdl" or self:GetRoleName() == role.DZ_Gas or self:GetRoleName() == role.ClassD_FartInhaler or hazed_special[mdl] or self:GTeam() == TEAM_CBG then
		return true
	end
	for _, v in ipairs(self:LookupBonemerges()) do
		if v:GetModel() == "models/cultist/humans/balaclavas_new/mog_hazmat.mdl" then return true end
	end
	return false
end

function mply:Dado(kind)
	local sid = self:SteamID64()
	if kind == 1 then
		local unique_id = "Radiation" .. sid
		local old_name = self:GetNamesurvivor()
		self.TempValues.radiation = true

		timer.Create(unique_id, .25, 0, function()
			if not IsValid(self) or self:GetNamesurvivor() ~= old_name or self:GTeam() == TEAM_SPEC or self:Health() <= 0 then
				timer.Remove(unique_id) return
			end

			self.NextParticle = self.NextParticle or 0
			if self.NextParticle < CurTime() then
				self.NextParticle = CurTime() + 3
				ParticleEffect("rgun1_impact_pap_child", self:GetPos(), angle_zero, self)
			end

			local myPos = self:GetPos()
			for _, v in ipairs(ents.FindInSphere(myPos, 400)) do
				if v:IsPlayer() and v:GTeam() ~= TEAM_SPEC and v:Health() > 0 then
					if v:HasHazmat() and v ~= self then continue end

					local radiation_info = DamageInfo()
					radiation_info:SetDamageType(DMG_RADIATION)
					radiation_info:SetDamage(2)
					radiation_info:SetAttacker(self)
					radiation_info:SetDamageForce(v:GetAimVector() * 4)

					if v == self then
						radiation_info:ScaleDamage(.5)
					else
						radiation_info:ScaleDamage(math.min(1 * (1600 / math.max(myPos:DistToSqr(v:GetPos()), 1)), 5))
					end
					v:TakeDamageInfo(radiation_info)
				end
			end
		end)

	elseif kind == 2 then
		local unique_id = "FireBlow" .. sid
		local old_name = self:GetNamesurvivor()
		self.TempValues.abouttoexplode = true
		self.TempValues.burnttodeath = true

		timer.Create(unique_id, 10, 1, function()
			if not IsValid(self) or self:GetNamesurvivor() ~= old_name or self:GTeam() == TEAM_SPEC or self:Health() <= 0 then
				timer.Remove(unique_id) return
			end

			if SERVER then
				local current_pos = self:GetPos() + Vector(0, 0, 10)
				self.TempValues.abouttoexplode = nil
				self.TempValues.burnttodeath = true
				local force = 100

				local dmg_info = DamageInfo()
				dmg_info:SetDamage(2000) dmg_info:SetDamageType(DMG_BLAST) dmg_info:SetAttacker(self)
				dmg_info:SetDamageForce(-self:GetAimVector() * 40)
				util.BlastDamageInfo(dmg_info, current_pos, 400)

				if hg and hg.ExplosionEffect then hg.ExplosionEffect(current_pos, 1500, 250) end
				if hgBlastDoors then hgBlastDoors(self, current_pos, force / 50, force / 15) end

				net.Start("hg_booom") net.WriteVector(current_pos) net.WriteString("Fire") net.Broadcast()
				util.ScreenShake(current_pos, 25, 1, 1, 3000)

				for i = 1, 8 do
					local randvec = VectorRand(-600, 600) randvec[3] = math.random(200, 600)
					if CreateVFireBall then CreateVFireBall(20, 50, current_pos + vector_up * 10, randvec) end
				end

				local trigger_ent = ents.Create("base_gmodentity")
				trigger_ent:SetPos(current_pos) trigger_ent:SetNoDraw(true) trigger_ent:DrawShadow(false) trigger_ent:Spawn()
				trigger_ent.Die = CurTime() + 50

				trigger_ent.Think = function(ent_self)
					ent_self:NextThink(CurTime() + 0.25)
					if ent_self.Die < CurTime() then ent_self:Remove() return true end

					for _, v in ipairs(ents.FindInSphere(ent_self:GetPos(), 300)) do
						if v:IsPlayer() and v:GTeam() ~= TEAM_SPEC and (v:GTeam() ~= TEAM_SCP or not v:GetNoDraw()) then
							v:SetOnFire(4)
							if CreateVFire then CreateVFire(v, v:GetPos(), vector_up, 2, ent_self) end
						end
					end
					return true
				end

				local suicide_dmg = DamageInfo()
				suicide_dmg:SetDamage(9999) suicide_dmg:SetDamageType(DMG_BLAST) suicide_dmg:SetAttacker(self) suicide_dmg:SetInflictor(self)
				self:TakeDamageInfo(suicide_dmg)
			end
		end)

	elseif kind == 3 then
		local unique_id = "Radiation" .. sid
		local old_name = self:GetNamesurvivor()
		self.TempValues.radiation = true

		timer.Create(unique_id, .25, 0, function()
			if not IsValid(self) or self:GetNamesurvivor() ~= old_name or self:GTeam() == TEAM_SPEC or self:Health() <= 0 then
				timer.Remove(unique_id) return
			end

			self.NextParticle = self.NextParticle or 0
			if self.NextParticle < CurTime() then
				self.NextParticle = CurTime() + 3
				ParticleEffect("rgun1_impact_pap_child", self:GetPos(), angle_zero, self)
			end

			for _, v in ipairs(ents.FindInSphere(self:GetPos(), 60)) do
				if v:IsPlayer() and v:GTeam() ~= TEAM_SPEC and v:Health() > 0 then
					if v:HasHazmat() and v ~= self then continue end

					local radiation_info = DamageInfo()
					radiation_info:SetDamageType(DMG_RADIATION) radiation_info:SetDamage(25)
					radiation_info:SetAttacker(self) radiation_info:SetDamageForce(v:GetAimVector() * 1)
					v:TakeDamageInfo(radiation_info)
				end
			end
		end)

	elseif kind == 4 then
		local unique_id = "FireBlow" .. sid
		local old_name = self:GetNamesurvivor()
		self.TempValues.abouttoexplode = true
		self.TempValues.burnttodeath = true

		timer.Create(unique_id, 1, 1, function()
			if not IsValid(self) or self:GetNamesurvivor() ~= old_name or self:GTeam() == TEAM_SPEC or self:Health() <= 0 then
				timer.Remove(unique_id) return
			end

			if SERVER then
				local current_pos = self:GetPos()
				self.TempValues.abouttoexplode = nil
				self.TempValues.burnttodeath = true

				local dmg_info = DamageInfo()
				dmg_info:SetDamage(2000) dmg_info:SetDamageType(DMG_BLAST) dmg_info:SetAttacker(self)
				dmg_info:SetDamageForce(-self:GetAimVector() * 40)
				util.BlastDamageInfo(dmg_info, self:GetPos(), 400)
				sound.Play("nextoren/others/explosion_ambient_" .. math.random(1, 2) .. ".ogg", current_pos, 100, 100, 100)

				local trigger_ent = ents.Create("base_gmodentity")
				trigger_ent:SetPos(current_pos) trigger_ent:SetNoDraw(true) trigger_ent:DrawShadow(false) trigger_ent:Spawn()
				trigger_ent.Die = CurTime() + 50

				net.Start("CreateParticleAtPos", true) net.WriteString("pillardust") net.WriteVector(current_pos) net.Broadcast()
				net.Start("CreateParticleAtPos", true) net.WriteString("gas_explosion_main") net.WriteVector(current_pos) net.Broadcast()

				trigger_ent.OnRemove = function(s) self:StopParticles() end
				trigger_ent.Think = function(s)
					s:NextThink(CurTime() + .25)
					if s.Die < CurTime() then s:Remove() end
				end
			end
		end)
	end
end

function mply:Boosted(kind, timetodie)
	if kind == 1 then
		if self:GetEnergized() then
			local current_name = self:GetNamesurvivor()
			local timer_name = "HeartAttack_" .. self:SteamID64()
			local max_ticks = 60
			local ticks = 0

			timer.Create(timer_name, 1, max_ticks, function()
				if not IsValid(self) or not self:Alive() or self:GetNamesurvivor() ~= current_name or self:GTeam() == TEAM_SPEC then
					timer.Remove(timer_name) return
				end

				ticks = ticks + 1
				local progress = ticks / max_ticks

				if self.organism then
					local org = self.organism
					org.heart = math.Approach(org.heart or 0, 1, 1 / max_ticks)
					org.painadd = (org.painadd or 0) + (1.5 * progress)
					org.shock = (org.shock or 0) + (1.0 * progress)

					if org.pulse then org.pulse = math.max(org.pulse - (3 * progress), 5) end

					if ticks == 20 then
						if self.Notify then self:Notify("В груди сильно колет...", 5, "heart_warn1", 0, nil, Color(255, 150, 150)) end
					elseif ticks == 45 then
						if self.Notify then self:Notify("Мне трудно дышать... сердце не справляется...", 5, "heart_warn2", 0, nil, Color(255, 50, 50)) end
						if hg and hg.organism and hg.organism.CoughBlood then hg.organism.CoughBlood(org) end
					end

					if ticks >= max_ticks then
						org.heartstop = true org.pulse = 0 org.heartbeat = 0 org.needotrub = true
						net.Start("ForcePlaySound", true) net.WriteString("nextoren/others/heartbeat_stop.ogg") net.Send(self)
						timer.Simple(3, function() if IsValid(self) and self:Alive() then self:Kill() end end)
					end
				else
					self:SetHealth(math.max(self:Health() - 2, 1))
					if ticks >= max_ticks then
						net.Start("ForcePlaySound", true) net.WriteString("nextoren/others/heartbeat_stop.ogg") net.Send(self)
						self:Kill()
					end
				end
			end)
			return
		end

		self:SetEnergized(true)
		timer.Simple(timetodie or 10, function()
			if IsValid(self) and self:Health() > 0 then self:SetEnergized(false) end
		end)

	elseif kind == 2 then
		if self:GetBoosted() then return end
		self:SetBoosted(true)

		if self.exhausted then
			self.exhausted = false
			if SERVER then self:SetRunSpeed(self.RunSpeed or 200) self:SetJumpPower(self.jumppower or 200) end
		end

		self:SetWalkSpeed(self:GetWalkSpeed() * 1.3)
		self:SetRunSpeed(self:GetRunSpeed() * 1.3)

		timer.Simple(timetodie or 10, function()
			if IsValid(self) and self:Alive() then
				self:SetBoosted(false)
				self:SetWalkSpeed(math.Round(self:GetWalkSpeed() * 0.77))
				self:SetRunSpeed(math.Round(self:GetRunSpeed() * 0.77))
			end
		end)

	elseif kind == 3 then
		if not SERVER then return end
		local randomhealth = math.random(60, 80)
		self.old_maxhealth = self.old_maxhealth or self:GetMaxHealth()
		local old_name = self:GetNamesurvivor()

		self:SetHealth(math.min(self.old_maxhealth + 200, self:Health() + randomhealth))
		self:SetMaxHealth(math.min(self.old_maxhealth + 200, self:GetMaxHealth() + randomhealth))

		local unique_id = "ReduceHealthByPills" .. self:SteamID64()
		timer.Create(unique_id, 1, self:GetMaxHealth() - self.old_maxhealth, function()
			if not IsValid(self) then timer.Remove(unique_id) return end

			if self:Health() < 2 or not self:Alive() or self:GTeam() == TEAM_SPEC or self:GTeam() == TEAM_SCP or self:GetMaxHealth() == self.old_maxhealth or self:GetNamesurvivor() ~= old_name then
				self:SetMaxHealth(self.old_maxhealth)
				self.old_maxhealth = nil
				timer.Remove(unique_id)
				return
			end

			self:SetHealth(self:Health() - 1)
			self:SetMaxHealth(self:GetMaxHealth() - 1)

			if self:GetMaxHealth() == self.old_maxhealth then self.old_maxhealth = nil end
		end)

	elseif kind == 4 then
		self:SetAdrenaline(true)
		timer.Simple(timetodie or 10, function() if IsValid(self) then self:SetAdrenaline(false) end end)

	elseif kind == 5 or kind == 6 then
		self.WaterDr = true
		timer.Simple(timetodie or 10, function() if IsValid(self) then self.WaterDr = false end end)
	end
end

function mply:GetExp()
	if not self.GetNEXP then player_manager.RunClass(self, "SetupDataTables") end
	if self.GetNEXP and self.SetNEXP then return self:GetNEXP() end
	ErrorNoHalt("Cannot get the exp, GetNEXP invalid")
	return 0
end

local box_parameters = Vector(5, 5, 5)

net.Receive("ThirdPersonCutscene", function()
	local time = net.ReadUInt(4)
	local client = LocalPlayer()
	client.ExitFromCutscene = nil
	local multiplier = 0

	hook.Add("CalcView", "ThirdPerson", function(cl, pos, angles, fov)
		if not cl.ExitFromCutscene and multiplier ~= 1 then
			multiplier = math.Approach(multiplier, 1, RealFrameTime() * 2)
		elseif cl.ExitFromCutscene then
			multiplier = math.Approach(multiplier, 0, RealFrameTime() * 2)
			if multiplier < .25 then
				hook.Remove("CalcView", "ThirdPerson")
				cl.ExitFromCutscene = nil
			end
		end

		local offset_eyes = cl:LookupAttachment("eyes")
		local att = cl:GetAttachment(offset_eyes)
		if att then angles = att.Ang end

		local startpos = att and att.Pos or pos
		local trace = util.TraceLine({
			start = startpos,
			endpos = startpos + angles:Forward() * (-80 * multiplier),
			filter = cl, mins = -box_parameters, maxs = box_parameters, mask = MASK_VISIBLE
		})

		pos = trace.Hit and (trace.HitPos + trace.HitNormal * 5) or trace.HitPos

		return { origin = pos, angles = angles, fov = fov, drawviewer = true }
	end)

	timer.Simple(time, function()
		if IsValid(client) then client.ExitFromCutscene = true end
	end)
end)

function BreachUtilEffect(effectname, effectdata)
	net.Start("Shaky_UTILEFFECTSYNC", true)
	net.WriteString(effectname)
	net.WriteTable({effectdata})
	net.Broadcast()
end

function BreachParticleEffect(ParticleName, Position, angles, EntityParent)
	EntityParent = EntityParent or NULL
	ParticleEffect(ParticleName, Position, angles, EntityParent)
	net.Start("Shaky_PARTICLESYNC", true)
	net.WriteString(ParticleName)
	net.WriteVector(Position)
	net.WriteAngle(angles)
	net.WriteEntity(EntityParent)
	net.Broadcast()
end

function BreachParticleEffectAttach(ParticleName, attachType, entity, attachmentID)
	ParticleEffectAttach(ParticleName, attachType, entity, attachmentID)
	net.Start("Shaky_PARTICLEATTACHSYNC", true)
	net.WriteString(ParticleName)
	net.WriteUInt(attachType, 4)
	net.WriteEntity(entity)
	net.WriteUInt(attachmentID, 20)
	net.Broadcast()
end

if CLIENT then
	net.Receive("Shaky_PARTICLESYNC", function(len)
		ParticleEffect(net.ReadString(), net.ReadVector(), net.ReadAngle(), net.ReadEntity())
	end)
	net.Receive("Shaky_UTILEFFECTSYNC", function(len)
		local effectname = net.ReadString()
		local EfData = net.ReadTable()[1] or EffectData()
		util.Effect(effectname, EfData)
	end)
	net.Receive("Shaky_PARTICLEATTACHSYNC", function(len)
		ParticleEffectAttach(net.ReadString(), net.ReadUInt(4), net.ReadEntity(), net.ReadUInt(20))
	end)
end

function mply:GetLevel()
	if not self.GetNLevel then player_manager.RunClass(self, "SetupDataTables") end
	return (self.GetNLevel and self.SetNLevel) and self:GetNLevel() or 0
end

function mply:WouldDieFrom(damage, hitpos)
	return self:Health() <= damage
end

function mply:ThrowFromPositionSetZ(pos, force, zmul, noknockdown)
	if force == 0 or self.NoThrowFromPosition then return false end
	zmul = zmul or .7

	if self:IsPlayer() then force = force * (self.KnockbackScale or 1) end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if IsValid(phys) and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			local dir = nearest - pos dir.z = 0 dir:Normalize() dir.z = zmul
			phys:ApplyForceOffset(force * 50 * dir, nearest)
		end
		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		local dir = self:LocalToWorld(self:OBBCenter()) - pos 
		dir.z = 0 dir:Normalize() dir.z = zmul
		self:SetVelocity(force * dir)
		return true
	end
end

function mply:MeleeViewPunch(damage)
	local maxpunch = (damage + 25) * 0.5
	local minpunch = -maxpunch
	self:ViewPunch(Angle(math.Rand(minpunch, maxpunch), math.Rand(minpunch, maxpunch), math.Rand(minpunch, maxpunch)))
end

if SERVER then
	util.AddNetworkString("SetStamina")
	function mply:SetStamina(float)
		net.Start("SetStamina", true) net.WriteFloat(float) net.WriteBool(false) net.Send(self)
	end
	function mply:AddStamina(float)
		net.Start("SetStamina", true) net.WriteFloat(float) net.WriteBool(true) net.Send(self)
	end
end

net.Receive("SetStamina", function()
	local stamina, add = net.ReadFloat(), net.ReadBool()
	local ply = LocalPlayer()
	if not add then ply.Stamina = stamina else
		ply.Stamina = (ply.Stamina or 100) + stamina
	end
end)

local cd_stamina = 0
if CLIENT then
	hook.Add("KeyPress", "Stamina_drain", function(ply, press)
		if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_OBSERVER then return end
		if press == IN_JUMP and ply.Stamina and not ply:Crouching() and ply:IsOnGround() then
			if not ply:GetEnergized() and not ply:GetAdrenaline() then
				cd_stamina = CurTime() + 3
				ply.Stamina = ply.Stamina - 6
			end
		end
	end)
end

function UpdateStamina_Breach(v, cd)
	LocalPlayer().Stamina = v
	cd_stamina = CurTime() + (cd or 1.5)
end

function Sprint(ply, mv)
	if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_OBSERVER then return end
	if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then
		ply.Stamina = nil ply.exhausted = nil return
	end
end

hook.Add("SetupMove", "stamina_new", function(ply, mv)
	if CLIENT then Sprint(ply, mv) end
end)

hook.Add("Move", "LeanSpeed", function(ply, mv)
	if ply:IsLeaning() and CanLean and CanLean(ply) then
		local speed = ply:GetWalkSpeed() * 0.55
		mv:SetMaxSpeed(speed) mv:SetMaxClientSpeed(speed)
	end
end)

hook.Add("CreateMove", "stamina_new", function(mv)
	local ply = LocalPlayer()
	if (ply.exhausted and not ply:GetBoosted()) or ply:GetInDimension() then
		if mv:KeyDown(IN_SPEED) then mv:SetButtons(mv:GetButtons() - IN_SPEED) end
		if mv:KeyDown(IN_JUMP) then mv:SetButtons(mv:GetButtons() - IN_JUMP) end
	end
end)

if CLIENT then
	function mply:DropWeapon(class)
		net.Start("DropWeapon", true) net.WriteString(class) net.SendToServer()
	end

	function mply:SelectWeapon(class)
		if not self:HasWeapon(class) then return end
		self.DoWeaponSwitch = self:GetWeapon(class)
	end
	
	hook.Add("CreateMove", "WeaponSwitch", function(cmd)
		local ply = LocalPlayer()
		if not IsValid(ply.DoWeaponSwitch) then return end

		cmd:SelectWeapon(ply.DoWeaponSwitch)

		if ply:GetActiveWeapon() == ply.DoWeaponSwitch then
			ply:GetActiveWeapon().DrawCrosshair = true
			ply.DoWeaponSwitch = nil
		end
	end)
end