local RunConsoleCommand = RunConsoleCommand
local tonumber = tonumber
local tostring = tostring
local Entity = Entity
local table = table
local pairs = pairs
local ipairs = ipairs
local timer = timer
local ents = ents
local hook = hook
local math = math
local util = util
local net = net
local player = player



local net_strings = {
	"WriteDerma", "PlayerBlink", "DropWeapon", "DropCurWeapon", "RequestEscorting",
	"PrepStart", "RoundStart", "PostStart", "RolesSelected", "SendRoundInfo",
	"Sound_Random", "Sound_Searching", "Sound_Classd", "Sound_Stop", "Sound_Lost",
	"UpdateRoundType", "ForcePlaySound", "EfficientPlaySound", "OnEscaped",
	"SlowPlayerBlink", "DropCurrentVest", "RoundRestart", "SpectateMode",
	"GocSpyUniform", "UpdateTime", "Effect", "NTFRequest", "ExplodeRequest",
	"ForcePlayerSpeed", "ClearData", "Restart", "AdminMode", "ShowText",
	"PlayerReady", "RecheckPremium", "689", "UpdateKeycard", "SendSound",
	"957Effect", "SCPList", "TranslatedMessage", "CameraDetect", "DropAdditionalArmor",
	"footstep_sync", "changesupport", "changesupport1", "SelectRole_Sync", "DoMe999",
	"DoMe106", "fastbuymehouse", "fastbuymehouse1"
}

for _, v in ipairs(net_strings) do
	util.AddNetworkString(v)
end

BREACH = BREACH or {}
BREACH.DonatorLim = BREACH.DonatorLim or {}
BREACH.QueuedSupports = BREACH.QueuedSupports or {}

local allowed_999 = {
	["76561198966614836"] = true,
	["76561198376629308"] = true,
	["76561198420505102"] = true,
	["76561199065187455"] = true
}

net.Receive("DoMe999", function(len, ply)
	if table.HasValue(BREACH.DonatorLim, ply:SteamID64()) then
		ply:RXSENDNotify("Превышен лимит установки роли")
		return
	end
	local target = net.ReadPlayer()
	if IsValid(target) and allowed_999[target:SteamID64()] then
		local scp_obj = GetSCP("SCP999")
		if scp_obj then
			target:SetupNormal()
			scp_obj:SetupPlayer(target)
		end
	end
end)

local allowed_106 = {
	["76561198966614836"] = true,
	["76561198867007475"] = true,
	["76561198376629308"] = true,
	["76561198420505102"] = true,
	["76561199065187455"] = true
}

net.Receive("DoMe106", function(len, ply)
	if table.HasValue(BREACH.DonatorLim, ply:SteamID64()) then
		ply:RXSENDNotify("Превышен лимит установки роли")
		return
	end
	local target = net.ReadPlayer()
	if IsValid(target) and allowed_106[target:SteamID64()] then
		local scp_obj = GetSCP("SCP106")
		if scp_obj then
			target:SetupNormal()
			scp_obj:SetupPlayer(target)
		end
	end
end)

net.Receive("DropWeapon", function(len, ply)
	local class = net.ReadString()
	if class and class ~= "" then
		ply:ForceDropWeapon(class)
	end
end)

local quicktables = {
	[TEAM_GOC] = BREACH_ROLES.GOC.goc.roles,
	[TEAM_CHAOS] = BREACH_ROLES.CHAOS.chaos.roles,
	--[TEAM_USA] = BREACH_ROLES.FBI_AGENTS.fbi_agents.roles,
	[TEAM_DZ] = BREACH_ROLES.DZ.dz.roles,
	[TEAM_NTF] = BREACH_ROLES.NTF.ntf.roles,
	--[TEAM_COTSK] = BREACH_ROLES.COTSK.cotsk.roles,
	--[TEAM_GRU] = BREACH_ROLES.GRU.gru.roles,
	--[TEAM_AR] = BREACH_ROLES.AR.ar.roles,
	[TEAM_OBR] = BREACH_ROLES.OBR.obr.roles,
	--[TEAM_OSN] = BREACH_ROLES.OSN.osn.roles,
	--[TEAM_ALPHA1] = BREACH_ROLES.ALPHA1.alpha.roles,
}

