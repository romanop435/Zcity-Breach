AddCSLuaFile()

local matRefract = Material("sprites/heatwave")
local matLight	= Material("models/effects/vol_light001")

local particles = {}
particles.model = "models/hunter/tubes/circle2x2c.mdl"
particles.scale = 1
particles.xSpeed = 20
particles.ySpeed = 20
particles.zSpeed = 20
particles.solid = SOLID_NONE
particles.ent = "prop_physics"
particles.move = MOVETYPE_FLY



function EFFECT:Init( data )
	
	

	self.Time = 2
	self.LifeTime = CurTime() + self.Time

	local ent = data:GetEntity()
	if ( ent.IsInfected ) then

		self.Reversed = true

	else

		self.Reverse = false

	end

	self.Fraction = 0

	

	if ( !IsValid( ent ) ) then return end
	if ( !ent:GetModel() ) then return end

	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )

	self.ParentEntity.RenderOverride = self.RenderParent
	self.ParentEntity.SpawnEffect = self
end



function EFFECT:Think( )

	if ( !IsValid( self.ParentEntity ) ) then return false end

	local PPos = self.ParentEntity:GetPos();
	self:SetPos( PPos + (EyePos() - PPos):GetNormal() )

	if ( self.LifeTime > CurTime() ) then return true end

	self.ParentEntity.RenderOverride = nil
	self.ParentEntity.SpawnEffect = nil

	return false

end

function EFFECT:Render() end

function EFFECT:RenderOverlay( entity )

	local Fraction = (self.LifeTime - CurTime()) / self.Time
	local ColFrac = (Fraction-0.5) * 2

	Fraction = math.Clamp( Fraction, 0, 1 )
	ColFrac = math.Clamp( ColFrac, 0, 1 )


	
	

	local Pos
	if ( entity:IsPlayer() ) then

		local EyeNormal = entity:GetPos() - EyePos()
		local Distance = EyeNormal:Length()
		EyeNormal:Normalize()

		Pos = EyePos() + EyeNormal * Distance * 0.01

	else

		Pos = entity:GetPos()

	end

	
	local bClipping = self:StartClip( entity, 1.2 )
	cam.Start3D( Pos, EyeAngles() )

	
	if ( render.GetDXLevel() >= 80 ) then

		
		render.UpdateRefractTexture()

		

		
		render.MaterialOverride( matRefract )
		entity:DrawModel()
		render.MaterialOverride( 0 )

	end

	
	cam.End3D()
	render.PopCustomClipPlane()
	render.EnableClipping( bClipping );

end


function EFFECT:RenderParent()


	local bClipping = self.SpawnEffect:StartClip( self, 1 )
	self:DrawModel()
	render.PopCustomClipPlane()
	render.EnableClipping( bClipping );

	self.SpawnEffect:RenderOverlay( self )

end


function EFFECT:StartClip( model, spd )

	local mn, mx = model:GetRenderBounds()
	local Up = (mx-mn):GetNormal()
	local Bottom = model:GetPos() + mn;
	local Top = model:GetPos() + mx;

	
	
	self.Fraction = math.Approach( self.Fraction, 1, FrameTime() * 0.1 )

	local Lerped = nil
	if self.Reverse then
		Lerped = LerpVector( self.Fraction, Top, Bottom )
	else
		Lerped = LerpVector( self.Fraction, Bottom, Top )
	end

	local normal = Up
	local distance = normal:Dot( Lerped );

	local bEnabled = render.EnableClipping( true );
	render.PushCustomClipPlane( normal, distance );

	return bEnabled

end
