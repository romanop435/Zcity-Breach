if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_base"

local function RagdollOwner(ent)
    return hg.RagdollOwner(ent)
end

SWEP.WeaponName = "v92_eq_unarmed"
SWEP.PrintName = "Руки"
SWEP.Category = "ZCity Other"
SWEP.Instructions = "ПКМ - взять предмет\nУдерж. ПКМ - тащить предмет\nПКМ+R - проверить пульс (на голове/руке)\nЛКМ (Держа предмет) - Бросить предмет/СЛР\nУдерж. E (Держа предмет) - Вращать мышью"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = "normal"
SWEP.ViewModel = "models/jessev92/weapons/unarmed_c.mdl" 
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ReachDistance = 100 
SWEP.HomicideSWEP = true
SWEP.NoDrop = true
SWEP.droppable = false
SWEP.UnDroppable = true

if CLIENT then
    SWEP.BounceWeaponIcon = false
    SWEP.InvIcon = Material("nextoren/gui/new_icons/hand.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/hand.png"
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if CLIENT then
        if LEFACY_GLOVES_BOY and LEFACY_GLOVES_BOY[self:GetOwner():SteamID64()] then
            self.InvIcon = Material("nextoren/gui/new_icons/gloves_boy.png")
            self.IconOverride = "nextoren/gui/new_icons/gloves_boy.png"
        end
    end
end

function SWEP:ShouldDrawViewModel()
    return false
end

function SWEP:DrawWorldModel()
end

SWEP.supportTPIK = true

function SWEP:Camera(eyePos, eyeAng, view, vellen)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.walkinglerp = Lerp(hg.lerpFrameTime2(0.1), self.walkinglerp or 0, owner.InVehicle and owner:InVehicle() and 0 or hg.GetCurrentCharacter(owner):GetVelocity():LengthSqr())
    self.huytime = self.huytime or 0
    local walk = math.Clamp(self.walkinglerp / 10000, 0, 1)

    self.huytime = self.huytime + walk * FrameTime() * 4 * game.GetTimeScale()
    if owner:IsSprinting() then walk = walk * 2 end

    local huy = self.huytime
    local x, y = math.cos(huy) * math.sin(huy) * walk * 1, math.sin(huy) * walk * 1
    
    eyePos = eyePos - eyeAng:Up() * walk
    eyePos = eyePos - eyeAng:Up() * x * 0.5
    eyePos = eyePos - eyeAng:Right() * y * 0.5

    view.origin = (eyePos - ((angle_difference_localvec or Vector()) * 150) - ((position_difference or Vector()) * 0.5))

    return view
end

SWEP.rhandik = false
SWEP.lhandik = false

local ang4 = Angle(0, 0, 180)
local ang5 = Angle(0, 0, 0)

function SWEP:SetHandPos(noset)
    local ply = self:GetOwner()

    if not IsValid(ply) then return end
    if IsValid(ply) and (not ply.shouldTransmit or ply.NotSeen) then return end

    self.rhandik = IsValid(self.CarryEnt) and ((ply:GetNetVar("carrymass", 0) > 15) or self.CarryEnt:IsRagdoll())
    self.lhandik = IsValid(self.CarryEnt)

    local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
    if not ply_spine_index then return end
    local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
    if not ply_spine_matrix then return end

    if ply:GetNetVar("handcuffed", false) then
        if hg and hg.handcuffedhands then hg.handcuffedhands(ply) end
        return
    end

    local break_data = ply.Ability_NeckBreak
    if break_data and IsValid(break_data.Victim) then
        local victim = break_data.Victim
        local head, anga = victim:GetBonePosition(victim:LookupBone("ValveBiped.Bip01_Head1"))
        head = head + anga:Right() * -3 + anga:Forward() * 2 - anga:Up() * break_data.Progress / 40
        local ang = victim:EyeAngles()
        ang[2] = ang[2] - break_data.Progress / 5
        hg.DragHandsToPos(ply, ply:GetActiveWeapon(), head, true, 2, ang:Forward(), ang4, ang5)
    end

    local rhmat, lhmat = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")), ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_L_Hand"))
    ply.rhold = rhmat
    ply.lhold = lhmat

    hg.DragHands(ply, self)
end

function SWEP:IsLocal()
    if SERVER then return false end
    return self:GetOwner() == LocalPlayer()
end

local pickupBlackList = {
    ["item_drink_294"] = true,
    ["scp_chair"] = true,
}