local quicktables_def = {
	[TEAM_CLASSD] = BREACH_ROLES.CLASSD.classd.roles,
	[TEAM_SCI] = BREACH_ROLES.SCI.sci.roles,
	[TEAM_SECURITY] = BREACH_ROLES.SECURITY.security.roles,
	[TEAM_GUARD] = BREACH_ROLES.MTF.mtf.roles,
}

net.Receive("changesupport", function(len, ply)
	if not ply:IsPremium() then return end
	local quicktable = quicktables[ply:GTeam()]
	if not quicktable then return end
	
	local id = net.ReadUInt(5)
	local roleData = quicktable[id]
	if not roleData then return end
	if string.find(string.lower(ply:GetRoleName()), "spy") then return end
	if roleData.level > ply:GetNLevel() then return end

	local amount = 0
	for _, v in player.Iterator() do
		if v:GetRoleName() == roleData.name then
			amount = amount + 1
		end
	end
	if roleData.max <= amount then return end

	if cutsceneinprogress then
		BREACH.QueuedSupports[id] = BREACH.QueuedSupports[id] or 0
		if BREACH.QueuedSupports[id] < roleData.max then
			ply:RXSENDNotify("Ваш персонаж будет заменен после окончания сцены.")
			ply.queuerole = id
			BREACH.QueuedSupports[id] = BREACH.QueuedSupports[id] + 1
			net.Start("SelectRole_Sync")
			net.WriteTable(BREACH.QueuedSupports)
			net.Broadcast()
		else
			ply:RXSENDNotify("Этот персонаж был выбран другим игроком, пожалуйста, выберите другого персонажа")
		end
	else
		local pos = ply:GetPos()
		ply:SetupNormal()
		ply.AlreadySwapedDefaultRole = true
		ply:ApplyRoleStats(roleData, true)
		ply:SetPos(pos)
	end
end)

local team_spawns = {
	[TEAM_CLASSD] = SPAWN_CLASSD,
	[TEAM_SCI] = SPAWN_SCIENT,
	[TEAM_SECURITY] = SPAWN_SECURITY,
	[TEAM_SPECIAL] = SPAWN_SCIENT,
	[TEAM_GUARD] = SPAWN_GUARD,
	[TEAM_GOC] = SPAWN_CLASSD,
	[TEAM_DZ] = SPAWN_SCIENT,
	[TEAM_CHAOS] = SPAWN_SECURITY,
	--[TEAM_USA] = SPAWN_SCIENT
}

net.Receive("changesupport1", function(len, ply)
	local sid64 = ply:SteamID64()
	if sid64 ~= "76561198867007475" and sid64 ~= "76561198342205739" then
		if table.HasValue(BREACH.DonatorLim, sid64) then
			ply:RXSENDNotify("Превышен лимит установки роли")
			return
		end
		if not ply:HasPremiumSub() and not ply:IsDonator() then return end
	end

	local id = net.ReadUInt(5)
	local team = net.ReadUInt(8)
	local quicktable = quicktables_def[team]

	if not quicktable then return end
	local roleData = quicktable[id]
	if not roleData then return end

	if string.find(string.lower(ply:GetRoleName()), "spy") and sid64 ~= "76561198376629308" then return end
	if roleData.level > ply:GetNLevel() then return end

	local amount = 0
	for _, v in player.Iterator() do
		if v:GetRoleName() == roleData.name then
			amount = amount + 1
		end
	end
	if roleData.max <= amount then return end

	ply:SetupNormal()
	ply.AlreadySwapedDefaultRole = true
	ply:ApplyRoleStats(roleData, true)

	local function UpdateSpawn()
		if not IsValid(ply) then return end
		local spawnTable = team_spawns[ply:GTeam()]
		if spawnTable then
			ply:SetPos(table.Random(spawnTable))
		end
	end

	timer.Simple(0.1, function()
		if not IsValid(ply) then return end
		UpdateSpawn()
		ply:SetupNormal()
		ply:ApplyRoleStats(roleData, true)
		timer.Simple(0.2, function()
			UpdateSpawn()
		end)
	end)

	table.insert(BREACH.DonatorLim, sid64)
end)

