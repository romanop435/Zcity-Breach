/********************************
MELEE CONFIG
********************************/
SWEP.PrintName		= "advanced melee base"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.Base = "weapon_base"

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= Model("models/aoc_weapon/v_mace2.mdl")
SWEP.WorldModel		= Model("models/aoc_weapon/w_mace2.mdl")

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.UseHands = false

SWEP.SwingWindUp = 600 
SWEP.SwingRelease = 475 
SWEP.SwingRecovery = 600 

SWEP.StabWindUp = 550 
SWEP.StabRelease = 350 
SWEP.StabRecovery = 600 

SWEP.ParryCooldown = 700 
SWEP.ParryWindow = 325 

SWEP.Length = 60 

SWEP.MissCost = 10
SWEP.FeintCost = 10
SWEP.MorphCost = 7
SWEP.StaminaDrain = 19
SWEP.ParryDrainNegation = 13

SWEP.SwingDamage = 40
SWEP.SwingDamageType = DMG_CLUB
SWEP.StabDamage = 20
SWEP.StabDamageType = DMG_CLUB

SWEP.HoldType = "melee2" 
SWEP.MainHoldType = "melee2" 
SWEP.SwingHoldType = "melee2"
SWEP.StabHoldType = "knife"

SWEP.IdleAnimVM = "deflect" 

SWEP.ParryAnim = "range_melee_shove_2hand"
SWEP.ParryAnimWeight = 0.9
SWEP.ParryAnimSpeed = 0.7
SWEP.ParryAnimVM = {"block"}

SWEP.SwingAnim = "range_melee2_b"
SWEP.SwingAnimWeight = 1
SWEP.SwingAnimWindUpMultiplier = 2.5
SWEP.SwingAnimVM = {"swing1", "swing2"}

SWEP.AttackSounds = {
	"mordhau/weapons/wooshes/bluntmedium/woosh_bluntmedium-01.wav",
	"mordhau/weapons/wooshes/bluntmedium/woosh_bluntmedium-02.wav",
	"mordhau/weapons/wooshes/bluntmedium/woosh_bluntmedium-03.wav",
	"mordhau/weapons/wooshes/bluntmedium/woosh_bluntmedium-04.wav",
}


SWEP.HitSolidSounds = {
	"mordhau/weapons/impacts/quarterstaff_metal_hit_01.wav",
	"mordhau/weapons/impacts/quarterstaff_metal_hit_02.wav",
}

SWEP.HitParry = {
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_01.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_02.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_03.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_04.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_05.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_06.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_07.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_08.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_09.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_10.wav",
	"mordhau/weapons/block/combined/bladedmedium/sw_blademedium_block_11.wav",
}


SWEP.ParrySounds = {
	"mordhau/weapons/block/combined/sw_bladedmedium_wasblocked_01.wav",
	"mordhau/weapons/block/combined/sw_bladedmedium_wasblocked_02.wav",
	"mordhau/weapons/block/combined/sw_bladedmedium_wasblocked_03.wav",
}

SWEP.StabWindUpAnim = "aoc_flamberge_stab.smd"
SWEP.StabAnim = "aoc_flamberge_stab.smd"
SWEP.StabAnimWeight = 1
SWEP.StabAnimWindUpMultiplier = 3
SWEP.StabAnimVM = {"stab"}


SWEP.GoreSwingSounds = {
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_1.wav",
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_2.wav",
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_3.wav",
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_4.wav",
}


SWEP.GoreStabSounds = {
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_1.wav",
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_2.wav",
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_3.wav",
	"mordhau/weapons/hits/bluntmedium/hit_bluntmedium_4.wav",
}
/********************************
CONFIG END
********************************/

/********************************
MELEE MAIN FUNCTIONS
********************************/

