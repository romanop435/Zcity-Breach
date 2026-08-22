local IsValid = IsValid
local CurTime = CurTime
local pairs = pairs
local tonumber = tonumber
local math_Approach = math.Approach
local math_max = math.max
local math_min = math.min
local math_random = math.random
local math_Clamp = math.Clamp
local math_Rand = math.Rand
local timer_Simple = timer.Simple
local net = net
local hook = hook

hg.organism.module = hg.organism.module or {}
local module = hg.organism.module
hg.organism.lastindex = hg.organism.lastindex or 1000000

hook.Add("Org Clear", "Main", function(org)
	org.alive = true
	org.otrub = false
	org.entindex = IsValid(org.owner) and org.owner:EntIndex() or hg.organism.lastindex + 1
	module.pulse[1](org)
	module.blood[1](org)
	module.pain[1](org)
	module.stamina[1](org)
	module.lungs[1](org)
	module.liver[1](org)
	module.metabolism[1](org)
	module.random_events[1](org)
	org.brain = 0
	org.consciousness = 1
	org.disorientation = 0
	org.jaw = 0
	org.spine1 = 0
	org.spine2 = 0
	org.spine3 = 0
	org.chest = 0
	org.pelvis = 0
	org.skull = 0
	org.stomach = 0
	org.intestines = 0

	org.thiamine = 0

	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
	org.larmdislocation = false
	org.jawdislocation = false

	org.furryinfected = false

	org.health = 100
	org.canmove = true
	org.recoilmul = 1
	org.legstrength = 1
	org.meleespeed = 1
	org.superfighter = false
	org.CantCheckPulse = nil
	org.HEV = nil
	org.bleedingmul = 1

	-- info for rp addition
	org.last_heartbeat = CurTime()
	org.bulletwounds = 0
	org.stabwounds = 0
	org.slashwounds = 0
	org.bruises = 0
	org.burns = 0
	org.explosionwounds = 0

	org.fear = 0
	org.fearadd = 0

	org.assimilated = 0
	org.berserk = 0

	if IsValid(org.owner) then
		if org.owner:IsPlayer() and org.owner:Alive() then
			org.owner:SetHealth(100)
			org.owner:SetNetVar("wounds",{})
			org.owner:SetNetVar("arterialwounds",{})
		end

		org.owner:SetNetVar("zableval_masku", false)
	end

	org.allowholster = false
	org.just_damaged_bone = nil
	org.LodgedEntities = nil
	org.dmgstack = {}
end)

hook.Add("Should Fake Up", "organism", function(ply)
	local org = ply.organism
	if org.otrub or org.fake or org.spine1 >= hg.organism.fake_spine1 or org.spine2 >= hg.organism.fake_spine2 or org.spine3 >= hg.organism.fake_spine3 or (org.lleg == 1 and org.rleg == 1) or (org.blood < 2900) or org.consciousness <= 0.4 then return false end
end)

util.AddNetworkString("organism_send")
util.AddNetworkString("organism_sendply")

local hg_developer = ConVarExists("hg_developer") and GetConVar("hg_developer") or CreateConVar("hg_developer",0,FCVAR_SERVER_CAN_EXECUTE,"enable developer mode (enables damage traces)",0,1)