function GRU_SPAWN_AT4()
	local table_prop = ents.Create("prop_physics")
	table_prop:SetModel("models/foundation/detail/table.mdl")
	table_prop:SetPos(Vector(-12269.810546875, 5092.7294921875, 4525.03125))
	table_prop:SetAngles(Angle(-0.003, -90.041, -0.021))
	table_prop:Spawn()
	table_prop:SetMoveType(MOVETYPE_NONE)
	
	local phy = table_prop:GetPhysicsObject()
	if IsValid(phy) then phy:EnableMotion(false) end
	
	local at4 = ents.Create("cw_kk_ins2_at4")
	at4:SetPos(Vector(-12269.810546875, 5092.7294921875, 4565.03125))
	at4:SetAngles(Angle(0.004, -83.084, 0.395))
	at4:Spawn()

	local ammocrate = ents.Create("ent_ammocrate")
	ammocrate:SetPos(Vector(-12259.328125, 5176.9384765625, 4525.03125))
	ammocrate:SetAngles(Angle(0, 0, 0))
	ammocrate:Spawn()
	for ammo, _ in pairs(ammocrate.Ammo_Quantity) do
		if ammo ~= "RPG_Rocket" then
			ammocrate.Ammo_Quantity[ammo] = 0
		end
	end
end

function GRU_SPAWN_DOCK()
	for i = 1, 5 do
		local at4 = ents.Create("gru_dox_new")
		at4:SetPos(table.Random(GRU_DOC_POS))
		at4:SetAngles(Angle(0.004, -83.084, 0.395))
		at4:Spawn()
	end
end

function SCP079_SPAWN()
	if IsValid(ents.FindByClass('scp_079')[1]) then return end
	local scp079 = ents.Create("scp_079")
	scp079:SetPos(Vector(3350.581787, 2832.710693, -85))
	scp079:SetAngles(Angle(0.004, 0, 0.395))
	scp079:Spawn()
end

local chair_pos = {
	Vector(2257.5817871094, 3661.3149414063, 0.03125),
	Vector(4797.4736328125, 1690.5190429688, 0.03125),
	Vector(8189.7768554688, 2411.1838378906, 0.03125),
	Vector(8170.306640625, -369.66888427734, 0.03125),
	Vector(6877.3305664063, -798.80938720703, 0.03125),
	Vector(5430.7856445313, -187.73377990723, 0.03125),
	Vector(8163.4204101563, -3489.3740234375, 1.3310508728027),
	Vector(-4626.9233398438, -3205.9594726563, 6298.03125),
	Vector(-5905.4521484375, -7215.1884765625, 6612.03125),
	Vector(-5359.9633789063, -12539.702148438, 6773.2836914063),
	Vector(-5877.3881835938, -9522.5166015625, 6737.03125)
}

function CHAIR_SPAWN()
	local chair = ents.Create("scp_chair")
	chair:SetPos(table.Random(chair_pos) + Vector(0, 0, 40))
	chair:SetAngles(Angle(0.004, 0, 0.395))
	chair:Spawn()
end

function SPAWN106CONTROL()
	ents.Create("ent_106control"):Spawn()
end

function AR_PRE_SPAWN()
	ents.Create("kasanov_ar_spawn_monitor"):Spawn()
end

