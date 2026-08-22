local surface = surface
local DrawColorModify = DrawColorModify
local CurTime = CurTime
local SysTime = SysTime
local table = table
local pairs = pairs
local ipairs = ipairs
local concommand = concommand
local timer = timer
local ents = ents
local hook = hook
local math = math
local util = util
local net = net
local player = player


local LocalPlayer = LocalPlayer
local CreateSound = CreateSound

BREACH = BREACH || {}
BREACH.Music = BREACH.Music || {}

BREACH.Music.GlobalVolume = BREACH.Music.GlobalVolume || 1
BREACH.Music.AudioVolume = BREACH.Music.AudioVolume || 1

BREACH.EF = {}
NextActionMusicTime = NextActionMusicTime || 0
SongEnd = SongEnd || 0
NextSeeSCPs = NextSeeSCPs || 0
VOLUME_MODIFY = VOLUME_MODIFY || 0
BREACH.Dead = BREACH.Dead || false
BREACH.DieStart = BREACH.DieStart || 0
BREACH.NTFEnter = BREACH.NTFEnter || 0


BREACH.ChaseVolumeCurrent = 0
BREACH.ChaseSoundObject = nil
BREACH.StareTimer = BREACH.StareTimer or 0

local BreachNextThink = 0
local thinkRate = 0.1 

local volumes = {
  ["misc"] = "breach_config_music_misc_volume",
  ["spawn"] = "breach_config_music_spawn_volume",
  ["ambience"] = "breach_config_music_ambient_volume",
  ["panic"] = "breach_config_music_panic_volume",
}

BREACH.Music.VolumeThinkRate = 0.2
BREACH.Music.IgnoreThinkRate = BREACH.Music.IgnoreThinkRate || false

local music_table = include(GM.FolderName .. "/gamemode/config/music.lua")

function BREACH.Music:GetVolume(n)
  if self._volumecache and self.VolumeThink > SysTime() then
    return self._volumecache[n]
  else
    if not self._volumecache then self._volumecache = {} end

    local overall = GetConVar("breach_config_overall_music_volume"):GetFloat()/100

    for i, v in pairs(volumes) do
      self._volumecache[i] = (GetConVar(v):GetFloat() * overall)/100
    end

    self.VolumeThink = SysTime() + self.VolumeThinkRate
    return self._volumecache[n]
  end
end

function BREACH.Music:Play(music_id, start, skipstart, loopskip)
  if not start then start = 0 end

  timer.Remove("Music_PlayAfter")
  self.NextGeneric = SysTime() + 60
  self.NoAutoMusic = true

  local m_tab = music_table[music_id]
  if not m_tab then return end

  timer.Remove("Music_fade")

  if not loopskip then
    self.GlobalVolume = 1
  end

  self._pickedalreadysong = nil
  self._time = start
  self._queue = music_id

  self._mustplayafter = m_tab.playwhenend
  if m_tab.playwhenend then BREACH.Music.IgnoreThinkRate = true end

  self._skipstart = skipstart
  self.StartAt = SysTime()

  if not loopskip then
    self.ActualStartAt = SysTime()
  end

  self._endAt = m_tab.EndAt
  self.fade = m_tab.fade

  if m_tab.IsPercentEndAt then
    self._endAt = nil
  end

  self._loop = m_tab.loop
  BreachNextThink = 0
  self.VolumeThink = 0
  self.NoAutoMusic = false
end

function BREACH.Music:Stop(fade)
  self.NoAutoMusic = true

  timer.Simple(1, function()
    self.NoAutoMusic = false
  end)

  self._endAt = nil

  if fade then
    self.IsFading = true
    timer.Create("Music_fade", 0, 0, function()
      self.GlobalVolume = math.Approach(self.GlobalVolume, 0, FrameTime()*fade)

      if self.MusicPatch and self.MusicPatch:IsValid() then
        self.MusicPatch:SetVolume(self:GetVolume(self.CurrentMusic.volumetype) * self.GlobalVolume * self.AudioVolume)
      end

      if self.GlobalVolume == 0 then
        timer.Remove("Music_fade")
        if self.MusicPatch and self.MusicPatch:IsValid() then
          self.MusicPatch:Stop()
        end
        self._loop = false
        self.GlobalVolume = 1
        self.IsFading = false
      end
    end)
  else
    if self.MusicPatch and self.MusicPatch:IsValid() then
      self.MusicPatch:Stop()
    end
    self._loop = false
  end
end

function StopMusic()
  BREACH.Music:Stop()
end

function FadeMusic( fadelen )
end

local function StartMusic()
  local s_music = net.ReadUInt(32)
  BREACH.Music:Play( s_music )
end
net.Receive( "ClientPlayMusic", StartMusic )

local function FadeeMusic()
  local s_time = net.ReadFloat()
  BREACH.Music:Stop(s_time)
