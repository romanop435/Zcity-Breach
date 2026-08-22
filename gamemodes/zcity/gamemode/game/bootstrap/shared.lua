BREACH = BREACH or {}

local FindMetaTable = FindMetaTable
local pairs = pairs
local ipairs = ipairs
local string = string
local table = table
local timer = timer
local hook = hook
local math = math
local tonumber = tonumber
local ents = ents
local util = util
local net = net
local player = player

local mply = FindMetaTable("Player")
local ment = FindMetaTable("Entity")

// Shared file
GM.Name 	= "ZCity"

function GM:GetGameDescription()
	return "ZCity"
end
GM.Author 	= "NextOren/RXSEND/Legacy"
GM.Email 	= ""
GM.Website 	= ""

VERSION = "dev build"
DATE = "10/01/2026"

function GM:Initialize()
	self.BaseClass.Initialize(self)
end

function BREACH.Msg(txt, color, ...)
	color = color or Color(255, 255, 255)
	MsgC(brlib and brlib.colors and brlib.colors.blue or Color(0,100,255), "[ZCity Breach] ", color, os.date('%H:%M:%S - ', os.time()) .. string.format(txt, ...), "\n")
end

local role_cache = {}

function GetRoleTableSH(rolename)
    local cached = role_cache[rolename]
    if cached ~= nil then return cached or nil end
    if not BREACH_ROLES then return nil end

    for _, faction in pairs(BREACH_ROLES) do
        for _, group in pairs(faction) do
            local roles = group.roles
            if roles then
                for i = 1, #roles do
                    local role = roles[i]
                    if role.name == rolename then
                        role_cache[rolename] = role
                        return role
                    end
                end
            end
        end
    end

    role_cache[rolename] = false
    return nil
end

BREACH.MainMenu_Spawns = {
	{Vector(-3003, 4135, 188), Angle(57, -46, 0)},
	{Vector(6783.93, -5664.27, 136.04), Angle(-12.46, 179.87, 0)},
	{Vector(-265.47, -6398.88, -2278.83), Angle(16.85, 138.93, 0)}
}

hook.Add("SetupMove", "SCP_DOWN_SPEED", function(ply, mv, cmd)
	if ply:GTeam() == TEAM_SCP then
		local speedmultiply = math.min(1, ply:GetNWInt("Speed_Multiply", 1))
		if speedmultiply < 1 then
			local speed = ply:GetRunSpeed() * speedmultiply
			mv:SetMaxSpeed(speed)
			mv:SetMaxClientSpeed(speed)
		end
	end
end)

function BREACH.TranslateString(str)
    if SERVER then return str, true end
    if not isstring(str) or (not str:find("l:", 1, true) and not str:find("dont_translate:", 1, true)) then
        return str, true
    end

    local isfound = true
    local tab = string.Explode(" ", str)

	if #tab >= 2 then
		for k, v in ipairs(tab) do
			if v:find("dont_translate:") then
				tab[k] = string.Replace(v, "dont_translate:", "")
				continue
			end

			if v:find("l:") then
				local explosion = string.Explode("l:", v)
				local before = explosion[1] or "" 
				local phrase = explosion[2]

				if ALLLANGUAGES[langtouse] and ALLLANGUAGES[langtouse][phrase] then
					tab[k] = before .. ALLLANGUAGES[langtouse][phrase]
				elseif ALLLANGUAGES["english"] and ALLLANGUAGES["english"][phrase] then
					tab[k] = before .. ALLLANGUAGES["english"][phrase]
				else
					isfound = false
					tab[k] = before .. "recursive phrase not found " .. (phrase or "")
				end
			end
		end
		return table.concat(tab, " "), isfound
	end

	if str:find("dont_translate:") then
		return string.Replace(str, "dont_translate:", ""), isfound
	end

	if str:find("l:") then
		local explosion = string.Explode("l:", str)
		local before = explosion[1] or "" 
		local phrase = explosion[2]
		langtouse = ALLLANGUAGES[langtouse] and langtouse or "english"

		if ALLLANGUAGES[langtouse] and ALLLANGUAGES[langtouse][phrase] then
			return before .. ALLLANGUAGES[langtouse][phrase], isfound
		elseif ALLLANGUAGES["english"] and ALLLANGUAGES["english"][phrase] then
			return before .. ALLLANGUAGES["english"][phrase], isfound
		else
			isfound = false
			return before .. "phrase not found " .. (phrase or ""), isfound
		end
	end

	return str, isfound
end

function BREACH.TranslateNonPrefixedString(str)
    local language = ALLLANGUAGES[langtouse] and langtouse or "english"
    local phrases = ALLLANGUAGES[language]
    return (phrases and phrases[str]) or (ALLLANGUAGES.english and ALLLANGUAGES.english[str]) or "non prefixed phrase not found " .. str
end

function L(str)
	local res, _ = BREACH.TranslateString(str)
	return res
end

function PickHeadModel(steamid64, isfemale)
	if steamid64 == "76561199064971307" then return "models/cultist/heads/male/male_head_165.mdl" end
	if steamid64 == "76561198966614836" then return "models/cultist/heads/male/male_head_95.mdl" end
	if steamid64 == "76561198867007475" then return "models/cultist/heads/male/male_head_35.mdl" end
	if steamid64 == "76561198342205739" then return "models/cultist/heads/male/male_head_177.mdl" end

	if isfemale then return "models/cultist/heads/female/female_head_" .. math.random(1, 52) .. ".mdl" end

	local num = math.random(1, 215)
	if num == 213 then num = 1 end
	return "models/cultist/heads/male/male_head_" .. num .. ".mdl"
end

function PickFaceSkin(black, steamid64, isfemale)
	if not isfemale then
		if steamid64 == "76561199064971307" then return "models/cultist/heads/male/black/male_face_black_281" end
		if not black then
			if steamid64 == "76561198966614836" then return "models/cultist/heads/male/male_face_137" end
			if steamid64 == "76561198342205739" then return "models/cultist/heads/male/male_face_26" end
			if steamid64 == "76561198867007475" then return "models/cultist/heads/male/male_face_180" end
			return "models/cultist/heads/male/male_face_" .. math.random(1, 400)
		else
			if steamid64 == "76561198966614836" then return "models/cultist/heads/male/black/male_face_black_304" end
			return "models/cultist/heads/male/black/male_face_black_" .. math.random(1, 384)
		end
	else
		if not black then
			return "models/cultist/heads/female/female_face_" .. math.random(1, 135)
		else
			return "models/cultist/heads/female/black/female_face_black_" .. math.random(1, 8)
		end
	end
end

CORRUPTED_HEADS = {
	["models/cultist/heads/male/male_head_2.mdl"] = true,
	["models/cultist/heads/male/male_head_3.mdl"] = true,
	["models/cultist/heads/male/male_head_6.mdl"] = true
}

local function ArrayToMap(arr)
	local map = {}
	for _, v in ipairs(arr) do map[v] = true end
	return map
end

