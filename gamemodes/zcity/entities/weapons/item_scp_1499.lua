
if ( CLIENT ) then

  SWEP.InvIcon = Material( "nextoren/gui/new_icons/scp/1499.png" )
SWEP.red = "SCP"
end

SWEP.PrintName = "SCP-1499"
SWEP.HoldType = "items"
SWEP.UseHands = false

SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/scp_items/1499/w_1499.mdl"

function SWEP:Initialize()

  self:SetHoldType( self.HoldType )

end

function SWEP:InDimension()

  if ( self:GetPos().y < -13000 ) then return true end
  return false

end

function SWEP:SetupDataTables()

  self:NetworkVar( "Bool", 0, "Activated" )

end

local mask_overlay = Material( "nextoren_hud/overlay/gasmaskdmxmd" )

function SWEP:Think()

  if ( CLIENT ) then
    if true then return end
    if ( self:GetActivated() && !self.HUDActivated ) then

      self.HUDActivated = true
      self.UnDroppable = true

      local client = LocalPlayer()

      client.BlackScreen = true

      timer.Simple( .6, function()

        if ( client && client:IsValid() ) then

          client.BlackScreen = nil

        end

      end )

      client.Fog_Overlay = true
      client:SetDSP( 15 )

      colour = .25

      local snd = CreateSound( client, "nextoren/weapons/items/gasmask/focus_inhale_0" .. math.random( 1, 4 ) .. ".wav" )
      snd:SetDSP( 17 )
      snd:Play()

      client.scp1499_ambient = CreateSound( client, "nextoren/scp/1499/enter.ogg" )
      client.scp1499_ambient:SetDSP( 1 )
      client.scp1499_ambient:Play()

      if ( !client.Gasmask_Breathing ) then

        client.Gasmask_Breathing = CreateSound( client, "nextoren/weapons/items/gasmask/gasmask_breathing_loop.wav" )
        client.Gasmask_Breathing:Play()

      end

      local old_name = client:GetNamesurvivor()

      

      

      
      
      
      

      

      
      

      

      
      

      
      
      
      
      
      
      

      

      

      

      
      
      
      

      

      
      

      

      
      

      
      
      
      
      
      
      

      

      

      

      

      

      
      

      
      

      

    elseif ( !self:GetActivated() && self.HUDActivated ) then

      self.HUDActivated = nil
      self.UnDroppable = nil

      local client = LocalPlayer()

      timer.Simple( .25, function()

        if ( client && client:IsValid() ) then

          colour = .7
          client.Fog_Overlay = nil
          client:SetDSP( 1 )

          local snd = CreateSound( client, "nextoren/weapons/items/gasmask/focus_exhale_0" .. math.random( 1, 4 ) .. ".wav" )
          snd:SetDSP( 17 )
          snd:Play()

          if ( client.scp1499_ambient && client.scp1499_ambient:IsPlaying() ) then

            client.scp1499_ambient:Stop()
            client.scp1499_ambient = nil

          end

          local ambient = CreateSound( client, "nextoren/scp/1499/exit.ogg" )
          ambient:Play()

          if ( client.Gasmask_Breathing ) then

            client.Gasmask_Breathing:Stop()
            client.Gasmask_Breathing = nil

          end

          hook.Remove( "SetupWorldFog", "SCP1499_Dimension_Fog" )
          hook.Remove( "SetupSkyboxFog", "SCP1499_Dimension_Fog" )
          hook.Remove( "RenderScreenspaceEffects", "SCP1499_Mask_Overlay" )

        end

      end )

    end

  end

end

function SWEP:TeleportSequence( pos )

  self.Owner:ScreenFade( SCREENFADE.IN, color_black, .2, .75 )

  if ( SERVER ) then

    timer.Simple( .25, function()

      if ( ( self && self:IsValid() ) && ( self.Owner && self.Owner:IsValid() && self.Owner:Alive() ) && pos ) then

        if self.Owner:GetInDimension() then return end

        self.Owner:SetPos( pos )

      end

    end )

  end

end

local dimension_initial_position = Vector( -1810.355957, -13645.223633, -3360.968750 )

function SWEP:PrimaryAttack()

  self:SetNextPrimaryFire( CurTime() + 2 )

  if ( CLIENT ) then return end

  
  print(self.Owner.OldPosition1499)
  if self.Owner.OldPosition1499 == nil then

    self:SetActivated( true )

    if ( !self.Owner.OldPosition1499 ) then

      self.Owner.OldPosition1499 = self.Owner:GetPos()


    end

    self.Owner:ScreenFade( SCREENFADE.IN, color_black, .2, 1 )
    
    

    timer.Simple( .25, function()

      if ( ( self && self:IsValid() ) && ( self.Owner && self.Owner:IsValid() && self.Owner:Alive() ) ) then

        if self.Owner:GetInDimension() then return end

        self:TeleportSequence( dimension_initial_position + Vector( math.Rand( 1, 74 ), math.Rand( 1, 74 ), 0 ) )

        if ( CLIENT ) then return end

        self.Owner.CustomTake = 0

        BREACH.SendClientEvent(self.Owner, "scp1499", {enabled = true})

        
        

      end

    end )

  else

    
    

    if ( self.Owner.OldPosition1499 ) then

      
      

      self:TeleportSequence( self.Owner.OldPosition1499 )

      self.Owner.OldPosition1499 = nil
        BREACH.SendClientEvent(self.Owner, "scp1499", {enabled = false})
      

      

      
      

      

    end

  end

end

function SWEP:CanSecondaryAttack() return false end
