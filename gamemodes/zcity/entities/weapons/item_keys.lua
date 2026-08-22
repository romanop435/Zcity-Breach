if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Ключи от машины"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/car_keys.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/car_keys.png"
    SWEP.Desc = "Позволяет отпирать закрытый транспорт."
end

SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/carkeys/w_key.mdl"
SWEP.WorldModelReal = "models/weapons/carkeys/c_key.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = false
SWEP.setrh = true


SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(2, -2, -8)

SWEP.droppable = true
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.AnimList = {
    ["deploy"] = {"draw", 0.5, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"primaryattack", 1.0, false} 
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        local sid = owner:SteamID64()
        if sid then
            timer.Remove("Key_Sound_" .. sid)
            timer.Remove("Key_Sound2_" .. sid)
        end
    end
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNextPrimaryFire(CurTime() + 2.5)

    local tr = owner:GetEyeTrace()
    local ent = tr.Entity

    
    if IsValid(ent) and owner:GetPos():DistToSqr(ent:GetPos()) > 40000 then return end

    if IsValid(ent) and ent:IsVehicle() and ent.Locked then
        self:PlayAnim("use")

        if SERVER then
            owner:BrProgressBar("l:opening_car_door", 2, "nextoren/gui/new_icons/car_keys.png", ent, false, 
                function() 
                    if not IsValid(ent) then return end
                    ent.Locked = false
                    sound.Play("nextoren/vehicle/car_unlocked.wav", ent:GetPos())
                end, 
                function() 
                    local sid = owner:SteamID64()
                    
                    timer.Create("Key_Sound_" .. sid, 0, 1, function()
                        if IsValid(self) and IsValid(owner) then
                            self:EmitSound("nextoren/vehicle/car_unlocking.wav")
                        end
                    end)
                    
                    timer.Create("Key_Sound2_" .. sid, 1.0, 1, function()
                        if IsValid(self) and IsValid(owner) then
                            self:EmitSound("nextoren/vehicle/car_unlocking.wav")
                        end
                    end)
                end, 
                function() 
                    local sid = owner:SteamID64()
                    timer.Remove("Key_Sound_" .. sid)
                    timer.Remove("Key_Sound2_" .. sid)
                end
            )
        end
    else
        
        self:SetNextPrimaryFire(CurTime() + 0.5)
    end
end

function SWEP:SecondaryAttack()
    return false
end