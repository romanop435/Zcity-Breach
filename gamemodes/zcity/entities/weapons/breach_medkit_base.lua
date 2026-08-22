if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Medkit Base"

SWEP.ProgressIcon = "nextoren/gui/new_icons/med_1.png"

if CLIENT then
    SWEP.InvIcon = Material(SWEP.ProgressIcon)
    SWEP.IconOverride = SWEP.ProgressIcon
end

SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/medkit/w_medkit.mdl"
SWEP.WorldModelReal = "models/cultist/items/medkit/v_medkit.mdl"
SWEP.WorldModelExchange = false

SWEP.HoldType = "heal"
SWEP.UseHands = true


SWEP.setlhik = true
SWEP.setrhik = true
SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(-5, 0, -5)

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

SWEP.Skin = 0
SWEP.HealPower = 1
SWEP.IsHealing = false

SWEP.AnimList = {
    ["deploy"] = {"deploy", 0.5, false},
    ["idle"] = {"idle", 5, true}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.IsHealing = false
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
    if self.IsHealing then return false end
    return true
end


function SWEP:ThinkAdd()
    if self.IsHealing then
        self.setlhik = false
        self.setrhik = false
    else
        self.setlhik = false
        self.setrhik = true
    end
end

function SWEP:MakeHealSound()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    for i = 1, 3 do
        timer.Create("Heal_Sound_"..i.."_"..owner:SteamID64(), 0.6 + (i - 1), 1, function()
            if IsValid(self) then
                self:EmitSound("nextoren/charactersounds/start_healing.wav", 100, 100, 1.25, CHAN_WEAPON)
            end
        end)
    end
end

function SWEP:StopHealSound()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    for i = 1, 3 do
        timer.Remove("Heal_Sound_"..i.."_"..owner:SteamID64())
    end
end

function SWEP:OnRemove()
    self:StopHealSound()
end

local function ApplyHomigradHeal(ply, power)
    if not IsValid(ply) or not ply.organism then return end
    
    local org = ply.organism

    org.pain = math.max(0, org.pain - (50 * power))
    org.painadd = math.max(0, org.painadd - (60 * power))
    org.avgpain = math.max(0, org.avgpain - (50 * power))
    org.shock = math.max(0, org.shock - (80 * power))

    org.adrenaline = math.max(0, org.adrenaline - (2 * power))
    org.adrenalineAdd = math.max(0, org.adrenalineAdd - (2 * power))

    org.blood = math.min(5000, org.blood + (1000 * power))
    
    org.wounds = {}
    org.arterialwounds = {}
    ply:SetNetVar("wounds", org.wounds)
    ply:SetNetVar("arterialwounds", org.arterialwounds)
    
    org.bleed = 0
    org.internalBleed = 0

    local boneHeal = 0.5 * power
    local bonesToHeal = {
        "lleg", "rleg", "larm", "rarm", 
        "spine1", "spine2", "spine3", 
        "pelvis", "chest", "skull", "jaw"
    }
    
    for _, bone in ipairs(bonesToHeal) do
        if org[bone] then
            org[bone] = math.max(0, org[bone] - boneHeal)
        end
    end

    if power >= 1.5 then
        org.llegdislocation = false
        org.rlegdislocation = false
        org.larmdislocation = false
        org.rarmdislocation = false
        org.jawdislocation = false
    end

    local healAmount = 30 * power
    ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + healAmount))
    ply.fullsend = true
end

