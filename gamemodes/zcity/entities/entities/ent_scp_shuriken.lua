AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model( "models/weapons/shuriken/shuriken.mdl" )

function ENT:Initialize()

  self:SetModel( self.Model )

  self:SetMoveType( MOVETYPE_FLY )
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

      self:Remove()

      

      

    else

      self:SetPos( end_pos )

    end

  end

end

if ( CLIENT ) then

  function ENT:Draw()

    self:DrawModel()

  end

end