if CLIENT then
gameevent.Listen("player_hurt")
hook.Add("player_hurt", "advmelee:RedParry", function(data) 
	local health = data.health				// Remaining health after injury
	local priority = SERVER and data.Priority or 5 		// Priority ??
	local id = data.userid					// Same as Player:UserID()
	local attackerid = data.attacker			// Same as Player:UserID() but it's the attacker id.

	local attacker = Player(attackerid)
	local victim = Player(id)

	local client = LocalPlayer()

	if victim != client then
		return
	end

	if !client.GetActiveWeapon then
		return
	end

	local actwep = client:GetActiveWeapon()

	if !IsValid(actwep) then
		return
	end

	if actwep:GetClass() != "adv_melee_base" then
		if !weapons.IsBasedOn(actwep:GetClass(), "adv_melee_base") then
			return
		end
	end

	if actwep.WeArePARRYING and !actwep:IsBackstab(attacker) then
		local ping = CurTime() - actwep.LastParryTime
		if ping < 0 then
			ping = ping * -1
		end
		print("Parry("..math.Round(ping * 1000).." ms ago) did not reach server in time!")
		actwep:AddRedParry(math.Round(ping * 1000))
	end
end)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Parrying")
	self:NetworkVar("Bool", 1, "ParryCooldown")
	self:NetworkVar("Bool", 2, "WindUp")
	self:NetworkVar("Bool", 3, "AttackRecovery")
	self:NetworkVar("Bool", 4, "Swinging")
	self:NetworkVar("Bool", 5, "Stabbing")
	self:NetworkVar("Bool", 6, "FullRelease")
	self:NetworkVar("Bool", 7, "Feint")
	self:NetworkVar("Bool", 8, "SwingQueued")
	self:NetworkVar("Bool", 9, "StabQueued")
	self:NetworkVar("Bool", 10, "Riposte")
	self:NetworkVar("Bool", 11, "CanRiposte")
	self:NetworkVar("Bool", 12, "Flinched")
	self:NetworkVar("Float", 0, "FlinchWeight")
	self:NetworkVar("Float", 1, "FeintWeight")
end

function SWEP:PlayFlinchOnPlayer(ply, gesture, weight, speed)
	if SERVER then
		self:BroadcastAndPlayFlinch(ply, gesture, weight, speed)
	end

	if CLIENT then
		ply:AnimResetGestureSlot(GESTURE_SLOT_FLINCH)
		ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_FLINCH, ply:LookupSequence(gesture), 0, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_FLINCH, weight)
		ply:SetLayerDuration(GESTURE_SLOT_FLINCH, speed)
	end
end

if CLIENT then
	net.Receive("advmelee:PlayFlinchOnPlayer", function()
		local ply = net.ReadEntity()
		if !IsValid(ply) then
			return
		end
	
		local gesture = net.ReadString()
		local weight = net.ReadFloat()
		local speed = net.ReadFloat()
	
		ply:AnimResetGestureSlot(GESTURE_SLOT_FLINCH)
		ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_FLINCH, ply:LookupSequence(gesture), 0, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_FLINCH, weight)
		ply:SetLayerDuration(GESTURE_SLOT_FLINCH, speed)
	end)
end

function SWEP:Flinch()
	if self:GetRiposte() then
		return
	end

	local owner = self:GetOwner()

	if self:GetSwinging() then
		self:SetFlinchWeight(self.SwingAnimWeight)
	end

	if self:GetStabbing() then
		self:SetFlinchWeight(self.StabAnimWeight)
	end

	local vm = owner:GetViewModel()
	if IsValid(vm) then
		vm:SendViewModelMatchingSequence(vm:LookupSequence(self.IdleAnimVM))
	end

	timer.Remove("advmelee:Swing_"..self:EntIndex())
	timer.Remove("advmelee:Stab_"..self:EntIndex())

	self:SetSwinging(false)
	self:SetStabbing(false)
	self:SetWindUp(false)
	self:SetFlinched(true)

	self:PlayFlinchOnPlayer(owner, "flinch_0"..math.random(1, 2), 1, 1)

	timer.Simple(325 / 1000, function()
		if !(IsValid(self) and IsValid(self:GetOwner())) then
			return
		end

		self:SetFlinched(false)
	end)
end

hook.Add("SetupMove", "advmelee:LimitMovement", function(ply, mv, cmd)
	local client = ply
	if !client.GetActiveWeapon then
		return
	end

	local wep = client:GetActiveWeapon()

	if !IsValid(wep) then
		return
	end

	if wep:GetClass() != "adv_melee_base" then
		if !weapons.IsBasedOn(wep:GetClass(), "adv_melee_base") then
			return
		end
	end

	if mv:KeyDown(IN_BACK) then
		mv:SetButtons(mv:GetButtons() - IN_RUN)
		mv:SetButtons(mv:GetButtons() - IN_SPEED)
		cmd:RemoveKey(IN_RUN)
		mv:SetMaxClientSpeed(100)
		mv:SetMaxSpeed(100)
	end

	if mv:KeyDown(IN_MOVELEFT) then
		mv:SetButtons(mv:GetButtons() - IN_RUN)
		mv:SetButtons(mv:GetButtons() - IN_SPEED)
		cmd:RemoveKey(IN_RUN)
		mv:SetMaxClientSpeed(100)
		mv:SetMaxSpeed(100)
	end

	if mv:KeyDown(IN_MOVERIGHT) then
		mv:SetButtons(mv:GetButtons() - IN_RUN)
		mv:SetButtons(mv:GetButtons() - IN_SPEED)
		cmd:RemoveKey(IN_RUN)
		mv:SetMaxClientSpeed(100)
		mv:SetMaxSpeed(100)
	end
end)

