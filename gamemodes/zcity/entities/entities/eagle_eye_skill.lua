AddCSLuaFile()

ENT.Type = "anim"


ENT.ExplosionDamage = 700    
ENT.ExplosionRadius = 700    
ENT.ExplosionForce  = 500    



function ENT:Initialize()
    self:SetModel("models/props_c17/oildrum001.mdl")  
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
        phys:SetMass(50)  
    end

    self.HasExploded = false
end

function ENT:PhysicsCollide(data, physobj)
    if self.HasExploded then return end

    if data.Speed > 50 then  
        self:Explode(data.HitPos)
    end
end

function ENT:Explode(hitPos)
    if self.HasExploded then return end
    self.HasExploded = true

    hitPos = hitPos or self:GetPos()

    

    
	ParticleEffect("gas_explosion_fireball", self:GetPos(), Angle(0,0,0), game.GetWorld())
	ParticleEffect("gas_explosion_firesmoke", self:GetPos(), Angle(0,0,0), game.GetWorld())

	ParticleEffect("aircraft_destroy_engineSmoke1", self:GetPos(), Angle(0,0,0), game.GetWorld())
	ParticleEffect("aircraft_destroy_engine_fireball", self:GetPos(), Angle(0,0,0), game.GetWorld())

	ParticleEffect("aircraft_destroy_fireballR1", self:GetPos(), Angle(0,0,0), game.GetWorld())

    self:EmitSound("bullet/explode/large_4.wav", 100, 100)

    util.BlastDamage(self, self:GetOwner() or self, hitPos, self.ExplosionRadius, self.ExplosionDamage)

    local entities = ents.FindInSphere(hitPos, self.ExplosionRadius)
    for _, ent in ipairs(entities) do
        if ent:IsValid() and ent:GetPhysicsObject():IsValid() then
            local phys = ent:GetPhysicsObject()
            if phys then
                phys:ApplyForceCenter((ent:GetPos() - hitPos):GetNormalized() * self.ExplosionForce)
            end
        end
    end

    self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
    self:TakePhysicsDamage(dmginfo)
end