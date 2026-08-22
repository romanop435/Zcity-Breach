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
local ErrorNoHalt = ErrorNoHalt
local util = util
local net = net
local player = player


local mply = FindMetaTable("Player")
local ment = FindMetaTable("Entity")

util.AddNetworkString("Special_outline")
util.AddNetworkString("catch_breath")
util.AddNetworkString("StopGestureClientNetworking")
util.AddNetworkString("ArmorIndicator")

mply.SetBodyGroups = ment.SetBodyGroups


function mply:SetUsingCloth(str)
	self:UpdateArmorIndicator("Clothes", (str and str ~= ""), str or "")
end

function mply:SetUsingBag(str)
	self:UpdateArmorIndicator("Bag", (str and str ~= ""), str or "")
end

function mply:SetUsingArmor(str)
	self:UpdateArmorIndicator("Armor", (str and str ~= ""), str or "")
end

function mply:SetUsingHelmet(str)
	self:UpdateArmorIndicator("Hat", (str and str ~= ""), str or "")
end

function mply:UpdateArmorIndicator(stype, bHas, ArmorEntity)
	ArmorEntity = ArmorEntity or ""

	net.Start("ArmorIndicator")
	net.WriteString(stype)
	net.WriteBool(bHas)
	net.WriteString(ArmorEntity)
	net.Send(self)

	if stype == "Everything" then
		self.HasHelmet = bHas
		self.HasArmor = bHas
		self.UsingCloth = bHas
		self.Hat = bHas
		self.ArmorEnt = bHas
		self.DisableFootsteps = nil
		self.HasBag = bHas
		self.BagEnt = bHas
		return
	end

	if stype == "Hat" then
		self.HasHelmet = bHas
		self.Hat = ArmorEntity
	elseif stype == "Armor" then
		self.HasArmor = bHas
		self.ArmorEnt = ArmorEntity
	elseif stype == "Clothes" then
		self.UsingCloth = ArmorEntity
	elseif stype == "Bag" then
		self.HasBag = bHas
		self.BagEnt = ArmorEntity
	end
end

net.Receive("catch_breath", function(len, ply)
	if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then return end
	
	ply.breathcd = ply.breathcd or 0
	if ply.breathcd >= CurTime() then return end
	
	ply.breathcd = CurTime() + 7
	local sound_file = ply:IsFemale() and "^nextoren/charactersounds/breathing/breathing_female.wav" or "^nextoren/charactersounds/breathing/breath0.wav"
	
	ply:EmitSound(sound_file, 75, 100, 1, CHAN_VOICE)
	
	timer.Create("stop_exhaust_" .. ply:SteamID64(), 6, 1, function()
		if IsValid(ply) then
			ply:StopSound(sound_file)
		end
	end)
end)

function mply:PrintTranslatedMessage(string)
	net.Start("TranslatedMessage")
	net.WriteString(string)
	net.Send(self)
end

local function CoreBoneMerge(target, mdl, table_name, keep_on_recreate)
	local bonemerged_ent = ents.Create("ent_bonemerged")
	bonemerged_ent:Spawn()
	bonemerged_ent:SetSolid(SOLID_NONE)
	bonemerged_ent:SetParent(target)
	bonemerged_ent:SetOwner(target)
	bonemerged_ent:SetModel(mdl)
	bonemerged_ent:SetTransmitWithParent(true)
	
	if keep_on_recreate then
		bonemerged_ent:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
	end

	target[table_name] = target[table_name] or {}
	table.insert(target[table_name], bonemerged_ent)

	return bonemerged_ent
end

function GhostBoneMerge(target, mdl) return CoreBoneMerge(target, mdl, "GhostBoneMergedEnts", false) end
function GhostBoneMergeArmor(target, mdl) return CoreBoneMerge(target, mdl, "GhostBoneMergedArmorEnts", false) end
function GhostBoneMergeHat(target, mdl) return CoreBoneMerge(target, mdl, "GhostBoneMergedHatEnts", false) end
function Bonemerge(mdl, ent) return CoreBoneMerge(ent, mdl, "BoneMergedEnts", true) end
function ApplyBonemergeHackerHat(mdl, ent) return CoreBoneMerge(ent, mdl, "BoneMergedHackerHat", true) end

function mply:ForceDropWeapon(class)
	if not self:HasWeapon(class) then return end
	local wep = self:GetWeapon(class)
	if IsValid(wep) and self:GTeam() ~= TEAM_SPEC then
		if wep:GetPrimaryAmmoType() > 0 then
			wep.SavedAmmo = wep:Clip1()
		end	
		if not wep:GetClass() or wep.droppable == false then return end
		
		BREACH.AdminLogs:Log("drop", {user = self, weapon = class})
		self:DropWeapon(wep)
		self:ConCommand("lastinv")
	end
end

function mply:DropAllWeapons(strip)
	if GetConVar("br_dropvestondeath"):GetInt() ~= 0 then
		self:UnUseArmor()
	end
	
	local weps = self:GetWeapons()
	if #weps > 0 then
		local pos = self:GetPos()
		for _, v in ipairs(weps) do
			if v.droppable ~= false then
				local class = v:GetClass()
				local wep = ents.Create(class)
				if IsValid(wep) then
					wep:SetPos(pos)
					wep:Spawn()
					if class == "br_keycard" then
						wep:SetKeycardType(v.KeycardType or v:GetNWString("K_TYPE", "safe"))
					end
					if v:GetPrimaryAmmoType() > 0 then
						wep.SavedAmmo = v:Clip1()
					end
				end
			end
			if strip then v:Remove() end
		end
	end
end

