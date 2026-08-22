AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, phys)
	if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() and data.HitEntity:Alive() then
		if data.HitEntity:GTeam() == TEAM_XMAS_VRAG then
			data.HitEntity:TakeDamage(math.random(25,75), self.Owner, self)
		else
			data.HitEntity:TakeDamage(zck.config.Swep.damage, self.Owner, self)
		end
	end

	self:Explode()
end

function ENT:Explode()
	if vFireInstalled then
		for k, ent in pairs(ents.FindInSphere(self:GetPos(),100)) do
			ent:Extinguish()
		end
	end
	SafeRemoveEntityDelayed(self, 0.1)
end