local function send_organism(org, ply)
	if not IsValid(org.owner) then return end
	
	-- Локальная инициализация таблицы работает быстро, нет нужды ее выносить
	local sendtable = {
		alive = org.alive,
		otrub = org.otrub,
		owner = org.owner,
		stamina = org.stamina,
		immobilization = org.immobilization,
		adrenaline = org.adrenaline,
		adrenalineAdd = org.adrenalineAdd,
		analgesia = org.analgesia,
		lleg = org.lleg,
		rleg = org.rleg,
		rarm = org.rarm,
		larm = org.larm,
		pelvis = org.pelvis,
		disorientation = org.disorientation,
		brain = org.brain,
		o2 = org.o2,
		CO = org.CO,
		blood = org.blood,
		bloodtype = org.bloodtype,
		bleed = org.bleed,
		pain = org.pain,
		shock = org.shock,
		pulse = org.pulse,
		heartbeat = org.heartbeat,
		timeValue = org.timeValue,
		holdingbreath = org.holdingbreath,
		arteria = org.arteria,
		recoilmul = org.recoilmul,
		meleespeed = org.meleespeed,
		canmove = org.canmove,
		fear = org.fear,
		llegdislocation = org.llegdislocation,
		rlegdislocation = org.rlegdislocation,
		rarmdislocation = org.rarmdislocation,
		larmdislocation = org.larmdislocation,
		jawdislocation = org.jawdislocation,
		lungsfunction = org.lungsfunction,
		consciousness = org.consciousness,
		assimilated = org.assimilated,
		berserk = org.berserk,
		LodgedEntities = org.LodgedEntities,
		CantCheckPulse = org.CantCheckPulse,
		critical = org.critical,
		superfighter = org.superfighter
	}

	net.Start("organism_send")
	net.WriteTable(not hg_developer:GetBool() and sendtable or org)
	net.WriteBool(org.owner.fullsend or false)
	net.WriteBool(false)
	net.WriteBool(true)
	net.WriteBool(false)
	
	if IsValid(ply) and ply:IsPlayer() then
		net.Send(ply)
	else
		net.Broadcast()
	end
	
	if org.owner == ply or not IsValid(ply) or not ply:IsPlayer() then
		org.owner.fullsend = nil
	end
end

local function send_bareinfo(org)
	if not IsValid(org.owner) then return end
	
	local sendtable = {
		alive = org.alive,
		otrub = org.otrub,
		owner = org.owner,
		bloodtype = org.bloodtype,
		pulse = org.pulse,
		blood = org.blood,
		heartbeat = org.heartbeat,
		analgesia = org.analgesia,
		o2 = org.o2,
		timeValue = org.timeValue,
		superfighter = org.superfighter,
		lungsfunction = org.lungsfunction,
		lleg = org.lleg,
		rleg = org.rleg,
		rarm = org.rarm,
		larm = org.larm,
		llegdislocation = org.llegdislocation,
		rlegdislocation = org.rlegdislocation,
		rarmdislocation = org.rarmdislocation,
		larmdislocation = org.larmdislocation,
		jawdislocation = org.jawdislocation,
		LodgedEntities = org.LodgedEntities,
		berserkActive2 = org.berserkActive2,
		CantCheckPulse = org.CantCheckPulse
	}

	local rf = RecipientFilter()
	rf:AddPVS(org.owner:GetPos())
	if org.owner:IsPlayer() then rf:RemovePlayer(org.owner) end

	net.Start("organism_send")
	net.WriteTable(not hg_developer:GetBool() and sendtable or org)
	net.WriteBool(org.owner.fullsend or false)
	net.WriteBool(true)
	net.WriteBool(false)
	net.WriteBool(false)
	net.Send(rf)
end

hg.send_organism = send_organism
hg.send_bareinfo = send_bareinfo

local META = FindMetaTable("Player")
function META:IsBerserk()
	if not IsValid(self) then return false end
	if self:IsPlayer() and not self:Alive() then return false end

	local org = self.organism
	return org and org.berserkActive2 or false
end

local META2 = FindMetaTable("Entity")
function META2:IsBerserk()
	return false
end


hook.Remove("HomigradDamage", "Berserk")

