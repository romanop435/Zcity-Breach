
CreateConVar( "awarn_kick", "1", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "Allow AWarn to kick players who reach the kick threshold. 1=Enabled 0=Disabled" )
CreateConVar( "awarn_ban", "1", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "Allow AWarn to ban players who reach the ban threshold. 1=Enabled 0=Disabled" )
CreateConVar( "awarn_decay", "1", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "If enabled, active warning acount will decay over time. 1=Enabled 0=Disabled" )
CreateConVar( "awarn_reasonrequired", "1", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "If enabled, admins must supply a reason when warning someone. 1=Enabled 0=Disabled" )
CreateConVar( "awarn_decay_rate", "30", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "Time (in minutes) a player needs to play for an active warning to decay." )
CreateConVar( "awarn_reset_warnings_after_ban", "0", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "If enabled, active warning count is cleared after a player is banned by awarn. 1=Enabled 0=Disabled" )
CreateConVar( "awarn_logging", "0", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "If enabled, AWarn will log actions to a data file. 1=Enabled 0=Disabled" )
CreateConVar( "awarn_allow_warnadmin", "1", bit.bxor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED ), "Disable to disallow the warning of other admins. 1=Enabled 0=Disabled" )


AWarn = AWarn or {}
AWarn.Version = "4.1"

local PlayerMeta = FindMetaTable("Player")

function awarn_checkadmin_view(ply)
    return not IsValid(ply) or ply:IsAdmin() or ply:IsSuperAdmin()
end

function awarn_checkadmin_warn(ply)
    return not IsValid(ply) or ply:IsAdmin() or ply:IsSuperAdmin()
end

function awarn_checkadmin_remove(ply)
    return not IsValid(ply) or ply:IsAdmin() or ply:IsSuperAdmin()
end

function awarn_checkadmin_delete(ply)
    return not IsValid(ply) or ply:IsSuperAdmin()
end

function awarn_checkadmin_options(ply)
    return not IsValid(ply) or ply:IsSuperAdmin()
end

function awarn_getUser( target )
	if not target then return false end

	local players = player.GetAll()
	target = target:lower()

	local plyMatch

	-- First, do a full name match in case someone's trying to exploit our target system
	for _, player in ipairs( players ) do
		if target == player:Nick():lower() then
			if not plyMatch then
				return player
			else
				return false
			end
		end
	end

	for _, player in ipairs( players ) do
		local nameMatch
		if player:Nick():lower():find( target, 1, true ) then -- No patterns
			nameMatch = player
		end

		if plyMatch and nameMatch then -- Already have one
			return false
		end
		if nameMatch then
			plyMatch = nameMatch
		end
	end

	if not plyMatch then
		return false
	end

	return plyMatch
end

---------------------------------END OF CREDITED CODE------------------------------------------

function AWarn_ConvertSteamID( id )
	id = string.upper(string.Trim( id ))
	if string.sub( id, 1, 6 ) == 'STEAM_' then
		local parts = string.Explode( ':', string.sub(id,7) )
		local id_64 = (1197960265728 + tonumber(parts[2])) + (tonumber(parts[3]) * 2)
		local str = string.format('%f',id_64)
		return '7656'..string.sub( str, 1, string.find(str,'.',1,true)-1 )
	else
		if tonumber( id ) ~= nil then
		  local id_64 = tonumber( id:sub(2) )
		  local a = id_64 % 2 == 0 and 0 or  1
		  local b = math.abs(6561197960265728 - id_64 - a) / 2
		  local sid = "STEAM_0:" .. a .. ":" .. (a == 1 and b -1 or b)
		  return sid
		end
	end
end