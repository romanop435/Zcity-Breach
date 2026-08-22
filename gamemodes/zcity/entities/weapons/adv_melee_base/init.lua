
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

SWEP.Weight			= 5		
SWEP.AutoSwitchTo	= true	
SWEP.AutoSwitchFrom	= true	

util.AddNetworkString("advmelee:PlayWeightedGestureOnPlayer")
util.AddNetworkString("advmelee:PlayerParried")
util.AddNetworkString("advmelee:PlayerHitSomething")
util.AddNetworkString("advmelee:ConfigureGestures")
util.AddNetworkString("advmelee:PlayFlinchOnPlayer")

function SWEP:BroadcastAndPlayGesture(ply, gesture, weight, speed)
	ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
	ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence(gesture), 0, true)
	ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, weight)
	ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD, speed)

	local filter = RecipientFilter(true) 
	filter:AddPVS(ply:GetPos())
	filter:RemovePlayer(ply) 

	net.Start("advmelee:PlayWeightedGestureOnPlayer", true) 
		net.WriteEntity(ply)
		net.WriteString(gesture)
		net.WriteFloat(weight)
		net.WriteFloat(speed)
	net.Send(filter)
end

function SWEP:CalculateSwingDamage(ent, hitpos)
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(self.SwingDamage)
	dmginfo:SetDamageType(self.SwingDamageType)
	dmginfo:SetDamagePosition(hitpos)
	dmginfo:SetAttacker(self:GetOwner())
	dmginfo:SetInflictor(self)
	ent:TakeDamageInfo(dmginfo)
end

function SWEP:CalculateStabDamage(ent, hitpos)
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(self.StabDamage)
	dmginfo:SetDamageType(self.StabDamageType)
	dmginfo:SetDamagePosition(hitpos)
	dmginfo:SetAttacker(self:GetOwner())
	dmginfo:SetInflictor(self)
	ent:TakeDamageInfo(dmginfo)
end

function SWEP:DoParryEffect(ent, ent_weapon)
	local filter = RecipientFilter(true) 
	filter:AddPVS(ent:GetPos())
	filter:RemovePlayer(ent) 

	net.Start("advmelee:PlayerParried", true) 
		net.WriteEntity(ent) 
		net.WriteEntity(ent_weapon) 
	net.Send(filter)
end

function SWEP:EmitGoreSounds(ent, owner, ent_weapon, swinging, stabbing)
	if swinging then
		local damage = self.SwingDamage
		local dmgtype = self.SwingDamageType
		local blunt = dmgtype == DMG_CLUB

		ent:EmitSound("mordhau/weapons/meleeenvironment/sw_heavyarmormeleehit0"..math.random(1, 5)..".wav", 55, math.random(98, 102), 1)
		ent:EmitSound(self.GoreSwingSounds[math.random(1, #self.GoreSwingSounds)], 75, math.random(98, 102), 1)
	end

	if stabbing then
		local damage = self.SwingDamage
		local dmgtype = self.SwingDamageType
		local blunt = dmgtype == DMG_CLUB

		ent:EmitSound("mordhau/weapons/meleeenvironment/sw_heavyarmormeleestab0"..math.random(1, 4)..".wav", 55, math.random(98, 102), 1)
		ent:EmitSound(self.GoreStabSounds[math.random(1, #self.GoreStabSounds)], 75, math.random(98, 102), 1)
	end
end

function SWEP:DoHitEffect(bool, ent, pos, ent_weapon, hitnormal)
	local filter = RecipientFilter(true) 
	local owner = IsValid(ent_weapon) and ent_weapon:GetOwner()
	if !IsValid(owner) then
		owner = ent
	end
	filter:AddPVS(owner:GetPos())
	filter:RemovePlayer(owner) 
	net.Start("advmelee:PlayerHitSomething", true) 
		net.WriteBool(bool) 
		if IsValid(ent_weapon) then
			net.WriteEntity(owner) 
		else
			net.WriteEntity(ent)
		end
		net.WriteVector(pos)
		if !bool then
			net.WriteEntity(ent_weapon)
			net.WriteNormal(hitnormal)
		end
	net.Send(filter)
	if self:IsAliveEnt(ent) then
		self:EmitGoreSounds(ent, owner, ent_weapon, ent_weapon:GetSwinging(), ent_weapon:GetStabbing())
	else
		self:EmitSound(self.HitSolidSounds[math.random(1, #self.HitSolidSounds)], 75, math.random(50, 100), 1, CHAN_WEAPON)
	end
end

function SWEP:BroadcastAndConfigureGestures(ply, weight, speed)
	ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, weight)
	ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD, speed)

	local filter = RecipientFilter(true) 
	filter:AddPVS(ply:GetPos())
	filter:RemovePlayer(ply) 

	net.Start("advmelee:ConfigureGestures", true) 
		net.WriteEntity(ply)
		net.WriteFloat(weight)
		net.WriteFloat(speed)
	net.Send(filter)
end

function SWEP:BroadcastAndPlayFlinch(ply, gesture, weight, speed)
	ply:AnimResetGestureSlot(GESTURE_SLOT_FLINCH)
	ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_FLINCH, ply:LookupSequence(gesture), 0, true)
	ply:AnimSetGestureWeight(GESTURE_SLOT_FLINCH, weight)
	ply:SetLayerDuration(GESTURE_SLOT_FLINCH, speed)

	local filter = RecipientFilter(true) 
	filter:AddPVS(ply:GetPos())
	filter:RemovePlayer(ply) 

	net.Start("advmelee:PlayFlinchOnPlayer", true) 
		net.WriteEntity(ply)
		net.WriteString(gesture)
		net.WriteFloat(weight)
		net.WriteFloat(speed)
	net.Send(filter)
end



function SWEP:OnRestore()
end


function SWEP:AcceptInput( name, activator, caller, data )
	return false
end


function SWEP:KeyValue( key, value )
end


function SWEP:Equip( newOwner )
end


function SWEP:EquipAmmo( newOwner )
end



function SWEP:OnDrop()
end


function SWEP:ShouldDropOnDie()
	return true
end


function SWEP:GetCapabilities()

	return CAP_WEAPON_RANGE_ATTACK1

end


function SWEP:NPCShoot_Secondary( shootPos, shootDir )

	self:SecondaryAttack()

end


function SWEP:NPCShoot_Primary( shootPos, shootDir )

	self:PrimaryAttack()

end


AccessorFunc( SWEP, "fNPCMinBurst",		"NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst",		"NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate",		"NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime",	"NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime",	"NPCMaxRest" )
