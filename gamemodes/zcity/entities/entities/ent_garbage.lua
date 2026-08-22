AddCSLuaFile()

ENT.Base        = "base_entity"
ENT.Type        = "anim"
ENT.Category    = "Breach"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
  local randongarbagemodel = {
    "models/props_questionableethics/smoking_boots_left.mdl",
    --"models/props_construction/constructioncone.mdl",
    "models/props_office/coffe_pot.mdl",
    "models/slasherin/last year/props/retro-pack/msh_floppydrive.mdl",
    "models/slasherin/last year/props/retro-pack/msh_mouse.mdl",
    "models/slasherin/last year/props/retro-pack/msh_tape.mdl",
    "models/slasherin/last year/props/retro-pack/msh_tapedrive.mdl",
    "models/slasherin/last year/props/retro-pack/sm_camcorder_01a.mdl",
    "models/slasherin/last year/props/retro-pack/sm_computer_keyboard_03a.mdl",
    "models/slasherin/last year/props/retro-pack/sm_monitor_01a.mdl",
    "models/slasherin/last year/props/retro-pack/sm_slideprojector_01c.mdl",
    "models/slasherin/last year/props/retro-pack/sm_soundmixer_01.mdl",
    "models/slasherin/last year/props/retro-pack/sm_tape_01a.mdl",
    "models/slasherin/last year/props/retro-pack/sm_tape_02a.mdl",
    "models/slasherin/last year/props/retro-pack/sm_taperecorder_01a.mdl",
    "models/slasherin/last year/props/retro-pack/sm_vhsplayer_02a.mdl",
    --"models/props_equipment/portablebattery01.mdl",
    "models/props_gffice/closed_laptop.mdl",
    --"models/props_gffice/deskfan.mdl",
    --"models/props_gffice/open_laptop.mdl",
    "models/props_gffice/paperfolder01_static.mdl",
    "models/eftpropspack/container_lab_03.mdl",
    "models/eftpropspack/ammo_crate_wood_full.mdl",
    "models/eftpropspack/container_lab_01.mdl",
    "models/eftpropspack/container_lab_02.mdl",
    "models/eftpropspack/container_lab_04.mdl",
    "models/eftpropspack/first_aid_box.mdl",
    "models/eftpropspack/item_container_ammo.mdl",
    "models/eftpropspack/item_container_grenadebox.mdl",
    "models/eftpropspack/pistol_case.mdl",
    "models/eftpropspack/security_box.mdl",
  }
  
  self:SetModel( self.Model or randongarbagemodel[math.random(#randongarbagemodel)] )
  
  self:PhysicsInit( SOLID_VPHYSICS ) 
  self:SetMoveType( MOVETYPE_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )
  --self:SetPos(self:GetPos() + Vector(0,0,10))

  local physobject = self:GetPhysicsObject()

  if ( physobject:IsValid() ) then
    physobject:Wake()
    physobject:EnableMotion( true ) 
  end

  if SERVER then
    timer.Simple( 5, function()
      if IsValid( self ) then 
        --local phys = self:GetPhysicsObject()
        --if IsValid( phys ) then
        --  phys:EnableMotion( false ) 
        --end
        self:PhysicsInit( SOLID_NONE ) 
        self:SetMoveType( MOVETYPE_NONE )
      end
    end )
  end

end

function ENT:Use( activator, caller )

  if caller:IsPlayer() and caller:GTeam() == TEAM_SCP then return end

end

if ( SERVER ) then

  function ENT:Think()

  end

else

  function ENT:Draw()

    self:DrawModel()

  end

end