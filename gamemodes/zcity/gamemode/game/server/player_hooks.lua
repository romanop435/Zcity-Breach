local tostring = tostring
local CurTime = CurTime
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



// Serverside file for all player related functions

function CheckIfPlayersStillEnough()
	if #GetActivePlayers() < MINPLAYERS and GetGlobalBool("EnoughPlayersCountDown") then
		for _, v in ipairs(GetActivePlayers()) do
			v:RXSENDNotify("l:not_enough_players")
		end
		BroadcastStopMusic()
		SetGlobalBool("EnoughPlayersCountDown", false)
		timer.Remove("StartRoundBecauseMinPlr")
		waitingplayers = true
		players_warned = false
	elseif #GetActivePlayers() >= 10 and not GetGlobalBool("EnoughPlayersCountDown") and not gamestarted then
		waitingplayers = false
		CheckStart()
	end
end
timer.Create("ENOUGH_PLAYERCHECK", 1, 0, CheckIfPlayersStillEnough)

function CheckStart()
	MINPLAYERS = 10
	if not gamestarted and #GetActivePlayers() >= MINPLAYERS then
		if not players_warned then
			for _, v in player.Iterator() do
				v:RXSENDNotify("l:game_will_start_soon")
			end
			BroadcastPlayMusic(BR_MUSIC_COUNTDOWN)
		end

		players_warned = true

		if not waitingplayers then
			waitingplayers = true
			SetGlobalBool("EnoughPlayersCountDown", true)
			SetGlobalInt("EnoughPlayersCountDownStart", CurTime() + 119)
			timer.Create("StartRoundBecauseMinPlr", 119, 1, function()
				if not gamestarted and #GetActivePlayers() >= MINPLAYERS then
					waitingplayers = false
					players_warned = false
					RoundRestart()
				elseif #GetActivePlayers() <= MINPLAYERS then
					waitingplayers = false
					players_warned = false
					for _, v in player.Iterator() do
						v:RXSENDNotify("l:not_enough_players_for_round_start")
					end
				end
			end)
		end
	end
	
	if gamestarted then
		BREACH.SendClientEvent(nil, "gamestarted", {value = true})
	end
end

function GM:PlayerInitialSpawn(ply)
	print("starting to spawn " .. ply:Name())

	ply:SetCanZoom(false)
	ply:SetNoDraw(true)
	ply.freshspawn = true
	ply.isblinking = false
	player_manager.SetPlayerClass(ply, "class_breach")
	player_manager.RunClass(ply, "SetupDataTables")

	CheckStart()

	timer.Simple(10, function()
		if not IsValid(ply) then return end
		if timer.Exists("RoundTime") then
			net.Start("UpdateTime")
			net.WriteString(tostring(timer.TimeLeft("RoundTime")))
			net.Send(ply)
		end
		if gamestarted then
			BREACH.SendClientEvent(ply, "gamestarted", {value = true})
		end
		ply:SetSpectator()
	end)
end

function GM:PlayerSpawn(ply)
	ply:SetCanZoom(false)
	ply:SetTeam(2)
	ply:SetNoCollideWithTeammates(false)

	if ply.freshspawn then
		ply:SetSpectator()
		local spawn_pos = table.Random(BREACH.MainMenu_Spawns)[1]
		ply:SetPos(spawn_pos)
		ply.freshspawn = false
	end

	ply.JustSpawned = false
end

function GM:PlayerNoClip(ply, desiredState)
	if ply:GTeam() == TEAM_SPEC and desiredState == true then return true end
end

function GM:PlayerDisconnected(ply)
	ply:SetTeam(TEAM_SPEC)
	if player.GetCount() < MINPLAYERS then
		BREACH.SendClientEvent(nil, "gamestarted", {value = false})
		gamestarted = false
	end
	WinCheck()
end

