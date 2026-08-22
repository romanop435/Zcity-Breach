AddCSLuaFile()
if CLIENT then
    SWEP.BounceWeaponIcon = false
    net.Receive("GetVictimsTable", function(len)
        local tvictim = net.ReadTable()
        LocalPlayer():GetActiveWeapon().victims = tvictim
    end)

    net.Receive("ChangeAnimations", function()
        local entity = net.ReadEntity()
        local rage = net.ReadBool()
        if entity and entity:IsValid() then
            local wep = entity:GetActiveWeapon()
            if wep ~= NULL and wep.AnimationsChange and rage then
				wep:AnimationsChange(rage, 1)
			elseif wep ~= NULL and wep.AnimationsChange and not rage then
				wep:AnimationsChange(rage, 2)
			end
        end
    end)

    function SWEP:DrawHUD()
        if not self.Deployed then self:Deploy() end
    end
end

kasanov = kasanov or {}
kasanov.FindAbilityTableByKey = function(wep, key)
    local abilityTable = wep.AbilityIcons

    for idx, info in ipairs(abilityTable) do
        if info.KEY == key then
            return idx
        end
    end

    return nil
end

if SERVER then
    util.AddNetworkString("GetVictimsTable")
    util.AddNetworkString("ChangeAnimations")
end

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/vinrax/props/keycard.mdl"
SWEP.WorldModel = "models/vinrax/props/keycard.mdl"
SWEP.PrintName = "SCP-096"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.HoldType = "scp096"
SWEP.Category = "kasanov"
SWEP.PrintName = "SCP-096 NEW"
SWEP.Base = "breach_scp_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ScreamSound = nil
SWEP.AttackDelay = 0.10
SWEP.droppable = false
SWEP.NextAttackW = 0
SWEP.IsInRage = false
SWEP.IsCrying = false

SWEP.AbilityIcons = {
	{
		Name = "Did u see me?",
		Description = "Give you some \"speedy\" to find your target",
		Cooldown = 180,
		CooldownTime = 0,
		KEY = _G["KEY_F"],
		Using = false,
		Icon = "icon16/user.png",
		Func = function(self, idx, ply)
			if not SCPLockDownHasStarted then return end
			if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            self.CooldownTime = CurTime() + self.Cooldown
			
			wep.IsCrying = true
			wep.Owner:Freeze(true)
			wep.Owner:EmitSound("shaky_scp096_new/scp_096_rage_new.ogg")
			wep.Owner.DamageModifier = 0.01
			wep:AnimationsChange(true, 3)
			wep.Owner:SetForcedAnimation("Angry", 9, nil, function()
			
				if wep and wep:IsValid() then
					wep.KeepRageUntil = CurTime() + 20
					wep.IsCrying = false
					wep.IsInRage = true
					if SERVER then wep.ScreamSound:Play() end
					wep.Owner:Freeze(false)
					wep.Owner:SetWalkSpeed(350)
					wep.Owner:SetRunSpeed(350)
					wep.Owner:SetMaxSpeed(350)
					wep.Owner.DamageModifier = 0.1
				end
			end)
		end,
	}
}