local pickupWhiteList = {
    ["prop_ragdoll"] = true,
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
    if not IsValid(ent) then return false end
    if ent:IsNPC() then return false end
    if ent:IsWorld() then return false end
    if pickupBlackList[ent:GetClass()] then return false end
    if ent.BlockDrag then return false end
    if ent.IsLootingBy and #ent.IsLootingBy > 0 then return false end

    if ent:IsPlayer() then
        local isCuffed = ent:GetNetVar("handcuffed", false) or ent.handcuffed or (ent.organism and ent.organism.handcuffed)
        if isCuffed and ent:Alive() then return true end
        return false
    end


    local class = ent:GetClass()
    if pickupWhiteList[class] then return true end
    if CLIENT then return true end
    if IsValid(ent:GetPhysicsObject()) then return true end
    return false
end

SWEP.CarryDist = 50

function SWEP:SetCarrying(ent, bone, pos, dist)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if IsValid(ent) or game.GetWorld() == ent then
        self.CarryEnt = ent
        self.CarryBone = bone
        self.CarryDist = dist or 50


        if ent:IsPlayer() then
            self.CarryPos = Vector(0, 0, 40)
            if not IsValid(owner:GetNetVar("carryent")) then
                owner:SetNetVar("carryent", self.CarryEnt)
                owner:SetNetVar("carrybone", 0)
                owner:SetNetVar("carrymass", 60)
                owner:SetNetVar("carrypos", self.CarryPos)
                if SERVER then
                    ent:SetNWEntity('PlayerCarrying', owner)
                end
            end
            return
        end

        local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

        if ent:GetClass() ~= "prop_ragdoll" then
            self.CarryPos = ent:WorldToLocal(pos)
        else
            self.CarryPos = WorldToLocal(pos, angle_zero, phys:GetPos(), phys:GetAngles())
        end

        if not IsValid(owner:GetNetVar("carryent")) then
            owner:SetNetVar("carryent", self.CarryEnt)
            owner:SetNetVar("carrybone", self.CarryBone)
            owner:SetNetVar("carrymass", phys:GetMass())
            owner:SetNetVar("carrypos", self.CarryPos)
            
            if SERVER then
                ent:SetNWEntity('PlayerCarrying', owner)
                timer.Remove('RemoveOwner_' .. ent:EntIndex())
            end
        end

        if not self.CarryEnt:GetCustomCollisionCheck() then
            self.CarryEnt:SetCustomCollisionCheck(true)
            self.CarryEnt:CollisionRulesChanged()
            owner:CollisionRulesChanged()

            self.CarryEnt:CallOnRemove("removenarsla", function()
                if not IsValid(owner) then return end
                owner:CollisionRulesChanged()
                owner:SetNetVar("carryent", nil)
                owner:SetNetVar("carrybone", nil)
                owner:SetNetVar("carrymass", nil)
                owner:SetNetVar("carrypos", nil)
            end)

            owner:SetNetVar("carrymass", self.CarryEnt:GetPhysicsObjectNum(self.CarryBone):GetMass())
        end
    else
        if IsValid(self.CarryEnt) and not self.CarryEnt:IsPlayer() and self.CarryEnt:GetCustomCollisionCheck() then
            self.CarryEnt:CollisionRulesChanged()
            owner:CollisionRulesChanged()
        end

        if IsValid(owner:GetNetVar("carryent")) then
            owner:SetNetVar("carryent", nil)
            owner:SetNetVar("carrybone", nil)
            owner:SetNetVar("carrypos", nil)
            owner:SetNetVar("carrymass", 0)
        end
        
        if SERVER and IsValid(self.CarryEnt) then
            self.CarryEnt:SetNWEntity('PlayerCarrying', nil)
        end

        self.CarryEnt = nil
        self.CarryBone = nil
        self.CarryPos = nil
        self.CarryDist = nil
    end
end

function SWEP:ApplyForce()
    local ply = self:GetOwner()
    local target = ply:GetAimVector() * self.CarryDist + ply:GetShootPos()
    if not IsValid(self.CarryEnt) then return end
    
    if self.CarryEnt:IsPlayer() then
        if not self.CarryEnt:Alive() then
            self:SetCarrying()
            return
        end

        local pPos = self.CarryEnt:GetPos() + Vector(0,0,40)
        local pDir = target - pPos
        local dist = pDir:Length()
        
        if dist > 200 then
            self:SetCarrying()
            return
        end

        if SERVER then
            local currentVel = self.CarryEnt:GetVelocity()
            local desiredVel = pDir * 8

            desiredVel.x = math.Clamp(desiredVel.x, -300, 300)
            desiredVel.y = math.Clamp(desiredVel.y, -300, 300)
            
            if pDir.z > 0 then
                self.CarryEnt:SetGroundEntity(NULL)
                desiredVel.z = math.Clamp(pDir.z * 15, 50, 400)
            else
                desiredVel.z = currentVel.z
            end

            self.CarryEnt:SetLocalVelocity(desiredVel)
        end
        return
    end

    local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)
    if not IsValid(phys) then return end

    if ply.organism and ply.organism.rarmamputated and ply:IsTyping() then
        self:SetCarrying()
        return
    end

    local TargetPos = phys:GetPos()

    if self.CarryEnt.poisoned then
        if ply.organism then
            ply.organism.poison2 = CurTime()
            self.CarryEnt.poisoned = nil
        end
    end

    if self.CarryEnt.organism and ((ply.sendTimeOrg or 0) < CurTime()) then
        ply.sendTimeOrg = CurTime() + 0.5
    end

    if self.CarryPos then
        if self.CarryEnt:IsRagdoll() then
            TargetPos = LocalToWorld(self.CarryPos, angle_zero, phys:GetPos(), phys:GetAngles())
        else
            TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
        end
    end

    local Dif = target - TargetPos
    local Nom
    local addanglevelocity = vector_origin

    if self.CarryEnt:GetClass() == "prop_ragdoll" then
        Nom = (Dif:GetNormal() * math.min(1, Dif:Length() / 100) * 500) * phys:GetMass()
        addanglevelocity = -phys:GetAngleVelocity()
    else
        Nom = (Dif:GetNormal() * math.min(1, Dif:Length() / 100) * 500 - phys:GetVelocity()) * phys:GetMass()
        addanglevelocity = -phys:GetAngleVelocity() / 4
    end

    if (ply.organism and ply.organism.superfighter) or ply:IsBerserk() then
        Nom = Nom * 2
    end

    if Dif:Length() > 200 then
        self:SetCarrying()
        return
    end

    phys:Wake()
    self.CarryEnt:SetPhysicsAttacker(ply, 15)

    if SERVER then
        if self.CarryEnt.welds then
            for _, weld in pairs(self.CarryEnt.welds) do
                if IsValid(weld) then weld:Remove() end
            end
            self.CarryEnt.welds = nil
        end
        if (ply:GetGroundEntity() == self.CarryEnt) or (ply:GetEntityInUse() == self.CarryEnt) or IsValid(ply.FakeRagdoll) or self.CarryEnt:IsPlayerHolding() then
            self:SetCarrying()
            return
        end

        local boneId = self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone)
        local boneName = (boneId and boneId >= 0) and self.CarryEnt:GetBoneName(boneId) or ""

        if self.CarryEnt:GetClass() == "prop_ragdoll" then
            local ply2 = RagdollOwner(self.CarryEnt) or self.CarryEnt

            if ply:KeyPressed(IN_RELOAD) then
                if not ply2.noHead and ply2.organism then
                    if not ply2.organism.CantCheckPulse and (boneName == "ValveBiped.Bip01_L_Hand" or boneName == "ValveBiped.Bip01_R_Hand" or boneName == "ValveBiped.Bip01_Head1") then
                        local org = ply2.organism

                        if org.heartstop then
                            ply:ChatPrint("Пульс отсутствует.")
                        else
                            if org.pulse < 20 then ply:ChatPrint("Пульс едва ощутим.")
                            elseif org.pulse <= 50 then ply:ChatPrint("Слабый пульс.")
                            elseif org.pulse <= 90 then ply:ChatPrint("Нормальный пульс.")
                            else ply:ChatPrint("Высокий пульс.") end
                        end

                        if org.blood < 3500 then ply:ChatPrint("Кожа бледная.") end
                        if org.bleed > 10 then ply:ChatPrint("Тело кровоточит обильно.")
                        elseif org.bleed > 5 then ply:ChatPrint("Тело кровоточит умеренно.")
                        elseif org.bleed > 0 then ply:ChatPrint("Тело кровоточит слабо.") end

                        if boneName == "ValveBiped.Bip01_Head1" then
                            if org.o2.curregen == 0 or not org.alive or org.holdingbreath then
                                ply:ChatPrint("Дыхание отсутствует.")
                            else
                                ply:ChatPrint("Дышит.")
                            end
                            if org.isPly and not org.otrub then
                                org.owner:ChatPrint("Вас проверили на реакцию.")
                            end
                        end
                    end
                end
            end
        end

        if ply:KeyDown(IN_ATTACK) then
            local tr = util.TraceLine({start = TargetPos, endpos = TargetPos - vector_up * 16, mask = MASK_SOLID_BRUSHONLY})

            if boneName ~= "ValveBiped.Bip01_Spine2" or not tr.Hit then
                local throwMul = (ply.organism and ply.organism.superfighter or ply:IsBerserk()) and 2 or 1
                phys:ApplyForceCenter(ply:GetAimVector() * math.min(15000, phys:GetMass() * 800) * throwMul)
                self:SetCarrying()
                return
            end

            if self.CarryEnt.organism and boneName == "ValveBiped.Bip01_Spine2" and tr.Hit then
                if self.firstTimePrint then
                    if not self.CarryEnt.noHead then ply:ChatPrint("Вы делаете СЛР.") else ply:Notify("Я не думаю, что СЛР здесь помогло бы...", 10) end
                end
                self.firstTimePrint = false

                if (self.CPRThink or 0) < CurTime() then
                    self.CPRThink = CurTime() + (1 / 120) * 60
                    local org = self.CarryEnt.organism
                    if org.alive then
                        org.pulse = math.min(org.pulse + 5 * (ply.Profession == "doctor" and 2 or 1), 70)
                        org.CO = math.Approach(org.CO, 0, (ply.Profession == "doctor" and 2 or 1))
                        org.COregen = math.Approach(org.COregen, 0, (ply.Profession == "doctor" and 2 or 1))
                        if math.random(3) == 1 then org.lungsfunction = true end
                        if math.random(50) == 1 and (ply.Profession ~= "doctor") then
                            local dmginfo = DamageInfo()
                            dmginfo:SetDamageType(DMG_CRUSH)
                            dmginfo:SetInflictor(self)
                            hg.organism.input_list.chest(org, 1, 5, dmginfo)
                        end
                        if org.pulse > 15 then org.heartstop = false end
                    end
                    phys:ApplyForceCenter(-vector_up * 6000)
                end
            end
        else
            self.firstTimePrint = true
        end
    end

    if self.CarryPos then
        phys:ApplyForceOffset(Nom, TargetPos)
    else
        phys:ApplyForceCenter(Nom)
    end

    if ply:KeyDown(IN_USE) then
        local commands = ply:GetCurrentCommand()
        local x, y = commands:GetMouseX(), commands:GetMouseY()
        local rotate = Vector(0, -x, -y) / (self.CarryEnt:IsRagdoll() and 6 or 4)
        addanglevelocity = addanglevelocity + (rotate * phys:GetMass() / 10)
    end

    phys:AddAngleVelocity(addanglevelocity)
