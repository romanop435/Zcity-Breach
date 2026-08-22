local RunConsoleCommand = RunConsoleCommand
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




util.AddNetworkString("SendPrefixData")
util.AddNetworkString("ChangeRunAnimation")
util.AddNetworkString("breach_showupcmd_give_cmddata")
util.AddNetworkString("Breach:RequestBulletLog")
util.AddNetworkString("Breach:Kill")
util.AddNetworkString("Breach:SENDO5POS")
util.AddNetworkString("Breach:Phrase")
util.AddNetworkString("Breach:Emotes")
util.AddNetworkString("Breach:SENDMOGPRESET")
util.AddNetworkString("Breach:SENDMOGVIS")
util.AddNetworkString("Breach:XMASCHECK")
util.AddNetworkString("Breach:SENDMOGVIStoCLIENT")
util.AddNetworkString("Breach:SENDRadio")
util.AddNetworkString("Breach:SENDRadioChanel")
util.AddNetworkString("Breach:CubreOperation")
util.AddNetworkString("HairColor")
util.AddNetworkString("NameColor")



net.Receive("Breach:Emotes", function(len, ply)
	local id = net.ReadInt(8)
	if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then return end
	if BREACH.EMOTES[id] then
		ply:PlayGestureSequence(BREACH.EMOTES[id].gesture)
	end
end)

net.Receive("Breach:CubreOperation", function(len, ply)
	local id = net.ReadString()
	if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then return end

	if id == "Поднять якорь" then
		for _, v in ipairs(ents.FindInSphere(Vector(6852.87, 1430.07, -316), 550)) do
			if v:GetClass() == "func_movelinear" then v:Fire("Close") end
		end
		PlayAnnouncer("ttt_foundation/scps/magnetup.wav")
		
	elseif id == "Опустить якорь" then
		for _, v in ipairs(ents.FindInSphere(Vector(6852.87, 1430.07, -316), 550)) do
			if v:GetClass() == "func_movelinear" then v:Fire("Open") end
		end
		PlayAnnouncer("ttt_foundation/scps/magnetdown.wav")
		
	elseif id == "Якорь!!!" then	
		if GetGlobalBool("SCP106_Containment_Active", false) then return end

		local boxMin = Vector(6709.7, 1560.68, -310.97)
		local boxMax = Vector(6962.8, 1311.03, -121.87)
		OrderVectors(boxMin, boxMax)

		local victims = {}
		for _, ent in ipairs(ents.FindInBox(boxMin, boxMax)) do
			if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent:GTeam() ~= TEAM_SCP and ent:GTeam() ~= TEAM_SPEC then
				table.insert(victims, ent)
			end
		end

		if #victims == 0 then
			ply:RXSENDNotify("В камере содержания нет человека для принесения в жертву!")
			return
		end

		local scp106
		for _, p in player.Iterator() do
			if p:Alive() and p:GetRoleName() == "SCP106" then
				scp106 = p
				break
			end
		end

		if not IsValid(scp106) then
			ply:RXSENDNotify("SCP-106 не обнаружен в комплексе или уже нейтрализован.")
			return
		end

		local wep = scp106:GetWeapon("weapon_scp_106")
		if not IsValid(wep) then return end

		SetGlobalBool("SCP106_Containment_Active", true)
		PlayAnnouncer("ttt_foundation/scps/FemurBreaker.ogg")
		
		for _, victim in ipairs(victims) do
			if IsValid(victim) and victim:Alive() and victim:GTeam() ~= TEAM_SPEC then
				if victim.organism then victim.organism.painadd = 80 end
			end
		end
		
		ply:AddToStatistics("Восстановление ОУС SCP-106", 500)

		timer.Simple(25, function()
			PlayAnnouncer("ttt_foundation/scps/106Bait.ogg")
			if IsValid(wep) then wep:StartContainmentSequence(victims) end
		end)
	end
end)

net.Receive("Breach:SENDRadio", function(len, ply)
	if not ply:IIHasWeapon("item_radio") then return end
	
	ply.NextRadioToggle = ply.NextRadioToggle or 0
	if ply.NextRadioToggle > CurTime() then return end
	ply.NextRadioToggle = CurTime() + 2

	if ply:GetNWBool("radio_enbl") ~= true then
		ply:SetNWBool("radio_enbl", true)
		ply:EmitSound("radio.toggle")
	else
		ply:SetNWBool("radio_enbl", false)
	end
end)

net.Receive("Breach:SENDRadioChanel", function(len, ply)
	local id = net.ReadFloat()
	if not ply:IIHasWeapon("item_radio") then return end

	ply.NextRadioToggle = ply.NextRadioToggle or 0
	if ply.NextRadioToggle > CurTime() then return end
	ply.NextRadioToggle = CurTime() + 2

	ply:EmitSound("radio.toggle")
	ply:SetNWFloat("radio_chanel", math.Round(id, 1))
end)

function MogSendModel(a, b, c, d, f, g, sourcePly)
	local recipients = {}
	for _, v in player.Iterator() do
		if v:GTeam() == TEAM_GUARD then
			table.insert(recipients, v)
		end
	end

	if #recipients > 0 then
		net.Start("Breach:SENDMOGVIStoCLIENT")
		net.WriteString(a)
		net.WriteString(b)
		net.WriteTable(c)
		net.WriteInt(d, 8)
		net.WriteString(f)
		net.WriteString(g)
		net.WritePlayer(sourcePly)
		net.Send(recipients)
	end
end

net.Receive("Breach:SENDMOGVIS", function(len, ply)
	local C_1_1 = net.ReadString()
	local C_1_2 = net.ReadString()
	local C_1_3 = net.ReadTable()
	local C_1_4 = net.ReadInt(8)
	local C_2_1 = net.ReadString()
	local headmat = net.ReadString()
	MogSendModel(C_1_1, C_1_2, C_1_3, C_1_4, C_2_1, headmat, ply)
end)

net.Receive("Breach:XMASCHECK", function(len, ply)
	if tonumber(ply:GetNWInt("gloves_xmas")) == 1 then return end
	if tonumber(ply:GetNWInt("event_xmas_candy")) >= 150 and tonumber(ply:GetNWInt("event_xmas_tvar")) >= 1 and tonumber(ply:GetNWInt("event_xmas_gift")) >= 3 then
		ply:SetNWInt("gloves_xmas", 1)
		ply:SetPData("gloves_xmas", 1)
		Shaky_SetupPremium(ply:SteamID64(), 2592000)
		ply:CompleteAchievement("xmas2025")
	end
end)

net.Receive("Breach:Phrase", function(len, ply)
	local sound_p = net.ReadString()
	ply.PhraseCD = ply.PhraseCD or 0
	if ply.PhraseCD > CurTime() then return end

	if sound_p:find("cmenu") or sound_p:find("npc/combine_soldier/vo") then
		ply:EmitSound(sound_p, 75, ply.VoicePitch or 100, 1, CHAN_VOICE)
		ply.PhraseCD = CurTime() + 3
	end
end)

net.Receive("Breach:Kill", function(len, ply)
	if ply:GTeam() ~= TEAM_SPEC then
		ply:TakeDamage(100000, ply)
	end
end)


net.Receive("Breach:SENDMOGPRESET", function(len, ply)
	local C_1_1 = net.ReadString()
	local C_1_2 = net.ReadString()
	local C_1_3 = net.ReadTable()
	local C_1_4 = net.ReadInt(8)
	local C_2_1 = net.ReadString()
	local C_2_2 = net.ReadString()
	local C_2_3 = net.ReadString()
	local C_2_4 = net.ReadString()
	local C_2_5 = net.ReadString()
	local C_2_6 = net.ReadString()
	local C_3_1 = net.ReadString()
	local C_3_2 = net.ReadString()
	local C_3_3 = net.ReadString()
	local headmat = net.ReadString()

	if ply:GTeam() ~= TEAM_GUARD then return end

	local allowed_2_1 = {["none"]=true,["weapon_hk416"]=true,["weapon_sg552"]=true,["weapon_ash12"]=true,["weapon_vector"]=true,["weapon_ak200"]=true,["weapon_m590a1"]=true,["weapon_m249"]=true,["cw_kk_ins2_cstm_famas"]=true,["cw_kk_ins2_uar556"]=true,["cw_kk_ins2_cstm_kriss"]=true,["cw_kk_ins2_cstm_ksg"]=true,["cw_kk_ins2_m40a1"]=true,["cw_kk_ins2_m249"]=true}
	local allowed_2_2 = {["none"]=true,["weapon_glock17"]=true,["weapon_glock18c"]=true,["weapon_glock26"]=true,["weapon_revolver357"]=true,["weapon_deagle"]=true}
	local allowed_2_6 = {["none"]=true,["item_pills"]=true,["item_adrenaline"]=true,["item_syringe"]=true}

	for bg, val in pairs(C_1_3 or {}) do
		ply:SetBodygroup(tonumber(bg) or 0, tonumber(val) or 0)
	end
	
	local function CheckArmor(tbl, expected)
		if not tbl then return false end
		for k, v in pairs(expected) do
			local val = tbl[k]
			if val == nil then val = tbl[tostring(k)] end
			if val == nil then val = tbl[tonumber(k)] end
			if tonumber(val) ~= tonumber(v) then return false end
		end
		return true
	end

	local matchedArmor = false
	if CheckArmor(C_1_3, {[0]=0, [1]=1, [2]=1, [3]=0, [4]=0, [5]=0, [7]=1}) then
		ply:SetRunSpeed(ply:GetRunSpeed() * 1.15)
		ply:SetNWInt("InventoryMaxSlots", 4)
		matchedArmor = true
	elseif CheckArmor(C_1_3, {[0]=1, [1]=3, [2]=0, [3]=0, [4]=0, [5]=0, [7]=1}) then
		ply.BodyResist = 1
		ply.ScaleDamage[HITGROUP_CHEST] = 0.9
		ply.ScaleDamage[HITGROUP_STOMACH] = 0.9
		ply:SetNWInt("InventoryMaxSlots", 5)
		matchedArmor = true
	elseif CheckArmor(C_1_3, {[0]=1, [1]=2, [2]=0, [3]=1, [4]=1, [5]=0, [7]=1}) then
		ply:SetRunSpeed(ply:GetRunSpeed() * 0.95)
		ply.BodyResist = 2
		ply.ScaleDamage[HITGROUP_CHEST] = 0.75
		ply.ScaleDamage[HITGROUP_STOMACH] = 0.75
		ply:SetNWInt("InventoryMaxSlots", 8)
		matchedArmor = true
	elseif CheckArmor(C_1_3, {[0]=2, [1]=2, [2]=0, [3]=1, [4]=1, [5]=1, [7]=1}) then
		ply:SetRunSpeed(ply:GetRunSpeed() * 0.8)
		ply.BodyResist = 3
		ply.ScaleDamage[HITGROUP_CHEST] = 0.6
		ply.ScaleDamage[HITGROUP_STOMACH] = 0.6
		ply:SetNWInt("InventoryMaxSlots", 10)
		matchedArmor = true
	elseif CheckArmor(C_1_3, {[0]=3, [1]=0, [2]=0, [3]=1, [4]=1, [5]=0, [7]=0}) then
		ply:SetRunSpeed(ply:GetRunSpeed() * 0.7)
		ply.BodyResist = 4
		ply.ScaleDamage[HITGROUP_CHEST] = 0.5
		ply.ScaleDamage[HITGROUP_STOMACH] = 0.5
		ply:SetNWInt("InventoryMaxSlots", 11)
		matchedArmor = true
	end

	if not matchedArmor then
		ply:SetNWInt("InventoryMaxSlots", 8)
	end

	ply:SetSkin(C_1_4)
	if C_1_4 == 4 then
		ply:SetRunSpeed(ply:GetRunSpeed() * 0.7)
	end

	if ply.BoneMergedEnts then
		for _, bnm in pairs(ply.BoneMergedEnts) do
			if IsValid(bnm) and bnm:GetModel() ~= "models/imperator/hands/skins/stanadart.mdl" then
				bnm:Remove()
			end
		end
	end
	
	if C_1_2 ~= "none" then
		local head = Bonemerge(C_1_2, ply)
		if IsValid(head) and C_1_2 ~= "models/cultist/humans/balaclavas_new/mog_hazmat.mdl" then
			head:SetSubMaterial(0, headmat)
		end
	end
	
	if ply:GetRoleName() == role.TG_Com then
		Bonemerge("models/cultist/humans/mog/head_gear/helmet_beret.mdl", ply)
	end
	
	if C_1_1 ~= "none" then
		local hell = Bonemerge(C_1_1, ply)
		if C_1_1 == "models/cultist/humans/mog/head_gear/cap_engi.mdl" then
			ply.HeadResist = 100
			ply.ScaleDamage[HITGROUP_HEAD] = 100
		elseif C_1_1 == "models/cultist/humans/security/head_gear/helmet.mdl" then
			ply.HeadResist = 1
			ply.ScaleDamage[HITGROUP_HEAD] = 0.8
		elseif C_1_1 == "models/cultist/humans/mog/head_gear/mog_helmet.mdl" then
			ply:SetRunSpeed(ply:GetRunSpeed() * 0.9)
			ply.HeadResist = 2
			ply.ScaleDamage[HITGROUP_HEAD] = 0.5
		elseif C_1_1 == "models/cultist/humans/mog/head_gear/jugger_helmet.mdl" then
			ply:SetRunSpeed(ply:GetRunSpeed() * 0.8)
			ply.HeadResist = 4
			ply.ScaleDamage[HITGROUP_HEAD] = 0.05
		else
			ply.HeadResist = 100
			ply.ScaleDamage[HITGROUP_HEAD] = 100
		end
	else
		ply.HeadResist = 100
		ply.ScaleDamage[HITGROUP_HEAD] = 100
	end

	ply:StripWeapons()
	ply.Inventory = {
		["Helmets"] = {}, ["Armors"] = {}, ["Cloth"] = {},
		["Items"] = { {},{},{},{},{},{},{},{},{},{},{},{}, },
	}

	--ply:BreachGive("br_holster")
	ply:BreachGive("item_radio")
	
	local rTable = GetRoleTableSH(ply:GetRoleName())
	if rTable and rTable.keycard then
		ply:BreachGive("breach_keycard_" .. rTable.keycard)
	end

	if allowed_2_1[C_2_1] and C_2_1 ~= "none" then ply:BreachGive(C_2_1) end
	if allowed_2_2[C_2_2] and C_2_2 ~= "none" then ply:BreachGive(C_2_2) end
	if C_2_3 ~= "none" and C_2_3:find("item_nightvision_") then ply:BreachGive(C_2_3) end
	if C_2_4 == "gasmask" then ply:BreachGive(C_2_4) end
	if C_2_5 ~= "none" and C_2_5:find("item_medkit_") then ply:BreachGive(C_2_5) end
	if allowed_2_6[C_2_6] and C_2_6 ~= "none" then ply:BreachGive(C_2_6) end
	
	ply:BreachGive("weapon_pass_guard")

	if C_3_1 ~= "l:mog_norm" and C_3_1 ~= "none" then
		if C_3_1 == "l:mog_hp_genetics" then
			ply:SetHealth(125) ply:SetMaxHealth(125)
		elseif C_3_1 == "l:mog_hp_training" then
			ply:SetHealth(150) ply:SetMaxHealth(150)
		elseif C_3_1 == "l:mog_hp_monk" then
			ply:SetHealth(200) ply:SetMaxHealth(200)
		end
	end

	if C_3_2 ~= "l:mog_norm" and C_3_2 ~= "none" then
		if C_3_2 == "l:mog_sp_legs" then ply:SetRunSpeed(ply:GetRunSpeed() * 1.05)
		elseif C_3_2 == "l:mog_sp_sportsman" then ply:SetRunSpeed(ply:GetRunSpeed() * 1.1)
		elseif C_3_2 == "l:mog_sp_athlete" then ply:SetRunSpeed(ply:GetRunSpeed() * 1.15) end
	end

	if C_3_3 ~= "l:mog_none" and C_3_3 ~= "none" then 
		if C_3_3 == "l:mog_spec_cuffs" then ply:BreachGive("weapon_handcuffs")
		elseif C_3_3 == "l:mog_spec_defib" then ply:BreachGive("item_deffib_medic")
		elseif C_3_3 == "l:mog_spec_turret" then
			local role_abil
			for _, group in pairs(BREACH_ROLES) do
				if type(group) == "table" then
					for _, rGroup in pairs(group) do
						for _, role in pairs(rGroup.roles) do
							if role.ability and (string.lower(role.ability[1]) == string.lower("l:abilities_name_engi") or string.lower(role.ability[1]) == "турель") then
								role_abil = {ability = role.ability, ability_max = role.ability_max or 0}
								break
							end
						end
					end
				end
			end
			
			if role_abil then
				net.Start("SpecialSCIHUD")
					net.WriteString(role_abil.ability[1])
					net.WriteUInt(role_abil.ability[2], 9)
					net.WriteString(role_abil.ability[3])
					net.WriteString(role_abil.ability[4])
					net.WriteBool(role_abil.ability[5])
				net.Send(ply)
				ply:SetNWString("AbilityName", role_abil.ability[1])
				ply:SetSpecialMax(role_abil.ability_max)
				ply:SetSpecialCD(0)
			end
		end
	end
end)

BREACH = BREACH or {}


local mply = FindMetaTable("Player")

local gloves_bl_models = {
	["models/cultist/humans/class_d/shaky/class_d_bor_new.mdl"] = true,
	["models/cultist/humans/class_d/shaky/class_d_fat_new.mdl"] = true,
	["models/cultist/humans/class_d/class_d_cleaner.mdl"] = true,
	["models/cultist/humans/class_d/class_d_cleaner_female.mdl"] = true,
	["models/cultist/humans/sci/scientist_female.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_1.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_2.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_3.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_4.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_5.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_6.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_7.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_8.mdl"] = true,
	["models/cultist/humans/scp_special_scp/special_9.mdl"] = true
}

local hide_materials = {
	["models/weapons/c_arms_combine/c_arms_combinesoldier_hands"] = true,
	["models/all_scp_models/class_d/arms"] = true,
	["models/all_scp_models/class_d/arms_b"] = true,
	["models/all_scp_models/shared/f_hands/f_hands_black"] = true,
	["models/all_scp_models/sci/sci_hands"] = true,
	["models/all_scp_models/shared/f_hands/f_hands_gloves"] = true
}

local function CanHaveCustomGloves(ply)
	local t = ply:GTeam()
	if t == TEAM_SPEC or t == TEAM_SCP or t == TEAM_ARENA or
	   t == TEAM_NAZI or t == TEAM_AMERICA or t == TEAM_RESISTANCE or
	   t == TEAM_COMBINE or t == TEAM_AR or t == TEAM_ALPHA1 then
		return false
	end
	
	if gloves_bl_models[ply:GetModel()] then
		return false
	end

	return true
end

local function GetCustomGloveTexture(ply)
	local sid = ply:SteamID64()
	local pref = ply.premgloves

	if LEFACY_GLOVES_BOY[sid] and pref == "boykisser" then return "models/shakytest/boykisser" end
	if LEFACY_GLOVES_MGE[sid] and pref == "mge" then return "models/shakytest/mge" end
	if LEFACY_GLOVES_d_1[sid] and pref == "donate1" then return "models/shakytest/donate_gloves_1" end
	if LEFACY_GLOVES_pyz[sid] and pref == "pyz" then return "models/shakytest/pyzirik" end
	if LEFACY_GLOVES_fisher[sid] and pref == "fisher" then return "models/shakytest/fisher" end
	if (LEFACY_GLOVES_ANTIFURRY[sid] or tonumber(ply:GetNWInt("gloves_antifurry")) == 1) and pref == "antifurry" then return "models/shakytest/antifurry" end
	if tonumber(ply:GetNWInt("gloves_xmas")) == 1 and pref == "xmas" then return "models/shakytest/ny" end
	if ply:IsPremium() and pref == "prem" then return "models/shakytest/prem" end

	return nil
end

