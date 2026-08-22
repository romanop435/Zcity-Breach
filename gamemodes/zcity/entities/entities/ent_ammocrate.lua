AddCSLuaFile()

ENT.Type        = "anim"
ENT.Category    = "Breach"

ENT.Model       = Model( "models/breach/items/ammocrate_full.mdl" )

ENT.SecurityLIST = {}

function ENT:Initialize()

  if ( SERVER ) then
    self:SetModel( self.Model )
    self:SetMoveType( MOVETYPE_NONE )

    self.Ammo_Quantity = {}
    if hg and hg.ammotypeshuy then
        for ammoName, data in pairs(hg.ammotypeshuy) do
            self.Ammo_Quantity[ammoName] = (data.maxcarry or 120) * 5
        end
    end
  end

  self:SetAutomaticFrameAdvance( true )
  self:ResetSequence( 0 )
  self:SetPlaybackRate( 1.0 )
  self:SetCycle( 0 )

  self:SetSolid( SOLID_VPHYSICS )

end

if ( SERVER ) then

  function ENT:Use( survivor )

    if ( ( self.NextUse || 0 ) > CurTime() ) then return end


    if ( survivor:GTeam() == TEAM_SECURITY or survivor:GetRoleName() == "CI Spy" ) and not table.HasValue(self.SecurityLIST, survivor:GetNamesurvivor()) then
      self.SecurityLIST[#self.SecurityLIST + 1] = survivor:GetNamesurvivor()
      
      local pistol = game.GetAmmoID("9x19 mm Parabellum")
      local rifle = game.GetAmmoID("5.56x45 mm")
      
      if pistol then survivor:GiveAmmo(80, pistol, true) end
      if rifle then survivor:GiveAmmo(120, rifle, true) end

      if survivor.inventory then
          survivor.inventory.Ammo = survivor:GetAmmo()
          survivor:SetNetVar("Inventory", survivor.inventory)
      end

      survivor:EmitSound( "nextoren/equipment/ammo_pickup.wav", 75, math.random( 95, 105 ), .75, CHAN_STATIC )
      self:ResetSequence( 1 )
      return
    end

    self.NextUse = CurTime() + .25

    if ( survivor:GTeam() == TEAM_SCP ) then return end

    if ( self:GetSequence() == 0 ) then

      local wep = survivor:GetActiveWeapon()

      if ( IsValid(wep) and ishgweapon and ishgweapon(wep) ) then

        local ammoID = wep:GetPrimaryAmmoType()
        if ammoID == -1 then return end

        local ammoName = game.GetAmmoName(ammoID)
        local current_ammo = survivor:GetAmmoCount( ammoID )


        local hgAmmoData = hg.ammotypeshuy and hg.ammotypeshuy[ammoName]
        
        local max_ammo = hgAmmoData and hgAmmoData.maxcarry or 120

        if survivor:GetRoleName() == role.ClassD_Banned then max_ammo = math.floor(max_ammo / 2) end

        if ( current_ammo >= max_ammo ) then
          BREACH.Players:ChatPrint( survivor, true, true, "l:ammocrate_max_ammo" )
          return
        end

        self.Ammo_Quantity[ammoName] = self.Ammo_Quantity[ammoName] or 0

        if ( self.Ammo_Quantity[ammoName] <= 0 ) then
          BREACH.Players:ChatPrint( survivor, true, true, "l:ammocrate_no_ammo" )
          return
        end

        self.CloseTime = CurTime() + 1
        self:ResetSequence( 1 )

        local have_ammo = self.Ammo_Quantity[ammoName]
        local need_ammo = max_ammo - current_ammo

        if ( need_ammo > have_ammo ) then
          need_ammo = have_ammo
        end

        survivor:SetAmmo( current_ammo + need_ammo, ammoID )
        
        if survivor.inventory then
            survivor.inventory.Ammo = survivor:GetAmmo()
            survivor:SetNetVar("Inventory", survivor.inventory)
        end

        survivor:EmitSound( "nextoren/equipment/ammo_pickup.wav", 75, math.random( 95, 105 ), .75, CHAN_STATIC )

        self.Ammo_Quantity[ammoName] = self.Ammo_Quantity[ammoName] - need_ammo

      else
        BREACH.Players:ChatPrint( survivor, true, true, "l:ammocrate_weapon_needed" )
      end

    end

  end

  function ENT:Think()

    self:NextThink( CurTime() + .1 )

    local int_curseq = self:GetSequence()

    if ( ( self.CloseTime || 0 ) < CurTime() && int_curseq == 1 ) then

      self:ResetSequence( 2 )

    elseif ( int_curseq == 2 && self:IsSequenceFinished() ) then

      self:ResetSequence( 0 )

    end

  end

end

if ( CLIENT ) then

  function ENT:Draw()
    self:DrawModel()
  end

end