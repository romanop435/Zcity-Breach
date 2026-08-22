include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Initialize()
	ParticleEffectAttach("zck_snowball_trail", PATTACH_POINT_FOLLOW, self, 0)
end

function ENT:OnRemove()
	ParticleEffect("zck_snowball_explode", self:GetPos(), Angle(0, 0, 0), NULL)
	self:EmitSound("zck_snowball_impact")
end