end
net.Receive( "ClientFadeMusic", FadeeMusic )

local function StopeMusic()
  BREACH.Music:Stop()
end
net.Receive( "ClientStopMusic", StopeMusic )


function BREACH.Music:ShouldMusicPlayAtTheMoment()
  if self.StartAt and self._endAt and self.CurrentMusic then
    if ( SysTime() - self.StartAt ) < self._endAt then
      return true
    end
  end
  if self.IsFading then return true end
  return false
end

function BREACH.Music:CanPlayGenericMusic()
  local client = LocalPlayer()
  if not IsValid(client) then return false end
  if client:Health() <= 0 then return false end
  if client:GTeam() == TEAM_SPEC then return false end
  if GetGlobalBool("Evacuation", false) then return false end
  if self.NoAutoMusic then return false end
  return true
end

local action_banned = {
  [ TEAM_SCP ] = true,
  [ TEAM_DZ ] = true,
  [ TEAM_SPEC ] = true
}

function BREACH.Music:ShouldPlayAction()
  local client = LocalPlayer()
  if not IsValid(client) then return false end
  local team = client:GTeam()
  if action_banned[team] then return false end
  return true
end

local amb_cd = 15

function BREACH.Music:PickAmb()
  if self.InToxicZone then return end
  if not self.NextAmb then self.NextAmb = 0 end
  if self.NextAmb >= SysTime() then return end

  local client = LocalPlayer()
  if not IsValid(client) then return end

  if not preparing then
    if math.random(1, 2) == 1 then
      surface.PlaySound("utopia/amb/someone_"..math.random(1, 30)..".mp3")
    else
      if ( client:IsLZ() ) then
        if math.random(0,5) ~= 0 then
          surface.PlaySound("Ambient/Zone1/Ambient"..math.random(0,10)..".ogg")
        else
          surface.PlaySound("Ambient/General/Ambient"..math.random(0,14)..".ogg")
        end
      elseif ( client:IsEntrance() ) then
        if math.random(0,5) ~= 0 then
          surface.PlaySound("Ambient/Zone3/Ambient"..math.random(0,10)..".ogg")
        else
          surface.PlaySound("Ambient/General/Ambient"..math.random(0,14)..".ogg")
        end
      elseif ( client:IsHardZone() ) then
        if math.random(0,5) ~= 0 then
          surface.PlaySound("Ambient/Zone2/Ambient"..math.random(0,10)..".ogg")
        else
          surface.PlaySound("Ambient/General/Ambient"..math.random(0,14)..".ogg")
        end
      end
    end
  end

  self.NextAmb = SysTime() + math.random(50,126)
end

function BREACH.Music:PickPodval()
  local client = LocalPlayer()
  if not IsValid(client) then return end

  if not preparing and client:GetPos():WithinAABox( Vector(-984.122070, -3499.068115, -1405), Vector(2166.351318, -6167.319824, -782) ) then
    if not podvalsound then
      podvalsound = CreateSound( client, "nextoren/Room3_Storage.ogg" )
    end
    if not podvalsound:IsPlaying() then
      podvalsound:Play()
    end
  else
    if podvalsound and podvalsound:IsPlaying() then
      podvalsound:Stop()
    end
  end
end

local generic_cd = 60

function BREACH.Music:PickGenericSong()
  if self.InToxicZone then return end
  if self:ShouldMusicPlayAtTheMoment() then return end
  if self:GetVolume("ambience") == 0 then return end
  if not self:CanPlayGenericMusic() then return end
  if not self.NextGeneric then self.NextGeneric = 0 end
  if self.NextGeneric >= SysTime() then return end
  if self._mustplayafter then return end
  if self.NoAutoMusic then return end

  local client = LocalPlayer()
  if not IsValid(client) then return end

  if not preparing then
    if ( client:IsLZ() ) then
      self:Play(BR_MUSIC_AMBIENT_LZ)
    elseif ( client:IsEntrance() ) then
      self:Play(BR_MUSIC_AMBIENT_OFFICE)
    elseif ( client:IsHardZone() ) then
      self:Play(BR_MUSIC_AMBIENT_HZ)
    elseif ( client:Outside() ) then
      self:Play(BR_MUSIC_AMBIENT_OUTSIDE)
    else
      self:Play(BR_MUSIC_AMBIENT_LZ)
    end
  end

  self.NextGeneric = SysTime() + generic_cd
end

function PlayMusic( str, fadelen, volume )
  
end


local toxicMin = Vector(-3655.074951, 7707.482422, -1511.903564)
local toxicMax = Vector(3680.588135, 12476.416992, 1556.305664)
OrderVectors(toxicMin, toxicMax)

local toxicSoundPatch = nil
local isFadingToxic = false

