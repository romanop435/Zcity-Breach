local tonumber = tonumber
local tostring = tostring
local CurTime = CurTime
local timer = timer
local ErrorNoHalt = ErrorNoHalt
local util = util
local player = player


local sql = sql
local string = string

BREACH = BREACH or {}
BREACH.Punishment = BREACH.Punishment or {}

BREACH.Punishment.Type_MUTE = 1
BREACH.Punishment.Type_GAG = 2
BREACH.Punishment.Type_BAN = 3
BREACH.Punishment.Type_PENALTY = 4
BREACH.Punishment.Type_GIVE = 4

BREACH.Punishment.Bans = BREACH.Punishment.Bans or {}
BREACH.Punishment.Gags = BREACH.Punishment.Gags or {}
BREACH.Punishment.Mutes = BREACH.Punishment.Mutes or {}
BREACH.Punishment.Penalties = BREACH.Punishment.Penalties or {}

local f = string.format

local function query(text)
	local q = BREACH.Punishment.databaseObject:query(text)
	q:start()
end

local function onConnected()
	query("CREATE TABLE IF NOT EXISTS ban_data (user TEXT, admin TEXT, reason TEXT, unban INT UNSIGNED)")
	query("CREATE TABLE IF NOT EXISTS ban_chat_data (user TEXT, type SMALLINT, admin TEXT, reason TEXT, unban INT UNSIGNED)")
	query("CREATE TABLE IF NOT EXISTS penalty_data (user TEXT, admin TEXT, reason TEXT, amount INT UNSIGNED)")

	BREACH.Punishment:LoadBans()
	BREACH.Punishment:LoadTalkMutes()
end

function PunishmentDataBaseSystemConnect()
	BREACH.Punishment.databaseObject = {}
	function BREACH.Punishment.databaseObject:query(sqlStr)
		local qObj = {}
		function qObj:start()
			if not newMysql or not newMysql.query then
				timer.Simple(1, function() self:start() end)
				return
			end
			
			newMysql.query(sqlStr, function(data)
				if self.onSuccess then self.onSuccess(nil, data) end
			end, function(err)
				if self.onError then 
					self.onError(nil, err) 
				else 
					ErrorNoHalt("[PunishmentDB] " .. tostring(err) .. "\n") 
				end
			end)
		end
		return qObj
	end

	timer.Simple(1, function()
		onConnected()
	end)
end

function BREACH.Punishment:Connect()
	PunishmentDataBaseSystemConnect()
end

function BREACH.Punishment:Initialize()
	self:Connect()
end

function BREACH.Punishment:LogAction(user, admin, reason, unban_successful, unban_notfound)
	self:Unban(user, admin, reason)
end

function BREACH.Punishment:LoadBans()
	local query_getbans = self.databaseObject:query("SELECT * FROM ban_data")
	query_getbans.onSuccess = function(_, bans)
		for _, ban in ipairs(bans or {}) do
			BREACH.Punishment.Bans[ban.user] = {
				admin = ban.admin,
				unban = ban.unban,
				reason = ban.reason,
				steamID = ban.user,
			}
		end
	end
	query_getbans:start()
end

function BREACH.Punishment:LoadTalkMutes()
	local query_get = self.databaseObject:query("SELECT * FROM ban_chat_data")
	query_get.onSuccess = function(_, bans)
		for _, ban in ipairs(bans or {}) do
			local targetTable = (tonumber(ban.type) == BREACH.Punishment.Type_GAG) and BREACH.Punishment.Gags or BREACH.Punishment.Mutes
			targetTable[ban.user] = {
				admin = ban.admin,
				unban = ban.unban,
				reason = ban.reason,
				steamID = ban.user,
			}
		end
	end
	query_get:start()
end

function BREACH.Punishment:Ban(user, admin, unban, reason)
	if not user then return end
	if IsValid(user) and user:IsPlayer() and (user:IsBot() or user:IsUserGroup("spectator") or user:IsSuperAdmin()) then return end 

	reason = reason or "No reason given."
	admin = admin or "CONSOLE"
	unban = unban or 0

	local saveply

	if type(user) ~= "string" and IsValid(user) and user:IsPlayer() then
		saveply = user
		user = user:SteamID()
	elseif type(user) == "string" then
		saveply = player.GetBySteamID(user)
	end

	if type(admin) ~= "string" and IsValid(admin) and admin:IsPlayer() then
		admin = admin:SteamID()
	end

	BREACH.Punishment.Bans[user] = {
		admin = tostring(admin),
		unban = unban,
		reason = tostring(reason),
		steamID = tostring(user),
	}

	local safe_user = sql.SQLStr(user)
	local safe_reason = sql.SQLStr(reason)
	local safe_admin = sql.SQLStr(admin)
	local safe_unban = sql.SQLStr(unban, true)

	local query_checkban = self.databaseObject:query(f("SELECT * FROM ban_data WHERE user = %s LIMIT 1", safe_user))
	query_checkban.onSuccess = function(_, isban)
		local q
		if isban and #isban > 0 then
			q = BREACH.Punishment.databaseObject:query(f("UPDATE ban_data SET unban = %s, admin = %s, reason = %s WHERE user = %s", safe_unban, safe_admin, safe_reason, safe_user))
		else
			q = BREACH.Punishment.databaseObject:query(f("INSERT INTO ban_data VALUES(%s, %s, %s, %s)", safe_user, safe_admin, safe_reason, safe_unban))
		end

		q.onSuccess = function()
			if IsValid(saveply) then
				saveply:Kick("You are banned, reconnect to see the reason")
			end
		end
		q:start()
	end
	query_checkban:start()
end