function HaveRadio(pl1, pl2)
	if pl1:HasWeapon("item_radio") and pl2:HasWeapon("item_radio") then
		local r1 = pl1:GetWeapon("item_radio")
		local r2 = pl2:GetWeapon("item_radio")
		if not IsValid(r1) or not IsValid(r2) or pl2:GetActiveWeapon() ~= r1 then return false end
		
		if r1.Enabled and r2.Enabled and r1.Channel == r2.Channel then
			return true
		end
	end
	return false
end

local CanTalkToOtherPlayersSCP = {
	["SCP049"] = true,
	["SCP079"] = true,
	["SCP076"] = true
}

local voiceCache = {}
local CACHE_TIME = 5 

function GM:PlayerCanHearPlayersVoice(Listener, Speaker)
	local currentTime = CurTime()
	local listenerID = Listener:UserID()
	local speakerID = Speaker:UserID()
	
	local cacheKey = listenerID .. "_" .. speakerID
	local cached = voiceCache[cacheKey]
	
	if cached and cached.time > currentTime then
		return cached.canHear, cached.isProximity
	end
	
	local listenerTeam = Listener:GTeam()
	local speakerTeam = Speaker:GTeam()
	
	local canHear = false
	local isProximity = false

	if Speaker:GetNWBool("priorityvoice") then
		canHear = true
	elseif BREACH.Punishment.Gags[Speaker:SteamID()] then
		canHear = false
	else
		if speakerTeam == TEAM_SPEC and listenerTeam == TEAM_SPEC then
			if not Listener.mutespec then
				canHear = true
				isProximity = false
			end
		elseif speakerTeam == TEAM_SCP and listenerTeam == TEAM_SCP then
			canHear = true
		else
			if Speaker:GetPos():DistToSqr(Listener:GetPos()) < 1062500 then
				canHear = true
				isProximity = true
			end
		end
	end
	
	voiceCache[cacheKey] = {
		canHear = canHear,
		isProximity = isProximity,
		time = currentTime + CACHE_TIME
	}
	
	return canHear, isProximity
end

timer.Create("VoiceCacheCleanup", 60, 0, function()
	local currentTime = CurTime()
	for key, data in pairs(voiceCache) do
		if data.time < currentTime then
			voiceCache[key] = nil
		end
	end
end)

hook.Add("PlayerSay", "RXSEND_Mute", function(ply, msg)
	if ply:GTeam() ~= TEAM_SCP and ply:GTeam() ~= TEAM_SPEC then 
		GAMEMODE:DoChatGesture(ply, "", msg) 
	end
	
	if ply.BypassMute then 
		ply.BypassMute = false 
		return msg 
	end
	
	if BREACH.Punishment.Mutes[ply:SteamID()] and (ply:GTeam() == TEAM_SPEC or not string.find(msg, "quickchat_")) then
		ply:RXSENDNotify("l:you_are_muted")
		return ""
	end
end)

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
	if not talker.GetRoleName then
		player_manager.SetPlayerClass(talker, "class_breach")
		player_manager.RunClass(talker, "SetupDataTables")
	end

	if not listener.GetRoleName then
		player_manager.SetPlayerClass(listener, "class_breach")
		player_manager.RunClass(listener, "SetupDataTables")
	end

	if not listener.hasloadedalready or talker.canttalk then return false end

	local lTeam = listener:GTeam()
	local tTeam = talker:GTeam()

	if lTeam == TEAM_SPEC then
		if listener.mutespec and tTeam == TEAM_SPEC then return false end
		if listener.mutealive and tTeam ~= TEAM_SPEC then return false end
	end

	if tTeam == TEAM_SCP and talker:GetInDimension() and talker:GetPos():DistToSqr(listener:GetPos()) < 562500 then
		return true, true
	end
	
	if talker:GetNWBool("IntercomTalking", false) and talker:Alive() and tTeam ~= TEAM_SCP and tTeam ~= TEAM_SPEC and talker:Health() > 0 then
		return true
	end

	if tTeam == TEAM_SPEC and lTeam == TEAM_SPEC then return true end
	if tTeam == TEAM_ARENA and lTeam == TEAM_ARENA then return true end

	if not talker:Alive() then return false end
	if tTeam == TEAM_SPEC or (not talker:Alive() and not listener:Alive()) then return false end
	if not listener:Alive() then return false end
	
	if tTeam == TEAM_SCP then
		if lTeam == TEAM_SCP then
			return true
		elseif lTeam == TEAM_SPEC or lTeam == TEAM_DZ or (talker:GetRoleName() == "SCP939" and not SCPFOOTSTEP["SCP939"]) then
			local distLimit = teamOnly and 2500 or 562500
			return talker:GetPos():DistToSqr(listener:GetPos()) < distLimit
		else
			return false
		end
	end

	if teamOnly then
		if lTeam ~= TEAM_SPEC then
			return talker:GetPos():DistToSqr(listener:GetPos()) < 2500
		end
	end

	if listener.CameraLook and listener:GetViewEntity():GetPos():DistToSqr(talker:GetPos()) < 562500 then
		return true, true
	end

	return talker:GetPos():DistToSqr(listener:GetPos()) < 562500