function BREACH.Music:PickToxicZone()
  if not self:CanPlayGenericMusic() then return end
  local client = LocalPlayer()
  if not IsValid(client) then return end

  
  self.InToxicZone = client:GetPos():WithinAABox(toxicMin, toxicMax)

  if not preparing and self.InToxicZone then
    isFadingToxic = false

    if not toxicSoundPatch then
      toxicSoundPatch = CreateSound(client, "utopia/new_music/scp/d106/tired.ogg")
    end

    
    if not toxicSoundPatch:IsPlaying() then
      toxicSoundPatch:PlayEx(0.001, 100)
      toxicSoundPatch:ChangeVolume(self:GetVolume("ambience") or 1, 2) 
    end

    
    if self.MusicPatch and self.MusicPatch:IsValid() and not self.IsFading then
      self:Stop(2) 
    end
  else
    
    if toxicSoundPatch and toxicSoundPatch:IsPlaying() and not isFadingToxic then
      isFadingToxic = true
      toxicSoundPatch:ChangeVolume(0, 3) 
      
      timer.Simple(3, function()
        
        if toxicSoundPatch and not self.InToxicZone then
          toxicSoundPatch:Stop()
          toxicSoundPatch = nil
          isFadingToxic = false
        end
      end)
    end
  end
end

local horror_tbl = {
  "nextoren/others/horror/horror_0.ogg",
  "nextoren/others/horror/horror_1.ogg",
  "nextoren/others/horror/horror_2.ogg",
  "nextoren/others/horror/horror_3.ogg",
  "nextoren/others/horror/horror_4.ogg",
  "nextoren/others/horror/horror_5.ogg",
  "nextoren/others/horror/horror_9.ogg",
  "nextoren/others/horror/horror_10.ogg",
  "nextoren/others/horror/horror_16.ogg"
}

local darken = false
local darken_lerp = 0