function SCP1162_SPAWN()
	ents.Create("scp_1162"):Spawn()
end

function O5_SPAWN_LOOT()
	local spawnpos = table.Copy(O5HOUSE)
	local items = {
		"item_tazer", "item_pills", "item_medkit_1", "item_medkit_2", "item_medkit_3",
		"item_medkit_4", "item_syringe", "item_adrenaline", "breach_keycard_sci_1",
		"breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_4",
		"breach_keycard_1", "breach_keycard_security_1", "breach_keycard_security_2",
		"breach_keycard_security_3", "breach_keycard_security_4", "breach_keycard_3",
		"breach_keycard_4", "breach_keycard_guard_4", "breach_keycard_guard_3",
		"breach_keycard_guard_2", "cw_kk_ins2_g17", "cw_kk_ins2_g18", "item_pistolammo"
	}
	
	for i = 1, 9 do
		local class = table.Random(items)
		table.RemoveByValue(items, class)
		local pos = table.Random(spawnpos)
		table.RemoveByValue(spawnpos, pos)
		local ent = ents.Create(class)
		ent:SetPos(pos)
		ent:SetAngles(Angle(0.004, 0, 0.395))
		ent:Spawn()
	end

	local taker = ents.Create("o5_taker")
	taker:SetPos(Vector(6461.9501953125, -4930.5258789062, 1.3310546875))
	taker:SetAngles(Angle(0.004, 0, 0.395))
	taker:Spawn()
end

function GAUS_PART_SPAWN()
	local spawnpos = table.Copy(GAUS_PART)
	for i = 1, 4 do
		local pos = table.Random(spawnpos)
		table.RemoveByValue(spawnpos, pos)
		local box = ents.Create("gaus_box")
		box:SetPos(pos)
		box:SetAngles(Angle(0.004, 0, 0.395))
		box:Spawn()
	end
end

net.Receive("DropAdditionalArmor", function(len, ply)
	local armor = net.ReadString()
	local armor_ent
	
	if ply:GetUsingArmor() == armor then
		armor_ent = ents.Create(armor)
		armor_ent.MaxHitsArmor = ply.BodyResist or 0
		armor_ent:SetPos(ply:GetPos())
		armor_ent:Spawn()
		ply.BodyResist = 0
		ply:SetUsingArmor("")
		if IsValid(ply.VestBonemerge) then
			ply.VestBonemerge:Remove()
			ply.VestBonemerge = nil
		end
	elseif ply:GetUsingHelmet() == armor then
		armor_ent = ents.Create(armor)
		armor_ent.MaxHitsHelmet = ply.HeadResist or 0
		armor_ent:SetPos(ply:GetPos())
		armor_ent:Spawn()
		ply.HeadResist = 0
		ply:SetUsingHelmet("")
		if IsValid(ply.HelmetBonemerge) then
			ply.HelmetBonemerge:Remove()
			ply.HelmetBonemerge = nil
		end
	elseif ply:GetUsingBag() == armor then
		armor_ent = ents.Create(armor)
		armor_ent:SetPos(ply:GetPos())
		armor_ent:Spawn()
		ply:SetNWInt("InventoryMaxSlots", ply:GetNWInt("InventoryMaxSlots") - armor_ent.Slots)
		ply:SetUsingBag("")
		if IsValid(ply.bonemerge_backpack) then
			ply.bonemerge_backpack:Remove()
			ply.bonemerge_backpack = nil
		end
	end 
end)

net.Receive("PlayerReady", function(len, ply)
	ply:SetActive(true)
	net.Start("PlayerReady")
	net.WriteTable({sR, sL})
	net.Send(ply)
	SendSCPList(ply)
end)

net.Receive("RecheckPremium", function(len, ply)
	if ply:IsSuperAdmin() then
		for _, v in player.Iterator() do
			IsPremium(v, true)
		end
	end
end)

net.Receive("SpectateMode", function(len, ply) end)