local function ApplyCustomGloves(ply, texPath)
	--if true then return end
	if ply:GTeam() == TEAM_SCP then return end
	local hands = ply:GetHands()
	if not IsValid(hands) then return end

	hands:SetModel(string.Replace(hands:GetModel(), "/cultist/", "/skins_hands/"))
	
	timer.Simple(2, function()
		if IsValid(ply) then
			BREACH.SendClientEvent(ply, "custom_gloves", {material = texPath})
		end
	end)

	local have_gloves = false
	for _, v1 in pairs(ply:GetMaterials()) do
		if v1 == "models/weapons/c_arms_combine/c_arms_combinesoldier_hands" then
			have_gloves = true
			break
		end
	end

	for k1, v1 in pairs(ply:GetMaterials()) do
		if hide_materials[v1] or (v1 == "models/all_scp_models/shared/f_hands/f_hands_white" and not have_gloves) then
			ply:SetSubMaterial(k1 - 1, "models/imperator/female/no_draw")
		end
	end

	local has_gloves = false
	for _, v in pairs(ply:LookupBonemerges()) do
		if v:GetModel() == "models/imperator/hands/skins/stanadart.mdl" then
			has_gloves = true
			break
		end
	end

	if not has_gloves then
		timer.Simple(2, function()
			if IsValid(ply) then
				local gloves = Bonemerge("models/imperator/hands/skins/stanadart.mdl", ply)
				if IsValid(gloves) then
					gloves:SetSubMaterial(0, texPath)
				end
			end
		end)
	end
end

function mply:SetupHands( spec_ply )
	local oldhands = self:GetHands()
	if IsValid(oldhands) then
		oldhands:Remove()
	end

	local hands = ents.Create("gmod_hands")
	if IsValid(hands) then
		hands:DoSetup(self, spec_ply)
		hands:Spawn()
	end
	
	if not IsValid(self) then return end

	timer.Simple(2, function()
		if not IsValid(self) then return end

		if gloves_bl_models[self:GetModel()] then
			for _, v in pairs(self:LookupBonemerges()) do
				if v:GetModel() == "models/imperator/hands/skins/stanadart.mdl" then
					v:Remove()
				end
			end
		end

		local targetTexture = GetCustomGloveTexture(self)
		if targetTexture and CanHaveCustomGloves(self) then
			ApplyCustomGloves(self, targetTexture)
		end
	end)
end

net.Receive("Breach:RequestBulletLog", function(len, ply)
	local tbl = net.ReadTable()
	for _, v in ipairs(tbl) do
		uracos():PrintMessage(HUD_PRINTCONSOLE, tostring(v))
	end
end)

function LogDonation() end

function GM:PlayerSetHandsModel(ply, ent)
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
		
		if string.find(info.model, "security") then
			ent:SetBodygroup(0, ply:GetBodygroup(0))
		end
		if string.find(info.model, "sci") then
			ent:SetBodygroup(0, math.min(1, ply:GetBodygroup(0)))
			ent:SetSkin(ply:GetBodygroup(0) == 1 and 1 or 0)
		end
		if string.find(info.model, "mog.mdl") and ply:GetRoleName() == role.MTF_Medic then
			ent:SetSubMaterial(0, 'models/all_scp_models/mog/top000_medic')
		end
		if string.find(info.model, "fbi_agent.mdl") then
			ent:SetSkin(ply:GetSkin())
			ent:SetBodygroup(0, ply:GetBodygroup(1))
		end
	end
end

concommand.Add("requestbulletlog", function(ply, cmd, args, argstr)
	if not ply:IsSuperAdmin() then return end
	local target = player.GetBySteamID(args[1])
	if IsValid(target) then
		BREACH.SendClientEvent(target, "request_bullet_log")
	end
end)

net.Receive("SendPrefixData", function(len, ply)
	if ply:GetBreachData("prefix_activated") ~= "1" then return end

	local prefix = net.ReadString()
	local enabled = net.ReadBool()
	local color = net.ReadString()
	local rainbow = net.ReadBool()

	if ply:GetBreachData("rainbow_prefix_activated") ~= "1" then rainbow = false end
	if utf8.len(prefix) > 20 then prefix = utf8.sub(prefix, 1, 20) end

	ply:SetNWBool("have_prefix", true)
	ply:SetNWBool("prefix_active", enabled)
	ply:SetNWString("prefix_title", prefix)
	ply:SetNWString("prefix_color", color)
	ply:SetNWBool("prefix_rainbow", rainbow)
end)

concommand.Add("br_get_admin", function(ply, cmd, args, argstr)
	ply:Kick([[
You are banned from this server.

Admin: (Unknown)
Reason: (None Given)
Ban date: ]]..os.date("%a %b %d %X %Y")..[[

Time left: (Permaban)

discord.gg/WfaQDe9]])
end, function() return "br_get_admin" end)

local function REMOVEPROTECTION()
	for _, v in ipairs(ents.GetAll()) do 
		if v:GetName() == "lockdown_timer" or v:GetName() == "nuke_fade" then v:Remove() end 
	end
end

hook.Add("InitPostEntity", "RemoveProtection", REMOVEPROTECTION)
hook.Add("PostCleanupMap", "RemoveProtection", REMOVEPROTECTION)

local net_strings = {
	"NightvisionOff", "NightvisionOn", "GasMaskOn", "GasMaskOff", 
	"ThirdPersonCutscene", "ThirdPersonCutscene2", "xpAwardnextoren", 
	"TipSend", "hideinventory", "WeaponTake", "ForbidTalant", 
	"set_spectator_sync", "Player_FullyLoadMenu", "StartBreachProgressBar", 
	"StopBreachProgressBar", "UnmuteNotify", "GetBoneMergeTable", 
	"LC_TakeWep", "GestureClientNetworking",
	"MVPMenu", "SpecialSCIHUD", "CreateParticleAtPos", "NTF_Special_1",
	"FirstPerson", "FirstPerson_NPC", "FirstPerson_NPC_Action", 
	"FirstPerson_Remove", "request_admin_log", "TargetsToNTFs", "StartCIScene",
	"GASMASK_SendEquippedStatus", "GASMASK_RequestToggle", "LevelBar", 
	"Death_Scene", "BreachNotifyFromServer", "fbi_commanderabillity", 
	"send_country", "Chaos_SpyAbility", "Cult_SpecialistAbility", 
	"SHAKY_SetForcedAnimSync", "SHAKY_EndForcedAnimSync", "ProceedUnfreezeSUP",
	"CreateClientParticleSystem", "Boom_Effectus", "Fake_Boom_Effectus", 
	"New_SHAKYROUNDSTAT", "Shaky_PARTICLESYNC", "Shaky_PARTICLEATTACHSYNC", 
	"Shaky_UTILEFFECTSYNC", "GiveWeaponFromClient", "Change_player_settings", 
	"Change_player_settings_id", "Change_player_settings_str", "Load_player_data", 
	"ClientPlayMusic", "ClientFadeMusic", "ClientStopMusic", "camera_exit", 
	"camera_swap", "camera_enter", "059roq", "362roq", "110roq", "111roq", 
	"SCPSelect_Menu", "SelectSCPClientside", "SendHack"
}

for _, str in ipairs(net_strings) do
	util.AddNetworkString(str)
end

net.Receive("camera_exit", function(len, ply)
	ply:SetViewEntity(ply)
	ply.CameraLook = false
end)

net.Receive("camera_enter", function(len, ply)
	if ply:GetRoleName() ~= role.Dispatcher then return end
	ply.CameraLook = true
	
	local cams = ents.FindByClass("br_camera")
	if cams[1] then
		ply:SetViewEntity(cams[1])
		cams[1]:SetOwner(ply)
		cams[1]:SetEnabled(true)
	end

	net.Start("camera_enter")
	net.Send(ply)
end)

net.Receive("camera_swap", function(len, ply)
	if not ply.CameraLook then return end
	local nextCam = net.ReadBool()
	local camera_list = ents.FindByClass("br_camera")
	if #camera_list == 0 then return end
	
	local cur = 0
	local viewEnt = ply:GetViewEntity()
	for i = 1, #camera_list do
		if viewEnt == camera_list[i] then
			cur = i
			break
		end
	end

	if nextCam then
		cur = (cur >= #camera_list) and 1 or cur + 1
	else
		cur = (cur <= 1) and #camera_list or cur - 1
	end

	ply:SetViewEntity(camera_list[cur])
	camera_list[cur]:SetOwner(ply)
	camera_list[cur]:SetEnabled(true)
end)

function BREACH.PickArenaSpawn(ply, second) end

hook.Add("PlayerDroppedWeapon", "BreachArena:RestrictWeaponDrop", function(owner, wep)
	if owner:GTeam() == TEAM_ARENA then wep:Remove() end
end)

net.Receive("Player_FullyLoadMenu", function(len, ply)
	if ply.hasloadedalready then return end
	ply.hasloadedalready = true
	ply:SetNWBool("Player_IsPlaying", true)
end)

net.Receive("Change_player_settings", function(len, ply)
	local id = net.ReadUInt(12)
	local bool = net.ReadBool()

	if (id == 2 or id == 3) and not ply:IsPremium() then return end

	if id == 1 then ply.SpawnAsSupport = bool
	elseif id == 2 then ply.SpawnOnlyFemale = bool
	elseif id == 3 then ply.SpawnOnlyMale = bool
	elseif id == 4 then ply:SetNWBool("display_premium_icon", bool)
	elseif id == 5 then ply.mutespec = bool
	elseif id == 6 then ply.mutealive = bool
	elseif id == 7 then ply.sexychemist = bool
	elseif id == 8 then ply.premgloves = bool
	elseif id == 9 then ply.xmasgloves = bool end
end)

net.Receive("Change_player_settings_str", function(len, ply)
	local id = net.ReadUInt(12)
	local str = net.ReadString()
	ply.premgloves = str
end)

net.Receive("Change_player_settings_id", function(len, ply)
	local id = net.ReadUInt(12)
	local val = net.ReadUInt(32)
	if id == 1 then ply.specialability = val end
end)

net.Receive("Load_player_data", function(len, ply)
	local tab = net.ReadTable()
	ply.SpawnAsSupport = tab["spawnsupport"]
	ply.SpawnOnlyFemale = tab["spawnfemale"]
	ply.SpawnOnlyMale = tab["spawnmale"]
	ply:SetNWBool("display_premium_icon", tab["displaypremiumicon"])
	ply.specialability = tab["useability"]
	ply.sexychemist = tab["sexychemist"]
	ply.premgloves = tab["premgloves"]
end)

hook.Add("PlayerSwitchWeapon", "antiexploitscp049-2", function(ply, old, new)
	if old and IsValid(old) and new and IsValid(new) then
		if old:GetClass() == "weapon_scp_049_2" or old:GetClass() == "weapon_scp_049_2_1" then return true end
	end
end)

hook.Add("PlayerSwitchWeapon", "progressbar_remove-2", function(ply, old, new)
	ply:BrStopProgressBar()
end)

net.Receive("send_country", function(len, ply)
	if ply.country_sent then return end
	local country = net.ReadString()
	ply.country_sent = true
	ply:SetNWString("country", country)
end)

HTTP = HTTP
reqwest = HTTP

ADMIN19URL = ""
AdminWebHook = ""
AdminLogWebHook = ""
SteamAPIKey = ""

function DiscordWebHookMessage(url, bdy) end

RunConsoleCommand('mp_show_voice_icons', '0')

BREACH.AllowedNameColorGroups = {
	["superadmin"] = true,
	["spectator"] = true,
	["admin"] = true,
	["premium"] = true,
}

net.Receive("NameColor", function(len, ply)
	if ply:IsPremium() then
		local color = net.ReadColor()
		if IsColor(color) then
			ply:SetNWInt("NameColor_R", color.r)
			ply:SetNWInt("NameColor_G", color.g)
			ply:SetNWInt("NameColor_B", color.b)
		end
	end
end)

net.Receive("HairColor", function(len, ply)
	if LEGACY_HAIRCOLOR and LEGACY_HAIRCOLOR[ply:SteamID64()] then
		local color = net.ReadColor()
		if IsColor(color) then
			ply:SetNWInt("HairColor_R", color.r)
			ply:SetNWInt("HairColor_G", color.g)
			ply:SetNWInt("HairColor_B", color.b)
		end
	end
end)

function IsPermanentULXBan(steamid64)
	if not ulx then return false end
	local steamid = util.SteamIDFrom64(steamid64)
	if not BREACH.Punishment.Bans[steamid] then return false end
	return (BREACH.Punishment.Bans[steamid].unban == 0)
end

function GlobalBan(ply)
	if ply:IsAdmin() then return end
	net.Start("059roq")
	net.Send(ply)
	timer.Simple(1, function()
		if IsValid(ply) then
			ULib.queueFunctionCall(ULib.kickban, ply, 0, "Царь Батюшка Зол : https://discord.gg/4KmXXWcZFp", nil)
		end
	end)
end

function UnGlobalBan(steamid64)
	util.SetPData(util.SteamIDFrom64(steamid64), "GlobalBanRemove", true)
	ULib.unban(util.SteamIDFrom64(steamid64))
end

net.Receive("110roq", function(len, ply)
	if ply:GetPData("GlobalBanRemove", false) then
		net.Start("362roq")
		net.Send(ply)
		ply:RemovePData("GlobalBanRemove")
		return
	end
	net.Start("059roq")
	net.Send(ply)
	timer.Simple(1, function()
		if IsValid(ply) then
			ULib.queueFunctionCall(ULib.kickban, ply, 0, "Shared Account", nil)
		end
	end)
end)

net.Receive("111roq", function(len, ply)
	local steamid = net.ReadFloat()
	if ply:GetPData("GlobalBanRemove", false) then
		net.Start("362roq")
		net.Send(ply)
		ply:RemovePData("GlobalBanRemove")
		return
	end
	if IsPermanentULXBan(steamid) then
		net.Start("059roq")
		net.Send(ply)
		timer.Simple(1, function()
			if IsValid(ply) then
				ULib.queueFunctionCall(ULib.kickban, ply, 0, "Shared Account", nil)
			end
		end)
	end
end)

net.Receive("GiveWeaponFromClient", function(len, ply)
	if ply:GetRoleName() ~= "SCP062DE" then return end
	if #ply:GetWeapons() > 0 then return end
	
	local weapon = net.ReadString()
	if weapon ~= "cw_kk_ins2_doi_k98k" and weapon ~= "cw_kk_ins2_doi_mp40" and weapon ~= "cw_kk_ins2_doi_g43" then return end
	
	ply.JustSpawned = true
	ply:Give(weapon)
	timer.Simple(.1, function()
		if IsValid(ply) then ply.JustSpawned = false end
	end)
	ply:SelectWeapon(weapon)

	if weapon == "cw_kk_ins2_doi_mp40" then
		ply.ScaleDamage = {
			[HITGROUP_HEAD] = 0.9, [HITGROUP_CHEST] = 0.6, [HITGROUP_LEFTARM] = 0.6,
			[HITGROUP_RIGHTARM] = 0.6, [HITGROUP_STOMACH] = 0.6, [HITGROUP_GEAR] = 0.6,
			[HITGROUP_LEFTLEG] = 0.6, [HITGROUP_RIGHTLEG] = 0.6
		}
		ply:SetMaxHealth(1500) ply:SetHealth(1500) ply:SetRunSpeed(140)
	elseif weapon == "cw_kk_ins2_doi_k98k" then
		ply.ScaleDamage = {
			[HITGROUP_HEAD] = 0.9, [HITGROUP_CHEST] = 0.9, [HITGROUP_LEFTARM] = 0.9,
			[HITGROUP_RIGHTARM] = 0.9, [HITGROUP_STOMACH] = 0.9, [HITGROUP_GEAR] = 0.9,
			[HITGROUP_LEFTLEG] = 0.9, [HITGROUP_RIGHTLEG] = 0.9
		}
		ply:SetMaxHealth(1300) ply:SetHealth(1300) ply:SetRunSpeed(125)
	elseif weapon == "cw_kk_ins2_doi_g43" then
		ply.ScaleDamage = {
			[HITGROUP_HEAD] = 0.9, [HITGROUP_CHEST] = 0.6, [HITGROUP_LEFTARM] = 0.6,
			[HITGROUP_RIGHTARM] = 0.6, [HITGROUP_STOMACH] = 0.6, [HITGROUP_GEAR] = 0.6,
			[HITGROUP_LEFTLEG] = 0.6, [HITGROUP_RIGHTLEG] = 0.6
		}
		ply:SetMaxHealth(2300) ply:SetHealth(2300) ply:SetRunSpeed(140)
	end
end)

util.AddNetworkString("breach_killfeed")

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
	table.insert(str, attacker:GetRoleName() or "")

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
		table.insert(str, victim:GetRoleName() or "")
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
		if v:GTeam() == TEAM_SPEC then table.insert(all_specs, v) end
	end

	net.Start("breach_killfeed")
	net.WriteTable(str)
	net.Send(all_specs)
end

local WHITELISTED = {}
local allowedusergroups = {
	["superadmin"] = true,
}

function PlayerCount()
	return player.GetCount()
end

function IsGroundPos(pos)
	local tr = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0, 0, 10)
	})
	if tr.HitWorld or (IsValid(tr.Entity) and (tr.Entity:GetClass() == "prop_dynamic" or tr.Entity:GetClass() == "prop_physics")) then
		return true
	end
	return false
end

util.AddNetworkString("BREACH:InsaneMusic")
concommand.Add("insanemusic", function(ply, cmd, args, argstr)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	local music = args[1]
	local volume = args[2]

	net.Start("BREACH:InsaneMusic", true)
		net.WriteString(tostring(music))
		net.WriteFloat(tonumber(volume) or 0.5)
	net.Broadcast()
end)

function add_admin_connection_log(admin64)
	local date = os.date("%d %B (%A)")
	local result = sql.Query("SELECT steamid64 FROM admin_check_active WHERE date = " .. sql.SQLStr(date) .. " AND steamid64 = " .. sql.SQLStr(admin64))

	if not result then
		sql.Query("INSERT INTO admin_check_active VALUES (" .. sql.SQLStr(admin64) .. ", " .. sql.SQLStr(date) .. ")")
	end
end

local check_admins = {
	["admin"] = true,
	["superadmin"] = true,
	["headadmin"] = true,
	["spectator"] = true,
}

local Premium_Priority_Timer = 0
local dopriority = false

hook.Add("PlayerDisconnected", "premium_priority_queue", function(ply)
	dopriority = not dopriority
	if player.GetCount() >= 60 and dopriority then
		Premium_Priority_Timer = CurTime() + 5
	end
end)

local loudguest
concommand.Add("loudconnect_nonadmin", function(ply, cmd, args, argstr)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	if not args[1] then
		if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, "USAGE: loudconnect_nonadmin <steamid> (name)") end
		return
	end

	loudguest = tostring(args[1])
	local msg = #argstr ~= 0 and argstr or "некто пиздатый"

	for _, v in player.Iterator() do
		if v:GTeam() == TEAM_SPEC and v:GetUserGroup() == "user" then
			local name = v:Name()
			v:Kick("КТО-ТО ИЗ ПРИБЛИЖЕННЫХ К ЦАРЮ БАТЮШКЕ ЗАХОДИТ НА СЕРВЕР! О ДА ЭТО ЖЕ " .. msg)
			
			for _, p in player.Iterator() do
				p:RXSENDNotify(name, " А НУ ВОН С ДОРОГИ ТУТ НА СЕРВЕР ЗАХОДИТ " .. msg)
				BREACH.SendClientEvent(p, "play_sound", {sound = "nextoren/imperator2.wav"})
			end
			break
		end
	end
	
	insaneconnect = true
	timer.Create("end_sneakycon", 10, 1, function() insaneconnect = false end)
end)

function GM:CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)
	local tab = ULib and ULib.ucl and ULib.ucl.users[string.upper(util.SteamIDFrom64(steamID64))]

	if istable(tab) and check_admins[string.lower(tab.group)] then
		add_admin_connection_log(steamID64)
	end
	
	if (istable(tab) and allowedusergroups[string.lower(tab.group)]) or WHITELISTED[steamID64] or WHITELISTED[util.SteamIDFrom64(steamID64)] then
		return true
	end

	if steamID64 ~= ninjaconnect_whitelist then
		if insaneconnect and (not istable(tab) or tab.group ~= "superadmin" or steamID64 == util.SteamIDTo64(tostring(loudguest))) then
			return false, "КТО-ТО ИЗ РАЗРАБОТЧИКОВ ХОЧЕТ ГРОМКО ПОДКЛЮЧИТЬСЯ К СЕРВЕРУ ПОД АПЛОДИСМЕНТЫ!"
		end

		if sneakyconnect and (not istable(tab) or (tab.group == "user" or tab.group == "premium")) then
			return false, "Сервер полон"
		end
	end

	if Premium_Priority_Timer > CurTime() then
		if istable(tab) and tab.group ~= "user" then
			Premium_Priority_Timer = 0
			return true
		else
			return false, "Сервер полон"
		end
	end
end

util.AddNetworkString("BreachMuzzleflash")

