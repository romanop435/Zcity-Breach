if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Melee Base"
SWEP.Category = "RP Melee"

SWEP.HoldType = "melee"
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.ismelee = true
SWEP.ismelee2 = true

SWEP.setlh = true
SWEP.setrh = true
SWEP.UseHands = true
SWEP.droppable = true
SWEP.UnDroppable = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.PrimaryAttackDelay = 1.0
SWEP.SecondaryAttackDelay = 1.5
SWEP.PrimaryAttackImpactTime = 0.1 
SWEP.PrimaryAttackRange = 65
SWEP.PrimaryDamage = 25
SWEP.SecondaryDamage = 45
SWEP.DamageForce = 5
SWEP.PrimaryStamina = 15
SWEP.SecondaryStamina = 25

SWEP.ImpactDecal = "ManhackCut"
SWEP.ButtonDecal = "Light"

SWEP.SoundSwing = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.SoundHitFlesh = "physics/flesh/flesh_impact_bullet1.wav"
SWEP.SoundHitWorld = "physics/metal/metal_solid_impact_bullet1.wav"

function SWEP:IsBackstab(ent)
    if not IsValid(ent) then return false end
    local owner = self:GetOwner()
    local dirToTarget = (ent:GetPos() - owner:GetPos()):GetNormalized()
    local targetForward = ent:GetForward()
    return dirToTarget:Dot(targetForward) > 0.5
end

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    if self.AnimList and self.AnimList["deploy"] then
        local animName = type(self.AnimList["deploy"]) == "table" and self.AnimList["deploy"][1] or self.AnimList["deploy"]
        self:PlayAnim(animName, 0.8, false, nil, false, true)
    end
end

function SWEP:Deploy()
    self.Initialzed = true
    local animName = "draw"
    if self.AnimList and self.AnimList["deploy"] then
        animName = type(self.AnimList["deploy"]) == "table" and self.AnimList["deploy"][1] or self.AnimList["deploy"]
    end
    
    self:PlayAnim(animName, 0.8, false, nil, false, true)
    self:SetHold(self.HoldType)
    self:EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
    return true
end

function SWEP:Holster() return true end