function BREACH.Punishment:BanTalk(user, admin, unban, reason, punish_type)
	if not user then return end
	if IsValid(user) and user:IsPlayer() and user:IsBot() then return end 

	reason = reason or "No reason given."
	admin = admin or "CONSOLE"
	unban = unban or 0

	if type(user) ~= "string" and IsValid(user) and user:IsPlayer() then
		user = user:SteamID()
	end

	if type(admin) ~= "string" and IsValid(admin) and admin:IsPlayer() then
		admin = admin:SteamID()
	end

	if string.StartWith(user, "7656") then 
		user = util.SteamIDFrom64(user) 
	end

	local targetTable = (punish_type == BREACH.Punishment.Type_GAG) and BREACH.Punishment.Gags or BREACH.Punishment.Mutes
	targetTable[user] = {
		admin = tostring(admin),
		unban = unban,
		reason = tostring(reason),
		steamID = tostring(user),
	}

	local safe_user = sql.SQLStr(user)
	local safe_reason = sql.SQLStr(reason)
	local safe_admin = sql.SQLStr(admin)
	local safe_unban = sql.SQLStr(unban, true)
	local safe_type = sql.SQLStr(punish_type, true)

	local query_checkban = self.databaseObject:query(f("SELECT * FROM ban_chat_data WHERE user = %s AND type = %s LIMIT 1", safe_user, safe_type))
	query_checkban.onSuccess = function(_, isban)
		local q
		if isban and #isban > 0 then
			q = BREACH.Punishment.databaseObject:query(f("UPDATE ban_chat_data SET unban = %s, admin = %s, reason = %s WHERE user = %s AND type = %s", safe_unban, safe_admin, safe_reason, safe_user, safe_type))
		else
			q = BREACH.Punishment.databaseObject:query(f("INSERT INTO ban_chat_data VALUES(%s, %s, %s, %s, %s)", safe_user, safe_type, safe_admin, safe_reason, safe_unban))
		end
		q:start()
	end
	query_checkban:start()
end

function BREACH.Punishment:Gag(user, admin, unban, reason)
	self:BanTalk(user, admin, unban, reason, self.Type_GAG)
end

function BREACH.Punishment:Mute(user, admin, unban, reason)
	self:BanTalk(user, admin, unban, reason, self.Type_MUTE)
end

function BREACH.Punishment:Unban(user, admin, reason)
	if not user then return end

	reason = reason or "No reason given."
	local plyadmin

	if type(user) == "string" and not string.StartWith(user, "STEAM") then
		user = util.SteamIDFrom64(user)
	end

	if admin and type(admin) ~= "string" and IsValid(admin) and admin:IsPlayer() then
		plyadmin = admin
		admin = admin:SteamID()
	else
		admin = admin or "CONSOLE"
	end

	BREACH.Punishment.Bans[user] = nil

	local notifyname = "ban_process_" .. tostring(CurTime())
	timer.Create(notifyname, 0.1, 1, function()
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Начат процесс снятия блокировки, подождите...")
		end
	end)

	local safe_user = sql.SQLStr(user)
	
	local unban_query = self.databaseObject:query(f("DELETE FROM ban_data WHERE user = %s", safe_user))
	unban_query.onSuccess = function()
		timer.Remove(notifyname)
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Блокировка была успешно снята с игрока!")
		end
	end
	unban_query:start()
end

function BREACH.Punishment:UnbanTalk(user, admin, reason, punish_type)
	if not user then return end
	reason = reason or "No reason given."

	if type(user) ~= "string" and IsValid(user) and user:IsPlayer() then
		user = user:SteamID()
	end

	if type(user) == "string" and not string.StartWith(user, "STEAM") then
		user = util.SteamIDFrom64(user)
	end

	local plyadmin
	if admin and type(admin) ~= "string" and IsValid(admin) and admin:IsPlayer() then
		plyadmin = admin
		admin = admin:SteamID()
	else
		admin = admin or "CONSOLE"
	end

	if punish_type == self.Type_GAG then
		self.Gags[user] = nil
	else
		self.Mutes[user] = nil
	end

	local notifyname = "ban_process_" .. tostring(punish_type) .. "_" .. tostring(CurTime())
	timer.Create(notifyname, 0.1, 1, function()
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Начат процесс снятия блокировки, подождите...")
		end
	end)

	local safe_user = sql.SQLStr(user)
	local safe_type = sql.SQLStr(punish_type, true)

	local unban_query = self.databaseObject:query(f("DELETE FROM ban_chat_data WHERE user = %s AND type = %s", safe_user, safe_type))
	unban_query.onSuccess = function()
		timer.Remove(notifyname)
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Блокировка была успешно снята с игрока!")
		end
	end
	unban_query:start()
end

function BREACH.Punishment:UnGag(user, admin, reason)
	self:UnbanTalk(user, admin, reason, self.Type_GAG)
end

function BREACH.Punishment:UnMute(user, admin, reason)
	self:UnbanTalk(user, admin, reason, self.Type_MUTE)
end

hook.Add("InitPostEntity", "CreatePunishmentDataTable", function()
	BREACH.Punishment:Initialize()
end)

BREACH.DataList = {}

function util.SteamIDTo32(steamid)
	local acc32 = tonumber(string.sub(steamid, 11))
	return tostring((acc32 * 2) + tonumber(string.sub(steamid, 9, 9)))
end

function util.SteamIDFrom32(steamid32)
	steamid32 = tonumber(steamid32)
	if not steamid32 then return "" end
	local y = steamid32 % 2
	local z = (steamid32 - y) / 2
	return "STEAM_0:" .. y .. ":" .. z
end

function util.SteamID64To32(steamid64)
	return util.SteamIDTo32(util.SteamIDFrom64(steamid64))
end

function util.SteamID64From32(steamid32)
	return util.SteamIDTo64(util.SteamIDFrom32(steamid32))
end
