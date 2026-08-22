if SERVER then AddCSLuaFile() end




if CLIENT then
    net.Receive("SetFrequency", function(len)
        local wep = net.ReadEntity()
        local freq = net.ReadFloat()

        if IsValid(wep) then
            wep.Channel = math.Round(freq, 1)
            if wep.SetKeyRedact then
                wep:SetKeyRedact(false)
            end
        end
    end)
elseif SERVER then
    util.AddNetworkString("SetFrequency")
    util.AddNetworkString("RadioHooks")
    util.AddNetworkString("GetRadioChannel")

    net.Receive("SetFrequency", function(len, ply)
        local wep = net.ReadEntity()
        local freq = net.ReadFloat()

        if IsValid(wep) then
            freq = tonumber(string.sub(tostring(freq), 1, 5))
            wep.Channel = freq

            if wep.SetKeyRedact then
                wep:SetKeyRedact(false)
            end
        end
    end)

    hook.Add("PlayerButtonDown", "Radio_TriggerOn", function(caller, button)
        if caller:GTeam() == TEAM_SPEC or caller:GTeam() == TEAM_SCP then return end
        if not caller:HasWeapon("item_radio") then return end
        if caller:IsFrozen() or caller:GetMoveType() ~= MOVETYPE_WALK then return end

        
        
        
        
        
        
        
    end)
end

sound.Add({
    name = "radio.toggle",
    channel = CHAN_WEAPON,
    pitch = { 100, 105 },
    volume = .35,
    sound = "weapons/radio/radio_on.wav"
})




SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Рация"
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.HoldType = "slam" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/danradio/w_radio.mdl"
SWEP.WorldModelReal = "models/cultist/items/danradio/c_radio.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true


SWEP.HoldPos = Vector(2, -4, -2)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.droppable = true
SWEP.Equipableitem = true
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

SWEP.Channel = 100.1
SWEP.Skin = 0

if CLIENT then
    SWEP.BounceWeaponIcon = false
    SWEP.InvIcon = Material("nextoren/gui/new_icons/radio.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/radio.png"
    SWEP.TextureBin = surface.GetTextureID("effects/combine_binocoverlay")
    
    surface.CreateFont("RadioOFFONFont", {
        font = "brradiofont",
        extended = false,
        size = 36,
        weight = 200,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
end

SWEP.AnimList = {
    ["deploy"] = {"draw", 1.2, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"use", 1, false},
    ["unuse"] = {"unuse", 1, false}
}

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Bool", 1, "Redacting")
    self:NetworkVar("Bool", 2, "KeyRedact")

    if SERVER then
        self:SetEnabled(false)
        self:SetKeyRedact(false)
        self:SetRedacting(false)
    end
end

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
end

function SWEP:Equip(new_owner)
    if SERVER then
        net.Start("RadioHooks")
        net.Send(new_owner)
    end
end

function SWEP:Deploy()
    self.Initialzed = true
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)
    
    if self:GetSkin() ~= 0 then
        self:SetSkin(0)
    end

    return true
end

function SWEP:Holster()
    if IsFirstTimePredicted() then
        self:SetKeyRedact(false)
        self:SetRedacting(false)
    end
    return true
end

function SWEP:PrimaryAttack()
    if true then return end
    if not self:GetEnabled() then return end

    self:SetNextPrimaryFire(CurTime() + 0.25)

    if CLIENT then return end

    self:ToggleKeyRedact()
end

function SWEP:Reload()
    if (self.NextCheck or 0) > CurTime() then return end
    if true then return end

    if not self:GetRedacting() then
        self.NextCheck = CurTime() + 1

        self:SetRedacting(true)

        if CLIENT then
            BREACH.Player:ChatPrint(true, true, "l:radio_edit_info")
        end

        self:PlayAnim("use")
    else
        self.NextCheck = CurTime() + 1

        self:SetRedacting(false)

        self:PlayAnim("unuse")
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 2.25)
    if true then return end

    if SERVER then
        if not self:GetEnabled() then
            self:GetOwner():EmitSound("radio.toggle")
        end
        self:SetEnabled(not self:GetEnabled())
    end
end

if SERVER then
    function SWEP:ToggleKeyRedact()
        self:SetKeyRedact(not self:GetKeyRedact())
    end
end




if CLIENT then
    function SWEP:DrawPostWorldModel()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local wm = self:GetWM()
        if not IsValid(wm) then return end

        
        
        local boneIndex = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneIndex then return end

        local matrix = owner:GetBoneMatrix(boneIndex)
        if not matrix then return end

        local BonePos = matrix:GetTranslation()
        local BoneAng = matrix:GetAngles()

        local TextPos = BonePos + BoneAng:Forward() * 4.9 + BoneAng:Right() * 2.66 + BoneAng:Up() * -2.89
        local TextAngle = BoneAng

        TextAngle:RotateAroundAxis(TextAngle:Right(), 191)
        TextAngle:RotateAroundAxis(TextAngle:Up(), -3.1)
        TextAngle:RotateAroundAxis(TextAngle:Forward(), 90)

        cam.Start3D2D(TextPos, TextAngle, 0.01)
            if self:GetEnabled() then
                surface.SetDrawColor(0, 0, 255, 100)
                surface.DrawRect(0, 0, 145, 58)

                surface.SetDrawColor(0, 0, 255)
                surface.SetTexture(self.TextureBin)
                surface.DrawTexturedRect(0, 0, 145, 58)

                local clr
                local txt

                if self:GetKeyRedact() then
                    clr = redact_clr or color_white 
                    txt = self.Channel_Key or self.Channel
                else
                    clr = color_white
                    txt = self.Channel
                end

                draw.SimpleText("Hz: " .. tostring(txt), "ImpactSmall", 12, 10, clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            end
        cam.End3D2D()
    end
end