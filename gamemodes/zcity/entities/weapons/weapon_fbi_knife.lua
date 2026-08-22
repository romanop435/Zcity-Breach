if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Керамбит : Сын Педро"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/weapons/fbi_knife.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/weapons/fbi_knife.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "knife"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/humans/fbi/weapons/knife/w_knife_fbi.mdl"
SWEP.WorldModelReal = "models/cultist/humans/fbi/weapons/knife/v_knife_fbi.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = false
SWEP.setrh = true


SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(0, 3, -5)

SWEP.droppable = false
SWEP.UnDroppable = true
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"


SWEP.AnimList = {
    ["deploy"] = {"draw", 0.65, false},
    ["idle"] = {"idle1", 5, true},
    ["miss_light1"] = {"light_miss1", 0.8, false},
    ["miss_light2"] = {"light_miss2", 0.8, false},
    ["hit_light1"] = {"light_hit1", 0.8, false},
    ["hit_light2"] = {"light_hit2", 0.8, false},
    ["miss_heavy"] = {"heavy_miss1", 1.25, false},
    ["hit_heavy"] = {"heavy_hit1", 1.25, false}
}

sound.Add({
    name = "csgo_knife.Deploy",
    channel = CHAN_WEAPON,
    volume = .8,
    level = 66,
    pitch = { 100, 105 },
    sound = {
        "weapons/fbi_knife/knife_deploy_1.wav",
        "weapons/fbi_knife/knife_deploy_2.wav",
        "weapons/fbi_knife/knife_deploy_3.wav",
        "weapons/fbi_knife/knife_deploy_4.wav",
        "weapons/fbi_knife/knife_deploy_5.wav",
        "weapons/fbi_knife/knife_deploy_6.wav"
    }
})

sound.Add({
    name = "fbi_knife.slash",
    channel = CHAN_WEAPON,
    volume = .8,
    level = 90,
    pitch = { 100, 105 },
    sound = {
        "weapons/fbi_knife/knife_stab_1.wav",
        "weapons/fbi_knife/knife_stab_2.wav",
        "weapons/fbi_knife/knife_stab_3.wav",
        "weapons/fbi_knife/knife_stab_4.wav"
    }
})

sound.Add({
    name = "fbi_knife.hit",
    channel = CHAN_WEAPON,
    volume = .9,
    level = 90,
    pitch = { 100, 105 },
    sound = {
        "weapons/fbi_knife/knife_hit_1.wav",
        "weapons/fbi_knife/knife_hit_2.wav",
        "weapons/fbi_knife/knife_hit_3.wav",
        "weapons/fbi_knife/knife_hit_4.wav",
        "weapons/fbi_knife/knife_hit_5.wav",
        "weapons/fbi_knife/knife_hit_6.wav",
        "weapons/fbi_knife/knife_hit_7.wav",
        "weapons/fbi_knife/knife_hit_8.wav",
        "weapons/fbi_knife/knife_hit_9.wav",
        "weapons/fbi_knife/knife_hit_10.wav"
    }
})

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)
    self:EmitSound("csgo_knife.Deploy")
    return true
end

function SWEP:Holster()
    return true
end

local prim_mins, prim_maxs = Vector(-16, -4, -32), Vector(16, 4, 32)
local hitDistance = 75 

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNextPrimaryFire(CurTime() + 0.8)
    owner:SetAnimation(PLAYER_ATTACK1)

    owner:LagCompensation(true)
    local tr = {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * hitDistance,
        filter = {self, owner},
        mins = prim_mins,
        maxs = prim_maxs
    }
    local trace = util.TraceHull(tr)
    owner:LagCompensation(false)

    local ent = trace.Entity

    if IsValid(ent) and ent:IsPlayer() then
        self:EmitSound("fbi_knife.hit")
        self:PlayAnim(math.random(1, 2) == 1 and "hit_light1" or "hit_light2")

        if SERVER then
            local damage_info = DamageInfo()
            if ent:GTeam() ~= TEAM_SCP then
                damage_info:SetDamage(ent:GetMaxHealth())
                damage_info:SetDamageForce(math.min(300, 50) * 80 * owner:GetAimVector())
            else
                damage_info:SetDamage(ent:GetMaxHealth() * 0.1)
                damage_info:SetDamageForce(owner:GetAimVector() * 4)
            end
            damage_info:SetInflictor(self)
            damage_info:SetAttacker(owner)
            damage_info:SetDamageType(DMG_SLASH)
            damage_info:SetDamagePosition(trace.HitPos)

            ent:TakeDamageInfo(damage_info)
        end

        local effectData = EffectData()
        effectData:SetOrigin(trace.HitPos)
        effectData:SetEntity(ent)
        util.Effect("BloodImpact", effectData)
    else
        self:EmitSound("fbi_knife.slash")
        self:PlayAnim(math.random(1, 2) == 1 and "miss_light1" or "miss_light2")
    end

    if SERVER then
        owner:ViewPunch(Angle(math.random(-5, 5), math.random(-2, 2), math.random(-2, 2)))
    end
end

function SWEP:SecondaryAttack()
    if self:GetNextSecondaryFire() > CurTime() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNextSecondaryFire(CurTime() + 1.25)
    self:SetNextPrimaryFire(CurTime() + 1.25)
    owner:SetAnimation(PLAYER_ATTACK1)

    owner:LagCompensation(true)
    local tr = {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * hitDistance,
        filter = {self, owner},
        mins = prim_mins,
        maxs = prim_maxs
    }
    local trace = util.TraceHull(tr)
    owner:LagCompensation(false)

    local ent = trace.Entity

    if IsValid(ent) and ent:IsPlayer() then
        self:EmitSound("fbi_knife.hit")
        self:PlayAnim("hit_heavy")

        if SERVER then
            local damage_info = DamageInfo()
            if ent:GTeam() ~= TEAM_SCP then
                damage_info:SetDamage(ent:GetMaxHealth() * 1.25)
                damage_info:SetDamageForce(math.min(300, 50) * 80 * owner:GetAimVector())
            else
                damage_info:SetDamage(ent:GetMaxHealth() * 0.1)
                damage_info:SetDamageForce(owner:GetAimVector() * 5)
            end
            damage_info:SetInflictor(self)
            damage_info:SetAttacker(owner)
            damage_info:SetDamageType(DMG_SLASH)
            damage_info:SetDamagePosition(trace.HitPos)

            ent:TakeDamageInfo(damage_info)
        end

        local effectData = EffectData()
        effectData:SetOrigin(trace.HitPos)
        effectData:SetEntity(ent)
        util.Effect("BloodImpact", effectData)
    else
        self:EmitSound("fbi_knife.slash")
        self:PlayAnim("miss_heavy")
    end

    if SERVER then
        owner:ViewPunch(Angle(math.random(-10, 10), math.random(-5, 5), 0))
    end
end