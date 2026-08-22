include("shared.lua")
SWEP.PrintName = "Snowball"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:SecondaryAttack()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local tr = self.Owner:GetEyeTrace()

	if tr.Hit and tr.HitWorld and tr.MatType == 74 and self.Owner:GetPos():Distance(tr.HitPos) < 300 then
		local snowballCount = self:GetSnowballCount()

		if snowballCount < zck.config.Swep.MaxAmmo then
			self.Owner:EmitSound("zck_snowball_pickup")
			ParticleEffect("zck_snowball_pickup", tr.HitPos, Angle(0, 0, 0), NULL)
		end
	end
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	timer.Simple(0.5, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_VM_DRAW)
		end
	end)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080
local snowball_icon = Material("materials/zerochain/zck/ui/zck_snowball.png", "smooth")
function SWEP:DrawHUD()
	//draw.RoundedBox(5, 900 * wMod, 975 * hMod, 100 * wMod, 100 * hMod, Color(0, 0, 0,200))

	surface.SetDrawColor(Color(255,255,255))
	surface.SetMaterial(snowball_icon)
	surface.DrawTexturedRect(850 * wMod, 880 * hMod, 200 * wMod, 200 * hMod)

	draw.DrawText(self:GetSnowballCount(), "zck_font01",950 * wMod, 910 * hMod, Color(0, 0, 0,125), TEXT_ALIGN_CENTER)
end

function SWEP:Holster(ent)
	self:SendWeaponAnim(ACT_VM_HOLSTER)
end
