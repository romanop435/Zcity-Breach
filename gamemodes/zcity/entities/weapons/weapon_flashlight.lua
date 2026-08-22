if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
DEFINE_BASECLASS("weapon_tpik_base")

SWEP.PrintName = "Фонарик"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = true

if CLIENT then
    SWEP.WepSelectIcon = Material("nextoren/gui/new_icons/flashlight.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/flashlight.png"
    SWEP.InvIcon = Material("nextoren/gui/new_icons/flashlight.png")
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "items"
SWEP.ViewModel = "models/cultist/items/flashlight/v_item_maglite.mdl"
SWEP.ViewModelFOV = 54
SWEP.WorldModel = "models/cultist/items/flashlight/w_item_maglite.mdl"
SWEP.WorldModelReal = "models/cultist/items/flashlight/v_item_maglite.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true

SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(-10, 5, 0)

SWEP.Primary.Blunt = true
SWEP.Primary.Damage = 25
SWEP.droppable = true
SWEP.Primary.Reach = 40
SWEP.Primary.RPM = 90
SWEP.Primary.SoundDelay = 0
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.ClipSize = 0
SWEP.Primary.Delay = 0.3
SWEP.Primary.Window = 0.2
SWEP.Primary.Automatic = false

SWEP.AllowViewAttachment = false

SWEP.AnimList = {
    ["deploy"]  = {"DrawOn", 0.75, false, false, function(self) self.IsBusy = false end},
    ["holster"] = {"Holster", 0.45, false},
    ["toggle"]  = {"ToggleLight", 1, false, false, function(self) self.IsBusy = false end},
    ["idle"]    = {"Idle", 2, true},
    ["walk"]    = {"walk", 2, true},
    ["sprint"]  = {"Sprint", 2, true}
}

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
end

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
end

function SWEP:Deploy()
    self.IsBusy = true
    self.LastMoveAnim = "deploy"
    
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)

    if SERVER then
        self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
        if IsValid(self.bnmrg) then
            self.bnmrg:SetInvisible(true)
        end
    end

    if CLIENT then
        hook.Remove("PreRender", "ManualFlashLightThink")
    end

    return true
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.IsBusy then return end

    self.IsBusy = true
    self.LastMoveAnim = "toggle"
    self:SetNextPrimaryFire(CurTime() + 1.5)
    self.setlh = true
	timer.Simple(1, function()
		self.setlh = false
	end)
    self:PlayAnim("toggle")

    local wepID = self:EntIndex()
    timer.Create("FlashToggle_" .. wepID, 0.25, 1, function()
        if not IsValid(self) then return end
        
        if SERVER then
            if self:GetActive() then
                self:SetActive(false)
                self:EmitSound("nextoren/weapons/items/flashlight/flashlight_off.wav", 75, 100, 0.6, CHAN_WEAPON)
				self.setlh = false
            else
                self:SetActive(true)
                self:EmitSound("nextoren/weapons/items/flashlight/flashlight_on.wav", 90, 100, 0.6, CHAN_WEAPON)
				self.setlh = false
            end
        end
    end)
end

function SWEP:Holster()
    if self.IsBusy then return false end

    if SERVER then
        self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_01.wav", 75, math.random(80, 100), 1, CHAN_WEAPON)
        if IsValid(self.bnmrg) then 
            self.bnmrg:SetInvisible(false) 
        end
    end

    if CLIENT then
        if IsValid(self.projectedLight) and self.projectedLight:GetNearZ() ~= 0 then
            self.projectedLight:SetNearZ(0)
            self.projectedLight:Update()
        end
        self:SetupHolsteredLight()
    end

    return true
end

function SWEP:Equip(Owner)
    if SERVER then
        if not IsValid(Owner.FlashLightBonemerge) then
            Owner.FlashLightBonemerge = Bonemerge("models/cultist/items/flashlight/bonemerge.mdl", Owner)
        end
        self.bnmrg = Owner.FlashLightBonemerge
    end