function mply:FindClosest(tab, num)
	local allradiuses = {}
	local myPos = self:GetPos()
	for _, v in pairs(tab) do
		if IsValid(v) then table.insert(allradiuses, {v:Distance(myPos), v}) end
	end
	table.sort(allradiuses, function(a, b) return a[1] < b[1] end)
	
	local rtab = {}
	for i = 1, math.min(num, #allradiuses) do
		table.insert(rtab, allradiuses[i])
	end
	return rtab
end

function mply:DeleteItems()
	for _, v in ipairs(ents.FindInSphere(self:GetPos(), 150)) do
		if v:IsWeapon() and not IsValid(v.Owner) then v:Remove() end
	end
end

function mply:ClearBodyGroups()
	for _, v in pairs(self:GetBodyGroups()) do
		self:SetBodygroup(v.id, 0)
	end
end

local function CleanBoneMergeTable(tbl)
	if tbl then
		for _, v in ipairs(tbl) do
			if IsValid(v) then v:Remove() end
		end
	end
end

function mply:ClearBoneMerges()
	CleanBoneMergeTable(self.GhostBoneMergedEnts)
	CleanBoneMergeTable(self.BoneMergedEnts)
	CleanBoneMergeTable(self.BoneMergedHackerHat)
	CleanBoneMergeTable(self.GhostBoneMergedHatEnts)
	CleanBoneMergeTable(self.GhostBoneMergedArmorEnts)
end

function mply:UnUseArmor()
	if self:GTeam() == TEAM_CBG then return end
	local cloth = self:GetUsingCloth()
	if not cloth or cloth == "" then return end

	CleanBoneMergeTable(self.GhostBoneMergedEnts)
	
	local function SetVis(tbl, state)
		if tbl then
			for _, v in ipairs(tbl) do
				if IsValid(v) then v:SetInvisible(state) end
			end
		end
	end
	
	for _, v in ipairs(self:LookupBonemerges()) do v:SetInvisible(false) end
	SetVis(self.BoneMergedEnts, false)
	SetVis(self.BoneMergedHackerHat, false)

	local item = ents.Create(cloth)
	if IsValid(item) then
		item:Spawn()
		item:SetPos(self:GetPos())
		for i = 0, 12 do
			item.Bodygroups[i] = self:GetBodygroup(i)
		end
	end
	
	self:SetSubMaterial() 
	self:ClearBodyGroups()
	self:SetModel(self.OldModel or self:GetModel())
	self:SetBodyGroups(self.OldBodygroups or "")
	self:SetSkin(self.OldSkin or 0)
	self:SetUsingCloth("")
	
	if self:HasWeapon("weapon_scp_409") then self:Start409Infected(self) end
	self.CanUseArmor = true
	self:SetupHands()
end

function BroadcastPlayMusic(music, s_time)
	net.Start("ClientPlayMusic")
	net.WriteUInt(music, 32)
	net.Send(GetActivePlayers())
end

function BroadcastFadeMusic(s_time)
	net.Start("ClientFadeMusic")
	net.WriteFloat(s_time or 1)
	net.Send(GetActivePlayers())
end

function BroadcastStopMusic()
	net.Start("ClientStopMusic")
	net.Send(GetActivePlayers())
end

function mply:PlayMusic(music)
	net.Start("ClientPlayMusic")
	net.WriteUInt(music, 32)
	net.Send(self)
end

function mply:FadeMusic(s_time)
	net.Start("ClientFadeMusic")
	net.WriteFloat(s_time or 1)
	net.Send(self)
end

function mply:StopMusic()
	net.Start("ClientStopMusic")
	net.Send(self)
end

function mply:SetSpectator()
	self:DropObject()
	self:ClearBoneMerges()
	self:ClearBodyGroups()
	self:SetSkin(0)
	self:Flashlight(false)
	self:AllowFlashlight(false)
	self.handsmodel = nil
	self:StripWeapons()
	self:RemoveAllAmmo()
	self:SetGTeam(TEAM_SPEC)
	
	if self.SetRoleName then self:SetRoleName(role.Spectator) end
	self.Active = true
	self.canblink = false
	self:SetNoTarget(true)
	self.BaseStats = nil
	self:SetMoveType(MOVETYPE_NOCLIP)
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	net.Start("set_spectator_sync")
	net.WriteEntity(self)
	net.Broadcast()

	self:ClearSpectateTarget()
end

function mply:ClearSpectateTarget()
	if self:GTeam() ~= TEAM_SPEC then return end
	if SERVER then
		local pos = self:GetPos()
		local ang = self:EyeAngles()
		
		self:UnSpectate()
		self:Spectate(OBS_MODE_ROAMING)
		self:SetObserverMode(OBS_MODE_ROAMING)
		self:SpectateEntity(NULL)
		
		self:SetPos(pos)
		self:SetEyeAngles(ang)
	end
	self:SetMoveType(MOVETYPE_NOCLIP)
end

function mply:GiveTempAttach()
	self:RXSENDNotify("l:temp_attach")
	self.CanAttach = true
	self:SetNW2Bool("Breach:CanAttach", true)
	timer.Simple(30, function()
		if IsValid(self) and self:GTeam() ~= TEAM_SPEC then
			self.CanAttach = false
			self:SetNW2Bool("Breach:CanAttach", false)
			self:RXSENDNotify("l:temp_attach_time_out")
		end
	end)
end

function mply:AddSpyDocument()
	if self:GetRoleName() ~= role.SCI_SpyUSA then return end
	local count = self:GetNWInt("CollectedDocument") + 1
	self:SetNWInt("CollectedDocument", count)
	if count >= 3 then
		self:RXSENDNotify("l:uiuspy_docs_ready")
	end
end

function mply:GuaranteedSetPos(vector)
	self:SetPos(vector)
	if self:GetPos() ~= vector then
		timer.Simple(0, function() 
			if not IsValid(self) then return end
			self:SetPos(vector)
			if self:GetPos() ~= vector then
				local tid = "GuaranteedSetPos"..self:SteamID64()
				timer.Create(tid, 0, 0, function()
					if not IsValid(self) or self:GetPos() == vector or not self:Alive() or self:Health() <= 0 then 
						timer.Remove(tid) 
						return 
					end
					self:SetPos(vector)
				end)
			end
		end)
	end
end

hook.Add("PlayerShouldTakeDamage", "scp_860_nodamage", function(ply)
	if ply:GetRoleName() == SCP8602 and ply:GetPos():WithinAABox(Vector(9427.23, -10222.64, -1387.80), Vector(15480.25, -15956.70, -3600.17)) then
		return false
	end
	return true
end)

function mply:AddToStatistics(reason_exp, value_exp)
	if self:GTeam() == TEAM_ARENA or GetGlobalBool("NewEventRound") then return end

	if tostring(reason_exp) == "l:escaped" then
		if self:GetRoleName() == role.ClassD_Banned and not self.norewardbanned then
			SetPenalty(self:SteamID64(), self:GetPenaltyAmount() - 1)
		end
		self:AddNEscapes(1)
		self:AddElo(self:CalculateElo(20, true))
	end

	if reason_exp == "l:cheemer_rescue" then self:CompleteAchievement("cheemer") end
	if value_exp > 0 and self:GetNLevel() <= 10 then value_exp = value_exp * 2 end

	self.LevelStats = self.LevelStats or {}
	for _, stat in ipairs(self.LevelStats) do
		if stat.reason == reason_exp then
			stat.value = stat.value + value_exp
			return
		end
	end
	table.insert(self.LevelStats, {value = value_exp, reason = reason_exp})
end

function mply:RemoveFromStatistics(reason_exp)
	if not self.LevelStats then return end
	for i = 1, #self.LevelStats do
		if self.LevelStats[i].reason == reason_exp then
			table.remove(self.LevelStats, i)
			return
		end
	end
end

function mply:ClearStatistics()
	self.LevelStats = {}
end

util.AddNetworkString("WTh_SyncData")
util.AddNetworkString("WTh_SetResearch")
util.AddNetworkString("WTh_BuyWithFreeEXP")
util.AddNetworkString("WTh_ToggleBlacklist")

net.Receive("WTh_ToggleBlacklist", function(_, ply)
	if not ply.WTh_DataLoaded then return end

	local roleName = net.ReadString()
	if not BREACH.GetRoleDataByName(roleName) then return end

	ply.WTh_BlacklistCache = ply.WTh_BlacklistCache or {}
	local enabled = not ply.WTh_BlacklistCache[roleName]

	if enabled then
		local count = 0
		for _, blacklisted in pairs(ply.WTh_BlacklistCache) do
			if blacklisted then count = count + 1 end
		end
		if count >= 2 then return end
		ply.WTh_BlacklistCache[roleName] = true
	else
		ply.WTh_BlacklistCache[roleName] = nil
	end

	BREACH.DataBaseSystem:SetRoleBlacklisted(ply:SteamID64(), roleName, enabled)

	net.Start("WTh_SyncData")
	net.WriteString("update_blacklist")
	net.WriteTable(ply.WTh_BlacklistCache)
	net.Send(ply)
end)

net.Receive("WTh_SetResearch", function(len, ply)
	if not ply.WTh_DataLoaded then ply:RXSENDNotify("Ваш профиль загружается, подождите...") return end
	
	ply.NextSetRes = ply.NextSetRes or 0
	if ply.NextSetRes > CurTime() then return end
	ply.NextSetRes = CurTime() + 0.5 
	
	local roleName = net.ReadString()
	local data = BREACH.GetRoleDataByName(roleName)
	if data and not ply:IsRoleUnlocked(roleName) then
		ply:SetBreachData("active_research", roleName)
		ply:SetNW2String("WTh_ActiveResearch", roleName)
		ply:RXSENDNotify("Вы начали исследование: ", Color(0, 255, 0), GetLangRole(roleName))
		
		net.Start("WTh_SyncData")
		net.WriteString("active_research")
		net.WriteString(roleName)
		net.Send(ply)
	end
end)

net.Receive("WTh_BuyWithFreeEXP", function(len, ply)
	if not ply.WTh_DataLoaded then return end
	ply.NextExpInvest = ply.NextExpInvest or 0
	if ply.NextExpInvest > CurTime() then return end
	ply.NextExpInvest = CurTime() + 0.1 

	local roleName = net.ReadString()
	local amount = net.ReadInt(32)

	local roleData = BREACH.GetRoleDataByName(roleName)
	if not roleData or ply:IsRoleUnlocked(roleName) then return end

	local freeEXP = ply:GetFreeEXP()
	local invested = ply:GetRoleInvestedEXP(roleName)
	local cost = roleData.cost or 0
	local needed = cost - invested

	amount = math.Clamp(amount, 0, math.min(freeEXP, needed))

	if amount > 0 then
		local newFree = freeEXP - amount
		ply:SetBreachData("free_exp", newFree)
		ply:SetNWInt("WTh_FreeEXP", newFree)
	
		net.Start("WTh_SyncData")
		net.WriteString("update_free_exp")
		net.WriteInt(newFree, 32)
		net.Send(ply)

		ply:AddRoleEXPWT(roleName, amount)
		ply:RXSENDNotify("Вложено ", Color(100, 200, 255), tostring(amount), color_white, " свободного опыта в ", Color(0, 255, 0), GetLangRole(roleName))
	end
end)

util.AddNetworkString("WTh_SetUpgradeResearch")	
util.AddNetworkString("WTh_BuyUpgradeWithFreeEXP")	

net.Receive("WTh_SetUpgradeResearch", function(len, ply)
	if not ply.WTh_DataLoaded then return end
	local roleName = net.ReadString()
	local upgradeId = net.ReadString()

	local roleData = BREACH.GetRoleDataByName(roleName)
	if roleData and roleData.upgrades and roleData.upgrades[upgradeId] then
		if not ply:IsUpgradeUnlocked(roleName, upgradeId) then
			local format = roleName .. ":" .. upgradeId
			ply:SetBreachData("active_upgrade_research", format)
			ply:SetNW2String("WTh_ActiveUpgrade", format)
			ply:RXSENDNotify("Вы начали исследование модуля: ", Color(0, 255, 0), roleData.upgrades[upgradeId].name)
		
			net.Start("WTh_SyncData")
			net.WriteString("active_upgrade")
			net.WriteString(format)
			net.Send(ply)
		end
	end
end)

net.Receive("WTh_BuyUpgradeWithFreeEXP", function(len, ply)
	if not ply.WTh_DataLoaded then return end
	local roleName = net.ReadString()
	local upgId = net.ReadString()
	local amount = net.ReadInt(32)

	local roleData = BREACH.GetRoleDataByName(roleName)
	if not roleData or not roleData.upgrades or not roleData.upgrades[upgId] then return end
	if ply:IsUpgradeUnlocked(roleName, upgId) then return end

	local freeEXP = ply:GetFreeEXP()
	local upgData = roleData.upgrades[upgId]
	local invested = ply:GetUpgradeInvestedEXP(roleName, upgId)
	local needed = upgData.cost - invested

	amount = math.Clamp(amount, 0, math.min(freeEXP, needed))

	if amount > 0 then
		local newFree = freeEXP - amount
		ply:SetBreachData("free_exp", newFree)
		ply:SetNWInt("WTh_FreeEXP", newFree)
	
		net.Start("WTh_SyncData")
		net.WriteString("update_free_exp")
		net.WriteInt(newFree, 32)
		net.Send(ply)
	
		local current = invested + amount
		local is_unlocked = false
		if current >= upgData.cost then
			current = upgData.cost
			is_unlocked = true
			
			ply.WTh_UpgUnlockedCache = ply.WTh_UpgUnlockedCache or {}
			ply.WTh_UpgUnlockedCache[roleName] = ply.WTh_UpgUnlockedCache[roleName] or {}
			ply.WTh_UpgUnlockedCache[roleName][upgId] = true
		
			ply:RXSENDNotify("Изучена модификация: ", Color(0,255,0), upgData.name)
		
			local actR, actU = ply:GetActiveUpgradeResearch()
			if actR == roleName and actU == upgId then
				ply:SetBreachData("active_upgrade_research", "")
				ply:SetNW2String("WTh_ActiveUpgrade", "")
				if SERVER then ply.WTh_ActiveUpgrade_Cache = "" end
			end
		end
	
		ply.WTh_UpgEXPCache = ply.WTh_UpgEXPCache or {}
		ply.WTh_UpgEXPCache[roleName] = ply.WTh_UpgEXPCache[roleName] or {}
		ply.WTh_UpgEXPCache[roleName][upgId] = current
	
		local sql_u_unlocked = is_unlocked and 1 or 0
		local q_upsert = string.format([[
			INSERT OR REPLACE INTO breach_upgrades (steamid64, rolename, upgid, exp, unlocked) 
			VALUES ('%s', %s, %s, %d, %d)
		]], ply:SteamID64(), sql.SQLStr(roleName), sql.SQLStr(upgId), current, sql_u_unlocked)
		
		if newMysql then newMysql.query(q_upsert) end
	
		ply:RXSENDNotify("Вложено ", Color(100, 200, 255), tostring(amount), color_white, " свободного опыта в ", Color(0, 255, 0), upgData.name)
	
		net.Start("WTh_SyncData")
		net.WriteString("update_upg_exp")
		net.WriteString(roleName)
		net.WriteString(upgId)
		net.WriteInt(current, 32)
		net.Send(ply)
	end
end)


function mply:LevelBar(noreward)
	if not self.GetNEXP then return end
	self.LevelStats = self.LevelStats or {}

	if self.StartedPlayAt and self:GetRoleName() ~= role.NTF_Pilot then
		local exp = (CurTime() - self.StartedPlayAt)
		if exp > 0 then exp = exp * 0.55 end
		if not noreward then self:AddToStatistics("l:survival_bonus", exp) end
		self.StartedPlayAt = CurTime() + 100
	end

	if self:IsPremium() then
		local exp = 0
		for _, v in ipairs(self.LevelStats) do
			if v.value > 0 then exp = exp + v.value end
		end
		if exp ~= 0 then table.insert(self.LevelStats, {value = exp, reason = "l:prem_bonus"}) end
	end

	local total_exp = 0
	for _, stat in ipairs(self.LevelStats) do total_exp = total_exp + stat.value end
	total_exp = math.floor(total_exp)
	
	local extra_data = {}
	if self:GetRoleName() ~= role.ClassD_Banned and total_exp > 0 then
		local target_role = self:GetActiveResearch() or ""
		local actRole, actUpg = self:GetActiveUpgradeResearch()
		
		local free_xp_multiplier = self:IsPremium() and 0.20 or 0.10
		local free_xp_earned = math.floor(total_exp * free_xp_multiplier)
		local target_xp_earned, upg_xp_earned = 0, 0

		if target_role ~= "" then target_xp_earned = total_exp 
		elseif actRole and actUpg then upg_xp_earned = total_exp
		else free_xp_earned = math.floor(total_exp * 0.50) end

		extra_data = {
			total = total_exp, free_xp = free_xp_earned, target_role = target_role,
			target_xp = target_xp_earned, faction_role = "", faction_xp = 0,
			upg_role = actRole or "", upg_id = actUpg or "", upg_xp = upg_xp_earned
		}

		self:SetBreachData("free_exp", tonumber(self:GetBreachData("free_exp") or 0) + extra_data.free_xp)
		self:SetNWInt("WTh_FreeEXP", tonumber(self:GetBreachData("free_exp")))

		if extra_data.target_xp > 0 then self:AddRoleEXPWT(extra_data.target_role, extra_data.target_xp) end
	end
	
	self:AddExp(total_exp)
	if self:GetRoleName() ~= role.ClassD_Banned then
		net.Start("LevelBar")
		net.WriteTable(self.LevelStats)
		net.WriteUInt(self:GetNEXP(), 32)
		net.WriteTable(extra_data) 
		net.Send(self)
	end

	self.LevelStats = {}
	self.SurvivalTime = nil
end

function SetPenalty(steamid64, amount, admin)
	local ply = player.GetBySteamID64(steamid64)
	if amount > 0 then
		if IsValid(ply) then
			if ply:GetPenaltyAmount() <= 0 then
				if admin then ply:RXSENDNotify("Вы получили ",Color(255,0,0),"наказание ",color_white,", Вы должны сбежать несколько раз, чтобы избавиться от этого состояния")
				else ply:RXSENDNotify("Вы достигли верхнего предела и получили свою личность ",Color(255,0,0),"Наказание ",color_white,", Чтобы выйти из этого состояния, вы должны сбежать несколько раз") end
			end
			ply:SetPenaltyAmount(amount)
			ply:RXSENDNotify("Требуемое количество побегов: ",Color(255,0,0), amount)
		end
		util.SetPData(util.SteamIDFrom64(steamid64), "breach_penalty", amount)
	else
		if IsValid(ply) then
			ply:SetPenaltyAmount(0)
			if admin then ply:RXSENDNotify("Наказание отменяется")
			else ply:RXSENDNotify("Вы сбежали необходимое количество раз! Старайтесь больше не нарушать") end
		end
		util.RemovePData(util.SteamIDFrom64(steamid64), "breach_penalty")
	end
end

function GivePenalty(steamid64, amount, admin)
	local ply = player.GetBySteamID64(steamid64)
	if IsValid(ply) then
		if ply:GetPenaltyAmount() <= 0 then
			if admin then ply:RXSENDNotify("Вы получили ",Color(255,0,0),"наказание ",color_white,", Вы должны сбежать несколько раз, чтобы избавиться от этого состояния")
			else ply:RXSENDNotify("Вы достигли верхнего предела и получили свою личность ",Color(255,0,0),"Наказание ",color_white,", Чтобы выйти из этого состояния, вы должны сбежать несколько раз") end
		end
		ply:SetPenaltyAmount(ply:GetPenaltyAmount() + amount)
	end
	
	local current_pen = tonumber(util.GetPData(util.SteamIDFrom64(steamid64), "breach_penalty", 0)) or 0
	util.SetPData(util.SteamIDFrom64(steamid64), "breach_penalty", math.max(0, current_pen + amount))
end

local duck_offset = Vector(0, 0, 32)
local stand_offset = Vector(0, 0, 64)

function mply:SetupNormal()
	self.GasExposure = 0
	self.scp215mana = 0
	self:SetNWBool("SCP966_Insomniac", false)
	self:SetNWBool("HasPestilence", false)
	self:SetNWBool("CloakSAM", false)
	BREACH.SendClientEvent(self, "close_inventory")

	self:SetSolid(SOLID_BBOX)
	self:PhysicsInit(SOLID_BBOX)
	self:RemoveSolidFlags(FSOLID_NOT_SOLID)
	self:SetMoveType(MOVETYPE_WALK)
	self:SetRenderMode(RENDERMODE_NORMAL)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	self.handcuffed = false
	self:SetNetVar("handcuffed", false)
	self.Inventory = { ["Helmets"] = {}, ["Armors"] = {}, ["Cloth"] = {}, ["Items"] = {{},{},{},{},{},{},{},{},{},{},{},{}} }
	
	--self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.LastDamagePly = nil
	self:SetNWBool("radio_enbl", false)
	self:SetNWFloat("radio_chanel", 0)
	self:SetNWInt("InventoryMaxSlots", 8)
	self:SetNWInt("ActiveSlot", 0)
	self:SetNWInt("MeatWeapon", 0)

	BREACH.SendClientEvent(self, "clear_nvg")
	net.Start("NightvisionOff") net.Send(self)

	self.OldPosition1499 = nil
	BREACH.SendClientEvent(self, "scp079_mode", {enabled = false})

	self.Infected409 = false
	local sid = self:SteamID64()
	timer.Remove("SCP409Phase1_"..sid)
	timer.Remove("SCP409Phase2_"..sid)
	timer.Remove("SCP409Phase3_"..sid)
	timer.Remove("SCP1025COLD"..sid)
	
	self:SetSubMaterial()
	self:SetCrouching(false)
	self:ResetHull()
	self:SetViewOffsetDucked(duck_offset)
	self:SetViewOffset(stand_offset)
	self:ConCommand("-forward")
	
	local saveangles = self:EyeAngles()
	local saveangles2 = self:GetAngles()
	local savepos = self:EyePos()
	
	self.CBG_NOFUCKING_VIP_MENU = nil
	self:SetColor(color_white)
	self.SurvivalTime = nil
	self.SCP079 = nil
	self.CBG_ReturnDamage = nil
	self.CBG_Shadow_Enabled = nil
	self.CBG_Shadow = nil
	timer.Remove("CBG_Shadow_" .. sid)
	timer.Remove("CBG_Shadow_Delete_" .. sid)
	
	self.___OldRunSpeed = nil
	self.___OldWalkSpeed = nil
	self.AlreadySwapedDefaultRole = false
	self:SetNWBool('ChipedByAndersonRobotik', false)
	self.recoilmultiplier = 1
	self:SetNWEntity("NTF1Entity", NULL)
	self.AdditionalScaleDamage = nil
	self.norewardbanned = nil
	self.queuerole = nil
	self:SetNWAngle("ViewAngles", angle_zero)
	
	self.OriginalWalkSpeed = 0
	self.OriginalRunSpeed = 0
	self:SetMaterial("")
	self.CameraLook = nil
	self:SetNWInt("CollectedDocument", 0)
	self:SetViewEntity(self)
	self.IsZombie = nil
	self.burn_to_death = nil
	self.AbilityTAB = nil
	self:SetEnergized(false)
	self:SetBoosted(false)
	self.VoicePitch = 100
	self:SetNWBool("RXSEND_ONFIRE", false)
	self.br_onfire = nil
	self.isescaping = false
	self.abouttoexplode = nil
	self.TempValues = {}
	self.Block_Use = nil
	self.ProgibTarget = nil
	self:SetStamina(100)
	self.SCP173Effect = false
	self.DamageModifier = 1
	self:SetModel("")
	self:SetModelScale(1)
	self:SetInDimension(false)
	self:ClearBoneMerges()
	self.GASMASK_Ready = true
	self:GASMASK_SetEquipped(false)
	self:ClearBodyGroups()
	self:SetSkin(0)
	self.BaseStats = nil
	self:SetNWString("AbilityName", "")
	self.KACHOKABILITY = nil
	self.HeadResist = 0
	self.BodyResist = 0
	self:StopForcedAnimation()
	self.HelmetBonemerge = nil
	self.ArmorBonemerge = nil
	self.HasHelmet = nil
	self.DeathAnimation = nil
	self.HasArmor = nil
	self.CanUseArmor = true
	self.handsmodel = nil
	
	self:UnSpectate()
	self:Spawn()
	self:SetSolid(SOLID_BBOX)
	self:PhysicsInit(SOLID_BBOX)
	self:RemoveSolidFlags(FSOLID_NOT_SOLID)
	self:SetMoveType(MOVETYPE_WALK)
	self:SetRenderMode(RENDERMODE_NORMAL)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:GodDisable()
	self:SetNoDraw(false)
	self:SetMaxSlots(8)
	self:SetNoTarget(false)
	self:SetupHands()
	self:RemoveAllAmmo()
	self:StripWeapons()
	self.canblink = true
	self.noragdoll = false
	self.scp1471stacks = 1
	self:RemoveEffects(EF_NODRAW)
	self:SetSpecialCD(0)
	self:Freeze(false)
	self:SetPos(savepos)
	saveangles.r = 0
	self:SetEyeAngles(saveangles)
	self:SetAngles(saveangles2)
	self:UpdateArmorIndicator("Everything", false)
end

function GM:PlayerShouldTaunt(ply, taunt) return false end

util.AddNetworkString("NTF_Intro")

function mply:AddToMVP(type, val)
	if self:GTeam() == TEAM_ARENA then return end
	if not MVPStats or not MVPStats[type] then return end

	local sid = self:SteamID64()
	MVPStats[type][sid] = math.floor((MVPStats[type][sid] or 0) + val)
end

function mply:NTF_Scene()
	local ntf_grunt = ents.Create("ntf_cutscene_2")
	ntf_grunt:SetOwner(self)
	ntf_grunt:Spawn()
end

local spy_teams = {
	[TEAM_CHAOS] = true,
	[TEAM_DZ] = true,
	[TEAM_GOC] = true,
	[TEAM_CLASSD] = true,
	[TEAM_USA] = true,
}

function mply:DonateAmbition()
	if not IsValid(self) then return end
	if (self:HasPremiumSub() or self:IsDonator()) and not self.AlreadySwapedDefaultRole then
		if not preparing then return end
		if table.HasValue(BREACH.DonatorLim, self:SteamID64()) then return end
		self.CanSwitchRole = true

		if self:SteamID64() == "76561198376629308" or self:SteamID64() == "76561198420505102" or self:SteamID64() == "76561199065187455" then
			self:ConCommand("br_donator_role_select")
		else
			BREACH.SendClientEvent(self, "select_default_class")
		end

		timer.Simple(30, function()
			if IsValid(self) then self.CanSwitchRole = false end
		end)
	end
end

local gloves_bl_models = {
	["models/cultist/humans/class_d/shaky/class_d_bor_new.mdl"] = true,
	["models/cultist/humans/class_d/shaky/class_d_fat_new.mdl"] = true,
	["models/cultist/humans/class_d/class_d_cleaner.mdl"] = true,
	["models/cultist/humans/class_d/class_d_cleaner_female.mdl"] = true,
	["models/cultist/humans/sci/scientist_female.mdl"] = true
}

function mply:SetupGloves()
	if not IsValid(self) then return end
	if LEFACY_GLOVES_BOY and LEFACY_GLOVES_BOY[self:SteamID64()] then
		local t = self:GTeam()
		if t ~= TEAM_SPEC and t ~= TEAM_SCP and t ~= TEAM_ARENA and t ~= TEAM_NAZI and t ~= TEAM_AMERICA and t ~= TEAM_RESISTANCE and t ~= TEAM_COMBINE and t ~= TEAM_AR and t ~= TEAM_ALPHA1 and not gloves_bl_models[self:GetModel()] then 
			local hands = self:GetHands()
			if IsValid(hands) then
				hands:SetModel(string.Replace(hands:GetModel(), "/cultist/", "/skins_hands/"))
			end
			
			for k1, v1 in ipairs(self:GetMaterials()) do
				if v1 == "models/weapons/c_arms_combine/c_arms_combinesoldier_hands" or v1 == "models/all_scp_models/class_d/arms" or v1 == "models/all_scp_models/class_d/arms_b" or v1 == "models/all_scp_models/shared/f_hands/f_hands_black" or v1 == "models/all_scp_models/shared/f_hands/f_hands_white" or v1 == "models/all_scp_models/sci/sci_hands" or v1 == "models/all_scp_models/shared/f_hands/f_hands_gloves" then
					self:SetSubMaterial(k1 - 1, "models/imperator/female/no_draw")
				end
			end
		end
	end
end

local function ApplyCustomDonatorHead(ply)
	local face = PickFaceSkin(false, ply:SteamID64())
	ply.FaceTexture = face
	local mdl = PickHeadModel(ply:SteamID64(), false)
	local ent = Bonemerge(mdl, ply)
	
	if mdl:find("balaclava") or mdl:find("male_head") then
		if CORRUPTED_HEADS and CORRUPTED_HEADS[mdl] then
			ent:SetSubMaterial(1, face)
		else
			ent:SetSubMaterial(0, face)
		end
	end
end

local DONATOR_HEADGEAR = {
	["76561198376629308"] = "models/cultist/humans/obr/head_gear/helmet_beret.mdl",
	["76561198336701519"] = "models/cultist/humans/fbi/head_gear/fbi_agent_hat.mdl",
	["76561199133126422"] = "models/cultist/humans/russian/head_gear/helmet_1.mdl",
	["76561198966614836"] = "models/imperator/heads/male/hair/mhair_21.mdl",
}

local BALD_DONATORS = {
	["76561198867007475"] = true,
	["76561198342205739"] = true,
}

local function ApplyCustomHair(ply, role, isblack)
	local sid = ply:SteamID64()
	local headItem
	local isHairAllowed = (role.hairm or role.blackhairm)

	if RXSEND_FEMBOY and RXSEND_FEMBOY[sid] then
		if isHairAllowed then
			headItem = Bonemerge("models/cultist/heads/male/hair/hair_astolfo.mdl", ply)
		end
	elseif DONATOR_HEADGEAR[sid] then
		local mdl = DONATOR_HEADGEAR[sid]
		if mdl:find("helmet") or mdl:find("hat") or isHairAllowed then
			headItem = Bonemerge(mdl, ply)
		end
	elseif BALD_DONATORS[sid] then
		-- Bald
	else
		if isHairAllowed and math.random(1, 22) > 1 then
			if (role.hairm and not isblack) or role.blackhairm then
				headItem = Bonemerge("models/imperator/heads/male/hair/mhair_" .. math.random(1, 22) .. ".mdl", ply)
			end
		end
	end

	if IsValid(headItem) then
		local mdl = headItem:GetModel() or ""
		if not (mdl:find("helmet") or mdl:find("hat")) then
			if LEGACY_HAIRCOLOR and LEGACY_HAIRCOLOR[sid] then
				ply:SetNWString("HairColor", tostring(Color(ply:GetNWInt("HairColor_R"), ply:GetNWInt("HairColor_G"), ply:GetNWInt("HairColor_B"))))
			else
				ply:SetNWString("HairColor", tostring(table.Random{Color(73, 73, 73), Color(180, 180, 180), Color(206, 167, 84)}))
			end
			headItem:SetColor(string.ToColor(ply:GetNWString("HairColor")))
		end
	end
end

local function ApplyCustomDonatorOverrides(ply, roleName)
	local sid = ply:SteamID64()
	if sid ~= "76561198867007475" and sid ~= "76561198342205739" then return end

	if roleName == "Security Shock trooper" then
		ply:SetBodygroup(2, 0)
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel() == "models/cultist/humans/security/head_gear/helmet_glass.mdl" then
				v:Remove()
			elseif v:GetModel() == "models/cultist/humans/balaclavas_new/balaclava_full.mdl" then
				v:SetModel("models/cultist/humans/balaclavas_new/head_balaclava_month.mdl")
			end
		end
	elseif roleName == "Security Sergeant" then
		ply:SetBodygroup(4, 0) ply:SetBodygroup(5, 0) ply:SetBodygroup(6, 0) ply:SetBodygroup(3, 4)
	elseif roleName == "Security Specialist" or roleName == "Security Officer" or roleName == "Security Warden" or roleName == "Security Chief" then
		if roleName == "Security Officer" then ply:SetBodygroup(1, 0)
		elseif roleName == "Security Specialist" then ply:SetBodygroup(2, 0) end
		
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel() == "models/cultist/humans/balaclavas_new/balaclava_half.mdl" then v:Remove() end
		end
		ApplyCustomDonatorHead(ply)
	elseif roleName == "Head of Security" then
		ply:SetBodygroup(0, 2) ply:SetBodygroup(1, 1) ply:SetBodygroup(4, 1) ply:SetBodygroup(3, 1)
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel() == "models/cultist/humans/balaclavas_new/balaclava_half.mdl" then v:Remove() end
		end
		ApplyCustomDonatorHead(ply)
	elseif roleName == "MTF Specialist" or roleName == "MTF Shock trooper" then
		if roleName == "MTF Specialist" then ply:SetBodygroup(0, 2) ply:SetBodygroup(3, 0) ply:SetBodygroup(5, 1)
		elseif roleName == "MTF Shock trooper" then ply:SetBodygroup(7, 1) end
		
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel() == "models/cultist/humans/mog/heads/head_main.mdl" then
				v:SetModel("models/cultist/humans/balaclavas_new/head_balaclava_month.mdl")
			end
		end
	elseif roleName == "MTF Juggernaut" or roleName == "MTF Guard" or roleName == "CI Commander" then
		if roleName == "CI Commander" then ply:SetBodygroup(1, 0) end
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel() == "models/cultist/humans/balaclavas_new/balaclava_full.mdl" then
				if roleName == "CI Commander" then v:Remove() else v:SetModel("models/cultist/humans/balaclavas_new/head_balaclava_month.mdl") end
			end
		end
		if roleName == "CI Commander" then ApplyCustomDonatorHead(ply) end
	elseif roleName == "NTF Commander" then
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel() == "models/cultist/humans/balaclavas_new/head_balaclava_month.mdl" then v:Remove() end
		end
		ApplyCustomDonatorHead(ply)
	end
end

local function HandleGOCSpyAppearance(ply, roleName, isblack)
	local sid = ply:SteamID64()
	if roleName ~= "GOC Spy" then return end

	local goc_status = 1
	if RXSEND_FEMALE_GOC and RXSEND_FEMALE_GOC[sid] and RXSEND_FAT_GOC and RXSEND_FAT_GOC[sid] then
		goc_status = math.random(2, 3)
	elseif RXSEND_FEMALE_GOC and RXSEND_FEMALE_GOC[sid] then
		goc_status = 2
	elseif RXSEND_FAT_GOC and RXSEND_FAT_GOC[sid] then
		goc_status = 3
	end

	if goc_status == 2 then
		ply:SetModel("models/cultist/humans/class_d/class_d_female.mdl")
		if ply.BoneMergedEnts then
			for _, bnm in ipairs(ply.BoneMergedEnts) do if IsValid(bnm) then bnm:Remove() end end
		end
		
		local face = PickFaceSkin(isblack, sid, true)
		ply.FaceTexture = face
		local mdl = PickHeadModel(sid, true)
		local ent = Bonemerge(mdl, ply)
		
		if CORRUPTED_HEADS and CORRUPTED_HEADS[mdl] then ent:SetSubMaterial(1, face) else ent:SetSubMaterial(0, face) end
		timer.Simple(4, function() if IsValid(ply) then ply:SetSkin(0) end end)
		
		ApplyCustomHair(ply, {hairm = true}, isblack)
		ply:SetFemale(true)
	elseif goc_status == 3 then
		ply:SetModel("models/cultist/humans/class_d/shaky/class_d_fat_new.mdl")
		if ply.BoneMergedEnts then
			for _, bnm in ipairs(ply.BoneMergedEnts) do if IsValid(bnm) then bnm:Remove() end end
		end
		Bonemerge("models/cultist/heads/male/fat_heads/male_fat_01.mdl", ply)
		ply:SetFemale(false)
	end
end

local function SendClientAction(ply, action)
	BREACH.SendClientEvent(ply, "action", {name = action})
end

local function PlayRoleIntro(ply, role, nointro)
	if nointro then return end
	local team = role.team
	
	if team == TEAM_DZ and not role.name:find("Spy") then
		SendClientAction(ply, "SHStart")
		ply:Freeze(true) ply.MovementLocked = true
		timer.Simple(8, function() if IsValid(ply) then ply.MovementLocked = nil ply:Freeze(false) end end)
	elseif team == TEAM_GUARD then
		if role.model == "models/cultist/humans/mog/mog.mdl" then SendClientAction(ply, "TGStart") else SendClientAction(ply, "MOGStart") end
		ply.canttalk = true
		timer.Simple(27, function() if IsValid(ply) then ply.canttalk = false end end)
	elseif team == TEAM_GRU then
		SendClientAction(ply, "GRUCutscene")
		timer.Simple(22, function() if IsValid(ply) then ply:Freeze(true) ply.MovementLocked = true end end)
	elseif team == TEAM_AR then
		SendClientAction(ply, "ARStart")
	elseif team == TEAM_NTF then 
		SendClientAction(ply, "NTFStart")
		ply:Freeze(true) ply.MovementLocked = true
	elseif team == TEAM_GOC and not role.name:find("Spy") then
		SendClientAction(ply, "GOCStart")
		ply:Freeze(true) ply.MovementLocked = true
		timer.Simple(8, function() if IsValid(ply) then ply.MovementLocked = nil ply:Freeze(false) end end)
	elseif team == TEAM_QRT or team == TEAM_OSN then
		SendClientAction(ply, "OBRStart")
		ply:Freeze(true) ply.MovementLocked = true
		timer.Simple(8, function() if IsValid(ply) then ply.MovementLocked = nil ply:Freeze(false) end end)
	elseif team == TEAM_ALPHA1 then
		SendClientAction(ply, "ALPHA1Start")
		ply:Freeze(true) ply.MovementLocked = true
		timer.Simple(8, function() if IsValid(ply) then ply.MovementLocked = nil ply:Freeze(false) end end)
	elseif team == TEAM_CBG then
		SendClientAction(ply, "CRBStart")
		ply:Freeze(true) ply.MovementLocked = true
		timer.Simple(8, function() if IsValid(ply) then ply.MovementLocked = nil ply:Freeze(false) end end)
	elseif team == TEAM_USA and not role.name:find("Spy") then
		if ply:GetModel() == "models/cultist/humans/fbi/fbi_agent.mdl" then SendClientAction(ply, "SHTURMONPStart") else SendClientAction(ply, "ONPStart") end
	elseif team == TEAM_CHAOS and not role.name:find("Spy") then
		SendClientAction(ply, "CutScene")
	elseif team == TEAM_COTSK then
		SendClientAction(ply, "CultStart")
		timer.Simple(8, function() if IsValid(ply) then ply.MovementLocked = nil ply:Freeze(false) end end)
	end
end

function mply:ApplyRoleStats(role, nointro)
	if not role then return end

	self:SetSubMaterial() 
	self.Infected409 = false
	local sid = self:SteamID64()
	timer.Remove("SCP409Phase1_" .. sid)
	timer.Remove("SCP409Phase2_" .. sid)
	timer.Remove("SCP409Phase3_" .. sid)
	timer.Remove("SCP1025COLD" .. sid)
	timer.Remove("Death_Scene" .. sid)

	self:SetNWInt("TASKS_Hell", 0)
	self:SetCrouching(false)
	self:ResetHull()
	self:SetViewOffsetDucked(duck_offset)
	self:SetViewOffset(stand_offset)
	self:ConCommand("-forward")
	self:DropObject() 
	net.Start("ots_off") net.Send(self) 
	self.IsInThirdPerson = false 
	BREACH.SendClientEvent(self, "flash_window")
	self:StripWeapons()

	if role.name == "CI Spy" then
		role = table.Copy(role)
		local values = BREACH.ChaosSpy_CanBe
		local val = values[math.random(1, #values)]
		local tab
		for _, v in ipairs(BREACH_ROLES.SECURITY.security.roles) do
			if v.name == val then tab = v break end
		end
		if tab then
			role.weapons, role.headgear, role.head = tab.weapons, tab.headgear, tab.head
			role.walkspeed, role.runspeed, role.jumppower = tab.walkspeed, tab.runspeed, tab.jumppower
			role.keycard, role.usehead = tab.keycard, tab.usehead
			role.randomizehead, role.randomizeface, role.ammo = tab.randomizehead, tab.randomizeface, tab.ammo
			for i = 0, 9 do role["bodygroup"..i] = tab["bodygroup"..i] end
		end
	end

	if role.ability ~= nil then
		self:SetNWString("AbilityName", role.ability[1])
		self.AbilityTAB = role.ability
		net.Start("SpecialSCIHUD")
			net.WriteString(role.ability[1])
			net.WriteUInt(role.ability[2], 9)
			net.WriteString(role.ability[3])
			net.WriteString(role.ability[4])
			net.WriteBool(role.ability[5])
		net.Send(self)
	end
	self:SetSpecialMax(role.ability_max or 0)
	self:SetRoleName(role.name)
	self.BodyResist = role.bodyresist or 0
	self.HeadResist = role.headresist or 0
	self.recoilmultiplier = 1 
	self:SetGTeam(role.team)

	timer.Simple(15, function() if IsValid(self) then self:DonateAmbition() end end)

	if CanBeNeutral and CanBeNeutral(self) then self:AddToStatistics("l:pacifist", 50) end

	if role.weapons then
		for _, v in ipairs(role.weapons) do
			if v ~= "br_holster" and v ~= "weapon_cqc" and v ~= "weapon_checker" and v ~= "weapon_cannibal" then
				local itemtable = {class = v}
				if v == "item_tazer" then itemtable.Clip = 15 end
				if v == "weapon_revolver357" then itemtable.Drum = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0} end
				if v:find("item_medkit_") then itemtable.Heal_Left = weapons.GetStored(v).Heal_Left end
				self.Inventory["Items"][InventoryGetFreeSlot(self)] = itemtable
			end
		end
	end

	if role.keycard and role.keycard ~= "" then
		self.Inventory["Items"][InventoryGetFreeSlot(self)] = {class = "breach_keycard_" .. role.keycard}
	end

	if role.ammo then
		for _, v in ipairs(role.ammo) do
			local wep_class = v[1]
			local ammo_amount = v[2]
			local wep_stored = weapons.GetStored(wep_class)
			if wep_stored and wep_stored.Primary and wep_stored.Primary.Ammo and wep_stored.Primary.Ammo ~= "none" then
				local ammo_type = wep_stored.Primary.Ammo
				local ammo_id = isstring(ammo_type) and game.GetAmmoID(ammo_type) or ammo_type
				if ammo_id and ammo_id ~= -1 then
					self:GiveAmmo(ammo_amount, ammo_id, true)
				end
			end
		end
	end

	self.ScaleDamage = role.damage_modifiers or {[HITGROUP_HEAD]=1, [HITGROUP_CHEST]=1, [HITGROUP_LEFTARM]=1, [HITGROUP_RIGHTARM]=1, [HITGROUP_STOMACH]=1, [HITGROUP_GEAR]=1, [HITGROUP_LEFTLEG]=1, [HITGROUP_RIGHTLEG]=1}
	self:SetNWFloat("HeadshotMultiplier", self.ScaleDamage[HITGROUP_HEAD])
	
	self:SetHealth(role.health)
	self:SetMaxHealth(role.health)
	self:SetArmor(role.armor or 0)
	
	local run = role.runspeed or 1
	self:SetWalkSpeed(100)
	self:SetCrouchedWalkSpeed(1)
	self:SetSlowWalkSpeed(70)
	self:SetRunSpeed(231 * run)
	self.StartedPlayAt = CurTime() + 100
	self.OriginalWalkSpeed = self:GetWalkSpeed()
	self.OriginalRunSpeed = self:GetRunSpeed()
	self:SetJumpPower(230)
	self:Flashlight(false)
	self:AllowFlashlight(false)
	self.RequiredLevelRole = role.level
	self.VoicePitch = math.random(79, 120)
	self:SetStaminaScale(role.stamina or 1)

	if role.genders ~= nil then
		self:SetFemale(table.Random(role.genders))
	elseif role.premium_female and self:IsPremium() then
		self:SetFemale(math.random(1, 2) == 1)
		if self.SpawnOnlyMale then self:SetFemale(false) elseif self.SpawnOnlyFemale then self:SetFemale(true) end
	else
		self:SetFemale(false)
	end

	if role.team == TEAM_CLASSD and role.fmodel then
		if math.random(1, 100) <= 20 then self:SetFemale(true) end
	end
	if role.fmodel and self.SpawnOnlyMale then self:SetFemale(false) end
	
	self:SetSkin(role.skin or 0)

	if sid == "76561198867007475" or sid == "76561198342205739" then self:SetFemale(false) end

	local isblack = (math.random(1, 3) == 1)
	if sid == "76561198867007475" or sid == "76561198342205739" or role.white then isblack = false end

	if self:GetFemale() then
		self:SetModel(role.fmodel or (role.premium_female and self:IsPremium() and role.premium_female) or role.model)
		local face = PickFaceSkin(isblack, sid, true)
		self.FaceTexture = face
		
		if not role.premium_female then
			if role.usehead then
				local mdl = role.randomizehead and PickHeadModel(sid, true) or "models/cultist/heads/female/female_head_1.mdl"
				local ent = Bonemerge(mdl, self)
				if CORRUPTED_HEADS and CORRUPTED_HEADS[mdl] then ent:SetSubMaterial(1, face) else ent:SetSubMaterial(0, face) end
			end
			if role.headf then Bonemerge(table.Random(role.headf), self) end
			if role.hairf then ApplyCustomHair(self, role, isblack) end
		else
			if role.female_head then Bonemerge(table.Random(role.female_head), self) end
			if role.female_headgear then
				if sid == "76561198376629308" then Bonemerge("models/cultist/humans/obr/head_gear/helmet_beret.mdl", self)
				elseif sid == "76561198336701519" then Bonemerge("models/cultist/humans/fbi/head_gear/fbi_agent_hat.mdl", self)
				elseif sid == "76561199133126422" then Bonemerge("models/cultist/humans/russian/head_gear/helmet_1.mdl", self)
				else Bonemerge(istable(role.female_headgear) and table.Random(role.female_headgear) or role.female_headgear, self) end
			end
		end

		if (self:GetModel() == "models/cultist/humans/class_d/class_d_female.mdl" or self:GetModel() == "models/cultist/humans/class_d/class_d_cleaner_female.mdl") and isblack then
			self:SetSkin(1)
		end
		self:SetNamesurvivor(name_f[math.random(1, #name_f)] .. " " .. surname[math.random(1, #surname)])
	else
		if self.sexychemist and (RXSEND_SEXY_CHEMISTS and RXSEND_SEXY_CHEMISTS[sid] or self:IsSuperAdmin()) and role.name == "MTF Chemist" then
			self:SetModel("models/cultist/humans/mog/sexy_mog_hazmat.mdl")
		elseif not self:GetFemale() and RXSEND_BIGASS and RXSEND_BIGASS[sid] and role.name == "Security Chief" then
			self:SetModel("models/cultist/humans/security/thiccboy.mdl")
		else
			self:SetModel(role.model)
		end

		local face = PickFaceSkin(isblack, sid)
		self.FaceTexture = face
		if self:GetModel():find("class_d_bor") then isblack = (math.random(1, 2) == 1) end

		if (self:GetModel() == "models/cultist/humans/class_d/class_d.mdl" or self:GetModel() == "models/cultist/humans/fbi/fbi_agent.mdl" or self:GetModel() == "models/cultist/humans/class_d/class_d_cleaner.mdl" or self:GetModel():find("class_d_bor")) and isblack then
			self:SetSkin(1)
		end

		if role.head ~= nil then
			local mdl = istable(role.head) and role.head[math.random(1, #role.head)] or role.head
			local ent = Bonemerge(mdl, self)
			if self:GetModel():find("class_d_bor") and isblack then ent:SetSkin(1) end
			if mdl:find("balaclava") or mdl:find("male_head") then
				if CORRUPTED_HEADS and CORRUPTED_HEADS[mdl] then ent:SetSubMaterial(1, face) else ent:SetSubMaterial(0, face) end
			end
		end

		if role.usehead then
			local mdl = role.randomizehead and PickHeadModel(sid) or "models/cultist/heads/male/male_head_1.mdl"
			local ent = Bonemerge(mdl, self)
			if CORRUPTED_HEADS and CORRUPTED_HEADS[mdl] then ent:SetSubMaterial(1, face) else ent:SetSubMaterial(0, face) end
		end

		ApplyCustomHair(self, role, isblack)

		if role.team == TEAM_GRU then self:SetNamesurvivor(name_ru[math.random(1, #name_ru)] .. " " .. surname_ru[math.random(1, #surname_ru)])
		elseif role.team == TEAM_COMBINE then self:SetNamesurvivor("OTA.SOLDIER - " .. math.random(1000, 9999))
		elseif role.team == TEAM_AR then self:SetNamesurvivor((role.skin == 1 and "AR.LEADER - " or "AR.DROID - ") .. math.random(1000, 9999))
		elseif role.head == "models/lazlo/gordon_freeman.mdl" then self:SetNamesurvivor("Gordon Freeman")
		elseif role.model == "models/imperator/humans/o5/o5_4.mdl" then self:SetNamesurvivor(" ")
		else self:SetNamesurvivor(name_eng[math.random(1, #name_eng)] .. " " .. surname[math.random(1, #surname)]) end
	end

	HandleGOCSpyAppearance(self, role.name, isblack)

	self.Stamina = role.stamina and (100 * role.stamina) or 100
	if role.bodygroups then self:SetBodyGroups(role.bodygroups[1]) end
	for i = 0, 20 do self:SetBodygroup(i, role["bodygroup"..i] or 0) end
	
	if role.hackerhat then ApplyBonemergeHackerHat(role.hackerhat, self) end
	if role.random_accessories then
		for i = 0, 13 do
			if role.random_accessories["bodygroup"..i] then self:SetBodygroup(i, math.random(role.random_accessories["bodygroup"..i][1], role.random_accessories["bodygroup"..i][2])) end
		end
	end

	if not self:GetFemale() and sid ~= "76561198376629308" and sid ~= "76561198336701519" and sid ~= "76561199133126422" then
		if role.headgearrandom then Bonemerge(table.Random(role.headgearrandom), self) end
		if role.headgear then
			local model = Bonemerge(role.headgear, self)
			if role.random_accessories and role.random_accessories["headgears"] then
				for i = 0, 8 do
					if role.random_accessories["headgears"]["bodygroup"..i] then
						model:SetBodygroup(i, math.random(role.random_accessories["headgears"]["bodygroup"..i][1], role.random_accessories["headgears"]["bodygroup"..i][2]))
					end
				end
			end
		end
	end

	if role.team == TEAM_SPECIAL then self:SetNamesurvivor(self:GetRoleName() .. " " .. surname[math.random(1, #surname)]) end

	net.Start("RolesSelected") net.Send(self)
	self:SetupHands()
	if role.maxslots then self:SetNWInt("InventoryMaxSlots", role.maxslots) end

	ApplyCustomDonatorOverrides(self, role.name)

	if role.name == "O5-4: 'Ambassador'" then
		timer.Simple(1, function() if IsValid(self) then self:SetPos(Vector(-2872.64, 4938.52, 0.03)) end end)
	end

	PlayRoleIntro(self, role, nointro)

	local spy_teams = {[TEAM_CHAOS] = true, [TEAM_DZ] = true, [TEAM_GOC] = true, [TEAM_CLASSD] = true, [TEAM_USA] = true}
	if spy_teams[role.team] then
		net.Start("Special_outline") net.WriteUInt(role.team, 16) net.Send(self)
	end

	self:SetNWEntity("RagdollEntityNO", NULL)
	self:SetNWBool("HasPestilence", math.random(1, 100) <= 80)
	if role.team == TEAM_DZ then self:SetNWBool("HasPestilence", false) end

	if sid == "76561198256901202" then Bonemerge("models/imperator/yshki.mdl", self) end

	local copy_table = table.Copy(self.Inventory)
	for _, v in pairs(copy_table["Items"]) do
		if v.class == "item_drink_294" then v.effect = nil v.scp294 = nil end
	end
	net.Start("SendInventoryDataOper") net.WriteTable(copy_table) net.Send(self)

	self.JustSpawned = true
	self:Give("br_holster", true)
	self.JustSpawned = false
	BREACH.SendClientEvent(self, "select_weapon", {class = "br_holster"})
end

function mply:SexTest()
	local d = DamageInfo()
	d:SetInflictor(self:GetActiveWeapon()) d:SetAttacker(self)
	d:SetDamageType(DMG_BULLET) d:SetDamage(100)
	self:TakeDamageInfo(d)
end

function mply:SetClassD() self:SetRoleBestFrom("classds") end
function mply:SetResearcher() self:SetRoleBestFrom("researchers") end

function mply:SetChaosSpy()
	self:SetupNormal()
	self:ApplyRoleStats(BREACH_ROLES.MTF.mtf.roles[table.Random({1, 2, 4, 6})], true)
	self:SetGTeam(TEAM_CHAOS)
	self:SetRoleName(role.SECURITY_Spy)
	self:BreachGive("cw_kk_ins2_nade_c4")
end

function mply:SetRoleBestFrom(roleKey)
	local thebestone = nil
	for _, v in ipairs(ALLCLASSES[roleKey]["roles"]) do
		local can = true
		if v.customcheck and v.customcheck(self) == false then can = false end
		local using = 0
		for _, pl in player.Iterator() do
			if pl:GetRoleName() == v.name then using = using + 1 end
		end
		if using >= v.max then can = false end
		if can then
			if self:GetLevel() >= v.level then
				if not thebestone or thebestone.level < v.level then thebestone = v end
			end
		end
	end
	if not thebestone then thebestone = ALLCLASSES[roleKey]["roles"][1] end
	if thebestone == ALLCLASSES["classds"]["roles"][4] and player.GetCount() < 4 then
		thebestone = ALLCLASSES["classds"]["roles"][3]
	end
	if GetConVar("br_dclass_keycards"):GetInt() ~= 0 then
		if thebestone == ALLCLASSES["classds"]["roles"][1] then thebestone = ALLCLASSES["classds"]["roles"][2] end
	else
		if thebestone == ALLCLASSES["classds"]["roles"][2] then thebestone = ALLCLASSES["classds"]["roles"][1] end
	end
	self:SetupNormal()
	self:ApplyRoleStats(thebestone)
end

function mply:IsActivePlayer() return self.Active end

hook.Add("KeyPress", "keypress_spectating", function(ply, key)
	if ply:GTeam() ~= TEAM_SPEC then return end
	if key == IN_ATTACK then ply:SpectatePlayerLeft()
	elseif key == IN_ATTACK2 then ply:SpectatePlayerRight()
	elseif key == IN_RELOAD then ply:ClearSpectateTarget() end
end)

function mply:SpectatePlayerRight()
	if not self:Alive() then return end
	self:SetNoDraw(true)
	local allply = GetAlivePlayers()
	if #allply == 0 then self:ClearSpectateTarget() return end
	if #allply == 1 then 
		if self:GetObserverMode() == OBS_MODE_ROAMING then self:Spectate(OBS_MODE_CHASE) end
		self:SpectateEntity(allply[1]) return 
	end
	
	self.SpecPly = (self.SpecPly or 0) - 1
	if self.SpecPly < 1 then self.SpecPly = #allply end
	if self:GetObserverMode() == OBS_MODE_ROAMING then self:Spectate(OBS_MODE_CHASE) end
	
	for k, v in ipairs(allply) do
		if k == self.SpecPly then
			if v:GetMoveType() == MOVETYPE_NOCLIP then
				self.SpecPly = self.SpecPly - 1
				continue
			end
			self:SpectateEntity(v)
		end
	end
end

function mply:SpectatePlayerLeft()
	if not self:Alive() then return end
	self:SetNoDraw(true)
	local allply = GetAlivePlayers()
	if #allply == 0 then self:ClearSpectateTarget() return end
	if #allply == 1 then 
		if self:GetObserverMode() == OBS_MODE_ROAMING then self:Spectate(OBS_MODE_CHASE) end
		self:SpectateEntity(allply[1]) return 
	end
	
	self.SpecPly = (self.SpecPly or 0) + 1
	if self.SpecPly > #allply then self.SpecPly = 1 end
	if self:GetObserverMode() == OBS_MODE_ROAMING then self:Spectate(OBS_MODE_CHASE) end
	
	for k, v in ipairs(allply) do
		if k == self.SpecPly then
			if v:GetMoveType() == MOVETYPE_NOCLIP then
				self.SpecPly = self.SpecPly + 1
				continue
			end
			self:SpectateEntity(v)
		end
	end
end

function GM:EntityTakeDamage(target, dmginfo)
	if IsValid(target) and dmginfo:GetDamage() > 1 and dmginfo:IsBulletDamage() and target:IsPlayer() then
		if not target:IsEFlagSet(EFL_NO_DAMAGE_FORCES) then
			target:AddEFlags(EFL_NO_DAMAGE_FORCES) 
		end
	end
end

function mply:ChangeSpecMode()
	if not self:Alive() or self:GTeam() ~= TEAM_SPEC then return end
	self:SetNoDraw(true)
	if self:GetObserverMode() == OBS_MODE_CHASE then
		self:ClearSpectateTarget()
	else
		local allply = GetAlivePlayers()
		if #allply > 0 then
			self:Spectate(OBS_MODE_CHASE)
			self:SpectatePlayerLeft()
		else
			self:ClearSpectateTarget()
		end
	end
end

hook.Add("Think", "Spec_Think", function()
	if CLIENT then return end
	for _, ply in ipairs(gteams.GetPlayers(TEAM_SPEC) or {}) do
		local observer = ply:GetObserverTarget()
		if IsValid(observer) then
			if observer:IsPlayer() then
				if observer:GTeam() == TEAM_SPEC or not observer:Alive() or observer:Health() <= 0 then
					ply:ClearSpectateTarget()
				end
			else
				ply:ClearSpectateTarget()
			end
		end
	end
end)

function mply:SaveExp() self:SetBreachData("exp", self:GetNEXP()) end
function mply:SaveLevel() self:SetBreachData("level", self:GetNLevel()) end

function mply:AddExp(amount)
	if not self.GetNEXP then return end
	local requiredexp = self:RequiredEXP()
	if self:GetNEXP() + amount >= requiredexp then
		self:SetNLevel(self:GetNLevel() + 1) self:SaveLevel()
		self:SetNEXP(0) self:SaveExp()
		self:RXSENDNotify("l:levelup ", Color(255,0,0), self:GetNLevel())
	else
		self:SetNEXP(self:GetNEXP() + amount) self:SaveExp()
	end
end

function mply:AddLevel(amount)
	if not self.GetNLevel then player_manager.RunClass(self, "SetupDataTables") end
	if self.GetNLevel and self.SetNLevel then
		self:SetNLevel(self:GetNLevel() + amount) self:SaveLevel()
	elseif self.SetNLevel then
		self:SetNLevel(0)
	else
		ErrorNoHalt("Cannot set the exp, SetNLevel invalid")
	end
end

function mply:AddNEscapes(amount) end
function mply:AddNDeaths(amount) end
function mply:AddElo(amount) end

hook.Add("PlayerAmmoChanged", "checkthisshit", function(ply, ammoID, oldCount, newCount)
	if ammoID == 3 and oldCount == 0 and newCount == 24 then ply:SetAmmo(0, ammoID) end
end)

function mply:SetActive(active)
	self.ActivePlayer = active
	if not gamestarted then CheckStart() end
end

function mply:PlayGestureSequence(sequence, slot, autokill, cycle)
	if isstring(sequence) then sequence = self:LookupSequence(sequence) end
	autokill = autokill == nil and true or autokill
	slot = slot or GESTURE_SLOT_CUSTOM
	cycle = cycle or 0

	self:AddVCDSequenceToGestureSlot(slot, sequence, cycle, autokill)
	local str = self:GetSequenceName(sequence)

	net.Start("GestureClientNetworking")
		net.WriteEntity(self)
		net.WriteString(str)
		net.WriteUInt(slot, 3)
		net.WriteBool(autokill)
		net.WriteFloat(cycle)
	net.Broadcast()
end

function mply:StopGestureSlot(gest)
	self:AnimResetGestureSlot(gest)
	net.Start("StopGestureClientNetworking")
		net.WriteEntity(self)
		net.WriteUInt(gest, 3)
	net.Broadcast()
end

function mply:SetForcedAnimation(sequence, endtime, startcallback, finishcallback, stopcallback, cantmove)
	if sequence == false then self:StopForcedAnimation() return end
	if SERVER then
		local send_seq
		if isstring(sequence) then 
			send_seq = sequence sequence = self:LookupSequence(sequence)
		else send_seq = self:GetSequenceName(sequence) end
		
		self:SetCycle(0)
		self.ForceAnimSequence = sequence
		local time = endtime or self:SequenceDuration(sequence)
		self.CanMoveInAnim = (cantmove ~= true)
		
		net.Start("SHAKY_SetForcedAnimSync")
		net.WriteEntity(self) net.WriteString(send_seq) net.Broadcast()
		
		if isfunction(startcallback) then startcallback() end
		local movecheckname = "MoveCheckSeq" .. self:EntIndex()

		if not self.CanMoveInAnim then
			timer.Create(movecheckname, 0.1, 0, function()
				if not IsValid(self) then timer.Remove(movecheckname) return end
				if self:GetVelocity():Length2DSqr() > 1 then self:StopForcedAnimation() end
			end)
		end
		
		self.StopFAnimCallback = stopcallback
		timer.Create("SeqF" .. self:EntIndex(), time, 1, function()
			if IsValid(self) then
				timer.Remove(movecheckname)
				self.ForceAnimSequence = nil
				net.Start("SHAKY_EndForcedAnimSync") net.WriteEntity(self) net.Broadcast()
				self.StopFAnimCallback = nil
				if isfunction(finishcallback) then finishcallback() end
			end
		end)
	end
end

function mply:AnimatedHeal(n)
	if self:Health() >= self:GetMaxHealth() or self:Health() == 0 or self:GTeam() == TEAM_SPEC then return end
	local uniqueid = "heal_animation_" .. self:SteamID64()
	timer.Create(uniqueid, FrameTime(), n, function()
		if IsValid(self) and self:Health() > 0 and self:Health() < self:GetMaxHealth() then
			self:SetHealth(math.Approach(self:Health(), self:GetMaxHealth(), 1))
		else
			timer.Remove(uniqueid)
		end 
	end)
end

function mply:SCP409Infect(initiator, killed)
	self:ExitVehicle()
	if IsValid(initiator) and initiator:IsPlayer() then initiator = BREACH.AdminLogs:FormatPlayer(initiator) end
	
	local ragdoll
	if not self.DeathAnimation then
		BREACH.AdminLogs:Log("death_ice", { user = self, killer = initiator, icetype = 1, waskilled = killed })
		ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel(self:GetModel()) ragdoll:SetSkin(self:GetSkin())
		for i = 0, 9 do ragdoll:SetBodygroup(i, self:GetBodygroup(i)) end
		ragdoll:SetPos(self:GetPos()) ragdoll:Spawn()

		local s409 = ents.Create("ent_scp_409")
		s409:Spawn() s409:RemoveEffects(EF_NODRAW) s409.Can_Obtain = false s409:SetNoDraw(true)
		s409:SetPos(self:GetPos()) s409:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		s409.initiatedby = initiator
		ragdoll:SetMaterial("nextoren/ice_material/icefloor_01_new")

		if IsValid(ragdoll) then
			for i = 1, ragdoll:GetPhysicsObjectCount() do
				local phys = ragdoll:GetPhysicsObjectNum(i)
				local bInd = ragdoll:TranslatePhysBoneToBone(i)
				local pos, ang = self:GetBonePosition(bInd)
				if IsValid(phys) then
					phys:SetPos(pos) phys:SetAngles(ang) phys:EnableMotion(false)
				end
			end
		end
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

		if self.BoneMergedEnts then
			for _, bnmrg in ipairs(self.BoneMergedEnts) do
				if IsValid(bnmrg) and not bnmrg:GetNoDraw() then
					local b = Bonemerge(bnmrg:GetModel(), ragdoll)
					b:SetMaterial("nextoren/ice_material/icefloor_01_new")
				end
			end
		end
	else
		ragdoll = ents.Create("base_gmodentity")
		ragdoll:SetModel(self:GetModel()) ragdoll:SetSkin(self:GetSkin())
		for i = 0, 9 do ragdoll:SetBodygroup(i, self:GetBodygroup(i)) end
		ragdoll:SetPos(self:GetPos()) ragdoll:SetAngles(self:GetAngles()) ragdoll:Spawn()
		ragdoll:SetMaterial("nextoren/ice_material/icefloor_01_new")
		ragdoll:SetPlaybackRate(0) ragdoll:SetSequence(self:GetSequence()) ragdoll:SetCycle(self:GetCycle())
		ragdoll.AutomaticFrameAdvance = true ragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
		
		local s409 = ents.Create("ent_scp_409")
		s409:Spawn() s409:RemoveEffects(EF_NODRAW) s409.Can_Obtain = false s409:SetNoDraw(true)
		s409:SetPos(ragdoll:GetPos()) s409:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
	
	ParticleEffect("pillardust", ragdoll:GetPos(), Angle(0,0,0))
	ParticleEffect("steam_manhole", ragdoll:GetPos(), Angle(0,0,0))

	self:CompleteAchievement("scp409") self:AddToStatistics("l:scp409_death", -100) self:LevelBar()
	self:SetupNormal() self:SetSpectator()
end

local killzones = {
	{Vector(-4138.2, 7821.5, 2283.8), Vector(-4074.6, 4063.3, 2994.3)},
	{Vector(-2879.9, 5671.1, 2608.0), Vector(808.2, 4042.6, 3092.5)},
	{Vector(-4079.9, 7399.5, 2344.0), Vector(751.9, 7663.9, 2707.6)},
	{Vector(-2812.3, 7151.9, 2224.0), Vector(-119.3, 5008.0, 2737.9)},
	{Vector(-130.2, 5008.1, 2344.0), Vector(751.9, 6392.8, 2510.6)},
	{Vector(-608.0, -6385.7, -2456.2), Vector(-232.1, -5979.1, -2646.7)},
	{Vector(-540.5, -6309.0, -2285.7), Vector(-319.6, -6081.3, -2497.7)},
	{Vector(-3067.9, 5292.5, 2231.0), Vector(-1181.0, 5414.4, 1926.1)},
	{Vector(-49.5, 6646.1, 2297.6), Vector(929.0, 7469.2, 2442.1)},
	{Vector(6709.0, -382.4, -566), Vector(5935.0, 123.9, -213)},
	{Vector(8396.3, 2125.6, -113), Vector(7849.4, 595.5, -401)},
	{Vector(5567.8, 1621.4, -474.9), Vector(6092.3, 2239.9, -116.1)},
	{Vector(8729.1, 1719.8, -470.9), Vector(7896.0, 1136.7, -186.7)},
	{Vector(8471.9, -293.9, -471.1), Vector(7848.0, 329.1, -146.0)},
	{Vector(2776.1, 2111.9, -483.7), Vector(3660.0, 1680.0, -135.3)},
}

local allowed_zone = {
	{Vector(-2492.3, 7486.0, 2535.9), Vector(-2894.5, 7085.7, 2853.8)},
	{Vector(-258.6, 6819.7, 2499.9), Vector(240.5, 6297.6, 2831.1)},
}

local sup_killzone = {
	{Vector(-112.8, 6226.9, 91), Vector(-746.5, 4644.9, 703)},
	{Vector(-3497.6, 1888.8, 100.4), Vector(-3077.2, 2520.0, 367.1)},
	{Vector(-9043.5, 1763.5, 2649.2), Vector(-12580.3, -1221.6, 1386.3)}
}

local sups = { [TEAM_GOC] = true, [TEAM_DZ] = true, [TEAM_CHAOS] = true, [TEAM_USA] = true, [TEAM_GRU] = true, [TEAM_COTSK] = true, [TEAM_NTF] = true, [TEAM_AR] = true, [TEAM_CBG] = true }

function mply:InKillZone()
	local pos = self:GetPos()
	local team = self:GTeam()

	if self:GetRoleName() == role.NTF_Pilot and not pos:WithinAABox(Vector(-2129.4, 7543.3, 3262.6), Vector(-4133.7, 4011.1, 2056.3)) then
		return true
	end

	for _, zone in ipairs(allowed_zone) do
		if pos:WithinAABox(zone[1], zone[2]) then return false end
	end

	for _, zone in ipairs(killzones) do
		if pos:WithinAABox(zone[1], zone[2]) then return true end
	end

	if not sups[team] then
		for _, zone in ipairs(sup_killzone) do
			if pos:WithinAABox(zone[1], zone[2]) then return true end
		end
	end

	return false
end

timer.Create("Kill_Zone_check", 1, 0, function()
	for _, ply in player.Iterator() do
		if ply:GTeam() == TEAM_SPEC or not ply:Alive() or ply:Health() <= 0 or ply:IsBot() or ply:GetMoveType() == MOVETYPE_NOCLIP then continue end
		
		if ply:InKillZone() then
			local uid = "killzone" .. ply:SteamID64()
			if not timer.Exists(uid) then
				ply:RXSENDNotify("l:you_are_not_supposed_to_be_here_pt1 ", Color(255,0,0), "l:you_are_not_supposed_to_be_here_pt2")
				timer.Create(uid, 5, 1, function()
					if IsValid(ply) and ply:InKillZone() and ply:GTeam() ~= TEAM_SPEC then ply:Kill() end
				end)
			end
		end
	end
end)

local function shaky_donationcheckandsex()
	while true do
		local players = player.GetHumans()
		if not next(players) then coroutine.yield() else
			for _, ply in ipairs(players) do
				coroutine.yield()
				if IsValid(ply) then
					if ply:IsPremium() and not (RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[ply:SteamID64()]) then
						if ply:GetUserGroup() == "user" then ply:SetUserGroup("premium") end
						local prem_time = tonumber(ply:GetBreachData("premium", tostring(os.time() + 1))) or 0
						if ply:GetNWBool("Shaky_IsPremium") and prem_time <= os.time() then 
							ply:SetNWBool("Shaky_IsPremium", false)
							if ply:GetUserGroup() == "premium" then ply:SetUserGroup("user") end
							ply:RemoveBreachData("premium")
						end
					end

					if ply:IsUserGroup("donate_admin") then
						local adm_time = tonumber(ply:GetBreachData("adminka", tostring(os.time() + 1))) or 0
						if adm_time <= os.time() then
							ply:SetUserGroup("user")
							ply:RemoveBreachData("adminka")
							ply:RXSENDNotify("l:admin_expired")
						end
					end
				end
			end
		end
	end
end

local tick_delay = 31
local co
hook.Add("Think", "Shaky_Premium_Check", function()
	if engine.TickCount() % tick_delay == tick_delay - 1 then
		if not co or coroutine.status(co) == "dead" then
			co = coroutine.create(shaky_donationcheckandsex)
		end
		coroutine.resume(co)
	end
end)

hook.Add("PlayerInitialSpawn", "shaky_premium_setup", function(ply)
	BREACH.DataBaseSystem:GetData(ply:SteamID64(), "adminka", false, function(isadminactive)
		if isadminactive and ply:GetUserGroup() == "user" then ply:SetUserGroup("donate_admin") end
	end)
	BREACH.DataBaseSystem:GetData(ply:SteamID64(), "premium", false, function(ispremiumactive)
		if ispremiumactive then
			ply:SetNWBool("Shaky_IsPremium", true)
			if ply:GetUserGroup() == "user" then ply:SetUserGroup("premium") end
		end
	end)
end)

timer.Create("AntiAfk_THINK", 30, 0, function()
	local plys = player.GetAll()
	local ct = CurTime()
	for _, ply in ipairs(plys) do
		ply.ButtonClickAtTime = ply.ButtonClickAtTime or ct
		if ply:GTeam() ~= TEAM_SPEC and not ply:IsSuperAdmin() and not ply:IsBot() and ply:GetPos().z < 14700 and #plys < 30 then
			if ply.ButtonClickAtTime + (180) <= ct then
			end
		else
			ply.ButtonClickAtTime = ct
		end
	end
end)

hook.Add("PlayerButtonDown", "AntiAft_ButtonClickCheck", function(ply)
	ply.ButtonClickAtTime = CurTime()
end)

function SetPremiumSub(steamid64, amount)
	local ply = player.GetBySteamID64(steamid64)
	local time = tonumber(util.GetPData(util.SteamIDFrom64(steamid64), "premium_sub", 0)) or 0
	if time > os.time() then time = time + 24 * amount * 60 * 60 else time = os.time() + 24 * amount * 60 * 60 end
	if IsValid(ply) then ply:SetNWInt("premium_sub", time) end
	util.SetPData(util.SteamIDFrom64(steamid64), "premium_sub", time)
end

function RemovePremiumSub(steamid64, amount)
	local ply = player.GetBySteamID64(steamid64)
	local time = tonumber(util.GetPData(util.SteamIDFrom64(steamid64), "premium_sub", 0)) or 0
	if time > os.time() then time = time - 24 * amount * 60 * 60 else time = os.time() end
	if IsValid(ply) then ply:SetNWInt("premium_sub", time) end
	util.SetPData(util.SteamIDFrom64(steamid64), "premium_sub", time)
end

function mply:HasPremiumSub()
	return self:GetNWInt("premium_sub", 0) > os.time()
end

hook.Add("PlayerInitialSpawn", "PremiumSub.Initial", function(ply)
	local function SetupPDATA(key, default)
		local val = tonumber(ply:GetPData(key, default)) or default
		ply:SetPData(key, val)
		ply:SetNWInt(key, val)
	end
	SetupPDATA("premium_sub", 0)
	SetupPDATA("event_xmas_test_cd_gift", 0)
	SetupPDATA("event_xmas_candy", 0)
	SetupPDATA("event_xmas_tvar", 0)
	SetupPDATA("event_xmas_gift", 0)
	SetupPDATA("gloves_xmas", 0)
	SetupPDATA("gloves_antifurry", 0)
end)