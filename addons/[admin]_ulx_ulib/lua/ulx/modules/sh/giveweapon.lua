--[[
addons/ulx_give_weapon/lua/ulx/modules/sh/giveweapon.lua
--]]
local CATEGORY_NAME = "Imperator"





function ulx.giveweapon( calling_ply, target_plys, weapon )

	

	

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		

		if not v:Alive() then

		ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )

		

		else

		v.IsLooting = true
		local wep = v:BreachGive(weapon)
		--if weapon == "weapon_physgun" then
		--	wep.HoldType = "gauss"
		--	wep:SetHoldType("gauss")
		--end
		v.IsLooting = false
		
		table.insert( affected_plys, v )

		end

	end

	ulx.fancyLogAdmin( calling_ply, "#A gave #T weapon #s", affected_plys, weapon )

end

	

	

local giveweapon = ulx.command( CATEGORY_NAME, "ulx giveweapon", ulx.giveweapon, {"!give", "!giveweapon"} )

giveweapon:addParam{ type=ULib.cmds.PlayersArg }

giveweapon:addParam{ type=ULib.cmds.StringArg, hint="weapon name" }

giveweapon:defaultAccess( ULib.ACCESS_ADMIN )

giveweapon:help( "Ага абузер ебанный используй - !giveweapon" )







function ulx.sgiveweapon( calling_ply, target_plys, weapon )

	

	

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		

		if not v:Alive() then

		ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )

		

		else

		v.IsLooting = true
		v:Give(weapon)
		v.IsLooting = false

		table.insert( affected_plys, v )

		end

	end

end

	

	

local sgiveweapon = ulx.command( CATEGORY_NAME, "ulx sgiveweapon", ulx.sgiveweapon )

sgiveweapon:addParam{ type=ULib.cmds.PlayersArg }

sgiveweapon:addParam{ type=ULib.cmds.StringArg, hint="weapon name" }

sgiveweapon:defaultAccess( ULib.ACCESS_ADMIN )

sgiveweapon:help( "Ага абузер ебанный так и знал" )


function ulx.setmodel( calling_ply, target_plys, weapon )

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		if not v:Alive() then

		ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )

		else

		v:SetModel(weapon)
		
		table.insert( affected_plys, v )

		end

	end

	ulx.fancyLogAdmin( calling_ply, "#A set #T model #s", affected_plys, weapon )

end

local setmodel = ulx.command( CATEGORY_NAME, "ulx setmodel", ulx.setmodel, "!setmodel" )

setmodel:addParam{ type=ULib.cmds.PlayersArg }
setmodel:addParam{ type=ULib.cmds.StringArg, hint="Model name" }
setmodel:defaultAccess( ULib.ACCESS_SUPERADMIN )
setmodel:help( "Пиздец блять" )

function ulx.giveach( calling_ply, target_plys, weapon )

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		--if not v:Alive() then
--
		--ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )
--
		--else

		--v:SetModel(weapon)
		v:CompleteAchievement(weapon)
		
		table.insert( affected_plys, v )

		--end

	end

	ulx.fancyLogAdmin( calling_ply, "#A дал ачивку #T - #s", affected_plys, weapon )

end

local giveach = ulx.command( CATEGORY_NAME, "ulx giveach", ulx.giveach, "!giveach" )

giveach:addParam{ type=ULib.cmds.PlayersArg }
giveach:addParam{ type=ULib.cmds.StringArg, hint="Model name" }
giveach:defaultAccess( ULib.ACCESS_SUPERADMIN )
giveach:help( "Пиздец блять" )

function ulx.cleanbm( calling_ply, target_plys )

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		if not v:Alive() then

		ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )

		else

		--v:SetModel(weapon)
		local mini_ply = v
		if ( mini_ply.BoneMergedEnts ) then
        	for _, bnm in pairs( mini_ply.BoneMergedEnts ) do

        	    if ( bnm && bnm:IsValid() ) then
        	        bnm:Remove()
        	    end
        	end
    	end
		
		table.insert( affected_plys, v )

		end

	end

	ulx.fancyLogAdmin( calling_ply, "#A remove bnm #T", affected_plys)

end

local cleanbm = ulx.command( CATEGORY_NAME, "ulx cleanbm", ulx.cleanbm, "!cleanbm" )

cleanbm:addParam{ type=ULib.cmds.PlayersArg }
cleanbm:defaultAccess( ULib.ACCESS_SUPERADMIN )
cleanbm:help( "Пиздец блять" )

function ulx.givebnm( calling_ply, target_plys, weapon )

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		if not v:Alive() then

		ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )

		else

		Bonemerge(weapon, v)
		
		table.insert( affected_plys, v )

		end

	end

	ulx.fancyLogAdmin( calling_ply, "#A give bnm #T model #s", affected_plys, weapon )

end

local givebnm = ulx.command( CATEGORY_NAME, "ulx givebnm", ulx.givebnm, "!givebnm" )

givebnm:addParam{ type=ULib.cmds.PlayersArg }
givebnm:addParam{ type=ULib.cmds.StringArg, hint="Model name" }
givebnm:defaultAccess( ULib.ACCESS_SUPERADMIN )
givebnm:help( "Пиздец блять" )

function ulx.setrpname( calling_ply, target_plys, weapon )

	local affected_plys = {}

	for i=1, #target_plys do

		local v = target_plys[ i ]

		if not v:Alive() then

		ULib.tsayError( calling_ply, v:Nick() .. " ты дебил он мертв", true )

		else

		v:SetNamesurvivor( weapon )
		
		table.insert( affected_plys, v )

		end

	end

	ulx.fancyLogAdmin( calling_ply, "#A set name #T - #s", affected_plys, weapon )

end

local setrpname = ulx.command( CATEGORY_NAME, "ulx setrpname", ulx.setrpname, "!setrpname" )

setrpname:addParam{ type=ULib.cmds.PlayersArg }
setrpname:addParam{ type=ULib.cmds.StringArg, hint="Name" }
setrpname:defaultAccess( ULib.ACCESS_SUPERADMIN )
setrpname:help( "Пиздец блять" )