RXSEND_SEXY_CHEMISTS = ArrayToMap({"76561198992538944", "76561198157355434", "76561198313424598", "76561198362124735", "76561198945943276", "76561199844957293", "76561198140280737", "76561198376629308", "76561197988103683", "76561198336701519", "76561198318718287", "76561199147978019", "76561199226082766", "76561198819734421", "76561198834615679", "76561199133126422", "76561198419953617", "76561199526441410", "76561198041120130", "76561198930754299", "76561198352370306", "76561198201445447"})
RXSEND_FEMALE_GOC = ArrayToMap({"76561198966614836", "76561198952289814", "76561199380043527", "76561199137889945", "76561198228193708", "76561198398068116", "76561198313424598", "76561198992538944", "76561198362124735", "76561198140280737", "76561198376629308", "76561197988103683", "76561198205202265", "76561198830666514", "76561198336701519", "76561198394734280", "76561198819734421", "76561198834615679", "76561199133126422", "76561198419953617", "76561199526441410", "76561198041120130", "76561198930754299", "76561198352370306", "76561198288541766"})
RXSEND_FAT_GOC = ArrayToMap({"76561198966614836", "76561199001255098", "76561198363687946", "76561198913866855"})
RXSEND_BIGASS = ArrayToMap({"76561198992538944", "76561198966614836", "76561198362124735", "76561198313424598", "76561197988103683", "76561198336701519", "76561198394734280", "76561198420505102", "76561198797549224"})
LEFACY_GLOVES_BOY = ArrayToMap({"76561198314296697", "76561198189145034", "76561198966614836", "76561198878159478", "76561198078183551", "76561198256901202", "76561199042337145", "76561199090301795", "76561199032709007", "76561198392875732", "76561198819734421", "76561198834615679", "76561199133126422", "76561198419953617", "76561199526441410", "76561198041120130", "76561198930754299", "76561198352370306", "76561199231572195", "76561198176282009", "76561198349260563"})
LEFACY_GLOVES_MGE = ArrayToMap({"76561199133126422", "76561199220664368", "76561198882003448", "76561198255240379", "76561199042352932", "76561198274138685", "76561198123638264", "76561199204595627", "76561199844957293", "76561199000547558", "76561199222095167", "76561198318718287", "76561199147978019", "76561198288541766", "76561198966614836"})
LEFACY_GLOVES_d_1 = ArrayToMap({"76561198162984281", "76561198966614836"})
LEFACY_GLOVES_pyz = ArrayToMap({"76561198362124735", "76561198966614836"})
LEFACY_GLOVES_fisher = ArrayToMap({"76561199144351466", "76561198966614836"})
LEFACY_GLOVES_ANTIFURRY = ArrayToMap({"76561198966614836"})
LEGACY_HAIRCOLOR = ArrayToMap({"76561199014587295", "76561199507725686", "76561198281030544", "76561198966614836", "76561197988103683", "76561198976658594", "76561198803892483", "76561198362124735", "76561198965530524", "76561199033186494", "76561198108880756", "76561198256901202", "76561199844957293", "76561198123654462", "76561198405805960", "76561199015801632", "76561199204595627", "76561198392875732", "76561198885298240", "76561198819734421", "76561198834615679", "76561199133126422", "76561198419953617", "76561199526441410", "76561198041120130", "76561198930754299", "76561198352370306", "76561198314296697"})
LEGACY_ROLE_PRIORITY = ArrayToMap({"76561198413522673", "76561198867007475"})
RXSEND_FEMBOY = ArrayToMap({})
RXSEND_YOUTUBERS = {["76561198363582847"] = "https://www.youtube.com/@ddos1c", ["76561199147978019"] = "https://www.youtube.com/@Ko1yaNkp"}

function util.PaintDown(start, effname, ignore) 
	local btr = util.TraceLine({start=start, endpos=(start + Vector(0,0,-256)), filter=ignore, mask=MASK_SOLID})
	util.Decal(effname, btr.HitPos + btr.HitNormal, btr.HitPos - btr.HitNormal)
end


function GM:GrabEarAnimation(ply) return false end
function IsBigRound() return GetGlobalBool("BigRound", false) end

NextOren_HEADS_BLACKHEADS = {
	["models/all_scp_models/shared/heads/head_1_7"] = true,
	["models/all_scp_models/shared/heads/head_1_8"] = true,
}

TEAM_SCP = 1
TEAM_GUARD = 2
TEAM_CLASSD = 3
TEAM_SCI = 5
TEAM_CHAOS = 6
TEAM_SECURITY = 7
TEAM_GRU = 8
TEAM_NTF = 9
TEAM_DZ = 10
TEAM_GOC = 11
TEAM_USA = 12
TEAM_QRT = 13
TEAM_COTSK = 14
TEAM_SPECIAL = 15
TEAM_OSN = 16
TEAM_NAZI = 17
TEAM_AMERICA = 18
TEAM_ARENA = 19
TEAM_RESISTANCE = 20
TEAM_COMBINE = 21
TEAM_ALPHA1 = 22
TEAM_AR = 23
TEAM_CBG = 24
TEAM_SPEC = 25
TEAM_XMAS_VRAG = 26
TEAM_XMAS_FRIEND = 27
TEAM_FURRY = 28
TEAM_ANTIFURRY = 29

BREACH.QuickChatPhrases_NonMilitaryTeams = { [TEAM_CLASSD] = true, [TEAM_SCI] = true, [TEAM_SPECIAL] = true, [TEAM_GOC] = true }
MINPLAYERS = 10

team.SetUp(1, "Fack u", Color(255, 0, 0))
team.SetUp(2, "Fack u", Color(0, 255, 0))

game.AddDecal("Decal106", "decals/decal106")

role = {}
local rolecache = {}

hook.Add("Breach_LanguageChanged", "UpdateRoleCache", function() rolecache = {} end)

local function GetLangRoleForCache(rl)
	if clang == nil then clang = english end
	if string.StartWith(rl, "SCP") then return role[rl] or "LANG ERROR!" end

	local rolef = nil
	for k, v in pairs(role) do
		if rl == v then rolef = k break end
	end
	return rolef and (clang.role[rolef] or "LANG ERROR!") or (rl or "LANG ERROR!")
end

function GetLangRole(rl)
	if not rolecache[rl] then rolecache[rl] = GetLangRoleForCache(rl) end
	return rolecache[rl]
end

function NormalVector(vec) return "Vector(" .. vec.x .. ", " .. vec.y .. ", " .. vec.z .. ")" end
function NormalAngle(ang) return "Angle(" .. ang.p .. ", " .. ang.y .. ", " .. ang.r .. ")" end

function GetLangWeapon(rl)
	if clang == nil then clang = english end
	if isstring(clang.weaponry[rl]) and clang.LangName ~= "Русский" then
		return clang.weaponry[rl]
	else
		local weptable = weapons.Get(rl)
		if not istable(weptable) then
			local enttable = scripted_ents.Get(rl)
			return istable(enttable) and enttable.PrintName or rl
		end
		return weptable.PrintName
	end
end

function GetLangWeaponDesc(rl)
	if clang == nil then clang = english end
	if isstring(clang.weaponrydesc[rl]) then
		return clang.weaponrydesc[rl]
	else
		local weptable = weapons.Get(rl)
		if not istable(weptable) then
			local enttable = scripted_ents.Get(rl)
			return istable(enttable) and enttable.Desc or rl
		end
		return weptable.Desc
	end
end

SCPS = {}