function SWEP:PerformMeleeAttack(damage, range, isHeavy)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.weight = self.weight or self.Weight or 5

    if SERVER and owner.organism then
        local st_cost = isHeavy and self.SecondaryStamina or self.PrimaryStamina
        owner.organism.stamina.subadd = (owner.organism.stamina.subadd or 0) + (st_cost / 10)
    end

    owner:SetAnimation(PLAYER_ATTACK1)

    
    if SERVER then
        owner:ViewPunch(Angle(isHeavy and 5 or 3, math.random(-2, 2), 0))
        local push = owner:GetAimVector() * 50
        push.z = 0
        owner:SetVelocity(push)
    end
    
    local animTime = isHeavy and (self.SecondaryAttackDelay * 0.8) or (self.PrimaryAttackDelay * 0.8)
    local animKey = isHeavy and "hit_heavy" or "hit"
    local animName = nil

    if self.AnimList and self.AnimList[animKey] then
        animName = type(self.AnimList[animKey]) == "table" and self.AnimList[animKey][1] or self.AnimList[animKey]
    end

    if animName then
        self:PlayAnim(animName, animTime, false, nil, false, true)
    else
        local wm = self:GetWM()
        if IsValid(wm) then
            local act = isHeavy and ACT_VM_SWINGHARD or ACT_VM_PRIMARYATTACK
            local seqID = wm:SelectWeightedSequence(act)
            if seqID and seqID > 0 then
                local seqName = wm:GetSequenceName(seqID)
                if seqName then self:PlayAnim(seqName, animTime, false, nil, false, true) end
            end
        end
    end

    self:EmitSound(self.SoundSwing, 75, math.random(90, 110))

    timer.Simple(self.PrimaryAttackImpactTime, function()
        if not IsValid(self) or not IsValid(owner) or not owner:Alive() then return end

        owner:LagCompensation(true)
        local tr = {
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * range,
            filter = {self, owner, hg.GetCurrentCharacter(owner)},
            mins = Vector(-10, -10, -10),
            maxs = Vector(10, 10, 10)
        }
        local trace = util.TraceHull(tr)
        owner:LagCompensation(false)

        local ent = trace.Entity

        if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
            local plyOwner = hg.RagdollOwner(ent) or ent:GetNWEntity("ply")
            if IsValid(plyOwner) and plyOwner:IsPlayer() then ent = plyOwner end
        end

        if trace.Hit then
            if IsValid(ent) then
                if ent:IsPlayer() or ent:IsNPC() or ent:IsRagdoll() then
                    self:EmitSound(self.SoundHitFlesh, 75, math.random(90, 110), 1, CHAN_WEAPON)
                    
                    if CLIENT then
                        local fx = EffectData()
                        fx:SetOrigin(trace.HitPos)
                        fx:SetNormal(trace.HitNormal)
                        fx:SetEntity(ent)
                        util.Effect("BloodImpact", fx)
                    end

                    if SERVER then
                        local dmginfo = DamageInfo()
                        local finalDmg = damage

                        if self:IsBackstab(ent) then
                            if ent:IsPlayer() and owner.CompleteAchievement then owner:CompleteAchievement("backstab") end
                            finalDmg = finalDmg * math.Rand(2.5, 3.5)
                        else
                            finalDmg = finalDmg * math.Rand(1.0, 1.5)
                        end

                        if ent.DamageModifier then finalDmg = finalDmg * ent.DamageModifier end

                        if ent:IsPlayer() and ent:GTeam() == TEAM_SCP then
                            finalDmg = finalDmg * 0.2
                        end

                        dmginfo:SetDamage(finalDmg)
                        dmginfo:SetDamageType(DMG_SLASH)
                        dmginfo:SetAttacker(owner)
                        dmginfo:SetInflictor(self)
                        dmginfo:SetDamageForce(owner:GetAimVector() * self.DamageForce * 5000)
                        dmginfo:SetDamagePosition(trace.HitPos)

                        ent:TakeDamageInfo(dmginfo)
                    end
                elseif ent:GetClass() == "func_button" then
                    if SERVER then
                        if ChangeSkinKeypad then ChangeSkinKeypad(owner, ent, false) end
                        local fx = EffectData()
                        fx:SetOrigin(ent:GetPos())
                        fx:SetMagnitude(math.Rand(10, 15))
                        util.Effect("HelicopterMegaBomb", fx)
                        ent:EmitSound("ambient/energy/spark"..math.random(1,5)..".wav")
                        util.Decal(self.ButtonDecal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
                    end
                else
                    self:EmitSound(self.SoundHitWorld, 75, math.random(90, 110))
                    if CLIENT then util.Decal(self.ImpactDecal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal) end
                    if SERVER then
                        local phys = ent:GetPhysicsObject()
                        if IsValid(phys) then phys:ApplyForceOffset(owner:GetAimVector() * self.DamageForce * 5000, trace.HitPos) end
                    end
                end
            else
                self:EmitSound(self.SoundHitWorld, 75, math.random(90, 110))
                if CLIENT then util.Decal(self.ImpactDecal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal) end
            end
        end
    end)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + self.PrimaryAttackDelay)
    self:SetNextSecondaryFire(CurTime() + self.PrimaryAttackDelay)
    self:PerformMeleeAttack(self.PrimaryDamage, self.PrimaryAttackRange, false)
end

function SWEP:SecondaryAttack()
    if self:GetNextSecondaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + self.SecondaryAttackDelay)
    self:SetNextSecondaryFire(CurTime() + self.SecondaryAttackDelay)
    self:PerformMeleeAttack(self.SecondaryDamage, self.PrimaryAttackRange, true)
end