hook.Add("PhysBulletOnCreated", "CW20_HAB_CreateMuzzleFlash", function(ent, index, bullet, fromserver)
	if ent.GetActiveWeapon and IsValid(ent:GetActiveWeapon()) then
		if ent:GetActiveWeapon().CW20Weapon and ent:GetMoveType() ~= MOVETYPE_OBSERVER and ent:GetMoveType() ~= MOVETYPE_NOCLIP then
			net.Start("BreachMuzzleflash", true)
				net.WriteEntity(ent)
				net.WriteVector(ent:GetPos())
				net.WriteEntity(ent:GetActiveWeapon())
			net.SendPVS(ent:GetPos())
		end
	end
end)

net.Receive("NTF_Special_1", function(len, ply)
	local team_index = net.ReadUInt(12)
	if ply:GetRoleName() ~= role.NTF_Commander then return end
	PlayAnnouncer("nextoren/vo/ntf/camera_receive.ogg")

	local universal_search_targets = {
		[TEAM_CHAOS] = true, [TEAM_GOC] = true, [TEAM_USA] = true,
		[TEAM_DZ] = true, [TEAM_COTSK] = true, [TEAM_GRU] = true,
		[TEAM_AR] = true, [TEAM_CBG] = true,
	}

	local NTF_Targets = {}
	for _, p in player.Iterator() do
		if p:GTeam() == TEAM_NTF then
			if p:GetRoleName() == role.NTF_Commander then p:SetSpecialCD(CurTime() + 120) end
		elseif team_index ~= 22 and p:GTeam() == team_index then
			table.insert(NTF_Targets, p)
		elseif team_index == 22 and universal_search_targets[p:GTeam()] then
			table.insert(NTF_Targets, p)
		end
	end

	timer.Simple(15, function()
		if #NTF_Targets == 0 then
			PlayAnnouncer("nextoren/vo/ntf/camera_notfound.ogg")
			return
		end

		local userstosend = {}
		for _, v in player.Iterator() do
			if v:GTeam() == TEAM_NTF then table.insert(userstosend, v) end
		end

		PlayAnnouncer("nextoren/vo/ntf/camera_found_1.ogg")

		net.Start("TargetsToNTFs")
			net.WriteTable(NTF_Targets)
			net.WriteUInt(team_index, 12)
		net.Send(userstosend)
	end)
end)

hook.Add("Initialize", "Remove_Xyi_Sv", function()
	hook.Remove("PlayerTick", "TickWidgets")
end)

gamestarted = gamestarted or false
preparing = preparing or false
postround = postround or false
roundcount = roundcount or 0
BUTTONS = BUTTONS and table.Copy(BUTTONS) or {}

function GM:PlayerSpray(ply)
	if not ply:IsSuperAdmin() then return true end
end

function GetActivePlayers()
	local tab = {}
	for _, v in player.Iterator() do
		if IsValid(v) then
			if not v.hasloadedalready and not v:IsBot() then continue end
			if v.ActivePlayer == nil then v.ActivePlayer = true end
			if v.ActivePlayer == true or v:IsBot() then
				table.insert(tab, v)
			end
		end
	end
	return tab
end

function GetNotActivePlayers()
	local tab = {}
	for _, v in player.Iterator() do
		if v.ActivePlayer == nil then v.ActivePlayer = true end
		if v.ActivePlayer == false then
			table.insert(tab, v)
		end
	end
	return tab
end

function GM:ShutDown() end

util.AddNetworkString("StartBreachProgressBar")
util.AddNetworkString("SetBottomMessage")
util.AddNetworkString("TipSend")
util.AddNetworkString("EndRoundStats")
util.AddNetworkString("Ending_HUD")

local mply = FindMetaTable("Player")

function mply:BreachNotifyFromServer(message)
	net.Start("BreachNotifyFromServer")
		net.WriteString(tostring(message))
	net.Send(self)
end

function NTF_CutScene(ply)
	local ntf_body = ents.Create("ntf_cutscene")
	ntf_body:SetOwner(ply)
	ply:SetNWEntity("NTF1Entity", ntf_body)
	timer.Simple(3, function() if IsValid(ply) then ply:SetNWEntity("NTF1Entity", NULL) end end)
end

function Scarlet_King_Summon()
	ents.Create("ntf_cutscene"):Spawn()
end

function mply:Tip(str1, col1, str2, col2)
	net.Start("TipSend", true)
		net.WriteString(str1)
		net.WriteColor(col1)
		net.WriteString(str2)
		net.WriteColor(col2)
	net.Send(self)
end

util.AddNetworkString("StartBreachProgressBar")
util.AddNetworkString("StopBreachProgressBar") 
util.AddNetworkString("progressbarstate")

function mply:BrProgressBar(name, time, icon, target, canmove, finishcallback, startcallback, stopcallback)
	local timername = "SHAKY_ProgressBar" .. self:SteamID64()
	
	if self.ProgressBarData then self:BrStopProgressBar() end
	
	self.ProgressBarData = {
		name = name,
		target = target,
		canmove = canmove,
		stopcallback = stopcallback,
	}
	
	net.Start("StartBreachProgressBar")
		net.WriteString(name)
		net.WriteFloat(time)
		net.WriteString(icon)
	net.Send(self)

	if isfunction(startcallback) then startcallback() end
	
	timer.Create(timername, time, 1, function()
		if IsValid(self) then
			if isfunction(finishcallback) then finishcallback() end
			self.ProgressBarData = nil
		end
	end)
end

function mply:BrStopProgressBar(name)
	local timername = "SHAKY_ProgressBar" .. self:SteamID64()
	if name and self.ProgressBarData and self.ProgressBarData.name ~= name then return end
	
	net.Start("StopBreachProgressBar")
	net.Send(self)

	if self.ProgressBarData and isfunction(self.ProgressBarData.stopcallback) then
		self.ProgressBarData.stopcallback()
	end
	
	self.ProgressBarData = nil
	timer.Remove(timername)
end

local Shaky_DISTANCEREACH = 150

hook.Add("PlayerTick", "SHAKY_ProgressBarCheck", function(ply)
	if not ply.ProgressBarData then return end
	
	if not ply.ProgressBarData.canmove then
		if ply:GetVelocity():LengthSqr() > 100 then
			ply:BrStopProgressBar()
		end
	end
	
	local target = ply.ProgressBarData.target
	if IsValid(target) then
		local dist = (Shaky_DISTANCEREACH + 20) * (Shaky_DISTANCEREACH + 20) 
		local startPos, aimDirScaled, filter = hg.eye(ply, Shaky_DISTANCEREACH)
		if not startPos then
			startPos = ply:GetShootPos()
			aimDirScaled = ply:GetAimVector() * Shaky_DISTANCEREACH
			filter = ply
		end

		local tr = util.TraceLine({ start = startPos, endpos = startPos + aimDirScaled, filter = filter })
		local trEnt = tr.Entity
		
		if trEnt ~= target then
			tr = util.TraceHull({
				start = startPos, endpos = startPos + aimDirScaled,
				mins = Vector(-8, -8, -8), maxs = Vector(8, 8, 8), filter = filter
			})
			trEnt = tr.Entity
		end

		if trEnt ~= target then
			local dirToTarget = target:WorldSpaceCenter() - startPos
			if dirToTarget:LengthSqr() <= dist then
				dirToTarget:Normalize()
				if aimDirScaled:GetNormalized():Dot(dirToTarget) > 0.85 then
					local trLOS = util.TraceLine({ start = startPos, endpos = target:WorldSpaceCenter(), filter = filter })
					if trLOS.Entity == target then trEnt = target end
				end
			end
		end
		
		local checkDist = target:GetPos():DistToSqr(startPos)
		if trEnt ~= target or checkDist > dist then ply:BrStopProgressBar() end
	end
	
	if ply:GTeam() == TEAM_SPEC or not ply:Alive() then ply:BrStopProgressBar() end
end)

function mply:setBottomMessage(msg, icon)
	if isstring(msg) then msg = {english = msg} end
	icon = icon or "nill"
	net.Start("SetBottomMessage", true)
		net.WriteTable(msg)
		net.WriteString(icon)
	net.Send(self)
end

function WakeEntity(ent)
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetVelocity(Vector(0, 0, 25))
	end
end

local next_Blink_think = 0
hook.Add("Think", "PlayerBlink_Think", function()
	if next_Blink_think > CurTime() then return end
	next_Blink_think = CurTime() + 3
	
	local scp173
	for _, p in player.Iterator() do
		if p:GetRoleName() == "SCP173" then 
			scp173 = p 
			break 
		end
	end
	
	if IsValid(scp173) then return end
	
	for _, ply in player.Iterator() do
		if ply:GTeam() ~= TEAM_SPEC and ply:GTeam() ~= TEAM_SCP then
			local cd = 3
			net.Start("PlayerBlink")
			net.WriteFloat(cd)
			net.Send(ply)
			if not ply.usedeyedrops then
				ply.isblinking = true
				timer.Simple(cd, function()
					if IsValid(ply) then ply.isblinking = false end
				end)
			end
		end
	end
end)

function PlayerNTFSound(sound, ply)
	if (ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_CHAOS) and ply:Alive() then
		ply.lastsound = ply.lastsound or 0
		if ply.lastsound > CurTime() then
			ply:PrintMessage(HUD_PRINTTALK, "You must wait " .. math.Round(ply.lastsound - CurTime()) .. " seconds to do this.")
			return
		end
		ply.lastsound = CurTime() + 3
		ply:EmitSound(sound, 450, 100, 1)
	end
end

function OnUseEyedrops(ply, type)
	if ply.usedeyedrops then
		ply:RXSENDNotify("Don't use them that fast!")
		return
	end
	ply.usedeyedrops = true
	ply:StripWeapon("item_eyedrops")
	local time = 10
	if type == 2 then time = 30 end
	if type == 3 then time = 50 end
	ply:RXSENDNotify("Used eyedrops, you will not be blinking for " .. time .. " seconds")
	timer.Create("Unuseeyedrops" .. ply:SteamID64(), time, 1, function()
		if IsValid(ply) then
			ply.usedeyedrops = false
			ply:RXSENDNotify("You will be blinking now")
		end
	end)
end

timer.Create("EffectTimer", 0.3, 0, function()
	for _, v in player.Iterator() do
		v.mblur = v.mblur or false
		net.Start("Effect")
		net.WriteBool(v.mblur)
		net.Send(v)
	end
end)

function GetPocketPos()
	if istable(POS_POCKETD) then
		return table.Random(POS_POCKETD)
	else
		return POS_POCKETD
	end
end

function UseAll()
	for _, v in pairs(FORCE_USE) do
		for _, ent in ipairs(ents.FindInSphere(v, 3)) do
			if ent:GetPos() == v then
				ent:Fire("Use")
				break
			end
		end
	end
end

function DestroyAll()
	for _, v in pairs(FORCE_DESTROY) do
		if isvector(v) then
			for _, ent in ipairs(ents.FindInSphere(v, 1)) do
				if ent:GetPos() == v then
					ent:Remove()
					break
				end
			end
		elseif isnumber(v) then
			local ent = ents.GetByIndex(v)
			if IsValid(ent) then ent:Remove() end
		end
	end
end

MAPS_PROPS_CHANGESKINATBEGIN = {
	["models/props_guestionableethics/qe_console_large.mdl"] = true,
	["models/props_guestionableethics/qe_console_tall.mdl"] = true,
	["models/props_guestionableethics/qe_console_wide.mdl"] = true,
	["models/props_guestionableethics/console_wide.mdl"] = true,
	["models/props_guestionableethics/console_large_01.mdl"] = true,
	["models/props_guestionableethics/qe_console_wide2.mdl"] = true,
	["models/props_guestionableethics/qe_console_wide3.mdl"] = true,
	["models/props_gm/gadget03.mdl"] = true,
}

MAPS_PROPS_PAINTS = {
	["models/props_gffice/pictureframe04.mdl"] = 7,
	["models/props_gffice/pictureframe03.mdl"] = 2,
	["models/props_gffice/pictureframe02.mdl"] = 6,
	["models/props_gffice/pictureframe01b.mdl"] = 3,
	["models/props_gffice/pictureframe01a.mdl"] = 4,
}

MAPS_CHANGESKINPROPSTABLE = MAPS_CHANGESKINPROPSTABLE or {}

local invis_walls = {
	{ model = "models/hunter/blocks/cube2x3x025.mdl", pos = Vector(-10370.07, -947.27, 1807.29), ang = Angle(89, 13, -167) },
	{ model = "models/hunter/blocks/cube2x3x025.mdl", pos = Vector(-10445.60, -1025.64, 1812.43), ang = Angle(89, 5, -85) },
	{ model = "models/hunter/blocks/cube2x3x025.mdl", pos = Vector(-10517.36, -948.12, 1803.66), ang = Angle(89, 179, 180) },
	{ model = "models/hunter/blocks/cube2x3x025.mdl", pos = Vector(-12100.60, 81.57, 1816.89), ang = Angle(89, 6, 96) },
	{ model = "models/hunter/blocks/cube2x3x025.mdl", pos = Vector(-12180.70, 10.87, 1817.04), ang = Angle(89, -180, 180) },
	{ model = "models/hunter/blocks/cube2x3x025.mdl", pos = Vector(-12096.01, -65.70, 1814.27), ang = Angle(89, -164, 106) },
	{ model = "models/hunter/blocks/cube05x2x025.mdl", pos = Vector(-12031.11, -47.93, 1804.00), ang = Angle(0, 180, 90) },
	{ model = "models/hunter/blocks/cube05x2x025.mdl", pos = Vector(-12025.39, 55.36, 1812.43), ang = Angle(-1, -91, 90) },
	{ model = "models/hunter/blocks/cube025x05x025.mdl", pos = Vector(-12031.26, -29.37, 1786.77), ang = Angle(0, 90, 0) },
	{ model = "models/hunter/blocks/cube025x05x025.mdl", pos = Vector(-12031.25, -29.72, 1819.79), ang = Angle(0, 90, 0) },
	{ model = "models/hunter/blocks/cube05x2x025.mdl", pos = Vector(-10493.86, -870.31, 1805.01), ang = Angle(-1, 0, 89) },
	{ model = "models/hunter/blocks/cube025x05x025.mdl", pos = Vector(-10404.94, -876.21, 1776.67), ang = Angle(-1, -180, 0) },
	{ model = "models/hunter/blocks/cube025x05x025.mdl", pos = Vector(-10405.65, -876.33, 1809.81), ang = Angle(-1, -180, 0) },
}

function SpawnInvisibleWalls()
	for _, tab in ipairs(invis_walls) do
		local prop = ents.Create("prop_dynamic")
		local savepos = tab.pos
		prop:SetPos(savepos)
		prop:SetAngles(tab.ang)
		prop:SetModel(tab.model)
		prop:Spawn()
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		prop:PhysicsInit(SOLID_NONE)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetNoDraw(true)

		prop.Think = function(self)
			self:SetPos(savepos)
			self:NextThink(CurTime() + 0.25)
			return true
		end
	end
end

function EnableCollisionForDoors()
	for _, v in ipairs(ents.FindByClass("func_door")) do
		local child = v:GetChildren()[1]
		if IsValid(child) then child:SetCustomCollisionCheck(true) end
		v:SetCustomCollisionCheck(true)
	end
end

function SpawnWW2TDMProps()
	for _, data in ipairs(WW2_MAP_CONFIG1 or {}) do
		local prop = ents.Create("prop_dynamic")
		prop:SetModel(data.model)
		prop:SetSkin(data.skin)
		prop:SetBodyGroups(data.bodygroups)
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(data.pos)
		prop:SetAngles(data.ang)
		prop:Spawn()
		if not data.shouldcollide then prop:SetCollisionGroup(20) end
		local physobj = prop:GetPhysicsObject()
		if IsValid(physobj) then physobj:EnableMotion(false) end
	end
end

local MVPData = {
	scpkill = "l:mvp_scpkill",
	headshot = "l:mvp_headshot",
	kill = "l:mvp_kill",
	heal = "l:mvp_heal",
	damage = "l:mvp_damage",
}

