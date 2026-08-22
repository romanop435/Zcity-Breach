local CurTime = CurTime;
local pairs = pairs;
local string = string;
local table = table;
local timer = timer;
local hook = hook;
local math = math;
local unpack = unpack;
local tonumber = tonumber;
local tostring = tostring;
local util = util
local net = net
local player = player


BREACH.Round = BREACH.Round || {}

function AdminActionLog(admin, user, title, desc)
	local niceusergroup = {
		["superadmin"] = "Creator",
		["admin"] = "Administrator",
		["headadmin"] = "Head Administrator",
		["spectator"] = "Head Administrator",
	}

	

	local nicecolor = {
		["superadmin"] = 57599,
		["admin"] = 16711680,
		["headadmin"] = 16732672,
		["spectator"] = 16732672,
	}

	local color = 0
	local name = ""
	local adminurl = "https://steamcommunity.com/profiles/76561198869328954"

	local usersteamid64 = ""

	if IsValid(user) then
		usersteamid64 = user:SteamID64()
	else
		usersteamid64 = user
	end

	local victimprofile = "https://steamcommunity.com/profiles/"

	if IsValid(user) then
		victimprofile = victimprofile..user:SteamID64()
	else
		victimprofile = victimprofile..user
	end

	if !IsValid(admin) then

		name = "SERVER"

	else

		name = admin:Name().." ("..niceusergroup[admin:GetUserGroup()]..")"
		color = nicecolor[admin:GetUserGroup()]
		adminurl = "https://steamcommunity.com/profiles/"..admin:SteamID64()

	end

	print(name,user,title,desc)

end

local function GetPlayerName(steamid)
	return ULib.bans[ steamid ] and ULib.bans[ steamid ].name
end

function InitializeBreachULX()
	if !ulx or !ULib then 
		print( "ULX or ULib not found" )
		return
	end

	function ulx.restartgame( ply, force )
		if force then
			RestartGame()
		else
			SetGlobalInt("RoundUntilRestart", 0)
		end
	end

	local restartgame = ulx.command( "Breach Admin", "ulx restart_game", ulx.restartgame, "!restartgame" )
	restartgame:addParam{ type = ULib.cmds.BoolArg, invisible = true }
	restartgame:setOpposite( "ulx restart_game_force", { _, true }, "!forcerestartgame" )
	restartgame:defaultAccess( ULib.ACCESS_SUPERADMIN )
	restartgame:help( "Restarts game" )

	function ulx.restartround( ply, silent )
		RoundRestart()
		if silent then
			ulx.fancyLogAdmin( ply, true, "#A restarted round" )
		else
			ulx.fancyLogAdmin( ply, "#A restarted round" )
		end
	end

	local restartround = ulx.command( "Breach Admin", "ulx restart_round", ulx.restartround, "!restart" )
	restartround:addParam{ type = ULib.cmds.BoolArg, invisible = true }
	restartround:setOpposite( "ulx silent restart_round", { _, true }, "!srestart" )
	restartround:defaultAccess( ULib.ACCESS_SUPERADMIN )
	restartround:help( "Restarts round" )
end

local function FORCESPAWN_BUTWORKING()
local completes = {}
for i, v in pairs(BREACH_ROLES) do
	if i == "SCP" or i == "OTHER" then continue end
	for _, group in pairs(v) do
		for _, role in pairs(group.roles) do
			table.insert(completes, role.name)
		end
	end
end

	table.sort(completes)

	function ulx.forcespawn( ply, plys, class )
        if !class then return end
        if class != "Class-D FartInhaler" then return end
        if plys[1]:GTeam() != TEAM_SPEC then
        	ply:RXSENDNotify(plys[1]:Name().." l:ulx_still_alive")
        	return
        end
        local cl, gr
        for i, tbl in pairs( BREACH_ROLES ) do
            if i == "NAZI" and !ply:IsSuperAdmin() then continue end
            for _, group in pairs( tbl ) do
                gr = group.name
                for k, clas in pairs( group.roles ) do
                    if clas.name == class or clas.name == class then
                        cl = clas
                    end
                    if cl then break end
                end
                if cl then break end
            end
        end
        if cl and gr then
            
            for k, v in pairs( plys ) do
                local pos = v:GetPos()
                v:SetupNormal()
                v:ApplyRoleStats( cl, true )
                v:SetPos(ply:GetPos())
                v:StripWeapon("item_knife")
				if v:IsAdmin() then
					v:SetModel("models/cultist/humans/mog/special_security.mdl")
					v:SetBodyGroups("000000")
				end
            end
        end
    end

    local forcespawn = ulx.command( "Breach Admin", "ulx force_spawn", ulx.forcespawn, "!forcespawn" )
    forcespawn:addParam{ type = ULib.cmds.PlayersArg }
    forcespawn:addParam{ type = ULib.cmds.StringArg, hint = "class name", completes = {"Class-D FartInhaler"}, ULib.cmds.takeRestOfLine }
    forcespawn:defaultAccess( ULib.ACCESS_SUPERADMIN )
    forcespawn:help( "Sets player(s) to specific class and spawns him" )

	function ulx.forcespawn_cool( ply, plys, class )
        if !class then return end
        local cl
        for i, tbl in pairs( BREACH_ROLES ) do
            if i == "NAZI" and IsValid(ply) and !ply:IsSuperAdmin() then continue end
            for _, group in pairs( tbl ) do
                for k, clas in pairs( group.roles ) do
                    if clas.name == class or clas.name == class then
                        cl = clas
                    end
                    if cl then break end
                end
                if cl then break end
            end
        end
        if cl then
            
            for k, v in pairs( plys ) do
                local pos = v:GetPos()
                v:SetupNormal()
                v:ApplyRoleStats( cl, true )
                v:SetPos(pos)
                BREACH.AdminLogs:Log("spawn", {
                    user = v,
                	spawn_type = SHLOG_SPAWNTYPE_ADMIN
                })
            end
        end
    end

    local forcespawn_cool = ulx.command( "Breach Admin", "ulx dev_force_spawn", ulx.forcespawn_cool, "!devforcespawn" )
    forcespawn_cool:addParam{ type = ULib.cmds.PlayersArg }
    forcespawn_cool:addParam{ type = ULib.cmds.StringArg, hint = "class name", completes = completes, ULib.cmds.takeRestOfLine }
    forcespawn_cool:defaultAccess( ULib.ACCESS_SUPERADMIN )
    forcespawn_cool:help( "Sets player(s) to specific class and spawns him" )
end