function SWEP:Heal(target)
    local owner = self:GetOwner()
    if owner:IsFrozen() or owner:GetMoveType() ~= MOVETYPE_WALK then return end

    local animation
    local heal_time
    
    local pIcon = self.ProgressIcon or "nextoren/gui/new_icons/med_1.png" 

    if target then
        
        if target:Health() >= target:GetMaxHealth() and (not target.organism or target.organism.pain <= 0) then return end

        animation = "l4d_Heal_Friend_Standing"
        heal_time = select(2, owner:LookupSequence(animation))
        self.IsHealing = true

        owner:BrProgressBar("l:medkit_healing " .. target:GetNamesurvivor() .. "...", heal_time, pIcon, target, false, 
            function() 
                if not IsValid(self) then return end
                self.IsHealing = false
                self:SetHold(self.HoldType)

                ApplyHomigradHeal(target, self.HealPower)
                owner:AddToMVP("heal", 25 * self.HealPower)
                target:AnimatedHeal(target:GetMaxHealth() * (0.25 * self.HealPower))
                owner:SetNWEntity("NTF1Entity", NULL)

                if SERVER then
                    owner:RemoveItemClass(self:GetClass())
                    owner:SelectWeapon("br_holster")
                    self:Remove()
                end
            end, 
            function() 
                self:MakeHealSound() 
                owner:SetNWEntity("NTF1Entity", owner) 
                
                self:SetHold("normal") 
                owner:SetForcedAnimation(animation, heal_time) 
            end, 
            function() 
                self:StopHealSound() 
                owner:SetNWEntity("NTF1Entity", NULL) 
                owner:StopForcedAnimation() 
                if IsValid(self) then 
                    self.IsHealing = false 
                    self:SetHold(self.HoldType)
                end
            end
        )
    else
        
        if not owner:Crouching() then animation = "l4d_Heal_Self_Standing_06" else animation = "l4d_Heal_Self_Crouching" end

        self.IsHealing = true
        heal_time = select(2, owner:LookupSequence(animation))

        owner:BrProgressBar("l:medkit_healing", heal_time, pIcon, nil, false, 
            function() 
                if not IsValid(self) or not IsValid(owner) then return end
                self.IsHealing = false
                self:SetHold(self.HoldType)

                ApplyHomigradHeal(owner, self.HealPower)
                owner:AddToMVP("heal", 15 * self.HealPower)
                owner:AnimatedHeal(owner:GetMaxHealth() * (0.25 * self.HealPower))
                owner:SetNWEntity("NTF1Entity", NULL)
                
                if SERVER then
                    BREACH.Players:ChatPrint(owner, true, true, "l:medkit_heal_ended")
                    owner:RemoveItemClass(self:GetClass())
                    owner:SelectWeapon("br_holster")
                    self:Remove()
                end
            end, 
            function() 
                self:MakeHealSound() 
                owner:SetNWEntity("NTF1Entity", owner) 
                
                self:SetHold("normal") 
                owner:SetForcedAnimation(animation, heal_time) 
            end, 
            function() 
                self:StopHealSound() 
                owner:SetNWEntity("NTF1Entity", NULL) 
                owner:StopForcedAnimation() 
                if IsValid(self) then 
                    self.IsHealing = false 
                    self:SetHold(self.HoldType)
                end
            end
        )
    end
end

function SWEP:PrimaryAttack()
    if self.IsHealing then return end
    if self:GetNWEntity("NTF1Entity") == self:GetOwner() then return end
    self:SetNextPrimaryFire(CurTime() + 0.25)
    if CLIENT then return end

    local owner = self:GetOwner()
    if owner:GTeam() == TEAM_AR and not owner:GetNWBool('ChipedByAndersonRobotik', false) then
        owner:RXSENDNotify("Как вы собираетесь аптечкой вылечить робота?")
        return
    end

    self:Heal()
end

local maxs = Vector(8, 2, 18)

function SWEP:SecondaryAttack()
    if self.IsHealing then return end
    if self:GetNWEntity("NTF1Entity") == self:GetOwner() then return end
    self:SetNextSecondaryFire(CurTime() + 0.25)
    if CLIENT then return end

    local owner = self:GetOwner()
    local trace = {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 80,
        mask = MASK_SHOT,
        filter = {self, owner},
        maxs = maxs,
        mins = -maxs
    }

    local tr = util.TraceHull(trace)
    local target = tr.Entity

    if IsValid(target) and target:IsPlayer() and target:GTeam() ~= TEAM_SCP and target:GTeam() ~= TEAM_SPEC then
        if target:GTeam() == TEAM_AR and not target:GetNWBool('ChipedByAndersonRobotik', false) then
            owner:RXSENDNotify("Как вы собираетесь аптечкой вылечить робота?")
            return
        end
        self:Heal(target)
    end
end

function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) and wm:GetSkin() ~= self.Skin then
        wm:SetSkin(self.Skin)
    end
end