hook.Add("Org Think", "Main", function(owner, org, timeValue)
	if not IsValid(owner) then
		hg.organism.list[owner] = nil
		return
	end

	local isPly = owner:IsPlayer()
	if isPly and not owner:Alive() then return end

	if not org.stamina then return end 

	org.isPly = isPly
	local curT = CurTime()
	org.curTime = curT

	if isPly or org.fakePlayer then
		if not org.fakePlayer then
			org.alive = owner:Alive()
		end
	else
		org.alive = false
	end

	org.needotrub = false
	org.needfake = false
	org.ownerFake = isPly and (org.FakeRagdoll and true) or false
	org.timeValue = timeValue
	org.critical = false

	if isPly then
		module.stamina[2](owner, org, timeValue)
	end

	if isPly or org.fakePlayer then
		module.lungs[2](owner, org, timeValue)
	end

	if isPly then
		module.liver[2](owner, org, timeValue)
	end

	module.blood[2](owner, org, timeValue)

	if isPly then
		module.pain[2](owner, org, timeValue)
		module.metabolism[2](owner, org, timeValue)
		module.random_events[2](owner, org, timeValue)
	end
	
	module.pulse[2](owner, org, timeValue)

	org.berserk = math_Approach(org.berserk, 0, timeValue / 60)

	if org.berserk > 0 and not org.berserkActive then
		org.berserkActive = true
		owner.lastBerserkLaughSoundCD = curT + 5
		timer_Simple(3.95, function()
			if IsValid(owner) and owner.organism then
				owner.organism.berserkActive2 = true
			end
		end)
	elseif org.berserk <= 0 then
		org.berserkActive = false
		org.berserkActive2 = false
		owner.BerserkKills = nil
	end

	if org.otrub then
		org.uncon_timer = (org.uncon_timer or 0) + timeValue
	else
		org.uncon_timer = 0
	end

	local just_went_uncon = not org.otrub and org.needotrub
	local just_woke_up = not org.needotrub and org.otrub and (org.uncon_timer or 0) > 6
	
	if isPly and just_went_uncon then hook.Run("HG_OnOtrub", owner); hook.Run("PlayerDropWeapon", owner) end
	if isPly and just_woke_up then hook.Run("HG_OnWakeOtrub", owner) end

	org.canmove = (org.spine2 < hg.organism.fake_spine2 and org.spine3 < hg.organism.fake_spine3) and not org.otrub
	org.canmovehead = (org.spine3 < hg.organism.fake_spine3) and not org.otrub
	
	if not (org.canmove and org.canmovehead and ((org.stun or 0) - curT) < 0) then org.needfake = true end
	if (org.blood < 2700) then org.needfake = true end

	if org.posturing then
		local ent = hg.GetCurrentCharacter(owner)
		if IsValid(ent) then
			local bones = ent._hgPostureBones
			if not bones then
				bones = {
					rleg = ent:LookupBone("ValveBiped.Bip01_R_Foot"),
					lleg = ent:LookupBone("ValveBiped.Bip01_L_Foot"),
					rarm = ent:LookupBone("ValveBiped.Bip01_R_Hand"),
					larm = ent:LookupBone("ValveBiped.Bip01_L_Hand"),
					spine = ent:LookupBone("ValveBiped.Bip01_Spine")
				}
				bones.rleg = ent:TranslateBoneToPhysBone(bones.rleg or 0)
				bones.lleg = ent:TranslateBoneToPhysBone(bones.lleg or 0)
				bones.rarm = ent:TranslateBoneToPhysBone(bones.rarm or 0)
				bones.larm = ent:TranslateBoneToPhysBone(bones.larm or 0)
				ent._hgPostureBones = bones
			end

			if bones.spine then
				local rleg = ent:GetPhysicsObjectNum(bones.rleg)
				local lleg = ent:GetPhysicsObjectNum(bones.lleg)
				local rarm = ent:GetPhysicsObjectNum(bones.rarm)
				local larm = ent:GetPhysicsObjectNum(bones.larm)
				local down = -ent:GetBoneMatrix(bones.spine):GetAngles():Forward()
				local force = down * 500

				if IsValid(rleg) and IsValid(rarm) and IsValid(larm) and IsValid(lleg) then
					rleg:ApplyForceCenter(force)
					lleg:ApplyForceCenter(force)
					rarm:ApplyForceCenter(force)
					larm:ApplyForceCenter(force)
				end
			end
		end
	end

	if org.brain < 0.4 then
		local naturalHeal = org.thiamine > 0 and timeValue / 480 or timeValue / 1800
		org.thiamine = math_Approach(org.thiamine, 0, timeValue / 240)

		if org.liver < 1 then org.liver = math_Approach(org.liver, 0, naturalHeal) end
		if org.heart < 1 then org.heart = math_Approach(org.heart, 0, naturalHeal) end
		if org.stomach < 1 then org.stomach = math_Approach(org.stomach, 0, naturalHeal) end
		if org.intestines < 1 then org.intestines = math_Approach(org.intestines, 0, naturalHeal) end
		if org.lungsR[1] < 1 then org.lungsR[1] = math_Approach(org.lungsR[1], 0, naturalHeal) end
		if org.lungsL[1] < 1 then org.lungsL[1] = math_Approach(org.lungsL[1], 0, naturalHeal) end
	end

	if just_went_uncon then
		owner.fullsend = true
	end

	if org.brain > 0.05 and math_random(600) < org.brain * 20 then
		org.needfake = true
	end

	--org.otrub = org.needotrub
	--org.fake = org.needfake
	
	-- НАШ КОД: Если игрок потерял сознание - он мгновенно умирает
	if org.otrub and org.alive then
		org.alive = false
	end

	if isPly and (org.healthRegen or 0) < curT then
		org.healthRegen = curT + 30
		owner:SetHealth(math_min(owner:GetMaxHealth(), owner:Health() + 1.5))
	end

	org.health = owner:Health()
	local rag = isPly and owner.FakeRagdoll or owner
	
	if IsValid(rag) and rag:IsRagdoll() and (not owner.lastFake or owner.lastFake == 0) then 
		rag:SetCollisionGroup((rag:GetVelocity():LengthSqr() > 40000) and COLLISION_GROUP_NONE or COLLISION_GROUP_WEAPON) 
	end
	
	if isPly then
		if org.otrub or org.fake then hg.Fake(owner, nil, true) end
		if not org.alive and owner:Alive() then owner:Kill() end
	end

	if not org.otrub and isPly then
		local mul = hg.likely_to_phrase(owner)
		org.likely_phrase = math_max((org.likely_phrase or 0) + math_Rand(0, mul) / 100, 0)
		
		if org.likely_phrase >= 1 and not hg.GetCurrentCharacter(owner):IsOnFire() then
			org.likely_phrase = 0
			local str = hg.get_status_message(owner)
			local clr_val = math_Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255)
			owner:Notify(str, 1, "phrase", 1, nil, Color(255, clr_val, clr_val, 255))
		end
	end

	if not org.alive then 
		org.otrub = true 
		org.lungsfunction = false
		org.heartstop = true
		org.skeletonRemove = org.skeletonRemove or (curT + 90)
	end

	if org.skeletonRemove and org.skeletonRemove < curT then
		owner:Remove()
	end

	if IsValid(owner) then
		org.sendPlyTime = org.sendPlyTime or curT
		if org.sendPlyTime <= curT or just_went_uncon then
			org.sendPlyTime = curT + 1 + (not isPly and 2 or 0)
			send_bareinfo(org)

			if isPly and owner:Alive() then
				send_organism(org, owner)
			end
		end
	end