role.SCP0082 = "SCP0082"
role.ADMIN = "ADMIN MODE"
SCP106, SCP049, SCP638, SCP076, SCP8602, SCP062FR, SCP006FR, SCP1015RU = "SCP106", "SCP049", "SCP638", "SCP0762", "SCP8602", "SCP062FR", "SCP006FR", "SCP1015RU"
SCP1027RU, SCP062DE, SCP096, SCP542, SCP966, SCP999, SCP1903, SCP973 = "SCP1027RU", "SCP062DE", "SCP096", "SCP542", "SCP966", "SCP999", "SCP1903", "SCP973"
SCP457, SCP173, SCP2012, SCP082, SCP939, SCP811, SCP682, SCP076, SCP912 = "SCP457", "SCP173", "SCP2012", "SCP082", "SCP939", "SCP811", "SCP682", "SCP076", "SCP912"

role.SCI_Assistant, role.SCI_Grunt, role.SCI_Tester, role.SCI_Recruiter = "Assistant", "Scientist", "Researcher", "Ethics Comitee"
role.SCI_Medic, role.SCI_Cleaner, role.SCI_Head, role.SCI_SpyUSA = "Medic", "Cleaner", "Head of Personnel", "UIU Spy"
role.USA, role.Nazi, role.EliteCombine, role.ShotCombine, role.SmgCombine = "USA Soldier", "Reich Soldat", "Elite Combine", "Nova Prospect Combine", "Echo Combine"
role.GF, role.RESISTANCE, role.SNOWMAN, role.SANTA, role.furry, role.antifurry = "Gordon Freeman", "Rebel", "SnowMan", "Santa", "furry", "antifurry"
role.ArenaParticipant = "Arena participant"

role.ClassD_FartInhaler, role.ClassD_Default, role.ClassD_Pron, role.ClassD_Thief = "Class-D FartInhaler", "Class-D", "Class-D Pron", "Class-D Thief"
role.ClassD_Fat, role.ClassD_Bor, role.ClassD_Hack, role.ClassD_Cannibal = "Class-D Fat", "Class-D Bor", "Class-D Hacker", "Class-D Cannibal"
role.ClassD_Probitiy, role.ClassD_Fast, role.ClassD_Snitch, role.ClassD_Killer = "Class-D Probitiy", "Class-D Fast", "Class-D Snitch", "Class-D Killer"
role.ClassD_Hitman, role.ClassD_Banned = "Class-D Stealthy", "Class-D Banned"

role.SECURITY_Recruit, role.SECURITY_Sergeant, role.SECURITY_OFFICER, role.SECURITY_Warden = "Security Rookie", "Security Sergeant", "Security Officer", "Security Warden"
role.SECURITY_Shocktrooper, role.SECURITY_IMVSOLDIER, role.SECURITY_Chief = "Security Shock trooper", "Security Specialist", "Security Chief"

role.MTF_Guard, role.MTF_Medic, role.MTF_Left, role.MTF_Chem = "MTF Guard", "MTF Medic", "MTF Left", "MTF Chemist"
role.MTF_Shock, role.MTF_Specialist, role.MTF_Com, role.MTF_Engi = "MTF Shock trooper", "MTF Specialist", "Head of Security", "MTF Engineer"
role.MTF_HOF, role.MTF_Security, role.Dispatcher, role.MTF_Jag, role.MTF_O5 = "Head of Facility", "MTF Security", "Dispatcher", "MTF Juggernaut", "O5-4: 'Ambassador'"

role.TG_Nerd, role.TG_Capral, role.TG_Ser, role.TG_SerPlus, role.TG_Left, role.TG_Com = "TG Recruit", "TG Corporal", "TG Sergeant", "TG Staff Sergeant", "TG Lieutenant", "TG Leader"

role.SCI_SPECIAL_DAMAGE, role.SCI_SPECIAL_HEALER, role.SCI_SPECIAL_SLOWER = "Kelen", "Matilda", "Speedwone"
role.SCI_SPECIAL_SPEED, role.SCI_SPECIAL_MINE, role.SCI_SPECIAL_BOOSTER = "Lomao", "Feelon", "Georg"
role.SCI_SPECIAL_SHIELD, role.SCI_SPECIAL_INVISIBLE, role.SCI_SPECIAL_VISION = "Shieldmeh", "Ruprecht", "Hedwig"

role.NTF_Soldier, role.NTF_Specialist, role.NTF_Sniper = "NTF Grunt", "NTF Specialist", "NTF Sniper"
role.NTF_Shock, role.NTF_Commander, role.NTF_Pilot = "NTF Shock trooper", "NTF Commander", "NTF Pilot"

role.OSN_Soldier, role.OSN_Specialist, role.OSN_Commander, role.OSN_Attaker = "STS Grunt", "STS Specialist", "STS Commander", "STS Suppressor"
role.GRU_Soldier, role.GRU_Specialist, role.GRU_Jugg, role.GRU_Commander = "GRU Soldier", "GRU Specialist", "GRU Juggernaut", "GRU Commander"
role.ALPHA1_Soldier, role.ALPHA1_Specialist, role.ALPHA1_Commander = "RRH Soldier", "RRH Specialist", "RRH Commander"

role.AR_Coordinator, role.AR_Executor, role.AR_Matilda = "AR Coordinator", "AR Specialist", "AR Matilda"
role.CBG_Com, role.CBG_Sold, role.CBG_Spec, role.CBG = "CBG Preacher", "CBG Follower", "CBG Shaman", "Broken God"

role.UIU_Soldier, role.UIU_Commander, role.UIU_Specialist, role.UIU_Clocker = "UIU Soldier", "UIU Commander", "UIU Specialist", "UIU Infiltrator"
role.UIU_Agent, role.UIU_Agent_Commander, role.UIU_Agent_Sniper = "UIU Agent", "UIU Agent's Commander", "UIU Agent's Sniper"
role.UIU_Agent_Specialist, role.UIU_Agent_Information = "UIU Agent's Specialist", "UIU Agent's Information"

function BREACH:IsUiuAgent(r)
	return r == role.UIU_Agent or r == role.UIU_Agent_Commander or r == role.UIU_Agent_Sniper or r == role.UIU_Agent_Specialist or r == role.UIU_Agent_Information
end

role.CBG_Psycho = "CBG Psycho"
role.DZ_Grunt, role.DZ_Gas, role.DZ_Psycho, role.DZ_Commander, role.SCI_SpyDZ = "SH Soldier", "SH Chemist", "SH Psycho", "SH Commander", "SH Spy"
role.Goc_Grunt, role.Goc_Commander, role.Goc_Jag, role.Goc_Special, role.ClassD_GOCSpy = "GOC Soldier", "GOC Commander", "GOC Juggernaut", "GOC Specialist", "GOC Spy"
role.QRT_Soldier, role.QRT_Medic, role.QRT_ShockTrooper, role.QRT_Commander = "QRT Soldier", "QRT Medic", "QRT Shock trooper", "QRT Commander"
role.QRT_Machinegunner, role.QRT_Shield, role.QRT_Marksmen = "QRT Machinegunner", "QRT Shield", "QRT Marksman"
role.SECURITY_Spy, role.Chaos_Grunt, role.Chaos_Commander, role.Chaos_Jugg, role.Chaos_Demo = "CI Spy", "CI Soldier", "CI Commander", "CI Juggernaut", "CI Demoman"
role.Cult_Grunt, role.Cult_Psycho, role.Cult_Commander, role.Cult_Specialist, role.Cult_BombGrunt = "COTSK Grunt", "COTSK Psycho", "COTSK Commander", "COTSK Specialist", "COTSK BombGrunt"
role.Spectator, role.vort, role.vort2, role.vort3 = "Spectator", "vort", "vort2", "vort3"