end

if CLIENT then
    function SWEP:BuildLight()
        self.projectedLight = ProjectedTexture()
        self.projectedLight:SetEnableShadows(false)
        self.projectedLight:SetFarZ(885)
        self.projectedLight:SetBrightness(2.2)
        self.projectedLight:SetFOV(76)
        self.projectedLight:SetColor(color_white)
        self.projectedLight:SetTexture("nextoren/flashlight/flashlight001")
    end

    function SWEP:SetupHolsteredLight()
        hook.Add("PreRender", "ManualFlashLightThink", function()
            local ply = LocalPlayer()
            if not IsValid(ply) or not ply:HasWeapon(self:GetClass()) or not IsValid(self) or self:GetOwner() ~= ply then
                hook.Remove("PreRender", "ManualFlashLightThink")
                return
            end

            if ply:GetActiveWeapon() ~= self and self:GetActive() then
                if not IsValid(self.projectedLight) then
                    self:BuildLight()
                end

                local pelvis = ply:LookupBone("ValveBiped.Bip01_Pelvis")
                if pelvis then
                    local bonePos = ply:GetBonePosition(pelvis)
                    local ang = ply:EyeAngles()
                    ang.p = 0
                    ang.y = ang.y + 2

                    self.projectedLight:SetPos(bonePos + ang:Right() * 7)
                    self.projectedLight:SetAngles(ang)

                    if self.projectedLight:GetNearZ() ~= 1 then
                        self.projectedLight:SetNearZ(1)
                    end
                    self.projectedLight:Update()
                end
            end
        end)
    end
end

function SWEP:Think()
    if BaseClass.Think then BaseClass.Think(self) end

    if CLIENT then
        if self:GetActive() then
            if not IsValid(self.projectedLight) then
                self:BuildLight()
            end

            local ply = self:GetOwner()
            if IsValid(ply) and ply:GetActiveWeapon() == self then
                self.att_ViewModel = ply:GetViewModel()
                
                if IsValid(self.att_ViewModel) then
                    local att = self.att_ViewModel:GetAttachment(1)
                    if att then
                        self.projectedLight:SetPos(att.Pos)
                        self.projectedLight:SetAngles(att.Ang)
                    end
                end

                if self.projectedLight:GetNearZ() ~= 1 then
                    self.projectedLight:SetNearZ(1)
                end
                self.projectedLight:Update()
            end
        else
            if IsValid(self.projectedLight) then
                self.projectedLight:SetNearZ(0)
                self.projectedLight:Update()
            end
        end
    end

    if not self.IsBusy then
        local owner = self:GetOwner()
        if IsValid(owner) then
            local speed = owner:GetVelocity():LengthSqr()
            local targetAnim = "idle"

            if speed > 1000 and speed < 22500 then
                targetAnim = "walk"
            elseif speed >= 22500 then
                targetAnim = "sprint"
            end

            if self.LastMoveAnim ~= targetAnim then
                self.LastMoveAnim = targetAnim
                self:PlayAnim(targetAnim)
            end
        end
    end
end

function SWEP:OnDrop()
    if CLIENT and IsValid(self.projectedLight) then
        self.projectedLight:SetNearZ(0)
        self.projectedLight:Update()
    end

    if SERVER and IsValid(self.bnmrg) then
        self.bnmrg:Remove()
    end
    
    self:OnRemove()
end

function SWEP:OnRemove()
    local wepID = self:EntIndex()
    timer.Remove("FlashToggle_" .. wepID)

    if CLIENT then
        if IsValid(self.projectedLight) then
            self.projectedLight:SetNearZ(0)
            self.projectedLight:Update()
            self.projectedLight:Remove()
        end
        hook.Remove("PreRender", "ManualFlashLightThink")
    end

    if SERVER and IsValid(self.bnmrg) then 
        self.bnmrg:Remove() 
    end

    return true
end

function SWEP:CanSecondaryAttack()
    return false
end