end)

hook.Add("Org Think", "regenerationberserk", function(owner, org, timeValue)
	if not (IsValid(owner) and owner:IsPlayer() and owner:Alive() and owner:IsBerserk()) then return end

	-- Кэширование математики для цикла
	local tv60 = timeValue * 60
	local tv10 = timeValue * 10
	local regen = timeValue / 120 * org.berserk

	org.blood = math_Approach(org.blood, 5000, tv60)

	for i, wound in pairs(org.wounds) do
		wound[1] = math_max(wound[1] - tv10, 0)
	end

	for i, wound in pairs(org.arterialwounds) do
		wound[1] = math_max(wound[1] - tv10, 0)
	end

	org.internalBleed = math_max(org.internalBleed - tv10, 0)

	org.lleg = math_max(org.lleg - regen, 0)
	org.rleg = math_max(org.rleg - regen, 0)
	org.rarm = math_max(org.rarm - regen, 0)
	org.larm = math_max(org.larm - regen, 0)
	org.chest = math_max(org.chest - regen, 0)
	org.pelvis = math_max(org.pelvis - regen, 0)
	org.spine1 = math_max(org.spine1 - regen, 0)
	org.spine2 = math_max(org.spine2 - regen, 0)
	org.spine3 = math_max(org.spine3 - regen, 0)
	org.skull = math_max(org.skull - regen, 0)

	org.liver = math_max(org.liver - regen, 0)
	org.intestines = math_max(org.intestines - regen, 0)
	org.heart = math_max(org.heart - regen, 0)
	org.stomach = math_max(org.stomach - regen, 0)
	org.lungsR[1] = math_max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math_max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math_max(org.lungsR[2] - regen, 0)
	org.lungsL[2] = math_max(org.lungsL[2] - regen, 0)
	org.brain = math_max(org.brain - regen, 0)

	org.hungry = 0

	org.pain = math_Approach(org.pain, 0, tv10)
	org.painadd = math_Approach(org.painadd, 0, tv10)
	org.avgpain = math_Approach(org.avgpain, 0, tv10)
	org.shock = math_Approach(org.shock, 0, tv10)
	org.immobilization = math_Approach(org.shock, 0, tv10)
	org.disorientation = math_Approach(org.disorientation, 0, tv10)

	org.lungsfunction = true
	org.heartstop = false

	owner:SetRunSpeed(math_min(500, 400 + (25 * org.berserk)))
end)