role.SCP079, role.SCP049, role.SCP062DE, role.SCP006FR, role.SCP062FR = "SCP-079", "SCP-049", "SCP-062-DE", "SCP-006-FR", "SCP-062-FR"
role.SCP1903, role.SCP8602, role.SCP638, role.SCP106, role.SCP096 = "SCP-1903", "SCP-860-2", "SCP-638", "SCP-106", "SCP-096"
role.SCP973, role.SCP457, role.SCP999 = "SCP-973", "SCP-457", "SCP-999-2"
role.SCP173, role.SCP2012, role.SCP082, role.SCP939, role.SCP682, role.SCP811, role.SCP542, role.SCP966, role.SCP076, role.SCP912 = "SCP-173", "SCP-2012", "SCP-082", "SCP-0939", "SCP-682", "SCP-811", "SCP-542", "SCP-966", "SCP-076-2", "SCP-912"

function mply:IIHasWeapon(class)
	local invData = SERVER and self.Inventory or self.operdatainv
	if not invData or not invData["Items"] then return false end
	
	for _, item in ipairs(invData["Items"]) do
		if item and item.class == class then
			return true
		end
	end
	return false
end

Radio_RandChannelList = Radio_RandChannelList or {
	{ teams = {TEAM_GUARD, TEAM_SECURITY, TEAM_QRT, TEAM_NTF, TEAM_OSN, TEAM_ALPHA1}, allowedroles = {"CI Spy"}, blockedroles = {}, chan = 101.1 },
	{ teams = {TEAM_DZ}, allowedroles = {}, blockedroles = {}, chan = 102.1 },
	{ teams = {TEAM_CHAOS}, allowedroles = {}, blockedroles = {"CI Spy"}, chan = 103.1 },
	{ teams = {TEAM_GRU}, allowedroles = {}, blockedroles = {}, chan = 104.1 },
	{ teams = {TEAM_COTSK}, allowedroles = {}, blockedroles = {}, chan = 105.1 },
	{ teams = {TEAM_GOC}, allowedroles = {}, blockedroles = {}, chan = 106.1 },
	{ teams = {TEAM_USA}, allowedroles = {}, blockedroles = {}, chan = 107.1 },
	{ teams = {TEAM_AR}, allowedroles = {}, blockedroles = {}, chan = 108.1 },
	{ teams = {TEAM_CBG}, allowedroles = {}, blockedroles = {}, chan = 109.1 },
}

function Radio_RandomizeChannels()
	for _, tab in pairs(Radio_RandChannelList) do
		tab.chan = tonumber(math.random(100, 999) .. "." .. math.random(1, 9))
	end
end

function Radio_GetChannel(team, rolename)
	for _, tab in ipairs(Radio_RandChannelList) do
		if (table.HasValue(tab.teams, team) and not table.HasValue(tab.blockedroles, rolename)) or table.HasValue(tab.allowedroles, rolename) then 
			return tab.chan 
		end
	end
	return 100.1
end

local function CreateServerCvar(name, default, desc, flags)
	flags = flags or {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}
	if not ConVarExists(name) then CreateConVar(name, default, flags, desc) end
end

CreateServerCvar("br_roundrestart", "0", "Restart the round")
CreateServerCvar("br_time_preparing", "60", "Set preparing time")
CreateServerCvar("br_time_round", "780", "Set round time")
CreateServerCvar("br_time_postround", "30", "Set postround time")
CreateServerCvar("br_time_ntfenter", "360", "Time that NTF units will enter the facility")
CreateServerCvar("br_time_blink", "0.25", "Blink timer")
CreateServerCvar("br_time_blinkdelay", "5", "Delay between blinks")
CreateServerCvar("br_spawnzombies", "0", "Do you want zombies?")
CreateServerCvar("br_scoreboardranks", "0", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateServerCvar("br_defaultlanguage", "english", "")
CreateServerCvar("br_expscale", "1", "")
CreateServerCvar("br_scp_cars", "0", "Allow SCPs to drive cars?")
CreateServerCvar("br_allow_vehicle", "1", "Allow vehicle spawn?")
CreateServerCvar("br_dclass_keycards", "0", "Is D class supposed to have keycards?")
CreateServerCvar("br_time_explode", "30", "Time from call br_destroygatea to explode")
CreateServerCvar("br_ci_percentage", "25", "Percentage of CI spawn")
CreateServerCvar("br_i4_min_mtf", "4", "Percentage of CI spawn")
CreateServerCvar("br_cars_oldmodels", "0", "Use old cars models?")
CreateServerCvar("br_premium_url", "", "Link to premium members list", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_premium_mult", "1.25", "Premium members exp multiplier", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_premium_display", "Premium player %s has joined!", "Text shown to all players when premium member joins", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_stamina_enable", "1", "Is stamina allowed?")
CreateServerCvar("br_stamina_scale", "1, 1", "Stamina regen and use.", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_rounds", "0", "How many round before map restart? 0 - dont restart", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_min_players", "2", "Minimum players to start round")
CreateServerCvar("br_firstround_debug", "1", "Skip first round", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_force_specialround", "", "Available special rounds [ infect, multi ]", {FCVAR_SERVER_CAN_EXECUTE})
CreateServerCvar("br_specialround_pct", "10", "Skip first round")
CreateServerCvar("br_cars_ammount", "12", "How many cars should spawn?")
CreateServerCvar("br_dropvestondeath", "1", "Do players drop vests on death?")
CreateServerCvar("br_force_showupdates", "0", "Should players see update logs any time they join to server?", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_allow_scptovoicechat", "0", "Can SCPs talk with humans?")
CreateServerCvar("br_ulx_premiumgroup_name", "", "Name of ULX premium group", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_experimental_bulletdamage_system", "0", "Turn it off when you see any problems with bullets", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_experimental_antiknockback_force", "5", "Turn it off when you see any problems with bullets", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_allow_ineye_spectate", "0", "")
CreateServerCvar("br_allow_roaming_spectate", "1", "")
CreateServerCvar("br_scale_bullet_damage", "1", "Bullet damage scale")
CreateServerCvar("br_new_eq", "1", "Enables new EQ", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateServerCvar("br_enable_warhead", "1", "Enables OMEGA Warhead", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_scale_human_damage", "1", "Scales damage dealt by humans", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_scale_scp_damage", "1", "Scales damage dealt by SCP", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_scp_penalty", "3", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
CreateServerCvar("br_premium_penalty", "0", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})

function table.Random(tab, issequential)
	local keys = issequential and tab or table.GetKeys(tab)
	if #keys == 0 then return nil, nil end
	local rand = keys[math.random(1, #keys)]
	return tab[rand], rand 
end

function BREACH.GroundPos(pos)
	local tr = util.TraceLine({start = pos, endpos = pos - Vector(0,0,32768), mask = MASK_BLOCKLOS})
	return tr.Hit and tr.HitPos or pos
end

local canjumpscp = {}
local cancrouchscp = {}

BREACH.EMOTES = {
	{ name = "l:emote_agree", premium = false, gesture = "0_shaky_handgesture_agree" },
	{ name = "l:emote_disagree", premium = false, gesture = "0_shaky_handgesture_disagree" },
	{ name = "l:emote_disapprove", premium = false, gesture = "0_shaky_handgesture_disapprove" },
	{ name = "l:emote_salute", premium = false, gesture = "0_shaky_handgesture_salute" },
	{ name = "l:emote_wave", premium = false, gesture = "0_shaky_handgesture_wave" },
	{ name = "l:emote_point", premium = false, gesture = "0_shaky_handgesture_point" },
}

hook.Add("SetupMove", "OverrideMovement", function(ply, mv, cmd)
	local movetype = ply:GetMoveType()
	if movetype == MOVETYPE_NOCLIP or movetype == MOVETYPE_OBSERVER then return end

	local rolename = ply:GetRoleName()
	local ducking = mv:KeyDown(IN_DUCK)
	local jumping = mv:KeyDown(IN_JUMP)

	if ply:Crouching() and jumping then
		mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
	end

	if ply:GTeam() ~= TEAM_SCP then
		if ducking then
			ply:SetDuckSpeed(0.1)
			ply:SetUnDuckSpeed(0.1)
			if jumping then mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP))) end
		end
	else
		if jumping and not canjumpscp[rolename] then mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP))) end
		if ducking and not cancrouchscp[rolename] then mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_DUCK))) end
	end
