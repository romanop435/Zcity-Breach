AddCSLuaFile()

ENT.Base        = "base_entity"
ENT.Type        = "anim"
ENT.Category    = "Breach"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
  local randongarbagemodel = {
    "models/catps_office/cat202.mdl",
    "models/catps_office/cat203.mdl",
    "models/catps_office/cat204.mdl",
    "models/catps_office/cat205.mdl",
    "models/catps_office/cat206.mdl",
    "models/catps_office/cat207.mdl",
    "models/catps_office/cat208.mdl",
  }
  
  self:SetModel( self.Model or randongarbagemodel[math.random(#randongarbagemodel)] )
  
  self:PhysicsInit( SOLID_VPHYSICS ) 
  self:SetMoveType( MOVETYPE_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )

  local physobject = self:GetPhysicsObject()

  if ( physobject:IsValid() ) then
    physobject:Wake()
    physobject:EnableMotion( true ) 
  end

end

function ENT:Use( activator, caller )

  if caller:IsPlayer() and caller:GTeam() == TEAM_SCP then return end
  activator:BrProgressBar("Сбор книжки", 1, "nextoren/gui/new_icons/hand.png", self, true, function()
    if !IsValid(self) then return end
    self:Remove()
    activator:BrTip( 0, "[Книга]", Color(122, 177, 122), "вы нашли странную книгу и забрали её с собой", Color(255, 255, 255) )
    activator:AddToStatistics("Сбор книг", math.random(1,100) )
  end)

end

if ( SERVER ) then

  function ENT:Think()

  end

else

  function ENT:Draw()

    self:DrawModel()

  end

end