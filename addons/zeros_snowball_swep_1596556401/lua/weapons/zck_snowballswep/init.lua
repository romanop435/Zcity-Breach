AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:PrimaryAttack()
	self:ThrowSnowball()
end

function SWEP:ThrowSnowball()

	local snowballCount = self:GetSnowballCount()
	if snowballCount <= 0 then return end

	self:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local ent = ents.Create("zck_snowball")
	if (not IsValid(ent)) then return end
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 25))
	ent:SetAngles(self.Owner:EyeAngles())
	ent:Spawn()
	local phys = ent:GetPhysicsObject()

	if (not IsValid(phys)) then
		ent:Remove()

		return
	end

	local velocity = self.Owner:GetAimVector()
	velocity = velocity * phys:GetMass() * 2000
	velocity = velocity + (VectorRand() * 10) -- a random element
	phys:ApplyForceCenter(velocity)

	cleanup.Add(self.Owner, "snowball", ent)


	timer.Simple(0.5, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_VM_DRAW)
		end
	end)

	self:SetSnowballCount(snowballCount - 1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local tr = self.Owner:GetEyeTrace()

	if tr.Hit then
		if tr.HitWorld and tr.MatType == 74 and self.Owner:GetPos():Distance(tr.HitPos) < 300 then
			local snowballCount = self:GetSnowballCount()

			if snowballCount < zck.config.Swep.MaxAmmo then
				self:SetSnowballCount(snowballCount + 1)
			end
		elseif tr.Entity and IsValid(tr.Entity) and tr.Entity:GetClass() == "zck_snowballcrate" and self.Owner:GetPos():Distance(tr.HitPos) < 100 then
			local snowballCount = self:GetSnowballCount()

			if snowballCount < zck.config.Swep.MaxAmmo then
				self:SetSnowballCount(snowballCount + 1)
				tr.Entity:TakeSnowBall()
			end
		end
	end

	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Equip()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.Owner:SetAnimation(PLAYER_IDLE)
end

function SWEP:ShouldDropOnDie()
	return false
end
