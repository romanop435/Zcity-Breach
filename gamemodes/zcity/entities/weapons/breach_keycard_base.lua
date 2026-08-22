if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Ключ-карта (База)"
SWEP.Category = "NextOren"
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.WorldModel = "models/cultist/items/keycards/w_keycard.mdl"

SWEP.WorldModelReal = "models/cultist/items/keycards/v_keycard.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""

SWEP.CLevels = {
    CLevel = 0, CLevelSCI = 0, CLevelGuard = 0, CLevelMTF = 0, CLevelSUP = 0
}

SWEP.Skin = 0

SWEP.Primary.Wait = 0.8
SWEP.Primary.Next = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.WorkWithFake = true

SWEP.HoldType = "slam"
SWEP.setlh = false
SWEP.setrh = true



SWEP.HoldPos = Vector(0, 0, -4)
SWEP.HoldAng = Angle(0, 0, 0)


SWEP.AnimList = {
    ["deploy"] = {"draw", 0.75, false},
    ["insert"] = {"insert", 0.6, false},
    ["idle"]   = {"idle", 5, true}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    
    self.WMSkin = self.Skin
    self:SetSkin(self.Skin)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self.WMSkin = self.Skin
    self:SetSkin(self.Skin)
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    if SERVER then
        self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
    end

    return true
end


function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) and wm:GetSkin() ~= self.Skin then
        wm:SetSkin(self.Skin)
    end
end

function SWEP:ThinkAdd()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    
    if owner:KeyDown(IN_USE) and self:GetNextPrimaryFire() <= CurTime() then
        self:SetNextPrimaryFire(CurTime() + 0.6)
        self:PlayAnim("insert")
    end
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Wait)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:PlayAnim("insert")

    if SERVER then
        local tr = util.TraceLine({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * 85,
            filter = owner
        })

        if tr.Hit and IsValid(tr.Entity) then
            
            owner:ConCommand("+use")
            timer.Simple(0.25, function()
                if not IsValid(self) or not IsValid(owner) then return end
                owner:ConCommand("-use")
            end)
        end
    end
end

function SWEP:SecondaryAttack()
    return false
end