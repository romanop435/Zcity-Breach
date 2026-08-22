AddCSLuaFile()

ENT.Base        = "base_entity"

ENT.Type        = "anim"
ENT.Category    = "Breach"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model       = Model( "models/props/scp_vendor.mdl" )

ENT.UsedPly = {}

function ENT:SetupDataTables()

  self:NetworkVar( "Bool", 0, "Activated" )

end

function ENT:PlayerDeath(vic)

  

    self.UsedPly[vic] = nil

end


ENT.DeclareSoda = {

  [ "gold_coin" ] = "item_drink_energy",
  [ "silver_coin" ] = "item_drink_soda",
  [ "copper_coin" ] = "item_drink_water"

}

local soda_vec, soda_ang = Vector( 20, 0, -25 ), Angle( -90, -90, 0 )

function ENT:CreateSoda( user )

  local pos, ang = LocalToWorld( soda_vec, soda_ang, self:GetPos(), self:GetAngles() )
  local soda = ents.Create( "weapon_scpsl_330" )
  soda:SetPos( pos )
  soda:SetAngles( ang )
  soda:Spawn()
  user:Give("weapon_scpsl_330")

end

function ENT:Initialize()

  hook.Add("DoPlayerDeath", self, self.PlayerDeath)

  self:SetModel( self.Model )
  self:SetSolid( SOLID_BBOX )
  self:PhysicsInit( SOLID_BBOX )
  self:SetMoveType(MOVETYPE_NONE)
  self:SetActivated( false )
  
  
  self:SetPlaybackRate( 1.0 )
  self.Activated = false
  self.Opened = false

  self:SetCollisionBounds( Vector( -24, -24, 0 ), Vector( 24, 24, 40 ) )

  self.idlesound = CreateSound( self, "nextoren/others/vending_machine_sounds/machine_idle.wav" )
  self.idlesound:Play()

  local phys = self:GetPhysicsObject()

  if ( phys && phys:IsValid() ) then

    phys:EnableMotion( false )
    phys:Wake()

  end

  if ( SERVER ) then

    self:SetUseType( SIMPLE_USE )

  end

end

function ENT:OnRemove()

  self.idlesound:Stop()

end

function ENT:Think()

  self:NextThink( CurTime() )

end

function ENT:Use( caller )

  if ( CLIENT ) then return end

  if ( ( self.NextUse || 0 ) > CurTime() ) then return end

  if ( !caller:IsPlayer() ) then return end

  if self.UsedPly[caller] and self.UsedPly[caller] >= 2 then
    self.UsedPly[caller] = nil
    caller:Kill()
  end

  

    self.NextUse = CurTime() + 1
    self.UsedPly[caller] = (self.UsedPly[caller] or 0) + 1

    
    
    local pos, ang = LocalToWorld( soda_vec, soda_ang, self:GetPos(), self:GetAngles() )
    local soda = ents.Create( "weapon_scpsl_330" )
    soda:SetPos( pos )
    soda:SetAngles( ang )
    soda:Spawn()
    caller:PickupWeapon(soda)
    
    self:EmitSound( "nextoren/others/vending_machine_sounds/coin_insert.wav" )
    self:EmitSound( "nextoren/others/vending_machine_sounds/can_buy.wav" )

  

end

function ENT:Draw()

  self:DrawModel()

end