hook.Add("StartCommand","hg_lol",function(ply,cmd)
	if ply.organism and ply.organism.otrub and ply:Alive() then
		cmd:ClearMovement()
	end
end)

hook.Add("PlayerDeath","next-respawn-full",function(ply)
	ply.fullsend = true
end)

hook.Add("HG_OnWakeOtrub", "afterOtrub", function( owner )
	owner.organism.after_otrub = true
	local str = hg.get_status_message(owner)
	owner.organism.after_otrub = nil
	
	timer_Simple(0.1,function()
		if not IsValid(owner) then return end
		local clr_val = math_Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255)
		owner:Notify(str, 1, "wake", 1, nil, Color(255, clr_val, clr_val) )
	end)

	owner.organism.fearadd = owner.organism.fearadd + 5
	BREACH.SendClientEvent(owner, "flash_window")
end)

hook.Add("OnEntityWaterLevelChanged", "ClearBlood", function(ent, old, new)
	if new >= 2 then
		if ent:IsOnFire() then ent:Extinguish() end
		ent:RemoveAllDecals()
	end
end)

if CLIENT then return end

-- Таблица крупных калибров, которые пробивают броню (если игрок НЕ Джаггернаут)
--local HighCaliberAmmo = {
--    [".338 Lapua Magnum"] = true,
--    ["12.7x108 mm"] = true,
--    ["12.7x55 mm"] = true,
--    ["14.5x114mm BZTM"] = true,
--    ["14.5x114mm B32"] = true,
--    [".50 Action Express"] = true,
--    ["12/70 Slug"] = true,
--}
--
---- Классы, которые считаются "Джаггернаутами" (могут танковать даже крупные калибры броней)
--local JuggernautClasses = {
--    ["Combine"] = true,
--    ["swat"] = true,
--    ["commanderforces"] = true,
--    ["juggernaut"] = true,
--}
--
-- 1. Срезаем урон ДО расчетов боли и отрывания конечностей в Homigrad
--hook.Add("PreHomigradDamage", "HG_Juggernaut_Resists", function(ply, dmgInfo, _, ent, harm, hitBoxs, inputHole)
--    if not IsValid(ply) or not ply:IsPlayer() then return end
--    if not dmgInfo:IsDamageType(DMG_BULLET) and not dmgInfo:IsDamageType(DMG_BUCKSHOT) then return end
--
--    -- В этом хуке Homigrad передает пустую хитгруппу (nil), поэтому мы вычисляем её сами через физический трейс
--    local tr = hg.GetTraceDamage(ent, dmgInfo:GetDamagePosition(), dmgInfo:GetDamageForce())
--    if not tr or not tr.Hit then return end
--
--    local bone = tr.PhysicsBone
--    if not bone then return end
--
--    local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(bone))
--    local actual_hitgroup = hg.bonetohitgroup and hg.bonetohitgroup[bonename] or 0
--
--    -- Определяем калибр
--    local ammoName = ""
--    local inf = dmgInfo:GetInflictor()
--    if IsValid(inf) and inf.bullet then
--        ammoName = inf.bullet.AmmoType or ""
--        if type(ammoName) == "number" then ammoName = game.GetAmmoName(ammoName) or "" end
--    end
--
--    local isHighCaliber = HighCaliberAmmo[ammoName] or false
--    local isJuggernaut = JuggernautClasses[ply.PlayerClassName] or (ply.GetRoleName and string.find(ply:GetRoleName() or "", "Juggernaut"))
--
--    if isHighCaliber and not isJuggernaut then return end
--
--    if ply.HG_ArmorResist_Head == nil then UpdateResists(ply) end
--
--    -- ЛОГИКА ШЛЕМА
--    if actual_hitgroup == HITGROUP_HEAD and ply.HG_ArmorResist_Head > 0 then
--        
--        -- Режем урон практически до нуля, чтобы избежать боли, шока и отрывания головы
--        dmgInfo:SetDamage(0.11)
--        dmgInfo:SetDamageType(DMG_CLUB) -- Конвертируем в удар тупым предметом, чтобы не было дырок
--
--        if not dmgInfo.HG_HeadResistDeducted then
--            ply.HG_ArmorResist_Head = ply.HG_ArmorResist_Head - 1
--            dmgInfo.HG_HeadResistDeducted = true
--            
--            if ply.HG_ArmorResist_Head <= 0 then
--                -- Срыв шлема
--                if ply.armors and ply.armors["head"] then hg.DropArmor(ply, ply.armors["head"]) end
--                if ply.armors and ply.armors["face"] then hg.DropArmor(ply, ply.armors["face"]) end
--                ply:EmitSound("physics/metal/metal_box_break1.wav", 85)
--            else
--                ply:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1,4) .. ".wav", 80)
--            end
--        end
--
--    -- ЛОГИКА ТЕЛА
--    elseif (actual_hitgroup == HITGROUP_CHEST or actual_hitgroup == HITGROUP_STOMACH) and ply.HG_ArmorResist_Body > 0 then
--        
--        dmgInfo:ScaleDamage(0.1)
--        dmgInfo:SetDamageType(DMG_CLUB)
--
--        if not dmgInfo.HG_BodyResistDeducted then
--            ply.HG_ArmorResist_Body = ply.HG_ArmorResist_Body - 1
--            dmgInfo.HG_BodyResistDeducted = true
--            
--            if ply.HG_ArmorResist_Body <= 0 then
--                if ply.armors and ply.armors["torso"] then hg.DropArmor(ply, ply.armors["torso"]) end
--                ply:EmitSound("physics/metal/metal_box_break1.wav", 85)
--            else
--                ply:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1,4) .. ".wav", 80)
--            end
--        end
--    end
--end)
--
---- 2. Физическая защита внутренних органов от пробития навылет
--hook.Add("PreTraceOrganBulletDamage", "HG_Juggernaut_OrganResist_Fix", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
--    local ply = org.owner
--    if not IsValid(ply) or not ply:IsPlayer() then return end
--
--    local organName = organ[1]
--    local isHead = (organName == "skull" or organName == "brain" or organName == "jaw" or string.find(organName, "helmet") or string.find(organName, "mask") or string.find(organName, "visor"))
--    local isTorso = (organName == "chest" or organName == "stomach" or organName == "spine1" or organName == "spine2" or organName == "heart" or organName == "liver" or string.find(organName, "vest") or string.find(organName, "armor"))
--
--    local ammoName = ""
--    if IsValid(dmgInfo:GetInflictor()) and dmgInfo:GetInflictor().bullet then
--        ammoName = dmgInfo:GetInflictor().bullet.AmmoType or ""
--        if type(ammoName) == "number" then ammoName = game.GetAmmoName(ammoName) or "" end
--    end
--
--    local isHighCaliber = HighCaliberAmmo[ammoName] or false
--    local isJuggernaut = JuggernautClasses[ply.PlayerClassName] or (ply.GetRoleName and string.find(ply:GetRoleName() or "", "Juggernaut"))
--
--    if isHighCaliber and not isJuggernaut then return end
--    if ply.HG_ArmorResist_Head == nil then UpdateResists(ply) end
--
--    -- Если попадание в голову и есть прочность шлема
--    if isHead and ply.HG_ArmorResist_Head > 0 then
--        hook_info.dmg = 0 
--        hook_info.restricted = true -- Блокируем весь урон по мозгу
--    end
--
--    -- Если попадание в торс и есть прочность бронежилета
--    if isTorso and ply.HG_ArmorResist_Body > 0 then
--        hook_info.dmg = hook_info.dmg * 0.1
--    end
--end)
--hook.Remove("PreTraceOrganBulletDamage")
--hook.Remove("HG_Juggernaut_OrganResist_Fix")