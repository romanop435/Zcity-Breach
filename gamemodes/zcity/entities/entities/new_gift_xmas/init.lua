AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")



function ENT:Initialize()
    local modeltablec = {
    "models/gift/christmas_gift.mdl",
    "models/gift/christmas_gift_2.mdl", 
    "models/gift/christmas_gift_3.mdl",
    }
    self:SetModel(table.Random(modeltablec))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end


function ENT:Use(a,c)
    if a:GTeam() != TEAM_SPEC then
        a:BrProgressBar("l:progress_wait", 30, "nextoren/gui/new_icons/eat_gift.png", self, false, function()
            open_imperator_gift(a)
            ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
            BREACH.SendClientEvent(nil, "particle_world", {effect = "gas_explosion_main", pos = self:GetPos()})
            self:Remove()
        end)
    end
end

