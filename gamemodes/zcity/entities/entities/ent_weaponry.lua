AddCSLuaFile()

ENT.Type        = "anim"
ENT.Category    = "Breach"

ENT.Model       = Model( "models/cultist/armory/armory.mdl" )

function ENT:Initialize()
  if ( SERVER ) then
    self:SetModel( self.Model )
    self:SetMoveType( MOVETYPE_NONE )

    self.BannedUsers = {}
    
    self.Ammo_Quantity = {}
    if hg and hg.ammotypeshuy then
        for ammoName, data in pairs(hg.ammotypeshuy) do
            self.Ammo_Quantity[ammoName] = (data.maxcarry or 120) * 10
        end
    end
  end

  self:SetSolid( SOLID_VPHYSICS )
end

if ( SERVER ) then

  local MTF_AMMO_TYPES = {
    [role.MTF_Shock]    = "12/70 gauge",
    [role.MTF_Security] = "9x19 mm Parabellum",
    [role.MTF_Engi]     = "7.62x51 mm",
    [role.MTF_Chem]     = "4.6x30 mm",
    [role.MTF_Medic]    = "5.56x45 mm",
    [role.MTF_HOF]      = ".357 Magnum",
    ["role.gay"]        = "5.56x45 mm",
  }

  local Teams_Setup = {
        [ role.SECURITY_Recruit ] = {
          weapon = { "weapon_tmp","breach_keycard_guard_2" },
          ammo_type = "9x19 mm Parabellum",
          ammo_count = 120,
          bodygroups = "11000001",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 1,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 1,
            ["HITGROUP_RIGHTARM"] = 1,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 1,
            ["HITGROUP_RIGHTLEG"] = 1
           },
        },
        [ role.SECURITY_Chief ] = {
          weapon = { "weapon_hk416","breach_keycard_guard_4" },
          ammo_type = "5.56x45 mm",
          ammo_count = 180,
          bodygroups = "12001001",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_full.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 1,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 1,
            ["HITGROUP_RIGHTARM"] = 1,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 1,
            ["HITGROUP_RIGHTLEG"] = 1
           },
        },
        [ role.SECURITY_Sergeant ] = {
          weapon = { "weapon_sg552","breach_keycard_guard_3" },
          ammo_type = "5.56x45 mm",
          ammo_count = 180,
          bodygroups = "22001001",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.8,
            ["HITGROUP_RIGHTLEG"] = 0.8
           },
        },
        [ role.SECURITY_OFFICER ] = {
          weapon = { "weapon_mp7","breach_keycard_guard_2" },
          ammo_type = "4.6x30 mm",
          ammo_count = 180,
          bodygroups = "10101001",
          bonemerge = "models/cultist/humans/balaclavas_new/head_balaclava_month.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.9,
            ["HITGROUP_RIGHTLEG"] = 0.9
           },
        },
        [ role.SECURITY_Shocktrooper ] ={
          weapon = { "weapon_m590a1","breach_keycard_guard_3" },
          ammo_type = "12/70 gauge",
          ammo_count = 40,
          bodygroups = "22011101",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_full.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.65,
            ["HITGROUP_CHEST"] = 0.65,
            ["HITGROUP_LEFTARM"] = 0.65,
            ["HITGROUP_RIGHTARM"] = 0.65,
            ["HITGROUP_STOMACH"] = 0.65,
            ["HITGROUP_GEAR"] = 0.65,
            ["HITGROUP_LEFTLEG"] = 0.65,
            ["HITGROUP_RIGHTLEG"] = 0.65
           },
        },
        [ role.SECURITY_Warden ] = {
          weapon = { "weapon_hk416","breach_keycard_guard_4" },
          ammo_type = "5.56x45 mm",
          ammo_count = 160,
          bodygroups = "12001001",
          bonemerge = true,
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.8,
            ["HITGROUP_RIGHTLEG"] = 0.8
           },
        },
        [ role.SECURITY_IMVSOLDIER ] = {
          weapon = { "weapon_m16a2","breach_keycard_guard_3" },
          ammo_type = "5.56x45 mm",
          ammo_count = 160,
          bodygroups = "22001001",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_full.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.9,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.8,
            ["HITGROUP_RIGHTLEG"] = 0.8
           },
        },
      }

  function ENT:Use( survivor )
    if ( ( self.NextUse || 0 ) > CurTime() ) then return end

    self.NextUse = CurTime() + 2

    local gteam = survivor:GTeam()

    if not timer.Exists("NiggaClose") then
      self:ResetSequence( self:LookupSequence( "close" ) )
      timer.Create( "NiggaClose", 1, 1, function()
        if IsValid(self) then self:ResetSequence( self:LookupSequence( "open" ) ) end
      end )
    end

    if ( gteam != TEAM_SECURITY and gteam != TEAM_GUARD ) or survivor:GetRoleName() == role.Dispatcher then
      survivor:RXSENDNotify("l:weaponry_cant_use")
      return
    end
    
    if gteam == TEAM_GUARD then
      if self.BannedUsers[survivor:GetNamesurvivor()] then
        survivor:RXSENDNotify("l:weaponry_took_ammo_already")
        return
      end

      local wep = survivor:GetActiveWeapon()

      if ( IsValid(wep) and ishgweapon and ishgweapon(wep) ) then
        local ammoID = wep:GetPrimaryAmmoType()
        if ammoID == -1 then return end

        local ammoName = game.GetAmmoName(ammoID)
        local current_ammo = survivor:GetAmmoCount( ammoID )
        
        local hgAmmoData = hg.ammotypeshuy and hg.ammotypeshuy[ammoName]
        local max_ammo = hgAmmoData and hgAmmoData.maxcarry or 120

        if survivor:GetRoleName() == role.ClassD_Banned then max_ammo = math.floor(max_ammo/2) end

        if ( current_ammo >= max_ammo ) then
          BREACH.Players:ChatPrint( survivor, true, true, "l:ammocrate_max_ammo" )
          return
        end

        self.Ammo_Quantity[ammoName] = self.Ammo_Quantity[ammoName] or 0

        if ( self.Ammo_Quantity[ammoName] <= 0 ) then
          BREACH.Players:ChatPrint( survivor, true, true, "l:ammocrate_no_ammo" )
          return
        end
        
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

    elseif gteam == TEAM_SECURITY then
      if gteam == TEAM_SECURITY and survivor:GetModel():find("mog.mdl") then
        survivor:RXSENDNotify("l:weaponry_took_uniform_already")
        return
      end
      if gteam != TEAM_SECURITY or not Teams_Setup[survivor:GetRoleName()] then
        survivor:RXSENDNotify("l:weaponry_cant_use")
        return
      end
      if survivor:GetMaxSlots() - survivor:GetPrimaryWeaponAmount() < #Teams_Setup[survivor:GetRoleName()].weapon then
        survivor:RXSENDNotify("l:weaponry_need_slots_pt1 "..tostring(#Teams_Setup[survivor:GetRoleName()].weapon).." l:weaponry_need_slots_pt2")
        return
      end

      if self.BannedUsers[survivor:GetNamesurvivor()] then
        survivor:RXSENDNotify("l:weaponry_took_ammo_already")
        return
      end

      self.BannedUsers[survivor:GetNamesurvivor()] = true
      
      survivor:CompleteAchievement("weaponry")
      local tab = Teams_Setup[survivor:GetRoleName()]
      survivor:EmitSound( Sound("nextoren/others/cloth_pickup.wav"), 125, 100, 1.25, CHAN_VOICE)
      survivor:ScreenFade(SCREENFADE.IN, color_black, 1, 1)

    if survivor:IsFemale() then
        survivor:SetModel("models/cultist/humans/mog/mog_woman_capt.mdl")
      else
        survivor:SetModel("models/cultist/humans/mog/mog.mdl")
        if tab.bonemerge and survivor:SteamID64() != "76561198867007475" and survivor:SteamID64() != "76561198342205739" then
          for _, bnmrg in ipairs(survivor:LookupBonemerges()) do
            if bnmrg:GetModel():find("male_head") or bnmrg:GetModel():find("balaclava") then
              local copytext = bnmrg:GetSubMaterial(0)
              local bnmrg_new
              if tab.bonemerge != true then
                bnmrg_new = Bonemerge(tab.bonemerge, survivor)
              else
                bnmrg_new = Bonemerge(PickHeadModel(), survivor)
              end
              bnmrg_new:SetSubMaterial(0, copytext)
              bnmrg:Remove()
            end
          end
        end
      end

      survivor:ClearBodyGroups()
      survivor:SetupHands()
      survivor:SetBodyGroups(tab.bodygroups)

      if survivor:SteamID64() == "76561198867007475" then
        if survivor:GetRoleName() == role.SECURITY_OFFICER then
          survivor:SetBodyGroups("11000001")
        end
        if survivor:GetRoleName() == role.SECURITY_IMVSOLDIER then
          survivor:SetBodyGroups("21001001")
        end
        if survivor:GetRoleName() == role.SECURITY_Shocktrooper then
          survivor:SetBodyGroups("21011101")
        end
        if survivor:GetRoleName() == role.SECURITY_Sergeant then
          survivor:SetBodyGroups("21000001")
        end
        if survivor:GetRoleName() == role.SECURITY_Chief then
          survivor:SetBodyGroups("11000001")
        end
        if survivor:GetRoleName() == role.SECURITY_Warden then
          survivor:SetBodyGroups("12110001")
        end
      end

      if survivor:SteamID64() == "76561198342205739" then
        if survivor:GetRoleName() == role.SECURITY_OFFICER then
          survivor:SetBodyGroups("11000001")
        end
        if survivor:GetRoleName() == role.SECURITY_IMVSOLDIER then
          survivor:SetBodyGroups("21000001")
        end
        if survivor:GetRoleName() == role.SECURITY_Shocktrooper then
          survivor:SetBodyGroups("21011101")
        end
        if survivor:GetRoleName() == role.SECURITY_Sergeant then
          survivor:SetBodyGroups("21000001")
        end
        if survivor:GetRoleName() == role.SECURITY_Chief then
          survivor:SetBodyGroups("11000001")
          for i, v in pairs(survivor:LookupBonemerges()) do
            if v:GetModel() == "models/cultist/humans/balaclavas_new/balaclava_half.mdl" then
              v:SetModel("models/cultist/humans/mog/heads/head_main.mdl")
            end
          end
        end
        if survivor:GetRoleName() == role.SECURITY_Warden then
          survivor:SetBodyGroups("12110001")
        end
      end

      survivor.ScaleDamage = tab.damage_modifiers
      
      for _, wep in ipairs(tab.weapon) do
       survivor:BreachGive(wep)
      end

      if tab.ammo_type and tab.ammo_count then
        local ammoID = game.GetAmmoID(tab.ammo_type)
        if ammoID then
            survivor:GiveAmmo(tab.ammo_count, ammoID, true)
        end
        
        if survivor.inventory then
            survivor.inventory.Ammo = survivor:GetAmmo()
            survivor:SetNetVar("Inventory", survivor.inventory)
        end
      end

      survivor:RXSENDNotify("l:weaponry_mtf_armor_pt1 ", gteams.GetColor(TEAM_GUARD), "l:weaponry_mtf_armor_pt2")
    end
  end

end

if ( CLIENT ) then

  function ENT:Draw()
    self:DrawModel()
  end

end