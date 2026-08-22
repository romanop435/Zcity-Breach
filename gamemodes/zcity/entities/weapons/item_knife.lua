if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Заточка"
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/srank.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/srank.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "knife"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/horizon/w_csgo_stiletto.mdl"
SWEP.WorldModelReal = "models/weapons/horizon/v_csgo_stiletto.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = false
SWEP.setrh = true
SWEP.UseHands = true


SWEP.HoldAng = Angle(0, 0, 20)
SWEP.HoldPos = Vector(-3, 2, -5)

SWEP.droppable = false
SWEP.UnDroppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HitSound = Sound("weapons/imbrokeru_knife/knife_hit3.wav")


SWEP.AnimList = {
    ["deploy"] = {"draw", 0.6, false},
    ["idle"] = {"idle1", 5, true},
    ["hit1"] = {"light_hit1", 0.6, false},
    ["hit2"] = {"light_hit2", 0.6, false},
    ["miss1"] = {"light_miss1", 0.6, false},
    ["miss2"] = {"light_miss2", 0.6, false}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    timer.Simple(0.1, function()
        if IsValid(self) and IsValid(self:GetOwner()) then
            self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
        end
    end)
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:ShouldDrawViewModel()
    return false
end

local trigger_box = Vector(20, 4, 32)

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNextPrimaryFire(CurTime() + 0.75)
    self:SetNextSecondaryFire(CurTime() + 0.75)

    owner:SetAnimation(PLAYER_ATTACK1)

    owner:LagCompensation(true)
    local tr = {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 130,
        filter = {self, owner},
        mins = -trigger_box,
        maxs = trigger_box
    }
    local trace = util.TraceHull(tr)
    owner:LagCompensation(false)

    local ent = trace.Entity

    
    if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
        local plyOwner = hg.RagdollOwner(ent) or ent:GetNWEntity("ply")
        if IsValid(plyOwner) and plyOwner:IsPlayer() then
            ent = plyOwner
        end
    end

    if IsValid(ent) and ent:IsPlayer() then
        
        self:PlayAnim(math.random(1, 2) == 1 and "hit1" or "hit2")

        if CLIENT then
            local fx = EffectData()
            fx:SetOrigin(trace.HitPos)
            fx:SetNormal(trace.HitNormal)
            fx:SetColor(BLOOD_COLOR_RED)
            util.Effect("BloodImpact", fx)
        end

        if SERVER then
            
            owner:EmitSound(self.HitSound, 75, 100, 1, CHAN_WEAPON)

            
            local dmginfo = DamageInfo()
            dmginfo:SetDamageType(DMG_SLASH)

            if ent:GTeam() ~= TEAM_SCP then
                dmginfo:SetDamage(ent:GetMaxHealth() * 2) 
            else
                dmginfo:SetDamage(50) 
            end

            dmginfo:SetDamageForce(owner:GetAimVector() * 3)
            dmginfo:SetAttacker(owner)
            dmginfo:SetInflictor(self)

            ent:TakeDamageInfo(dmginfo)

            
            if owner.RemoveItemClass then
                owner:RemoveItemClass(self:GetClass())
            end
            
            
            owner:SelectWeapon("br_holster") 
            self:Remove()
        end
    else
        
        self:PlayAnim(math.random(1, 2) == 1 and "miss1" or "miss2")
        if SERVER then
            owner:EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
        end
    end

    if SERVER then
        owner:ViewPunch(Angle(math.random(-2, 2), math.random(-2, 2), 0))
    end
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end