end)

function mply:StopForcedAnimation()
	if CLIENT then return end
	timer.Remove("SeqF"..self:EntIndex())
	timer.Remove("MoveCheckSeq"..self:EntIndex())
	if isfunction(self.StopFAnimCallback) then self.StopFAnimCallback() self.StopFAnimCallback = nil end
	
	self.ForceAnimSequence = nil		
	net.Start("SHAKY_EndForcedAnimSync")
	net.WriteEntity(self)
	net.Broadcast()
end

if CLIENT then
	net.Receive("SHAKY_EndForcedAnimSync", function(len)
		local ply = net.ReadEntity()
		if IsValid(ply) then ply.ForceAnimSequence = nil end
	end)
	
	net.Receive("SHAKY_SetForcedAnimSync", function(len)
		local ply = net.ReadEntity()
		if not IsValid(ply) then return end
		local sequence = net.ReadString()
		ply:SetCycle(0)
		ply.ForceAnimSequence = ply:LookupSequence(sequence)
	end)
end

MINPLAYERS = GetConVar("br_min_players"):GetInt()

function GetPrepTime() return GetGlobalBool("FurryRound") and 1 or (BREACH.RoundPrepareTime or 62) end
function GetRoundTime() return GetGlobalBool("EventRound") and 300 or (GetGlobalBool("BigRound", false) and 960 or 720) end
function GetPostTime() return 30 end
function GM:EntityFireBullets(ent, data) end

local AllowedModels = {
	["models/cultist/humans/mog/mog.mdl"] = true, ["models/cultist/humans/chaos/chaos.mdl"] = true,
	["models/cultist/humans/osn/osn.mdl"] = true, ["models/cultist/humans/chaos/fat/chaos_fat.mdl"] = true,
	["models/cultist/humans/ntf/ntf.mdl"] = true, ["models/cultist/humans/goc/goc.mdl"] = true,
	["models/cultist/humans/fbi/fbi.mdl"] = true, ["models/cultist/humans/nazi/nazi.mdl"] = true,
	["models/cultist/humans/russian/russians.mdl"] = true, ["models/cultist/humans/mog/mog_hazmat.mdl"] = true,
	["models/cultist/humans/obr/obr.mdl"] = true, ["models/cultist/humans/obr/obr_new.mdl"] = true,
	["models/cultist/humans/mog/mog_jagger.mdl"] = true, ["models/cultist/humans/mog/mog_woman_capt.mdl"] = true,
	["models/cultist/humans/mog/mog_woman.mdl"] = true, ["models/cultist/humans/goc/goc_female_commander.mdl"] = true,
	["models/cultist/humans/fbi/fbi_woman.mdl"] = true, ["models/cultist/humans/ntf/ntf_female_sniper.mdl"] = true,
	["models/cultist/scp/scp_912.mdl"] = true, ["models/cultist/humans/mog/sexy_mog_hazmat.mdl"] = true,
	["models/imperator/humans/ar/ar.mdl"] = true,
}

local silencedwalkroles = {
	[role.UIU_Clocker] = true, ["SCP457"] = true, ["SCP096"] = true,
	["SCP062DE"] = true, ["SCP062FR"] = true, ["SCP1903"] = true,
	["SCP999"] = true, ["SCP106"] = true,
}

SCPFOOTSTEP = { ["SCP682"] = true, ["SCP939"] = true, ["SCP082"] = true }
FOOTSTEP_SOUNDTIME = { ["SCP638"] = 500 }

function ment:IsLZ()
	local pos = self:GetPos()
	if pos.z < 1482 then
		if (pos.z < 550 and pos.z > -550 and pos.y < -4640) then return true end
		if (pos.x > 4600 and pos.y > -7003 and pos.y < -1200 and pos.z < 880) or 
		   (pos.x > 8550 and pos.y < -440 and pos.y > -7000) or 
		   (pos.x > -1000 and pos.x < 1680 and pos.y < -3600 and pos.y > -6000 and pos.z > -1300) then return true end
		if (pos.x > 7283 and pos.x < 7680 and pos.y < -1075 and pos.y > -1240) then return true end
	end
	return false
end

function ment:Outside() return self:GetPos().z > 880 end

// ИСПРАВЛЕНИЕ: Оптимизирована функция IsEntrance (замена && на and)
function ment:IsEntrance()
	local pos = self:GetPos()
	return (pos.x < 1767 and pos.x > -3120 and pos.y > 1944 and pos.y < 6600 and pos.z < 880)
end

function mply:IsBlack()
	for _, v in ipairs(ents.FindByClassAndParent("ent_bonemerged", self) or {}) do
		if IsValid(v) and (v:GetModel():find("balaclava") or v:GetModel():find("head_main_1")) then
			if NextOren_HEADS_BLACKHEADS[v:GetSubMaterial(0)] or NextOren_HEADS_BLACKHEADS[v:GetSubMaterial(2)] then
				return true
			end
		end
	end
	return false
end

// ИСПРАВЛЕНИЕ: Оптимизирована функция IsHardZone (замена && на and)
function ment:IsHardZone()
	local pos = self:GetPos()
	return (pos.x < 8320 and pos.x > 1200 and pos.y > -1200 and pos.z < 880)
end

local blockeddoors_scp = {
	Vector(-105, 6153, 786), Vector(-2588.12, 7636.62, 787.22), Vector(-4742.49, 4279.50, 530.25),
	Vector(-4560, 4486, 530), Vector(-942.47, 1279.97, -136.19), Vector(-1149.75, 8030, 1710.78),
	Vector(-1008.86, 1240.85, -137), Vector(-1149.76, 8030.00, 1710.80), Vector(-1167.76, 7946.00, 1710),
	Vector(-1167.75, 7946, 1710), Vector(-942.47, 1279.97, -136.19), Vector(-744, 1404.01, -138),
	Vector(-5028.97, 3993.5, -1947),
}

local banned_models = {
	["*506"] = true, ["*507"] = true, ["*474"] = true, ["*473"] = true, ["*290"] = true, ["*291"] = true, ["*344"] = true,
	["models/cult_props/gates/bunker_gates/bunker_door_right.mdl"] = true,
	["models/cult_props/gates/bunker_gates/bunker_door_left.mdl"] = true,
}

function hook.Exists(var, var2)
	local tab = hook.GetTable()
	return tab[var] and tab[var2] ~= nil
end

