if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "SCP-294"
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/scp294.png", "noclamp smooth")
    SWEP.IconOverride = "nextoren/gui/new_icons/scp294.png"
    SWEP.BounceWeaponIcon = false

    
    function draw.Circle(x, y, radius, seg)
        local cir = {}
        table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })

        for i = 0, seg do
            local a = math.rad((i / seg) * -360)
            table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
        end

        local a = math.rad(0) 
        table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
        surface.DrawPoly(cir)
    end
end

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/vinrax/props/cup_294.mdl"
SWEP.WorldModelReal = "models/shaky/items/scp/scp294/v_scp294.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = false
SWEP.setrh = true
SWEP.UseHands = true


SWEP.HoldAng = Angle(15, 0, 0)
SWEP.HoldPos = Vector(0, 0, 0)

SWEP.droppable = true
SWEP.BlockDrag = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsDrinking = false

local siptosound = {
    [1] = "ahh",
    [2] = "beurk",
    [3] = "burn",
    [4] = "cough",
    [5] = "slurp",
    [6] = "spit",
}

local viewpunch_angle = Angle(-15, 0, 0)

SWEP.AnimList = {
    ["deploy"] = {"deploy", 0.5, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"use", 1.5, false, false, function(self)
        
        self.IsDrinking = false
        if SERVER then
            local owner = self:GetOwner()
            if IsValid(owner) then
                owner:SelectWeapon("br_holster")
            end
            self:Remove()
        end
    end}
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
    
    if SERVER then
        self:AddEFlags(EFL_NO_DAMAGE_FORCES)
    end
end

function SWEP:Deploy()
    self.Initialzed = true
    self.IsDrinking = false
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
    if self.IsDrinking then return false end
    return true
end

function SWEP:OnRemove()
    local wepID = self:EntIndex()
    timer.Remove("SCP294Punch_" .. wepID)
    timer.Remove("SCP294Drink_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsDrinking then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsDrinking = true
    self:SetNextPrimaryFire(CurTime() + 4)

    self:PlayAnim("use")

    if SERVER then
        local sipSound = siptosound[self.sip or 5] or "slurp"
        owner:EmitSound("scp294/" .. sipSound .. ".ogg")
    end

    local wepID = self:EntIndex()

    
    timer.Create("SCP294Punch_" .. wepID, 0.5, 1, function()
        if IsValid(self) and IsValid(owner) then
            if SERVER then owner:ViewPunch(viewpunch_angle) end
        end
    end)

    
    timer.Create("SCP294Drink_" .. wepID, 1.0, 1, function()
        if not IsValid(self) or not IsValid(owner) then return end

        if SERVER then
            
            if owner.RemoveItemClass then
                owner:RemoveItemClass(self:GetClass())
            end

            
            if self.effect then
                self.effect(owner, self.SCP294)
            end
        end
    end)
end

function SWEP:SecondaryAttack()
    return false
end


function SWEP:Equip(owner)
    if self.drink == "tnt" then
        if owner.CompleteAchievement then
            owner:CompleteAchievement("tnt")
        end

        local current_pos = self:GetPos()
        self.abouttoexplode = nil
        self.burnttodeath = true

        local dmg_info = DamageInfo()
        dmg_info:SetDamage(2000)
        dmg_info:SetDamageType(DMG_BLAST)
        dmg_info:SetAttacker(owner)
        dmg_info:SetDamageForce(-owner:GetAimVector() * 40)

        util.BlastDamageInfo(dmg_info, self:GetPos(), 400)

        sound.Play("nextoren/others/explosion_ambient_" .. math.random(1, 2) .. ".ogg", current_pos, 100, 100, 100)

        net.Start("CreateParticleAtPos")
        net.WriteString("pillardust")
        net.WriteVector(current_pos)
        net.Broadcast()

        net.Start("CreateParticleAtPos")
        net.WriteString("gas_explosion_main")
        net.WriteVector(current_pos)
        net.Broadcast()
        
        self:Remove()
    end
end

function SWEP:OnTakeDamage(dmginfo)
    if self.drink == "tnt" then
        local attacker = dmginfo:GetAttacker()
        
        if IsValid(attacker) and attacker:IsPlayer() and attacker.CompleteAchievement then
            attacker:CompleteAchievement("tnt")
        end

        local current_pos = self:GetPos()
        self.abouttoexplode = nil
        self.burnttodeath = true

        local dmg_info = DamageInfo()
        dmg_info:SetDamage(2000)
        dmg_info:SetDamageType(DMG_BLAST)
        dmg_info:SetAttacker(attacker)
        dmg_info:SetDamageForce(Vector(0, 0, 1) * 40)

        util.BlastDamageInfo(dmg_info, self:GetPos(), 400)

        sound.Play("nextoren/others/explosion_ambient_" .. math.random(1, 2) .. ".ogg", current_pos, 100, 100, 100)

        net.Start("CreateParticleAtPos")
        net.WriteString("pillardust")
        net.WriteVector(current_pos)
        net.Broadcast()

        net.Start("CreateParticleAtPos")
        net.WriteString("gas_explosion_main")
        net.WriteVector(current_pos)
        net.Broadcast()
    end

    self:Remove()
end




if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "DrawSCP294Liquid", function()
        
        for _, ply in player.Iterator() do
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "item_drink_294" then
                local wm = wep:GetWM()
                if IsValid(wm) and not wm:GetNoDraw() and not wm.IsHiddenCustom then
                    
                    local pos = wm:GetRenderOrigin() or wm:GetPos()
                    local ang = wm:GetRenderAngles() or wm:GetAngles()

                    local col = Color(wep:GetNWInt("r", 255), wep:GetNWInt("g", 255), wep:GetNWInt("b", 255))
                    local draw_pos = pos + ang:Up() * 3.2

                    cam.Start3D2D(draw_pos, ang, 1)
                        surface.SetDrawColor(col)
                        draw.NoTexture()
                        draw.Circle(0, 0, 2, 20)
                    cam.End3D2D()
                end
            end
        end
        
        
        for _, wep in ipairs(ents.FindByClass("item_drink_294")) do
            if not IsValid(wep:GetOwner()) then
                local pos = wep:GetPos()
                local ang = wep:GetAngles()
                local col = Color(wep:GetNWInt("r", 255), wep:GetNWInt("g", 255), wep:GetNWInt("b", 255))
                
                local draw_pos = pos + ang:Up() * 3.2

                cam.Start3D2D(draw_pos, ang, 1)
                    surface.SetDrawColor(col)
                    draw.NoTexture()
                    draw.Circle(0, 0, 2, 20)
                cam.End3D2D()
            end
        end
    end)
end