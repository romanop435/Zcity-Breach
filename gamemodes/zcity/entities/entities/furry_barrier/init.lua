AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")





function ENT:Initialize()
    self:SetModel("models/imperator/furry/main.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetUseType( SIMPLE_USE )

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
    self:ResetSequence(self:LookupSequence("lineidle02"))
    
    
    
end




function ENT:Think()
	if ( SERVER ) then
		
        local target
        for k,v in ipairs(ents.FindInSphere(self:GetPos(),75)) do
		    if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_FURRY then
		    	target = v
		    end
        end
        if target then
			
			target:SetupNormal()
			target:ApplyRoleStats( BREACH_ROLES.MINIGAMES.minigame.roles[13] )
			target:SetPos( target:GetPos() + Vector(0,0,-20) )
			target:SetNoCollideWithTeammates(true)
        
			target:SetNamesurvivor(table.Random({"Пушистая обнимушка","Нежная мурчалка","Мохнатая лапуська","Мягкая жмякалка","Облачная мягонька","Сладкая кексик","Медовая плюшка","Клубничная няшка","Карамельная тянучка","Ванильная пышечка","Маленькая чихуня","Добрая бусинка","Рыжая хвостушка","Забавная мордашка","Ласковая лапочка",}))
        
			target:SetMoveType(MOVETYPE_WALK)
			target:EmitSound( "nextoren/toms_screams.mp3", 89, 100, 1, CHAN_WEAPON, 0, 0 )
		end
        
	end
end

function ENT:Use(a,c)
    
end