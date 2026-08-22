AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model( "models/cultist/scp/scp2012/crossbow_bolt.mdl" )

sound.Add( {

  name = "arrow.impact_world",
  channel = CHAN_STATIC,
  pitch = { 90, 100 },
  volume = 1,
  sound = {

    "nextoren/scp/2012/crossbow/impact/stick_1.wav",
    "nextoren/scp/2012/crossbow/impact/stick_2.wav",
    "nextoren/scp/2012/crossbow/impact/stick_3.wav"

  }

} )

sound.Add( {

  name = "arrow.impact_flesh",
  channel = CHAN_STATIC,
  pitch = { 90, 100 },
  volume = 1,
  sound = {

    "nextoren/scp/2012/crossbow/impact/flesh_1.wav",
    "nextoren/scp/2012/crossbow/impact/flesh_2.wav",
    "nextoren/scp/2012/crossbow/impact/flesh_3.wav",
    "nextoren/scp/2012/crossbow/impact/flesh_4.wav"

  }

} )

function ENT:Initialize()

  self:SetModel( self.Model )

  self:SetMoveType( MOVETYPE_FLYGRAVITY )
  self:SetSolid( SOLID_VPHYSICS )

  self:PhysWake()

  if ( SERVER ) then

    self:SetTrigger( true )
    self.CreationTime = CurTime() + 5

  end

end

function ENT:SetupDataTables()

  self:NetworkVar( "Bool", 0, "IsOnFire" )
  self:SetIsOnFire( false )

end

if ( SERVER ) then

  function ENT:Touch( collider )

    if ( self.Collided ) then return end

    if ( !collider:IsSolid() || collider == self:GetOwner() ) then return end

    local forward_vec = self:GetAngles():Forward()

    local trace = {}
    trace.start = self:GetPos() - forward_vec * 10
    trace.endpos = trace.start + forward_vec * 80
    trace.filter = { self, self:GetOwner() }

    self:SetLagCompensated( true )

    trace = util.TraceLine( trace )

    self:SetLagCompensated( false )

    

    local end_pos = trace.HitPos

    self.Collided = true

    self:SetVelocity( vector_origin )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_WORLD )

    self:SetSolid( SOLID_NONE )

    if ( collider:IsPlayer() ) then
      

      local arrow_damage = DamageInfo()
      arrow_damage:SetDamage( math.random( 190, 200 ) )
      arrow_damage:SetInflictor( self.Owner:GetActiveWeapon() || NULL )
      arrow_damage:SetAttacker( self.Owner )

      collider:TakeDamageInfo( arrow_damage )
      collider:EmitSound( "arrow.impact_flesh" )

      sound.Play( "arrow.impact_flesh", collider:GetPos(), 75, math.random( 90, 100 ), 1 )

      self:Remove()

      

      

    else

      self:SetPos( end_pos )
      self:EmitSound( "arrow.impact_world" )

    end

  end

end

if ( CLIENT ) then

  function ENT:Draw()

    self:DrawModel()

  end

end
