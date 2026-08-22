AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:DrawShadow(false)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply:GetPos():Distance(self:GetPos()) < 100) then
		self.lastUsed = CurTime() + 0.25
		local swep = ply:GetWeapon("zck_snowballswep")

		if IsValid(swep) then
			local snowballCount = swep:GetSnowballCount()

			if snowballCount < zck.config.Swep.MaxAmmo then
				swep:SetSnowballCount(snowballCount + 1)
				self:TakeSnowBall()
			end
		else
			ply:Give("zck_snowballswep", false)
			ply:SelectWeapon("zck_snowballswep")
			self:TakeSnowBall()
		end

	end
end

function ENT:TakeSnowBall()
	self:SetUsedCrateCount(self:GetUsedCrateCount() + 1)
end