end

local Squech = Sound("nextoren/weapons/radio/squelch.ogg")

hook.Add("PlayerSay", "Shaky_Radio", function(ply, msg, teamonly)
	if ply:IsFrozen() then return "" end
	
	local lowerMsg = string.lower(msg)
	if string.StartWith(lowerMsg, "!r ") or string.StartWith(lowerMsg, "/r ") then
		if ply:GTeam() == TEAM_SCP then return "" end
		if not ply:IIHasWeapon("item_radio") then ply:RXSENDNotify("l:no_radio") return "" end
		if not ply:GetNWBool("radio_enbl") then ply:RXSENDNotify("l:turn_up_the_radio") return "" end
		
		local msgtext = string.sub(msg, 4)
		if msgtext == "" then ply:RXSENDNotify("l:no_text_radio") return "" end
		
		local plychan = ply:GetNWFloat("radio_chanel")
		ply:EmitSound("^" .. Squech, 76, 100, 2)
		local talkername = ply:GetNamesurvivor()
		ply:RXSENDNotify(Color(0,0,255), "l:radio_in_chat", Color(0, 255, 0), " ["..talkername.."] ", color_white, "<\"", msgtext, "\">")

		if BREACH and BREACH.AdminLogs then
			BREACH.AdminLogs:Log("radio", {
				sender = ply,
				message = "[РАЦИЯ " .. tostring(math.Round(plychan, 1)) .. " MHz] " .. msgtext
			})
		end

		for _, tply in player.Iterator() do
			if tply == ply then continue end
			if not tply:IIHasWeapon("item_radio") then continue end
			if not tply:GetNWBool("radio_enbl") then continue end
			if tply:GetNWFloat("radio_chanel") ~= plychan then continue end

			net.Start("ForcePlaySound")
			net.WriteString(Squech)
			net.Send(tply)

			tply:RXSENDNotify(Color(0,0,255), "l:radio_in_chat", Color(0, 255, 0), " ["..talkername.."] ", color_white, "<\"", msgtext, "\">")
		end
		return ""
	end
end)

local BREACH = BREACH or {}
local gradient = Material("vgui/gradient-r")
local gradients = Material("gui/center_gradient")

util.AddNetworkString("CameraPVS")

net.Receive("CameraPVS", function(len, ply)
	ply.CameraEnabled = net.ReadBool()
end)

hook.Add("SetupPlayerVisibility", "CCTVPVS", function(ply, viewentity)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "item_cameraview" then
		if wep:GetEnabled() and CCTV and CCTV[wep:GetCAM()] and IsValid(CCTV[wep:GetCAM()].ent) then
			AddOriginToPVS(CCTV[wep:GetCAM()].pos) 
		end
	end
	
	if ply:GetTable().CameraEnabled and CamerasTable then
		for i = 1, #CamerasTable do
			AddOriginToPVS(CamerasTable[i].Vector)
		end
	end
end)

