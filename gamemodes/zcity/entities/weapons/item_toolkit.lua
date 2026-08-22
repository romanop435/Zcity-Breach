
AddCSLuaFile()

if ( CLIENT ) then

	SWEP.InvIcon = Material( "nextoren/gui/new_icons/tool_kit.png" )

end

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= "models/cultist/items/toolbox/tool_box.mdl"
SWEP.PrintName		= "Набор инструментов"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "items"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false
SWEP.ProgressIcon = "nextoren/gui/new_icons/tool_kit.png"
SWEP.PercentHeal = .5
SWEP.Heal_Left = 1

SWEP.droppable				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false
SWEP.UseHands = true

SWEP.Pos = Vector( 1, 3, -2 )
SWEP.Ang = Angle( 240, -90, 240 )

function SWEP:Deploy()
  	self.Owner:DrawViewModel( false )
end

function SWEP:CanPrimaryAttack()
  	return self.Owner:GTeam() == TEAM_AR
end

function SWEP:CanSecondaryAttack()
  	return false
end

function SWEP:DrawWorldModel()
	self:DrawModel()
end

function SWEP:MakeHealSound()
	for i = 1, 3 do
		timer.Create("Heal_Sound_"..i.."_"..self.Owner:SteamID64(), 0.6 + (i - 1), 1, function()
			self:EmitSound("nextoren/ar_heal"..math.random(1,3)..".wav", 100, 100, 1.25, CHAN_WEAPON)
		end)
	end
end

function SWEP:StopHealSound()
	for i = 1, 3 do
		timer.Remove("Heal_Sound_"..i.."_"..self.Owner:SteamID64())
	end
end

function SWEP:Heal( target )

  local animation
  local heal_time

  if ( self.Owner:IsFrozen() || self.Owner:GetMoveType() != MOVETYPE_WALK ) then return end

  if ( target ) then

    if ( target:Health() >= target:GetMaxHealth() ) then

      

      return
    end

    

    animation = "l4d_Heal_Friend_Standing"

    heal_time = select( 2, self.Owner:LookupSequence( animation ) )

    self.Healing = true

    self.Owner:BrProgressBar( "l:medkit_healing " .. target:GetNamesurvivor() .. "...", heal_time, self.ProgressIcon, target, false, function()

      self.Heal_Left = self.Heal_Left - 1

      self.Healing = false

      
      
      self.Owner:AddToMVP("heal", math.min(target:GetMaxHealth() - target:Health(), target:GetMaxHealth() * self.PercentHeal))
      target:AnimatedHeal( target:GetMaxHealth() * self.PercentHeal )

      self.Owner:SetNWEntity( "NTF1Entity", NULL )

    end, function() self:MakeHealSound() self.Owner:SetNWEntity("NTF1Entity", self.Owner) self.Owner:SetForcedAnimation( animation, heal_time ) end, function() self:StopHealSound() self.Owner:SetNWEntity("NTF1Entity", NULL) self.Owner:StopForcedAnimation() end)

  else

    if ( !self.Owner:Crouching() ) then

      animation = "l4d_Heal_Self_Standing_06"

    else

      animation = "l4d_Heal_Self_Crouching"

    end

    self.Healing = true

    heal_time = select( 2, self.Owner:LookupSequence( animation ) )

    self.Owner:BrProgressBar( "l:medkit_healing", heal_time, self.ProgressIcon, nil, false, function()

      if ( !( ( self && self:IsValid() ) && ( self.Owner && self.Owner:IsValid() ) ) ) then return end

      self.Healing = false

      BREACH.Players:ChatPrint( self.Owner, true, true, "l:medkit_heal_ended" )

      self.Owner:AddToMVP("heal", math.min(self.Owner:GetMaxHealth() - self.Owner:Health(), self.Owner:GetMaxHealth() * self.PercentHeal))
      self.Owner:AnimatedHeal( self.Owner:GetMaxHealth() * self.PercentHeal )
      self.Owner:SetNWEntity( "NTF1Entity", NULL )

      self.Heal_Left = self.Heal_Left - 1

    end, function() self:MakeHealSound() self.Owner:SetNWEntity("NTF1Entity", self.Owner) self.Owner:SetForcedAnimation( animation, heal_time ) end, function() self:StopHealSound() self.Owner:SetNWEntity("NTF1Entity", NULL) self.Owner:StopForcedAnimation() end)

  end

end

function SWEP:PrimaryAttack()
	if ( self:GetNWEntity( "NTF1Entity" ) == self.Owner ) then return end
	self:SetNextPrimaryFire( CurTime() + .25 )
	if ( CLIENT ) then return end
	if self.Owner:GTeam() ~= TEAM_AR then
		
		return
	end

	local current_health, max_health = self.Owner:Health(), self.Owner:GetMaxHealth()
	if ( current_health >= max_health ) then
		BREACH.Players:ChatPrint( self.Owner, true, true, "Вы не нуждаетесь в лечении." )
	else
		self:Heal()
	end
end
local maxs = Vector( 8, 2, 18 )
function SWEP:SecondaryAttack()
	if ( self:GetNWEntity( "NTF1Entity" ) == self.Owner ) then return end
	self:SetNextSecondaryFire( CurTime() + .25 )

	if ( CLIENT ) then return end

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 80
	trace.mask = MASK_SHOT
	trace.filter = { self, self.Owner }
	trace.maxs = maxs
	trace.mins = -maxs

	trace = util.TraceHull( trace )

	local target = trace.Entity
	if target:GTeam() ~= TEAM_AR then
		self.Owner:RXSENDNotify("Вы что собираетесь лечить человека гаечным ключом?")
		return
	end
	if ( target:IsPlayer() && !( target:GTeam() == TEAM_SCP || target:GTeam() == TEAM_SPEC ) ) then
		self:Heal( target )
	end
end