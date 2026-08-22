if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Наручники"
SWEP.Instructions = "Устройства для ограничения свободы рук. Можно надеть только на человека, у которого в руках ничего нет (пустые руки)."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
if CLIENT then
    --SWEP.InvIcon = Material("utopia/new_items/weapon_ash12.png")
	SWEP.InvIcon = Material("nextoren/gui/new_icons/handcuff.png")
	--nextoren/gui/new_icons/battery_2.png
end
SWEP.WorldModel = "models/grinchfox/weapons/handcuffs/dropped_handcuffs.mdl"
SWEP.WorldModelReal = "models/grinchfox/weapons/handcuffs/c_handcuffs.mdl"
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_handcuffs")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_handcuffs"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.WorkWithFake = true

SWEP.setlh = true
SWEP.setrh = true

SWEP.AnimList = {
	["deploy"] = { "anim_draw", 1, false },
    ["attack"] = { "anim_fire", 1, false, false, function(self)
		if CLIENT then return end
		local tr = self:GetEyeTrace()
		self:Tie(tr)
	end },
	["idle"] = {"anim_idle", 5, true}
}

SWEP.HoldPos = Vector(0,-1,0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.CallbackTimeAdjust = 0.5

if SERVER then
    function SWEP:OnRemove() end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Holding")
end

function SWEP:Animation() end

function SWEP:Think()
	self:SetHold(self.HoldType)
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace( self:GetOwner())
end

if CLIENT then
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
        local tr = self:GetEyeTrace()
        local toScreen = tr.HitPos:ToScreen()

        surface.SetDrawColor(255,255,255,155)
        surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end
end

function SWEP:SecondaryAttack() end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
end

local function handcuff(ragdoll)
	if ragdoll:IsBerserk() then return end
	local body = ragdoll:GetPhysicsObjectNum(0)
	local lh = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll,5))
	lh:SetPos(body:GetPos())

	local rh = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll,7))
	rh:SetPos(body:GetPos())

	local weld = constraint.Weld(ragdoll, ragdoll, hg.realPhysNum(ragdoll,7), hg.realPhysNum(ragdoll,5), 0, true, false)

	local handcuffs = ents.Create("prop_physics")
	handcuffs:SetModel("models/weapons/spy/w_handcuffs.mdl")
	handcuffs:SetPos(rh:GetPos())

	local ang = rh:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-20)
	handcuffs:SetAngles(ang)

	handcuffs:FollowBone(ragdoll,ragdoll:TranslatePhysBoneToBone(hg.realPhysNum(ragdoll,7)))
	handcuffs:SetMoveType(MOVETYPE_VPHYSICS)
	handcuffs:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	handcuffs:Spawn()

	ragdoll.handcuffed = true
	ragdoll.handcuffs = {weld, handcuffs}
end

hg.handcuff = handcuff

SWEP.CoolDown = 0

function SWEP:Tie(tr)
    local ent = tr.Entity

	if IsValid(ent) and IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() and self:GetOwner():GetPos():DistToSqr(ent:GetPos()) < 15000 then 
		if IsValid(ent) and (ent:IsRagdoll() or (ent:IsPlayer() and ent:GetVelocity():Length() < 100)) and hg.RagdollOwner(ent) ~= self:GetOwner() then
			
			local isHandcuffed = ent:GetNetVar("handcuffed", false) or ent.handcuffed or (ent.organism and ent.organism.handcuffed)
			if isHandcuffed then return end
			
			-- Проверка: у цели в руках должно быть пусто (br_holster)
			local targetPly = ent:IsPlayer() and ent or hg.RagdollOwner(ent)
			if IsValid(targetPly) then
				local activeWep = targetPly:GetActiveWeapon()
				if IsValid(activeWep) and activeWep:GetClass() ~= "br_holster" then
					if SERVER then
						self:GetOwner():RXSENDNotify("Цель должна убрать оружие (с пустыми руками)!")
					end
					return
				end
			end

			if ent:IsRagdoll() then handcuff(ent) end

			ent:EmitSound("weapons/357/357_reload3.wav")
			if ent:IsRagdoll() then ent:PhysWake() end

			local org = ent.organism or {}
			if IsValid(targetPly) and targetPly:Alive() then
				targetPly:SelectWeapon("br_holster")
				targetPly:SetNetVar("handcuffed", true)
				-- Ограничиваем скорость
				targetPly:SetWalkSpeed(75)
				targetPly:SetRunSpeed(75)
				targetPly:SetCrouchedWalkSpeed(0.5)
			end
			
			self:GetOwner():SelectWeapon("br_holster")

			org.handcuffed = true
			ent:SetNetVar("handcuffed", true)
			ent.handcuffed = true

			--if SERVER then
			--	self:Remove() -- Наручники пропадают из инвентаря после использования
			--end
		end
	end
