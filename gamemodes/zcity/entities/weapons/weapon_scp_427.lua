AddCSLuaFile()

if ( CLIENT ) then
	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/scp/427.png" )
  	SWEP.red = "SCP"
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= "models/cultist/scp_items/427/scp_427.mdl"
SWEP.PrintName		= "SCP-427"
SWEP.Slot			= 0
SWEP.SlotPos		= 0
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.AttackDelay			= 0.15
SWEP.droppable				= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false

SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Percent = 100
SWEP.IsUsing = false

local NextPercent = 0
local NextRandom = 0
local NextNetSync = 0

function SWEP:Equip()
end

function SWEP:PrimaryAttack()
	if ( ( self.NextToggle || 0 ) > CurTime() ) then return end
	self.NextToggle = CurTime() + 2

    if ( !self.IsUsing ) then
		if ( SERVER ) then
			self.Owner:BrTip( 3, "[SCP - 427]", Color( 0, 255, 0, 180 ), "l:scp427_regenerates_health", color_white )
		end
        self.IsUsing = true
    else
		if ( SERVER ) then
			self.Owner:BrTip( 3, "[SCP - 427]", Color( 255, 0, 0, 180 ), "l:you_took_off_scp427", color_white )
		end
        self.IsUsing = false
    end
end

function SWEP:Think()
	if ( !( self.Owner && self.Owner:IsValid() ) ) then return end

	if ( self.Owner:Health() <= 0 && self.Owner:Alive() ) then
		self.Owner:Kill()
		return
	end

    if ( self.Owner:Health() <= 0 || CLIENT ) then return end

    if ( !self.IsUsing ) then return end

    local ply = self.Owner
    local ft = FrameTime()

    if SERVER and ply.organism then
        local org = ply.organism
        local healRate = ft * 15

        if ply:Health() < ply:GetMaxHealth() then
            ply:SetHealth(math.min(ply:Health() + (ft * 10), ply:GetMaxHealth()))
        end

        org.blood = math.min(org.blood + (ft * 150), 5000)

        if org.wounds then
            for i, wound in pairs(org.wounds) do
                wound[1] = math.max(wound[1] - healRate, 0)
            end
        end
        if org.arterialwounds then
            for i, wound in pairs(org.arterialwounds) do
                wound[1] = math.max(wound[1] - healRate, 0)
            end
        end

        org.internalBleed = math.max((org.internalBleed or 0) - healRate, 0)
        org.pneumothorax = math.max((org.pneumothorax or 0) - healRate, 0)

        org.pain = math.max(org.pain - healRate, 0)
        org.painadd = math.max(org.painadd - healRate, 0)
        org.avgpain = math.max(org.avgpain - healRate, 0)
        org.shock = math.max(org.shock - healRate, 0)
        org.disorientation = math.max(org.disorientation - (healRate * 0.1), 0)

        local damageFields = {
            "lleg", "rleg", "larm", "rarm", 
            "spine1", "spine2", "spine3", 
            "pelvis", "chest", "skull",
            "brain", "liver", "stomach", "intestines", "heart", "trachea"
        }
        for _, field in ipairs(damageFields) do
            if org[field] and type(org[field]) == "number" then
                org[field] = math.max(org[field] - (ft * 0.05), 0)
            end
        end

        if org.lungsL and type(org.lungsL[1]) == "number" then org.lungsL[1] = math.max(org.lungsL[1] - (ft * 0.05), 0) end
        if org.lungsR and type(org.lungsR[1]) == "number" then org.lungsR[1] = math.max(org.lungsR[1] - (ft * 0.05), 0) end

        org.llegdislocation = false
        org.rlegdislocation = false
        org.larmdislocation = false
        org.rarmdislocation = false
        org.jawdislocation = false

        if NextNetSync < CurTime() then
            NextNetSync = CurTime() + 0.5
            ply:SetNetVar("wounds", org.wounds)
            ply:SetNetVar("arterialwounds", org.arterialwounds)
            ply.fullsend = true
        end
    end

    if ( NextPercent < CurTime() ) then
        NextPercent = CurTime() + math.random( 1, 3 )
        self.Percent = self.Percent - 2
    end

    if ( NextRandom < CurTime() && self.Percent <= 75 ) then
        NextRandom = CurTime() + 2

		if ( !self.Tip ) then
			self.Tip = true
			self.Owner:Tip( 3, "[SCP - 427]", Color( 255, 0, 0, 180 ), "Вы стали странно себя ощущать. Наверное, стоит прекратить использование SCP-427?", color_white )
		end

        if ( math.log( math.random( 1, self.Percent ), self.Percent ) > 0.85 ) then
            self.Owner:Kill()
        end
    end

    return true
end

function SWEP:CanSecondaryAttack()
	return false
end