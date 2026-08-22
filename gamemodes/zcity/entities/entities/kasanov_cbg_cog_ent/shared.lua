ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "kasanov.cbg.cog"
ENT.Category = "kasanov"
ENT.Spawnable = true
ENT.Editable = true
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true

ENT.Model = "models/props_phx/gears/bevel9.mdl"

function ENT:Initialize()
    self:SetModel( self.Model )

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end