function BREACH.Music:Think()
  local client = LocalPlayer()
  if not IsValid(client) then return end

  self:PickPodval()
  self:PickToxicZone()

  if self._endAt and self.ActualStartAt and (SysTime() - self.ActualStartAt) >= self._endAt then 
    self:Stop(self.fade) 
  end

  
  if self._queue then
    local m_tab = music_table[self._queue]
    if self.MusicPatch and self.MusicPatch:IsValid() then self.MusicPatch:Stop() end

    local snd = m_tab.soundname
    if self._pickedalreadysong then
      snd = self._pickedalreadysong
    else
      if istable(snd) then snd = snd[math.random(#snd)] end
      self._pickedalreadysong = snd
    end

    local filename = string.GetFileFromFilename(snd)
    self.AudioVolume = self.Custom_Volumes and self.Custom_Volumes[filename] or 1

    sound.PlayFile( snd, "noplay", function( music, errCode, errStr )
      if ( IsValid( music ) and not self.music_created ) then
        self.music_created = true
        music:SetVolume(self:GetVolume(m_tab.volumetype) * self.GlobalVolume * self.AudioVolume)
        music:SetTime(self._time)

        self.CurrentMusic = m_tab
        self.MusicDuration = music:GetLength()

        if self._mustplayafter then
          local tract = self._mustplayafter
          local dur = self.MusicDuration
          local start = self.StartAt
          timer.Create("Music_PlayAfter", 0, 0, function()
            if tract and SysTime() >= start + dur-FrameTime() then
              timer.Remove("Music_PlayAfter")
              self.NextGeneric = SysTime() + generic_cd
              self:Play(tract)
            end
          end)
        end

        if m_tab.IsPercentEndAt then
          self._endAt = self.MusicDuration * m_tab.EndAt
        end

        if not self._endAt then 
          if self._loop then 
            music:EnableLooping(true) 
            self._endAt = math.huge 
          else 
            self._endAt = self.MusicDuration 
          end 
        end

        self.MusicPatch = music
        music:Play()
      end
    end )

    self.music_created = false
    self._queue = nil
  end

  if self.MusicPatch and self.MusicPatch:IsValid() and self.CurrentMusic then
    self.MusicPatch:SetVolume(self:GetVolume(self.CurrentMusic.volumetype) * self.GlobalVolume * self.AudioVolume)
  end

  if not self.NoAutoMusic then
    self:PickGenericSong()
  end
  self:PickAmb()

  
  
  
  
  local maxThreat = 0
  local isStaringAtSCP = false 

  if not action_banned[client:GTeam()] and not GetGlobalBool("Evacuation", false) and client:Health() > 0 then
    
    local eyePos = client:EyePos()
    local aimVector = client:GetAimVector()

    for _, v in ipairs( ents.FindInSphere( eyePos, 1000 ) ) do
      if not v:IsPlayer() or v == client or v:GetNoDraw() then continue end
      if v:GTeam() ~= TEAM_SCP or v:GTeam() ~= TEAM_DZ or v:GTeam() ~= TEAM_NTF or v:GetRoleName() == SCP999 then continue end
      --if not v:GetModel():find( "/scp/" ) then continue end

      local scpPos = v:EyePos()
      local dist = eyePos:Distance(scpPos)

      
      local distFactor = 1 - math.Clamp((dist - 150) / 850, 0, 1)

      
      local ent_vector = scpPos - eyePos
      local dir = ent_vector:GetNormalized()
      local dot = aimVector:Dot(dir)

      
      local viewFactor = math.Clamp((dot + 1) / 2, 0.3, 1.0)

      
      if distFactor > 0 then
        local tr = util.TraceLine({
          start = eyePos,
          endpos = scpPos,
          filter = {client, v}
        })

        
        if tr.Fraction == 1 then
          local currentThreat = distFactor * viewFactor
          if currentThreat > maxThreat then maxThreat = currentThreat end

          
          if dot > 0.866 then
            isStaringAtSCP = true 

            
            if NextSeeSCPs < CurTime() or BREACH.StareTimer > 4 then
              darken = true
              timer.Simple( 1.5, function() darken = false end )
              surface.PlaySound( table.Random( horror_tbl ) )
              
              
              BREACH.StareTimer = 0
              
              NextSeeSCPs = CurTime() + math.random( 30, 40 )

              
              net.Start("hg_scp_jumpscare")
              net.SendToServer()
            end
          end
        end
      end
    end
  end

  
  if isStaringAtSCP then
    BREACH.StareTimer = BREACH.StareTimer + FrameTime()
  else
    
    BREACH.StareTimer = math.Approach(BREACH.StareTimer, 0, FrameTime() * 2)
  end

  
  
  

  
  if not BREACH.ChaseSoundObject then
    BREACH.ChaseSoundObject = CreateSound(client, "utopia/new_music/scp/action/CHASE_IT_DOWN.ogg")
    BREACH.ChaseSoundObject:PlayEx(0.001, 100) 
  elseif not BREACH.ChaseSoundObject:IsPlaying() then
    BREACH.ChaseSoundObject:PlayEx(0.001, 100)
  end

  
  if maxThreat > 0 then
    BREACH.ChaseVolumeCurrent = math.Approach(BREACH.ChaseVolumeCurrent, maxThreat, FrameTime() * 1.5)
    self.NoAutoMusic = true 
  else
    BREACH.ChaseVolumeCurrent = math.Approach(BREACH.ChaseVolumeCurrent, 0, FrameTime() * 0.1)
    if BREACH.ChaseVolumeCurrent <= 0.01 then
      self.NoAutoMusic = false 
    end
  end

  local panicVolumeSetting = self:GetVolume("panic") or 1
  local finalChaseVol = BREACH.ChaseVolumeCurrent * panicVolumeSetting

  
  if finalChaseVol < 0.001 then finalChaseVol = 0.001 end

  
  if BREACH.ChaseSoundObject then
    BREACH.ChaseSoundObject:ChangeVolume(finalChaseVol, 0.1)
  end

  
  if finalChaseVol > 0.1 and self.MusicPatch and self.MusicPatch:IsValid() then
    self:Stop(1) 
  end

end




hook.Add( "RenderScreenspaceEffects", "SCPEncounter_ScreenDarken", function()
  if darken_lerp <= 0 and not darken then return end 

  
  darken_lerp = math.Clamp( darken_lerp + ( darken and FrameTime() * 2 or -(FrameTime() * 0.5) ), 0, 1 )
  local darken_eased = math.ease.OutCubic( darken_lerp )

  local tab = {
    [ "$pp_colour_addr" ] = 0,
    [ "$pp_colour_addg" ] = 0,
    [ "$pp_colour_addb" ] = 0,
    [ "$pp_colour_brightness" ] = 0,
    [ "$pp_colour_contrast" ] = 1 - (0.6 * darken_eased),
    [ "$pp_colour_colour" ] = 1,
    [ "$pp_colour_mulr" ] = 0,
    [ "$pp_colour_mulg" ] = 0,
    [ "$pp_colour_mulb" ] = 0
  }
  
  
  DrawColorModify( tab )
end )

hook.Add("Think", "music_think", function()
  if ( CurTime() >= BreachNextThink ) or (BREACH.Music._loop and BREACH.Music.StartAt and BREACH.Music.MusicDuration and SysTime() >= BREACH.Music.StartAt + BREACH.Music.MusicDuration) then 
    BREACH.Music:Think()
    BreachNextThink = CurTime() + thinkRate
  end
end)

hook.Add( "EntityEmitSound", "Breach_Sound_Emit", function( t )

	local snd = string.lower(t.SoundName)
	if snd:find("player/footsteps/") and !snd:find("zcity") then
		--print(snd)
		return false
	end

end)