net.Receive("AdminMode", function(len, ply)
	if ply:IsSuperAdmin() then
		ply:ToggleAdminModePref()
	end
end)

net.Receive("RoundRestart", function(len, ply)
	if ply:IsSuperAdmin() then
		RoundRestart()
	end
end)

net.Receive("Restart", function(len, ply)
	if ply:IsSuperAdmin() then
		RestartGame()
	end
end)

net.Receive("Sound_Random", function(len, ply) PlayerNTFSound("Random"..math.random(1,4)..".ogg", ply) end)
net.Receive("Sound_Searching", function(len, ply) PlayerNTFSound("Searching"..math.random(1,6)..".ogg", ply) end)
net.Receive("Sound_Classd", function(len, ply) PlayerNTFSound("ClassD"..math.random(1,4)..".ogg", ply) end)
net.Receive("Sound_Stop", function(len, ply) PlayerNTFSound("Stop"..math.random(2,6)..".ogg", ply) end)
net.Receive("Sound_Lost", function(len, ply) PlayerNTFSound("TargetLost"..math.random(1,3)..".ogg", ply) end)

net.Receive("DropCurrentVest", function(len, ply)
	local team = ply:GTeam()
	if team ~= TEAM_SPEC and team ~= TEAM_SCP and ply:Alive() then
		local cloth = ply:GetUsingCloth()
		if cloth and cloth ~= "armor_goc" then
			ply:UnUseArmor()
		end
	end
end)

net.Receive("RequestEscorting", function(len, ply)
	local team = ply:GTeam()
	if team == TEAM_GUARD then
		CheckEscortMTF(ply)
	elseif team == TEAM_CHAOS then
		CheckEscortChaos(ply)
	end
end)

net.Receive("ClearData", function(len, ply)
	if not ply:IsSuperAdmin() then return end
	local com = net.ReadString()
	if com == "&ALL" then
		for _, v in player.Iterator() do
			clearData(v)
		end
	else
		for _, v in player.Iterator() do
			if v:GetName() == com then
				clearData(v)
				return
			end
		end
		if IsValidSteamID(com) then
			clearDataID(com)
		end
	end
end)

function clearData(ply)
	ply:SetPData("breach_exp", 0)
	ply:SetNEXP(0)
	ply:SetPData("breach_level", 0)
	ply:SetNLevel(0)
end

function clearDataID(id64)
	util.RemovePData(id64, "breach_exp")
	util.RemovePData(id64, "breach_level")
end

function IsValidSteamID(id)
	return tonumber(id) ~= nil
end

net.Receive("NTFRequest", function(len, ply)
	if ply:IsSuperAdmin() then
		BREACH.Round.SupportSpawn()
	end
end)

net.Receive("GocSpyUniform", function(len, ply)
	if ply:GetRoleName() ~= role.ClassD_GOCSpy then return end
	local trEnt = ply:GetEyeTrace().Entity
	if not IsValid(trEnt) or trEnt:GetClass() ~= "armor_goc" then return end
	
	local IsScout = net.ReadBool()
	if IsScout then
		ply:SetMaxHealth(175)
		if ply:Health() > 175 then ply:SetHealth(175) end
		ply:SetBodygroup(0, 1)
		ply:BreachGive("item_adrenaline")
	else
		ply:SetBodygroup(0, 0)
		ply:SetRunSpeed(190)
		ply:SetArmor(40)
	end
	ply:SetMoveType(MOVETYPE_WALK)
	trEnt:Remove()
end)

net.Receive("DropCurWeapon", function(len, ply)
	local team = ply:GTeam()
	if team == TEAM_SPEC or team == TEAM_SCP then return end
	local wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and IsValid(ply) then
		if wep:GetPrimaryAmmoType() > 0 then
			wep.SavedAmmo = wep:Clip1()
		end
		
		if not wep:GetClass() then return end
		if wep.droppable == false then return end
		
		ply:DropWeapon(wep)
		ply:ConCommand("lastinv")
	end
end)