if CLIENT then
function SWEP:AddRedParry(time)
	if !self.RedParryTable then
		self.RedParryTable = {}
	end

	table.insert(self.RedParryTable, {tostring(time), LocalPlayer():Ping()})

	timer.Simple(5, function()
		if !(IsValid(self) and IsValid(self:GetOwner())) then
			return
		end

		for k, v in ipairs(self.RedParryTable) do
			if tostring(time) == v[1] then
				table.remove(self.RedParryTable, k)
			end
		end
	end)
end
end

local yellow = Color(255, 255, 0)
local black = Color(0, 0, 0)
local red = Color(255, 0, 0)
hook.Add("HUDPaint", "advmelee:DrawHUD", function()
	local client = LocalPlayer()
	if !client.GetActiveWeapon then
		return
	end

	local wep = client:GetActiveWeapon()

	if !IsValid(wep) then
		return
	end

	if wep:GetClass() != "adv_melee_base" then
		if !weapons.IsBasedOn(wep:GetClass(), "adv_melee_base") then
			return
		end
	end

	local scrw = ScrW()
	local scrh = ScrH()
	draw.SimpleTextOutlined("Alpha version", "BudgetLabel", scrw * 0.4, scrh/1.01, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.4, black)

	if wep.RedParryTable then
		for k, v in ipairs(wep.RedParryTable) do
			local time = v[1]
			local ping = v[2]
			draw.SimpleTextOutlined("Parry("..time.." ms ago) did not reach server in time! Ping: "..ping.." ms", "BudgetLabel", scrw * 0.12, scrh * 0.1 - k*15, red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.4, black)
		end
	end
end)

function SWEP:HitSolidDLight(ent, pos)
	if CLIENT then
		local dlight = DynamicLight(ent:EntIndex())
		if dlight then
			dlight.pos = pos
			dlight.r = 255
			dlight.g = 240
			dlight.b = 70
			dlight.brightness = 1
			dlight.Decay = 4000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end
	end
end

function SWEP:IsBackstab(ent)
	local angles = self:GetOwner():EyeAngles()
	angles.p = 0
	angles = angles:Forward()

	local ang = ent:EyeAngles()
	ang.p = 0
	ang = ang:Forward()

	local back = ang:DotProduct(angles) >= 0.7

	return back
end

function SWEP:GetHitBone(ply, radius)
	local weapon = self
	local startpos = ply:GetShootPos()
	local dir = ply:GetAimVector()
	local len = 100
	local sphere_pos_trace = util.TraceHull( {
		start = startpos,
		endpos = startpos + dir * len,
		maxs = maxs,
		mins = mins,
		filter = ply,
		mask = MASK_SHOT_HULL
	} )
	local sphere_ents = ents.FindInSphere(sphere_pos_trace.HitPos, radius)
	local closest_ent
	for k, v in ipairs(sphere_ents) do
		--we don't want to hit ourselves
		if ply == v then
			continue
		end

		
		if v.GetObserverMode then
			if v:GetObserverMode() != OBS_MODE_NONE then
				continue
			end
		end

		
		if !(v:IsNPC() or v:IsPlayer()) then
			continue
		end

		
		if !IsValid(closest_ent) then
			closest_ent = v
		end

		
		if v:GetPos():DistToSqr(sphere_pos_trace.HitPos) < closest_ent:GetPos():DistToSqr(sphere_pos_trace.HitPos) then
			closest_ent = v
		end

	end

	
	if !closest_ent then
		return
	end

	
	local closest_bone
	local closest_bone_pos
	if closest_ent.GetBoneCount then
		for i = 0, closest_ent:GetBoneCount() - 1 do
			
			if closest_bone == nil then
				closest_bone = i
			end

			
			local bonename = closest_ent:GetBoneName(i)
			if bonename:find("_Hand") or bonename:find("_Shoulder") or bonename:find("_UpperArm") then
				continue
			end

			
			local pos = closest_ent:GetBonePosition(i)

			
			if closest_bone_pos == nil then
				closest_bone_pos = pos
			end

        	if pos:DistToSqr(sphere_pos_trace.HitPos) < closest_bone_pos:DistToSqr(sphere_pos_trace.HitPos) then
				closest_bone = i
				closest_bone_pos = pos
			end
    	end
    end

    return closest_ent, closest_bone, closest_bone_pos
end

function SWEP:Feint()
	if !self:GetWindUp() then
		return
	end

	local owner = self:GetOwner()

	if self:GetSwinging() then
		self:SetFeintWeight(self.SwingAnimWeight)
	end

	if self:GetStabbing() then
		self:SetFeintWeight(self.StabAnimWeight)
	end

	local vm = owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(self.IdleAnimVM))

	timer.Remove("advmelee:Swing_"..self:EntIndex())
	timer.Remove("advmelee:Stab_"..self:EntIndex())

	self:SetSwinging(false)
	self:SetStabbing(false)
	self:SetWindUp(false)
	self:SetFeint(true)