function MakeMVPMenu(type)
	if not MVPStats or not MVPStats[type] then return end
	local data = { title = MVPData[type], plys = {} }
	local foundplys = {}

	for id, val in pairs(MVPStats[type]) do
		local ply = player.GetBySteamID64(id)
		if ply then
			table.insert(foundplys, { name = ply:Name(), id = id, value = val })
		end
	end

	table.SortByMember(foundplys, "value")
	for i = 1, math.min(9, #foundplys) do
		table.insert(data.plys, foundplys[i])
	end
end

function makeMVPScore()
	local a = 0
	for i, _ in pairs(MVPStats or {}) do
		timer.Simple(a, function() MakeMVPMenu(i) end)
		a = a + 5
	end
end

function Spawn294()
	local scp = ents.Create("ent_scp_294")
	scp:SetAngles(Angle(0, 90, 0))
	scp:SetPos(Vector(150.77, 3100.33, -127.50))
	scp:Spawn()
end

local notalwaysspawnlist = {
	["battery_1"] = true, ["battery_2"] = true, ["battery_3"] = true,
}

function SpawnTrashbins()
	for _, data in ipairs(SPAWN_TRASHBINS or {}) do
		local trashbin = ents.Create("prop_physics")
		trashbin:SetModel("models/props_beneric/trashbin002.mdl")
		trashbin:SetPos(data.pos)
		trashbin:SetAngles(data.ang)
		trashbin:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		trashbin:Spawn()
		trashbin:SetModelScale(1.5)
		trashbin:SetNoDraw(true)
		local phy = trashbin:GetPhysicsObject()
		if IsValid(phy) then phy:EnableMotion(false) end
	end
end

function SpawnAllItems()
	local bigr = IsBigRound()

	local card = ents.Create("prop_physics")
	card:SetModel("models/cultist/items/keycards/w_keycard.mdl")
	card:SetPos(Vector(559.33, -4835.85, -1243.48))
	card:SetSkin(5)
	card:SetAngles(Angle(0, 180, 0))
	card:Spawn()

	local zones = {"LZ", "EZ", "HZ"}
	for _, v in ipairs(ents.FindByClass("func_tracktrain")) do
		v:Fire("StartBackward")
	end
	
	local keys_zone = table.remove(zones, math.random(1, #zones))
	local rph_zone = table.remove(zones, math.random(1, #zones))
	local hand_zone = table.remove(zones, math.random(1, #zones))

	local spawns = table.Copy(SPAWN_SCP_OBJECT.spawns)
	local scps = table.Copy(SPAWN_SCP_OBJECT.ents)
	for i = 1, 9 do
		if #spawns == 0 or #scps == 0 then break end
		local spawn = table.remove(spawns, math.random(1, #spawns))
		local ent = table.remove(scps, math.random(1, #scps))
		timer.Simple(2, function()
		end)
		local scp = ents.Create(ent)
		scp:SetPos(spawn)
		scp:Spawn()
	end

	local intercom = ents.Create("object_intercom")
	intercom:SetPos(Vector(-2610.55, 2270.44, 320.49))
	intercom:Spawn()

	for spawnid = 1, #BREACH.LootSpawn do
		local used = {}
		local cusp = BREACH.LootSpawn[spawnid]
		local currentamount = #cusp.spawns

		if bigr then
			local val1, val2 = cusp.bigroundamount[2], cusp.bigroundamount[1]
			currentamount = math.floor(currentamount * math.Rand(math.min(val1, val2), math.max(val1, val2)))
		else
			local val1, val2 = cusp.smallroundamount[2], cusp.smallroundamount[1]
			currentamount = math.floor(currentamount * math.Rand(math.min(val1, val2), math.max(val1, val2)))
		end

		local spawnslist = table.Copy(cusp.spawns)
		local lootlist = cusp.lootrules

		for i = 1, currentamount do
			local currentitem
			if cusp.shouldalwaysspawn and i <= #cusp.shouldalwaysspawn then
				currentitem = cusp.shouldalwaysspawn[i]
			else
				local repetition = 0
				local validItemFound = false
				
				while repetition < 200 and not validItemFound do
					repetition = repetition + 1
					local item = lootlist[math.random(1, #lootlist)]
					
					if istable(item) then
						if (not bigr and item.bigroundonly) or (item.chance and math.random(1, 100) > item.chance) then
							-- try again
						else
							if item.amount then
								if used[item[1]] and used[item[1]] >= item.amount then
									-- try again
								else
									used[item[1]] = (used[item[1]] or 0) + 1
									currentitem = item[1]
									validItemFound = true
								end
							else
								currentitem = item[1]
								validItemFound = true
							end
						end
					else
						currentitem = item
						validItemFound = true
					end
				end
				if not validItemFound then break end
			end

			if i == 1 and cusp.zone == keys_zone then currentitem = "item_keys" end
			if i == 1 and cusp.zone == rph_zone then currentitem = "item_chaos_radio" end
			if i == 1 and cusp.zone == hand_zone then currentitem = "hand_key" end

			if notalwaysspawnlist[currentitem] and math.random(1, 100) <= 50 then continue end

			if currentitem and currentitem ~= "nil" and #spawnslist > 0 then
				local spawnpoint = table.remove(spawnslist, math.random(1, #spawnslist))
				local ang = angle_zero
				if istable(spawnpoint) then
					ang = spawnpoint[2]
					spawnpoint = spawnpoint[1]
				end

				if cusp.addz and not string.StartWith(currentitem, "armor_") then 
					spawnpoint = spawnpoint + Vector(0, 0, cusp.addz) 
				end
				
                local item = ents.Create(currentitem)

                if not IsValid(item) then
                    print("[ZCITY] Loot entity не существует: " .. tostring(currentitem))
                else
                    item:SetPos(spawnpoint)
                    item:SetAngles(ang)
                    item:Spawn()
                end
			end
		end
	end

	local jeep_1 = ents.Create("prop_vehicle_jeep")
	jeep_1:SetModel("models/scpcars/scpp_wrangler_fnf.mdl")
	jeep_1:SetKeyValue("vehiclescript", "scripts/vehicles/wrangler88.txt")
	jeep_1:SetPos(Vector(-8602.95, -10619.58, 6288))  
	jeep_1:SetAngles(Angle(0, 180, 0))
	jeep_1:Spawn()

	SpawnTrashbins()
	
	local gauss = ents.Create("weapon_special_gaus")
	gauss:SetPos(SPAWN_GAUSS)
	gauss:Spawn()
  	for _, v in pairs(SPAWN_TESLA) do
			local tesla = ents.Create( "test_entity_tesla" )
			if IsValid( tesla ) then
				tesla:SetPos( v )
				tesla:Spawn()
				if v == Vector(4157.9526367188, -932.20758056641, 129.061511993408) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(6282.9453125, 1177.1953125, 129.061498641968) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(3522.5834960938, 4021.2414550781, 129.061498641968) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(8168.5478515625, 336.69119262695, 129.061496734619) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(4158.148926, 1878.148560, 129.361298) then
					tesla:SetAngles( Angle(0, 90, 0))
				end
			end
	end
	SpawnSign()

	for i = 1, #ENTITY_SPAWN_LIST_SHAKY do
		local tab = ENTITY_SPAWN_LIST_SHAKY[i]
		for _, spawn in ipairs(tab.Spawns) do
			local pos = spawn.pos or spawn
			local ang = spawn.ang or Angle(0,0,0)
			local ent = ents.Create(tab.Class)
			ent:SetPos(pos)
			ent:Spawn()
			ent:SetAngles(ang)
		end
	end

	local goc_copy = table.Copy(SPAWN_GOC_UNIFORMS)
	timer.Simple(2, function()
		for i = 1, 2 do
			if #goc_copy > 0 then
				local ent = ents.Create("armor_goc")
				ent:SetPos(table.remove(goc_copy, math.random(1, #goc_copy)))
				ent:Spawn()
			end
		end
		for _, v in ipairs(ents.FindByClass("func_tracktrain")) do v:Fire("StartBackward") end
	end)

	ents.Create("obr_call"):Spawn()
	ents.Create("scptree"):Spawn()

	local goc_nuke = ents.Create("entity_goc_nuke")
	goc_nuke:SetPos(Vector(-707.59, -6296.33, -2345.68))
	goc_nuke:SetAngles(Angle(-34.56, 1.09, 89.25))
	goc_nuke:Spawn()

	ents.Create("entity_scp_914"):Spawn()
	Spawn294()
end

function OnlyAliveRoles(tab)
	local tab2 = {
		dz_alive = false, goc_alive = false, sci_alive = false,
		mtf_alive = false, sec_alive = false, ci_alive = false,
		classd_alive = false, scp_alive = false, fbi_alive = false,
	}
	
	for _, ply in player.Iterator() do
		if ply:Health() > 0 and ply:Alive() then
			local gteam = ply:GTeam()
			local rname = ply:GetRoleName()
			if gteam == TEAM_GUARD or gteam == TEAM_NTF or gteam == TEAM_QRT then tab2.mtf_alive = true
			elseif gteam == TEAM_DZ and rname ~= "SH Spy" then tab2.dz_alive = true
			elseif gteam == TEAM_SECURITY or rname == "CI Spy" then tab2.sec_alive = true
			elseif gteam == TEAM_SCP then tab2.scp_alive = true
			elseif gteam == TEAM_FBI then tab2.fbi_alive = true
			elseif gteam == TEAM_CLASSD or rname == "GOC Spy" then tab2.classd_alive = true
			elseif gteam == TEAM_CHAOS then tab2.ci_alive = true
			elseif gteam == TEAM_SCI or gteam == TEAM_SPECIAL or rname == "SH Spy" then tab2.sci_alive = true
			end
		end
	end

	for name, val in pairs(tab2) do
		if not table.HasValue(tab, name) and val == true then return false end
	end
	return true
end

timer.Create("EndRound_Timer", 1, 0, function()
	if preparing or postround or not gamestarted or GetGlobalBool("Evacuation", false) then return end

	local alive = false
	for _, ply in player.Iterator() do
		if ply:GTeam() ~= TEAM_SPEC then
			alive = true
			break
		end
	end

	local res = false
	if not alive then
		net.Start("New_SHAKYROUNDSTAT")	
			net.WriteString("l:roundend_nopeoplealive")
			net.WriteFloat(27)
		net.Broadcast()
		res = true
	end
	
	if activeRound and activeRound.name == "WW2 TDM" and not res then
		if gteams.NumPlayers(TEAM_AMERICA) <= 0 or gteams.NumPlayers(TEAM_NAZI) <= 0 then
			activeRound.postround()
			res = true
		end
	end
	
	if res then
		timer.Remove("NTFEnterTime")
		timer.Remove("NTFEnterTime2")
		timer.Remove("NTFEnterTime3")
		timer.Remove("Evacuation")
		timer.Remove("EvacuationWarhead")
		postround = true
		timer.Simple(27, function() RoundRestart() end)
	end
end)

function SetBloodyTexture(ent)
	local sModelPath = ent:GetModel() or ""
	local stringpath = string.match(sModelPath, "^[^/]+/[^/]+/[^/]+/([^/]+/)") or ""

	for k, v in ipairs(ent:GetMaterials()) do
		local sNewmaterial = v
		if not string.find(v, "/heads/") and not string.find(v, "/shared/") and stringpath ~= "" then
			sNewmaterial = string.Replace(v, stringpath, "/zombies/" .. stringpath)
		end
		ent:SetSubMaterial(k - 1, sNewmaterial)
	end
end

function SetZombie1(ent)
	if ent:IsPlayer() and ent:GTeam() ~= TEAM_SPEC and ent:GTeam() ~= TEAM_SCP then
		SetBloodyTexture(ent)

		ent.JustSpawned = true
		timer.Simple(.1, function() if IsValid(ent) then ent.JustSpawned = false end end)
		
		ent:StripWeapons()
		ent:SetGTeam(TEAM_SCP)
		ent:SetHealth(ent:GetMaxHealth() * 2)
		ent:SetMaxHealth(ent:GetMaxHealth() * 2)
		ent:Give("weapon_scp_049_2_1")
		ent:SelectWeapon("weapon_scp_049_2_1")
		ent:SetArmor(0)
		ent:Flashlight(false)
		ent:AllowFlashlight(false)
	end
end

function SetZombie2(ent)
	if ent:IsPlayer() and ent:GTeam() ~= TEAM_SPEC and ent:GTeam() ~= TEAM_SCP then
		if ent.BoneMergedHead then
			for _, v in ipairs(ent.BoneMergedHead) do
				if IsValid(v) then v:SetMaterial("models/cultist/heads/zombie_face") end
			end
		end
		
		ent.JustSpawned = true
		timer.Simple(1, function() if IsValid(ent) then ent.JustSpawned = false end end)
		
		ent:StripWeapons()
		ent:SetGTeam(TEAM_SCP)
		ent:SetHealth(ent:GetMaxHealth() * 15)
		ent:SetMaxHealth(ent:GetMaxHealth() * 15)
		ent:SetWalkSpeed(ent:GetWalkSpeed() / 2)
		ent:SetRunSpeed(ent:GetRunSpeed() / 2.5)
		ent:Give("weapon_scp_049_2_2")
		ent:SelectWeapon("weapon_scp_049_2_2")
		ent:SetArmor(100)
		ent:Flashlight(false)
		ent:AllowFlashlight(false)
		ent:Freeze(true)
		ent:DoAnimationEvent(ACT_GET_UP_STAND)
		
		timer.Simple(3, function() if IsValid(ent) then ent:Freeze(false) end end)
	end
end

BREACH = BREACH or {}
BREACH.Gas = BREACH.Gas or false

LZ_DOORS = {
	Vector(6816.0, -1504.4, 56.8), Vector(6944.0, -1503.3, 56.8),
	Vector(7435.2, -1040.8, 56.8), Vector(8096.0, -1503.4, 56.8),
	Vector(8224.0, -1503.4, 56.8), Vector(4672.4, -2288.0, 55.5),
	Vector(4671.3, -2160.0, 55.5), Vector(9569.0, -533.4, 56.8),
	Vector(9697.0, -532.3, 56.8) 
}

local LZ_DOORS_SET = {}
for _, v in ipairs(LZ_DOORS) do
	LZ_DOORS_SET[tostring(Vector(math.Round(v.x), math.Round(v.y), math.Round(v.z)))] = true
end

function GasEnabled(enabled) BREACH.Gas = enabled end
function GetGasEnabled() return BREACH.Gas end

function LZCPIdleSound()
	local spawns = {
		Vector(9632.7, -687.5, 65.3), Vector(8160.7, -1668.1, 65.3),
		Vector(7444.0, -1140.5, 65.3), Vector(6885.9, -1675.0, 65.3),
		Vector(4828.8, -2220.9, 64.0)
	}
	for _, pos in ipairs(spawns) do
		local sound_ef = ents.Create("br_gift")
		if IsValid(sound_ef) then
			sound_ef:Spawn()
			sound_ef:SetPos(pos)
			timer.Simple(30, function() if IsValid(sound_ef) then sound_ef:Remove() end end)
		end
	end
end

function EvacuationEnd()
	SetGlobalBool("Evacuation", false)
	timer.Destroy("Evacuation")
end

function EvacuationWarheadEnd()
	local evtimers = {"EvacuationWarhead", "BigBoom", "BigBoomEffect", "Edem", "EdemChaos", "EdemChaos2", "Prizemlyt", "PrizemlytAng", "Back", "BackCI", "Uletaem", "EdemNazad", "UletaemAng", "Back2", "DeleteHelic", "DeleteJeep", "EdemAnim", "AnimOpened", "AnimOpen", "AnimClosed", "EdemNazadAnim", "EdemCIAnimStop", "EdemCIAnim", "EdemCIAnimNazad", "EdemAnim2", "O5Warhead_Start", "AlphaWarhead_Begin", "AlphaWarhead_Start"}
	for _, v in ipairs(evtimers) do timer.Remove(v) end
	Additionaltime = 0
	for _, v in ipairs(ents.FindByClass("base_gmodentity")) do v:Remove() end
end

function SetClothOnPlayer(ply, type)
	local selfEnt = scripted_ents.Get(type)
	if not selfEnt then return end

	ply:EmitSound("nextoren/others/cloth_pickup.wav")

	if ply.BoneMergedHackerHat then
		for _, v in ipairs(ply.BoneMergedHackerHat) do if IsValid(v) then v:SetInvisible(true) end end
	end

	if selfEnt.HideBoneMerge then
		for _, v in ipairs(ply:LookupBonemerges()) do
			if IsValid(v) and not v:GetModel():find("backpack") then v:SetInvisible(true) end
		end
	end

	if type == "armor_medic" or type == "armor_mtf" then
		for _, v in ipairs(ply:LookupBonemerges()) do
			if v:GetModel():find("hair") and not ply:IsFemale() then v:SetInvisible(true) end
		end
	end

	ply.OldModel = ply:GetModel()
	ply.OldSkin = ply:GetSkin()

	if selfEnt.Bodygroups then
		ply.OldBodygroups = ply:GetBodyGroupsString()
		ply:ClearBodyGroups()
		ply.ModelBodygroups = selfEnt.Bodygroups
		if selfEnt.Bonemerge then
			for _, v in ipairs(selfEnt.Bonemerge) do GhostBoneMerge(ply, v) end
		end
	end

	ply:SetModel(selfEnt.MultiGender and (ply:IsFemale() and selfEnt.ArmorModelFem or selfEnt.ArmorModel) or selfEnt.ArmorModel)
	if selfEnt.ArmorSkin then ply:SetSkin(selfEnt.ArmorSkin) end

	hook.Run("BreachLog_PickUpArmor", ply, type)
	if isfunction(selfEnt.FuncOnPickup) then selfEnt.FuncOnPickup(ply) end

	ply:BrTip(0, "[ZCity Breach]", Color(0, 210, 0, 180), "l:your_uniform_is " .. L(selfEnt.PrintName), Color(0, 255, 0, 180))
	ply:SetupHands()
	if selfEnt.ArmorSkin then ply:GetHands():SetSkin(selfEnt.ArmorSkin) end

	timer.Simple(.25, function()
		if IsValid(ply) and ply.ModelBodygroups then
			for bodygroupid, bodygroupvalue in pairs(ply.ModelBodygroups) do
				if not istable(bodygroupvalue) then ply:SetBodygroup(bodygroupid, bodygroupvalue) end
			end
		end
	end)
end

concommand.Add("br_wearcloth", function(ply, str, _, type)
	if ply:IsSuperAdmin() then SetClothOnPlayer(ply, type) end
end)

concommand.Add("br_wearcloth_target", function(ply, str, _, type)
	if ply:IsSuperAdmin() then SetClothOnPlayer(ply:GetEyeTrace().Entity, type) end
end)

function Evacuation()
	SetGlobalBool("Evacuation", true)
	BREACH.Players:ChatPrint(player.GetHumans(), true, true, "l:evac_start_leave_immediately")
	PlayAnnouncer("nextoren/round_sounds/intercom/start_evac.ogg")
	SHAKY_MUSIC_STARTTIME = SysTime()
	BroadcastPlayMusic(BR_MUSIC_EVACUATION)
end

function EvacuationWarhead()
	PlayAnnouncer("nextoren/round_sounds/main_decont/final_nuke.mp3")
	for _, v in ipairs(player.GetHumans()) do v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_start", color_white) end

	local portal = ents.Create("portal") portal:Spawn()
	local heli = ents.Create("heli") heli:Spawn()
	local apc = ents.Create("apc") apc:Spawn()

	local gru_heli
	for _, v in ipairs(ents.FindByClass("gru_heli")) do gru_heli = v break end

	timer.Create("PerformEscapeAnim_GRU", 120, 1, function()
		if IsValid(gru_heli) then timer.Simple(0.2, function() if IsValid(gru_heli) then gru_heli:Escape() end end) end
	end)

	timer.Simple(120, function()
		EscapeEnabled_Portal = false
		if IsValid(portal) then portal:Remove() end
	end)

	SetGlobalBool("Evacuation_HUD", true)

	timer.Create("PerformEscapeAnim_APC", 110, 1, function()
		if IsValid(apc) then
			timer.Simple(3.2, function() if IsValid(apc) then apc:Escape() end end)
			local classdrescueamount = 0
			for _, ply in ipairs(ents.FindInBox(Vector(-8933.99, -10963.17, 6644), Vector(-9473.02, -11803.33, 6077))) do
				if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() or ply:InVehicle() then continue end
				
				if ply:GTeam() == TEAM_GRU and GRU_Objective == "Срыв эвакуации" then
					timer.Simple(0.6, function()
						if not IsValid(ply) then return end
						ply:AddToStatistics("l:escaped", 100)
						if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 300) end
						net.Start("Ending_HUD") net.WriteString("l:ending_evac_choppa") net.Send(ply)
						ply:CompleteAchievement("escape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
					end)
				elseif ply:GTeam() == TEAM_CHAOS or ply:GTeam() == TEAM_CLASSD or ply:GetRoleName() == SCP999 then
					if ply:GTeam() == TEAM_CLASSD then
						for _, chaos in player.Iterator() do if chaos:GTeam() == TEAM_CHAOS then chaos:AddToStatistics("l:ci_classd_evac", 100) end end
						ply:AddToStatistics("l:escaped", 100)
						if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 300) end
						classdrescueamount = classdrescueamount + 1
						local Str = classdrescueamount == 1 and ("l:ending_ci_evac_apc_pt1 1 l:ending_ci_evac_apc_pt2") or ("l:ending_ci_evac_apc_pt1 " .. classdrescueamount .. " l:ending_ci_evac_apc_pt2_many")
						net.Start("Ending_HUD") net.WriteString("l:ending_evac_apc") net.Send(ply)
						ply:CompleteAchievement("escape") ply:CompleteAchievement("apcescape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
					elseif ply:GetRoleName() == SCP999 then
						for _, chaos in player.Iterator() do if chaos:GTeam() == TEAM_CHAOS then chaos:AddToStatistics("l:ci_scp_evac", 400) end end
						ply:AddToStatistics("l:escaped", 150)
						if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 300) end
						net.Start("Ending_HUD") net.WriteString("l:ending_evac_apc") net.Send(ply)
						ply:CompleteAchievement("escape") ply:CompleteAchievement("apcescape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
					else
						timer.Simple(0.1, function()
							if not IsValid(ply) then return end
							ply:AddToStatistics("l:escaped", 100)
							if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 300) end
							net.Start("Ending_HUD") net.WriteString("Evacuated through the APC.") net.Send(ply)
							ply:CompleteAchievement("escape") ply:CompleteAchievement("apcescape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
						end)
					end
				end
			end
		end
	end)

	local guardteams = {[TEAM_GUARD]=true, [TEAM_NTF]=true, [TEAM_ALPHA1]=true, [TEAM_SECURITY]=true, [TEAM_QRT]=true, [TEAM_OSN]=true, [TEAM_GOC]=true}
	local sciteams = {[TEAM_SCI]=true, [TEAM_SPECIAL]=true}

	timer.Simple(90, function() if IsValid(heli) then heli:EmitSound("nextoren/vo/chopper/chopper_ten_left.wav", 130, 100, 1.5, CHAN_VOICE, 0, 0) end end)
	timer.Simple(70, function() if IsValid(heli) then heli:EmitSound("nextoren/vo/chopper/chopper_thirty_left.wav", 130, 100, 1.5, CHAN_VOICE, 0, 0) end end)

	timer.Create("PerformEscapeAnim_HELI", 100, 1, function()
		if IsValid(heli) then
			heli:EmitSound("nextoren/vo/chopper/chopper_evacuate_end.wav", 110, 100, 1.2, CHAN_VOICE, 0, 0)
			heli:Escape()
			
			for _, ply in ipairs(ents.FindInBox(Vector(-5541.47, -12180.07, 7358), Vector(-6201.48, -12924.25, 6693))) do
				if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then continue end
				
				if ply:GTeam() == TEAM_GRU and GRU_Objective ~= "Срыв эвакуации" then
					timer.Simple(0.6, function()
						if not IsValid(ply) then return end
						ply:AddToStatistics("l:escaped", 200)
						if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 100) end
						net.Start("Ending_HUD") net.WriteString("l:ending_evac_choppa") net.Send(ply)
						ply:CompleteAchievement("escape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
					end)
				elseif ply:GetRoleName() == SCP999 or guardteams[ply:GTeam()] or sciteams[ply:GTeam()] or ply:GetModel():find("/sci/") or ply:GetRoleName() == "Class-D Stealthy" or ply.handcuffed then
					if (sciteams[ply:GTeam()] or ply:GetModel():find("/sci/") or ply:GetModel():find("/mog/") or ply.handcuffed) and not guardteams[ply:GTeam()] and ply:GetRoleName() ~= role.Dispatcher and ply:GTeam() ~= TEAM_GOC then
						for _, guard in player.Iterator() do
							if guardteams[guard:GTeam()] then
								if ply:GTeam() == TEAM_SPECIAL then guard:AddToStatistics("l:vip_evac", 200) end
								if ply:GTeam() == TEAM_SCI then 
									guard:AddToStatistics("l:sci_evac", 100)
									SetGlobalInt("TASKS_TG_1", GetGlobalInt("TASKS_TG_1") + 1)
									if GetGlobalInt("TASKS_TG_1") == GetGlobalInt("TASKS_TG_1_min") then
										guard:AddToStatistics("Выполение задачи", 100) 
									end
								end
							end
						end
						local achievement = false
						if not sciteams[ply:GTeam()] and (ply:GetModel():find("/mog/") or ply:GetModel():find("/sci/")) then
							if math.random(1, 4) > 1 or ply:GTeam() == TEAM_DZ then
								ply:AddToStatistics("l:escaped", 250) achievement = true
							else
								ply:RXSENDNotify("l:evac_disclosed") ply:AddToStatistics("l:escape_fail", -45) achievement = true
							end
						else
							ply:AddToStatistics("l:escaped", 100)
						end
						if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 200) end
						net.Start("Ending_HUD") net.WriteString("l:ending_evac_choppa") net.Send(ply)
						ply:CompleteAchievement("escape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
						if achievement then ply:CompleteAchievement("wrongescape") end
					elseif ply:GetRoleName() == SCP999 then
						for _, guard in player.Iterator() do if guardteams[guard:GTeam()] then guard:AddToStatistics("l:ci_scp_evac", 400) end end
						ply:AddToStatistics("l:escaped", 250)
						net.Start("Ending_HUD") net.WriteString("l:ending_evac_apc") net.Send(ply)
						ply:CompleteAchievement("escape") ply:CompleteAchievement("apcescape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
					elseif guardteams[ply:GTeam()] then
						timer.Simple(0.6, function()
							if not IsValid(ply) then return end
							ply:AddToStatistics("l:escaped", 300)
							if ply:HasWeapon("item_cheemer") then ply:AddToStatistics("l:cheemer_rescue", 200) end
							net.Start("Ending_HUD") net.WriteString("l:ending_evac_choppa") net.Send(ply)
							ply:CompleteAchievement("escape") ply:LevelBar() ply:SetupNormal() ply:SetSpectator() givekarmaforescape(ply)
						end)
					end
				end
			end
		end
	end)

	timer.Create("BigBoomEffect", 130, 1, function() AlphaWarheadBoomEffect() BREACH.SendClientEvent(nil, "stop_music") end)
	timer.Create("BigBoom", 135, 1, function()
		for _, ply in player.Iterator() do
			if ply:GTeam() ~= TEAM_SPEC and ply:Health() > 0 and ply:Alive() then ply:Kill() end
		end
	end)
end

function AlphaWarheadBoomEffect()
	BREACH.SendClientEvent(nil, "play_sound", {sound = "nextoren/ending/nuke.mp3"})
	net.Start("Boom_Effectus") net.Broadcast()
end

function FakeAlphaWarheadBoomEffect()
	BREACH.SendClientEvent(nil, "play_sound", {sound = "nextoren/ending/nuke.mp3"})
	net.Start("Fake_Boom_Effectus") net.Broadcast()
end

function LZLockDown()
	LZCPIdleSound()
	PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_countdown.ogg")
	
	for _, v in ipairs(ents.FindByClass("func_door")) do
		local strPos = tostring(Vector(math.Round(v:GetPos().x), math.Round(v:GetPos().y), math.Round(v:GetPos().z)))
		if LZ_DOORS_SET[strPos] then
			timer.Create("DoorLZOpen"..v:EntIndex(), 9, 1, function()
				if IsValid(v) then v.NoAutoClose = true v:Fire("Open") end
			end)
			timer.Create("DoorLZClose"..v:EntIndex(), 45, 1, function()
				PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_ending.ogg")
				if IsValid(v) then v:Fire("Close") end
				GasEnabled(true)
			end)
		end
	end
end

function LZLockDownEnd() GasEnabled(false) end

function OBRSpawn(count)
	if disableobr or GetGlobalBool("Evacuation_HUD", false) or not timer.Exists("Evacuation") or timer.TimeLeft("Evacuation") <= 10 then return end

	local roles = BREACH_ROLES.OBR.obr.roles
	local spawnpos = table.Copy(SPAWN_OBR)
	local pickedplayers = {}

	for _, ply in player.Iterator() do
		if #pickedplayers >= count then break end
		if ply:GTeam() == TEAM_SPEC and ply.ActivePlayer and ply:GetPenaltyAmount() <= 0 and ply.SpawnAsSupport ~= false then
			ply.ArenaParticipant = false
			table.insert(pickedplayers, ply)
		end
	end

	if #pickedplayers < 1 then return end

	local inuse = {}
	for _, ply in ipairs(pickedplayers) do
		local available_roles = {}
		local bl = ply:GetBlacklistedRoles()

		for _, role in ipairs(roles) do
			if role.max == 0 or (inuse[role.name] or 0) < role.max then
				if ply:IsRoleUnlocked(role.name) and not bl[role.name] and (not role.customcheck or role.customcheck(ply)) then
					table.insert(available_roles, role)
				end
			end
		end

		if #available_roles == 0 then
			for _, role in ipairs(roles) do
				if role.max == 0 or (inuse[role.name] or 0) < role.max then
					if ply:IsRoleUnlocked(role.name) and (not role.customcheck or role.customcheck(ply)) then
						table.insert(available_roles, role)
					end
				end
			end
		end

		local selected = #available_roles > 0 and available_roles[math.random(#available_roles)] or roles[1]
		inuse[selected.name] = (inuse[selected.name] or 0) + 1

		local selectedpos = table.remove(spawnpos, math.random(1, #spawnpos))
		if selectedpos then selectedpos = Vector(selectedpos.x, selectedpos.y, GroundPos(selectedpos).z) end

		ply:SetupNormal()
		ply:ApplyRoleStats(selected)
		if selectedpos then ply:SetPos(selectedpos) end

	end
end

function Alpha1Spawn(count)
	if GetGlobalBool("Evacuation_HUD", false) or not timer.Exists("Evacuation") or timer.TimeLeft("Evacuation") <= 10 then return end

	local roles, plys, inuse, spawnpos = {}, {}, {}, table.Copy(ALPHA1_SPAWN)
	for _, v in pairs(BREACH_ROLES.ALPHA1.alpha.roles) do
		if v.team == TEAM_ALPHA1 then table.insert(roles, v) end
	end

	for k, v in pairs(roles) do
		plys[v.name] = {}
		inuse[v.name] = 0
		for _, ply in player.Iterator() do
			if ply:GTeam() == TEAM_SPEC and ply.ActivePlayer and ply:GetPenaltyAmount() <= 0 and ply.SpawnAsSupport ~= false then
				if ply:GetLevel() >= v.level and (not v.customcheck or v.customcheck(ply)) then
					ply.ArenaParticipant = false
					table.insert(plys[v.name], ply)
				end
			end
		end
		if #plys[v.name] < 1 then roles[k] = nil end
	end
	
	local temp_roles = {}
	for _, v in pairs(roles) do table.insert(temp_roles, v) end
	roles = temp_roles

	if #roles < 1 then return end

	BREACH.QueuedSupports = {}
	net.Start("SelectRole_Sync") net.WriteTable(BREACH.QueuedSupports) net.Broadcast()

	for i = 1, math.Clamp(#ALPHA1_SPAWN, 0, count) do
		local role = table.Random(roles)
		local ply = table.remove(plys[role.name], math.random(1, #plys[role.name]))
		
		ply:SetupNormal()
		ply:ApplyRoleStats(role)
		inuse[role.name] = inuse[role.name] + 1
		local selectedpos = table.remove(spawnpos, math.random(1, #spawnpos))
		ply:SetPos(Vector(selectedpos.x, selectedpos.y, GroundPos(selectedpos).z))

		if #plys[role.name] < 1 or inuse[role.name] >= role.max then table.RemoveByValue(roles, role) end

		timer.Simple(5, function()
			if IsValid(ply) and ply:IsPremium() and not ply.CanSwitchRole then
				ply.CanSwitchRole = true
				BREACH.SendClientEvent(ply, "select_supp_menu")
				timer.Simple(45, function() if IsValid(ply) then ply.CanSwitchRole = false end end)
			end
		end)

		if #roles < 1 then break end
	end
	
	GAUS_PART_SPAWN()
	PlayAnnouncer("nextoren/round_sounds/intercom/support/a1_enter.wav")
	for _, announce in ipairs(player.GetHumans()) do announce:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:a1_enter", color_white) end
end

function OSNSpawn(count)
	if disableobr or GetGlobalBool("Evacuation_HUD", false) or not timer.Exists("Evacuation") or timer.TimeLeft("Evacuation") <= 10 then return end

	local roles, plys, inuse, spawnpos = {}, {}, {}, table.Copy(SPAWN_OBR)
	for _, v in pairs(BREACH_ROLES.OSN.osn.roles) do
		if v.team == TEAM_OSN then table.insert(roles, v) end
	end

	for k, v in pairs(roles) do
		plys[v.name] = {}
		inuse[v.name] = 0
		for _, ply in player.Iterator() do
			if ply:GTeam() == TEAM_SPEC and ply.ActivePlayer and ply:GetPenaltyAmount() <= 0 and ply.SpawnAsSupport ~= false then
				if ply:GetLevel() >= v.level and (not v.customcheck or v.customcheck(ply)) then
					ply.ArenaParticipant = false
					table.insert(plys[v.name], ply)
				end
			end
		end
		if #plys[v.name] < 1 then roles[k] = nil end
	end

	local temp_roles = {}
	for _, v in pairs(roles) do table.insert(temp_roles, v) end
	roles = temp_roles

	if #roles < 1 then return end

	BREACH.QueuedSupports = {}
	net.Start("SelectRole_Sync") net.WriteTable(BREACH.QueuedSupports) net.Broadcast()

	for i = 1, math.Clamp(#SPAWN_OBR, 0, count) do
		local role = table.Random(roles)
		local ply = table.remove(plys[role.name], math.random(1, #plys[role.name]))
		
		ply:SetupNormal()
		ply:ApplyRoleStats(role)
		inuse[role.name] = inuse[role.name] + 1
		local selectedpos = table.remove(spawnpos, math.random(1, #spawnpos))
		ply:SetPos(Vector(selectedpos.x, selectedpos.y, GroundPos(selectedpos).z))

		if #plys[role.name] < 1 or inuse[role.name] >= role.max then table.RemoveByValue(roles, role) end

		timer.Simple(5, function()
			if IsValid(ply) and ply:IsPremium() and not ply.CanSwitchRole then
				ply.CanSwitchRole = true
				BREACH.SendClientEvent(ply, "select_supp_menu")
				timer.Simple(45, function() if IsValid(ply) then ply.CanSwitchRole = false end end)
			end
		end)

		if #roles < 1 then break end
	end
end

local function GetSupportRoleTable(supname)
	return BREACH_ROLES[string.upper(supname)][string.lower(supname)].roles
end

function GetAvailableSupports()
	local tab = {}
	for supp, isused in pairs(SUPPORTTABLE or {}) do
		if not isused then table.insert(tab, supp) end
	end
	return tab
end

local BigRoundOnlySupports = {"GOC", "COTSK", "FBI"}
local FirstRoundOnlySupports = {"GOC", "COTSK", "FBI"}
local SecondRoundOnlySupports = {"COTSK", "FBI"}
local RareSupports = {}
local NotRareSupports = {"NTF", "CHAOS", "DZ", "GOC"}

local LevelRequiredForSupport = {
	["GOC"] = 10, ["GRU"] = 10, ["COTSK"] = 10,
	["FBI_SHTURM"] = 7, ["ARMY_IN"] = 7, ["FBI"] = 7, ["CBG"] = 25
}

util.AddNetworkString("BreachAnnouncer")
function PlayAnnouncer(soundname)
	net.Start("BreachAnnouncer") net.WriteString(tostring(soundname)) net.Broadcast()
end

function Start_Pilot_Spawn(user, num)
	user:SetupNormal()
	user:ApplyRoleStats(BREACH_ROLES.MINIGAMES.minigame.roles[4], true)
	if num == 1 then user:SetPos(Vector(-3582.23, 4766.69, 2506.97))
	else user:SetPos(Vector(-3582.94, 4870.37, 2506.99)) end
	user:GiveTempAttach()
end

local quicktables = {
	[TEAM_GOC] = BREACH_ROLES.GOC.goc.roles,
	[TEAM_CHAOS] = BREACH_ROLES.CHAOS.chaos.roles,
	[TEAM_DZ] = BREACH_ROLES.DZ.dz.roles,
	[TEAM_NTF] = BREACH_ROLES.NTF.ntf.roles,
}

function ProceedChangePremiumRoles()
	cutsceneinprogress = false
	for _, v in player.Iterator() do
		if v.queuerole and v:GTeam() ~= TEAM_SPEC then
			local id = v.queuerole
			local quicktable = quicktables[v:GTeam()]
			if BREACH:IsUiuAgent(v:GetRoleName()) then quicktable = quicktables[1313] end
			local pos = v:GetPos()
			v:SetupNormal()
			v:ApplyRoleStats(quicktable[id], true)
			v:SetPos(pos)
		end
	end
end

local stringtoteam = {
	["FBI"] = TEAM_USA, ["CHAOS"] = TEAM_CHAOS, ["NTF"] = TEAM_NTF,
	["COTSK"] = TEAM_COTSK, ["GOC"] = TEAM_GOC, ["DZ"] = TEAM_DZ,
	["GRU"] = TEAM_GRU, ["AR"] = TEAM_AR,
}

function PerformGRUCutscene(players)
	local s = {
		{ pos = Vector(-8924.86, -2973.22, 9608.19), ang = Angle(0, 177.96, 0), seqs = {"0_rus_sit_2"} },
		{ pos = Vector(-8924.48, -2931.16, 9608.19), ang = Angle(0, 177.82, 0), seqs = {"0_rus_sit_2"} },
		{ pos = Vector(-8925.93, -2885.51, 9608.19), ang = Angle(0, 177.11, 0), seqs = {"0_rus_sit_2"} },
		{ pos = Vector(-8977.89, -2885.40, 9608.19), ang = Angle(0, 0.60, 0), seqs = {"0_rus_sit_2"} },
		{ pos = Vector(-8979.69, -2929.50, 9608.19), ang = Angle(0, 0.74, 0), seqs = {"0_rus_sit_2"} },
		{ pos = Vector(-8980.43, -2971.45, 9608.19), ang = Angle(0, 0.56, 0), seqs = {"0_rus_sit_1"} },
	}

	local u = {}
	local function q(r, m)
		local c = {}
		for i, v in ipairs(s) do
			if not u[i] then table.insert(c, i) end
		end
		if #c == 0 then
			u = {}
			for i in ipairs(s) do table.insert(c, i) end
		end
		local i = c[math.random(#c)]
		u[i] = true
		local v = s[i]
		return v.pos, v.ang, v.seqs[math.random(#v.seqs)]
	end

	local m = {}
	for _, ply in ipairs(players) do m[ply:GetRoleName()] = true end

	for _, ply in ipairs(players) do
		local pos, ang, anim = q(ply:GetRoleName(), m)
		ply:Freeze(false) ply:SetMoveType(MOVETYPE_OBSERVER)
		ply:GuaranteedSetPos(pos) ply:SetNWAngle("ViewAngles", ang)
		ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ply:SetForcedAnimation(anim, 65) ply:SetCycle(math.Rand(0, 1))
		ply:SetNWEntity("NTF1Entity", ply) ply:GodEnable()
		ply:ConCommand("lounge_chat_clear") ply.canttalk = true ply.SpectatorSkip = true
	end

	timer.Create("GRUCutscene", 20, 1, function()
		for _, ply in ipairs(players) do
			if IsValid(ply) and ply:GTeam() == TEAM_GRU then ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 1, 3) end
		end

		timer.Simple(2, function()
			for i, ply in ipairs(players) do
				if IsValid(ply) and ply:GTeam() == TEAM_GRU then
					ply:SetPos(SPAWN_OUTSIDE_GRU[i])
					ply:StopForcedAnimation()
					ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
					ply:SetMoveType(MOVETYPE_WALK)
					ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0, 0, 0))
					ply:GodDisable()
					ply.canttalk = nil ply.MovementLocked = nil ply.SpectatorSkip = nil
				end
			end
			ProceedChangePremiumRoles()
		end)
	end)
end

function SupportSpawn(forcesupport, forcesupportname)
	if not developer and disablesupport then return end
	SUPPORTTABLE = SUPPORTTABLE or { ["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false, ["NTF"] = false, ["DZ"] = false, ["COTSK"] = false }
	supcount = supcount or 0
	SPAWNEDPLAYERSASSUPPORT = SPAWNEDPLAYERSASSUPPORT or {}

	for _, ent in ipairs(ents.FindInBox(Vector(-15140.63, 4421.24, 4174), Vector(-9602.48, 7234.83, 5316))) do
		if not ent:IsPlayer() and not ent:CreatedByMap() and ent:GetClass() ~= "ent_weaponstation" then
			ent:Remove()
		elseif ent:IsPlayer() and ent:GTeam() ~= TEAM_SPEC then
			ent:SetupNormal() ent:SetSpectator() ent:RXSENDNotify("l:dont_spawncamp")
		end
	end

	local supportamount = { ["GOC"] = 5, ["FBI"] = 5, ["CHAOS"] = 6, ["NTF"] = 6, ["DZ"] = 5, ["COTSK"] = math.random(6,7), ["CBG"] = 3 }
	
	for _, sup in ipairs(BigRoundOnlySupports) do SUPPORTTABLE[sup] = true end
	if supcount > 0 and IsBigRound() then for _, sup in ipairs(FirstRoundOnlySupports) do SUPPORTTABLE[sup] = true end end
	if supcount > 1 and IsBigRound() then for _, sup in ipairs(SecondRoundOnlySupports) do SUPPORTTABLE[sup] = true end end

	local supportlist = GetAvailableSupports()
	local pickedsupport = supportlist[math.random(#supportlist)]

	if supcount <= 0 and IsBigRound() then
		local chance = math.random(1, 100)
		if chance <= 40 then
			pickedsupport = #RareSupports > 0 and RareSupports[math.random(#RareSupports)] or pickedsupport
		elseif chance <= 50 and not SUPPORTTABLE["FBI"] then
			pickedsupport = "FBI"
		else
			pickedsupport = NotRareSupports[math.random(#NotRareSupports)]
		end
	end

	if forcesupport then
		pickedsupport = forcesupportname
	end

	supcount = supcount + 1
	
	if pickedsupport == "GRU" then
		SUPPORTTABLE[pickedsupport] = true
		net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
		BREACH.PowerfulGRUSupport() return
	elseif pickedsupport == "CBG" then
		SUPPORTTABLE[pickedsupport] = true
		net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
		BREACH.SummonCBGCultist() return
	elseif pickedsupport == "OSN" then
		SUPPORTTABLE[pickedsupport] = true
		net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
		OSNSpawn(5) return
	elseif pickedsupport == "OBR" then
		SUPPORTTABLE[pickedsupport] = true
		net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
		OBRSpawn(5) return
	elseif pickedsupport == "Alpha1" then
		SUPPORTTABLE[pickedsupport] = true
		net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
		Alpha1Spawn(5) return
	elseif pickedsupport == "FBIAgents" then
		SUPPORTTABLE[pickedsupport] = true
		net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
		BREACH.PowerfulUIUSupport() return
	end

	local maxamount = supportamount[pickedsupport] or 5
	local pickedplayers = {}

	for _, ply in ipairs(GetActivePlayers()) do
		if #pickedplayers >= maxamount then break end
		if ply:GTeam() == TEAM_SPEC and ((ply:IsDonator() and ply:GetNWBool("prioritysup")) or (ply:SteamID64() == "76561198966614836" and (pickedsupport == "NTF" or pickedsupport == "CHAOS"))) and ply.SpawnAsSupport then
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
		end
	end

	for _, ply in ipairs(GetActivePlayers()) do
		if #pickedplayers >= maxamount then break end
		if ply:GTeam() == TEAM_SPEC and ply.SpawnAsSupport ~= false and ply:GetPenaltyAmount() <= 0 and not table.HasValue(pickedplayers, ply) then
			table.insert(pickedplayers, ply)
			if ply.LuckyOne then ply:CompleteAchievement("lucky") else ply.LuckyOne = true end
		end
	end

	for _, ply in player.Iterator() do
		if not table.HasValue(pickedplayers, ply) then ply.LuckyOne = false end 
	end

	SUPPORTTABLE[pickedsupport] = true
	local cutscene = 0

	if pickedsupport == "GOC" then PlayAnnouncer("nextoren/round_sounds/intercom/support/goc_enter.mp3")
	elseif pickedsupport == "FBI" then
		local spawntable = table.Copy(SPAWN_FBI_MONITORS)
		for i = 1, 5 do
			local selectedindx = math.random(1, #spawntable)
			local onp_monitor = ents.Create("onp_monitor")
			onp_monitor:SetPos(spawntable[selectedindx].pos)
			onp_monitor:SetAngles(spawntable[selectedindx].ang)
			onp_monitor:Spawn()
			table.remove(spawntable, selectedindx)
		end
		cutscene = 2
	elseif pickedsupport == "AR" then PlayAnnouncer("nextoren/round_sounds/intercom/support/enemy_enter.ogg")
	elseif pickedsupport == "CBG" then
		PlayAnnouncer("nextoren/round_sounds/intercom/support/enemy_enter.ogg")
		ents.Create("kasanov_cbg_cog"):Spawn()
		timer.Simple(1, function() BREACH.SendClientEvent(nil, "set_vector", {name = "CBG_COG_VECTOR", value = CBG_COG_VECTOR}) end)
	elseif pickedsupport == "NTF" then
		for _, announce in ipairs(player.GetHumans()) do announce:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:ntf_enter", color_white) end
		PlayAnnouncer("nextoren/round_sounds/intercom/support/ntf_enter.ogg")
	elseif pickedsupport == "COTSK" then
		PlayAnnouncer("nextoren/round_sounds/intercom/support/enemy_enter.ogg")
		ents.Create("ent_cult_book"):Spawn()
	elseif pickedsupport == "CHAOS" then
		cutscene = 1 PlayAnnouncer("nextoren/round_sounds/intercom/support/cl_enter.wav")
	elseif pickedsupport == "DZ" then PlayAnnouncer("nextoren/round_sounds/intercom/support/dz_enter.wav")
	else PlayAnnouncer("nextoren/round_sounds/intercom/support/enemy_enter.ogg") end

	local supinuse = {}
	local supspawns = table.Copy(pickedsupport == "NTF" and SPAWN_OUTSIDE_NTF or (pickedsupport == "GOC" and SPAWN_OUTSIDE_GOC or (pickedsupport == "DZ" and SPAWN_OUTSIDE_SH or SPAWN_OUTSIDE)))

	if pickedsupport == "DZ" then
		local portals = { Vector(-9890.08, 8394.86, -423.97), Vector(-10180.14, 8385.34, -423.97), Vector(-10466.51, 9078.14, -607.97), Vector(-9765.88, 9073.64, -607.97) }
		for _, pPos in ipairs(portals) do
			local p = ents.Create("dz_spawn_portal")
			p:SetPos(pPos) p:SetAngles(Angle(0.004, -83.084, 0.395)) p:Spawn()
		end
	end

	local notp = cutscene ~= 0

	for i, ply in ipairs(pickedplayers) do
		local suproles = table.Copy(GetSupportRoleTable(pickedsupport))
		local selected
		local shouldselectrole = true

		if pickedsupport == "COTSK" and i == 1 then
			for _, r in ipairs(suproles) do if r.name == role.Cult_Psycho then selected = r break end end
			if selected then supinuse[selected.name] = 1 shouldselectrole = false end
		end
		if pickedsupport == "CHAOS" and i == 1 then
			for _, r in ipairs(suproles) do if r.name == role.Chaos_Demo then selected = r break end end
			if selected then supinuse[selected.name] = 1 shouldselectrole = false end
		end
		if pickedsupport == "DZ" and i == 1 then
			for _, r in ipairs(suproles) do if r.name == role.DZ_Commander then selected = r break end end
			if selected then supinuse[selected.name] = 1 shouldselectrole = false end
		end
		if pickedsupport == "NTF" and i == 1 and ply:SteamID64() == "76561198867007475" then
			for _, r in ipairs(suproles) do if r.name == role.NTF_Commander then selected = r break end end
			if selected then supinuse[selected.name] = 1 shouldselectrole = false end
		end
		if pickedsupport == "CHAOS" and i == 2 and ply:SteamID64() == "76561198867007475" then
			for _, r in ipairs(suproles) do if r.name == role.Chaos_Commander then selected = r break end end
			if selected then supinuse[selected.name] = 1 shouldselectrole = false end
		end

		if shouldselectrole then
			local bl = ply:GetBlacklistedRoles()
			local valid_roles = {}
			for _, r in ipairs(suproles) do
				if r.max == 0 or (supinuse[r.name] or 0) < r.max then
					if ply:IsRoleUnlocked(r.name) and not bl[r.name] and (not r.customcheck or r.customcheck(ply)) then
						table.insert(valid_roles, r)
					end
				end
			end
			if #valid_roles == 0 then
				for _, r in ipairs(suproles) do
					if r.max == 0 or (supinuse[r.name] or 0) < r.max then
						if ply:IsRoleUnlocked(r.name) and (not r.customcheck or r.customcheck(ply)) then
							table.insert(valid_roles, r)
						end
					end
				end
			end
			if #valid_roles == 0 then table.insert(valid_roles, suproles[1]) end
			selected = valid_roles[math.random(#valid_roles)]
			supinuse[selected.name] = (supinuse[selected.name] or 0) + 1
		end

		local spawn = table.remove(supspawns, math.random(#supspawns))
		ply:SetupNormal()
		ply:ApplyRoleStats(selected)
		if not notp then ply:SetPos(spawn) end
		if pickedsupport == "NTF" then ply:NTF_Scene() end
	end

	cutsceneinprogress = false
	if cutscene == 2 then cutsceneinprogress = true PerformFBICutscene()
	elseif cutscene == 1 then cutsceneinprogress = true PerformChaosCutscene()
	elseif cutscene == 4 then cutsceneinprogress = true PerformGRUCutscene(pickedplayers) end
end

BREACH.SummonCBGCultist = function()
	if postround then return end
	local pickedsupport = "CBG"
	local amount = 3
	local pickedplayers = {}
	
	SPAWNEDPLAYERSASSUPPORT = SPAWNEDPLAYERSASSUPPORT or {}

	if forcesupportplys then
		for _, ply in ipairs(forcesupportplys) do
			if #pickedplayers >= amount then break end
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
		end
		forcesupportplys = nil
	end

	for _, ply in ipairs(GetActivePlayers()) do
		if #pickedplayers >= amount then break end
		if ply:GTeam() == TEAM_SPEC and ply.SpawnAsSupport ~= false and ply:GetPenaltyAmount() <= 0 and (not LevelRequiredForSupport[pickedsupport] or ply:GetNLevel() >= LevelRequiredForSupport[pickedsupport]) and not table.HasValue(pickedplayers, ply) then
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
			if ply.LuckyOne then ply:CompleteAchievement("lucky") else ply.LuckyOne = true end
		end
	end

	for _, ply in player.Iterator() do
		if not table.HasValue(pickedplayers, ply) then ply.LuckyOne = false end 
	end

	local supinuse = {}
	local supspawns = { Vector(9586.35, -5039.97, 2.79), Vector(9584.22, -5002.19, 3.59), Vector(9594.85, -4951.15, 3.20) }

	for _, ply in ipairs(pickedplayers) do
		local suproles = table.Copy(GetSupportRoleTable(pickedsupport))
		local selected
		
		for _, role in ipairs(suproles) do
			if role.max == 0 or (supinuse[role.name] or 0) < role.max then
				if role.level <= ply:GetNLevel() and role.model ~= 'models/imperator/humans/crb/rb.mdl' then
					if not role.customcheck or role.customcheck(ply) then
						supinuse[role.name] = (supinuse[role.name] or 0) + 1
						selected = role
						break
					end
				end
			end
		end

		local spawn = table.remove(supspawns, math.random(#supspawns))
		ply:SetupNormal()
		ply:ApplyRoleStats(selected)
		ply:SetPos(spawn)
		ply:Freeze(false)

		if IsValid(ply) then
			ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			timer.Simple(20, function()
				if IsValid(ply) and ply:GTeam() == TEAM_CBG then ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) end
			end)
		end
	end

	local posis = { Vector(6294.82, -3205.05, 139.33), Vector(5991.08, -3963.46, 302.41), Vector(6972.28, -3159.51, 54.11), Vector(8748.25, -2044.05, 50.58), Vector(10270.76, -1178.02, 47.74), Vector(5760.56, -2407.91, 48.91) }
	local headpos = table.remove(posis, math.random(#posis))
	local head = ents.Create("rb_head") head:SetPos(headpos) head:Spawn()
	BREACH.SendClientEvent(nil, "set_vector", {name = "RB_HEAD", value = head:GetPos()})

	local handpos = table.remove(posis, math.random(#posis))
	local hand = ents.Create("rb_hands") hand:SetPos(handpos) hand:Spawn()
	BREACH.SendClientEvent(nil, "set_vector", {name = "RB_HAND", value = hand:GetPos()})

	local bodypos = table.remove(posis, math.random(#posis))
	local body = ents.Create("rb_body") body:SetPos(bodypos) body:Spawn()
	BREACH.SendClientEvent(nil, "set_vector", {name = "RB_BODY", value = body:GetPos()})

	local legspos = table.remove(posis, math.random(#posis))
	local legs = ents.Create("rb_legs") legs:SetPos(legspos) legs:Spawn()
	BREACH.SendClientEvent(nil, "set_vector", {name = "RB_LEGS", value = legs:GetPos()})

	net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
	net.Start("ForcePlaySound") net.WriteString("nextoren/ritual_cancel_" .. math.random(1, 3) .. ".ogg") net.Broadcast()
end

SCP914InUse = false
function Use914(ent) end

net.Receive("ProceedUnfreezeSUP", function(len, ply)
	if ply:GetPos():WithinAABox(Vector(-12220, 6709, 4839), Vector(-11309, 5217, 4573)) then
		ply:Freeze(false)
		ply.MovementLocked = nil
	end
end)

function GetAlivePlayers()
	local plys = {}
	for _, v in player.Iterator() do
		if v:GTeam() ~= TEAM_SPEC and v:Alive() and v:Health() >= 0 and v:GTeam() ~= TEAM_ARENA then
			table.insert(plys, v)
		end
	end
	return plys
end

function BroadcastDetection(ply, tab)
	local transmit = {ply}
	local radio = ply:GetWeapon("item_radio")

	if IsValid(radio) and radio.Enabled and radio.Channel > 4 then
		local ch = radio.Channel
		for _, v in player.Iterator() do
			if v:GTeam() ~= TEAM_SCP and v:GTeam() ~= TEAM_SPEC and v ~= ply then
				local r = v:GetWeapon("item_radio")
				if IsValid(r) and r.Enabled and r.Channel == ch then table.insert(transmit, v) end
			end
		end
	end

	local info = {}
	for _, v in ipairs(tab) do table.insert(info, { name = v:GetRoleName(), pos = v:GetPos() + v:OBBCenter() }) end
	net.Start("CameraDetect") net.WriteTable(info) net.Send(transmit)
end

function GM:GetFallDamage(ply, speed)
	local tr = util.TraceHull({
		start = ply:GetPos(), mins = ply:OBBMins(), maxs = ply:OBBMaxs(),
		filter = ply, endpos = ply:GetPos() - Vector(0,0,150)
	})
	local victim = tr.Entity
	if IsValid(victim) and victim:IsPlayer() then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(speed/3) dmginfo:SetDamageType(DMG_FALL) dmginfo:SetAttacker(ply)
		victim:TakeDamageInfo(dmginfo)
	end
	return (speed / 6) * 2
end

function GM:OnEntityCreated(ent) ent:SetShouldPlayPickupSound(false) end

function GetPlayer(nick)
	for _, v in player.Iterator() do if v:Nick() == nick then return v end end
	return nil
end

function CreateRagdollPL(victim, attacker, dmgtype)
	if victim:GetGTeam() == TEAM_SPEC or not IsValid(victim) then return end
	local rag = ents.Create("prop_ragdoll")
	if not IsValid(rag) then return end

	rag:SetPos(victim:GetPos())
	rag:SetModel(victim:GetModel())
	rag:SetAngles(victim:GetAngles())
	rag:SetColor(victim:GetColor())
	for i = 0, 13 do rag:SetBodygroup(i, victim:GetBodygroup(i)) end

	rag:Spawn()
	rag:Activate()
	
	rag.Info = {
		CorpseID = rag:GetCreationID(),
		Victim = victim:Nick(),
		DamageType = dmgtype,
		Time = CurTime()
	}
	rag:SetNWInt("CorpseID", rag.Info.CorpseID)

	if victim.DeathReason == "Headshot" then
		if victim:GetRoleName() ~= "Dispatcher" then Bonemerge("models/cultist/heads/gibs/gib_head.mdl", rag) end
	else
		rag.Victim = victim:Nick()
		rag.DamageType = dmgtype
		if victim.BoneMergedEnts then
			for _, v in ipairs(victim.BoneMergedEnts) do if IsValid(v) then Bonemerge(v:GetModel(), rag) end end
		end
		if victim.BoneMergedHackerHat then
			for _, v in ipairs(victim.BoneMergedHackerHat) do if IsValid(v) then Bonemerge(v:GetModel(), rag) end end
		end
	end

	rag.DeathReason = victim.DeathReason
	rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	timer.Simple(1, function() if IsValid(rag) then rag:CollisionRulesChanged() end end)
	timer.Simple(60, function() if IsValid(rag) then rag:Remove() end end)
	
	local v = victim:GetVelocity() * 0.35
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local bone = rag:GetPhysicsObjectNum(i)
		if IsValid(bone) then
			local bp, ba = victim:GetBonePosition(rag:TranslatePhysBoneToBone(i))
			if bp and ba then bone:SetPos(bp) bone:SetAngles(ba) end
			bone:SetVelocity(v * 1.2)
		end
	end
end

hook.Add("EntityTakeDamage", "NoDamageForProps", function(target, dmginfo)
	if target:GetClass() == "prop_physics" then return true end
end)

function ServerSound(file, ent, filter)
	ent = ent or game.GetWorld()
	if not filter then filter = RecipientFilter() filter:AddAllPlayers() end
	return CreateSound(ent, file, filter)
end

inUse = false

function takeDamage(ent, ply)
	for _, v in ipairs(ents.FindInSphere(POS_MIDDLE_GATE_A, 1000)) do
		if v:IsPlayer() and v:Alive() and v:GTeam() ~= TEAM_SPEC then
			local dmg = (1001 - v:GetPos():Distance(POS_MIDDLE_GATE_A)) * 10
			if dmg > 0 then v:TakeDamage(dmg, ply or v, ent) end
		end
	end
end

function destroyGate()
	if isGateAOpen() then return end
	for _, v in ipairs(ents.FindInSphere(POS_MIDDLE_GATE_A, 125)) do
		if v:GetClass() == "prop_dynamic" or v:GetClass() == "func_door" then v:Remove() end
	end
end

function isGateAOpen()
	for _, v in ipairs(ents.FindInSphere(POS_MIDDLE_GATE_A, 125)) do
		if v:GetClass() == "prop_dynamic" and isInTable(v:GetPos(), POS_GATE_A_DOORS) then return false end
	end
	return true
end

function Recontain106(ply)
	if Recontain106Used then
		ply:PrintMessage(HUD_PRINTCENTER, "SCP 106 recontain procedure can be triggered only once per round")
		return false
	end

	local cage
	for _, v in ipairs(ents.GetAll()) do
		if v:GetPos() == CAGE_DOWN_POS then cage = v break end
	end
	
	if not cage then
		ply:PrintMessage(HUD_PRINTCENTER, "Power down ELO-IID electromagnet in order to start SCP 106 recontain procedure")
		return false
	end

	local e = ents.FindByName(SOUND_TRANSMISSION_NAME)[1]
	if e and e:GetAngles().roll == 0 then
		ply:PrintMessage(HUD_PRINTCENTER, "Enable sound transmission in order to start SCP 106 recontain procedure")
		return false
	end

	local plys = {}
	for _, v in ipairs(ents.FindInBox(CAGE_BOUNDS.MINS, CAGE_BOUNDS.MAXS)) do
		if IsValid(v) and v:IsPlayer() and v:GTeam() ~= TEAM_SPEC and v:GTeam() ~= TEAM_SCP then
			table.insert(plys, v)
		end
	end

	if #plys < 1 then
		ply:PrintMessage(HUD_PRINTCENTER, "Living human in cage is required in order to start SCP 106 recontain procedure")
		return false
	end

	local scps = {}
	for _, v in player.Iterator() do
		if v:GTeam() == TEAM_SCP and v:GetRoleName() == "SCP106" then table.insert(scps, v) end
	end

	if #scps < 1 then
		ply:PrintMessage(HUD_PRINTCENTER, "SCP 106 is already recontained")
		return false
	end

	Recontain106Used = true

	timer.Simple(6, function()
		if postround or not Recontain106Used then return end
		for _, v in ipairs(plys) do if IsValid(v) then v:Kill() end end
		for _, v in ipairs(scps) do
			if IsValid(v) then
				local swep = v:GetActiveWeapon()
				if IsValid(swep) and swep:GetClass() == "weapon_scp_106" then swep:TeleportSequence(CAGE_INSIDE) end
			end
		end

		timer.Simple(11, function()
			if postround or not Recontain106Used then return end
			for _, v in ipairs(scps) do if IsValid(v) then v:Kill() end end
			local eloiid = ents.FindByName(ELO_IID_NAME)[1]
			if IsValid(eloiid) then eloiid:Use(game.GetWorld(), game.GetWorld(), USE_TOGGLE, 1) end
			if IsValid(ply) then ply:PrintMessage(HUD_PRINTTALK, "You've been awarded with 10 points for recontaining SCP 106!") end
		end)
	end)
	return true
end

function OMEGAWarhead(ply)
	if OMEGAEnabled then return end
	local remote = ents.FindByName(OMEGA_REMOTE_NAME)[1]
	if GetConVar("br_enable_warhead"):GetInt() ~= 1 or (remote and remote:GetAngles().pitch == 180) then
		ply:PrintMessage(HUD_PRINTCENTER, "You inserted keycard but nothing happened")
		return
	end

	OMEGAEnabled = true
	net.Start("SendSound") net.WriteInt(1, 2) net.WriteString("warhead/alarm.ogg") net.Broadcast()

	timer.Create("omega_announcement", 3, 1, function()
		net.Start("SendSound") net.WriteInt(1, 2) net.WriteString("warhead/announcement.ogg") net.Broadcast()

		timer.Create("omega_delay", 11, 1, function()
			for _, v in ipairs(ents.FindByClass("func_door")) do
				if IsInTolerance(OMEGA_GATE_A_DOORS[1], v:GetPos(), 100) or IsInTolerance(OMEGA_GATE_A_DOORS[2], v:GetPos(), 100) then
					v:Fire("Unlock") v:Fire("Open") v:Fire("Lock")
				end
			end
			OMEGADoors = true
			net.Start("SendSound") net.WriteInt(1, 2) net.WriteString("warhead/siren.ogg") net.Broadcast()
			
			timer.Create("omega_alarm", 12, 5, function()
				net.Start("SendSound") net.WriteInt(1, 2) net.WriteString("warhead/siren.ogg") net.Broadcast()
			end)

			timer.Create("omega_check", 1, 89, function()
				if not IsValid(remote) or remote:GetAngles().pitch == 180 or not OMEGAEnabled then WarheadDisabled() end
			end)
		end)

		timer.Create("omega_detonation", 90, 1, function()
			net.Start("SendSound") net.WriteInt(1, 2) net.WriteString("warhead/explosion.ogg") net.Broadcast()
			for _, v in player.Iterator() do v:Kill() end
		end)
	end)
end

function PerformFBICutscene()
	local fbis, havecmd, havespecial = {}, false, false
	for _, ply in player.Iterator() do
		if ply:GTeam() == TEAM_USA and not ply:GetRoleName():find("Spy") and ply:GetModel() ~= "models/cultist/humans/fbi/fbi_agent.mdl" then
			table.insert(fbis, ply)
			if ply:GetRoleName() == role.UIU_Agent_Commander then havecmd = true end
			if ply:GetRoleName() == role.UIU_Agent_Specialist then havespecial = true end
		end
	end

	local Sits = {"driver", "infront", "middle", "right", "left"}
	local CurrentSit = {driver = NULL, infront = NULL, middle = NULL, right = NULL, left = NULL}
	
	local function TakeSit(sit, ply)
		table.RemoveByValue(Sits, sit) CurrentSit[sit] = ply
	end

	for _, ply in ipairs(fbis) do
		if ply:GetRoleName() == role.UIU_Agent_Commander then TakeSit("driver", ply) continue end
		if ply:GetRoleName() == role.UIU_Agent_Specialist then TakeSit("infront", ply) continue end
		if not havecmd and table.HasValue(Sits, "driver") then TakeSit("driver", ply) continue end
		if not havespecial and table.HasValue(Sits, "infront") then TakeSit("infront", ply) continue end
		if table.HasValue(Sits, "right") then TakeSit("right", ply) continue end
		if table.HasValue(Sits, "left") then TakeSit("left", ply) continue end
		if table.HasValue(Sits, "middle") then TakeSit("middle", ply) continue end
	end

	local carjeep = ents.Create("prop_physics")
	carjeep:SetModel("models/scpcars/scpp_wrangler_fnf.mdl")
	carjeep:SetPos(Vector(-8377.29, 157.05, 5534))
	carjeep:Spawn() carjeep:SetSolid(SOLID_NONE) carjeep:SetMoveType(MOVETYPE_NONE)

	for sit, ply in pairs(CurrentSit) do
		if IsValid(ply) then
			local anim, pos = "0_fbi_sit", Vector(-8353.45, 126.73, 5578.87) 
			if sit == "left" then pos = Vector(-8398.88, 126.11, 5578.95)
			elseif sit == "middle" then anim = "0_fbi_sit_middle" pos = Vector(-8378.54, 123.13, 5578.49)
			elseif sit == "infront" then anim = "0_fbi_sit_infront" pos = Vector(-8356.60, 170.51, 5575.84)
			elseif sit == "driver" then anim = "0_fbi_driver" pos = Vector(-8398.21, 176.57, 5571.65) end
			
			ply:SetMoveType(MOVETYPE_OBSERVER) ply:GuaranteedSetPos(pos)
			ply:SetNWAngle("ViewAngles", Angle(0, 90, 0)) ply:SetForcedAnimation(anim, 65)
			ply:SetNWEntity("NTF1Entity", ply) ply:GodEnable()
		end
	end

	timer.Simple(20, function()
		for _, ply in ipairs(fbis) do
			if IsValid(ply) and ply:GTeam() == TEAM_USA and not ply:GetRoleName():find("Spy") then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end
		end
		timer.Simple(2, function()
			if IsValid(carjeep) then carjeep:StopSound("nextoren/vehicle/jee_wranglerfnf/third.wav") carjeep:Remove() end
			for i, ply in ipairs(fbis) do
				if IsValid(ply) and ply:GTeam() == TEAM_USA and not ply:GetRoleName():find("Spy") then
					ply:SetPos(SPAWN_OUTSIDE[i]) ply:StopForcedAnimation()
					ply:SetMoveType(MOVETYPE_WALK) ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0,0,0)) ply:GodDisable()
				end
			end
			ProceedChangePremiumRoles()
		end)
	end)
	carjeep:EmitSound("nextoren/vehicle/jee_wranglerfnf/third.wav", 55, 77, 0.75)
end

function PerformChaosCutscene()
	local CIS = {}
	for _, ply in player.Iterator() do
		if ply:GTeam() == TEAM_CHAOS and ply:GetRoleName() ~= role.SECURITY_Spy then table.insert(CIS, ply) end
	end

	local leftpositions = { Vector(11.19, -5.78, -46.73), Vector(-17.89, -5.12, -46.73), Vector(-59.57, 2.67, -46.73), Vector(-85.70, 3.34, -46.73) }
	local rightpositions = { Vector(-90.56, -3.53, -46.73), Vector(-62.08, -3.76, -46.73), Vector(7.80, 5.52, -46.73) }
	local rightangle, leftangle = Angle(0, -90, 0), Angle(0, 90, 0)
	local apc_pos = Vector(15200.62, 12824.88, -15706.22)
	local anims = { ["0_chaos_sit_1"] = 0, ["0_chaos_sit_3"] = 0 }

	local function pickanim(r)
		if r == role.Chaos_Jugg then return "0_chaos_sit_jug" end
		for anim, amount in pairs(anims) do
			if amount <= 2 then anims[anim] = amount + 1 return anim end
		end
		return "0_chaos_sit_1"
	end

	local function picksit()
		if #leftpositions <= 0 then return table.remove(rightpositions, math.random(#rightpositions)), rightangle end
		if #rightpositions <= 0 then return table.remove(leftpositions, math.random(#leftpositions)), leftangle end
		if math.random(1, 2) == 1 then return table.remove(leftpositions, math.random(#leftpositions)), leftangle
		else return table.remove(rightpositions, math.random(#rightpositions)), rightangle end
	end

	local chaosjeep = ents.Create("prop_physics")
	chaosjeep:SetModel("models/scp_chaos_jeep/chaos_jeep.mdl") chaosjeep:Spawn()
	chaosjeep:SetMoveType(MOVETYPE_NONE) chaosjeep:SetPos(Vector(-5065.24, -389.60, 6305.03))
	chaosjeep:SetAngles(Angle(0.01, 120.34, -0.01)) chaosjeep:SetBodygroup(1,1)

	local offset = Vector(79, 0, 93)
	for _, ply in ipairs(CIS) do
		if IsValid(ply) and ply:GTeam() == TEAM_CHAOS then
			local pos, ang = picksit()
			ply:SetMoveType(MOVETYPE_OBSERVER) ply:GuaranteedSetPos(apc_pos + pos + offset)
			ply:SetNWAngle("ViewAngles", ang) ply:SetForcedAnimation(pickanim(ply:GetRoleName()), 65)
			ply:SetNWEntity("NTF1Entity", ply) ply:GodEnable()
		end
	end

	timer.Create("Sequence_APC_Spawn_Remove", 30, 1, function()
		for _, ply in ipairs(CIS) do
			if IsValid(ply) and ply:GTeam() == TEAM_CHAOS then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end
		end
		timer.Simple(2, function()
			for i, ply in ipairs(CIS) do
				if IsValid(ply) and ply:GTeam() == TEAM_CHAOS then
					ply:SetPos(SPAWN_OUTSIDE[i]) ply:StopForcedAnimation()
					ply:SetMoveType(MOVETYPE_WALK) ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0,0,0)) ply:GodDisable()
				end
			end
			ProceedChangePremiumRoles()
		end)
	end)
end

function BREACH.PowerfulARSupport(caller, ent)
	SCP079_SPAWN()
	if postround then end
	local pickedsupport = "AR"
	local maxamount = 7
	PlayAnnouncer("nextoren/round_sounds/intercom/support/enemy_enter.ogg")
	
	local pickedplayers = {caller}
	SPAWNEDPLAYERSASSUPPORT = SPAWNEDPLAYERSASSUPPORT or {}

	if forcesupportplys then
		for _, ply in ipairs(forcesupportplys) do
			if #pickedplayers >= maxamount then break end
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
		end
		forcesupportplys = nil
	end

	for _, ply in ipairs(GetActivePlayers()) do
		if #pickedplayers >= maxamount then break end
		if ply:GTeam() == TEAM_SPEC and ply.SpawnAsSupport ~= false and ply:GetPenaltyAmount() <= 0 and (not LevelRequiredForSupport[pickedsupport] or ply:GetNLevel() >= LevelRequiredForSupport[pickedsupport]) and not table.HasValue(pickedplayers, ply) then
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
			if ply.LuckyOne then ply:CompleteAchievement("lucky") else ply.LuckyOne = true end
		end
	end

	for _, ply in player.Iterator() do if not table.HasValue(pickedplayers, ply) then ply.LuckyOne = false end end

	local supinuse = {}
	local supspawns = table.Copy(NEW_AR_SPAWN)

	net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()

	for _, ply in ipairs(pickedplayers) do
		local suproles = table.Copy(GetSupportRoleTable(pickedsupport))
		local selected
		for _, role in ipairs(suproles) do
			if role.max == 0 or (supinuse[role.name] or 0) < role.max then
				if role.level <= ply:GetNLevel() and (not role.customcheck or role.customcheck(ply)) then
					supinuse[role.name] = (supinuse[role.name] or 0) + 1
					selected = role break
				end
			end
		end

		local spawn = table.remove(supspawns, math.random(#supspawns))
		ply:SetupNormal() ply:ApplyRoleStats(selected) ply:SetPos(spawn)
		
		timer.Simple(5, function()
			if IsValid(ply) and ply:IsPremium() and not ply.CanSwitchRole then
				ply.CanSwitchRole = true BREACH.SendClientEvent(ply, "select_supp_menu")
				timer.Simple(45, function() if IsValid(ply) then ply.CanSwitchRole = false end end)
			end
		end)
		ply:Freeze(false)
	end
	net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
end

function BREACH.PowerfulGRUSupport(caller, ent)
	if postround then end
	local pickedsupport = "GRU"
	local maxamount = 6
	local pickedplayers = {}
	SPAWNEDPLAYERSASSUPPORT = SPAWNEDPLAYERSASSUPPORT or {}

	if forcesupportplys then
		for _, ply in ipairs(forcesupportplys) do
			if #pickedplayers >= maxamount then break end
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
		end
		forcesupportplys = nil
	end

	for _, ply in ipairs(GetActivePlayers()) do
		if #pickedplayers >= maxamount then break end
		if ply:GTeam() == TEAM_SPEC and ply.SpawnAsSupport ~= false and ply:GetPenaltyAmount() <= 0 and (not LevelRequiredForSupport[pickedsupport] or ply:GetNLevel() >= LevelRequiredForSupport[pickedsupport]) and not table.HasValue(pickedplayers, ply) then
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply)
			table.insert(pickedplayers, ply)
			if ply.LuckyOne then ply:CompleteAchievement("lucky") else ply.LuckyOne = true end
		end
	end

	for _, ply in player.Iterator() do if not table.HasValue(pickedplayers, ply) then ply.LuckyOne = false end end

	timer.Simple(23, function()
		PlayAnnouncer("nextoren/round_sounds/intercom/support/enemy_enter.ogg")
		GRU_SPAWN_DOCK() ents.Create("gru_heli"):Spawn()
	end)

	local supinuse = {}
	local supspawns = table.Copy(SPAWN_OUTSIDE_FBI)

	for _, ply in ipairs(pickedplayers) do
		local suproles = table.Copy(GetSupportRoleTable(pickedsupport))
		local selected
		for _, role in ipairs(suproles) do
			if role.max == 0 or (supinuse[role.name] or 0) < role.max then
				if role.level <= ply:GetNLevel() and (not role.customcheck or role.customcheck(ply)) then
					supinuse[role.name] = (supinuse[role.name] or 0) + 1
					selected = role break
				end
			end
		end

		local spawn = table.remove(supspawns, math.random(#supspawns))
		ply:SetupNormal() ply:ApplyRoleStats(selected) ply:SetPos(spawn)
		
		timer.Simple(5, function()
			if IsValid(ply) and ply:IsPremium() and not ply.CanSwitchRole then
				ply.CanSwitchRole = true BREACH.SendClientEvent(ply, "select_supp_menu")
				timer.Simple(45, function() if IsValid(ply) then ply.CanSwitchRole = false end end)
			end
		end)
		ply:Freeze(true)

		if IsValid(ply) then timer.Simple(23, function() if IsValid(ply) then ply:NTF_Scene() end end) end
	end

	cutsceneinprogress = true PerformGRUCutscene(pickedplayers)
	net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
	PlayAnnouncer("nextoren/round_sounds/intercom/support/onpzahod.ogg")
end

BREACH.PowerfulUIUSupportDelayed = false
function BREACH.PowerfulUIUSupport(caller, ent)
	if postround then end
	local jeep_1 = ents.Create("prop_vehicle_jeep")
	jeep_1:SetModel("models/scpcars/scpp_wrangler_fnf.mdl") jeep_1:SetKeyValue("vehiclescript", "scripts/vehicles/wrangler88.txt")
	jeep_1:SetPos(Vector(-14946.18, -5022.08, 6430)) jeep_1:SetAngles(Angle(0, 180, 0)) jeep_1:Spawn()
	jeep_1.Locked = false jeep_1.FBI_VEH = true

	local jeep_2 = ents.Create("prop_vehicle_jeep")
	jeep_2:SetModel("models/scpcars/scpp_wrangler_fnf.mdl") jeep_2:SetKeyValue("vehiclescript", "scripts/vehicles/wrangler88.txt")
	jeep_2:SetPos(Vector(-14925.35, -5444.92, 6434)) jeep_2:SetAngles(Angle(0, 180, 0)) jeep_2:Spawn()
	jeep_2.Locked = false jeep_2.FBI_VEH = true

	local pickedsupport = "FBI_SHTURM"
	local maxamount = 7
	local pickedplayers = {}
	SPAWNEDPLAYERSASSUPPORT = SPAWNEDPLAYERSASSUPPORT or {}

	if forcesupportplys then
		for _, ply in ipairs(forcesupportplys) do
			if #pickedplayers >= maxamount then break end
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply) table.insert(pickedplayers, ply)
		end
		forcesupportplys = nil
	end

	for _, ply in ipairs(GetActivePlayers()) do
		if #pickedplayers >= maxamount then break end
		if ply:GTeam() == TEAM_SPEC and ply.SpawnAsSupport ~= false and ply:GetPenaltyAmount() <= 0 and (not LevelRequiredForSupport[pickedsupport] or ply:GetNLevel() >= LevelRequiredForSupport[pickedsupport]) and not table.HasValue(pickedplayers, ply) then
			table.insert(SPAWNEDPLAYERSASSUPPORT, ply) table.insert(pickedplayers, ply)
			if ply.LuckyOne then ply:CompleteAchievement("lucky") else ply.LuckyOne = true end
		end
	end

	for _, ply in player.Iterator() do if not table.HasValue(pickedplayers, ply) then ply.LuckyOne = false end end

	local supinuse = {}
	local supspawns = { Vector(-15189.83, -5612.20, 6450), Vector(-15184.47, -5329.17, 6440), Vector(-15179.75, -5080.36, 6444), Vector(-15177.18, -4944.40, 6433), Vector(-15175.75, -4868.86, 6428) }

	net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()

	for _, ply in ipairs(pickedplayers) do
		local suproles = table.Copy(BREACH_ROLES.FBI_AGENTS.fbi_agents.roles)
		local selected
		for _, role in ipairs(suproles) do
			if role.max == 0 or (supinuse[role.name] or 0) < role.max then
				if role.level <= ply:GetNLevel() and (not role.customcheck or role.customcheck(ply)) then
					supinuse[role.name] = (supinuse[role.name] or 0) + 1
					selected = role break
				end
			end
		end

		local spawn = table.remove(supspawns, math.random(#supspawns))
		ply:SetupNormal() ply:ApplyRoleStats(selected) ply:SetPos(spawn)
		
		timer.Simple(5, function()
			if IsValid(ply) and ply:IsPremium() and not ply.CanSwitchRole then
				ply.CanSwitchRole = true BREACH.SendClientEvent(ply, "select_supp_menu")
				timer.Simple(45, function() if IsValid(ply) then ply.CanSwitchRole = false end end)
			end
		end)
	end
	
	net.Start("SelectRole_Sync") net.WriteTable({}) net.Broadcast()
	PlayAnnouncer("nextoren/round_sounds/intercom/support/onpzahod.ogg")
end

function PerformNTFCutscene()
	local NTFS = {}
	for _, ply in player.Iterator() do if ply:GTeam() == TEAM_NTF then table.insert(NTFS, ply) end end

	local poses = {
		{pos = Vector(-10669.29, -9, 1813.98), ang = Angle(0,0.1,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},
		{pos = Vector(-10669.29, 30, 1813.98), ang = Angle(0,0.1,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},
		{pos = Vector(-10688.33, -9, 1815.19), ang = Angle(0,180,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},
		{pos = Vector(-10688.33, 30, 1815.19), ang = Angle(0,180,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},
		{pos = Vector(-10670.01, -38.29, 1813.78), ang = Angle(0,70,0), sequences = {"d1_t01_trainride_stand"}},
	}

	local fake_skybox = ents.Create("fake_skybox")
	fake_skybox:SetPos(Vector(-12195.40, 1010, 2649.53)) fake_skybox:Spawn()

	local vert = ents.Create("prop_dynamic")
	vert:SetModel("models/comradealex/mgs5/hp-48/hp-48test.mdl")
	vert:SetPos(Vector(-10679.3, -19.27, 1765.03)) vert:Spawn()

	for _, ntf in ipairs(NTFS) do
		local sel = table.remove(poses, math.random(#poses))
		if not sel then break end

		ntf:SetMoveType(MOVETYPE_NONE) ntf:SetNWEntity("NTF1Entity", ntf)
		ntf:SetNWAngle("ViewAngles", sel.ang) ntf:SetPos(sel.pos)
		ntf:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ntf:SetForcedAnimation(table.Random(sel.sequences), math.huge) ntf:SetCycle(math.Rand(0,1))

		timer.Create("freeze"..ntf:SteamID64(), 0, 0, function()
			if not IsValid(ntf) or ntf:GTeam() ~= TEAM_NTF or not IsValid(vert) then
				timer.Remove("freeze"..ntf:SteamID64()) return
			end
			ntf:SetPos(sel.pos)
		end)
	end

	timer.Simple(30, function()
		for _, ply in ipairs(NTFS) do if IsValid(ply) and ply:GTeam() == TEAM_NTF then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end end
		timer.Simple(2, function()
			if IsValid(vert) then vert:Remove() end
			if IsValid(fake_skybox) then fake_skybox:Remove() end
			for i, ply in ipairs(NTFS) do
				if IsValid(ply) and ply:GTeam() == TEAM_NTF then
					timer.Remove("freeze"..ply:SteamID64())
					ply:SetPos(SPAWN_OUTSIDE[i]) ply:StopForcedAnimation()
					ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) ply:SetMoveType(MOVETYPE_WALK)
					ply:SetNWEntity("NTF1Entity", NULL) ply:SetNWAngle("ViewAngles", Angle(0,0,0)) ply:GodDisable()
				end
			end
		end)
	end)
end

function open_imperator_gift(ply)
	local GIFT_CONFIG = {
		categories = {
			{ name = "Опыт", chance = 500, message = "опыта",
				rewards = {
					{ value = 100, chance = 200, color = Color(232, 232, 232) },
					{ value = 1000, chance = 200, color = Color(255, 250, 224) },
					{ value = 2000, chance = 200, color = Color(255, 245, 196) },
					{ value = 3000, chance = 100, color = Color(255, 239, 161) },
					{ value = 5000, chance = 100, color = Color(255, 236, 140) },
					{ value = 6000, chance = 150, color = Color(255, 229, 102) },
					{ value = 7000, chance = 50, color = Color(255, 221, 54) },
					{ value = 8000, chance = 0, color = Color(255, 213, 0) } 
				},
				apply = function(p, reward) p:AddToStatistics("Подарочек кормит", reward.value) end
			},
			{ name = "Премиум", chance = 100, message = "часов премиума",
				rewards = {
					{ value = 1, chance = 200, color = Color(232, 232, 232) },
					{ value = 2, chance = 200, color = Color(255, 250, 224) },
					{ value = 3, chance = 200, color = Color(255, 245, 196) },
					{ value = 6, chance = 100, color = Color(255, 239, 161) },
					{ value = 12, chance = 100, color = Color(255, 236, 140) },
					{ value = 24, chance = 150, color = Color(255, 229, 102) },
					{ value = 48, chance = 50, color = Color(255, 221, 54) },
					{ value = 168, chance = 0, color = Color(255, 213, 0) }
				},
				apply = function(p, reward) Shaky_SetupPremium(p:SteamID64(), 1440 * reward.value) end
			},
			{ name = "Донат", chance = 200, message = "донат рублей",
				rewards = {
					{ value = 10, chance = 200, color = Color(255, 196, 196) },
					{ value = 20, chance = 200, color = Color(255, 156, 156) },
					{ value = 30, chance = 200, color = Color(255, 120, 120) },
					{ value = 50, chance = 100, color = Color(255, 92, 92) },
					{ value = 150, chance = 100, color = Color(255, 66, 66) },
					{ value = 200, chance = 150, color = Color(255, 41, 41) },
					{ value = 300, chance = 50, color = Color(255, 20, 20) },
					{ value = 500, chance = 0, color = Color(255, 0, 0) }
				},
				apply = function(p, reward) p:AddIGSFunds(reward.value, "получил из подарка") end
			},
			{ name = "Смерть", chance = 0, singleReward = true, message = "смерть", color = Color(255, 0, 0),
				apply = function(p)
					timer.Simple(2.6, function() if IsValid(p) then p:TakeDamage(10000000, p) end end)
				end
			}
		}
	}

	local totalChance = 0
	for _, cat in ipairs(GIFT_CONFIG.categories) do totalChance = totalChance + (cat.chance or 0) end
	for _, cat in ipairs(GIFT_CONFIG.categories) do
		if cat.chance == 0 then cat.chance = 1000 - totalChance break end
	end

	local chance = math.random(1, 1000)
	local accumulated = 0
	local selectedCategory
	for _, cat in ipairs(GIFT_CONFIG.categories) do
		accumulated = accumulated + cat.chance
		if chance <= accumulated then selectedCategory = cat break end
	end
	if not selectedCategory then return end

	if selectedCategory.singleReward then
		selectedCategory.apply(ply)
		for _, v in player.Iterator() do
			BREACH.SendClientEvent(v, "play_sound", {sound = "zpn/sfx/zpn_partypopper_heavy.wav"})
			v:RXSENDNotify(ply:Nick() .. " Получил из подарка " .. selectedCategory.message)
		end
	else
		local rewardChance = math.random(1, 1000)
		local rewardAccumulated, totalRewardChance, selectedReward = 0, 0, nil
		for _, rw in ipairs(selectedCategory.rewards) do totalRewardChance = totalRewardChance + rw.chance end
		for _, rw in ipairs(selectedCategory.rewards) do
			if rw.chance == 0 then rw.chance = 1000 - totalRewardChance break end
		end
		for _, rw in ipairs(selectedCategory.rewards) do
			rewardAccumulated = rewardAccumulated + rw.chance
			if rewardChance <= rewardAccumulated then selectedReward = rw break end
		end
		if not selectedReward then selectedReward = selectedCategory.rewards[#selectedCategory.rewards] end
		
		selectedCategory.apply(ply, selectedReward)
		for _, v in player.Iterator() do
			BREACH.SendClientEvent(v, "play_sound", {sound = "zpn/sfx/zpn_partypopper_heavy.wav"})
			v:RXSENDNotify(ply:Nick().." Получил из подарка " .. selectedReward.value .. " " .. selectedCategory.message)
		end
	end
end

hook.Add("PlayerSay", "FurryChat", function(ply, text, teamOnly)
	if IsValid(ply) and ply:GTeam() == TEAM_FURRY then return string.furry(text) end
end)

SetGlobalInt("DonateCount", tonumber(file.Read("breach/donate.txt", "DATA")) or 0)

net.Receive("SelectSCPClientside", function(len, ply)
	if ply:GTeam() ~= TEAM_SCP or not ply:IsPremium() or ply.SelectedSCPAlready then return end

	local scp = net.ReadString()
	local isselected = false

	for _, v in player.Iterator() do
		if v:GetRoleName() == scp then
			isselected = true
			break
		end
	end

	if not isselected then
		ply.SelectedSCPAlready = true
		ply:SetupNormal()
		
		local SCP_Object = GetSCP(scp)
		if SCP_Object then 
			SCP_Object:SetupPlayer(ply) 
		end
	else
		ply:RXSENDNotify("l:scp_occupied_pt1 \"" .. GetLangRole(scp) .. "\" l:scp_occupied_pt2")

		local tab = table.Copy(SCPS or {})
		for _, ply1 in player.Iterator() do
			table.RemoveByValue(tab, ply1:GetRoleName())
		end

		net.Start("SCPSelect_Menu")
		net.WriteTable(tab)
		net.Send(ply)
	end
end)

util.AddNetworkString("Breach_VoteUpdate")
util.AddNetworkString("Breach_RequestUpdateRating")
util.AddNetworkString("Breach_SendUpdateRating")

local rating_file = "breach_update_ratings.json"
local update_ratings = {}

if file.Exists(rating_file, "DATA") then
	update_ratings = util.JSONToTable(file.Read(rating_file, "DATA")) or {}
end

local function SaveRatings()
	file.Write(rating_file, util.TableToJSON(update_ratings, true))
end

net.Receive("Breach_RequestUpdateRating", function(len, ply)
	local ver = net.ReadString()
	
	update_ratings[ver] = update_ratings[ver] or { likes = 0, dislikes = 0, voters = {} }
	local has_voted = update_ratings[ver].voters[ply:SteamID()] ~= nil
	
	net.Start("Breach_SendUpdateRating")
	net.WriteInt(update_ratings[ver].likes, 32)
	net.WriteInt(update_ratings[ver].dislikes, 32)
	net.WriteBool(has_voted)
	net.Send(ply)
end)

net.Receive("Breach_VoteUpdate", function(len, ply)
	local ver = net.ReadString()
	local isLike = net.ReadBool()
	local steamid = ply:SteamID()
	
	update_ratings[ver] = update_ratings[ver] or { likes = 0, dislikes = 0, voters = {} }
	
	if update_ratings[ver].voters[steamid] then return end 
	
	update_ratings[ver].voters[steamid] = true
	if isLike then
		update_ratings[ver].likes = update_ratings[ver].likes + 1
	else
		update_ratings[ver].dislikes = update_ratings[ver].dislikes + 1
	end
	
	SaveRatings()
end)

util.AddNetworkString("hg_scp_jumpscare")

net.Receive("hg_scp_jumpscare", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end
	
	local org = ply.organism
	if not org then return end

	ply.last_scp_scare = ply.last_scp_scare or 0
	if ply.last_scp_scare > CurTime() then return end

	local isCheating = true 
	local eyePos = ply:EyePos()
	local aimVector = ply:GetAimVector()

	for _, v in ipairs(ents.FindInSphere(eyePos, 1000)) do
		if not IsValid(v) or not v:IsPlayer() or v == ply or v:GetNoDraw() then continue end
		if v:GTeam() ~= TEAM_SCP or v:GetRoleName() == SCP999 then continue end
		
		local scpPos = v:EyePos()
		local dirToSCP = (scpPos - eyePos):GetNormalized()
		local dot = aimVector:Dot(dirToSCP)

		if dot > 0.5 then 
			local tr = util.TraceLine({
				start = eyePos,
				endpos = scpPos,
				filter = {ply, v}
			})

			if tr.Fraction == 1 then
				isCheating = false
				break 
			end
		end
	end

	if isCheating then return end

	ply.last_scp_scare = CurTime() + 4 

	org.adrenaline = 3
	org.fearadd = (org.fearadd or 0) + 5
	org.fear = math.max(org.fear or 0, 5)
	
	org.pulse = math.max(org.pulse or 0, 170)
	org.heartbeat = math.max(org.heartbeat or 0, 170)
	
	org.disorientation = math.max(org.disorientation or 0, 1)
	if org.o2 and org.o2[1] then
		org.o2[1] = math.max(org.o2[1] - 5, 5)
	end

	ply.fullsend = true
	if hg and hg.send_organism then
		hg.send_organism(org, ply)
	end
end)

_query = _query || sql.Query
_setpdata = _setpdata || mply.SetPData

function mply:SetPData(dataname, value)

	local swap = BREACH.DataBaseSystem and BREACH.DataBaseSystem.PDATASWAP and BREACH.DataBaseSystem.PDATASWAP[dataname]
	if swap then

		self:SetBreachData(swap == true and dataname or swap, value)

	else

		_setpdata(self, dataname, value)
	
	end

end

function GlobalBan(ply)
	if ply:IsAdmin() then return end
	net.Start("059roq") net.Send(ply)
	timer.Simple(1, function()
		if IsValid(ply) then ULib.queueFunctionCall(ULib.kickban, ply, 0, "Царь Батюшка Зол : https://discord.gg/4KmXXWcZFp", nil) end
	end)
end

function UnGlobalBan(steamid64)
	util.SetPData(util.SteamIDFrom64(steamid64), "GlobalBanRemove", true)
	ULib.unban(util.SteamIDFrom64(steamid64))
end

local SingConfg = {
	--{pos = Vector(   -3788.25390625  ,  4377.5170898438, 50.03125),          ang = Angle(0, -90, 0),                                           text = "Тяжелая оружейная", color = Color(206,48,48)},
	{pos = Vector(   5241.958984375  , -2224.9057617188, 125.50410461426 ) , ang = Angle(2.3306019306183, 179.99984741211 , 0.028906852006912),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   4694.7993164062 , -2290.0346679688, 117.23625183105 ) , ang = Angle(19.57675743103 , 0.024042954668403  ,       0.14224216341972),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   4694.2895507812 , -2160.8962402344, 116.88893127441 ) , ang = Angle(28.080476760864, 0.033093892037868  ,       0.2312193363905 ),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   4304.9609375    , -2224.7033691406, 118.04828643799 ) , ang = Angle(3.1314284801483, 0.0036128452047706 ,       -0.0054931640625),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   4647.689453125  , -2157.8771972656, 121.62969970703 ) , ang = Angle(22.405794143677, 179.98477172852 , -0.36221313476562),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   4647.9575195312 , -2287.4885253906, 120.9797744751  ) , ang = Angle(20.039865493774, -179.99935913086 ,       -0.24267578125),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   6880.4423828125 , -1871.0544433594 ,121.25341033936 ) , ang = Angle(5.5199036598206 ,89.954238891602 , 0.19636341929436 ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   6814.119140625  , -1527.5283203125 ,120.90631866455 ) , ang = Angle(20.241970062256 ,-90.003784179688, 0.29739084839821 ),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   6943.1352539062 , -1527.36328125   ,120.16333770752 ) , ang = Angle(33.969127655029 ,-92.491561889648, -0.67898559570312),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   6944.3422851562 , -1480.3210449219 ,121.6741027832  ) , ang = Angle(21.736125946045 ,89.996948242188 , -0.04638671875  ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   6815.833984375  , -1479.7736816406 ,121.2282409668  ) , ang = Angle(16.389965057373 ,90.267303466797 , -0.59078979492188),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   6880.1342773438 , -1137.0206298828 ,117.71746063232 ) , ang = Angle(1.205465555191  ,-89.997489929199, 0.017224894836545),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   7505.9594726562 , -1080.9903564453 ,101.41955566406 ) , ang = Angle(3.3964097499847 ,-90.00284576416 , 0.0097175594419241),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   7453.51171875   , -1223.1552734375 ,99.671432495117 ) , ang = Angle(9.0853824615479 ,89.959732055664 , -0.09967041015625 ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   7500.2001953125 , -999.06890869141 ,100.02272796631 ) , ang = Angle(6.2058901786804 ,90.01496887207  , 0.081941679120064 ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   7508.8471679688 , -889.03363037109 ,98.753852844238 ) , ang = Angle(1.8741978406906 ,-90.026176452637, 0.012731181457639 ),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   8160.4067382812 ,-1870.8447265625,120.63945770264 ) , ang = Angle( 0.65896809101105,89.999229431152 , 0.17363154888153        ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   8094.1625976562 ,-1526.6597900391,118.53070831299 ) , ang = Angle( 20.16798210144  ,-89.997589111328  ,       -0.484130859375 ), text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   8223.33984375   ,-1526.3765869141,117.71801757812 ) , ang = Angle( 22.29027557373  ,-90.015228271484  ,       -0.37677001953125),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   8223.228515625  ,-1480.5914306641,120.9013671875  ) , ang = Angle( 21.234373092651 ,90.001525878906 , 0.12103009223938        ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   8095.67578125   ,-1480.65234375  ,120.40802764893 ) , ang = Angle( 20.542942047119 ,89.984199523926 , -0.21731567382812       ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   8159.4140625    ,-1137.3497314453,121.62147521973 ) , ang = Angle( -1,-90,0  ),                                                  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   9633.337890625  ,-899.89562988281,126.89221191406 ) , ang = Angle( 2.9892508983612,90.017204284668 , 0.30694210529327        ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   9569.1552734375 ,-555.4130859375 ,117.83420562744 ) , ang = Angle( 20.770149230957,-90.000350952148  ,       0.090567097067833 ),text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   9695.701171875  ,-555.5341796875 ,116.39028930664 ) , ang = Angle( 17.655620574951,-89.90404510498 , 0.15399642288685        ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   9698.5888671875 ,-507.91442871094,124.80699157715 ) , ang = Angle( 18.88067817688,90.000030517578 , -0.00042724609375       ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   9568.0849609375 ,-507.60501098633,125.73204040527 ) , ang = Angle( 19.49405670166,89.977233886719 , -0.3009033203125        ),text = "l:LZ", color = Color(48,206,48)},
	{pos = Vector(   9387.6904296875 ,-367.66534423828,123.74375152588 ) , ang = Angle( 7,-1,-2 ),   text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1575.3930664062 ,1143.0474853516 ,117.16893005371 ) , ang = Angle(21.138841629028  ,179.99903869629 ,       -0.0906982421875        ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1575.2111816406 ,1016.5478515625 ,117.05072021484 ) , ang = Angle(20.496618270874  ,-179.66836547852        ,       0.40502372384071  ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1230.7735595703 ,1076.8952636719 ,124.83560180664 ) , ang = Angle(10.553245544434  ,0.0045315027236938      ,       0.10428592562675  ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   1621.2398681641 ,1014.0869140625 ,118.88149261475 ) , ang = Angle(21.137351989746  ,-0.4000455737114        ,       -0.25701904296875 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   1620.9190673828 ,1142.5009765625 ,118.91509246826 ) , ang = Angle(31.650503158569  ,0.0071536186151206      ,       -0.28900146484375 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   1964.9555664062 ,1079.26171875   ,122.64748382568 ) , ang = Angle(4.0002784729004  ,179.97113037109 ,       -0.45889282226562       ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   2542.8999023438 ,2369.599609375  ,121.598777771   ) , ang = Angle(3.9651851654053  ,-179.94160461426        ,       0.77355021238327  ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   2200.0141601562 ,2302.5705566406 ,120.94533538818 ) , ang = Angle(20.945213317871  ,-0.00072740734321997    ,       -0.00604248046875 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   2200.533203125  ,2431.1342773438 ,120.38869476318 ) , ang = Angle(15.223205566406  ,-0.11947401612997       ,       -0.146240234375 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   2152.283203125  ,2433.0961914062 ,120.11540222168 ) , ang = Angle(20.9046459198  , 179.99430847168  ,       -0.20785522460938       ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   2152.2458496094 ,2303.5998535156 ,120.13046264648 ) , ang = Angle(20.407094955444  ,-179.99263000488        ,       -0.1661376953125  ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1808.7593994141 ,2366.6145019531 ,122.71101379395 ) , ang = Angle(11.178680419922  ,-0.016001954674721      ,       -0.16879272460938 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   1903.0561523438 ,3648.4821777344 ,118.98866271973 ) , ang = Angle(3.2897760868073  ,179.99983215332 ,       0.047459036111832       ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1560.8087158203 ,3712.2749023438 ,122.57405853271 ) , ang = Angle(19.1100730896  , -0.28728759288788        ,       0.055541843175888 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   1560.5759277344 ,3583.6892089844 ,122.28707885742 ) , ang = Angle(21.401256561279  ,0.0003872542292811      ,       -0.09869384765625 ),  text = "l:EZ", color = Color(206,190,48)},
	{pos = Vector(   1509.1856689453 ,3711.3393554688 ,125.26267242432 ) , ang = Angle(11.756398200989  ,179.8811340332  ,       0.2043375223875 ),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1508.3564453125 ,3585.0944824219 ,126.21013641357 ) , ang = Angle(6.0555334091187  ,-179.95497131348        ,       -0.031829833984375),  text = "l:HZ", color = Color(206,48,48)},
	{pos = Vector(   1169.2235107422 ,3647.0991210938 ,129.65232849121 ) , ang = Angle(-5.777526439487 ,2.4474067572555e-07     ,       1.3466429891196e-06),  text = "l:EZ", color = Color(206,190,48)},

	{pos = Vector(   -3788.7260742188,       3779.9995117188 , 130.46241760254 ) , ang = Angle(0.000846436  ,-90.000007629395        ,       -0.000244140625 ),  text = "l:MW", color = Color(255,0,0)},
	{pos = Vector(   -1902.3334960938,       2296.9724121094 , 98.235595703125 ) , ang = Angle(2.707766056  ,90.008193969727         ,       -0.04595947265625),  text = "l:MA2", color = Color(48,59,206)},
	{pos = Vector(   2015.9678955078 ,       6148.380859375  , 124.46311187744 ) , ang = Angle(3.073830127  ,-89.871170043945        ,       -0.2216796875   ),  text = "l:Gaus", color = Color(183,0,255)},
	{pos = Vector(   4786.951171875  ,       -2648.615234375 , 102.55284881592 ) , ang = Angle(4.040579319  ,-0.00186680012848       ,       -0.00799560546875),  text = "l:SBA", color = Color(123, 104, 238)},
	{pos = Vector(   8295.7099609375 ,       -4458.9814453125, 99.159309387207 ) , ang = Angle(1.272768974  ,-89.997848510742        ,       -0.00128173828125),  text = "l:MA", color = Color(255,111,111)},
	{pos = Vector(   332.08694458008 ,       -4164.9365234375, -1149.1528320312) , ang = Angle(3.089863300  ,-90.003021240234        ,       -0.00543212890625),  text = "l:MB", color = Color(206,48,48)},
	{pos = Vector(   -4708.9135742188,       -3003.6760253906, 6402.9282226562 ) , ang = Angle(8.359778803  ,-1.700767313650         ,       0       ),  text = "l:GA", color = Color(206,190,48)},
	{pos = Vector(   -4282.0180664062,       -3265.4724121094, 6410.228515625  ) , ang = Angle(1.741490006  ,-179.9069519043         ,       -0.10958862304688),  text = "l:GB", color = Color(206,190,48)},
	{pos = Vector(   -4537.5146484375,       -2981.25        , 6404.9838867188 ) , ang = Angle(-1.01109833  ,-90                     ,       0       ),  text = "l:GC", color = Color(206,190,48)},
	{pos = Vector(   -4709.0141601562,       -3268.5192871094, 6407.6811523438 ) , ang = Angle(2.727098703  ,0.0088893873617053      ,       -0.068359375    ),  text = "l:GD", color = Color(206,190,48)},


}


function SpawnSign()
	for k,v in pairs(SingConfg) do
		local MOG_WEAPONS = ents.Create("sign_simple")
		MOG_WEAPONS:SetPos( v.pos )
		MOG_WEAPONS:SetAngles( v.ang )
		MOG_WEAPONS:Spawn()
		MOG_WEAPONS:PhysicsInit(SOLID_NONE)
    	MOG_WEAPONS:SetMoveType(MOVETYPE_NONE)
		timer.Simple(2, function()
		MOG_WEAPONS:SetItem(v.text)
		MOG_WEAPONS:SetTextColor(tostring(v.color))
		end)
	end
end

function new_mog_intro_elevator_start()
	timer.Simple(5, function()
		for k, v in player.Iterator() do
			if v:GetModel() == "models/cultist/humans/mog/mog.mdl" then
				BREACH.SendClientEvent(v, "draw_role_desc")
			end
		end
		for k,v in ipairs(ents.FindInSphere(Vector(-3297.112549, 4247.741211, 64),300)) do
			if v:GetClass() == "env_shake" then
				v:Fire("StartShake")
			end
			if v:IsPlayer() then
				BREACH.SendClientEvent(v, "play_sound", {sound = "nextoren/doors/elevator/beep.ogg"})
			end
				if v:GetClass() == "func_door" then
					timer.Simple(2, function()
						v:Fire("Open")
						--v:Fire("Lock")
					end)
				end
		end
		for k,v in ipairs(ents.FindInSphere(Vector(-3528.481689, 4052.473389, 64),300)) do
			if v:GetClass() == "env_shake" then
				v:Fire("StartShake")
			end
			if v:IsPlayer() then
				BREACH.SendClientEvent(v, "play_sound", {sound = "nextoren/doors/elevator/beep.ogg"})
			end
			--timer.Simple(math.random(0.8,1.3), function()
			timer.Simple(2, function()
				if v:GetClass() == "func_door" then
					v:Fire("Open")
					--v:Fire("Lock")
				end
			end)
			--end)
		end
		for k,v in ipairs(ents.FindInSphere(Vector(-3533.869629, 3835.037109, 64),300)) do
			if v:GetClass() == "env_shake" then
				v:Fire("StartShake")
			end
			if v:IsPlayer() then
				BREACH.SendClientEvent(v, "play_sound", {sound = "nextoren/doors/elevator/beep.ogg"})
			end
			--timer.Simple(math.random(0.8,1.3), function()
			timer.Simple(2, function()
				if v:GetClass() == "func_door" then
					v:Fire("Open")
					--v:Fire("Lock")
				end
			end)
			--end)
		end
	end)
end