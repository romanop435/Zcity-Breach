if ( SERVER ) then

	AddCSLuaFile()

	CreateConVar("slappers_slap_weapons", 0, FCVAR_REPLICATED, "Slap weapons out of players' hands")
	CreateConVar("slappers_force", 300, FCVAR_REPLICATED, "Force of the slappers")

	util.AddNetworkString( "SlapAnimation" )

end

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/hand.png")

end


SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true
SWEP.UnDroppable = true

SWEP.PrintName	= "Накаченные руки"
SWEP.Slot		= 1
SWEP.SlotPos	= 0
SWEP.droppable	= false

SWEP.ViewModel	= Model("models/cultist/items/v_bigniggahands.mdl")
SWEP.WorldModel	= ""
SWEP.HoldType	= "normal"

SWEP.Primary = {
    ClipSize     = -1,
    Delay = 0,
    DefaultClip = -1,
    Automatic = false,
    Ammo = "none"
}

SWEP.Secondary = SWEP.Primary

SWEP.Sounds = {
	Miss = Sound("Weapon_Knife.Slash"),
	HitWorld = Sound("Default.ImpactSoft"),
	Hurt = {
		Sound("npc_citizen.ow01"),
		Sound("npc_citizen.ow02")
	},
	Slap = {
		Sound("nextoren/weapons/class_d_slap/slap_hit01.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit02.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit03.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit04.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit05.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit06.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit07.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit08.wav"),
		Sound("nextoren/weapons/class_d_slap/slap_hit09.wav")
	}
}

SWEP.NPCFilter = {
	"npc_monk", "npc_alyx", "npc_barney", "npc_citizen",
	"npc_kleiner", "npc_magnusson", "npc_eli", "npc_fisherman",
	"npc_gman", "npc_mossman", "npc_odessa", "npc_breen"
}

SWEP.Mins = Vector(-8, -8, -8)
SWEP.Maxs = Vector(8, 8, 8)


/*
	Weapon Config
*/
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:DrawShadow(false)

	if CLIENT then
		self:SetupHands()
	end
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

function SWEP:ShouldDropOnDie()
	return false
end


/*
	Slap Animation Reset
*/
if ( SERVER ) then

	function SWEP:Think()

		local vm = self.Owner:GetViewModel()
		if self:GetNextPrimaryFire() < CurTime() && vm:GetSequence() != 0 then

			vm:ResetSequence(0)

		end

	end

end

/*
	Third Person Slap Hack
*/
function SWEP:SlapAnimation()

	
	if SERVER and !game.SinglePlayer() then
		net.Start( "SlapAnimation" )
			net.WriteEntity(self.Owner)
		net.Broadcast()
	end

	
	
	self:SetHoldType("melee")
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	
	timer.Simple(0.3, function()
		if IsValid(self) then
			self:SetHoldType(self.HoldType)
		end
	end)

end

net.Receive( "SlapAnimation", function()

	
	local ply = net.ReadEntity()
	if !IsValid(ply) then return end

	
	local weapon = ply:GetActiveWeapon()
	if !IsValid(weapon) or !weapon.SlapAnimation then return end

	
	weapon:SlapAnimation()

end)


/*
	Slapping
*/
function SWEP:PrimaryAttack()

	if game.SinglePlayer() then
		self:CallOnClient("PrimaryAttack", "")
	end

	
	self.ViewModelFlip = false

	self:Slap()

end

function SWEP:SecondaryAttack()

	if game.SinglePlayer() then
		self:CallOnClient("SecondaryAttack", "")
	end

	
	self.ViewModelFlip = true

	self:Slap()

end

function SWEP:Slap()

	
	self:SlapAnimation()

	
	if SERVER then

		
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)

		
		local tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 40),
			mins = self.Mins,
			maxs = self.Maxs,
			filter = self.Owner
		})

		local ent = tr.Entity

		if IsValid(ent) or game.GetWorld() == ent then

			if ent:IsPlayer() then
				self:SlapPlayer(ent, tr)
			elseif ent:IsNPC() then
				self:SlapNPC(ent, tr)
			elseif ent:IsWorld() then
				self:SlapWorld()
			else
				self:SlapProp(ent, tr)
			end

		else
			self.Owner:EmitSound( self.Sounds.Miss, 80, 100 )
		end

	end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SlapPlayer(ply, tr)

	local vec = (tr.HitPos - tr.StartPos):GetNormal()

	

	
	ply:SetLocalVelocity( vec * 470 )

	
	self:SlapWeaponOutOfHands(ply)

	
	self.Owner:EmitSound( table.Random(self.Sounds.Slap), 80, 100)

end