end

function SWEP:Morph()

end

function SWEP:PlayGestureOnPlayer(ply, gesture, weight, speed)
	if SERVER then
		self:BroadcastAndPlayGesture(ply, gesture, weight, speed)
	end

	if CLIENT then
		ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
		ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence(gesture), 0, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, weight)
		ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD, speed)
	end
end

if CLIENT then
net.Receive("advmelee:PlayWeightedGestureOnPlayer", function()
	local ply = net.ReadEntity()
	if !IsValid(ply) then
		return
	end

	local gesture = net.ReadString()
	local weight = net.ReadFloat()
	local speed = net.ReadFloat()

	ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
	ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence(gesture), 0, true)
	ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, weight)
	ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD, speed)
end)
end

function SWEP:ConfigureGestures(ply, weight, speed)
	if SERVER then
		self:BroadcastAndConfigureGestures(ply, weight, speed)
	end

	if CLIENT then
		ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, weight)
		ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD, speed)
	end
end

if CLIENT then
net.Receive("advmelee:ConfigureGestures", function()
	local ply = net.ReadEntity()
	if !IsValid(ply) then
		return
	end

	local weight = net.ReadFloat()
	local speed = net.ReadFloat()

	ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, weight)
	ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD, speed)
end)
end

function SWEP:CanParry()
	local owner = self:GetOwner()

	if self:GetParrying() then
		
		return false
	end

	if self:GetRiposte() then
		return true
	end

	if self:GetParryCooldown() then
		
		return false
	end

	if self:GetSwinging() then
		
		return false
	end

	if self:GetStabbing() then
		
		return false
	end

	return true
end