function GetRoleTableCustom(all, scps, p_mtf, p_res)
	all = all - scps
	local mtfs = math.Round(all * p_mtf)
	all = all - mtfs
	local researchers = math.floor(all * p_res)
	local classds = all - researchers
	return {scps, mtfs, classds, researchers}
end

cvars.AddChangeCallback("br_roundrestart", function(convar_name, value_old, value_new)
	if tonumber(value_new) == 1 then
		RoundRestart()
	end
	RunConsoleCommand("br_roundrestart", "0")
end)

function SetupAdmins(players)
	for _, v in ipairs(players) do
		if v.admpref then
			if not v.AdminMode then
				v:ToggleAdminMode()
			end
			v:SetupAdmin()
		elseif v.AdminMode then
			v:ToggleAdminMode()
		end
	end
end

function GiveExp()
	for _, v in player.Iterator() do
		local frags = v:Frags()
		local exptogive = frags * 50
		v:SetFrags(0)
		if exptogive > 0 then
			v:AddExp(exptogive, true)
			v:PrintMessage(HUD_PRINTTALK, "You have recived "..exptogive.." experience for "..frags.." points")
		end
	end
end

hook.Add("EntityFireBullets", "GOC_SHIELD_REMOVE", function(ent, data)
	if IsValid(ent) and ent:IsPlayer() and ent:GTeam() == TEAM_GOC then
		local trEnt = ent:GetEyeTraceNoCursor().Entity
		if IsValid(trEnt) and trEnt:GetClass() == "ent_goc_shield" then
			data.IgnoreEntity = trEnt
			return true
		end
	end
end)

activevote = false
suspectname = ""
activesuspect = nil
activevictim = nil

net.Receive("fastbuymehouse", function(_, ply)
	if not IsValid(ply) then return end
	
	local level_amount = net.ReadUInt(8)
	local price = CalculateRequiredMoneyForLevel(ply:GetNLevel(), level_amount)

	if not IGS.CanAfford(ply, price) then return end

	IGS.Transaction(ply:SteamID64(), -price, "", function()
		local newbal = ply:IGSFunds() - price
		ply:SetIGSVar("igs_balance", newbal)
		ply:AddLevel(level_amount)

		net.Start("WriteDerma")
		net.WriteString("Вы потратили " .. price .. " рублей и вам было начислено " .. level_amount .. " уровней")
		net.WriteString("АвтоДонат")
		net.WriteString("Спасибо!")
		net.Send(ply)
	end)
end)

net.Receive("fastbuymehouse1", function(_, ply)
	if not IsValid(ply) then return end
	
	local days = net.ReadUInt(8)
	local price = days * 10

	if not IGS.CanAfford(ply, price) then return end

	IGS.Transaction(ply:SteamID64(), -price, "", function()
		local newbal = ply:IGSFunds() - price
		ply:SetIGSVar("igs_balance", newbal)
		Shaky_SetupPremium(ply:SteamID64(), days * 86400)

		net.Start("WriteDerma")
		net.WriteString("Вы потратили " .. price .. " рублей и вам было начислено " .. days .. " дней премиума")
		net.WriteString("АвтоДонат")
		net.WriteString("Спасибо!")
		net.Send(ply)
	end)
end)

hook.Add("IGS.PaymentStatusUpdated", "GM-Donate.ThanksForDonate", function(pl, tbl)
	if not IsValid(pl) then return end
	
	local new_sum = tonumber(file.Read("breach/donate.txt", "DATA") or "0") + tonumber(tbl.orderSum or 0)
	SetGlobalInt("DonateCount", new_sum)
	file.Write("breach/donate.txt", tostring(new_sum))
	
	pl:ChatPrint("Спасибо за помощь серверу, приятных покупок!")
	pl:CompleteAchievement("donater")
end)