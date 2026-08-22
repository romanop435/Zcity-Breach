if SERVER then AddCSLuaFile() end

SWEP.HoldType = "slam"

if ( CLIENT ) then
  SWEP.Category           = "NextOren Breach"
  SWEP.PrintName          = "SCP-500"
  SWEP.Slot               = 1
  SWEP.ViewModelFOV       = 50
  SWEP.DrawSecondaryAmmo = false
  SWEP.DrawAmmo       = false
  SWEP.InvIcon = Material( "nextoren/gui/new_icons/scp/500.png" )
end

SWEP.ViewModelFlip      = false

SWEP.Spawnable          = true
SWEP.AdminSpawnable     = true

SWEP.ViewModel          = ""
SWEP.WorldModel         = "models/cultist/scp_items/500/scp500.mdl"

SWEP.Amount = 1
SWEP.UseHands = true
SWEP.ShowWorldModel = false
SWEP.HoldType       = "slam"

SWEP.Primary.Delay          = 3.5
SWEP.NextAttack = 0
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.Ammo         = "none"

function SWEP:Initialize() end

function SWEP:Think()
  if ( self && self:IsValid() && self.Amount <= 0 ) then
    self:Remove()
  end
  return true
end

function SWEP:CanSecondaryAttack()
  self:PrimaryAttack()
end

function SWEP:Eat()
  if !IsFirstTimePredicted() then return end

  if SERVER then
    local ply = self.Owner
    if not IsValid(ply) then return end

    ply:ScreenFade(SCREENFADE.IN, Color(0,255,0, 100), 0.5, 0)
    ply:BrTip(0, "[ZCity Breach]", Color(255,0,0,220), "l:you_feel_healthy", color_white )
    
    ply.TempValues.Used500 = true
    ply.Infected409 = false
    timer.Remove("SCP409Phase1_"..ply:SteamID64())
    timer.Remove("SCP409Phase2_"..ply:SteamID64())
    timer.Remove("SCP409Phase3_"..ply:SteamID64())
    timer.Remove("SCP1025COLD"..ply:SteamID64())
    
    if ply.TempValues.diseaseremember then
      for i, v in pairs(ply.TempValues.diseaseremember) do
        if i == "jumppower" then
          ply:SetJumpPower(v)
        elseif i == "staminascale" then
          ply:SetStaminaScale(v)
        end
      end
    end

    if ply.organism then
        local org = ply.organism


        org.blood = 5000
        org.bleed = 0
        org.internalBleed = 0
        org.internalBleedHeal = 0

        org.pain = 0
        org.painadd = 0
        org.avgpain = 0
        org.shock = 0
        org.disorientation = 0

        org.llegdislocation = false
        org.rlegdislocation = false
        org.larmdislocation = false
        org.rarmdislocation = false
        org.jawdislocation = false

        local damageFields = {
            "lleg", "rleg", "larm", "rarm", 
            "spine1", "spine2", "spine3", 
            "pelvis", "chest", "skull", "jaw",
            "brain", "liver", "stomach", "intestines", "heart", "trachea"
        }
        for _, field in ipairs(damageFields) do
            if type(org[field]) == "number" then
                org[field] = 0
            end
        end

        if org.lungsL and type(org.lungsL[1]) == "number" then org.lungsL[1] = 0 end
        if org.lungsR and type(org.lungsR[1]) == "number" then org.lungsR[1] = 0 end
        org.pneumothorax = 0

        org.wounds = {}
        org.arterialwounds = {}
        ply:SetNetVar("wounds", {})
        ply:SetNetVar("arterialwounds", {})

        local arteries = {"arteria", "larmartery", "rarmartery", "llegartery", "rlegartery", "spineartery"}
        for _, art in ipairs(arteries) do
            if org[art] then org[art] = 0 end
        end

        if org.o2 then org.o2[1] = org.o2.range or 30 end
        org.CO = 0
        if org.stamina then org.stamina[1] = org.stamina.max or 180 end

        if ply.Virus then
            ply.Virus = nil
        end

        org.holdingbreath = false
        org.otrub = false
        org.consciousness = 1
        org.alive = true

        ply.fullsend = true
        if hg and hg.send_organism then
            hg.send_organism(org, ply)
        end
    end

    if ply:Health() < ply:GetMaxHealth() then
        if ply.AnimatedHeal then
            ply:AnimatedHeal( ply:GetMaxHealth() - ply:Health() )
        else
            ply:SetHealth(ply:GetMaxHealth())
        end
    end

    ply:RemoveItem(tonumber(ply:GetNWInt("ActiveSlot")))
  end
end

function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire(CurTime() + 1)
  self:SetNextSecondaryFire(CurTime() + 1)

  self:Eat()
end