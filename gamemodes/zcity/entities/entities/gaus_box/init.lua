AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/noundation/detail/crate_02.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    BREACH.ALPHA1GC = 0
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end


function ENT:Use(a,c)
    if a:GTeam() == TEAM_ALPHA1 then
        BREACH.ALPHA1GC = BREACH.ALPHA1GC + 1
        a:RXSENDNotify(L"l:gaus_box_pickup " .. 3 - BREACH.ALPHA1GC )
        if BREACH.ALPHA1GC >= 3 then
            a:RXSENDNotify(L"l:gaus_box_end")
            a:BreachGive("weapon_special_gaus")
        end
        self:Remove()
    end
end

