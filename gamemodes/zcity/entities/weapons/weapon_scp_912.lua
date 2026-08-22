
SWEP.AbilityIcons = {

  {

    ["Name"] = "Smoke Grenade",
    ["Description"] = "Throw a smoke grenade you can see through.",
    ["Cooldown"] = "55",
    ["CooldownTime"] = 0,
    ["KEY"] = _G["KEY_F"],
    ["Using"] = false,
    ["Icon"] = "nextoren/gui/special_abilities/cult_command_hide.png",
    ["Abillity"] = nil

  },

  

  {

    ["Name"] = "Stealth Style",
    ["Description"] = "You taking out a special knife, your footsteps are deaf and you are faster than before",
    ["Cooldown"] = "200",
    ["CooldownTime"] = 0,
    ["KEY"] = _G["KEY_G"],
    ["Using"] = false,
    ["Icon"] = "nextoren/gui/special_abilities/scp_076_combo.png",
    ["Abillity"] = nil

  },

  

}

SWEP.Category = "BREACH SCP"
SWEP.PrintName = "SCP-912"
SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.HoldType = "scp638"

SWEP.Base = "breach_scp_base"

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

local w = 64
local h = 64
local padding = 133

local RageIcon = Material( "nextoren/achievements/ahive35.jpg", "smooth" )

local function DrawHUD()

  local client = LocalPlayer()

  if ( client:GetRoleName() != SCP912 ) then

    hook.Remove( "HUDPaint", "SCP_912_HUD" )

    return
  end

  
  
  

  
  

  
  

  
  
  
  

  

  
  
  

  
  
  
  

  
  


  

  
  

  

  

  

  

  

  

end

function SWEP:Initialize()
  if CLIENT then
    hook.Add("HUDPaint", "SCP_912_HUD", function()
      if LocalPlayer():GetRoleName() != SCP912 or !LocalPlayer():HasWeapon("weapon_scp_912") then 
        hook.Remove("HUDPaint", "SCP_912_HUD")
        return
      end
      self:DrawHUD()
    end)
  end
end

if SERVER then
  hook.Add( "PlayerDeath", "SCP_912_playerkillcheck", function( victim, inflictor, attacker )
    if IsValid(attacker) and attacker:IsPlayer() and attacker:GetRoleName() == SCP912 and IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "cw_kk_scp_912_deagle" then
      attacker:SetNWInt("scp_912_kills", math.min(5, attacker:GetNWInt("scp_912_kills", 0) + 1))
    end
  end)
end

function SWEP:Deploy()

  if ( CLIENT ) then
    hook.Add( "HUDPaint", "SCP_912_HUD", DrawHUD )
  end

  self.Owner:SetNWInt("scp_912_kills", 0)

  if SERVER then
    local deploycd = SysTime() + 1
    hook.Add( "PlayerButtonDown", "SCP912_Buttons", function( caller, button )

      if ( caller:GetRoleName() != "SCP912" ) then return end

      local wep = caller:GetWeapon("weapon_scp_912")

      if ( wep == NULL || !wep.AbilityIcons ) then return end

      
        
        
      

      if button == KEY_G and wep.AbilityIcons[2].CooldownTime <= CurTime() and caller:GetActiveWeapon():GetClass() == "cw_kk_scp_912_deagle" then
        self:Cooldown(2, tonumber(wep.AbilityIcons[2].Cooldown))

        if self.AbilityIcons[1].CooldownTime <= CurTime() + 25 then
          self:Cooldown(1, 30)
        end

        
        caller.JustSpawned = true
			  caller:Give( "weapon_scp_912_knife" )
			  timer.Simple( .1, function()
			  	caller.JustSpawned = false 
			  end)
        caller:GetActiveWeapon().SwitchWep = caller:GetWeapon("weapon_scp_912_knife")

        local smokeScreen = ents.Create("cw_smokescreen_912")
        smokeScreen:SetPos(caller:GetPos())
        smokeScreen:Spawn()

        caller:ScreenFade(SCREENFADE.IN, Color(255,0,0, 50), 4, 1)
        local saverun = caller:GetRunSpeed()
        local savewalk = caller:GetWalkSpeed()
        caller:SetRunSpeed(270)
        caller:SetWalkSpeed(270)

        caller:BrProgressBar("l:ragemode", 10, "nextoren/achievements/ahive116.jpg", NULL, true, function()
        end)

        timer.Simple(10, function()
          if caller:GetRoleName() == SCP912 then
            caller:SelectWeapon("cw_kk_scp_912_deagle")
            caller:SetRunSpeed(saverun)
            caller:SetWalkSpeed(savewalk)
          end
        end)
      
      
      
      
      
		  
		  
		  
		  
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      elseif button == KEY_F and wep.AbilityIcons[1].CooldownTime <= CurTime() and caller:GetActiveWeapon():GetClass() == "cw_kk_scp_912_deagle" then
        self:Cooldown(1, tonumber(wep.AbilityIcons[1].Cooldown))

        caller:PlayGestureSequence("gesture_item_throw")

        caller:BrProgressBar("l:throwing_grenade", 0.86, "nextoren/achievements/halloween.png", NULL, true, function()

          caller:ViewPunch(Angle(15,0,0))

          local smokecock = ents.Create("cw_smoke_912")
          smokecock:SetOwner(caller)
          smokecock:SetPos(caller:EyePos())
          smokecock.grenadetype = 1
          smokecock:Spawn()

          local phys = smokecock:GetPhysicsObject()

          if IsValid(phys) then
            phys:SetVelocity(caller:EyeAngles():Forward()*800)
            phys:SetAngleVelocity(Vector(1000,1000,0))
          end

        end)

        


      end

    end)
  end

  self:SetHoldType( self.HoldType )

  if ( CLIENT ) then

    self:ChooseAbility( self.AbilityIcons )

    colour = 0

  end

  if SERVER then

    
    
    self.Owner.JustSpawned = true
		self.Owner:Give( "cw_kk_scp_912_deagle" )
		
		
		
    
		self.Owner:Give( "weapon_scp_912_knife" )
		timer.Simple( .1, function()
			self.Owner.JustSpawned = false 
		end)
    self.Owner:GiveAmmo(999999, "SMG1", true)
    self.Owner:SelectWeapon("cw_kk_scp_912_deagle")

    local wep = self.Owner:GetWeapon("cw_kk_scp_912_deagle")
    wep:SetClip1(7)
    timer.Simple(1, function()
    if !IsValid(wep) then return end
    wep:attachSpecificAttachment("kk_ins2_suppressor_sec")
    wep:attachSpecificAttachment("kk_ins2_vertgrip") end)

  end

end

if ( SERVER ) then
  
  function SWEP:OnRemove()


    local players = player.GetAll()

    local SCP912_exists

    for i = 1, #players do

      local player = players[ i ]

      if ( player:GetRoleName() == "SCP912" ) then

        SCP638_exists = true

        break
      end

    end

    if ( !SCP912_exists ) then

      hook.Remove( "PlayerButtonDown", "SCP912_Buttons" )

    end


    local players = player.GetAll()

    for i = 1, #players do

      local player = players[ i ]

      if ( player && player:IsValid() ) then

        

      end

    end

  end

else

  function SWEP:DrawHUD()

    if ( !self.Deployed ) then

      self.Deployed = true

      self:Deploy()

    end

  end

end
