AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureChair001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(0000)
    end
    timer.Simple( 4, function()
    self:SetMoveType(MOVETYPE_NONE)
    end)
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end

function ENT:Use(a,c)
    
    
    
    
    
    
    
    
end

function ENT:OnTakeDamage(dmginfo)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    local attacker = dmginfo:GetAttacker()
    self:SetPos(attacker:GetPos() + Vector(0,0,40))
    attacker:EmitSound("nextoren/charactersounds/hurtsounds/male/gore_" .. math.random( 1, 4 ) .. ".mp3")
    attacker:TakeDamage(35000,attacker,self)
    attacker:CompleteAchievement("scp_chair")
    ParticleEffect( "tank_gore_c", attacker:GetPos(), attacker:GetAngles() )
	attacker:GetNWEntity( "RagdollEntityNO" ):Remove()
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    timer.Simple( math.random(1,2), function()
        for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
            if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:Alive() then
                    self:SetPos(v:GetPos() + Vector(0,0,40))
                    self:SetAngles(Angle(0,0,0))
                    v:EmitSound("nextoren/charactersounds/hurtsounds/male/gore_" .. math.random( 1, 4 ) .. ".mp3")
                    v:TakeDamage(35000,attacker,self)
                    v:CompleteAchievement("scp_chair")
                    ParticleEffect( "tank_gore_c", v:GetPos(), v:GetAngles() )
	                v:GetNWEntity( "RagdollEntityNO" ):Remove()
                    local phys = self:GetPhysicsObject()
                    if phys:IsValid() then
                    phys:Wake()
                    end
                    return
            end
        end
    end)
    timer.Simple( math.random(3,5), function()
        for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
            if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:Alive() then
                    self:SetPos(v:GetPos() + Vector(0,0,40))
                    self:SetAngles(Angle(0,0,0))
                    v:EmitSound("nextoren/charactersounds/hurtsounds/male/gore_" .. math.random( 1, 4 ) .. ".mp3")
                    v:TakeDamage(35000,attacker,self)
                    v:CompleteAchievement("scp_chair")
                    ParticleEffect( "tank_gore_c", v:GetPos(), v:GetAngles() )
	                v:GetNWEntity( "RagdollEntityNO" ):Remove()
                    local phys = self:GetPhysicsObject()
                    if phys:IsValid() then
                    phys:Wake()
                    end
                    return
            end
        end
    end)
    timer.Simple( math.random(6,9), function()
        for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
            if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:Alive() then
                self:SetPos(v:GetPos() + Vector(0,0,40))
                self:SetAngles(Angle(0,0,0))
                v:EmitSound("nextoren/charactersounds/hurtsounds/male/gore_" .. math.random( 1, 4 ) .. ".mp3")
                v:TakeDamage(35000,attacker,self)
                v:CompleteAchievement("scp_chair")
                ParticleEffect( "tank_gore_c", v:GetPos(), v:GetAngles() )
	            v:GetNWEntity( "RagdollEntityNO" ):Remove()
                local phys = self:GetPhysicsObject()
                if phys:IsValid() then
                phys:Wake()
                end
                return
            end
        end
    end)
    timer.Simple( 12, function()
    self:SetMoveType(MOVETYPE_NONE)
    end)
end