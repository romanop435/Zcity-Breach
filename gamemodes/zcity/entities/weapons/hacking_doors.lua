if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Устройство для взлома"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = true

if CLIENT then
    SWEP.WepSelectIcon = Material("nextoren/gui/new_icons/hacker_hack.png")
    SWEP.InvIcon = Material("nextoren/gui/new_icons/hacker_hack.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/hacker_hack.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/hacker_crack/w_hacker_hack.mdl"
SWEP.WorldModelReal = "models/cultist/items/hacker_crack/v_hacker_hack.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.WorkWithFake = true


SWEP.setlh = true
SWEP.setrh = true
SWEP.UseHands = true


SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(-8, 5, -1)

SWEP.droppable = false
SWEP.UnDroppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.LockPickTime = 60

SWEP.AnimList = {
    ["deploy"] = {"draw", 0.8, false},
    ["idle"] = {"idle1", 5, true},
    ["start_pressing"] = {"start_pressing", 0.5, false},
    ["pressing"] = {"pressing", 1, true},
    ["end_pressing"] = {"end_pressing", 0.5, false}
}

local BannedDoors = {
    [3667] = true,
    [3762] = true,
    [4675] = true,
    [4403] = true
}

local BannedDoors2 = {
    [4574] = true
}

local customtimedoors = {
    { button = Vector(9983.000000, -3292.000000, 54.299999), time = 100/2 },
    { button = Vector(302.399994, -4156.640137, -1196.000000), time = 110/2 }
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)
    self.Hacking = false
    self.OldHacking = false
    
    return true
end

function SWEP:Holster()
    
    return true
end

function SWEP:PrimaryAttack()
    if (self.NextTry or 0) >= CurTime() then return end
    self.NextTry = CurTime() + 1

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local tr = owner:GetEyeTrace()
    local ent = tr.Entity

    if IsValid(ent) and ent:GetClass() == "func_button" then
        if CLIENT then return end
        owner:ConCommand("new_hacker_panel")
    end
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end

if SERVER then
    net.Receive("SendHack", function(len, ply)
        local id = net.ReadInt(16)
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "hacking_doors" then return end

        if timer.Exists("HackerCD" .. ply:SteamID64()) then return end
        timer.Create("HackerCD" .. ply:SteamID64(), 5, 1, function() end)
        
        wep.NextTry = CurTime() + 1

        local tr = ply:GetEyeTrace()
        local time
        local ent = tr.Entity

        if IsValid(ent) and ent:GetClass() == "func_button" then

            wep:PlayAnim("start_pressing")
            
            
            timer.Simple(0.5, function()
                if IsValid(wep) and ply:GetActiveWeapon() == wep then
                    wep:PlayAnim("pressing")
                    wep.Hacking = true
                end
            end)

            if ent:GetInternalVariable("m_iName"):find("checkpoint") or BannedDoors[ent:MapCreationID()] then
                time = 55
            elseif BannedDoors2[ent:MapCreationID()] then
                time = 80
            else
                time = 25
            end

            
            if ent:GetPos() == Vector(7704, -3967, 54.3) then time = 180 end
            if ent:GetPos() == Vector(7784, -4160.59, 54.3) then time = 180 end
            if ent:GetPos() == Vector(7048, -2095, 54.3) then time = 180 end
            if ent:GetPos() == Vector(6632, -2303, 54.3) then time = 180 end
            if ent:GetPos() == Vector(6226.01, -2041, 54.41) then time = 180 end
            if ent:GetPos() == Vector(6171, -2320.99, 53.41) then time = 180 end
            if ent:GetPos() == Vector(8264, -4451.59, 54.99) then time = 180 end

            for _, tab in ipairs(customtimedoors) do
                if ent:GetPos() == tab.button then
                    time = tab.time
                    break
                end
            end

            local chance = 100
            if id == 1 then
                time = time * 0.2
                chance = 10
            elseif id == 2 then
                time = time * 0.4
                chance = 30
            elseif id == 3 then
                time = time * 0.6
                chance = 50
            elseif id == 4 then
                time = time * 0.8
                chance = 70
            elseif id == 5 then
                chance = 101
            end

            ply:BrProgressBar("l:hacking_door", time, "nextoren/gui/new_icons/hacker_hack.png", ent, false, 
                function() 
                    if not IsValid(wep) then return end
                    wep.Hacking = false
                    wep:PlayAnim("end_pressing")

                    if math.random(1, 100) > chance then
                        ply:EmitSound("nextoren/others/access_denied.wav")
                    else
                        ply:EmitSound("nextoren/others/chaos_radio_open.wav")
                        timer.Simple(3, function()
                            if IsValid(ent) then
                                ent:Fire("use")
                            end
                        end)
                    end
                end, 
                function() 
                    ply:EmitSound("nextoren/others/hacker/scanning01.wav")
                end, 
                function() 
                    if IsValid(wep) then
                        wep.Hacking = false
                        wep:PlayAnim("end_pressing")
                    end
                end
            )
        end
    end)
end