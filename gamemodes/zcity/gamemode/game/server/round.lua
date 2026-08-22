local RunConsoleCommand = RunConsoleCommand
local CurTime = CurTime
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



activeRound = activeRound
rounds = rounds or -1
roundEnd = roundEnd or 0
MAP_LOADED = MAP_LOADED or false

local allowedteams = {
	[TEAM_SPECIAL] = true,
	[TEAM_SCI] = true,
}

local allowedroles = {
	[role.SECURITY_Chief] = true,
	[role.SECURITY_Sergeant] = true,
	[role.MTF_Com] = true,
	[role.MTF_HOF] = true,
	[role.SECURITY_IMVSOLDIER] = true,
	[role.MTF_Left] = true,
	[role.Dispatcher] = true,
	[role.MTF_Specialist] = true,
	[role.MTF_Engi] = true,
}

local blockedroles = {
	[role.SCI_Cleaner] = true
}

function UIUSelectTargets()
	local numcount = 0
	for _, v in RandomPairs(player.GetAll()) do
		local team = v:GTeam()
		local rname = v:GetRoleName()
		if (allowedteams[team] and not blockedroles[rname]) or allowedroles[rname] then
			numcount = numcount + 1
		end
		if numcount >= 3 then break end
	end
end

function RestartGame()
	for _, v in player.Iterator() do
		BREACH.AdminLogSystem:LogPlayer(v)
	end
	timer.Simple(1, function()
		RunConsoleCommand("_restart")
	end)
end

local timers_to_destroy = {
	"PreparingTime", "RoundTime", "PostTime", "GateOpen", "PlayerInfo", 
	"NTFEnterTime", "NTFEnterTime2", "NTFEnterTime3", "PunishEnd", 
	"GateExplode", "SCP173Open", "PerformRandomIntercomAnnouncement", 
	"LZDecont", "LZDecont_Anounce1", "LZDecont_Anounce2", "LZDecont_Music", 
	"AnnounceAboutDetonation", "AnnounceAboutDetonation2", "AnnounceAboutDetonation3"
}

function CleanUp()
	game.CleanUpMap(false, {"env_fire", "phys_bone_follower", "entityflame", "_firesmoke", "light"}, function() end)

	for _, tName in ipairs(timers_to_destroy) do
		timer.Destroy(tName)
	end

	SPAWN_SCP_RANDOM_COPY = nil

	if not timer.Exists("InfiniteEscapes") then
		timer.Create("InfiniteEscapes", 1, 0, InfiniteEscapes)
	end

	for _, ply in player.Iterator() do
		ply.SelectedSCPAlready = nil
	end

	BREACH.SendClientEvent(nil, "blood_pool_iteration")
	game.GetWorld():StopParticles()
	Recontain106Used = false
	OMEGAEnabled = false
	OMEGADoors = false
	nextgateaopen = 0
	spawnedntfs = 0
	
	roundstats = {
		descaped = 0, rescaped = 0, sescaped = 0, dcaptured = 0, 
		rescorted = 0, deaths = 0, teleported = 0, snapped = 0, 
		zombies = 0, secretf = false
	}
	inUse = false
end

function CleanUpPlayers()
	for _, v in player.Iterator() do
		v:SetModelScale(1)
		v:SetCrouchedWalkSpeed(0.6)
		v.mblur = false
		player_manager.SetPlayerClass(v, "class_breach")
		player_manager.RunClass(v, "SetupDataTables")
		v:Freeze(false)
		v.MaxUses = nil
		v.blinkedby173 = false
		v.scp173allow = false
		v.scp1471stacks = 1
		v.usedeyedrops = false
		v.isescaping = false
		BREACH.SendClientEvent(v, "camera_disable")
	end
	
	net.Start("Effect")
	net.WriteBool(false)
	net.Broadcast()
	
	net.Start("957Effect")
	net.WriteBool(false)
	net.Broadcast()
end

function RoundTypeUpdate()
	activeRound = ROUNDS.normal
	if forceround then
		activeRound = ROUNDS[forceround]
		forceround = nil
	end
	SetGlobalString("RoundName", activeRound.name)
end

function Breach_EndRound(reason)
	net.Start("New_SHAKYROUNDSTAT")	
	net.WriteString(reason)
	net.WriteFloat(GetPostTime())
	net.Broadcast()
	
	postround = true
	if activeRound and activeRound.postround then
		activeRound.postround()
	end
	
	roundEnd = 0
	timer.Create("PostTime", GetPostTime(), 1, function()
		RoundRestart()
	end)
