AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/imperator/ar/box.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    self:SetAngles(Angle(0,180,90))
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end


function ENT:Use(a,c)
    if a:GTeam() == TEAM_AR then
        local pickedplayers = {}
		local pick = 0
		for _, ply in RandomPairs(GetActivePlayers()) do
			if ply:GTeam() != TEAM_SPEC then continue end
			if ply.SpawnAsSupport == false then continue end
			if ply:GetPenaltyAmount() > 0 then continue end
			
			
			pickedplayers[#pickedplayers + 1] = ply
		end
		local ply = table.Random(pickedplayers)
		ply:SetupNormal()
		ply:ApplyRoleStats( BREACH_ROLES.AR.ar.roles[table.Random({1,1,1,1,2,3,3})] )
		
        self:Remove()
		ply:SetPos( self:GetPos() + (self:GetUp() * 71.8) )
    
    
    
    
    
    

    end
end

