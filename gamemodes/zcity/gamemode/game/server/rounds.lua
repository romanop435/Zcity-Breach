local tonumber = tonumber
local table = table
local pairs = pairs
local ipairs = ipairs
local timer = timer
local ents = ents
local math = math
local player = player



local function GetTimeForSetup(n)
	return GetRoundTime() - n
end


function OpenSCP106Camera()
	ents.GetMapCreatedEntity(1904):Fire("use")
	timer.Simple(7.4, function()
		ents.GetMapCreatedEntity(2198):Fire("use")
	end)
end

function OpenSCPDoors()
	for _, v0 in pairs(POS_DOOR) do
		for _, v in ipairs(ents.FindInSphere(v0, 500)) do
			if v:GetClass() == "func_door" then
				v:Fire("Unlock")
				v:Fire("Use")
			end
		end
	end
	for _, v in ipairs(ents.FindByClass("func_button")) do
		for _, v0 in pairs(POS_BUTTON) do
			if v:GetPos() == v0 then
				v:Fire("use")
				break
			end
		end
	end
	for _, v in ipairs(ents.FindByClass("func_rot_button")) do
		for _, v0 in pairs(POS_ROT_BUTTON) do
			if v:GetPos() == v0 then
				v:Fire("use")
				break
			end
		end
	end
end

