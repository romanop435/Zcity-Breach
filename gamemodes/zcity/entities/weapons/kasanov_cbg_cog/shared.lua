AddCSLuaFile()

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.PrintName = "Часть моего бога"

SWEP.ViewModelFOV = 90

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/missing.png" )

end

SWEP.UnDroppable = true
SWEP.UseHands = false

SWEP.ViewModel = Model( "models/jessev92/weapons/unarmed_c.mdl" )
SWEP.WorldModel = "models/props_phx/gears/bevel9.mdl"
SWEP.HoldType = "normal"

SWEP.Spawns = {
	Vector(5443.8955078125, 1121.3458251953, -419.21389770508),
	Vector(4412.3837890625, 448.02236938477, 67.45817565918),
	Vector(8803.162109375, 842.1455078125, 62.782764434814),
	Vector(6992.5092773438, 2200.7534179688, 82.80606842041),
	Vector(5486.158203125, -1682.1391601563, 73.268608093262),
}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )

	self:SetPos( table.Random(self.Spawns) )

	CBG_COG_VECTOR = self:GetPos()
end

function SWEP:CanPrimaryAttack()
	return true
end

if CLIENT then
	function SWEP:DrawWorldModel( flags )
		if LocalPlayer():GTeam() ~= TEAM_CBG then return end
		self:DrawModel( flags )
	end

	
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack( )
	return false
end

function SWEP:Reload() end

function SWEP:Deploy()
	BREACH.SendClientEvent(nil, "set_vector", {name = "CBG_COG_VECTOR", value = vector_origin})
	if SERVER then
		self:GetOwner():RXSENDNotify("l:crb_item")
	end
end

function SWEP:OnDrop()
	CBG_COG_VECTOR = self:GetPos()
	BREACH.SendClientEvent(nil, "set_vector", {name = "CBG_COG_VECTOR", value = CBG_COG_VECTOR})
end