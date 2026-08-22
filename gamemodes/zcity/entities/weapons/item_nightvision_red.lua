if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Тепловизор"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/pnv_red.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/pnv_red.png"
end

SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/imperator/items/nightvision/w_night_vision_red.mdl"
SWEP.WorldModelReal = "models/imperator/items/nightvision/v_night_vision_red.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.WorkWithFake = true

SWEP.setlh = true
SWEP.setrh = true

SWEP.HoldAng = Angle(0, -10, 0)
SWEP.HoldPos = Vector(0, 0, -5)

SWEP.droppable = true
SWEP.teams = {2,3,4,6}

SWEP.Primary.Wait = 1.0
SWEP.Primary.Next = 0
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 5
SWEP.Secondary.DefaultClip = 5
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CallbackTimeAdjust = 0
SWEP.showstats = false

local matName = "pnv_invisible_mat_fixed"
if CLIENT then
    CreateMaterial(matName, "VertexLitGeneric", {
        ["$no_draw"] = "1"
    })
end

SWEP.AnimList = {
    ["deploy"] = {"deploy", 0.5, false},
    ["puton"] = {"puton", 1.5, false, false, function(self)
        self.IsToggling = false
    end},
    ["putoff"] = {"putoff", 0.75, false, false, function(self)
        self.IsToggling = false
    end},
    ["idle"] = {"idle", 5, true}
}

local banned_models = {
    --["models/cultist/humans/sci/hazmat_2.mdl"] = true,
    --["models/cultist/humans/sci/hazmat_1.mdl"] = true,
    --["models/cultist/humans/goc/goc.mdl"] = true,
    --["models/cultist/humans/class_d/class_d_fat_new.mdl"] = true
}

local function NormalizePath(path)
    if not path then return "" end
    return path:lower():gsub("\\", "/")
end

local function HasEquippedNVG(ply)
    if not IsValid(ply) then return false end
    
    if ply.LookupBonemerges then
        for _, ent in ipairs(ply:LookupBonemerges("ent_bonemerged")) do
            if IsValid(ent) then
                local model = ent:GetModel() or ""
                if model:lower():find("models/imperator/items/nightvision/bonemerge_nvg_forface_", 1, true) then
                    return true, ent
                end
            end
        end
    end

    return false
end

local function CheckEquip(player)
    if SERVER then
        return not IsValid(player.NVG_Bonemerged)
    else
        return not HasEquippedNVG(player)
    end
end

function SWEP:IsNightvisionActive()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    
    if SERVER then
        return IsValid(owner.NVG_Bonemerged)
    else
        return HasEquippedNVG(owner)
    end
end

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self.setlh = true
    self.setrh = true
end

function SWEP:Deploy()
    self.IsToggling = false
    self.Initialzed = true

    local active = self:IsNightvisionActive()

    if not active then
        self:PlayAnim("deploy")
        self.setlh = true
        self.setrh = true
    else
        self.setlh = false
        self.setrh = false
    end
    
    self:SetHold(self.HoldType)
    return true
end

function SWEP:Holster()
    if self.IsToggling then return false end
    return true
end

function SWEP:OnRemove()
    local wepID = self:EntIndex()
    timer.Remove("NVGToggle_" .. wepID)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsToggling then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local active = self:IsNightvisionActive()

    if not active and not CheckEquip(owner) then
        if CLIENT then
            BREACH.Player:ChatPrint(true, true, "l:take_off_nvg_first")
        end
        self:SetNextPrimaryFire(CurTime() + 1)
        return
    end

    self.IsToggling = true
    local wepID = self:EntIndex()
    if owner:GetModel():find('hazmat') then 
        if SERVER then
		owner:BrTip( 0, "[ПНВ]", Color(255, 0, 0), "Я не могу одеть пнв по верх хазмата", Color(255, 255, 255) )
        end
		return 
	end
    if not active then
        self:SetNextPrimaryFire(CurTime() + 2)
        self:PlayAnim("puton", 1.5)
        
        timer.Create("NVGToggle_" .. wepID, 1.2, 1, function()
            if IsValid(self) then
                if SERVER then
                    self:ApplyNVG()
                end
            end
        end)
        
    else
        self:SetNextPrimaryFire(CurTime() + 1.5)
        self:PlayAnim("putoff", 0.75)

        if SERVER then
            self:RemoveNVG()
        end

        timer.Create("NVGToggle_" .. wepID, 0.75, 1, function()
            if IsValid(self) then
                self.IsToggling = false
            end
        end)
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:ApplyNVG()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:ScreenFade(SCREENFADE.IN, color_black, 2, 0)

    if owner:Alive() then
        self.Nightvision_Owner = owner
        owner:EmitSound("nextoren/weapons/items/nightvision/nvgturnon.wav", 75, 100, 1, CHAN_STATIC)
        
        if not banned_models[NormalizePath(owner:GetModel())] then
            Bonemerge("models/imperator/items/nightvision/bonemerge_nvg_forface_red.mdl", owner)
            for _, v in ipairs(owner.BoneMergedEnts) do
                if v and IsValid(v) and v:GetModel():lower():find("_nvg_") then
                    v:SetSkin(3)
                    owner.NVG_Bonemerged = v
                end
            end
        end

        net.Start("NightvisionOn")
        net.WriteString("red")
        net.Send(owner)
    end
end

function SWEP:RemoveNVG()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:ScreenFade(SCREENFADE.IN, color_black, 0.9, 0)
    
    if owner.NVG_Bonemerged and IsValid(owner.NVG_Bonemerged) then
        owner.NVG_Bonemerged:Remove()
    end
    
    self.Nightvision_Owner = nil

    if owner:Alive() then
        net.Start("NightvisionOff")
        net.Send(owner)
    end
end

function SWEP:ThinkAdd()
    if self:IsNightvisionActive() and not self.IsToggling then
        self.setlh = false
        self.setrh = false
    else
        self.setlh = true
        self.setrh = true
    end
end

function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) then
        local active = self:IsNightvisionActive()
        if active then
            if not wm.IsHiddenCustom then
                wm.IsHiddenCustom = true
                wm:SetRenderMode(10)
                wm:SetMaterial("!" .. matName)
                for i = 0, 31 do
                    wm:SetSubMaterial(i, "!" .. matName)
                end
                wm:DrawShadow(false)
            end
        else
            if wm.IsHiddenCustom then
                wm.IsHiddenCustom = nil
                wm:SetRenderMode(0)
                wm:SetMaterial("")
                for i = 0, 31 do
                    wm:SetSubMaterial(i, "")
                end
                wm:DrawShadow(true)
            end
        end
    end
end