function GM:PlayerCanPickupWeapon(ply, wep)
	ply.OnTheGround = true

	if ply.Shaky_PICKUPWEAPON == wep then
		if IsValid(wep) and wep.GetClass then
			BREACH.AdminLogs:Log("pickup", {
				user = ply,
				weapon = wep:GetClass(),
			})
		end
		hook.Run("BreachLog_PickedUpItem", ply, wep) 
		ply.Shaky_PICKUPWEAPON = nil 
		return true 
	end
	
	if ply.JustSpawned or ply.IsLooting then return true end
	
	local team = ply:GTeam()
	if team == TEAM_SCP or team == TEAM_SPEC then
		if team == TEAM_SCP and ply.JustSpawned then return true end
		return false
	end

	if ply:HasWeapon(wep:GetClass()) then return false end
	if not ply:KeyDown(IN_USE) then return false end
	if ply:Health() <= 0 then return false end

	local tr = ply:GetEyeTrace()
end

local button_models = {
	["models/next_breach/entrance_button.mdl"] = true,
	["models/next_breach/hcz_keycard_panel.mdl"] = true,
	["models/next_breach/keycard_panel.mdl"] = true,
}

local function DeepCopy(original)
	if not istable(original) then return original end
	local copy = {}
	for key, value in pairs(original) do
		if istable(value) then
			copy[key] = DeepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end


function GM:PlayerCanPickupItem(ply, item)
	return ply:GTeam() ~= TEAM_SPEC or ply:GetRoleName() == ADMIN
end

function GM:AllowPlayerPickup(ply, ent)
	if ent.funkyragdoll and ply:GTeam() ~= TEAM_SPEC then return true end
	return false
end

function IsInTolerance(spos, dpos, tolerance)
	if spos == dpos then return true end

	if isnumber(tolerance) then
		tolerance = {x = tolerance, y = tolerance, z = tolerance}
	end

	local allaxes = {"x", "y", "z"}
	for _, v in ipairs(allaxes) do
		if spos[v] ~= dpos[v] then
			if tolerance[v] then
				if math.abs(dpos[v] - spos[v]) > tolerance[v] then
					return false
				end
			else
				return false
			end
		end
	end
	return true
end

local trashbins = {
	"models/props_canteen/canteenbin.mdl",
	"models/props_gffice/metalbin01.mdl",
	"models/props_beneric/trashbin002.mdl",
	"models/props_residue/trashcan01.mdl",
}

local trashbinloot = {
	{ 
		"breach_keycard_1", "breach_keycard_sci_1", "breach_keycard_guard_1",
		"breach_keycard_security_1", "copper_coin", "silver_coin",
		"weapon_flashlight", "item_screwdriver", "item_eyedrops_1",
		"item_drink_soda", "item_drink_water",
	},
	{ 
		"breach_keycard_2", "breach_keycard_3", "breach_keycard_security_2",
		"breach_keycard_sci_2", "gold_coin", "item_eyedrops_2",
		"item_eyedrops_3", "item_drink_energy", "item_drink_coffee",
	},
	{ 
		"breach_keycard_guard_2", "breach_keycard_security_2",
		"breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_sci_4",
	},
	{ 
		"breach_keycard_7", "item_keys",
	},
}

local function GetTrashbinLootTable()
	local rand = math.random(1, 100)
	if rand == 1 then return trashbinloot[4]
	elseif rand <= 5 then return trashbinloot[3]
	elseif rand <= 24 then return trashbinloot[2]
	else return trashbinloot[1] end
end

local function LogDoorOpen(ply, ent, name)
	hook.Run("BreachLog_DoorOpen", ply, name)
end

local function LogDoorClose(ply, ent, name)
	hook.Run("BreachLog_DoorClose", ply, name)
end

local function LogElevator(ply, ent, name)
	hook.Run("BreachLog_ElevatorUse", ply, name)
end

local function LogDoorOrElevator(ply, ent, name)
	if ent:GetName():find("elev") then
		LogElevator(ply, ent, name)
	else
		if ent.Opened then
			LogDoorClose(ply, ent, name)
		else
			LogDoorOpen(ply, ent, name)
		end
	end