function SWEP:Deploy()
    kasanov = kasanov or {}
    kasanov.FindAbilityTableByKey = function(wep, key)
        local abilityTable = wep.AbilityIcons

        for idx, info in ipairs(abilityTable) do
            if info.KEY == key then
                return idx
            end
        end

        return nil
    end

	hook.Add('PlayerButtonDown', 'SCP096_Buttons', function(ply, button)
        if ply:GetRoleName() ~= "SCP096" then return end

        local wep = ply:GetActiveWeapon()
        if not wep or not wep.AbilityIcons then return end

        local abilityIdx = kasanov.FindAbilityTableByKey(wep, button)
        if abilityIdx then
            local abilityTable = wep.AbilityIcons[abilityIdx]
            if abilityTable.CooldownTime > CurTime() then return end
            if abilityTable.Func and isfunction(abilityTable.Func) then
                abilityTable.Func(abilityTable, abilityIdx, ply)
            end
        end
    end)

    self.Deployed = true
    if SERVER then self.Owner:DrawWorldModel(false) end
    self.Owner:DrawViewModel(false)
    if CLIENT then
        local victim_clr = Color(255, 80, 0, 210)
        hook.Add("SetupOutlines", "DrawVictims", function()
            local client = LocalPlayer()
            if client:GTeam() ~= TEAM_SCP and client:GetRoleName() ~= "SCP096" and client:Health() <= 0 then
                hook.Remove("SetupOutlines", "DrawVictims")
                return
            end

            local wep = client:GetActiveWeapon()
            if wep == NULL or not wep.victims then return end
            local victimstab = {}
            for victimsid, victimsv in ipairs(wep.victims) do
                if victimsv and victimsv:IsValid() and victimsv:Health() > 0 and victimsv:GTeam() ~= TEAM_SPEC then
                    victimstab[#victimstab + 1] = victimsv
                    local bnm = victimsv:LookupBonemerges()
                    for i = 1, #bnm do
                        victimstab[#victimstab + 1] = bnm[i]
                    end
                else
                    table.RemoveByValue(wep.victims, victimsv)
                end
            end

            outline.Add(victimstab, victim_clr, 0)
        end)
    end

    self:SetHoldType(self.HoldType)
    if SERVER then
        local filter = RecipientFilter()
        filter:AddAllPlayers()
        self.ScreamSound = CreateSound(self, "nextoren/scp/096/scream.wav", filter)
    end
end

function SWEP:DrawWorldModel()
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:CanPrimaryAttack()
    return true
end

local bannedTeams = {
    [TEAM_SCP] = true,
    [TEAM_SPEC] = true,
    [TEAM_DZ] = true
}

function SWEP:SecondaryAttack() 
    return false
end

function SWEP:Holster()
    table.Empty(self.victims)
    if SERVER and self.Owner and self.Owner:IsValid() and self.ScreamSound and self.ScreamSound:IsPlaying() then self.ScreamSound:Stop() end
end

function SWEP:OnRemove()
	hook.Remove("PlayerButtonDown", "SCP096_Buttons")
    table.Empty(self.victims)
    if SERVER and self.Owner and self.Owner:IsValid() and self.ScreamSound and self.ScreamSound:IsPlaying() then self.ScreamSound:Stop() end
end

SWEP.victims = {}
function SWEP:IsLookingAt(ply, targ)
    local yes
    if ply ~= self.Owner then
        yes = ply:GetAimVector():Dot((self.Owner:GetPos() - ply:GetPos()):GetNormalized())
        return yes > 0.9
    elseif targ and targ:IsValid() and ply == self.Owner then
        yes = ply:GetAimVector():Dot((targ:GetPos() - ply:GetPos()):GetNormalized()) + .35
        return yes > 0.9
    end
    return false
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    if self.NextAttackW >= CurTime() then return end
    self.NextAttackW = CurTime() + self.AttackDelay
    if SERVER then
        if self.IsInRage then
            local tr = {
                start = self.Owner:GetShootPos(),
                endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 90,
                filter = self.Owner,
                mins = Vector(-15, -15, -5),
                maxs = Vector(15, 15, 5)
            }

            local trace = util.TraceHull(tr)
            local ent = trace.Entity
            if not ent:IsPlayer() then return end
            if not table.HasValue(self.victims, ent) then return end
            ent:Kill()
            self.ScreamSound:Stop()
            net.Start("GetVictimsTable")
            net.WriteTable(self.victims)
            net.Send(self.Owner)
            self.Owner:Freeze(true)
            
                self.Owner:SetForcedAnimation("Claim Boy", self.Owner:SequenceDuration(self.Owner:LookupSequence("Claim Boy")), nil, function()
                    if self and self:IsValid() then
                        self.Owner:Freeze(false)
                        if #self.victims > 0 then self.ScreamSound:Play() end
                    end
                end)
            

            timer.Simple(.1, function()
                if ent:GetNWEntity("RagdollEntityNO") and ent:GetNWEntity("RagdollEntityNO"):IsValid() then
                    local ragdoll_pos = ent:GetPos()
                    local snd = CreateSound(ent, "nextoren/charactersounds/hurtsounds/male/gore_" .. math.random(1, 4) .. ".mp3") 
                    snd:SetDSP(17)
                    snd:Play()
                    if #self.victims > 0 then self:AnimationsChange(true, 1) end
                    ParticleEffect("tank_gore_c", ragdoll_pos, ent:GetAngles())
                    ent:GetNWEntity("RagdollEntityNO"):Remove()
                end
            end)

            table.RemoveByValue(self.victims, ent)
            if #self.victims <= 0 then
                self.IsInRage = false
                self.Owner:SetWalkSpeed(40)
                self.Owner:SetMaxSpeed(40)
                self.Owner:SetRunSpeed(40)
                self.Owner:DoAnimationEvent(ACT_GESTURE_MELEE_ATTACK1)
                self.ScreamSound:Stop()
                self.ScreamSound = nil
                local filter = RecipientFilter()
                filter:AddAllPlayers()
                self.ScreamSound = CreateSound(self, "nextoren/scp/096/scream.wav", filter)
                self:AnimationsChange(false, 2)
            end
        end
    end
end

function SWEP:AnimationsChange(rage, num)
    if SERVER then
        net.Start("ChangeAnimations")
        net.WriteEntity(self.Owner)
        net.WriteBool(rage)
        net.Broadcast()
    end

    if num == 1 then
        self.Owner:SetCustomCollisionCheck(true)
        self.Owner.SafeModelWalk = self.Owner:LookupSequence("walk_MELEE")
        self.Owner.SafeRun = self.Owner:LookupSequence("run_melee")
        self.Owner.IdleSafemode = self.Owner:LookupSequence("Rage Idle")
	elseif num == 2 then
        self.Owner:SetCustomCollisionCheck(false)
        self.Owner.SafeModelWalk = self.Owner:LookupSequence("walk_MELEE")
        self.Owner.SafeRun = self.Owner:LookupSequence("run_melee")
        self.Owner.IdleSafemode = self.Owner:LookupSequence("idle_loop_melee")
	elseif num == 3 then
		self.Owner:SetCustomCollisionCheck(false)
        self.Owner.SafeModelWalk = self.Owner:LookupSequence("walk_MELEE")
        self.Owner.SafeRun = self.Owner:LookupSequence("Charge Boy")
        self.Owner.IdleSafemode = self.Owner:LookupSequence("idle_loop_melee")
    end
end

function SWEP:StartWatching()
    self.IsCrying = true
    self.Owner:Freeze(true)
    self.Owner:EmitSound("shaky_scp096_new/scp_096_rage_new.ogg")
    self.Owner.DamageModifier = 0.01
    self:AnimationsChange(true, 1)
    self.Owner:SetForcedAnimation("Angry", 9, nil, function()
    
        if self and self:IsValid() then
            self.KeepRageUntil = CurTime() + 120
            self.IsCrying = false
            self.IsInRage = true
            if SERVER then self.ScreamSound:Play() end
            self.Owner:Freeze(false)
            self.Owner:SetWalkSpeed(350)
            self.Owner:SetRunSpeed(350)
            self.Owner:SetMaxSpeed(350)
            self.Owner.DamageModifier = 0.1
        end
    end)
end

local BannedDoors = {
    [5323] = true,
    [4022] = true,
    [4394] = true
}

function SWEP:Think()
    if CLIENT then return end
    if not self.Owner:Alive() then return end
    if self.IsInRage then
        for _, v in ipairs(ents.FindInSphere(self.Owner:GetPos(), 60)) do
            if v:GetClass() == "func_door" and not v.OpenedBySCP096 and self.Owner:GetVelocity():Length2D() > .25 and not BannedDoors[v:MapCreationID()] and not v:GetInternalVariable("noise2"):find("elevator") and not v:GetInternalVariable("parentname"):find("914_door") and not v:GetInternalVariable("m_iName"):find("gate") then
                v.OpenedBySCP096 = true
                v:EmitSound("nextoren/scp/096/metal_break3.wav")
                v:Fire("Unlock")
                v:Fire("Open")
                timer.Simple(6, function()
                    v:SetCustomCollisionCheck(false)
                    v.OpenedBySCP096 = false
                end)
            end
        end
    end

    local watching = false
    if not self.KeepRageUntil or not self.IsInRage or self.KeepRageUntil <= CurTime() then
        if self.IsInRage and #self.victims <= 0 then
            self.IsInRage = false 
            self.Owner:SetWalkSpeed(40)
            self.Owner:SetMaxSpeed(40)
            self.Owner:SetRunSpeed(40)
            self.Owner:DoAnimationEvent(ACT_GESTURE_MELEE_ATTACK1)
            self.ScreamSound:Stop()
            self:AnimationsChange(false, 2)
        else
            local victimremoved = false
            local victims = self.victims
            for i = #victims, 1, -1 do
                local v = victims[i]
                if not IsValid(v) or v:Health() <= 0 or v:GTeam() == TEAM_SPEC or v.AffectedBy049 or (v.SCP096TimeElapse and v.SCP096TimeElapse <= CurTime()) then
                    victims[i] = nil
                    victimremoved = true
                end
            end

            if victimremoved then
                if table.Count(victims) == 0 then
                    victims = {} 
                end

                net.Start("GetVictimsTable")
                net.WriteTable(victims)
                net.Send(self:GetOwner())
            end
        end
    end

    local List = ents.FindInSphere(self.Owner:GetPos(), 2048)
    for i = 1, #List do
        local v = List[i]
        if not v:IsPlayer() or not v and not v:IsValid() or not v:Alive() or not v:CanSee(self.Owner) or table.HasValue(self.victims, v) then continue end
        if bannedTeams[v:GTeam()] then continue end

		local tr_eyes = util.TraceLine({
            start = v:EyePos() + v:EyeAngles():Forward() * 15,
            endpos = self.Owner:EyePos()
        })

        if tr_eyes.Entity and tr_eyes.Entity:IsValid() and tr_eyes.Entity == self.Owner then
            if self.Owner:CanSee(v) and self:IsLookingAt(v) and self:IsLookingAt(self.Owner, v) and not v:IsFrozen() and not (v:HasWeapon("item_nightvision_scramble") and v:GetWeapon("item_nightvision_scramble").Nightvision) then
                watching = true
                v.SCP096TimeElapse = CurTime() + 60
                table.insert(self.victims, v)
                net.Start("GetVictimsTable")
                net.WriteTable(self.victims)
                net.Send(self.Owner)
                break
            end
        end
    end

    if watching and not self.IsInRage and not self.IsCrying then self:StartWatching() end
end