local pos_table = {}
function ulx.forcespawn_vip( ply, class )
	pos_table = {
	["Class-D FartInhaler"] = SPAWN_CLASSD,
	["Class-D Killer"] = SPAWN_CLASSD,
	["Class-D Stealthy"] = SPAWN_CLASSD,
	["Class-D Pron"] = SPAWN_CLASSD,
	["Researcher"] = SPAWN_SCIENT,
	["Ethics Comitee"] = SPAWN_SCIENT,
	["Head of Personnel"] = SPAWN_SCIENT,
	["Security Officer"] = SPAWN_SECURITY,
	["Security Warden"] = SPAWN_SECURITY,
	["Security Shock trooper"] = SPAWN_SECURITY,
	["Security Chief"] = SPAWN_SECURITY,
	["MTF Engineer"] = SPAWN_GUARD,
	["Head of Security"] = SPAWN_GUARD,
	["MTF Chemist"] = SPAWN_GUARD,
	["MTF Left"] = SPAWN_GUARD,
	["Kelen"] = SPAWN_SCIENT,
	["Matilda"] = SPAWN_SCIENT,
	["Speedwone"] = SPAWN_SCIENT,
	["Lomao"] = SPAWN_SCIENT,
	["Feelon"] = SPAWN_SCIENT,
	["Georg"] = SPAWN_SCIENT,
	["Shieldmeh"] = SPAWN_SCIENT,
	["Ruprecht"] = SPAWN_SCIENT,
	["Hedwig"] = SPAWN_SCIENT
	}
    if !class then return end
	if GetGlobalBool("EventRound") then return end
    if !table.HasValue({"Class-D FartInhaler","Class-D Killer","Class-D Stealthy","Class-D Pron","Researcher","Ethics Comitee","Head of Personnel","Security Officer","Security Warden","Security Shock trooper","Security Chief","MTF Engineer","Head of Security","MTF Chemist","MTF Left","Kelen","Matilda","Speedwone","Lomao","Feelon","Georg","Shieldmeh","Ruprecht","Hedwig"},class) then return end
	if table.HasValue(BREACH.DonatorLim,ply:SteamID64()) then ply:RXSENDNotify("Превышен лимит установки роли") return end
    
    
    
    
    local cl, gr
    for i, tbl in pairs( BREACH_ROLES ) do
        if i == "NAZI" then continue end
        for _, group in pairs( tbl ) do
            gr = group.name
            for k, clas in pairs( group.roles ) do
                if clas.name == class or clas.name == class then
                    cl = clas
                end
                if cl then break end
            end
            if cl then break end
        end
    end
    if cl and gr then
        
       
			print("Сет профы")
			print(class)
			print(pos_table[class])
            local pos = table.Copy(pos_table[class])
			print(pos)
            ply:SetupNormal()
            ply:ApplyRoleStats( cl, true )
            ply:SetPos(table.remove( pos, math.random( #pos ) ))
           
			table.insert(BREACH.DonatorLim,ply:SteamID64())
       
    end
    end

    local forcespawn_vip = ulx.command( "Breach Admin", "ulx donator_force_spawn", ulx.forcespawn_vip, "!forcespawn_vip" )
    
    forcespawn_vip:addParam{ type = ULib.cmds.StringArg, hint = "class name", completes = {"Class-D FartInhaler","Class-D Killer","Class-D Stealthy","Class-D Pron","Researcher","Ethics Comitee","Head of Personnel","Security Officer","Security Warden","Security Shock trooper","Security Chief","MTF Engineer","Head of Security","MTF Chemist","MTF Left","Kelen","Matilda","Speedwone","Lomao","Feelon","Georg","Shieldmeh","Ruprecht","Hedwig"}, ULib.cmds.takeRestOfLine }
    forcespawn_vip:defaultAccess( ULib.ACCESS_SUPERADMIN )
    forcespawn_vip:help( "Sets player(s) to specific class and spawns him" )

local completes2 = {}
local function FORCESPAWN_BUTWORKING2()
	for i, v in pairs(BREACH_ROLES) do
	if i == "SCP" or i == "OTHER" or i == "OBR" or i == "NTF" or i == "ALPHA1" or i == "AR" or i == "OSN" or i == "CHAOS" or i == "GRU" or i == "GOC" or i == "DZ" or i == "FBI" or i == "COTSK" or i == "MINIGAMES" then continue end
	for _, group in pairs(v) do
		for _, role in pairs(group.roles) do
			if role.name != "O5-4: 'Ambassador'" and role.name != "UIU Spy" then
				table.insert(completes2, role.name)
			end
		end
	end
	end
end

local function FORCESPAWN_SETPOS(ply)
	if ply:GTeam() == TEAM_CLASSD then
		ply:SetPos(table.Random(SPAWN_CLASSD))
	elseif ply:GTeam() == TEAM_SCI then
		ply:SetPos(table.Random(SPAWN_SCIENT))
	elseif ply:GTeam() == TEAM_SECURITY then
		ply:SetPos(table.Random(SPAWN_SECURITY))
	elseif ply:GTeam() == TEAM_SPECIAL then
		ply:SetPos(table.Random(SPAWN_SCIENT))
	elseif ply:GTeam() == TEAM_GUARD then
		ply:SetPos(table.Random(SPAWN_GUARD))
	elseif ply:GTeam() == TEAM_GOC then
		ply:SetPos(table.Random(SPAWN_CLASSD))
	elseif ply:GTeam() == TEAM_DZ then
		ply:SetPos(table.Random(SPAWN_SCIENT))
	elseif ply:GTeam() == TEAM_CHAOS then
		ply:SetPos(table.Random(SPAWN_SECURITY))
	end
end

	table.sort(completes2)

	function ulx.forcespawn_mega( ply, class )
	 	if !class then return end
		if GetGlobalBool("EventRound") then return end
		if ply:SteamID64() != "76561198376629308" then ply:RXSENDNotify("У вас нет доступа к этой команде") return end
		
		local cl
        for i, tbl in pairs( BREACH_ROLES ) do
            for _, group in pairs( tbl ) do
                for k, clas in pairs( group.roles ) do
                    if clas.name == class or clas.name == class then
                        cl = clas
                    end
                    if cl then break end
                end
                if cl then break end
            end
        end
        if cl then
            
            local pos = ply:GetPos()
            ply:SetupNormal()
            ply:ApplyRoleStats( cl, true )
            
			timer.Simple( 0.2, function()
				FORCESPAWN_SETPOS(ply)
			end)
			
        end
    end
    local forcespawn_mega = ulx.command( "Breach Admin", "ulx mega_force_spawn", ulx.forcespawn_mega, "!forcespawn_mega" )
    
    forcespawn_mega:addParam{ type = ULib.cmds.StringArg, hint = "class name", completes = completes2, ULib.cmds.takeRestOfLine }
    forcespawn_mega:defaultAccess( ULib.ACCESS_SUPERADMIN )
    forcespawn_mega:help( "Спец команда для главных спонсоров проекта" )

function ulx.arena(ply, plys, class) end
local arena = ulx.command( "Breach", "ulx arena", ulx.arena, "!arena" )
arena:defaultAccess( ULib.ACCESS_ALL )
arena:help( "Enter/Exit arena" )

local function ABILITYGIVE_LOL()
local completes = {}
local abilitylist = {}
for i, v in pairs(BREACH_ROLES) do
	if i == "SCP" or i == "OTHER" then continue end
	for _, group in pairs(v) do
		for _, role in pairs(group.roles) do
			if role["ability"] then
				table.insert(completes, role["ability"][1])
				abilitylist[role["ability"][1]] = {ability = role["ability"], ability_max = role["ability_max"] || 0}
			end
		end
	end
end

	function ulx.giveability( ply, plys, ability )
		local role

		for i, v in pairs(abilitylist) do
			if string.lower(i) != string.lower(ability) then continue end
			role = v
		end

		if !role then ply:RXSENDNotify("l:ulx_ability_not_found_pt1 "..ability.." l:ulx_ability_not_found_pt2") return end

		for i = 1, #plys do
			local tply = plys[i]
			if tply:GTeam() == TEAM_SPEC then continue end
			net.Start("SpecialSCIHUD")
			    net.WriteString(role["ability"][1])
				net.WriteUInt(role["ability"][2], 9)
				net.WriteString(role["ability"][3])
				net.WriteString(role["ability"][4])
				net.WriteBool(role["ability"][5])
			net.Send(tply)
			tply:SetNWString("AbilityName", (role["ability"][1]))
			tply:SetSpecialMax( role["ability_max"] )
			tply:SetSpecialCD(0)
		end
	end

	local giveability = ulx.command( "Shaky Poopers", "ulx giveability", ulx.giveability, "!giveability" )
	giveability:addParam{ type = ULib.cmds.PlayersArg }
	giveability:addParam{ type = ULib.cmds.StringArg, hint = "ability", completes = completes, ULib.cmds.takeRestOfLine }
	giveability:defaultAccess( ULib.ACCESS_SUPERADMIN )
	giveability:help( "" )
end

function ulx.steamsharing( ply, tply )
	if tply:OwnerSteamID64() == tply:SteamID64() then
		ply:RXSENDNotify("l:ulx_family_sharing_pt1 \""..tply:Name().."\" l:ulx_family_sharing_pt2")
		return
	end

	ply:RXSENDNotify("l:ulx_family_sharing_pt1 \""..tply:Name().."\" l:ulx_family_sharing_pt3 = <\""..tply:OwnerSteamID64().."\".")
end

local steamsharing = ulx.command( "Admin", "ulx steamsharing", ulx.steamsharing, "!steamsharing" )
steamsharing:addParam{ type = ULib.cmds.PlayerArg }
steamsharing:defaultAccess( ULib.ACCESS_ADMIN )
steamsharing:help( "" )

function ulx.getgaginfo( ply, s64 )

	if s64 == "" then s64 = ply:SteamID64() end

	local steamid = util.SteamIDFrom64(s64)

	if !BREACH.Punishment.Gags[steamid] then
		ply:RXSENDNotify("l:ulx_not_gagged")
		return
	end

	local admin = BREACH.Punishment.Gags[steamid].admin
	local reason = BREACH.Punishment.Gags[steamid].reason
	local unmute = BREACH.Punishment.Gags[steamid].unban

	if reason == "" then
		reason = "No reason given"
	end

	local unmutetext = "l:ulx_never"

	if unmute > 0 then
		unmutetext = "l:ulx_after "..string.NiceTime_Full_Rus(unmute - os.time()).."."
	end

	ply:RXSENDNotify("l:ulx_gagged_by \""..admin.."\"")
	ply:RXSENDNotify("l:ulx_gag_reason <\""..reason.."\">")
	ply:RXSENDNotify("l:ulx_gag_expires "..unmutetext)

end

local getgaginfo = ulx.command( "Admin", "ulx getgaginfo", ulx.getgaginfo, "!getgaginfo" )
getgaginfo:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
getgaginfo:defaultAccess( ULib.ACCESS_ADMIN )
getgaginfo:help( "" )

function ulx.getmuteinfo( ply, s64 )

	if s64 == "" then s64 = ply:SteamID64() end

	local steamid = util.SteamIDFrom64(s64)

	if !BREACH.Punishment.Mutes[steamid] then
		ply:RXSENDNotify("l:ulx_not_gagged")
		return
	end

	local admin = BREACH.Punishment.Mutes[steamid].admin
	local reason = BREACH.Punishment.Mutes[steamid].reason
	local unmute = BREACH.Punishment.Mutes[steamid].unban

	if reason == "" then
		reason = "No reason given"
	end

	local unmutetext = "l:ulx_never"

	if unmute > 0 then
		unmutetext = "l:ulx_after "..string.NiceTime_Full_Rus(unmute - os.time()).."."
	end

	ply:RXSENDNotify("l:ulx_muted_by \""..admin.."\"")
	ply:RXSENDNotify("l:ulx_mute_reason <\""..reason.."\">")
	ply:RXSENDNotify("l:ulx_mute_expires "..unmutetext)

end

local getmuteinfo = ulx.command( "Admin", "ulx getmuteinfo", ulx.getmuteinfo, "!getmuteinfo" )
getmuteinfo:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
getmuteinfo:defaultAccess( ULib.ACCESS_ADMIN )
getmuteinfo:help( "" )

function ulx.globalban( ply, tply )
	GlobalBan(tply)
	ply:RXSENDNotify(tply:Name(), " l:ulx_global_banned")

	AdminActionLog(ply, tply, "Global Banned "..tply:Name(), "")
end

local globalban = ulx.command( "Admin", "ulx globalban", ulx.globalban, "!globalban" )
globalban:addParam{ type = ULib.cmds.PlayerArg }
globalban:defaultAccess( ULib.ACCESS_ADMIN )
globalban:help( "" )

function ulx.lastseenuser( ply, tply )
	GetConnectedUsersList(ply, tply)
end

local lastseenuser = ulx.command( "Admin", "ulx lastseenuser", ulx.lastseenuser, "!lastseenuser" )
lastseenuser:addParam{ type = ULib.cmds.PlayerArg }
lastseenuser:defaultAccess( ULib.ACCESS_ADMIN )
lastseenuser:help( "" )

function ulx.unglobalban( ply, steamid64 )
	UnGlobalBan(steamid64)
	ply:RXSENDNotify("l:ulx_global_unbanned "..steamid64)

	AdminActionLog(ply, steamid64, "Removed Global Ban from  "..steamid64, "")
end

local unglobalban = ulx.command( "Admin", "ulx unglobalban", ulx.unglobalban, "!unglobalban" )
unglobalban:addParam{ type = ULib.cmds.StringArg, hint = "SteamID64" }
unglobalban:defaultAccess( ULib.ACCESS_ADMIN )
unglobalban:help( "" )

function ulx.giveexp( admin, ply, amount )

	ply:AddExp(amount)
	admin:RXSENDNotify("Игрок ", Color(255,0,0), "\""..ply:Name().."\"", color_white, " Получил "..amount.." опыта ")
	ply:RXSENDNotify("Вам было даровано: ",Color(255,0,0), amount.." Опыта")

end
local giveexp = ulx.command( "Admin", "ulx giveexp", ulx.giveexp, "!giveexp" )
giveexp:addParam{ type = ULib.cmds.PlayerArg }
giveexp:addParam{ type = ULib.cmds.NumArg, min=0 }
giveexp:defaultAccess( ULib.ACCESS_ADMIN )
giveexp:help( "" )

function ulx.givelevel( admin, ply, amount )

	ply:AddLevel(amount)
	admin:RXSENDNotify("Игрок ", Color(255,0,0), "\""..ply:Name().."\"", color_white, " Получил "..amount.." уровней ")
	ply:RXSENDNotify("Вам было даровано: ",Color(255,0,0), amount.." Уровней")

end

local givelevel = ulx.command( "Admin", "ulx givelevel", ulx.givelevel, "!givelevel" )
givelevel:addParam{ type = ULib.cmds.PlayerArg }
givelevel:addParam{ type = ULib.cmds.NumArg, min=-100 }
givelevel:defaultAccess( ULib.ACCESS_ADMIN )
givelevel:help( "" )


function ulx.givepenaltiid( admin, steamid64, amount )
	
	GivePenalty(steamid64, amount, true)
	
end

local givepenaltiid = ulx.command( "Breach Imperator", "ulx givepenaltiid", ulx.givepenaltiid, "!givepenaltiid" )
givepenaltiid:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
givepenaltiid:addParam{ type = ULib.cmds.NumArg, min=-100 }
givepenaltiid:defaultAccess( ULib.ACCESS_ADMIN )
givepenaltiid:help( "" )

function ulx.getpenaltiid( admin, steamid64, amount )
	
	local ply = player.GetBySteamID64(steamid64)
	
	
	
	admin:RXSENDNotify(util.GetPData(util.SteamIDFrom64(steamid64), "breach_penalty", 0))
	
	
	
	
	
end

local getpenaltiid = ulx.command( "Breach Imperator", "ulx getpenaltiid", ulx.getpenaltiid, "!getpenaltiid" )
getpenaltiid:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
getpenaltiid:defaultAccess( ULib.ACCESS_ADMIN )
getpenaltiid:help( "" )

function ulx.giveprem( admin, steamid64, amount )
	Shaky_SetupPremium(steamid64,amount * 60)
end

local giveprem = ulx.command( "Breach Imperator", "ulx giveprem", ulx.giveprem, "!giveprem" )
giveprem:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
giveprem:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
giveprem:defaultAccess( ULib.ACCESS_ADMIN )
giveprem:help( "" )

function ulx.giverolechange( admin, steamid64, amount )

	SetPremiumSub(steamid64,amount)
	
	admin:RXSENDNotify( ("Вы выдали игроку %s возможность менять роль на %s дней"):format(steamid64, amount) )

end

local giverolechange = ulx.command( "Breach Imperator", "ulx giverolechange", ulx.giverolechange, "!giverolechange" )
giverolechange:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
giverolechange:addParam{ type = ULib.cmds.NumArg, min=-100 }
giverolechange:defaultAccess( ULib.ACCESS_SUPERADMIN )
giverolechange:help( "!!!УКАЖИ КОЛ-ВО ДНЕЙ!!!" )

function ulx.getrolechange( admin, steamid64, amount )
	
	local ply = player.GetBySteamID64(steamid64)
	
	
	
	

	local ExpireDate = tonumber(util.GetPData(util.SteamIDFrom64(steamid64), "premium_sub", 0))

	local str = string.NiceTime_Full_Rus(ExpireDate - os.time())

	if str then
		admin:RXSENDNotify("l:ulx_premium_will_expire_pt1 ", Color(255,255,0,200), "l:ulx_premium_will_expire_pt2", color_white, " l:ulx_premium_will_expire_pt3 ", Color(255,0,0, 200), str)
	end	
	
	
	
	
	
end

local getrolechange = ulx.command( "Breach Imperator", "ulx getrolechange", ulx.getrolechange, "!getrolechange" )
getrolechange:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
getrolechange:defaultAccess( ULib.ACCESS_ADMIN )
getrolechange:help( "" )

function ulx.setlevelid( admin, steamid64, amount )

	local ply = player.GetBySteamID64(steamid64)
	if IsValid(ply) and ply:IsPlayer() then
		ply:SetNLevel(amount)
		ply:RXSENDNotify("l:levels_setted_pt1 "..tostring(amount).."l:levels_setted_pt2")
	end

	BREACH.DataBaseSystem:UpdateData(steamid64, "level", amount, false)

end

local setlevelid = ulx.command( "Breach Imperator", "ulx setlevelid", ulx.setlevelid, "!setlevelid" )
setlevelid:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
setlevelid:addParam{ type = ULib.cmds.NumArg, min=0 }
setlevelid:defaultAccess( ULib.ACCESS_ADMIN )
setlevelid:help( "" )

function ulx.givelevelid( admin, steamid64, amount )

	
	local ply = player.GetBySteamID64(steamid64)
	if IsValid(ply) and ply:IsPlayer() then
		ply:SetNLevel(ply:GetNLevel() + amount)
		ply:RXSENDNotify("l:levels_gifted_pt1 "..tostring(amount).."l:levels_gifted_pt2")
	end

	BREACH.DataBaseSystem:UpdateData(steamid64, "level", amount, true)

end

local givelevelid = ulx.command( "Breach Imperator", "ulx givelevelid", ulx.givelevelid, "!givelevelid" )
givelevelid:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
givelevelid:addParam{ type = ULib.cmds.NumArg, min=-100 }
givelevelid:defaultAccess( ULib.ACCESS_ADMIN )
givelevelid:help( "" )


function ulx.givefreeexpid( admin, steamid64, amount )

	
	local ply = player.GetBySteamID64(steamid64)
	if IsValid(ply) and ply:IsPlayer() then
		--ply:SetNLevel(ply:GetNLevel() + amount)
		ply:SetNWInt("WTh_FreeEXP", tonumber(ply:GetBreachData("free_exp") + amount))
		ply:RXSENDNotify("Вам выдали "..tostring(amount).." ед. свободного опыта")
	end
    --self:SetBreachData("free_exp", tonumber(self:GetBreachData("free_exp") or 0) + extra_data.free_xp)
        --self:SetNWInt("WTh_FreeEXP", tonumber(self:GetBreachData("free_exp")))
	BREACH.DataBaseSystem:UpdateData(steamid64, "free_exp", amount, true)

end

local givefreeexpid = ulx.command( "Breach Imperator", "ulx givefreeexpid", ulx.givefreeexpid, "!givefreeexpid" )
givefreeexpid:addParam{ type = ULib.cmds.StringArg, hint="SteamID64", ULib.cmds.optional }
givefreeexpid:addParam{ type = ULib.cmds.NumArg, min=-100 }
givefreeexpid:defaultAccess( ULib.ACCESS_ADMIN )
givefreeexpid:help( "" )

function ulx.removepenalty( admin, ply )

	SetPenalty(ply:SteamID64(), 0, true)
	admin:RXSENDNotify("Игрок ", Color(255,0,0), "\""..ply:Name().."\"", color_white, " был освобожден от наказания!")

end

local removepenalty = ulx.command( "Breach Imperator", "ulx removepenalty", ulx.removepenalty, "!removepenalty" )
removepenalty:addParam{ type = ULib.cmds.PlayerArg }
removepenalty:defaultAccess( ULib.ACCESS_ADMIN )
removepenalty:help( "" )

function ulx.checkpenalty( me )

	local amount = me:GetPenaltyAmount()

	if amount > 0 then

		me:RXSENDNotify("Количество требуемых побегов: ",Color(255,0,0), amount)

	else

		me:RXSENDNotify("Вы не имеете статус штрафника.")

	end

end

local checkpenalty = ulx.command( "Breach", "ulx checkpenalty", ulx.checkpenalty, "!checkpenalty" )
checkpenalty:defaultAccess( ULib.ACCESS_ALL )
checkpenalty:help( "" )

function ulx.logs( me )

	me:ConCommand("shlogs_openmenu")

end

local logs = ulx.command( "Admin", "ulx logs", ulx.logs, "!logs" )
logs:defaultAccess( ULib.ACCESS_ALL )
logs:help( "Открывает панельку с логами" )

local function SendSpecMessage(ignore, ...)
	local plys = player.GetAll()
	for i = 1, #plys do
		local ply = plys[i]
		if ply:GTeam() != TEAM_SPEC and !ply:IsAdmin() then continue end
		if ply == ignore then continue end
		local msg = {...}
		ply:RXSENDNotify(unpack(msg))
	end
end

local function SendAdminMessage(ignore, ...)
	local plys = player.GetAll()
	for i = 1, #plys do
		local ply = plys[i]
		if !ply:IsAdmin() then continue end
		if ply == ignore then continue end
		local msg = {...}
		ply:RXSENDNotify(unpack(msg))
	end
end

function ulx.mute( call_ply, ply, time, reason )

	time = time * 60

	local mutetext = {" l:ulx_has_been_muted "}
	local timestring = string.NiceTime_Full_Eng(time)

	if reason == nil or reason == "" then
		if time == 0 then
			mutetext = {" l:ulx_has_been_muted_permanently ", Color(255,0,0), call_ply:Name()}
		else
			mutetext = {" l:ulx_has_been_muted_for "..timestring.." l:ulx_has_been_muted_by ", Color(255,0,0), call_ply:Name()}
		end
	else
		if time == 0 then
			mutetext = {" l:ulx_has_been_muted_permanently l:ulx_has_been_muted_by ", Color(255,0,0), call_ply:Name(),color_white,": "..reason}
		else
			mutetext = {" l:ulx_has_been_muted_for "..timestring.." l:ulx_has_been_muted_by ", Color(255,0,0), call_ply:Name(),color_white,": "..reason}
		end
	end

	local datafloat = os.time() + time

	if time == 0 then datafloat = 0 end

	BREACH.Punishment:Mute(ply, call_ply, datafloat, reason)

	SendSpecMessage(ply, "l:ulx_player ", Color(255,0,0), "\""..ply:Name().."\"",Color(255,255,255), unpack(mutetext))
	ply:RXSENDNotify(Color(255,0,0), ply:Name().."l:ulx_you", Color(255,255,255), unpack(mutetext))

	local logtext = "Muted "..ply:Name().." Permanently"
	if time != 0 then
		logtext = "Muted "..ply:Name().." for "..timestring
	end
	local logreason = ""
	if reason != nil and reason != "" then
		logreason = reason
	end
	AdminActionLog(call_ply, ply, logtext, logreason)

end

local mute = ulx.command( "Admin", "ulx mute", ulx.mute, "!mute" )
mute:addParam{ type=ULib.cmds.PlayerArg }
mute:addParam{ type=ULib.cmds.NumArg, hint="in minutes, 0 is Permanent", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
mute:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
mute:defaultAccess( ULib.ACCESS_ADMIN )
mute:help( "" )

function ulx.gag( call_ply, ply, time, reason )

	time = time * 60

	local mutetext = {" l:ulx_has_been_gagged "}
	local timestring = string.NiceTime_Full_Eng(time)

	local adminname = call_ply:Name()

	if call_ply:IsSuperAdmin() then adminname = "SERVER" end

	if reason == nil or reason == "" then
		if time == 0 then
			mutetext = {" l:ulx_has_been_gagged_permanently ", Color(255,0,0), adminname}
		else
			mutetext = {" l:ulx_has_been_gagged_for "..timestring.." l:ulx_has_been_gagged_by ", Color(255,0,0), adminname}
		end
	else
		if time == 0 then
			mutetext = {" l:ulx_has_been_gagged_permanently l:ulx_has_been_gagged_by ", Color(255,0,0), adminname,color_white,": "..reason}
		else
			mutetext = {" l:ulx_has_been_gagged_for "..timestring.." l:ulx_has_been_gagged_by ", Color(255,0,0), adminname,color_white,": "..reason}
		end
	end

	local datafloat = os.time() + time

	if time == 0 then datafloat = 0 end

	BREACH.Punishment:Gag(ply, call_ply, datafloat, reason)

	SendSpecMessage(ply, "l:ulx_player ", Color(255,0,0), "\""..ply:Name().."\"",Color(255,255,255), unpack(mutetext))
	ply:RXSENDNotify(Color(255,0,0), ply:Name().."l:ulx_you", Color(255,255,255), unpack(mutetext))

	local logtext = "Gagged "..ply:Name().." Permanently"
	if time != 0 then
		logtext = "Gagged "..ply:Name().." for "..timestring
	end
	local logreason = ""
	if reason != nil and reason != "" then
		logreason = reason
	end
	AdminActionLog(call_ply, ply, logtext, logreason)

end

local gag = ulx.command( "Admin", "ulx gag", ulx.gag, "!gag" )
gag:addParam{ type=ULib.cmds.PlayerArg }
gag:addParam{ type=ULib.cmds.NumArg, hint="in minutes, 0 is Permanent", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
gag:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
gag:defaultAccess( ULib.ACCESS_ADMIN )
gag:help( "" )

function ulx.forcesupport( call_ply, supname )
	SupportSpawn(true,supname)
end

local forcesupport = ulx.command( "Admin", "ulx forcesupport", ulx.forcesupport, "!forcesupport" )
forcesupport:addParam{ type=ULib.cmds.StringArg, hint="supportname", completes = {"GRU", "COTSK", "FBI", "CHAOS", "NTF", "GOC", "DZ", "AR","CBG","OBR","OSN","Alpha1","FBIAgents"} }
forcesupport:defaultAccess( ULib.ACCESS_SUPERADMIN )
forcesupport:help( "" )

function ulx.forceround( call_ply, roundname )

	

	forceround = roundname
	if forceround == "furry_event" then
		SetGlobalBool("NextFurry", true)
	end

end

local forceround = ulx.command( "Admin", "ulx forceround", ulx.forceround, "!forceround" )
forceround:addParam{ type=ULib.cmds.StringArg, hint="roundname", completes = {"normal","normalevent", "ww2tdm", "hl2tdm","uiugoc","event","ny_event","furry_event"} }
forceround:defaultAccess( ULib.ACCESS_SUPERADMIN )
forceround:help( "" )

function ulx.adminlog( call_ply, type, admin, victim )

	if !admin or admin == "admin" then admin = "" end
	if !victim or victim == "victim" then victim = "" end
	if type == "all" then type = "" end

	if admin:find("STEAM_") then admin = util.SteamIDTo64(admin) end
	if victim:find("STEAM_") then victim = util.SteamIDTo64(victim) end

	request_admin_log(call_ply, type, admin, victim)

end

local adminlog = ulx.command( "Admin", "ulx adminlog", ulx.adminlog, "!adminlog" )
adminlog:addParam{ type=ULib.cmds.StringArg, hint="type", completes = {"gag", "mute", "ungag", "unmute", "ban", "unban", "all"} }
adminlog:addParam{ type=ULib.cmds.StringArg, hint="admin", ULib.cmds.optional }
adminlog:addParam{ type=ULib.cmds.StringArg, hint="victim", ULib.cmds.optional }
adminlog:defaultAccess( ULib.ACCESS_ADMIN )
adminlog:help( "" )

function ulx.prioritysupport( call_ply )

	
	if !call_ply:IsDonator() then return call_ply:RXSENDNotify("Нет иди нахуй") end
	if !call_ply:GetNWBool("prioritysup") or call_ply:GetNWBool("prioritysup") == nil then
		call_ply:RXSENDNotify("Вам выдан приоритет до следующего спавна за поддержку")
		call_ply:SetNWBool("prioritysup",true)
	else
		call_ply:RXSENDNotify("Приоритет был отобран")
		call_ply:SetNWBool("prioritysup",false)
	end
	

end

local prioritysupport = ulx.command( "Admin", "ulx prioritysupport", ulx.prioritysupport, "!prioritysupport" )
prioritysupport:defaultAccess( ULib.ACCESS_SUPERADMIN )
prioritysupport:help( "Дает больше шанс появится за поддержку (После каждого спавна надо включать)" )

function ulx.priorityvoice( call_ply )

	
	if !call_ply:GetNWBool("priorityvoice") or call_ply:GetNWBool("priorityvoice") == nil then
		call_ply:RXSENDNotify("Вам выдано право говорить всем")
		call_ply:SetNWBool("priorityvoice",true)
	else
		call_ply:RXSENDNotify("Все отобрано")
		call_ply:SetNWBool("priorityvoice",false)
	end
	

end

local priorityvoice = ulx.command( "Admin", "ulx priorityvoice", ulx.priorityvoice, "!priorityvoice" )
priorityvoice:defaultAccess( ULib.ACCESS_SUPERADMIN )
priorityvoice:help( "Если включить то вас все будут слышать" )

function ulx.expiredaterole( ply )

	if !ply:HasPremiumSub() then
		ply:RXSENDNotify("У вас нету установки роли")
		return
	end

	local ExpireDate = tonumber(util.GetPData(util.SteamIDFrom64(ply:SteamID64()), "premium_sub", 0))

	local str = string.NiceTime_Full_Rus(ExpireDate - os.time())

	if str then
		ply:RXSENDNotify("Ваша ", Color(255,255,0,200), "Установка роли", color_white, " закончится через ", Color(255,0,0, 200), str)
	end	

end

local expiredaterole = ulx.command( "Premium", "ulx expiredaterole", ulx.expiredaterole, "!expiredaterole" )
expiredaterole:defaultAccess( ULib.ACCESS_ALL )
expiredaterole:help( "" )

function ulx.expiredate( ply )

	if !ply:IsPremium() then
		ply:RXSENDNotify("l:ulx_premium_expired")
		return
	end

	local ExpireDate = tonumber(ply:GetBreachData("premium"))

	local str = string.NiceTime_Full_Rus(ExpireDate - os.time())

	if str then
		ply:RXSENDNotify("l:ulx_premium_will_expire_pt1 ", Color(255,255,0,200), "l:ulx_premium_will_expire_pt2", color_white, " l:ulx_premium_will_expire_pt3 ", Color(255,0,0, 200), str)
	end	

end

local expiredate = ulx.command( "Premium", "ulx expiredate", ulx.expiredate, "!expiredate" )
expiredate:defaultAccess( ULib.ACCESS_ALL )
expiredate:help( "" )

function ulx.expiredate_admin( ply )

	if !ply:IsUserGroup("donate_admin") then
		ply:RXSENDNotify("l:ulx_admin_expired")
		return
	end

	local ExpireDate = tonumber(ply:GetBreachData("adminka"))

	local str = string.NiceTime_Full_Rus(ExpireDate - os.time())

	if str then
		ply:RXSENDNotify("l:ulx_admin_will_expire_pt1 ", Color(0,255,255,200), "l:ulx_admin_will_expire_pt2", color_white, " l:ulx_admin_will_expire_pt3 ", Color(255,0,0, 200), str)
	end	

end

local expiredate_admin = ulx.command( "Admin", "ulx expiredate_admin", ulx.expiredate_admin, "!expiredate_admin" )
expiredate_admin:defaultAccess( ULib.ACCESS_ALL )
expiredate_admin:help( "" )

function ulx.muteid(call_ply, steamid64, time, reason)

	time = time * 60

	local steamid = util.SteamIDFrom64(steamid64)

	local remembername = GetPlayerName(steamid)

	if remembername then
		call_ply:RXSENDNotify("l:ulx_player "..remebername.." ("..steamid64..") l:ulx_has_been_successfully_muted")
	else
		call_ply:RXSENDNotify("l:ulx_player "..steamid64.." l:ulx_has_been_successfully_muted")
	end

	local datafloat = 0

	if time != 0 then
		datafloat = os.time() + time
	end

	BREACH.Punishment:Mute(steamid, call_ply, datafloat, reason)

	local timestring = string.NiceTime(time)

	if remembername then
		remembername = steamid64.." ("..remembername..")"
	else
		remembername = steamid64
	end

	local logtext = "Muted "..remembername.." Permanently"
	if time != 0 then
		logtext = "Muted "..remembername.." for "..timestring
	end
	local logreason = ""
	if reason != nil and reason != "" then
		logreason = reason
	end
	AdminActionLog(call_ply, steamid64, logtext, logreason)

end

local muteid = ulx.command( "Admin", "ulx muteid", ulx.muteid, "!muteid" )
muteid:addParam{ type=ULib.cmds.StringArg, hint="SteamID64" }
muteid:addParam{ type=ULib.cmds.NumArg, hint="in minutes, 0 is Permanent", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
muteid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
muteid:defaultAccess( ULib.ACCESS_ADMIN )
muteid:help( "" )

if SERVER then
	util.AddNetworkString("FUNNY_PIC_NET")
else
	net.Receive("FUNNY_PIC_NET", function()
	
		local emg = net.ReadString()

		local img = vgui.Create("DImage")
		img:SetSize(ScrW(), ScrH())

		local mat = LOUNGE_CHAT.GetDownloadedImage(emg)
			if (mat) then
				img.m_Image = mat
				
				
			else
		LOUNGE_CHAT.DownloadImage(
			emg,
				function(mat)
					if (IsValid(img)) then
						img.m_Image = mat
						
						
					end
				end
			)
        end

		img.Paint = function(self, w, h)
			if self.m_Image then
				if !self.disappear then
					self.disappear = true
					self:AlphaTo(0, 5, 0, function() self:Remove() end)
				end
				surface.SetDrawColor(255,255,255)
				surface.SetMaterial(self.m_Image)
				surface.DrawTexturedRect(0,0,w,h)
			end
		end

		timer.Simple(10, function() img:Remove() end)

	end)
end

function ulx.funnypic(call_ply, plys, img)

	
	net.Start("FUNNY_PIC_NET")
	net.WriteString(img)
	net.Send(plys)

end

local funnypic = ulx.command( "Shaky Poopers", "ulx funnypic", ulx.funnypic, "!funnypic" )
funnypic:addParam{ type=ULib.cmds.PlayersArg }
funnypic:addParam{ type=ULib.cmds.StringArg, hint="Image url (MUST BE IMGUR)" }
funnypic:defaultAccess( ULib.ACCESS_SUPERADMIN )
funnypic:help( "" )

function ulx.gagid(call_ply, steamid64, time, reason)

	time = time * 60

	local steamid = util.SteamIDFrom64(steamid64)

	local remembername = GetPlayerName(steamid)

	if remembername then
		call_ply:RXSENDNotify("l:ulx_player "..remebername.." ("..steamid64..") l:ulx_has_been_successfully_gagged")
	else
		call_ply:RXSENDNotify("l:ulx_player "..steamid64.." l:ulx_has_been_successfully_gagged")
	end

	local datafloat = 0

	if time != 0 then
		datafloat = os.time() + time
	end

	BREACH.Punishment:Gag(steamid, call_ply, datafloat, reason)

	local timestring = string.NiceTime(time)

	if remembername then
		remembername = steamid64.." ("..remembername..")"
	else
		remembername = steamid64
	end

	local logtext = "Gagged "..remembername.." Permanently"
	if time != 0 then
		logtext = "Gagged "..remembername.." for "..timestring
	end
	local logreason = ""
	if reason != nil and reason != "" then
		logreason = reason
	end
	AdminActionLog(call_ply, steamid64, logtext, logreason)

end

local gagid = ulx.command( "Admin", "ulx gagid", ulx.gagid, "!gagid" )
gagid:addParam{ type=ULib.cmds.StringArg, hint="SteamID64" }
gagid:addParam{ type=ULib.cmds.NumArg, hint="in minutes, 0 is Permanent", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
gagid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
gagid:defaultAccess( ULib.ACCESS_ADMIN )
gagid:help( "" )

function ulx.unmute(call_ply, ply)

	local adminname = "SERVER"

	if IsValid(call_ply) then
		adminname = call_ply:Name()
	end
	
	ply:RXSENDNotify("l:ulx_admin \""..adminname.."\" l:ulx_they_removed_mute_from_you")
	if IsValid(call_ply) then call_ply:RXSENDNotify("l:ulx_player \""..ply:Name().."\" l:ulx_has_been_sucessfully_unmuted") end

	BREACH.Punishment:UnMute(ply, call_ply, nil)

	local logtext = "Unmuted "..ply:Name()
	local logreason = ""
	AdminActionLog(call_ply, ply, logtext, logreason)

end

local unmute = ulx.command( "Admin", "ulx unmute", ulx.unmute, "!unmute" )
unmute:addParam{ type=ULib.cmds.PlayerArg }
unmute:defaultAccess( ULib.ACCESS_ADMIN )
unmute:help( "" )

function ulx.ungag(call_ply, ply)

	local adminname = "SERVER"

	if IsValid(call_ply) then
		adminname = call_ply:Name()
	end
	
	ply:RXSENDNotify("l:ulx_admin \""..adminname.."\" l:ulx_they_removed_gag_from_you")
	if IsValid(call_ply) then call_ply:RXSENDNotify("l:ulx_player \""..ply:Name().."\" l:ulx_has_been_sucessfully_ungagged") end

	BREACH.Punishment:UnGag(ply, call_ply, nil)

	local logtext = "Ungagged "..ply:Name()
	local logreason = ""
	AdminActionLog(call_ply, ply, logtext, logreason)

end

local ungag = ulx.command( "Admin", "ulx ungag", ulx.ungag, "!ungag" )
ungag:addParam{ type=ULib.cmds.PlayerArg }
ungag:defaultAccess( ULib.ACCESS_ADMIN )
ungag:help( "" )

function ulx.unmuteid(call_ply, steamid64)

	local steamid = util.SteamIDFrom64(steamid64)
	
	local remembername = GetPlayerName(steamid)

	BREACH.Punishment:UnMute(steamid, call_ply, nil)

	if IsValid(call_ply) then
		if remembername then
			call_ply:RXSENDNotify("l:ulx_player ", steamid64," ("..remembername..") l:ulx_has_been_sucessfully_unmuted")
		else
			call_ply:RXSENDNotify("l:ulx_player "..steamid64.." l:ulx_has_been_sucessfully_unmuted")
		end
	end

	local logtext = "Unmuted "..steamid64
	if remembername then
		logtext = "Unmuted "..steamid64.." ("..remembername..")"
	end
	AdminActionLog(call_ply, steamid64, logtext, "")

end

local unmuteid = ulx.command( "Admin", "ulx unmuteid", ulx.unmuteid, "!unmuteid" )
unmuteid:addParam{ type=ULib.cmds.StringArg, hint="SteamID64" }
unmuteid:defaultAccess( ULib.ACCESS_ADMIN )
unmuteid:help( "" )

function ulx.ungagid(call_ply, steamid64)

	local steamid = util.SteamIDFrom64(steamid64)
	
	local remembername = GetPlayerName(steamid)

	if remembername then
		call_ply:RXSENDNotify("l:ulx_player ", steamid64," ("..remembername..") l:ulx_has_been_sucessfully_ungagged")
	else
		call_ply:RXSENDNotify("l:ulx_player "..steamid64.." l:ulx_has_been_sucessfully_ungagged")
	end

	BREACH.Punishment:UnGag(steamid, call_ply, nil)

	local logtext = "Ungagged "..steamid64
	if remembername then
		logtext = "Ungagged "..steamid64.." ("..remembername..")"
	end
	AdminActionLog(call_ply, steamid64, logtext, "")

end

local ungagid = ulx.command( "Admin", "ulx ungagid", ulx.ungagid, "!ungagid" )
ungagid:addParam{ type=ULib.cmds.StringArg, hint="SteamID64" }
ungagid:defaultAccess( ULib.ACCESS_ADMIN )
ungagid:help( "" )

if SERVER then
	util.AddNetworkString("change_ignore_state")
else
	net.Receive("change_ignore_state", function()
		local ply = net.ReadEntity()
		local client = LocalPlayer()
		local name = ply:Name()
		if client:GTeam() != TEAM_SPEC and ply:GTeam() != TEAM_SPEC then
			
			
		end
		if ply:IsMuted() then
			chat.AddText(Color(0, 255, 0), "[ZCity Breach] ", Color(255, 255, 255), BREACH.TranslateString("l:ulx_unignore ")..name)
		else
			if client:GTeam() != TEAM_SPEC then
				if !(client:GTeam() == TEAM_SCP and ply:GTeam() == TEAM_SCP) then
					chat.AddText(Color(0, 255, 0), "[ZCity Breach] ", Color(255, 255, 255), BREACH.TranslateString("l:clientside_mute_spec_only"))
					return
				end
			end
			chat.AddText(Color(0, 255, 0), "[ZCity Breach] ", Color(255, 255, 255), BREACH.TranslateString("l:ulx_ignore ")..name)
		end
		ply:SetMuted(!ply:IsMuted())
	end)

end

function ulx.ignore(call_ply, send_ply)

	net.Start("change_ignore_state")
	net.WriteEntity(send_ply)
	net.Send(call_ply)

end

local ignore = ulx.command( "Admin", "ulx ignore", ulx.ignore, "!ignore" )
ignore:addParam{ type=ULib.cmds.PlayerArg }
ignore:defaultAccess( ULib.ACCESS_ALL )
ignore:help( "" )

if SERVER then

	local nextthink = 0

	hook.Add("Think", "RXSEND_MuteThink", function()

		if CurTime() < nextthink then return end

		nextthink = CurTime() + 1

		local plys = player.GetAll()

		for i = 1, #plys do

			local ply = plys[i]

			if BREACH.Punishment.Mutes[ply:SteamID()] then

				local mutetime = BREACH.Punishment.Mutes[ply:SteamID()].unban

				if mutetime != 0 then

					if mutetime <= os.time() then

						ply:RXSENDNotify("l:ulx_your_mute_expired")

						SendAdminMessage(nil, "Player ".."\""..ply:Name().."\" has been unmuted: Punishment time is over.")

						BREACH.Punishment:UnMute(ply, "AUTOMATIC", "Punishment time is over.")

					end


				end

			end

			if BREACH.Punishment.Gags[ply:SteamID()] then

				local gagtime = BREACH.Punishment.Gags[ply:SteamID()].unban

				if gagtime != 0 then

					if gagtime <= os.time() then

						ply:RXSENDNotify("l:ulx_your_gag_expired")

						SendAdminMessage(nil, "Player ".."\""..ply:Name().."\" has been ungagged: Punishment time is over.")

						BREACH.Punishment:UnGag(ply, "AUTOMATIC", "Punishment time is over.")

					end


				end

			end

		end

	end)

end

function SetupForceSCP()
	if !ulx or !ULib then 
		print( "ULX or ULib not found" )
		return
	end
	
	function ulx.forcescp( plyc, plyt, scp, silent )
		if !scp then return end
		
			
				
		local scp_obj = GetSCP( scp )
		if scp_obj then
			plyt:SetupNormal()
			scp_obj:SetupPlayer( plyt )

			if silent then
				ulx.fancyLogAdmin( plyc, true, "#A force spawned #T as "..scp, plyt )
			else
				ulx.fancyLogAdmin( plyc, "#A force spawned #T as "..scp, plyt )
			end
				
			
		else
			ULib.tsayError( plyc, "Invalid SCP "..scp.."!", true )
		end
	end

	local forcescp = ulx.command( "Breach Admin", "ulx force_scp", ulx.forcescp, "!forcescp" )
	forcescp:addParam{ type = ULib.cmds.PlayerArg }
	forcescp:addParam{ type = ULib.cmds.StringArg, hint = "SCP name", completes = SCPS, ULib.cmds.takeRestOfLine }
	forcescp:addParam{ type = ULib.cmds.BoolArg, invisible = true }
	forcescp:setOpposite( "ulx silent force_scp", { _, _, _, true }, "!sforcescp" )
	forcescp:defaultAccess( ULib.ACCESS_SUPERADMIN )
	forcescp:help( "Sets player to specific SCP and spawns him" )
end

InitializeBreachULX()
SetupForceSCP()
FORCESPAWN_BUTWORKING()
FORCESPAWN_BUTWORKING2()
ABILITYGIVE_LOL()