end

util.AddNetworkString("PrepClient")

function RoundRestart()
	for _, v in player.Iterator() do
		v.ArenaParticipant = false
		v:ConCommand("dev_loading")
		v:SetFrags(0)
	end
	
	timer.Simple(2, function()
		local rTimeLeft = GetGlobalInt("RoundUntilRestart", 15)
		if rTimeLeft <= 0 then
			hook.Run("BreachLog_GameRestart")
			RestartGame()
			return
		end
		
		net.Start("PrepClient")
		net.Broadcast()
		BroadcastStopMusic()
		
		timer.Simple(1, function()
			SetGlobalBool("EnoughPlayersCountDown", false)

			if #GetActivePlayers() < 10 and not DEBUG_TESTIC then
				for _, v in ipairs(GetActivePlayers()) do
					if v:GTeam() ~= TEAM_SPEC then
						v:SetupNormal()
						v:SetSpectator()
					end
					v:RXSENDNotify("l:not_enough_players")
				end
				CleanUp()
				EvacuationEnd()
				EvacuationWarheadEnd()
				LZLockDownEnd()
				gamestarted = false
				preparing = false
				postround = false
				activeRound = nil
				BREACH.SendClientEvent(nil, "reset_round_flags")
				return
			end

			if not MAP_LOADED then
				error("Map config is not loaded!")
			end

			SetGlobalInt("RoundUntilRestart", rTimeLeft - 1)
			SetGlobalBool("BigRound", #GetActivePlayers() >= 16)
			
			hook.Run("BreachLog_RoundStart", rTimeLeft)
			BREACH.AdminLogs.Logs_Data.CurRound = BREACH.AdminLogs.Logs_Data.CurRound + 1

			SetGlobalInt("TASKS_GRU_1", 0)
			SetGlobalInt("TASKS_GRU_2", 0)
			SetGlobalInt("TASKS_GRU_3", 0)
			SetGlobalInt("TASKS_TG_1", 0)
			SetGlobalInt("TASKS_TG_2", 0)
			SetGlobalInt("TASKS_TG_3", 0)

			LZLockDownEnd()
			EvacuationEnd()
			EvacuationWarheadEnd()
			Radio_RandomizeChannels()
			CleanUp()
			CleanUpPlayers()
			
			preparing = true
			postround = false
			activeRound = nil
			
			if #GetActivePlayers() < MINPLAYERS then WinCheck() end
			
			RoundTypeUpdate()
			SetupCollide()
			SetupAdmins(player.GetAll())
			activeRound.setup()
			
			net.Start("UpdateRoundType")
			net.WriteString(activeRound.name)
			net.Broadcast()
			
			activeRound.init()	
			gamestarted = true
			BREACH.SendClientEvent(nil, "gamestarted", {value = true})
			
			net.Start("PrepStart")
			net.WriteInt(GetPrepTime(), 8)
			net.Broadcast()
			
			UseAll()
			DestroyAll()
			timer.Destroy("PostTime") 
			hook.Run("BreachPreround")
			
			timer.Create("PreparingTime", GetPrepTime(), 1, function()
				for _, v in player.Iterator() do
					v:Freeze(false)
				end
				preparing = false
				postround = false		
				activeRound.roundstart()
				
				net.Start("RoundStart")
				net.WriteInt(GetRoundTime(), 12)
				net.Broadcast()
				
				roundEnd = CurTime() + GetRoundTime() + 3
				hook.Run("BreachRound")

				for _, classddoor in ipairs(ents.FindInBox(Vector(6279.50, -4907.61, 342.16), Vector(6057.34, -6251.33, 117.72))) do 
					if IsValid(classddoor) then classddoor:Fire("Open") end 
				end
				for _, classddoor in ipairs(ents.FindInBox(Vector(7828.5, -6147.87, 402.44), Vector(7890.51, -4939.61, 221.63))) do 
					if IsValid(classddoor) then classddoor:Fire("Open") end 
				end

				timer.Create("RoundTime", GetRoundTime(), 1, function()
					postround = true
					for _, v in player.Iterator() do
						v:Freeze(false)
						if v:GTeam() == TEAM_ARENA then
							v.ArenaParticipant = false
							v:SetupNormal()
							v:SetSpectator()
						end
					end
					
					activeRound.postround()
					
					if activeRound.name == "Containment Breach" then 
						net.Start("New_SHAKYROUNDSTAT")	
						net.WriteString("l:roundend_alphawarhead")
						net.WriteFloat(GetPostTime())
						net.Broadcast()
						
						net.Start("PostStart")
						net.WriteInt(GetPostTime(), 6)
						net.WriteInt(1, 4)
						net.Broadcast()
					end
					
					roundEnd = 0
					timer.Destroy("PunishEnd")
					hook.Run("BreachPostround")
					
					timer.Create("PostTime", GetPostTime(), 1, function()
						RoundRestart()
					end)	
				end)
				hook.Run("BreachRoundTimerCreated")
			end)
		end)
	end)
end

function GetAlivePlayers()
	local tab = GetActivePlayers()
	local _t = {}
	for i = 1, #tab do
		local v = tab[i]
		if v:Alive() and v:GTeam() ~= TEAM_SPEC and v:Health() > 0 then
			_t[#_t + 1] = v
		end
	end
	return _t
end

local horror_tbl = {
	"nextoren/others/horror/horror_0.ogg", "nextoren/others/horror/horror_1.ogg",
	"nextoren/others/horror/horror_2.ogg", "nextoren/others/horror/horror_3.ogg",
	"nextoren/others/horror/horror_4.ogg", "nextoren/others/horror/horror_5.ogg",
	"nextoren/others/horror/horror_9.ogg", "nextoren/others/horror/horror_10.ogg",
	"nextoren/others/horror/horror_16.ogg"
}

function givekarmaforescape(ply)
	ply:SetBreachData("karma", ply:GetBreachData("karma") + math.random(10, 40)) 
	timer.Simple(math.random(0.1, 2), function()
		if IsValid(ply) then ply:SetNWInt("karma", ply:GetBreachData("karma")) end
	end)
end

function InfiniteEscapes()
	for _, v in ipairs(GetAlivePlayers()) do
		if v:GTeam() == TEAM_SPEC or not v:Alive() or v:Health() <= 0 or v:GetModel() == "models/scp079microcom/scp079microcom.mdl" then continue end

		local pos = v:GetPos()

		if pos:WithinAABox(Vector(2488.34, -15383.38, -6151), Vector(4081.90, -14840.19, -6558)) or
		   pos:WithinAABox(Vector(4084.23, -15360.80, -6057), Vector(3654.92, -13843.79, -6540)) or
		   pos:WithinAABox(Vector(4067.33, -13810.75, -6127), Vector(2516.55, -14276.68, -6566)) or
		   pos:WithinAABox(Vector(2530.95, -13814.92, -6131), Vector(2956.11, -15462.25, -6570)) then
			v:SetPos(Vector(1719.54, -13027.41, -6191.96))
			BREACH.SendClientEvent(v, "play_sound", {sound = table.Random(horror_tbl)})
		elseif pos:WithinAABox(Vector(3856.35, -13147.78, -6220), Vector(4067.24, -12915.45, -5970)) then
			v:SetPos(Vector(6702.36, -14160.72, -6300.98))
			BREACH.SendClientEvent(v, "play_sound", {sound = table.Random(horror_tbl)})
		end

		if v.isescaping then continue end

		if pos:WithinAABox(Vector(-4983.18, -9017.58, 6032), Vector(-4482.65, -9830.18, 6427)) then
			if v:CanEscapeChaosRadio() then
				v:GodEnable()
				v:SetNoDraw(true)
				v:Freeze(true)
				givekarmaforescape(v)
				net.Start("StartCIScene")
				net.Send(v)
				v:SetPos(Vector(-4740.20, -9564.01, 6145.03))
				v:SetEyeAngles(Angle(0.54, 81.12, 0.0))
				v.isescaping = true
				
				net.Start("Ending_HUD")
				net.WriteString("l:ending_captured_by_unknown")
				net.Send(v)
				
				timer.Create("EscapeWait" .. v:SteamID64(), 8, 1, function()
					if not IsValid(v) then return end
					v:AddToStatistics("l:escaped", 250)
					if v:HasWeapon("item_cheemer") then v:AddToStatistics("l:cheemer_rescue", 250) end
					v:CompleteAchievement("escape")
					v:LevelBar()
					v:Freeze(false)
					v:GodDisable()
					v:CompleteAchievement("chaosradio")
					v:SetupNormal()
					v:SetSpectator()
					WinCheck()
					v.isescaping = false
				end)
			end
		elseif pos:WithinAABox(Vector(-7162.36, -6643.33, 6812), Vector(-6828.07, -6340.28, 6966)) then
			v:GodEnable()
			v:Freeze(true)
			v.canblink = false
			v.isescaping = true
			givekarmaforescape(v)
			
			timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
				if not IsValid(v) then return end
				v:Freeze(false)
				v:GodDisable()
				v:SetupNormal()
				v:SetSpectator()
				WinCheck()
				v.isescaping = false
			end)
			
			net.Start("Ending_HUD")
			net.WriteString("l:ending_escaped_site19_got_captured")
			net.Send(v)
			
			v:CompleteAchievement("escape")
			v:CompleteAchievement("escapehand")
			v:AddToStatistics("l:escaped", 500)
			if v:HasWeapon("item_cheemer") then v:AddToStatistics("l:cheemer_rescue", 600) end
			v:LevelBar()
		elseif pos:WithinAABox(Vector(-8060.71, -9043.73, 6526), Vector(-8217.99, -8887.62, 6896)) then
			local gru_heli = false 
			for _, ent in ipairs(ents.FindByClass("gru_heli")) do
				gru_heli = true
				break
			end
			if not gru_heli then continue end
			if v:GTeam() == TEAM_GRU and not GetGlobalBool("Evacuation") then continue end
			
			if v:GTeam() ~= TEAM_GRU then 
				SetGlobalInt("TASKS_GRU_2", GetGlobalInt("TASKS_GRU_2") + 1)
			end
			
			givekarmaforescape(v)
			if v:GTeam() == TEAM_GRU then
				if GetGlobalInt("TASKS_GRU_1") == 5 then v:AddToStatistics("l:uiu_obj_bonus", 1000) end
				if GetGlobalInt("TASKS_GRU_2") >= 3 then v:AddToStatistics("l:uiu_obj_bonus", 1000) end
				if GetGlobalInt("TASKS_GRU_3") >= 3 then v:AddToStatistics("l:uiu_obj_bonus", 1000) end
			end
			
			v:GodEnable()
			v:Freeze(true)
			v.canblink = false
			v.isescaping = true

			timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
				if not IsValid(v) then return end
				v:Freeze(false)
				v:GodDisable()
				v:SetupNormal()
				v:SetSpectator()
				WinCheck()
				v.isescaping = false
			end)
			
			net.Start("Ending_HUD")
			net.WriteString("l:ending_escaped_site19_got_captured")
			net.Send(v)
			
			v:CompleteAchievement("escape")
			v:CompleteAchievement("escapehand")
			v:AddToStatistics("l:escaped", 800)
			if v:HasWeapon("item_cheemer") then v:AddToStatistics("l:cheemer_rescue", 100) end
			v:LevelBar()
		elseif pos:WithinAABox(Vector(-3257.01, -5308.47, 7305), Vector(-5486.95, -7352.57, 6439)) then
			givekarmaforescape(v)
			v:GodEnable()
			v:Freeze(true)
			v.canblink = false
			v.isescaping = true
			
			timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
				if not IsValid(v) then return end
				v:Freeze(false)
				v:GodDisable()
				v:SetupNormal()
				v:SetSpectator()
				WinCheck()
				v.isescaping = false
			end)
			
			if v:GTeam() == TEAM_USA and v:GetModel() ~= "models/cultist/humans/fbi/fbi_agent.mdl" then
				if v:GetRoleName() ~= role.SCI_SpyUSA then
					if Monitors_Activated and Monitors_Activated >= 5 then
						net.Start("Ending_HUD")
						net.WriteString("l:ending_mission_complete")
						net.Send(v)
						v:CompleteAchievement("fbiescape")
						v:AddToStatistics("l:escaped", 400)
					else
						net.Start("Ending_HUD")
						net.WriteString("l:ending_mission_failed")
						net.Send(v)
						v:AddToStatistics("l:escaped", 200)
					end
				else
					if v.TempValues.FBIHackedTerminal then
						net.Start("Ending_HUD")
						net.WriteString("l:ending_mission_complete")
						net.Send(v)
						v:AddToStatistics("l:escaped", 700)
					else
						net.Start("Ending_HUD")
						net.WriteString("l:ending_mission_failed")
						net.Send(v)
						v:AddToStatistics("l:escaped", 100)
					end
				end
			else
				net.Start("Ending_HUD")
				net.WriteString("l:ending_escaped_site19")
				net.Send(v)
				v:AddToStatistics("l:escaped", 100)
			end
			
			if v:HasWeapon("item_cheemer") then v:AddToStatistics("l:cheemer_rescue", 250) end
			
			if v:GetModel() == "models/cultist/humans/fbi/fbi_agent.mdl" and v:HasWeapon("item_special_document_o5") then
				for _, ply in player.Iterator() do
					if ply:GetModel() == "models/cultist/humans/fbi/fbi_agent.mdl" then
						ply:AddToStatistics("l:escaped", 1000)
					end
				end
			end
			
			v:CompleteAchievement("escape")
			v:CompleteAchievement("beglec")
			if not timer.Exists("RoundTime") or timer.TimeLeft("RoundTime") <= 5 then
				v:CompleteAchievement("runbitch")
			end
			v:LevelBar()
		elseif pos:WithinAABox(Vector(-14531.46, 3658.37, -15753.98), Vector(-15083.87, 3132.85, -15400)) then
			if v:CanEscapeO5() then
				v:GodEnable()
				v:Freeze(true)
				v.canblink = false
				v.isescaping = true

				timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
					if not IsValid(v) then return end
					v:Freeze(false)
					v:GodDisable()
					v:SetupNormal()
					v:SetSpectator()
					v.isescaping = false
				end)

				net.Start("Ending_HUD")
				net.WriteString("l:ending_o5")
				net.Send(v)
				givekarmaforescape(v)
				v:CompleteAchievement("monorail")
				v:CompleteAchievement("escape")
				v:AddToStatistics("l:escaped", 450)
				if v:HasWeapon("item_cheemer") then v:AddToStatistics("l:cheemer_rescue", 450) end
				v:LevelBar()
			end
		elseif pos:WithinAABox(Vector(-7706.34, -2536.74, 6463), Vector(-8621.49, -2150.88, 6985)) then
			if v:InVehicle() then
				v:ExitVehicle()
				net.Start("Ending_HUD")
				net.WriteString("l:ending_car")
				net.Send(v)
				if v:CanEscapeCar() then
					timer.Create("EscapeWait" .. v:SteamID64(), 1, 1, function()
						if not IsValid(v) then return end
						givekarmaforescape(v)
						v.canblink = false
						v.isescaping = true
						v:SetupNormal()
						v:SetSpectator()
						v:CompleteAchievement("escape")
						v:CompleteAchievement("car")
						v:AddToStatistics("l:escaped", 500)
						v:LevelBar()
					end)
				end
			end
		end
	end
