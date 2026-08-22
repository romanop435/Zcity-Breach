AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end

function ENT:Use(a,c)
    
    
end

