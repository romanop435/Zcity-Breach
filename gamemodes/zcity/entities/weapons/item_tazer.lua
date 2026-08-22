if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Электрошокер"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/taser_small.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/taser_small.png"
end


SWEP.HoldType = "pistol" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/taser/w_taser_small.mdl"
SWEP.WorldModelReal = "models/weapons/shaky/breach_items/tazer/v_tazer.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = false
SWEP.setrh = true


SWEP.HoldAng = Angle(0, 30, 30)
SWEP.HoldPos = Vector(0, 15, -5)

SWEP.droppable = true
SWEP.UseHands = true

SWEP.Primary.ClipSize = 1000
SWEP.Primary.DefaultClip = 1000 
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.AnimList = {
    ["deploy"] = {"draw", 0.75, false},
    ["idle"] = {"idle", 5, true},
    ["attack"] = {"attack", 1.1, false}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")

    if SERVER then
        local filter = RecipientFilter()
        filter:AddAllPlayers()
        self.tazersound = CreateSound(self, "weapons/tazer_sound.wav", filter)
        self.tazersound:Stop()
    end
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    timer.Simple(0.25, function()
        if IsValid(self) and IsValid(self:GetOwner()) then
            self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
        end
    end)

    return true
end

function SWEP:Holster()
    return true
end

function SWEP:OnDrop()
    if self and IsValid(self) and self.tazersound then
        self.tazersound:Stop()
    end
end

function SWEP:OnRemove()
    if self and IsValid(self) and self.tazersound then
        self.tazersound:Stop()
    end
end

if CLIENT then
    function SWEP:CreateMuzzle(hitpos)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.r = 10
            dlight.g = 0
            dlight.b = 180
            dlight.brightness = 6
            dlight.pos = hitpos + owner:GetAimVector() * 3
            dlight.size = 128
            dlight.decay = 128
            dlight.dietime = CurTime() + 2
        end
    end
end

local maxs = Vector(8, 10, 5)

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    
    if self:Clip1() <= 0 then
        if SERVER then
            if owner.BrTip then
                owner:BrTip(0, "[ZCity Breach]", Color(255, 0, 0, 210), "Вы не можете использовать Электрошокер, ибо заряд закончился.", color_white)
            else
                owner:ChatPrint("Заряд электрошокера закончился.")
            end
        end
        self:SetNextPrimaryFire(CurTime() + 2.5)
        return
    end

    local imba = 65 
    
    
    local filterEnts = {self, owner}
    if IsValid(owner.FakeRagdoll) then table.insert(filterEnts, owner.FakeRagdoll) end

    local tr = {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * imba,
        filter = filterEnts,
        mins = -maxs,
        maxs = maxs
    }

    local trace = util.TraceHull(tr)
    local ent = trace.Entity
    local pos = trace.HitPos

    
    if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
        local plyOwner = hg.RagdollOwner(ent) or ent:GetNWEntity("ply")
        if IsValid(plyOwner) and plyOwner:IsPlayer() then
            ent = plyOwner
        end
    end

    
    if IsValid(ent) and ent:IsPlayer() and (ent:GTeam() ~= TEAM_SCP or owner:IsSuperAdmin()) then
        
        self:SetNextPrimaryFire(CurTime() + 2.5)
        self:SetClip1(self:Clip1() - 1)
        owner:SetNWInt("TaizerCount", math.max(0, owner:GetNWInt("TaizerCount", 0) - 1))

        self:PlayAnim("attack")

        if CLIENT then
            self:CreateMuzzle(pos)
        end

        if SERVER then
            ent:ScreenFade(SCREENFADE.IN, color_white, 0.1, 2)
            
            
            ent:Freeze(true)

            if IsValid(ent.ProgibTarget) then
                ent.ProgibTarget:StopForcedAnimation()
                ent.ProgibTarget.ProgibTarget = nil
                ent:StopForcedAnimation()
                ent.ProgibTarget = nil
            end

            if self.tazersound then
                self.tazersound:Play()
            end

            
            if ent:GTeam() == TEAM_AR then
                ent:SetForcedAnimation("0_SCP_542_lifedrain", 1, function() end, function()
                    if IsValid(ent) then ent:Kill() end
                end, nil)
            else
                
                local sndPath
                if ent.IsFemale and ent:IsFemale() then
                    sndPath = "nextoren/charactersounds/hurtsounds/sfemale/hurt_" .. math.random(1, 66) .. ".mp3"
                else
                    sndPath = "nextoren/charactersounds/hurtsounds/male/hurt_" .. math.random(1, 39) .. ".wav"
                end

                local snd = CreateSound(ent, sndPath)
                if snd then
                    snd:SetDSP(17)
                    snd:Play()
                end
            end

            timer.Simple(0.4, function()
                if IsValid(self) and self.tazersound then
                    self.tazersound:Stop()
                end
            end)

            timer.Create("ZAP_SHOCKER_" .. ent:SteamID64(), 2, 1, function()
                if IsValid(ent) then
                    if not IsValid(ent.ProgibTarget) then
                        ent:Freeze(false)
                    end
                    ent:StopParticles()
                end
            end)

            local org = ent.organism
            if org then
                org.painadd = org.painadd + 5 -- Дикая нарастающая боль
                org.shock = org.shock + 3     -- Мгновенный шок, вызывающий отключку
            end

            
            local zap = ents.Create("point_tesla")
            if IsValid(zap) then
                zap:SetKeyValue("targetname", "teslab")
                zap:SetKeyValue("m_SoundName", "")
                zap:SetKeyValue("texture", "sprites/physbeam.spr")
                zap:SetKeyValue("m_Color", "210 200 255")
                zap:SetKeyValue("m_flRadius", "15")
                zap:SetKeyValue("beamcount_min", "1")
                zap:SetKeyValue("beamcount_max", "2")
                zap:SetKeyValue("thick_min", ".1")
                zap:SetKeyValue("thick_max", ".2")
                zap:SetKeyValue("lifetime_min", ".01")
                zap:SetKeyValue("lifetime_max", ".1")
                zap:SetKeyValue("interval_min", ".01")
                zap:SetKeyValue("interval_max", ".05")
                zap:SetPos(owner:GetShootPos() + owner:GetAimVector() * 40 + owner:GetRight() * 5 - owner:GetUp() * 4)
                zap:Spawn()
                zap:Fire("DoSpark", "", 0)
                zap:Fire("kill", "", 0.1)
            end
        end
    else
        
        self:SetNextPrimaryFire(CurTime() + 0.5)
    end
end

function SWEP:SecondaryAttack()
    return false
end