ROUNDS = {
	normal = {
		name = "Containment Breach",
		setup = function()
			CBG_COG_VECTOR = nil
			BREACH.SendClientEvent(nil, "set_vector", {name = "CBG_COG_VECTOR", value = vector_origin})
			SetGlobalBool("EventRound", false)
			SetGlobalBool("NewEventRound", false)
			SetGlobalBool("FurryRound", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			SetupPlayers(GetRoleTable(#GetActivePlayers()))
			timer.Create("NewTG_SpanwTimer", 80, 1, function() 
				new_mog_intro_elevator_start()
			end)
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			BREACH.DonatorLim = {}
			MVPStats = {
				scpkill = {},
				headshot = {},
				kill = {},
				heal = {},
				damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false,
				["CHAOS"] = false,
				["NTF"] = false,
				["DZ"] = false,
			}
		end,
		init = function()
			timer.Simple(4, function()
				SpawnAllItems()
				CHAIR_SPAWN()
				SpawnSec()
				SPAWN106CONTROL()
			end)
			SetGlobalBool("MentalBarrierActive", true)
			SetGlobalBool("Evacuation_HUD", false)

			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function()
			timer.Remove("PowerfulUIUSupportDelayed")
			BREACH.PowerfulUIUSupportDelayed = false
			SCPLockDownHasStarted = true
			timer.Simple(2, function()
				if istable(MAPS_CHANGESKINPROPSTABLE) then
					for _, prop in ipairs(MAPS_CHANGESKINPROPSTABLE) do
						if IsValid(prop) then prop:SetSkin(1) end
					end
				end
			end)
			timer.Create("Security_Doors", 35, 1, function()
				sound.Play("nextoren/others/button_unlocked.wav", Vector(6505, -6675, 198.3))
				sound.Play("nextoren/others/button_unlocked.wav", Vector(5166, -7325, 54.3))
				sound.Play("nextoren/others/button_unlocked.wav", Vector(5927, -6975, 201.41))
				OpenSecDoors = true
			end)
			timer.Create("SCPNEWOPEN_Doors", 65, 1, function()
				OpenSCPDoors()
			end)
			SetGlobalBool("MentalBarrierActive", false)
			timer.Simple(2, function()
			for _, v in ipairs(ents.FindByClass("npc_security")) do
				v:TakeDamage(500, v)
			end
			end)

			local lzlockdowntime = GetTimeForSetup(60 * 7)
			local announcetime = GetTimeForSetup(60 * 8)
			local scp173open = GetTimeForSetup(60 * 10)

			if IsBigRound() then
				lzlockdowntime = GetTimeForSetup(60 * 10 + 30)
				announcetime = GetTimeForSetup(60 * 12)
				scp173open = GetTimeForSetup(60 * 20)
			end

			for _, door in ipairs(ents.FindInBox(Vector(6446.74, -3533.15, 344.55), Vector(6061.39, -3381.31, 81.95))) do
				if IsValid(door) and door:GetClass() == "func_door" then
					door:Fire("lock")
				end
			end

			timer.Create("SCP173Open", scp173open, 1, function()
				for _, door in ipairs(ents.FindInBox(Vector(6446.74, -3533.15, 344.55), Vector(6061.39, -3381.31, 81.95))) do
					if IsValid(door) and door:GetClass() == "func_door" then
						door:Fire("unlock")
						door:Fire("open")
					end
				end
			end)

			BREACH.SendClientEvent(nil, "lz_timer", {delay = lzlockdowntime})
			timer.Create("LZDecont", lzlockdowntime, 1, function()
				LZLockDown()
			end)

			for _, ent in ipairs(ents.FindByClass("livetablz")) do
				if IsValid(ent) then ent:SetDecontTimer(lzlockdowntime) end
			end

			if IsBigRound() then
				timer.Create("AnnounceAboutDetonation", GetTimeForSetup(900), 1, function()
					PlayAnnouncer("nextoren/round_sounds/main_decont/decont_15_b.mp3")
					for _, v in player.Iterator() do
						v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_15min", color_white)
					end
				end)

				timer.Create("LZDecont_Anounce1", GetTimeForSetup(300), 1, function()
					PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_5_min.ogg")
					for _, v in player.Iterator() do
						if v:GTeam() ~= TEAM_SPEC and v:IsLZ() then
							v:BrTip(0, "[ZCity Breach]", Color(255,0,0,240), "l:decont_5min", Color(255,255,255,240))
						end
					end
				end)

				timer.Create("NTFEnterTime2", GetTimeForSetup(math.random(650, 660)), 1, function()
					if not GetGlobalBool("NukeTime", false) then SupportSpawn() end
				end)

				timer.Create("NTFEnterTime3", GetTimeForSetup(math.random(480, 500)), 1, function()
					if not GetGlobalBool("NukeTime", false) then SupportSpawn() end
				end)
			else
				timer.Create("NTFEnterTime", GetTimeForSetup(math.random(480, 500)), 1, function()
					if not GetGlobalBool("NukeTime", false) then SupportSpawn() end
				end)
			end

			timer.Create("LZDecont_Anounce2", announcetime, 1, function()
				PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_1_min.ogg")
				for _, v in player.Iterator() do
					if v:GTeam() ~= TEAM_SPEC and v:IsLZ() then
						v:PlayMusic(BR_MUSIC_LIGHTZONE_DECONT)
						v:BrTip(0, "[ZCity Breach]", Color(255,0,0,240), "l:decont_1min", Color(255,255,255,240))
					end
				end
			end)

			timer.Create("AnnounceAboutDetonation2", GetTimeForSetup(600), 1, function()
				PlayAnnouncer("nextoren/round_sounds/main_decont/decont_10_b.mp3")
				for _, v in player.Iterator() do
					v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_10min", color_white)
				end
			end)

			timer.Create("AnnounceAboutDetonation3", GetTimeForSetup(300), 1, function()
				PlayAnnouncer("nextoren/round_sounds/main_decont/decont_5_b.mp3")
				for _, v in player.Iterator() do
					v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_5min", color_white)
				end
			end)
			
			local timetostart = 195 - 66
			timer.Create("Evacuation", GetTimeForSetup(195), 1, function() Evacuation() end)
			timer.Create("EvacuationWarhead", GetTimeForSetup(timetostart), 1, function() EvacuationWarhead() end)

			local r_time = IsBigRound() and GetTimeForSetup(60 * 14) or GetTimeForSetup(60 * 10)

			timer.Create("FullContainmentOutBreak", r_time, 1, function()
				SCPLockDownHasStarted = true
				for _, door in ipairs(ents.FindInBox(Vector(2570, 3006, -334), Vector(2570, 3100, -331.25))) do
					if IsValid(door) and door:GetClass() == "func_door" then door:Fire("open") end
				end

				for _, v in player.Iterator() do
					if v:GTeam() == TEAM_SCP and v:GetRoleName() == "SCP062DE" and #v:GetWeapons() == 0 then
						v:BreachGive("cw_kk_ins2_doi_k98k")
						break
					end
				end

				for _, v in ipairs(ents.FindByModel("models/noundation/doors/860_door.mdl")) do v:Fire("use") end
				
				for _, v in ipairs(ents.FindInBox(Vector(2679.06, 1976.07, 368.10), Vector(2333.40, 1436.37, -17.68))) do
					if IsValid(v) and v:GetClass() == "func_door" then
						v:Fire("Unlock")
						v:Fire("Open")
					end
				end

				local new_scp_doors = {
					Vector(8413.53, 1153.55, 1.26), Vector(6999.36, 2526.96, 0.03),
					Vector(6571.09, 2354.59, 0.03), Vector(5007.53, 3558.17, 0.03),
					Vector(4310.07, 2364.32, 1.26), Vector(6062.51, 1366.46, 1.26),
					Vector(5670.75, -670.53, 1.26), Vector(2410.28, 1853.29, 1.66),
					Vector(2542.28, 1727.46, 1.26), Vector(6587.91, 1102.95, 10.03),
					Vector(6584.18, 926.43, 10.71), Vector(3173.13, 3821.09, 152.03),
					Vector(3179.29, 3702.81, 152.03), Vector(3331.64, 3428.25, 152.03)
				}

				for _, pos in ipairs(new_scp_doors) do 
					for _, v in ipairs(ents.FindInSphere(pos, 100)) do 
						if v:GetClass() == "func_door" then
							v:Fire('Unlock')
							v:Fire('open') 
						end
					end
				end

				for _, v in pairs(BUTTONS) do
					if v.LockDownOpen then
						for _, door in ipairs(ents.FindInSphere(v.pos, 40)) do
							if IsValid(door) and door:GetClass() == "func_door" then
								door:Fire("Unlock")
								door:Fire("Open")
							end
						end
					end
				end

				for _, door049 in ipairs(ents.FindInSphere(Vector(7565.89, -272.04, 55.38), 10)) do
					if IsValid(door049) and door049:GetClass() == "prop_dynamic" then door049:Remove() end
				end
			end)
		end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function()
			if #GetActivePlayers() < 2 then return end	
			endround = false
		end,
	},
	ww2tdm = {
		name = "WW2TDM",
		setup = function()
			SetGlobalBool("EventRound", true)
			SetGlobalBool("NewEventRound", false)
			SetGlobalBool("FurryRound", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			SetupWW2(#GetActivePlayers())
			
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			BREACH.ALPHA1GC = 0
			MVPStats = {
				scpkill = {}, headshot = {}, kill = {}, heal = {}, damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false,
				["NTF"] = false, ["DZ"] = false, ["COTSK"] = false,
			}
		end,
		init = function()
			SetGlobalBool("Evacuation_HUD", false)
			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function() end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function()
			local usa = gteams.NumPlayers(TEAM_AMERICA)
			local nazi = gteams.NumPlayers(TEAM_NAZI)
			if usa == 0 then
				Breach_EndRound("Победа сил Рейха")
				local topPlayer = GetTopFragger()
				if IsValid(topPlayer) then topPlayer:AddToStatistics("Чемпион", 500) end
				for _, v in ipairs(gteams.GetPlayers(TEAM_NAZI)) do
					v:CompleteAchievement("nazi")
				end
			elseif nazi == 0 then
				Breach_EndRound("Победа сил США")
				local topPlayer = GetTopFragger()
				if IsValid(topPlayer) then topPlayer:AddToStatistics("Чемпион", 500) end
				for _, v in ipairs(gteams.GetPlayers(TEAM_AMERICA)) do
					v:CompleteAchievement("usa")
				end
			end
		end,
	},
	hl2tdm = {
		name = "HL2TDM",
		setup = function()
			SetGlobalBool("EventRound", true)
			SetGlobalBool("NewEventRound", false)
			SetGlobalBool("FurryRound", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			Setuphl2(#GetActivePlayers())
			
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			MVPStats = {
				scpkill = {}, headshot = {}, kill = {}, heal = {}, damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false,
				["NTF"] = false, ["DZ"] = false, ["COTSK"] = false,
			}
		end,
		init = function()
			SetGlobalBool("Evacuation_HUD", false)
			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function() end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function()
			local gf = gteams.NumPlayers(TEAM_RESISTANCE)
			local com = gteams.NumPlayers(TEAM_COMBINE)
			if gf == 0 then
				Breach_EndRound("Победа сил Альянса")
				for _, v in ipairs(gteams.GetPlayers(TEAM_COMBINE)) do
					v:CompleteAchievement("combine")
				end
				local topPlayer = GetTopFragger()
				if IsValid(topPlayer) then topPlayer:AddToStatistics("Чемпион", 500) end
			elseif com == 0 then
				Breach_EndRound("Победа сил Сопротивления")
				for _, v in ipairs(gteams.GetPlayers(TEAM_RESISTANCE)) do
					v:CompleteAchievement("gf")
				end
				local topPlayer = GetTopFragger()
				if IsValid(topPlayer) then topPlayer:AddToStatistics("Чемпион", 500) end
			end
		end,
	},
	ny_event = {
		name = "HNE_EVENT",
		setup = function()
			SetGlobalBool("EventRound", true)
			SetGlobalBool("NewEventRound", false)
			SetGlobalBool("FurryRound", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			Setupny(#GetActivePlayers())
			
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			MVPStats = {
				scpkill = {}, headshot = {}, kill = {}, heal = {}, damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false,
				["NTF"] = false, ["DZ"] = false, ["COTSK"] = false,
			}
		end,
		init = function()
			SetGlobalBool("Evacuation_HUD", false)
			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function() end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function()
			local gf = gteams.NumPlayers(TEAM_XMAS_VRAG)
			local com = gteams.NumPlayers(TEAM_XMAS_FRIEND)
			if gf == 0 then
				Breach_EndRound("Победа сил Нового Года")
				for _, v in ipairs(gteams.GetPlayers(TEAM_XMAS_FRIEND)) do
					local val = v:GetPData("event_xmas_tvar")
					v:SetPData("event_xmas_tvar", val and (tonumber(val) + 1) or 1)
					v:SetNWInt("event_xmas_tvar", tonumber(v:GetPData("event_xmas_tvar")))
				end
				local topPlayer = GetTopFragger()
				if IsValid(topPlayer) then topPlayer:AddToStatistics("Чемпион", 500) end
			elseif com == 0 then
				Breach_EndRound("НОВОГОДНЯЯ ТВАРЬ ИСПОРТИЛА ПРАЗДНИК!!!")
				local topPlayer = GetTopFragger()
				if IsValid(topPlayer) then topPlayer:AddToStatistics("Чемпион", 500) end
			end
		end,
	},
	furry_event = {
		name = "Furry_Event",
		setup = function()
			SetGlobalBool("EventRound", true)
			SetGlobalBool("FurryRound", true)
			SetGlobalBool("NewEventRound", false)
			SetGlobalBool("NextFurry", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			Setupfurry(#GetActivePlayers())
			
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = true
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			MVPStats = {
				scpkill = {}, headshot = {}, kill = {}, heal = {}, damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false,
				["NTF"] = false, ["DZ"] = false, ["COTSK"] = false,
			}
		end,
		init = function()
			SetGlobalBool("Evacuation_HUD", false)
			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function() end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function()
			local antifurry = gteams.NumPlayers(TEAM_ANTIFURRY)
			if antifurry == 0 then
				Breach_EndRound("Фурри поработили мир")
			end
		end,
	},
	normalevent = {
		name = "Containment Breach",
		setup = function()
			CBG_COG_VECTOR = nil
			BREACH.SendClientEvent(nil, "set_vector", {name = "CBG_COG_VECTOR", value = vector_origin})
			SetGlobalBool("EventRound", false)
			SetGlobalBool("NewEventRound", true)
			SetGlobalBool("FurryRound", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			SetupPlayers(GetRoleTable(#GetActivePlayers()))

			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			BREACH.DonatorLim = {}
			MVPStats = {
				scpkill = {}, headshot = {}, kill = {}, heal = {}, damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false,
				["NTF"] = false, ["DZ"] = false, ["COTSK"] = false,
			}
		end,
		init = function()
			timer.Simple(4, function()
				SpawnAllItems()
				CHAIR_SPAWN()
			end)
			SetGlobalBool("Evacuation_HUD", false)
			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function()
			timer.Remove("PowerfulUIUSupportDelayed")
			BREACH.PowerfulUIUSupportDelayed = false
			OpenSCPDoors()
			timer.Simple(2, function()
				if istable(MAPS_CHANGESKINPROPSTABLE) then
					for _, prop in ipairs(MAPS_CHANGESKINPROPSTABLE) do
						if IsValid(prop) then prop:SetSkin(1) end
					end
				end
			end)
			timer.Create("Security_Doors", 35, 1, function()
				sound.Play("nextoren/others/button_unlocked.wav", Vector(-2463, 3592, 53))
				sound.Play("nextoren/others/button_unlocked.wav", Vector(6217.42, -6575.99, 183))
				sound.Play("nextoren/others/button_unlocked.wav", Vector(9983, -3292, 54.3))
				sound.Play("nextoren/others/button_unlocked.wav", Vector(10457, -1370.58, 54.3))
				OpenSecDoors = true
			end)

			local lzlockdowntime = GetTimeForSetup(60 * 7)
			local announcetime = GetTimeForSetup(60 * 8)
			local scp173open = GetTimeForSetup(60 * 10)

			if IsBigRound() then
				lzlockdowntime = GetTimeForSetup(60 * 10 + 30)
				announcetime = GetTimeForSetup(60 * 12)
				scp173open = GetTimeForSetup(60 * 20)
			end

			for _, door in ipairs(ents.FindInBox(Vector(6446.74, -3533.15, 344.55), Vector(6061.39, -3381.31, 81.95))) do
				if IsValid(door) and door:GetClass() == "func_door" then
					door:Fire("lock")
				end
			end

			timer.Create("SCP173Open", scp173open, 1, function()
				for _, door in ipairs(ents.FindInBox(Vector(6446.74, -3533.15, 344.55), Vector(6061.39, -3381.31, 81.95))) do
					if IsValid(door) and door:GetClass() == "func_door" then
						door:Fire("unlock")
						door:Fire("open")
					end
				end
			end)

			BREACH.SendClientEvent(nil, "lz_timer", {delay = lzlockdowntime})
			timer.Create("LZDecont", lzlockdowntime, 1, function()
				LZLockDown()
			end)

			for _, ent in ipairs(ents.FindByClass("livetablz")) do
				if IsValid(ent) then ent:SetDecontTimer(lzlockdowntime) end
			end

			if IsBigRound() then
				timer.Create("AnnounceAboutDetonation", GetTimeForSetup(900), 1, function()
					PlayAnnouncer("nextoren/round_sounds/main_decont/decont_15_b.mp3")
					for _, v in player.Iterator() do
						v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_15min", color_white)
					end
				end)

				timer.Create("LZDecont_Anounce1", GetTimeForSetup(300), 1, function()
					PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_5_min.ogg")
					for _, v in player.Iterator() do
						if v:GTeam() ~= TEAM_SPEC and v:IsLZ() then
							v:BrTip(0, "[ZCity Breach]", Color(255,0,0,240), "l:decont_5min", Color(255,255,255,240))
						end
					end
				end)
			end

			timer.Create("LZDecont_Anounce2", announcetime, 1, function()
				PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_1_min.ogg")
				for _, v in player.Iterator() do
					if v:GTeam() ~= TEAM_SPEC and v:IsLZ() then
						v:PlayMusic(BR_MUSIC_LIGHTZONE_DECONT)
						v:BrTip(0, "[ZCity Breach]", Color(255,0,0,240), "l:decont_1min", Color(255,255,255,240))
					end
				end
			end)

			timer.Create("AnnounceAboutDetonation2", GetTimeForSetup(600), 1, function()
				PlayAnnouncer("nextoren/round_sounds/main_decont/decont_10_b.mp3")
				for _, v in player.Iterator() do
					v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_10min", color_white)
				end
			end)

			timer.Create("AnnounceAboutDetonation3", GetTimeForSetup(300), 1, function()
				PlayAnnouncer("nextoren/round_sounds/main_decont/decont_5_b.mp3")
				for _, v in player.Iterator() do
					v:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:evac_5min", color_white)
				end
			end)

			local timetostart = 195 - 66
			timer.Create("Evacuation", GetTimeForSetup(195), 1, function() Evacuation() end)
			timer.Create("EvacuationWarhead", GetTimeForSetup(timetostart), 1, function() EvacuationWarhead() end)

			local r_time = IsBigRound() and GetTimeForSetup(60 * 14) or GetTimeForSetup(60 * 10)

			timer.Create("FullContainmentOutBreak", r_time, 1, function()
				SCPLockDownHasStarted = true
				for _, door in ipairs(ents.FindInBox(Vector(2570, 3006, -334), Vector(2570, 3100, -331.25))) do
					if IsValid(door) and door:GetClass() == "func_door" then door:Fire("open") end
				end

				for _, v in player.Iterator() do
					if v:GTeam() == TEAM_SCP and v:GetRoleName() == "SCP062DE" and #v:GetWeapons() == 0 then
						v:BreachGive("cw_kk_ins2_doi_k98k")
						break
					end
				end

				for _, v in ipairs(ents.FindByModel("models/noundation/doors/860_door.mdl")) do v:Fire("use") end
				
				for _, v in ipairs(ents.FindInBox(Vector(2679.06, 1976.07, 368.10), Vector(2333.40, 1436.37, -17.68))) do
					if IsValid(v) and v:GetClass() == "func_door" then
						v:Fire("Unlock")
						v:Fire("Open")
					end
				end

				for _, v in ipairs(ents.FindByName('scp_door_new_*')) do
					v:Fire('Unlock')
					v:Fire('open')
				end

				for _, v in pairs(BUTTONS) do
					if v.LockDownOpen then
						for _, door in ipairs(ents.FindInSphere(v.pos, 40)) do
							if IsValid(door) and door:GetClass() == "func_door" then
								door:Fire("Unlock")
								door:Fire("Open")
							end
						end
					end
				end

				for _, door049 in ipairs(ents.FindInSphere(Vector(7565.89, -272.04, 55.38), 10)) do
					if IsValid(door049) and door049:GetClass() == "prop_dynamic" then door049:Remove() end
				end
			end)
		end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function()
			if #GetActivePlayers() < 2 then return end	
			endround = false
		end,
	},
	event = {
		name = "event",
		setup = function()
			SetGlobalBool("EventRound", false)
			SetGlobalBool("NewEventRound", true)
			SetGlobalBool("FurryRound", false)
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			Setupevent(#GetActivePlayers())
			SetGlobalString("gru_objective", nil)
			
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			MVPStats = {
				scpkill = {}, headshot = {}, kill = {}, heal = {}, damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false, ["FBI"] = false, ["CHAOS"] = false,
				["NTF"] = false, ["DZ"] = false, ["COTSK"] = false,
			}
		end,
		init = function()
			SetGlobalBool("Evacuation_HUD", false)
			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function() end,
		postround = function()
			makeMVPScore()
		end,
		endcheck = function() end,
	},
}