function GM:ShouldCollide(ent1, ent2)
	local ent1_class = ent1:GetClass()
	local ent2_class = ent2:GetClass()

	if (ent1:IsPlayer() and ent1:GTeam() == TEAM_SCP) or (ent2:IsPlayer() and ent2:GTeam() == TEAM_SCP) then
		if (ent1_class == "func_door" or ent2_class == "func_door" or ent2_class == "prop_dynamic" or ent1_class == "prop_dynamic") and not banned_models[ent1:GetModel()] and not banned_models[ent2:GetModel()] then
			if (ent1:IsPlayer() and ent1:GetRoleName() == SCP106) or (ent2:IsPlayer() and ent2:GetRoleName() == SCP106) then
				return false
			end
			if (ent1:IsPlayer() and ent1:GetRoleName() == SCP096 and ent1:GetWalkSpeed() ~= 40) or (ent2:IsPlayer() and ent2:GetRoleName() == SCP096 and ent2:GetWalkSpeed() ~= 40) then
				if SERVER and (ent1:CreatedByMap() or ent2:CreatedByMap()) then
					return false
				end
			end
		end
	end
	return true
end

function GM:Move(ply, mv) end

function ment:AddNetworkVar(name, type)
	if not self._NVTable then
		self._NVTable = {
			Int = {0, 32}, Float = {0, 32}, Bool = {0, 32},
			String = {0, 4}, Vector = {0, 32}, Angle = {0, 32}, Entity = {0, 32}
		}
	end
	local tab = self._NVTable[type]
	self:NetworkVar(type, tab[1], name)
	tab[1] = tab[1] + 1
end

local function AddModelAndHands(id, mdl, hands_mdl)
	player_manager.AddValidModel(id, mdl)
	player_manager.AddValidHands(id, hands_mdl, 0, "000000")
end

AddModelAndHands("12312399", "models/cultist/humans/chaos/fat/chaos_fat.mdl", "models/cultist/humans/chaos/hands/c_arms_chaos.mdl")
AddModelAndHands("777771", "models/shaky/scp/scp2012/scp_2012.mdl", "models/cultist/scp/scp2012/scp_2012_arms.mdl")
AddModelAndHands("777772", "models/cultist/scp/scp_076.mdl", "models/cultist/scp/scp_076_arms.mdl")
AddModelAndHands("125312399", "models/cultist/humans/osn/osn.mdl", "models/cultist/humans/obr/hands/c_arms_obr_new.mdl")
AddModelAndHands("125312398", "models/cultist/humans/specialmod/nazi/nazi.mdl", "models/cultist/humans/specialmod/nazi/arms/c_arms_nazi.mdl")
AddModelAndHands("125312397", "models/cultist/humans/specialmod/american/american.mdl", "models/cultist/humans/specialmod/american/arms/c_arms_american.mdl")
AddModelAndHands("125312396", "models/cultist/humans/sci/class_d_fat.mdl", "models/cultist/humans/sci/hands/c_arms_sci.mdl")
AddModelAndHands("125312395", "models/cultist/humans/sci/class_d_bor.mdl", "models/cultist/humans/sci/hands/c_arms_sci.mdl")
AddModelAndHands("21525", "models/cultist/humans/mog/mog_woman_capt.mdl", "models/cultist/humans/mog/hands/c_arms_mog.mdl")
AddModelAndHands("6216", "models/cultist/humans/mog/mog_woman.mdl", "models/cultist/humans/mog/hands/c_arms_mog.mdl")
AddModelAndHands("62161", "models/cultist/humans/goc/goc_female_commander.mdl", "models/cultist/humans/goc/hands/c_arms_goc.mdl")
AddModelAndHands("62162", "models/cultist/humans/fbi/fbi_woman.mdl", "models/cultist/humans/fbi/hands/c_arms_fbi.mdl")
AddModelAndHands("62167", "models/cultist/humans/ntf/ntf_female_sniper.mdl", "models/cultist/humans/ntf/hands/c_arms_ntf.mdl")
AddModelAndHands("62163", "models/cultist/humans/mog/special_security_woman.mdl", "models/cultist/humans/mog/hands/c_arms_admin.mdl")
AddModelAndHands("62164", "models/cultist/humans/security/security_female.mdl", "models/cultist/humans/security/hands/c_arms_security.mdl")
AddModelAndHands("62165", "models/cultist/humans/class_d/shaky/class_d_fat_new.mdl", "models/cultist/humans/class_d/hands/c_arms_class_d.mdl")
AddModelAndHands("62166", "models/cultist/humans/class_d/shaky/class_d_bor_new.mdl", "models/cultist/humans/class_d/hands/c_arms_class_d.mdl")
AddModelAndHands("62167_obr", "models/cultist/humans/obr/obr_new.mdl", "models/cultist/humans/obr/hands/c_arms_obr_new.mdl")
AddModelAndHands("62168", "models/cultist/humans/mog/sexy_mog_hazmat.mdl", "models/cultist/humans/mog/hands/c_arms_hazmat.mdl")
AddModelAndHands("fbi_a", "models/cultist/humans/fbi/fbi_agent.mdl", "models/cultist/humans/fbi/hands/c_arms_fbi.mdl")

local adminGroups = { "superadmin", "admin", "operator", "Gl.event", "event", "headadmin", "cm" }
function mply:IsAdmin()
	if not IsValid(self) then return false end
	local userGroup = self:GetUserGroup()
	for _, group in ipairs(adminGroups) do
		if userGroup == group then return true end
	end
	return false
end

kasanov = kasanov or {}
kasanov.array = kasanov.array or {}
function kasanov.array.toKeys(array, value)
	if value == nil then value = true end
	local out = {}
	for _, v in ipairs(array) do out[v] = value end
	return out
end

function mply:IsDonator()
	if not IsValid(self) then return false end
	local sid = self:SteamID64()
	if self:GetUserGroup() == "donator" or sid == "76561198362124735" or sid == "76561198376629308" then return true end
	return false
end

if SERVER then
	resource.AddFile("sound/hitmarkers/mlghit.wav")
	util.AddNetworkString("DrawHitMarker")
	util.AddNetworkString("OpenMixer")
	
	hook.Add("EntityTakeDamage", "HitmarkerDetector", function(ply, dmginfo)
		local att = dmginfo:GetAttacker()
		if IsValid(att) and att:IsPlayer() and att ~= ply and (ply:IsPlayer() or ply:IsNPC()) then 
			net.Start("DrawHitMarker") net.Send(att) 
		end
	end)
	
	hook.Add("PlayerSay", "ColorMixerOpen", function(ply, text)
		if string.lower(text):sub(1, 8) == "!hmcolor" then
			net.Start("OpenMixer") net.Send(ply)
			return false
		end
	end)
end