end

if SERVER then
	hook.Add("Org Clear","Removehandcuffs",function(org)
		org.handcuffed = false 
		if IsValid(org.owner) and org.owner:IsPlayer() then
			org.owner:SetNetVar("handcuffed",false)
		end
	end)

	hook.Add("Ragdoll_Create","Addhandcuffs", function(ply, ragdoll)
		if ply.organism.handcuffed or (ragdoll.organism and ragdoll.organism.handcuffed) then
			handcuff(ragdoll)
			ply:SelectWeapon("br_holster")
		end
	end)

	hook.Add("PlayerCanPickupWeapon","handcuffDisallowpickup",function(ply,ent)
		if ply.organism and ply.organism.handcuffed then
			return false
		end
	end)

	hook.Add("PlayerUse","restrictuser",function(ply, ent)
		if ply.organism and ply.organism.handcuffed then
			return false
		end
	end)

	-- ========================================================
	-- СИСТЕМА СНЯТИЯ НАРУЧНИКОВ ЧЕРЕЗ [E] НА 15 СЕКУНД
	-- ========================================================
	hook.Add("PlayerButtonDown", "ZCity_Uncuff_Action", function(ply, button)
		if button ~= KEY_E then return end
		if not IsValid(ply) or not ply:Alive() or ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then return end
		if ply:GetNetVar("handcuffed", false) then return end -- Связанный не может развязать

		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if not IsValid(ent) then return end
		if ply:GetPos():DistToSqr(ent:GetPos()) > 8000 then return end

		local isHandcuffed = ent:GetNetVar("handcuffed", false) or ent.handcuffed or (ent.organism and ent.organism.handcuffed)
		if not isHandcuffed then return end

		local function FinishUncuff()
			if not IsValid(ent) then return end
			
			-- Удаляем физические пропы с рэгдолла
			if ent.handcuffs then
				if IsValid(ent.handcuffs[1]) then ent.handcuffs[1]:Remove() end
				if IsValid(ent.handcuffs[2]) then ent.handcuffs[2]:Remove() end
				ent.handcuffs = nil
			end

			ent.handcuffed = false
			ent:SetNetVar("handcuffed", false)
			if ent.organism then ent.organism.handcuffed = false end

			ent:EmitSound("weapons/357/357_reload1.wav")

			local targetPly = ent:IsPlayer() and ent or hg.RagdollOwner(ent)
			if IsValid(targetPly) then
				targetPly:SetNetVar("handcuffed", false)
				-- Возвращаем дефолтные скорости Breach
				targetPly:SetWalkSpeed(targetPly.OriginalWalkSpeed or 100)
				targetPly:SetRunSpeed(targetPly.OriginalRunSpeed or 231)
				targetPly:RXSENDNotify("С вас сняли наручники.")
			end
			
			if IsValid(ply) then
				ply:RXSENDNotify("Вы сняли наручники с задержанного.")
			end
		end

		-- Запускаем прогресс бар на 15 секунд. Игрок не должен двигаться (false).
		ply:BrProgressBar("СНЯТИЕ НАРУЧНИКОВ", 15, "nextoren/gui/new_icons/hand.png", ent, false, FinishUncuff)
	end)
end

hook.Add("PlayerSwitchWeapon", "WeaponSwitchExample", function(ply, oldWeapon, newWeapon)
	if (ply:GetNetVar("handcuffed", false) or not IsValid(newWeapon)) then
		local hands = ply:GetWeapon("br_holster")
		if IsValid(hands) and SERVER then
			ply:SetActiveWeapon(hands)
		end
		return true
	end
end)

function SWEP:PrimaryAttack()
	if SERVER then
		if self.CoolDown > CurTime() then return end
		self:PlayAnim("attack")
		timer.Simple(0.5, function()
			if not IsValid(self) then return end
			self:EmitSound("weapons/357/357_reload3.wav")
		end)
		self.CoolDown = CurTime() + 2
	end
end

function SWEP:Reload() end