function SWEP:Parry()
	if !self:CanParry() then
		return
	end

	self.LastParryTime = CurTime()
	self.WeArePARRYING = true

	local owner = self:GetOwner()

	self:SetParrying(true)
	self:SetParryCooldown(true)
	self:SetSwinging(false)
	self:SetStabbing(false)
	self:SetWindUp(false)
	self:PlayGestureOnPlayer(owner, self.ParryAnim, self.ParryAnimWeight, self.ParryAnimSpeed)
	self:EmitSound("mordhau/foley/drawequipment/sw_drawequipmentgeneric0"..math.random(1, 7)..".wav")

	local vm = owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(self.ParryAnimVM[math.random(1, #self.ParryAnimVM)]))

	

	timer.Simple(self.ParryWindow / 1000, function()
		if !(IsValid(self) and IsValid(self:GetOwner())) then
			return
		end
		self:SetParrying(false)
		self.WeArePARRYING = false
		timer.Simple(self.ParryCooldown / 1000, function()
			if !(IsValid(self) and IsValid(self:GetOwner())) then
				return
			end

			self:SetParryCooldown(false)
		end)
	end)
end

function SWEP:CanAttack()
	local owner = self:GetOwner()

	if self:GetFlinched() then
		return
	end

	if self:GetParryCooldown() then
		return false
	end

	if self:GetSwinging() then
		
		return false
	end

	if self:GetStabbing() then
		
		return false
	end

	if self:GetWindUp() then
		
		return false
	end

	if self:GetAttackRecovery() then
		
		return false
	end

	return true
end

function SWEP:IsAliveEnt(ent)
	if IsValid(ent) then
		if ent:IsNPC() or ent:IsPlayer() then
			return true
		end
	end

	return false
end

hook.Add("StartCommand", "advmelee:PlayerScrollUp", function(ply, cmd)
	local plytable = ply:GetTable()
	plytable.advmelee_mouse_scroll_up = cmd:GetMouseWheel() == 1
end)

function SWEP:Attack()
	if !self:CanAttack() then
		return
	end

	local owner = self:GetOwner()

	self:Slash()
end

function SWEP:Slash()
	if self:GetFeint() then
		self:SetSwingQueued(true)
		return
	end

	local owner = self:GetOwner()
	local vm = owner:GetViewModel()

	

	self:SetWindUp(true)
	self:SetFeintWeight(self.SwingAnimWeight)
	self:SetHoldType(self.SwingHoldType)
	self.HoldType = self.SwingHoldType

	vm:SendViewModelMatchingSequence(vm:LookupSequence(self.SwingAnimVM[math.random(1, #self.SwingAnimVM)]))
	self:PlayGestureOnPlayer(owner, self.SwingAnim, self.SwingAnimWeight, (self.SwingWindUp / 1000) * self.SwingAnimWindUpMultiplier + self.SwingRelease / 1000)

	if self:GetParrying() and !self:GetParryCooldown() then
		self:SetRiposte(true)
	end

	timer.Create("advmelee:Swing_"..self:EntIndex(), self.SwingWindUp / 1000, 1, function()
		if !(IsValid(self) and IsValid(self:GetOwner())) then
			return
		end

		if self:GetParrying() or self:GetParryCooldown() then
			return
		end
		self:EmitSound(self.AttackSounds[math.random(1, #self.AttackSounds)], 75, math.random(98, 102), 1, CHAN_WEAPON)
		self:SetSwinging(true)
		self:SetWindUp(false)

		
		timer.Simple((self.SwingRelease / 1000) / 2, function()
			if !(IsValid(self) and IsValid(self:GetOwner())) then
				return
			end

			self:SetFullRelease(true)
			if CLIENT then
				self.WaitForSwingCalculation = true
			end
		end)

		timer.Simple(self.SwingRelease / 1000, function()
			if !(IsValid(self) and IsValid(self:GetOwner())) then
				return
			end

			
			self:SetFullRelease(false)
			if CLIENT then
				self.WaitForSwingCalculation = false
			end
			self:SetSwinging(false)
		end)
	end)
end

function SWEP:Stab()
	if self:GetFeint() then
		self:SetStabQueued(true)
		return
	end

	if self:GetFlinched() then
		return
	end

	local owner = self:GetOwner()
	
	owner:LagCompensation(true)
		local vm = owner:GetViewModel()

		self:SetWindUp(true)
		self:SetFeintWeight(self.StabAnimWeight)
		self:SetHoldType(self.StabHoldType)
		

		vm:SendViewModelMatchingSequence(vm:LookupSequence(self.StabAnimVM[math.random(1, #self.StabAnimVM)]))
		self:PlayGestureOnPlayer(owner, self.SwingAnim, self.SwingAnimWeight, 1)
		self:PlayGestureOnPlayer(owner, self.StabAnim, self.StabAnimWeight, (self.StabWindUp / 1000) * self.StabAnimWindUpMultiplier + self.StabRelease / 1000)

		if self:GetParrying() and !self:GetParryCooldown() then
			self:SetRiposte(true)
		end

		timer.Create("advmelee:Stab_"..self:EntIndex(), self.StabWindUp / 1000, 1, function()
			if !(IsValid(self) and IsValid(self:GetOwner())) then
				return
			end

			if self:GetParrying() or self:GetParryCooldown() then
				return
			end

			self:EmitSound(self.AttackSounds[math.random(1, #self.AttackSounds)], 75, math.random(98, 102), 1, CHAN_WEAPON)
			self:SetStabbing(true)
			self:SetWindUp(false)
			self:SetHoldType(self.StabHoldType)

			
			
			timer.Simple((self.SwingRelease / 1000) / 2, function()
				if !(IsValid(self) and IsValid(self:GetOwner())) then
					return
				end

				self:SetFullRelease(true)
				if CLIENT then
					self.WaitForStabCalculation = true
				end
			end)

			timer.Simple(self.StabRelease / 1000, function()
				if !(IsValid(self) and IsValid(self:GetOwner())) then
					return
				end

				
				self:SetStabbing(false)
				self:SetFullRelease(false)
				if CLIENT then
					self.WaitForStabCalculation = false
				end
				if self:GetStabbing() then
					return
				end
				self:SetHoldType(self.MainHoldType)
			end)
		end)
	owner:LagCompensation(false)
end

function SWEP:CreateHitEffect(ent, pos, hitnormal)
	local effect = EffectData()
	effect:SetEntity(ent)
	effect:SetOrigin(pos)

	if self:IsAliveEnt(ent) then
		
		if CLIENT then
			util.Effect("BloodImpact", effect, true, true)
		end

		if SERVER then
			self:DoHitEffect(true, ent, pos, self)
		end
	else
		self:EmitSound(self.HitSolidSounds[math.random(1, #self.HitSolidSounds)], 75, math.random(50, 100), 1, CHAN_WEAPON)

		
		if CLIENT then
			local spark = EffectData()
			spark:SetEntity(ent_weapon)
			spark:SetOrigin(pos)
			spark:SetNormal(hitnormal)
			spark:SetAngles(angle_zero)
			spark:SetMagnitude(1)
			spark:SetRadius(1)
			spark:SetScale(1)

			util.Effect("Sparks", spark, nil, true)
			util.Effect("Impact", effect, true, true)
		end

		if SERVER then
			self:DoHitEffect(false, ent, pos, self, hitnormal)
		end

		if CLIENT then
			self:HitSolidDLight(self:GetOwner(), pos)
		end
	end
end

if CLIENT then
net.Receive("advmelee:PlayerHitSomething", function()
	local hit_alive = net.ReadBool()
	local ply = net.ReadEntity()
	local pos = net.ReadVector()

	local effect = EffectData()
	effect:SetEntity(ply)
	effect:SetOrigin(pos)

	if hit_alive then
		util.Effect("BloodImpact", effect, true, true)
	else
		local wep = net.ReadEntity()
		local normal = net.ReadNormal()

		local spark = EffectData()
		spark:SetEntity(wep)
		spark:SetOrigin(pos)
		spark:SetNormal(normal)
		spark:SetAngles(angle_zero)
		spark:SetMagnitude(1)
		spark:SetRadius(1)
		spark:SetScale(1)

		util.Effect("Sparks", spark, true, true)
		util.Effect("Impact", effect, true, true)

		if IsValid(wep) then
			wep:HitSolidDLight(ply, pos)
		end
	end
end)
end


function SWEP:GotParried(ent, ent_weapon)
	ent_weapon:EmitSound(ent_weapon.ParrySounds[math.random(1, #ent_weapon.ParrySounds)])
	self:EmitSound(self.HitSolidSounds[math.random(1, #self.HitSolidSounds)], 75, math.random(98, 102), 1, CHAN_WEAPON)

	local effect = EffectData()
	effect:SetEntity(ent_weapon)
	effect:SetOrigin(ent:GetBonePosition(ent:LookupBone("ValveBiped.Anim_Attachment_RH")) + (ent:GetAngles():Up() * 135) / 3)
	effect:SetNormal(ent:GetAngles():Up())
	effect:SetAngles(ent:GetAngles())
	effect:SetMagnitude(1)
	effect:SetRadius(1)
	effect:SetScale(1)

	util.Effect("Sparks", effect, nil, true)

	
	if SERVER then
		self:DoParryEffect(ent, ent_weapon)
	end
end

if CLIENT then
net.Receive("advmelee:PlayerParried", function()
	local ply = net.ReadEntity()
	if !IsValid(ply) then
		return
	end

	local wep = net.ReadEntity()
	if !IsValid(wep) then
		return
	end

	local effect = EffectData()
	local pos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Anim_Attachment_RH")) + (ply:GetAngles():Up() * 135) / 3
	effect:SetEntity(wep)
	effect:SetOrigin(pos)
	effect:SetNormal(ply:GetAngles():Up())
	effect:SetAngles(ply:GetAngles())
	effect:SetMagnitude(1)
	effect:SetRadius(1)
	effect:SetScale(1)

	wep:HitSolidDLight(ply, pos)
end)
end


function SWEP:WeParry(ent, ent_weapon)
	ent_weapon:EmitSound(ent_weapon.ParrySounds[math.random(1, #ent_weapon.ParrySounds)])
	self:EmitSound(self.HitSolidSounds[math.random(1, #self.HitSolidSounds)], 75, math.random(98, 102), 1, CHAN_WEAPON)

	if CLIENT then
		if ent == LocalPlayer() then
			return
		end
	end
	local effect = EffectData()
	effect:SetEntity(ent_weapon)
	effect:SetOrigin(self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * advmelee.CMtoHU(self.Length)) / 3)
	effect:SetNormal(ent:GetAngles():Up())
	effect:SetAngles(ent:GetAngles())
	effect:SetMagnitude(1)
	effect:SetRadius(1)
	effect:SetScale(1)

	util.Effect("Sparks", effect, nil, true)
end

function SWEP:CalculateSwingAttack()
	local owner = self:GetOwner()
	
	owner:LagCompensation(true)
	
	local startpos = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local point_trace = {}
	point_trace.start = startpos
	
	point_trace.endpos = startpos + dir * 70
	point_trace.mask = MASK_SOLID
	point_trace.filter = owner

	tr = util.TraceLine(point_trace)
	if tr.Hit then
		local hiswep = false
		if tr.Entity.GetActiveWeapon then
			local ent_actwep = tr.Entity:GetActiveWeapon()

			
			if IsValid(ent_actwep) then
				if ent_actwep:GetClass() == "adv_melee_base" or weapons.IsBasedOn(ent_actwep:GetClass(), "adv_melee_base") then
					hiswep = ent_actwep
					if ent_actwep:GetParrying() and !self:IsBackstab(tr.Entity) then
						
						ent_actwep:SetParryCooldown(false)
						self:GotParried(tr.Entity, ent_actwep)
						return true, tr.Entity
					end
				end
			end
		end

		if hiswep then
			hiswep:Flinch()
		end

		
		self:CreateHitEffect(tr.Entity, tr.HitPos, tr.HitNormal)

		if SERVER then
			self:CalculateSwingDamage(tr.Entity, tr.HitPos)
		end

		owner:LagCompensation(false)
		return true, tr.Entity 
	end

	
	local ent, bone, bone_pos = self:GetHitBone(owner, 20)
	if IsValid(ent) then
		local hiswep = false
		if ent.GetActiveWeapon then
			local ent_actwep = ent:GetActiveWeapon()

			
			if IsValid(ent_actwep) then
				if ent_actwep:GetClass() == "adv_melee_base" or weapons.IsBasedOn(ent_actwep:GetClass(), "adv_melee_base") then
					hiswep = ent_actwep
					if ent_actwep:GetParrying() and !self:IsBackstab(ent) then
						
						ent_actwep:SetParryCooldown(false)
						self:GotParried(ent, ent_actwep)
						return true, ent
					end
				end
			end
		end

		if hiswep then
			hiswep:Flinch()
		end

		
		self:CreateHitEffect(ent, bone_pos)

		if SERVER then
			self:CalculateSwingDamage(ent, bone_pos)
		end

		owner:LagCompensation(false)
		return true, ent 
	end
	owner:LagCompensation(false)
end

function SWEP:CalculateStabAttack()
	local owner = self:GetOwner()
	
	owner:LagCompensation(true)
	
	local startpos = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local point_trace = {}
	point_trace.start = startpos
	point_trace.endpos = startpos + dir * 145 
	point_trace.mask = MASK_SOLID
	point_trace.filter = owner

	tr = util.TraceLine(point_trace)
	if tr.Hit then
		hiswep = false
		if tr.Entity.GetActiveWeapon then
			local ent_actwep = tr.Entity:GetActiveWeapon()

			
			if IsValid(ent_actwep) then
				if ent_actwep:GetClass() == "adv_melee_base" or weapons.IsBasedOn(ent_actwep:GetClass(), "adv_melee_base") then
					hiswep = ent_actwep
					if ent_actwep:GetParrying() and !self:IsBackstab(tr.Entity) then
						
						ent_actwep:SetParryCooldown(false)
						self:GotParried(tr.Entity, ent_actwep)
						return true, tr.Entity
					end
				end
			end
		end

		if hiswep then
			hiswep:Flinch()
		end

		
		self:CreateHitEffect(tr.Entity, tr.HitPos, tr.HitNormal)

		if SERVER then
			self:CalculateStabDamage(tr.Entity, tr.HitPos)
		end

		owner:LagCompensation(false)
		return true, tr.Entity 
	end

	
	local ent, bone, bone_pos = self:GetHitBone(owner, 10) 
	if IsValid(ent) then
		local hiswep = false
		if ent.GetActiveWeapon then
			local ent_actwep = ent:GetActiveWeapon()

			
			if IsValid(ent_actwep) then
				if ent_actwep:GetClass() == "adv_melee_base" or weapons.IsBasedOn(ent_actwep:GetClass(), "adv_melee_base") then
					hiswep = ent_actwep
					if ent_actwep:GetParrying() and !self:IsBackstab(ent) then
						
						ent_actwep:SetParryCooldown(false)
						self:GotParried(ent, ent_actwep)
						return true, ent
					end
				end
			end
		end

		if hiswep then
			hiswep:Flinch()
		end

		
		self:CreateHitEffect(ent, bone_pos)

		if SERVER then
			self:CalculateStabDamage(ent, bone_pos)
		end

		owner:LagCompensation(false)
		return true, ent 
	end
	owner:LagCompensation(false)
end

function SWEP:Think()
	local owner = self:GetOwner()

	
	if CLIENT then
		
		if self.WaitForSwingCalculation then
			local hit, ent = self:CalculateSwingAttack()

			if hit then
				self:SetSwinging(false)
				self:SetFullRelease(false)
				self.WaitForSwingCalculation = false
				self:SetRiposte(false)
			end

			self:SetAttackRecovery(true)
			self:ConfigureGestures(owner, self.SwingAnimWeight, 0.8)
			self:SetRiposte(false)
			timer.Simple(self.SwingRecovery / 1000, function()
				if !(IsValid(self) and IsValid(self:GetOwner())) then
					return
				end

				self:SetAttackRecovery(false)
			end)
		end

		
		if self.WaitForStabCalculation then
			self:SetHoldType(self.StabHoldType)
			

			local hit, ent = self:CalculateStabAttack()

			if hit then
				self:SetStabbing(false)
				self:SetFullRelease(false)
				self.WaitForStabCalculation = false
				self:SetRiposte(false)
			end

			self:SetAttackRecovery(true)
			self:ConfigureGestures(owner, self.StabAnimWeight, 0.8)
			self:SetRiposte(false)
			timer.Simple(self.StabRecovery / 1000, function()
				if !(IsValid(self) and IsValid(self:GetOwner())) then
					return
				end

				self:SetAttackRecovery(false)
				if !self:GetStabbing() then
					self:SetHoldType(self.MainHoldType)
				end
			end)
		end
	end

	
	if self:GetFullRelease() then
		if self:GetSwinging() then
			local hit, ent = self:CalculateSwingAttack()

			if hit then
				self:SetSwinging(false)
				self:SetFullRelease(false)
				self:SetRiposte(false)
			end

			self:SetAttackRecovery(true)
			self:ConfigureGestures(owner, self.SwingAnimWeight, 0.8)
			self:SetRiposte(false)
			timer.Simple(self.SwingRecovery / 1000, function()
				if !(IsValid(self) and IsValid(self:GetOwner())) then
					return
				end

				self:SetAttackRecovery(false)
			end)
		end

		if self:GetStabbing() then
			self:SetHoldType(self.StabHoldType)
			

			local hit, ent = self:CalculateStabAttack()

			if hit then
				self:SetStabbing(false)
				self:SetFullRelease(false)
				self:SetRiposte(false)
			end

			self:SetAttackRecovery(true)
			self:ConfigureGestures(owner, self.StabAnimWeight, 0.8)
			self:SetRiposte(false)
			timer.Simple(self.StabRecovery / 1000, function()
				if !(IsValid(self) and IsValid(self:GetOwner())) then
					return
				end

				self:SetAttackRecovery(false)
				if !self:GetStabbing() then
					self:SetHoldType(self.MainHoldType)
				end
			end)
		end
	end

	local owner_table = owner:GetTable()
	if owner_table.advmelee_mouse_scroll_up then
		if self:CanAttack() then
			self:Stab()
		end
	end

	if self:GetFeint() then
		local weight = math.Approach(self:GetFeintWeight(), 0, 0.05)
		self:SetFeintWeight(weight)
		self:ConfigureGestures(owner, weight, 3)

		
		if self:GetWindUp() then
			timer.Remove("advmelee:Swing_"..self:EntIndex())
			timer.Remove("advmelee:Stab_"..self:EntIndex())

			local vm = owner:GetViewModel()
			vm:SendViewModelMatchingSequence(vm:LookupSequence(self.IdleAnimVM))

			self:SetWindUp(false)
		end

		if weight == 0 then
			self:SetFeint(false)

			if self:GetSwingQueued() then
				self:Slash()
				self:SetSwingQueued(false)
			elseif self:GetStabQueued() then
				self:Stab()
				self:SetStabQueued(false)
			end
		end
	end

	if self:GetFlinched() then
		local weight = math.Approach(self:GetFlinchWeight(), 0, 0.05)
		self:SetFlinchWeight(weight)
		self:ConfigureGestures(owner, weight, 3)
	end
end


function SWEP:Initialize()
	self:SetHoldType(self.MainHoldType)
end


function SWEP:PrimaryAttack()
	self:Attack()
end


function SWEP:SecondaryAttack()
	self:Parry()
end


function SWEP:Reload()
	if IsFirstTimePredicted() then
		self:Feint()
	end
end

function SWEP:ResetNetVars()
	self:SetParrying(false)
	self:SetParryCooldown(false)
	self:SetWindUp(false)
	self:SetAttackRecovery(false)
	self:SetSwinging(false)
	self:SetStabbing(false)
	self:SetFullRelease(false)
	self:SetFeint(false)
	self:SetSwingQueued(false)
	self:SetStabQueued(false)
	self:SetFlinched(false)
	self:SetRiposte(false)
	self:SetFlinchWeight(0)
	self:SetFeintWeight(0)
	if CLIENT then
		self.WaitForSwingCalculation = false
		self.WaitForStabCalculation = false
	end
end

function SWEP:Holster( wep )
	if SERVER then
	net.Start("ots_off")
    net.Send(self:GetOwner()) 
    self:GetOwner().IsInThirdPerson = false 
	end
	self:ResetNetVars()
	return true
end

function SWEP:Deploy()
	if SERVER then
	net.Start("ots_on")
    net.Send(self:GetOwner()) 
    self:GetOwner().IsInThirdPerson = true 
	end
	self:ResetNetVars()
	return true
end

/********************************
MAIN FUNCTIONS END
********************************/

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end


function SWEP:OnRemove()
	if SERVER then
	net.Start("ots_off")
    net.Send(self:GetOwner()) 
    self:GetOwner().IsInThirdPerson = false 
	end
end


function SWEP:OwnerChanged()
	
	
    
    
	
end










function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

SWEP:SetDeploySpeed(1)


function SWEP:DoImpactEffect( tr, nDamageType )

	return false

end

