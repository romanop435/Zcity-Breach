
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Initialize()

    if SERVER then
	self:SetModel( "models/props_junk/watermelon01.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	end

    end

end

function ArbuzFunc(index)

end

function ENT:OnTakeDamage(dmginfo)
	for k, v in player.Iterator() do
		BREACH.SendClientEvent(v, "arbuz", {entity = self})
	end
end