end

timer.Create("InfiniteEscapes", 0.5, 0, InfiniteEscapes)

function WinCheck()
	if postround or not activeRound then return end
	activeRound.endcheck()
	
	if roundEnd > 0 and roundEnd < CurTime() then
		roundEnd = 0
		print("Something went wrong! Error code: 100")
		print(debug.traceback())
	end
	
	if endround then
		StopRound()
		timer.Destroy("RoundTime")
		preparing = false
		postround = true

		net.Start("")	
		net.WriteString("l:roundend_cbended")
		net.WriteFloat(GetPostTime())
		net.Broadcast()
		
		net.Start("PostStart")
		net.WriteInt(GetPostTime(), 6)
		net.WriteInt(2, 4)
		net.Broadcast()
		
		activeRound.postround()	
		endround = false
		hook.Run("BreachPostround")
		
		timer.Create("PostTime", GetPostTime(), 1, function()
			RoundRestart()
		end)
	end
end

function StopRound()
	local toStop = {"PreparingTime", "RoundTime", "PostTime", "GateOpen", "PlayerInfo"}
	for _, t in ipairs(toStop) do
		timer.Stop(t)
	end
end

timer.Create("WinCheckTimer", 5, 0, function()
	if not postround and not preparing then
		WinCheck()
	end
end)

function SetupCollide()
	for _, v in ipairs(ents.GetAll()) do
		local cls = v:GetClass()
		if cls == "func_door" or cls == "prop_dynamic" then
			if cls == "prop_dynamic" then
				local neardors = false
				for _, ennt in ipairs(ents.FindInSphere(v:GetPos(), 5)) do
					if ennt:GetClass() == "func_door" then
						neardors = true
						break
					end
				end
				if not neardors then 
					v.ignorecollide106 = false
					continue
				end
			end

			local changed = false
			local pos = v:GetPos()
			for _, dpos in pairs(DOOR_RESTRICT106) do
				if pos:Distance(dpos) < 100 then
					v.ignorecollide106 = false
					changed = true
					break
				end
			end
			
			if not changed then
				v.ignorecollide106 = true
			end
		end
	end
end

timer.Create("scp542_damage", 1, 0, function()
	for _, v in player.Iterator() do
		if v:GetModel() == "models/cultist/scp/scp_542.mdl" then
			v:SetHealth(v:Health() - 5)
			if v:Health() <= 0 and v:Alive() then 
				v:Kill() 
			end
		end
	end
end)