if CLIENT then
	local hm_type = CreateClientConVar("hm_hitmarkertype", "lines", true, true)
	local hm_color = CreateClientConVar("hm_hitmarkercolor", "255, 255, 0", true, true)
	local hm_sound = CreateClientConVar("hm_hitsound", "1", true, true)	
	local DrawHitM, alpha = false, 0
	
	net.Receive("DrawHitMarker", function()
		DrawHitM, alpha = true, 255 
	end)

	local function GrabColor() 
		local coltable = string.Explode(",", hm_color:GetString())
		return Color(tonumber(coltable[1]) or 0, tonumber(coltable[2]) or 0, tonumber(coltable[3]) or 0)
	end
	
	hook.Add("HUDPaint", "HitmarkerDrawer", function() 
		local t = LocalPlayer():GTeam()
		if t ~= TEAM_AMERICA and t ~= TEAM_COMBINE and t ~= TEAM_RESISTANCE and t ~= TEAM_NAZI then return end 
		
		if DrawHitM then
			local x, y = ScrW() / 2, ScrH() / 2
			alpha = math.Approach(alpha, 0, 5)
			local col = GrabColor() col.a = alpha 
			surface.SetDrawColor(col)
			
			local sel = string.lower(hm_type:GetString())
			if sel == "lines" or sel == "" then 
				surface.DrawLine(x - 6, y - 5, x - 11, y - 10) surface.DrawLine(x + 5, y - 5, x + 10, y - 10)
				surface.DrawLine(x - 6, y + 5, x - 11, y + 10) surface.DrawLine(x + 5, y + 5, x + 10, y + 10)
			elseif sel == "sidesqr_lines" then
				surface.DrawLine(x - 15, y, x, y + 15) surface.DrawLine(x + 15, y, x, y - 15)
				surface.DrawLine(x, y + 15, x + 15, y) surface.DrawLine(x, y - 15, x - 15, y)
				surface.DrawLine(x - 5, y - 5, x - 10, y - 10) surface.DrawLine(x + 5, y - 5, x + 10, y - 10)
				surface.DrawLine(x - 5, y + 5, x - 10, y + 10) surface.DrawLine(x + 5, y + 5, x + 10, y + 10)
			elseif sel == "sqr_rot" then
				surface.DrawLine(x - 15, y, x, y + 15) surface.DrawLine(x + 15, y, x, y - 15)
				surface.DrawLine(x, y + 15, x + 15, y) surface.DrawLine(x, y - 15, x - 15, y)
			end
		end
	end)
end

function GetTopFragger()
	local topPlayer, maxFrags = nil, -1
	for _, ply in player.Iterator() do
		if ply:Frags() > maxFrags then
			maxFrags = ply:Frags()
			topPlayer = ply
		end
	end
	return topPlayer, maxFrags
end

function mply:HasBNM(model)
	for _, v in ipairs(self:LookupBonemerges() or {}) do
		if v:GetModel() == model then return true end
	end
	return false
end

local replacewords = { {"милый", "милашка"}, {"милые", "милашки"}, {"<3", ":3"}, {"фурриеб", "фуррилюб~"}, {"фурри", "фурряшки"}, {"пушистый", "пушистик~"} }
local replaceletters = { {"ить", "ють"}, {"рр", "ррр~"}, {"ер", "ерръ"}, {"ую", "уууую"}, {"яв", "явъ~"}, {"ст", "сть"}, {"ый", "ийъ"}, {"ну", "нъю"}, {"но", "нъо"}, {"ия", "йя~"}, {"дь", "ть"}, {"ое", "оъе"}, {"вы", "ви"}, {"лала", "лалъя"}, {"нет", "нетъ"}, {"ем", "емъ"}, {"шимся", "шимьъся"}, {"ю", "йу"} }
local endwords = {":3", "<3", ">w<", "OwO", "UwU", "woo", "^w^"}
local eng_rpl = { ["ove"]="uv", ["r"]="w", ["l"]="w" }

for _, w in ipairs({"a", "e", "i", "o", "u"}) do eng_rpl["n" .. w] = "ny" end
for i, v in pairs(eng_rpl) do if i ~= v:upper() then eng_rpl[i:upper()] = v:upper() end end