function SWEP:SlapNPC(ent, tr)

	local vec = (tr.HitPos - tr.StartPos):GetNormal()

	
	local vel = vec * GetConVar("slappers_force"):GetInt() * 4.75
	vel.z = math.Clamp( vel.z, 0, 500 )
	ent:SetLocalVelocity( vel )

	
	if table.HasValue( self.NPCFilter, ent:GetClass() ) then

		ent:EmitSound( table.Random(self.Sounds.Hurt), 50, 100 )

	end

	
	if ent:Disposition(self.Owner) != 3 then

		
		local dmginfo = DamageInfo()
		dmginfo:SetDamagePosition(tr.HitPos)
		dmginfo:SetDamageType(DMG_CLUB)
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetInflictor(self.Owner)
		dmginfo:SetDamage(math.random(20,25))

		ent:TakeDamageInfo(dmginfo)

	end

	
	self:SlapWeaponOutOfHands(ent)

	
	self.Owner:EmitSound( table.Random(self.Sounds.Slap), 80, 100)

end

function SWEP:SlapWorld()

	self.Owner:EmitSound( self.Sounds.HitWorld, 80, 100)

end

function SWEP:SlapProp(ent, tr)

	local vec = (tr.HitPos - tr.StartPos):GetNormal()
	local emitSound = self.Sounds.HitWorld
	local damage = math.random(10,13)



	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		emitSound = table.Random(self.Sounds.Slap)
		phys:SetVelocity( phys:GetVelocity() + vec * GetConVar("slappers_force"):GetInt() * math.Clamp( 100 / phys:GetMass(), 0, 1) )
	end

	
	self.Owner:EmitSound( emitSound, 80, 100 )

end


/*
	Weapon Slapping
*/
function SWEP:SlapWeaponOutOfHands( ent )
	if !GetConVar("slappers_slap_weapons"):GetBool() then return end

	local weapon = ent:GetActiveWeapon()
	if !IsValid(weapon) then return end

	local class = weapon:GetClass()
	if class == "slappers" then return end

	local pos = weapon:GetPos()

	
	if ent:IsPlayer() then
		ent:StripWeapon( class )
	elseif ent:IsNPC() then
		weapon:Remove()
	end

	
	local wep = ents.Create( class )

	local pos
	local hand = ent:LookupBone( "ValveBiped.Bip01_R_Hand" )
	if hand then
		pos = ent:GetBonePosition( hand )
	else
		pos = ent:GetPos(), Angle(0,0,0)
	end

	wep:SetPos(pos)
	wep:SetOwner(ent)
	wep:Spawn()
	wep.CannotPickup = CurTime() + 3

	local phys = wep:GetPhysicsObject()
	if IsValid( phys ) then
		timer.Simple(0.01, function()
			local ang = self.Owner:EyeAngles()
			phys:ApplyForceCenter( ang:Forward() * 3000 + ang:Right() * 3000 + Vector(0,0,math.Rand(1500,3000)) )
		end)
	end
end

hook.Add( "PlayerCanPickupWeapon", "SlapCanPickup", function( ply, weapon )
	if weapon.CannotPickup and weapon.CannotPickup > CurTime() then
		return false
	end
end )

if CLIENT then

	local CvarAnimCam = CreateClientConVar("slappers_animated_camera", 0, true, false)

	SWEP.DrawCrosshair = false

	function SWEP:DrawHUD() end
	function SWEP:DrawWorldModel() end

	local function GetViewModelAttachment(attachment)
		local vm = LocalPlayer():GetViewModel()
		local attachID = vm:LookupAttachment(attachment)
		return vm:GetAttachment(attachID)
	end

	
	function SWEP:CalcView( ply, origin, angles, fov )
		if CvarAnimCam:GetBool() and !IsValid(self.Owner:GetVehicle()) then 
			local attach = GetViewModelAttachment("attach_camera")
			if attach and self:GetNextPrimaryFire() > CurTime() then
				local angdiff = angles - (attach.Ang + Angle(0,0,-90))

				
				if (self:GetNextPrimaryFire() > CurTime()) and angdiff.r > 179.9 then 
					angdiff.p = -(89 - angles.p) 
				end

				angles = angles - angdiff
			end
		end

		return origin, angles, fov
	end

	

	local CvarUseHands = CreateClientConVar("slappers_vm_hands", 1, true, false)
	local shouldHideVM = false
	local bonesToHide = {
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Clavicle",
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Clavicle",
	}
	local boneScale = vector_origin

	function SWEP:PreDrawViewModel( vm, ply, weapon )
		if shouldHideVM then
			shouldHideVM = false

			vm:SetMaterial("engine/occlusionproxy")
		end

		for _, bone in ipairs(bonesToHide) do
			local boneId = vm:LookupBone(bone)
			if not boneId then continue end
			vm:ManipulateBoneScale(boneId, boneScale)
		end
	end

	function SWEP:SetupHands()
		local useHands = CvarUseHands:GetBool()
		self.UseHands = useHands
		shouldHideVM = useHands
	end

	function SWEP:Holster()
		self:OnRemove()
		return true
	end

	function SWEP:OnRemove()
		if not IsValid(self.Owner) then return end

		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end

end
