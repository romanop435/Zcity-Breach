ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Указатель"
ENT.Category = "SCP"
ENT.Spawnable = true
ENT.Editable = true
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true
function ENT:SetupDataTables()

  self:NetworkVar( "String", 0, "Item" )
  self:NetworkVar( "String", 1, "TextColor" )
  

end

function ENT:Initialize()
    if SERVER then
        
    self:SetModel("models/cult_props/zone_signs.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    self:SetItem("нил")
	self:SetTextColor(tostring(Color(255,255,255)))
    
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(0000)
    end
    end
end