local cache = {}
function string.furry(str, maxrepl)
	if cache[str] then return cache[str] end
	maxrepl = math.Clamp(maxrepl or 255, 2, 999)
	local exp = string.Explode(" ", str)
	if #exp <= 0 then return end
	local out = {}

	for i = 1, math.min(maxrepl, #exp) do
		local d = exp[i]
		if d then
			for _, v in ipairs(replacewords) do if v[1] == d then d = v[2] break end end
			for _, v in ipairs(replaceletters) do if d:find(v[1]) then d = d:gsub(v[1], v[2]) end end
			for k, v in pairs(eng_rpl) do d = d:gsub(k, v) end
			table.insert(out, d)
		end
	end

	if math.random(0, 1) == 1 then table.insert(out, endwords[math.random(1, #endwords)]) end
	if math.random(0, 5) == 1 then table.insert(out, ("~"):rep(math.random(1, 3))) end

	local result = table.concat(out, " ")
	cache[str] = result
	return result
end

--hook.Add("PlayerFootstep", "DisableAllFootsteps", function() return true end)

local pos1 = Vector(6032.66, -6367.04, 0)
local pos2 = Vector(6029.10, -6783.16, 129)
local bMin = Vector(math.min(pos1.x, pos2.x), math.min(pos1.y, pos2.y), math.min(pos1.z, pos2.z))
local bMax = Vector(math.max(pos1.x, pos2.x), math.max(pos1.y, pos2.y), math.max(pos1.z, pos2.z))
local center = (bMin + bMax) / 2

local wallX, thickness = center.x, 25
local bMinY, bMaxY = bMin.y - 50, bMax.y + 50
local bMinZ, bMaxZ = bMin.z - 100, bMax.z + 200

hook.Add("FinishMove", "MentalBarrier_SoftwareWall", function(ply, mv)
	if not GetGlobalBool("MentalBarrierActive", false) then return end
	local mt = ply:GetMoveType()
	if not ply:Alive() or mt == MOVETYPE_NOCLIP or mt == MOVETYPE_OBSERVER then return end

	local pos = mv:GetOrigin()
	if pos.y >= bMinY and pos.y <= bMaxY and pos.z >= bMinZ and pos.z <= bMaxZ then
		if pos.x > (wallX - thickness) and pos.x < (wallX + thickness) then
			local vel = mv:GetVelocity()
			if pos.x >= wallX then
				pos.x = wallX + thickness
				if vel.x < 0 then vel.x = 0 end
			else
				pos.x = wallX - thickness
				if vel.x > 0 then vel.x = 0 end
			end
			mv:SetOrigin(pos)
			mv:SetVelocity(vel)
		end
	end
end)

MogConfigurations = {
    helmets = {
        { name = "l:mog_helm_none", buf = "l:mog_buf_speed35", debuf = "l:mog_def_headshot", price = 0, model = "none", icon = "nextoren/mog/hel/nill.png" },
        { name = "l:mog_helm_phones", buf = "l:mog_buf_cap", debuf = "l:mog_def_headshot", price = 5, model = "models/cultist/humans/mog/head_gear/cap_engi.mdl", icon = "nextoren/mog/hel/eng.png" },
        { name = "l:mog_helm_light", buf = "l:mog_buf_head20", debuf = "", price = 40, model = "models/cultist/humans/security/head_gear/helmet.mdl", icon = "nextoren/mog/hel/mini.png" },
        { name = "l:mog_helm_med", buf = "l:mog_buf_head40", debuf = "l:mog_def_speed10", price = 80, model = "models/cultist/humans/mog/head_gear/mog_helmet.mdl", icon = "nextoren/mog/hel/meed.png" },
        { name = "l:mog_helm_heavy", buf = "l:mog_buf_head60", debuf = "l:mog_def_speed20", price = 200, model = "models/cultist/humans/mog/head_gear/jugger_helmet.mdl", icon = "nextoren/mog/hel/heavy.png" }
    },

    faces = {
        { name = "l:mog_none", buf = "l:mog_buf_face_none", debuf = "", price = 0, model = "models/cultist/heads/male/male_head_15.mdl", icon = "nextoren/mog/head/nill.png" },
        { name = "l:mog_face_bandana", buf = "l:mog_buf_face_bandana", debuf = "", price = 0, model = "models/cultist/humans/balaclavas_new/balaclava_half.mdl", icon = "nextoren/mog/head/half.png" },
        { name = "l:mog_face_balaclava", buf = "l:mog_buf_face_balaclava", debuf = "", price = 0, model = "models/cultist/humans/balaclavas_new/balaclava_full.mdl", icon = "nextoren/mog/head/full.png" },
        { name = "l:mog_face_balaclava2", buf = "l:mog_buf_face_balaclava2", debuf = "", price = 0, model = "models/cultist/humans/balaclavas_new/head_balaclava_month.mdl", icon = "nextoren/mog/head/fullm.png" },
        { name = "l:mog_face_gas", buf = "l:mog_buf_face_gas", debuf = "", price = 150, model = "models/cultist/humans/balaclavas_new/mog_hazmat.mdl", icon = "nextoren/mog/head/gaz.png" }
    },

    armor = {
        { name = "l:mog_armor_none", buf = "l:mog_buf_speed35", debuf = "l:mog_def_slots4", price = 0, bodygroups = { [0]=0, [1]=1, [2]=1, [3]=0, [4]=0, [5]=0, [7]=1 }, icon = "nextoren/mog/armor/nill.png" },
        { name = "l:mog_armor_light", buf = "l:mog_buf_body10", debuf = "l:mog_def_slots3", price = 25, bodygroups = { [0]=1, [1]=3, [2]=0, [3]=0, [4]=0, [5]=0, [7]=1 }, icon = "nextoren/mog/armor/stan.png" },
        { name = "l:mog_armor_std", buf = "l:mog_buf_body25", debuf = "l:mog_def_speed15", price = 45, bodygroups = { [0]=1, [1]=2, [2]=0, [3]=1, [4]=1, [5]=0, [7]=1 }, icon = "nextoren/mog/armor/meed.png" },
        { name = "l:mog_armor_med", buf = "l:mog_buf_body40", debuf = "l:mog_def_speed50", price = 60, bodygroups = { [0]=2, [1]=2, [2]=0, [3]=1, [4]=1, [5]=1, [7]=1 }, icon = "nextoren/mog/armor/heavy.png" },
        { name = "l:mog_armor_heavy", buf = "l:mog_buf_body60", debuf = "l:mog_def_speed70", price = 180, bodygroups = { [0]=3, [1]=0, [2]=0, [3]=1, [4]=1, [5]=0, [7]=0 }, icon = "nextoren/mog/armor/jag.png" }
    },

    skins = {
        { name = "l:mog_skin_std", buf = "l:mog_buf_speed35", debuf = "", price = 0, skin = 0, icon = "nextoren/mog/form/standart.png" },
        { name = "l:mog_skin_basalt", buf = "l:mog_buf_fire", debuf = "l:mog_def_dmg_vuln", price = 75, skin = 2, icon = "nextoren/mog/form/orange.png" },
        { name = "l:mog_skin_polymer", buf = "l:mog_buf_acid", debuf = "l:mog_def_speed20", price = 90, skin = 3, icon = "nextoren/mog/form/green.png" },
        { name = "l:mog_skin_asbestos", buf = "l:mog_buf_scp_res", debuf = "l:mog_def_bullet_vuln", price = 130, skin = 5, icon = "nextoren/mog/form/white.png" },
        { name = "l:mog_skin_kevlar", buf = "l:mog_buf_dmg_res", debuf = "l:mog_def_speed50", price = 200, skin = 4, icon = "nextoren/mog/form/black.png" }
    },

    primary_weapons = {
        { name = "weapon_hk416", price = 0 },
        { name = "weapon_sg552", price = 20 },
        { name = "weapon_ash12", price = 50 },
        { name = "weapon_vector", price = 100 },
        { name = "weapon_ak200", price = 120 },
        { name = "weapon_m590a1", price = 150 },
        { name = "weapon_m249", price = 250 }
    },

    secondary_weapons = {
        { name = "none", price = 0 },
        { name = "weapon_glock17", price = 10 },
        { name = "weapon_glock18c", price = 25 },
        { name = "weapon_glock26", price = 45 },
        { name = "weapon_revolver357", price = 70 },
        { name = "weapon_deagle", price = 100 }
    },

    nvgs = {
        { name = "none", price = 0 },
        { name = "item_nightvision_green", model = "models/imperator/items/nightvision/bonemerge_nvg_forface_green.mdl", buf = "l:mog_buf_nvg_green", price = 10 },
        { name = "item_nightvision_blue", model = "models/imperator/items/nightvision/bonemerge_nvg_forface_blue.mdl", buf = "l:mog_buf_nvg_blue", price = 55 },
        { name = "item_nightvision_white", model = "models/imperator/items/nightvision/bonemerge_nvg_forface_white.mdl", buf = "l:mog_buf_nvg_white", price = 150 },
        { name = "item_nightvision_red", model = "models/imperator/items/nightvision/bonemerge_nvg_forface_red.mdl", buf = "l:mog_buf_nvg_red", price = 300 }
    },

    gasmasks = {
        { name = "none", price = 0 },
        { name = "gasmask", price = 90 }
    },

    medkits = {
        { name = "none", price = 0 },
        { name = "item_medkit_1", price = 30 },
        { name = "item_medkit_2", price = 45 },
        { name = "item_medkit_3", price = 50 },
        { name = "item_medkit_4", price = 150 }
    },

    consumables = {
        { name = "none", price = 0 },
        { name = "item_pills", buf = "l:mog_buf_pills", price = 20 },
        { name = "item_adrenaline", buf = "l:mog_buf_adr", price = 50 },
        { name = "item_syringe", buf = "l:mog_buf_syr", price = 75 }
    },

    health_abilities = {
        { name = "l:mog_norm", icon = "nextoren/mog/abb/h_empty.png", price = 0 },
        { name = "l:mog_hp_genetics", icon = "nextoren/mog/abb/h1.png", buf = "l:mog_buf_hp25", price = 100 },
        { name = "l:mog_hp_training", icon = "nextoren/mog/abb/h2.png", buf = "l:mog_buf_hp50", price = 150 },
        { name = "l:mog_hp_monk", icon = "nextoren/mog/abb/h3.png", buf = "l:mog_buf_hp100", price = 200 }
    },

    speed_abilities = {
        { name = "l:mog_norm", icon = "nextoren/mog/abb/s_empty.png", price = 0 },
        { name = "l:mog_sp_legs", icon = "nextoren/mog/abb/s1.png", buf = "l:mog_buf_sp10", price = 70 },
        { name = "l:mog_sp_sportsman", icon = "nextoren/mog/abb/s2.png", buf = "l:mog_buf_sp30", price = 120 },
        { name = "l:mog_sp_athlete", icon = "nextoren/mog/abb/s3.png", buf = "l:mog_buf_sp50", price = 200 }
    },

    special_equipment = {
        { name = "l:mog_none", icon = "nextoren/mog/abb/nothing.png", price = 0 },
        { name = "l:mog_spec_cuffs", icon = "nextoren/gui/new_icons/handcuff.png", price = 65 },
        { name = "l:mog_spec_defib", icon = "nextoren/gui/new_icons/medic_kit.png", price = 100 },
        { name = "l:mog_spec_turret", icon = "nextoren/mog/items/turet.png", price = 200 }
    }
}