end

function SWEP:GetCarrying()
    return self.CarryEnt
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if owner.PlayerClassName == "sc_infiltrator" and self.handsDesc ~= "infiltrator" then
        self.PrintName = "CQC"
        self.handsDesc = "infiltrator"
    elseif owner.PlayerClassName == "furry" and self.handsDesc ~= "furry" then
        self.PrintName = "Лапы"
        self.handsDesc = "furry"
    elseif self.handsDesc ~= "default" then
        self.PrintName = "Руки"
        self.handsDesc = "default"
    end

    if owner:GetNWBool("TauntHolsterWeapons", false) then
        self:SetCarrying()
        return
    end

    if IsValid(owner) and owner:KeyDown(IN_ATTACK2) then
        if IsValid(self.CarryEnt) or game.GetWorld() == self.CarryEnt then 
            self:ApplyForce() 
        end
    elseif self.CarryEnt then
        self:SetCarrying() 
    end

    local HoldType = "normal"
    if SERVER then self:SetHoldType(HoldType) end
end

function SWEP:PrimaryAttack()
    return false 
end

function SWEP:SecondaryAttack()
    if self:GetOwner():InVehicle() then return end
    if not IsFirstTimePredicted() then return end
    if self:GetOwner():GetNetVar("handcuffed", false) then return end
    
    if SERVER then
        self:SetCarrying()
        local ply = self:GetOwner()
        local pos = ply:GetShootPos()
        local dir = ply:GetAimVector()
        
        local tr
        if ply.PlayerClassName == "furry" then
            tr = util.TraceHull({
                start = pos,
                endpos = pos + dir * self.ReachDistance,
                filter = {ply},
                mins = Vector(-5, -5, -5),
                maxs = Vector(5, 5, 5),
            })
        else
            tr = util.TraceLine({
                start = pos,
                endpos = pos + dir * self.ReachDistance,
                filter = {ply}
            })
        end

        if IsValid(tr.Entity) and self:CanPickup(tr.Entity) then
            local dist = (pos - tr.HitPos):Length()
            sound.Play("Flesh.ImpactSoft", ply:GetShootPos(), 65, math.random(90, 110))
            
            local bone = tr.PhysicsBone or 0
            if tr.Entity:GetClass() == "prop_ragdoll" then
                local closest = math.huge
                for i = 0, tr.Entity:GetPhysicsObjectCount() - 1 do
                    local phys = tr.Entity:GetPhysicsObjectNum(i)
                    if IsValid(phys) then
                        local d = phys:GetPos():DistToSqr(tr.HitPos)
                        if d < closest then
                            closest = d
                            bone = i
                        end
                    end
                end
            end

            self:SetCarrying(tr.Entity, bone, tr.HitPos, dist)
            tr.Entity.Touched = true
            self:ApplyForce()
        end
    end
end

function SWEP:Reload() 
end

function SWEP:Deploy()
    return true
end

function SWEP:OnDrop()
    if self and IsValid(self) then
        self:Remove()
    end
end