end

local scp079_sounds = {
	"cpthazama/scp/079/broadcast1.mp3", "cpthazama/scp/079/broadcast2.mp3",
	"cpthazama/scp/079/broadcast3.mp3", "cpthazama/scp/079/broadcast4.mp3",
	"cpthazama/scp/079/broadcast5.mp3", "cpthazama/scp/079/broadcast6.mp3",
	"cpthazama/scp/079/broadcast7.mp3",
}

function ChangeSkinKeypad(ply, ent, state)
	if ent:GetClass() == "func_button" then
		if ent:GetInternalVariable("m_toggle_state") == 1 then
			for _, v in ipairs(ents.FindInSphere(ent:GetPos(), 65)) do
				if IsValid(v) and button_models[v:GetModel()] then
					if state then
						local sid = ply:SteamID64()
						if math.random(1, 100) > 98 and not timer.Exists("SCP079_ROFL_" .. sid) then
							timer.Create("SCP079_ROFL_" .. sid, 5, 1, function() end)
							timer.Simple(0.3, function()
								for _, doorEnt in ipairs(ents.FindInSphere(ent:GetPos(), 200)) do
									if IsValid(doorEnt) and doorEnt:GetClass() == "func_door" then
										doorEnt:Fire("Close")
										doorEnt:Fire("Lock")
										doorEnt:EmitSound(table.Random(scp079_sounds), 85, 100)
										timer.Simple(3, function()
											if IsValid(doorEnt) then doorEnt:Fire("Unlock") end
										end)
									end
								end
								if IsValid(v) then v:SetSkin(2) end
							end)
						end
						v:SetSkin(1)
					else
						v:SetSkin(2)
					end
					
					timer.Create("DefaultButtonSkin" .. v:EntIndex(), 1.8, 1, function()
						if IsValid(v) then v:SetSkin(0) end
					end)
					
					for _, e in ipairs(ents.FindInSphere(v:GetPos() + v:GetAngles():Forward() * -65, 55)) do
						if IsValid(e) and button_models[e:GetModel()] then
							e:SetSkin(state and 1 or 2)
							timer.Create("DefaultButtonSkin" .. e:EntIndex(), 1.8, 1, function()
								if IsValid(e) then e:SetSkin(0) end
							end)
						end
					end
				end
			end
		end
	end
end

function GM:PlayerUse(ply, ent)
	if ply:GTeam() == TEAM_SPEC and ply:GetRoleName() ~= ADMIN then return false end
	if ent:GetModel() == "models/noundation/doors/860_door.mdl" and not SCPLockDownHasStarted then return false end
	if ply:GetRoleName() == ADMIN then return true end
	
	if ply:GetRoleName() == role.SCI_Cleaner then
		if IsValid(ent) and ent:GetClass() == "prop_physics" and ply:KeyPressed(IN_USE) then
			if table.HasValue(trashbins, ent:GetModel()) and ply:GetEyeTrace().Entity == ent and ent:GetPos():DistToSqr(ply:GetPos()) <= 22500 then
				if not ent.CleanerLooted then
					ply:BrProgressBar("l:looting_trash_can", 7, "nextoren/gui/new_icons/hand.png", ent, false, function()
						ent.CleanerLooted = true
						ply:BrTip(0, "l:trashbin_title", Color(124, 226, 129), "l:trashbin_loot_end", Color(255, 255, 255))
						local _t = GetTrashbinLootTable()
						ply:BreachGive(_t[math.random(1, #_t)])
					end, nil, nil)
				else
					ply:BrTip(0, "l:trashbin_title", Color(82, 82, 82), "l:trashbin_empty", Color(255, 255, 255))
				end
			end
		end
	end

	if ply:GetRoleName() == "SCP079" then return false end
	
	ply.lastuse = ply.lastuse or 0
	if ply.lastuse > CurTime() then return false end

	if ent.SCP079_Blocked then
		ent:EmitSound("nextoren/others/access_denied.wav")
		ply:BrTip(0, "l:legacy_breach_title", Color(255, 0, 0), "l:access_denied", Color(255, 255, 255))
		return false
	end

	ent._lastusedby = ply
	ent._lastusedwhen = SysTime()

	if ent:GetName() == "funicularButtonUp" and ent:GetPos().z < -15160 then
		ply.lastuse = CurTime() + 1
		for _, v in ipairs(ents.FindByClass("func_tracktrain")) do
			v:Fire("StartBackward")
		end
	end

	if ent:GetName() == "funicularButtonDown" and ent:GetPos().z > -15160 then
		ply.lastuse = CurTime() + 1
		for _, v in ipairs(ents.FindByClass("func_tracktrain")) do
			v:Fire("StartForward")
		end
	end

	if BUTTONS then
		for _, v in pairs(BUTTONS) do
			if v.pos == ent:GetPos() or (v.tolerance and IsInTolerance(v.pos, ent:GetPos(), v.tolerance)) then
				local name = v.name or v:GetName()
				ply.lastuse = CurTime() + 1

				if v.keycardnotrequired then
					if v.custom_access_granted then
						if v.custom_access_granted(ply, ent) then
							ChangeSkinKeypad(ply, ent, true)
							return true
						else
							ply:BrTip(0, "l:keypad_title", Color(255, 0, 0), "l:access_denied", Color(255, 255, 255))
							ChangeSkinKeypad(ply, ent, false)
							return false
						end
					else
						return true
					end
				end

				if v.access then
					if v.name:find("Ворота") or v.name:find("КПП") then
						if GetGlobalBool("Evacuation", false) then
							if not isnumber(Monitors_Activated) or Monitors_Activated < 5 then
								LogDoorOrElevator(ply, ent, name)
								return true
							end
						end
					end

					if OMEGADoors or (v.levelOverride and v.levelOverride(ply)) or ply:GTeam() == TEAM_FURRY then
						LogDoorOrElevator(ply, ent, name)
						return true
					end

					local wep = ply:GetActiveWeapon()
					if IsValid(wep) and wep:GetClass():find("_keycard_") then
						if not (v.allowed_keycards and v.allowed_keycards[wep:GetClass()]) then
							for key, acses in pairs(v.access) do
								if acses > wep.CLevels[key] then
									if not v.nosound then ply:EmitSound("^nextoren/weapons/keycard/keycarduse_2.ogg") end
									ply:BrTip(0, "l:keypad_title", Color(255, 0, 0), "l:access_denied", Color(255, 255, 255))
									ChangeSkinKeypad(ply, ent, false)
									return false
								end
							end
						end

						if v.custom_access_granted and not v.custom_access_granted(ply, ent) then
							if not v.nosound then ply:EmitSound("^nextoren/weapons/keycard/keycarduse_2.ogg") end
							ply:BrTip(0, "l:keypad_title", Color(255, 0, 0), "l:access_denied", Color(255, 255, 255))
							ChangeSkinKeypad(ply, ent, false)
							return false
						end

						if not v.nosound then ply:EmitSound("^nextoren/weapons/keycard/keycarduse_1.ogg") end
						ply:BrTip(0, "l:keypad_title", Color(150, 255, 136), "l:access_granted", Color(255, 255, 255))
						ent:Fire("use")
						LogDoorOrElevator(ply, ent, name)
						ChangeSkinKeypad(ply, ent, true)
						return true
					else
						ply:BrTip(0, "l:keypad_title", Color(238, 216, 89), "l:keycard_needed", Color(255, 255, 255))
						return false
					end
				end

				if v.canactivate == nil or v.canactivate(ply, ent) then
					LogDoorOrElevator(ply, ent, name)
					return true
				else
					if not v.nosound then ply:EmitSound("^nextoren/weapons/keycard/keycarduse_2.ogg") end
					ply:BrTip(0, "l:keypad_title", Color(255, 0, 0), v.customdenymsg or "l:access_denied", Color(255, 255, 255))
					ChangeSkinKeypad(ply, ent, false)
					return false
				end
			end
		end
	end

	if ent:GetClass() == "func_button" and ent:GetInternalVariable("m_toggle_state") == 1 then
		ChangeSkinKeypad(ply, ent, true)
	end

	return true
end

function GM:CanPlayerSuicide(ply)
	return false
end


function OpenedDoor(index)
	local door = Entity(index)
	if IsValid(door) then door.Opened = true end
end

function ClosedDoor(index)
	local door = Entity(index)
	if IsValid(door) then door.Opened = false end
end

function ElevatorTest(index)
	local button = Entity(index)
	if IsValid(button) and IsValid(button._lastusedby) and button._lastusedby:IsPlayer() then
		print(button.doorentity)
	end
end

function SetupMapLua()
	MapLua = ents.Create("lua_run")
	MapLua:SetName("triggerhook")
	MapLua:Spawn()

	for _, v in ipairs(ents.FindByClass("func_button")) do
		if v:GetName():find("elev") then
			v:Fire("AddOutput", "OnPressed triggerhook:RunPassedCode:ElevatorTest(" .. v:EntIndex() .. ")")
			local closestdoor_dist = math.huge
			local door = NULL

			for _, ent in ipairs(ents.FindInSphere(v:GetPos(), 200)) do
				if IsValid(ent) and ent:GetClass() == "func_door" then
					local dist = v:GetPos():DistToSqr(ent:GetPos())
					if dist < closestdoor_dist then
						closestdoor_dist = dist
						door = ent
					end
				end
			end

			if IsValid(door) and (v:GetName():find("_up") or v:GetName():find("_down")) then
				door.buttonentity = v
			end
		end
	end

	for _, v in ipairs(ents.FindByClass("func_door")) do
		v.Opened = false
		local name = string.lower(v:GetName())
		if not string.find(name, "elev") and not string.find(name, "gate") and not string.find(name, "_lift_") and not string.find(name, "containment") then
			v:SetKeyValue("wait", "2.2")
		end

		v:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:CloseDoor(" .. v:EntIndex() .. ")")
		v:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:OpenedDoor(" .. v:EntIndex() .. ")")
		v:Fire("AddOutput", "OnClose triggerhook:RunPassedCode:ClosedDoor(" .. v:EntIndex() .. ")")
	end

	for _, v in ipairs(ents.FindByClass("func_button")) do
		local name = string.lower(v:GetName())
		if not string.find(name, "elev") and not string.find(name, "gate") and not string.find(name, "containment") then
			v:SetKeyValue("wait", "2.2")
		end
	end

	for _, v in ipairs(ents.FindByClass("func_button")) do
		if string.find(string.lower(v:GetName()), "gate") then
			v:SetKeyValue("wait", "5")
		end
	end
end

hook.Add("InitPostEntity", "SetupMapLua", SetupMapLua)
hook.Add("PostCleanupMap", "SetupMapLua", SetupMapLua)

local blockedkpps = {
	Vector(6880.000000, -1504.000000, 54.299999),
	Vector(7499.200195, -1040.619995, 54.299999),
	Vector(8160.000000, -1504.000000, 54.299999),
	Vector(9633.0302734375, -533.01000976562, 54.299999237061),
	Vector(4672, -2224, 53)
}

function CloseDoor(index)
	local door = Entity(index)
	if not IsValid(door) then return end
	local name = string.lower(door:GetName())
	
	if string.find(name, "elev") or string.find(name, "lift") then return end

	local dPos = door:GetPos()
	if table.HasValue(ents.FindInSphere(Vector(9537.967773, -5018.667480, 66.792221), 32), door) then return end
	if table.HasValue(ents.FindInSphere(Vector(9546.245117, -4566.125488, 66.792221), 32), door) then return end
	if table.HasValue(blockedkpps, dPos) then return end
	if door.NoAutoClose then return end

	timer.Create("close_door_" .. index, 17, 1, function()
		if IsValid(door) then door:Fire('Close') end
	end)
end