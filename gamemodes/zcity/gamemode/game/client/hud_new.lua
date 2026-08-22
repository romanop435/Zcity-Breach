local surface = surface
local Material = Material
local draw = draw
local RunConsoleCommand = RunConsoleCommand;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
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


local rust_bg       = Color(18, 16, 15, 245)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_red      = Color(188, 64, 43)
local rust_yellow   = Color(218, 165, 32)
local rust_green    = Color(112, 126, 73)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)
local rust_row      = Color(40, 38, 35, 255)
local rust_text_dim = Color(140, 140, 140)  

function GetPlayerVitality(ply)
    if not IsValid(ply) or not ply:Alive() then return 0 end
    
    local org = ply.organism
    
    if not org then return math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1) end 

    
    if org.otrub then return 0 end 

    
    local blood_pct = math.Clamp((org.blood - 2500) / 2500, 0, 1)
    
    
    local pain_pct = math.Clamp(1 - ((org.pain or 0) / 100), 0, 1)

    
    local oxy_pct = math.Clamp(((org.o2 and org.o2[1] or 30) - 5) / 25, 0, 1)

    
    local consc_pct = org.consciousness or 1

    
    
    local vitality = ((blood_pct * 0.6) + (pain_pct * 0.2) + (oxy_pct * 0.2)) * consc_pct

    return math.Clamp(vitality, 0, 1)
end

local staminaBars = {}
local lastStamina = 0

local healthBars = {}
local lastHealth = 0

local ratio, ratio2, mathRound = ScrW() / 1920, ScrH() / 1080, math.Round


local corner_materials = {
    tl = Material("nextoren_hud/round_boxe_1.png"),
    tr = Material("nextoren_hud/round_boxe_2.png"),
    br = Material("nextoren_hud/round_boxe_3.png"),
    bl = Material("nextoren_hud/round_boxe_4.png") 
}


function SigmaYgliDraw(x, y, w, h, color, cornerSize)
    
    cornerSize = cornerSize or math.min(w, h) * 0.1
    
    
    surface.SetDrawColor(color)
    surface.SetMaterial(corner_materials.bl)
    surface.DrawTexturedRect(x, y, cornerSize, cornerSize)
    
    surface.SetMaterial(corner_materials.br)
    surface.DrawTexturedRect(x + w - cornerSize, y, cornerSize, cornerSize)
    
    surface.SetMaterial(corner_materials.tr)
    surface.DrawTexturedRect(x + w - cornerSize, y + h - cornerSize, cornerSize, cornerSize)
    
    surface.SetMaterial(corner_materials.tl)
    surface.DrawTexturedRect(x, y + h - cornerSize, cornerSize, cornerSize)
end

function SigmaYgliDrawEx(x, y, w, h, color, cornerSize, rotation)
    cornerSize = cornerSize or math.min(w, h) * 0.1
    rotation = rotation or 0
    
    surface.SetDrawColor(color)
    
    local corners = {
        {mat = corner_materials.tl, x = x, y = y},
        {mat = corner_materials.tr, x = x + w - cornerSize, y = y},
        {mat = corner_materials.br, x = x + w - cornerSize, y = y + h - cornerSize},
        {mat = corner_materials.bl, x = x, y = y + h - cornerSize}
    }
    
    for _, corner in ipairs(corners) do
        surface.SetMaterial(corner.mat)
        surface.DrawTexturedRectRotated(
            corner.x + cornerSize/2, 
            corner.y + cornerSize/2, 
            cornerSize, 
            cornerSize, 
            rotation
        )
    end
end

local blur = Material( "pp/blurscreen" )
function DrawBlurRect(x, y, w, h)
	local X, Y = 0,0
	
	if GetConVar("breach_config_blur"):GetInt() == 1 then
	
	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)
		for i = 1, 5 do
			blur:SetFloat("$blur", (i / 4) * (4))
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			render.SetScissorRect(x, y, x+w, y+h, true)
				surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end
   
		local lightness = 125
   

		lightness = 175
	
   draw.RoundedBox(0,x,y,w,h,Color(0,0,0,lightness))
   surface.SetDrawColor(0,0,0)
   //surface.DrawOutlinedRect(x,y,w,h)
   
end

hook.Add("OnScreenSizeChanged", "ScreenScale", function() ratio, ratio2 = ScrW() / 1920, ScrH() / 1080 end)
OGRX = OGRX or {}
function OGRX.ScaleW(px)
    return mathRound(px * ratio)
end

function OGRX.ScaleH(px)
    return mathRound(px * ratio2)
end
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetTextColor = surface.SetTextColor
local surface_SetTextPos = surface.SetTextPos
local surface_DrawText = surface.DrawText
local Color = Color
local surface_SetMaterial = surface.SetMaterial
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawTexturedRect = surface.DrawTexturedRect
local ScrW = ScrW
local ScrH = ScrH
local textAlignMultiplier = {
	[TEXT_ALIGN_CENTER] = 0.5,
	[TEXT_ALIGN_BOTTOM] = 1,
	[TEXT_ALIGN_RIGHT] = 1,
	[TEXT_ALIGN_LEFT] = 0,
	[TEXT_ALIGN_TOP] = 0,
}
function OGRX.outlineText(text, font, x, y, color, xAlign, yAlign, outlineColor)


	xAlign = xAlign or 0


	yAlign = yAlign or 0


	surface_SetFont(font)


	local textWidth, textHeight = surface_GetTextSize(text)


	x = x - textWidth * textAlignMultiplier[xAlign]


	y = y - textHeight * textAlignMultiplier[yAlign]


	surface_SetTextColor(outlineColor) 


	surface_SetTextPos(x - 1, y - 1)


	surface_DrawText(text)


	surface_SetTextPos(x + 1, y - 1)


	surface_DrawText(text)


	surface_SetTextPos(x - 1, y + 1)


	surface_DrawText(text)


	surface_SetTextPos(x + 1, y + 1)


	surface_DrawText(text)


	surface_SetTextColor(color)


	surface_SetTextPos(x, y)


	surface_DrawText(text)


end

function draw.OutlinedBox( x, y, w, h, thickness, clr )
	surface.SetDrawColor( clr || color_white )
	surface.DrawRect( x, y, w, thickness )
	surface.DrawRect( x, y + h - thickness, w, thickness )
	surface.DrawRect( x, y + thickness, thickness, h - thickness * 2 )
	surface.DrawRect( x + w - thickness, y + thickness, thickness, h - thickness * 2 )
end

hook.Add("HUDPaint", "breachfunnycrosshair", function()

	
		
	
		hook.Remove("HUDPaint", "breachfunnycrosshair")
	

end)

local TeamIcons = {

	[ TEAM_CLASSD ] = { mat = Material( "nextoren/gui/roles_icon/class_d.png" ) },
	[ TEAM_SCI ] = { mat = Material( "nextoren/gui/roles_icon/sci.png" ) },
	[ TEAM_SECURITY ] = { mat = Material( "nextoren/gui/roles_icon/sb.png" ) },
	[ TEAM_GUARD ] = { mat = Material( "nextoren/gui/roles_icon/mtf.png" ) },
	[ TEAM_NTF ] = { mat = Material( "nextoren/gui/roles_icon/ntf.png" ) },
	[ TEAM_CHAOS ] = { mat = Material( "nextoren/gui/roles_icon/chaos.png" ) },
	[ TEAM_GOC ] = { mat = Material( "nextoren/gui/roles_icon/goc.png" ) },
	[ TEAM_SPECIAL ] = { mat = Material( "nextoren/gui/roles_icon/sci_special.png" ) },
	[ TEAM_QRT ] = { mat = Material( "nextoren/gui/roles_icon/obr.png" ) },
	[ TEAM_DZ ] = { mat = Material( "nextoren/gui/roles_icon/dz.png" ) },
	[ TEAM_SCP ] = { mat = Material( "nextoren/gui/roles_icon/scp.png" ) },
	[ TEAM_USA ] = { mat = Material( "nextoren/gui/roles_icon/fbi.png" ) },
	[ TEAM_SPEC ] = { mat = Material( "nextoren/gui/roles_icon/sci.png" ) },
	[ TEAM_COTSK ] = { mat = Material( "nextoren/gui/roles_icon/scarlet.png" ) },
	[ 1331 ] = { mat = Material( "nextoren/gui/roles_icon/fbi_agent.png" ) },
	[ TEAM_ALPHA1 ] = { mat = Material( "nextoren/gui/roles_icon/a1.png" ) },
	[ TEAM_AR ] = { mat = Material( "nextoren/gui/roles_icon/ar.png" ) },
	[ TEAM_CBG ] = { mat = Material( "nextoren/gui/roles_icon/crb.png" ) },
	[ TEAM_GRU ] = { mat = Material( "nextoren/gui/roles_icon/gru.png" ) },
	[ TEAM_COMBINE ] = { mat = Material( "nextoren/gui/roles_icon/cmb.png" ) },
	[ TEAM_RESISTANCE ] = { mat = Material( "nextoren/gui/roles_icon/rebel.png" ) },
	[ TEAM_AMERICA ] = { mat = Material( "nextoren/gui/roles_icon/america.png" ) },
	[ TEAM_NAZI ] = { mat = Material( "nextoren/gui/roles_icon/reich.png" ) },

}

function GetActivePlayers()
	local tab = {}
	for k,v in player.Iterator() do
		if IsValid( v ) then

				table.ForceInsert(tab, v)

		end
	end
	return tab
end

surface.CreateFont( "SpectatorTimer", {
	font = "Conduit ITC",
	size = 28,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

local fpsHistory = {}
local nextSample = 0
local maxHistoryTime = 7 
local sampleRate = 0.1    

local blurMaterial = Material("pp/blurscreen")
function GM:HUDPaint()
  local client = LocalPlayer()
  local current_team = LocalPlayer():GTeam()
  local screenwidth = ScrW()
  local screenheight = ScrH()

 	local curTime = SysTime() 
    local frameTime = FrameTime()
    
    
    
    
	
  			if ( current_team == TEAM_SPEC or current_team == TEAM_ARENA or current_team == TEAM_FURRY or current_team == TEAM_ANTIFURRY ) or GetGlobalBool("AliveCanSeeRoundTime", false) then
				if ( !( preparing || postround ) && ( cltime > 0 or GetGlobalBool("NukeTime", false) ) ) then

					local time = string.ToMinutesSeconds( cltime )
					local isNuke = GetGlobalBool("NukeTime", false)
				

					local titleText = "ВРЕМЯ РАУНДА"
					local timeColor = rust_text
					local accentColor = rust_yellow

					if isNuke then
						titleText = "КРИТИЧЕСКАЯ УГРОЗА"
						timeColor = rust_red
						accentColor = rust_red

						if timer.Exists("NukeTimer") then
							time = string.ToMinutesSeconds( timer.TimeLeft("NukeTimer") )
						elseif timer.Exists("NukeTimer2") then
							time = string.ToMinutesSeconds( timer.TimeLeft("NukeTimer2") )
					    else
							time = "СБОЙ"
						end

						if math.floor(CurTime() * 4) % 2 == 0 then
							timeColor = Color(255, 100, 100, 255)
							accentColor = Color(255, 100, 100, 255)
						end
					end

					local boxW = 140
					local boxH = 42
					local boxX = (ScrW() / 2) - (boxW / 2)
					local boxY = ScrH() / 64

					surface.SetDrawColor(rust_bg)
					surface.DrawRect(boxX, boxY, boxW, boxH)

					surface.SetDrawColor(rust_panel)
					surface.DrawRect(boxX, boxY, boxW, 16)

					surface.SetDrawColor(accentColor)
					surface.DrawRect(boxX, boxY + 16, boxW, 2)

					surface.SetDrawColor(rust_outline)
					surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 1)

					draw.SimpleText(titleText, "MogM_4", boxX + boxW / 2, boxY + 8, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText(time, "MogM_6", boxX + boxW / 2, boxY + 29, timeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				end
			end

if ( gamestarted != true ) then

		local rust_bg       = Color(18, 16, 15, 245)
		local rust_outline  = Color(255, 255, 255, 15)
		local rust_yellow   = Color(218, 165, 32, 255)
		local rust_green    = Color(112, 126, 73, 255)
		local rust_red      = Color(188, 64, 43, 255)
		local rust_text     = Color(230, 230, 230, 255)
		local rust_dim      = Color(140, 140, 140, 255)

		if ( !GetGlobalBool("EnoughPlayersCountDown", false) ) then

			if ( client.MusicPlaying ) then
				client.MusicPlaying = nil
				BREACH.Music:Stop()
			end

			local text1 = string.upper(L("l:waiting_for_players") or "ОЖИДАНИЕ ИГРОКОВ")
			local remaining = math.max(0, 10 - #GetActivePlayers())
			local text2 = string.upper((L("l:waiting_for_players_pt2") or "ОСТАЛОСЬ") .. " " .. remaining .. " " .. (L("l:waiting_for_players_pt3") or ""))

			surface.SetFont("MogM_5")
			local tw1, th1 = surface.GetTextSize(text1)
			local tw2, th2 = surface.GetTextSize(text2)

			local bw = math.max(tw1, tw2) + 60 
			local bh = th1 + th2 + 16
			
			local bx = (ScrW() / 2) - (bw / 2)
			local by = ScrH() * 0.03 

			surface.SetDrawColor(rust_bg)
			surface.DrawRect(bx, by, bw, bh)

			local pulse = math.abs(math.sin(CurTime() * 3))
			surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 100 + 155 * pulse)
			surface.DrawRect(bx, by, bw, 2)

			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(bx, by, bw, bh, 1)

			draw.SimpleText(text1, "MogM_5", bx + bw / 2, by + 8, rust_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(text2, "MogM_5", bx + bw / 2, by + 8 + th1, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		else

			if ( !client.MusicPlaying ) then
				client.MusicPlaying = true
				BREACH.Music:Play(BR_MUSIC_COUNTDOWN)
			end

			local time_left = math.Round( GetGlobalInt("EnoughPlayersCountDownStart", CurTime() + 180) - CurTime() )

			if ( time_left > 10 ) then
				local ltime = (#GetActivePlayers() >= 20) and 840 or 720
				
				local text1 = string.upper(#GetActivePlayers() .. " " .. (L("l:starting_pt1") or "ИГРОКОВ ГОТОВО"))
				local text2 = string.upper((L("l:starting_pt3") or "ДО СТАРТА: ") .. " " .. time_left .. " СЕК")

				surface.SetFont("MogM_5")
				local tw1, th1 = surface.GetTextSize(text1)
				local tw2, th2 = surface.GetTextSize(text2)

				local bw = math.max(tw1, tw2) + 60 
				local bh = th1 + th2 + 16
				local bx = (ScrW() / 2) - (bw / 2)
				local by = ScrH() * 0.03 

				surface.SetDrawColor(rust_bg)
				surface.DrawRect(bx, by, bw, bh)

				surface.SetDrawColor(rust_green)
				surface.DrawRect(bx, by, bw, 2)

				surface.SetDrawColor(rust_outline)
				surface.DrawOutlinedRect(bx, by, bw, bh, 1)

				draw.SimpleText(text1, "MogM_5", bx + bw / 2, by + 8, rust_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText(text2, "MogM_5", bx + bw / 2, by + 8 + th1, rust_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			else
				local cx, cy = ScrW() / 2, ScrH() / 2 - 50
				
				local pulse = math.abs(math.sin(CurTime() * 10))
				local alphaMult = 150 + 105 * pulse

				local boxW, boxH = 200, 160
				local boxX = cx - boxW / 2
				local boxY = cy - boxH / 2

				draw.SimpleText(time_left, "Waiting", cx, boxY + 30, ColorAlpha(rust_red, alphaMult), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			end

		end

	end

  if ( BREACH.Nuked ) then
		
		if ( CurTime() - BREACH.NukeStart <= 0.2 ) then

			surface.SetDrawColor(255, 255, 255, 255 * math.Clamp( ( CurTime() - BREACH.NukeStart ) * 5, 0, 1) );

		else

			surface.SetDrawColor(255, 255, 255, 255 * ( 1 - math.Clamp( ( ( CurTime() - BREACH.NukeStart ) - 0.2) / 3, 0, 1) ) );

		end

		surface.DrawRect(0, 0, ScrW(), ScrH());
	end

	if ( BREACH.f_RoundStart ) then

		if ( CurTime() - BREACH.f_RoundStart <= 10 ) then

			if ( alpha < 255 ) then

				alpha = math.Approach( alpha, 255, FrameTime() * 256 )

			end

		else

			if ( alpha > 0 ) then

				alpha = math.Approach( alpha, 0, FrameTime() * 512 )

			end

		end

		surface.SetDrawColor( 0, 0, 0, alpha );

		if ( CurTime() - BREACH.f_RoundStart > 15 ) then

			BREACH.f_RoundStart = nil
			alpha = 0

		end

		surface.DrawRect( 0, 0, ScrW(), ScrH() )

	end

	if ( client.IntroBlackOut ) then

		if ( CurTime() - BREACH.NTFEnter <= .2 ) then

			surface.SetDrawColor( 0, 0, 0, 255 * math.Clamp( ( CurTime() - BREACH.NTFEnter ) * 5, 0, 1 ) )

		else

			surface.SetDrawColor( 0, 0, 0, 255 * ( 1 - math.Clamp( ( (CurTime() - BREACH.NTFEnter ) - 0.2) / 3, 0, 1) ) );

		end

		surface.DrawRect( 0, 0, ScrW(), ScrH() );

	end

	if ( client.BlackScreen ) then

		surface.SetDrawColor( color_black )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )

	end

end

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudDeathNotice = true,
	CHudPoisonDamageIndicator = true,
	CHudSquadStatus = true,
	CHudWeaponSelection = true,
	CHudCrosshair = true,
	CHudDamageIndicator = true,
	CHUDQuickInfo = true,
	CHudVoiceStatus = true,
	CHUDAutoAim = true,
	CHudVoiceSelfStatus = true,
	CHudChat = true
}

function GM:HUDDrawPickupHistory()
end

function GetAmmoString(tbl)
	for k, v in ipairs(tbl) do

			if v == "semi" or v == "auto" then
				return "МАГАЗИНЫ"

			elseif v == "bolt" then
				return "ПАТРОНЫ"

			elseif v == "pump" then
				return "КАРТЕЧИ"

			else
				return "БОЕЗАПАС"
			end

	end
end

local alpha_color = 0

hook.Add( "HUDShouldDraw", "HideHUDElements", function( name )
	if name == "CHudWeaponSelection" and GetConVar( "br_new_eq" ):GetInt() == 1 then
		return false
	end
	if hide[ name ] then return false end
end )

local MATS = {
	menublack = Material("nextoren_hud/inventory/menublack.png"),//Material("pp/blurscreen"),
	blanc = Material("hud_scp/texture_blanc.png"),
	meter = Material("hud_scp/meter.png"),
	time = Material("hud_scp/timeicon.png"),
	user = Material("hud_scp/user.png"),
	scp = Material("hud_scp/scp.png"),
	ammo = Material("hud_scp/ammoicon.png"),
	mag = Material("hud_scp/magicon.png"),
	blink = Material("hud_scp/blinkicon.png"),
	hp = Material("hud_scp/hpicon.png"),
	sprint = Material("hud_scp/sprinticon.png"),
}

surface.CreateFont("ClassName", {font = "Trebuchet24",
                                    size = 28,
                                    weight = 1000})
surface.CreateFont("TimeLeft",     {font = "Trebuchet24",
                                    size = 24,
                                    weight = 800})
surface.CreateFont("HealthAmmo",   {font = "Trebuchet24",
                                    size = 24,
                                    weight = 750})

surface.CreateFont( "LuctusScoreFontBigest", { font = "Montserrat",extended = true, size = ScreenScale(17), weight = 800, antialias = true, bold = true })
surface.CreateFont( "LuctusScoreFontBig", { font = "Montserrat",extended = true, size = ScreenScale(12), weight = 800, antialias = true, bold = true })
surface.CreateFont( "LuctusScoreFontMiniBig", { font = "Montserrat",extended = true, size = ScreenScale(9), weight = 800, antialias = true, bold = true })
surface.CreateFont( "LuctusScoreFontSmall", { font = "Montserrat",extended = true, size = ScreenScale(7), weight = 700, antialias = true, bold = true })
surface.CreateFont( "LuctusScoreFontSmall2218", { font = "Montserrat",extended = true, size = ScreenScale(7), weight = 700, antialias = false, bold = true })
surface.CreateFont( "LuctusScoreFontSmallest", { font = "Montserrat",extended = true, size = ScreenScale(6), weight = 700, antialias = false, bold = true })
surface.CreateFont( "LuctusScoreFontSmallest2", { font = "Montserrat",extended = true, size = ScreenScale(5), weight = 400, antialias = false, bold = true })
surface.CreateFont( "LuctusScoreFontSmallest3", { font = "Montserrat",extended = true, size = ScreenScale(4), weight = 400, antialias = false, bold = true })

surface.CreateFont( "Event_Terminal", {
	font = "Courier New",
	extended = false,
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

surface.CreateFont( "TimeMisterFreeman", {
	font = "B52",
	extended = true,
	size = 24,
	antialias = true,
	shadow = false
})

surface.CreateFont( "Buba", {
	font = "Lorimer No 2 Stencil", 
	extended = true,
	size = 60,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Buba7", {
	font = "Lorimer No 2 Stencil", 
	extended = true,
	size = 19,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Buba6", {
	font = "Lorimer No 2 Stencil", 
	extended = true,
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


surface.CreateFont( "Buba5", {
	font = "Lorimer No 2 Stencil", 
	extended = true,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 3,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BubaChat", {
	font = "Lorimer No 2 Stencil", 
	extended = true,
	size = 18,
	weight = 500,
	blursize = 0,
	scanlines = 3,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Buba55", {
	font = "Lorimer No 2 Stencil", 
	extended = true,
	size = 45,
	weight = 500,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Buba3", {
	font = "Righteous", 
	extended = true,
	size = 30,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local clr_red = Color( 255, 0, 0 )

function Pulsate( c )

  return math.abs( math.sin( CurTime() * c ) )

end

function Fluctuate( c )

  return ( math.cos( CurTime() * c ) + 1 ) * .5

end

surface.CreateFont( "Buba2", {
	font = "LittleMerry", 
	extended = false,
	size = 48,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

function CreateKillFeed(data)

	if !GetConVar("breach_config_killfeed"):GetBool() then return end

	if !IsValid(KILLFEED_UI) then

		KILLFEED_UI = vgui.Create("DPanel")

		local scrw = ScrW()

		local w, h = scrw, ScrH()

		w = w/3.6

		KILLFEED_UI:SetSize(w, h)
		KILLFEED_UI:SetPos(scrw - w, 0)

		KILLFEED_UI.Paint = function(self, w, h)
		end

		local i_list = vgui.Create("DListLayout", KILLFEED_UI)
		i_list:Dock(FILL)

		KILLFEED_UI.list = i_list

	end

	local i_list = KILLFEED_UI.list

	local killfeed_font = "killfeed_font"
	local size_w, size_h = KILLFEED_UI:GetSize()

	local h = 1

	local all_text = ""

	for i = 1, #data do

		local v = data[i]

		if isstring(v) then
			all_text = all_text..v
		end

	end

	surface.SetFont(killfeed_font)
	local t_w, t_h = surface.GetTextSize(all_text)

	t_h = t_h + 5

	local text_gui = i_list:Add("DPanel")
	text_gui:Dock(TOP)

	text_gui:SetSize(size_w, t_h)
	text_gui.Paint = function() end

	text_gui:SetAlpha(0)
	text_gui:AlphaTo(255,1)

	text_gui:AlphaTo(0, 1, 6, function()

    text_gui:Remove()

	end)

	local _w = 0
	local _h = 0
	local prev = nil
	local lastcol = nil
	for i = 1, #data do
		local v = data[i]
		if isstring(v) then
			v = L(GetLangRole(v))
			local my_w = surface.GetTextSize(v)
			local text = vgui.Create("DPanel", text_gui)
			text:SetSize(my_w, t_h)
			if _w + my_w > size_w then
				_h = _h + t_h
				_w = 0
				text_gui:SetSize(size_w, t_h + _h)
			else
				text_gui:SetSize(size_w, t_h + _h)
				no = true
			end
			text:SetPos(_w, _h)
			local col = lastcol
			text.Paint = function(self, w, h)

				draw.DrawText(v, killfeed_font, 0, 0, col, TEXT_ALIGN_LEFT)

			end
			_w = _w + my_w
		elseif IsColor(v) then
			lastcol = v
		end

		prev = v

	end

end

net.Receive("breach_killfeed", function(len)
	local data = net.ReadTable() 
	CreateKillFeed(data)
end)

local clr_gray = Color( 198, 198, 198 )
local clr_green = Color( 0, 180, 0 )

local function UIU_Ending( complete )

	StopMusic()

	local status

	if ( complete ) then

		status = L"l:ending_mission_complete"
		
		timer.Simple(0.1, function()
			surface.PlaySound( "nextoren/new_onp_end.wav" )
		end)

	else

		status = L"l:ending_mission_failed"
		timer.Simple(0.1, function()
			surface.PlaySound( "nextoren/new_onp_end.wav" )
		end)
		

	end

	local client = LocalPlayer()

	local screenwidth, screenheight = ScrW(), ScrH()

	client.Ending_window = vgui.Create( "DPanel" )
	client.Ending_window:SetSize( screenwidth, screenheight )
	client.Ending_window.Name = L"l:cutscene_subject " .. client:GetNamesurvivor()
	if client:GetRoleName() == "UIU Spy" then
		client.Ending_window.Name = client.Ending_window.Name..L", l:cutscene_undercover_agent"
	end
	client.Ending_window.StartTime = CurTime()
	client.Ending_window.Status = L"l:cutscene_status " .. status
	client.Ending_window.Icon_Alpha = 0

	local screenmiddle_w, screenmiddle_h = screenwidth / 2, screenheight / 2

	local name_string_table, status_string_table = string.Explode( "", client.Ending_window.Name, true ), string.Explode( "", client.Ending_window.Status, true )

	local actual_string_1, actual_string_2 = "", ""

	client.Ending_window.Paint = function( self, w, h )
		
		draw.RoundedBox( 0, 0, 0, w, h, color_black )

		if ( self.Icon_Alpha < 255 ) then

			self.Icon_Alpha = math.Approach( self.Icon_Alpha, 255, RealFrameTime() * 256 )

		end

		surface.SetDrawColor( ColorAlpha( color_white, self.Icon_Alpha ) )
		surface.SetMaterial( TeamIcons[ TEAM_USA ].mat )
		surface.DrawTexturedRect( screenmiddle_w - 128, screenmiddle_h - 128, 256, 256 )

		if ( actual_string_1:len() != #name_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_1 = actual_string_1 .. name_string_table[ #actual_string_1 + 1 ]

		elseif ( actual_string_2:len() != #status_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_2 = actual_string_2 .. status_string_table[ #actual_string_2 + 1 ]

		end

		draw.SimpleTextOutlined( actual_string_1, "MainMenuFont", screenmiddle_w, screenmiddle_h * .9, desc_clr_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		draw.SimpleTextOutlined( actual_string_2, "MainMenuFont", screenmiddle_w, screenmiddle_h, desc_clr_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )

		if ( self.StartTime < CurTime() - 7 ) then

			if ( !self.alpha_variable ) then

				self.alpha_variable = 255

			end

			self.alpha_variable = math.Approach( self.alpha_variable, 0, RealFrameTime() * 512 )

			if ( self.alpha_variable == 0 ) then

				if ( !self.CallFade ) then

					self.CallFade = true
					FadeMusic( 10 )

				end

			end

			self:SetAlpha( self.alpha_variable )

		end

	end

end

surface.CreateFont("GOC_Huge", { font = "Hitmarker Normal", size = 80, weight = 800, extended = true })
surface.CreateFont("GOC_Small", { font = "Hitmarker Normal", size = 22, weight = 600, extended = true })

local goc_icon = Material("nextoren/gui/roles_icon/goc.png", "smooth")

local goc_cyan  = Color(198, 0, 0)
local rust_bg   = Color(10, 9, 8, 255)

function GOCStart()
	local client = LocalPlayer()
	client:ConCommand("stopsound")

	if BREACH and BREACH.Music then
		BREACH.Music:Play(BR_MUSIC_SPAWN_GOC)
	end

	local str_name   = string.upper(BREACH.TranslateString("l:cutscene_subject_name ") .. client:GetNamesurvivor())
	local str_status = string.upper(BREACH.TranslateString("l:cutscene_objective l:cutscene_disaster_relief"))
	local str_time   = string.upper(BREACH.TranslateString("l:cutscene_time_after_disaster ") .. string.ToMinutesSeconds(GetRoundTime() - cltime))

	if IsValid(GOC_CUTSCENE_PANEL) then GOC_CUTSCENE_PANEL:Remove() end

	local w, h = ScrW(), ScrH()
	GOC_CUTSCENE_PANEL = vgui.Create("DPanel")
	local pnl = GOC_CUTSCENE_PANEL
	pnl:SetSize(w, h)
	pnl:SetPos(0, 0)
	pnl:SetZPos(32767)

	pnl.InitTime = SysTime()
	pnl.DropTime = pnl.InitTime + 24.2 
	pnl.FadeTime = pnl.DropTime + 6.0  
	
	pnl.AlphaMult = 1
	pnl.DescPlayed = false

	pnl.Paint = function(self, pw, ph)
		local t = SysTime()

		if t < self.DropTime then
			surface.SetDrawColor(rust_bg)
			surface.DrawRect(0, 0, pw, ph)

            local timeLeft = math.max(0, self.DropTime - t)
            local ms = math.floor((timeLeft % 1) * 100)
            local sec = math.floor(timeLeft)
            local countdownStr = L("l:goc_arrival_in") .. string.format("%02d:%02d", sec, ms)

            local cx, cy = pw / 2, ph / 2

            local pulse = (math.sin(t * 4) + 1) / 2

			draw.SimpleText(L("l:goc_arrival"), "GOC_Small", cx, cy - 15, ColorAlpha(goc_cyan, 150 + 105 * pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(countdownStr, "GOC_Small", cx, cy + 15, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			return
		end

		local dropT = t - self.DropTime
		
		if t >= self.FadeTime then
			self.AlphaMult = Lerp(FrameTime() * 4, self.AlphaMult, 0)
			
			if not self.DescPlayed then
				self.DescPlayed = true
				if DrawNewRoleDesc then DrawNewRoleDesc() end
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end

			if self.AlphaMult <= 0.01 then
				FadeMusic(15)
				self:Remove()
				return
			end
		end

		surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 255 * self.AlphaMult)
		surface.DrawRect(0, 0, pw, ph)

        surface.SetDrawColor(255, 255, 255, 10 * self.AlphaMult)
        surface.SetMaterial(goc_icon)
        local iconSize = ph * 0.8
        surface.DrawTexturedRect(pw - iconSize + 100, ph/2 - iconSize/2, iconSize, iconSize)

        local glitchX = 0
        if dropT < 0.3 then glitchX = math.random(-15, 15) end

        local cy = ph / 2 + 30
		local startX = pw * 0.15
		local lineW = pw * 0.7

		local currentLineW = Lerp(math.ease.OutExpo(math.Clamp(dropT / 0.5, 0, 1)), 0, lineW)

		surface.SetDrawColor(goc_cyan.r, goc_cyan.g, goc_cyan.b, 255 * self.AlphaMult)
		surface.DrawRect(startX + glitchX, cy, currentLineW, 4)

        if dropT < 0.1 then return end

        local textAlpha = 255 * self.AlphaMult * math.ease.OutSine(math.Clamp((dropT - 0.1) / 0.4, 0, 1))

		draw.SimpleText("GLOBAL OCCULT COALITION", "GOC_Huge", startX + glitchX, cy - 10, Color(rust_text.r, rust_text.g, rust_text.b, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

        local ty = cy + 20
        local step = 30
        
		draw.SimpleText(str_name, "GOC_Small", startX + glitchX, ty, Color(rust_dim.r, rust_dim.g, rust_dim.b, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(str_status, "GOC_Small", startX + glitchX, ty + step, Color(goc_cyan.r, goc_cyan.g, goc_cyan.b, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(str_time, "GOC_Small", startX + glitchX, ty + step * 2, Color(rust_dim.r, rust_dim.g, rust_dim.b, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

local clr_text = Color( 180, 0, 0, 210 )
local onp_icon = TeamIcons[ TEAM_USA ].mat

function ONPStart()

	local client = LocalPlayer()

	if ( IsValid( client.Faction_intro ) ) then

		client.Faction_intro:Remove()

	end

	client:ConCommand( "stopsound" )

	client.Faction_intro = vgui.Create( "DPanel" )
	client.Faction_intro:SetSize( ScrW(), ScrH() )
	client.Faction_intro.StartTime = CurTime() + 2
	client.Faction_intro.Name = BREACH.TranslateString"l:cutscene_subject_name " .. client:GetNamesurvivor()
	client.Faction_intro.Time = BREACH.TranslateString"l:cutscene_time_after_disaster " .. string.ToMinutesSeconds( GetRoundTime() - ( cltime - 28 ) )

	local name_string_table = string.Explode( "", client.Faction_intro.Name, true )
	local time_string_table = string.Explode( "", client.Faction_intro.Time )

	local actual_string_1, actual_string_2 = "", ""

	local screenmiddle_w, screenmiddle_h = ScrW() / 2, ScrH() / 2

	client.Faction_intro.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, color_black )

		if ( ( self.StartTime ) < CurTime() ) then

			surface.SetDrawColor( ColorAlpha( color_white, 210 ) )
			surface.SetMaterial( onp_icon )
			surface.DrawTexturedRect( screenmiddle_w - 128, screenmiddle_h - 128, 256, 256 )

		end

		if ( ( self.StartTime - 1.9 ) < CurTime() && !self.MusicPlaying ) then

			self.MusicPlaying = true
			BREACH.Music:Play(BR_MUSIC_SPAWN_FBI)

		end

		

		if ( self.StartTime < CurTime() - 5 ) then

			if ( !self.alpha_variable ) then

				self.alpha_variable = 255

			end
			self.alpha_variable = math.Approach( self.alpha_variable, 0, RealFrameTime() * 512 )
			if self.alpha_variable != 255 and self.DescPlayed != true then
				self.DescPlayed = true
				DrawNewRoleDesc()
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end
			self:SetAlpha( self.alpha_variable )

		end

	end

end

local clr_text = Color( 180, 0, 0, 210 )
local onp_icon = TeamIcons[ 1331 ].mat

function SHTURMONPStart()

	local client = LocalPlayer()

	if ( IsValid( client.Faction_intro ) ) then

		client.Faction_intro:Remove()

	end

	client:ConCommand( "stopsound" )

	client.Faction_intro = vgui.Create( "DPanel" )
	client.Faction_intro:SetSize( ScrW(), ScrH() )
	client.Faction_intro.StartTime = CurTime() + 2
	client.Faction_intro.Name = BREACH.TranslateString"l:cutscene_subject_name " .. client:GetNamesurvivor()
	client.Faction_intro.Time = BREACH.TranslateString"l:a1_task"

	local name_string_table = string.Explode( "", client.Faction_intro.Name, true )
	local time_string_table = string.Explode( "", client.Faction_intro.Time )

	local actual_string_1, actual_string_2 = "", ""

	local screenmiddle_w, screenmiddle_h = ScrW() / 2, ScrH() / 2

	client.Faction_intro.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, color_black )

		if ( ( self.StartTime - 8 ) < CurTime() ) then

			surface.SetDrawColor( ColorAlpha( color_white, 210 ) )
			surface.SetMaterial( onp_icon )
			surface.DrawTexturedRect( screenmiddle_w - 128, screenmiddle_h - 128, 256, 256 )

		end

		if ( ( self.StartTime - 6 ) < CurTime() && !self.MusicPlaying ) then

			self.MusicPlaying = true
			BREACH.Music:Play(BR_MUSIC_SPAWN_FBI_AGENTS)

		end

		if ( self.StartTime > CurTime() ) then return end

		if ( actual_string_1:len() != #name_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_1 = actual_string_1 .. name_string_table[ #actual_string_1 + 1 ]

		elseif ( actual_string_2:len() != #time_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_2 = actual_string_2 .. time_string_table[ #actual_string_2 + 1 ]

		end

		draw.SimpleTextOutlined( actual_string_1, "MainMenuFont", screenmiddle_w, screenmiddle_h * .9, clr_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		draw.SimpleTextOutlined( actual_string_2, "MainMenuFont", screenmiddle_w, screenmiddle_h, clr_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )

		if ( self.StartTime < CurTime() - 8 ) then

			if ( !self.alpha_variable ) then

				self.alpha_variable = 255

			end
			self.alpha_variable = math.Approach( self.alpha_variable, 0, RealFrameTime() * 512 )
			if self.alpha_variable != 255 and self.DescPlayed != true then
				self.DescPlayed = true
				DrawNewRoleDesc()
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end
			self:SetAlpha( self.alpha_variable )

		end

	end

end

surface.CreateFont("DZ_Smooth_Huge", { font = "Hitmarker Normal", size = 75, weight = 300, extended = true })
surface.CreateFont("DZ_Smooth_Small", { font = "Hitmarker Normal", size = 24, weight = 400, extended = true })

local rust_bg = Color(8, 8, 8, 255)

function SHStart()
	local client = LocalPlayer()

	if IsValid(client.Faction_intro) then
		client.Faction_intro:Remove()
	end

	client:ConCommand("stopsound")

	local dz_color = gteams.GetColor(TEAM_DZ) or Color(0, 198, 100)

	local str_name   = string.upper(BREACH.TranslateString("l:cutscene_subject_name ") .. client:GetNamesurvivor())
	local str_status = string.upper(BREACH.TranslateString("l:cutscene_objective l:cutscene_scp_rescue"))
	local str_time   = string.upper(BREACH.TranslateString("l:cutscene_time_after_disaster ") .. string.ToMinutesSeconds(GetRoundTime() - (cltime - 23)))

	local w, h = ScrW(), ScrH()
	client.Faction_intro = vgui.Create("DPanel")
	local pnl = client.Faction_intro
	pnl:SetSize(w, h)
	pnl:SetPos(0, 0)
	pnl:SetZPos(32767)

	pnl.InitTime = SysTime()
	pnl.MusicTime = pnl.InitTime + 4.0   
	pnl.RevealTime = pnl.InitTime + 5.0  
	pnl.FadeTime = pnl.RevealTime + 6.0  
	
	pnl.MusicPlayed = false
	pnl.DescPlayed = false

	local cx, cy = w / 2, h / 2

	pnl.Paint = function(self, pw, ph)
		local t = SysTime()

		if t >= self.MusicTime and not self.MusicPlayed then
			self.MusicPlayed = true
			if BREACH and BREACH.Music then
				BREACH.Music:Play(BR_MUSIC_SPAWN_DZ)
			end
		end

		local globalAlpha = 1
		local logoProgress = 0
		local text1Alpha, text2Alpha, text3Alpha, text4Alpha = 0, 0, 0, 0

		local logoT = math.Clamp((t - self.InitTime) / 6.0, 0, 1)
		logoProgress = math.ease.InOutSine(logoT)

		if t >= self.RevealTime then
			local revealT = t - self.RevealTime
			text1Alpha = math.ease.InOutSine(math.Clamp(revealT / 1.5, 0, 1))
			text2Alpha = math.ease.InOutSine(math.Clamp((revealT - 1.0) / 1.5, 0, 1))
			text3Alpha = math.ease.InOutSine(math.Clamp((revealT - 1.5) / 1.5, 0, 1))
			text4Alpha = math.ease.InOutSine(math.Clamp((revealT - 2.0) / 1.5, 0, 1))
		end

		if t >= self.FadeTime then
			local fadeT = math.Clamp((t - self.FadeTime) / 3.0, 0, 1)
			globalAlpha = 1 - math.ease.InOutSine(fadeT)

			if not self.DescPlayed then
				self.DescPlayed = true
				if DrawNewRoleDesc then DrawNewRoleDesc() end
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end

			if globalAlpha <= 0.01 then
				FadeMusic(15)
				self:Remove()
				return
			end
		end
		
		surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 255 * globalAlpha)
		surface.DrawRect(0, 0, pw, ph)

		local dz_icon = TeamIcons and TeamIcons[TEAM_DZ] and TeamIcons[TEAM_DZ].mat or Material("nextoren/gui/roles_icon/dz.png", "smooth")
		
		surface.SetDrawColor(20, 20, 20, 255 * logoProgress * globalAlpha)
		surface.SetMaterial(dz_icon)
		local iconSize = ph * 0.7
		surface.DrawTexturedRect(cx - iconSize/2, cy - iconSize/2, iconSize, iconSize)

		local startY = cy - 60
		local step = 35

		if text1Alpha > 0 then
			draw.SimpleText("ДЛАНЬ ЗМЕЯ", "DZ_Smooth_Huge", cx, startY - 40, ColorAlpha(dz_color, 255 * text1Alpha * globalAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			local lineW = 400 * text1Alpha
			surface.SetDrawColor(dz_color.r, dz_color.g, dz_color.b, 100 * text1Alpha * globalAlpha)
			surface.DrawRect(cx - lineW/2, startY - 20, lineW, 1)
		end

		if text2Alpha > 0 then
			draw.SimpleText(str_name, "DZ_Smooth_Small", cx, startY, ColorAlpha(color_white, 200 * text2Alpha * globalAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		if text3Alpha > 0 then
			draw.SimpleText(str_status, "DZ_Smooth_Small", cx, startY + step, ColorAlpha(dz_color, 255 * text3Alpha * globalAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		if text4Alpha > 0 then
			draw.SimpleText(str_time, "DZ_Smooth_Small", cx, startY + step * 2, ColorAlpha(color_white, 100 * text4Alpha * globalAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end
end



local cult_icon = TeamIcons[ TEAM_COTSK ].mat

function CultStart()

	local clr_text = gteams.GetColor( TEAM_COTSK )

	local client = LocalPlayer()

	if ( IsValid( client.Faction_intro ) ) then

		client.Faction_intro:Remove()

	end

	client:ConCommand( "stopsound" )

	timer.Simple( 1, function()

		

	end )

	client.Faction_intro = vgui.Create( "DPanel" )
	client.Faction_intro:SetSize( ScrW(), ScrH() )
	client.Faction_intro.StartTime = CurTime() + 25
	client.Faction_intro.Name = BREACH.TranslateString"l:cutscene_name " .. client:GetNamesurvivor()
	client.Faction_intro.Status = BREACH.TranslateString"l:cutscene_objective l:cutscene_namaz"
	client.Faction_intro.Time = BREACH.TranslateString"l:cutscene_time_after_disaster " .. string.ToMinutesSeconds( GetRoundTime() - ( cltime - 23 ) )

	local name_string_table = string.Explode( "", client.Faction_intro.Name, true )
	local status_string_table = string.Explode( "", client.Faction_intro.Status, true )
	local time_string_table = string.Explode( "", client.Faction_intro.Time )

	local actual_string_1, actual_string_2, actual_string_3 = "", "", ""

	local screenmiddle_w, screenmiddle_h = ScrW() / 2, ScrH() / 2

	client.Faction_intro.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, color_black )

		if ( ( self.StartTime - 9 ) < CurTime() ) then

			surface.SetDrawColor( ColorAlpha( color_white, 210 ) )
			surface.SetMaterial( cult_icon )
			surface.DrawTexturedRect( screenmiddle_w - 128, screenmiddle_h - 128, 256, 256 )

		end

		if ( ( self.StartTime - 24 ) < CurTime() && !self.MusicPlaying ) then

			self.MusicPlaying = true
			BREACH.Music:Play(BR_MUSIC_SPAWN_CULT)

		end

		if ( self.StartTime > CurTime() ) then return end

		if ( actual_string_1:len() != #name_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_1 = actual_string_1 .. name_string_table[ #actual_string_1 + 1 ]

		elseif ( actual_string_2:len() != #status_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_2 = actual_string_2 .. status_string_table[ #actual_string_2 + 1 ]

		elseif ( actual_string_3:len() != #time_string_table && ( self.NextSymbol || 0 ) < CurTime() ) then

			self.NextSymbol = CurTime() + .025
			actual_string_3 = actual_string_3 .. time_string_table[ #actual_string_3 + 1 ]

		end

		draw.SimpleTextOutlined( actual_string_1, "MainMenuFont", screenmiddle_w, screenmiddle_h * .8, clr_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		draw.SimpleTextOutlined( actual_string_2, "MainMenuFont", screenmiddle_w, screenmiddle_h * .9, clr_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		draw.SimpleTextOutlined( actual_string_3, "MainMenuFont", screenmiddle_w, screenmiddle_h, clr_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )

		if ( self.StartTime < CurTime() - 8 ) then

			if ( !self.alpha_variable ) then

				self.alpha_variable = 255

			end

			self.alpha_variable = math.Approach( self.alpha_variable, 0, RealFrameTime() * 512 )
			if self.alpha_variable != 255 and self.DescPlayed != true then
				self.DescPlayed = true
				DrawNewRoleDesc()
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end
			self:SetAlpha( self.alpha_variable )

		end

	end

end

local ntf_icon = TeamIcons[ TEAM_NTF ].mat

function NTFStart()

	local clr_text = gteams.GetColor( TEAM_NTF )

	local client = LocalPlayer()

	if ( IsValid( client.Faction_intro ) ) then

		client.Faction_intro:Remove()

	end

	client:ConCommand( "stopsound" )

	timer.Simple(FrameTime(), function()
		BREACH.Music:Play(BR_MUSIC_SPAWN_NTF)
	end)

	client.Faction_intro = vgui.Create( "DPanel" )
	client.Faction_intro:SetSize( ScrW(), ScrH() )
	client.Faction_intro.StartTime = CurTime() + 0.2

	local name_string_table = string.Explode( "", client.Faction_intro.Name, true )
	local status_string_table = string.Explode( "", client.Faction_intro.Status, true )
	local time_string_table = string.Explode( "", client.Faction_intro.Time )

	local actual_string_1, actual_string_2, actual_string_3 = "", "", ""

	local screenmiddle_w, screenmiddle_h = ScrW() / 2, ScrH() / 2

	client.Faction_intro.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, color_black )

		if ( ( self.StartTime ) < CurTime() ) then

			surface.SetDrawColor( color_white )
			surface.SetMaterial( ntf_icon )
			surface.DrawTexturedRect( screenmiddle_w - 128, screenmiddle_h - 128, 256, 256 )

		end

		if ( self.StartTime < CurTime() - 2) then

			if ( !self.alpha_variable ) then

				self.alpha_variable = 255

			end

			self.alpha_variable = math.Approach( self.alpha_variable, 0, RealFrameTime() * 512 )
			if self.alpha_variable != 255 and self.DescPlayed != true then
				self.DescPlayed = true
				DrawNewRoleDesc()
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end
			self:SetAlpha( self.alpha_variable )

		end

	end

end

function NEWGRUStart()

	local clr_text = gteams.GetColor( TEAM_GRU )

	local client = LocalPlayer()

	if ( IsValid( client.Faction_intro ) ) then

		client.Faction_intro:Remove()

	end

	

	
	
	

	client.Faction_intro = vgui.Create( "DPanel" )
	client.Faction_intro:SetSize( ScrW(), ScrH() )
	client.Faction_intro.StartTime = CurTime() + 0.2

	local name_string_table = string.Explode( "", client.Faction_intro.Name, true )
	local status_string_table = string.Explode( "", client.Faction_intro.Status, true )
	local time_string_table = string.Explode( "", client.Faction_intro.Time )

	local actual_string_1, actual_string_2, actual_string_3 = "", "", ""

	local screenmiddle_w, screenmiddle_h = ScrW() / 2, ScrH() / 2

	client.Faction_intro.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, color_black )

		if ( ( self.StartTime ) < CurTime() ) then

			surface.SetDrawColor( color_white )
			surface.SetMaterial( TeamIcons[ TEAM_GRU ].mat )
			surface.DrawTexturedRect( screenmiddle_w - 128, screenmiddle_h - 128, 256, 256 )

		end

		if ( self.StartTime < CurTime() - 2) then

			if ( !self.alpha_variable ) then

				self.alpha_variable = 255

			end

			self.alpha_variable = math.Approach( self.alpha_variable, 0, RealFrameTime() * 512 )
			if self.alpha_variable != 255 and self.DescPlayed != true then
				self.DescPlayed = true
				DrawNewRoleDesc()
				net.Start("ProceedUnfreezeSUP")
				net.SendToServer()
			end
			self:SetAlpha( self.alpha_variable )

		end

	end

end

local ci_icon = Material( "nextoren/gui/roles_icon/chaos.png" )
local ranktable = {

	[ "CI Commander" ] = "CI Commander.",
	[ "CI Demoman" ] = "CI Demoman.",
	[ "CI Soldier" ] = "CI Soldier.",
	[ "CI Juggernaut" ] = "CI Juggernaut."

}

surface.CreateFont("CI_Huge", { font = "Hitmarker Normal", size = 85, weight = 900, extended = true })
surface.CreateFont("CI_Sub", { font = "Hitmarker Normal", size = 30, weight = 800, extended = true })
surface.CreateFont("CI_Micro", { font = "Hitmarker Normal", size = 18, weight = 800, extended = true })

local rust_bg  = Color(8, 9, 8, 255)
local ci_green = Color(40, 180, 60)
local ci_red   = Color(220, 30, 30)

function CutScene()
	if GetGlobalBool("NoCutScenes", false) then return end

	APC_spawn_CI_Cutscene()

	local client = LocalPlayer()
	client:ConCommand("stopsound")

	if BREACH and BREACH.Music then
		BREACH.Music:Play(BR_MUSIC_SPAWN_CHAOS)
	end

	local rank = ranktable and ranktable[client:GetRoleName()] or "ERROR"

	local str_name   = string.upper(L("l:ci_cutscene_operative") .. rank .. " " .. client:GetNamesurvivor())
	local str_status = string.upper(L("l:ci_cutscene_target"))
	local str_time   = string.upper(L("l:ci_cutscene_time") .. string.ToMinutesSeconds(GetRoundTime() - cltime) .. L("l:ci_cutscene_after_disaster"))

	if IsValid(CI_CUTSCENE_PANEL) then CI_CUTSCENE_PANEL:Remove() end

	local w, h = ScrW(), ScrH()
	CI_CUTSCENE_PANEL = vgui.Create("DPanel")
	local pnl = CI_CUTSCENE_PANEL
	pnl:SetSize(w, h)
	pnl:SetPos(0, 0)
	pnl:SetZPos(32767)

	pnl.InitTime = SysTime()
	pnl.HijackTime = pnl.InitTime + 4.4
	pnl.FadeTime = pnl.InitTime + 8.0
	
	pnl.AlphaMult = 1
	pnl.DescPlayed = false

    local function GetHackerText(text, startTime, speed)
        local t = SysTime() - startTime
        if t < 0 then return "" end
        
        local len = utf8.len(text)
        local charsToShow = math.floor(t * speed)
        local currentText = utf8.sub(text, 1, math.Clamp(charsToShow, 0, len))
        
        if charsToShow < len and math.floor(SysTime() * 20) % 2 == 0 then
            currentText = currentText .. "█"
        end
        return currentText
    end

	pnl.Paint = function(self, pw, ph)
		local t = SysTime()
		local cx, cy = pw / 2, ph / 2

		if t < self.HijackTime then
			surface.SetDrawColor(rust_bg)
			surface.DrawRect(0, 0, pw, ph)

            local hijackT = t - self.InitTime
            
            if hijackT < 4.2 then
                draw.SimpleText("[ SECURE CONNECTION ESTABLISHED ]", "CI_Micro", 40, 40, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText("SITE-19 MAINFRAME ACTIVE", "CI_Micro", 40, 60, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                local shakeX = math.random(-15, 15)
                local shakeY = math.random(-5, 5)
                
                surface.SetDrawColor(ci_red.r, ci_red.g, ci_red.b, math.random(50, 100))
                surface.DrawRect(0, 0, pw, ph)
                
                draw.SimpleText("[ CRITICAL SYSTEM OVERRIDE ]", "CI_Huge", cx + shakeX, cy + shakeY, ci_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("UNAUTHORIZED EXTERNAL UPLINK DETECTED", "CI_Sub", cx - shakeX, cy + 60 + shakeY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
			return
		end

		local dropT = t - self.HijackTime
		
		if t >= self.FadeTime then
			self.AlphaMult = Lerp(FrameTime() * 0.2, self.AlphaMult, 0)
			
			if not self.DescPlayed then
				self.DescPlayed = true
				if DrawNewRoleDesc then DrawNewRoleDesc() end
			end

			if self.AlphaMult <= 0.01 then
				self:Remove()
				return
			end
		end

		surface.SetDrawColor(8, 12, 8, 255 * self.AlphaMult)
		surface.DrawRect(0, 0, pw, ph)

        surface.SetDrawColor(ci_green.r, ci_green.g, ci_green.b, 5 * self.AlphaMult)
        for i = 0, ph, 4 do surface.DrawLine(0, i, pw, i) end

        local iconMat = ci_icon or Material("nextoren/gui/roles_icon/chaos.png", "smooth")
        surface.SetDrawColor(40, 180, 60, 20 * self.AlphaMult)
        surface.SetMaterial(iconMat)
        local iconSize = ph * 0.85
        surface.DrawTexturedRect(pw - iconSize + 150, ph/2 - iconSize/2, iconSize, iconSize)

        local glitchX = 0
        if dropT < 0.2 then glitchX = math.random(-25, 25) end
		local startX = pw * 0.15 
		local lineW = pw * 0.7

		local currentLineW = Lerp(math.ease.OutExpo(math.Clamp(dropT / 0.4, 0, 1)), 0, lineW)


		surface.SetDrawColor(ci_green.r, ci_green.g, ci_green.b, 255 * self.AlphaMult)
		surface.DrawRect(startX + glitchX, cy, currentLineW, 6)

        if dropT < 0.1 then return end

        local textAlpha = 255 * self.AlphaMult * math.ease.OutSine(math.Clamp((dropT - 0.1) / 0.3, 0, 1))

		draw.SimpleText("CHAOS INSURGENCY", "CI_Huge", startX + glitchX, cy - 10, ColorAlpha(color_white, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

        local typeSpeed = 60
        local ty = cy + 25
        local step = 35
        
        local t1 = GetHackerText(str_name,   self.HijackTime + 0.3, typeSpeed)
        local t2 = GetHackerText(str_status, self.HijackTime + 1.0, typeSpeed)
        local t3 = GetHackerText(str_time,   self.HijackTime + 1.8, typeSpeed)

		draw.SimpleText(t1, "CI_Sub", startX + glitchX, ty, ColorAlpha(Color(200, 200, 200), textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(t2, "CI_Sub", startX + glitchX, ty + step, ColorAlpha(ci_green, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(t3, "CI_Sub", startX + glitchX, ty + step * 2, ColorAlpha(Color(150, 150, 150), textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if dropT > 0.5 then
            for i = 1, 15 do
                draw.SimpleText("0x" .. string.format("%04X", math.random(0, 65535)), "CI_Micro", 20, 40 + i * 20, ColorAlpha(ci_green, 50 * self.AlphaMult), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end
	end
end

local ci_icon = Material( "nextoren/gui/roles_icon/gru.png" )
local client = LocalPlayer()
local timer_Simple = timer.Simple
local vgui_Create = vgui.Create
local draw_RoundedBox = draw.RoundedBox
--local surface_SetDrawColor = surface.SetDrawColor
--local math_Clamp = math.Clamp
--local surface_SetMaterial = surface.SetMaterial
--local surface_DrawTexturedRect = surface.DrawTexturedRect
--local math_Approach = math.Approach
--local net_Start = net.Start
--local net_SendToServer = net.SendToServer
--local timer_Remove = timer.Remove
--local timer_Create = timer.Create
--local hook_Remove = hook.Remove
--local util_ScreenShake = util.ScreenShake
--local math_min = math.min
--local string_ToMinutesSeconds = string.ToMinutesSeconds
--local GetPrepTime = GetPrepTime
--local surface_SetFont = surface.SetFont
--local surface_GetTextSize = surface.GetTextSize
--local draw_DrawText = draw.DrawText
--local os_date = os.date
--local system_HasFocus = system.HasFocus
--local system_FlashWindow = system.FlashWindow
--local ents_CreateClientside = ents.CreateClientside
--local draw_SimpleTextOutlined = draw.SimpleTextOutlined
local ranktable = {

	[ "GRU Commander" ] = "Капитан",
	[ "GRU Specialist" ] = "Прапорщик",
	[ "GRU Soldier" ] = "Сержант",
	[ "GRU Juggernaut" ] = "Лейтенант"

}

local heliStart = function(heliModel, heliPos, heliAngle)
    local heliEnt = ents_CreateClientside("base_gmodentity")
    heliEnt:SetModel(heliModel)
    heliEnt:SetPos(heliPos)
    heliEnt:SetAngles(heliAngle)

    heliEnt:Spawn()
    heliEnt:Activate()

    return heliEnt
end

local string_len = utf8.len
local string_sub = utf8.sub
local string_find = string.find

function utf8.StringToTable( str )

  local tbl = {}

  for i = 1, string_len( str ) do

    tbl[ i ] = string_sub( str, i, i )

  end

  return tbl

end

local totable = utf8.StringToTable

function utf8.Explode( separator, str, withpattern )

  if ( separator == "" ) then return totable( str ) end
  if ( withpattern == nil ) then withpattern = false end

  local ret = {}
  local current_pos = 1

  for i = 1, string_len( str ) do

    local start_pos, end_pos = string_find( str, separator, current_pos, !withpattern )

    if ( !start_pos ) then break end

    ret[ i ] = string_sub( str, current_pos, start_pos - 1 )
    current_pos = end_pos + 1

  end

  ret[ #ret + 1 ] = string_sub( str, current_pos )

  return ret

end

function GRUCutscene()
	local client = LocalPlayer()
    client:ConCommand("stopsound")
	timer_Simple(1, function()
	surface.PlaySound( "nextoren/new_gru_2.wav" )
	end)
    client.NoAutoMusic = true
    client.cantSeeNames = true

    

    local rank = ranktable[client:GetRoleName()] or "ERROR"
    local sw, sh = ScrW(), ScrH()
    local midW, midH = sw * 0.5, sh * 0.5

    local panel = vgui_Create("EditablePanel")
    panel:SetSize(sw, sh)
    panel.StartAlpha = 255
    panel.StartTime = CurTime() + 12
    panel.Name = rank .. " " .. client:GetNamesurvivor() 
    panel.Time = string_ToMinutesSeconds(GetRoundTime() - cltime) .. " времени после Н.У.С"

    local tblName = utf8.Explode("", panel.Name, true)
    local tblTime = utf8.Explode("", panel.Time, true)
    local sName, sTime = "", "", ""
    local iName, iTime = 0, 0, 0

    panel.Paint = function(self, w, h)
        draw_RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, self.StartAlpha))

        surface_SetDrawColor(255, 255, 255, self.StartAlpha)
        surface_SetMaterial(Material("nextoren/gui/roles_icon/gru.png", "smooth"))
        surface_DrawTexturedRect(midW - OGRX.ScaleW(128), midH - OGRX.ScaleH(128), OGRX.ScaleW(256), OGRX.ScaleH(256))

        if CurTime() >= self.StartTime - 7 then
            if CurTime() >= self.StartTime then
                self.StartAlpha = math_Approach(self.StartAlpha, 0, RealFrameTime() * 128)
                if self.StartAlpha < 255 and not self.DescPlayed then
                    self.DescPlayed = true
                    DrawNewRoleDesc()
                end
            end

            local now = SysTime()
            if (self.NextSymbol or 0) <= now then
                if iTime < #tblTime then
                    iTime = iTime + 1
                    sTime = sTime .. tblTime[iTime]
                elseif iName < #tblName then
                    iName = iName + 1
                    sName = sName .. tblName[iName]
                end

                self.NextSymbol = now + 0.08
            end

            draw_SimpleTextOutlined(sTime, "MainMenuFont", midW, midH, ColorAlpha(Color(255, 0, 0), self.StartAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, self.StartAlpha))
            draw_SimpleTextOutlined(sName, "MainMenuFont", midW, midH + OGRX.ScaleH(32), ColorAlpha(Color(255, 0, 0), self.StartAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, self.StartAlpha))
        end

        if self.StartAlpha <= 0 then
            timer_Simple(12, function()
                if IsValid(client) then
                    client.NoAutoMusic = nil
                    client.cantSeeNames = nil
                    StopMusic(8)
                end
            end)

            self:Remove()
        end
    end

    local dlight = DynamicLight(client:EntIndex())
    if dlight then
        dlight.pos = Vector(14883.383789, 13000.545898, -15600.162109)
        dlight.r = 190
        dlight.g = 0
        dlight.b = 0
        dlight.brightness = 2.1
        dlight.Size = 900
        dlight.DieTime = CurTime() + 60
    end

    local heli = heliStart("models/ogrx/props/gru_heli/mil_mi-8_hip.mdl", Vector(-8935.576171875, -2918.1501464844, 9724.1923828125), Angle(4, -92, 0))
    timer_Simple(10, function()
        if not IsValid(heli) or not IsValid(client) then return end
        local hoverSound = CreateSound(heli, "nextoren/others/helicopter/helicopter_propeller.wav")
        hoverSound:Play()
        timer_Simple(10, function()
            if not IsValid(heli) or not IsValid(client) then return end
            hoverSound:ChangeVolume(0, 1.5)
            timer_Simple(6, function()
                hoverSound:Stop()
                heli:Remove()
            end)
        end)
    end)

    client.Faction_intro = panel
end



surface.CreateFont("Void_Huge", { font = "Hitmarker Normal", size = 80, weight = 200, extended = true })
surface.CreateFont("Void_Small", { font = "Hitmarker Normal", size = 20, weight = 200, extended = true })

local function Ending( status )
    local ply = LocalPlayer()

    local accentCol = Color(112, 126, 73)
    local statusStr = status

    if status == "Evacuated by CI" then
        statusStr = "l:cutscene_evac_by_ci"
        surface.PlaySound("nextoren/vo/acp/survivor_escaped_" .. math.random( 1, 3 ) .. ".wav")
        accentCol = Color(40, 160, 60)
    elseif status == "Evacuated by Helicopter" then
        statusStr = "l:cutscene_evac_by_heli"
        surface.PlaySound("nextoren/vo/chopper/chopper_evacuate_evacuated.wav")
        accentCol = Color(60, 140, 255)
    end

    local translatedStatus = string.upper(BREACH.TranslateString(statusStr))

        if BREACH and BREACH.Music then
            BREACH.Music:Play(BR_MUSIC_ESCAPED)
        end

    local name, roleName
    if ply:GTeam() == TEAM_SCP then
        name = string.upper(BREACH.TranslateString("l:cutscene_subject ") .. GetLangRole(ply:GetRoleName()))
        roleName = "АНОМАЛЬНАЯ УГРОЗА"
    else
        name = string.upper(ply:GetNamesurvivor())
        roleName = string.upper(GetLangRole(ply:GetRoleName()))
    end

    local timeText = tostring(os.date("%H:%M:%S")) .. " (+" .. string.ToMinutesSeconds(cltime) .. ")"

    if IsValid(BREACH_ENDING_WINDOW) then BREACH_KIA_WINDOW:Remove() end

    BREACH_ENDING_WINDOW = vgui.Create("DPanel")
    local pnl = BREACH_ENDING_WINDOW
    pnl:SetSize(ScrW(), ScrH())
    pnl:SetPos(0, 0)
    pnl:SetZPos(32765)

    pnl.CreationTime = SysTime()
    pnl.LifeTime = 10
    pnl.IsDying = false

    pnl.Paint = function(self, w, h)
        local t = SysTime() - self.CreationTime

        if t > self.LifeTime and not self.IsDying then
            self.IsDying = true
            self.DieTime = SysTime()
        end

        local anim_bg, anim_line, anim_text = 0, 0, 0
        if not self.IsDying then
            anim_bg   = math.ease.OutCubic(math.Clamp(t / 1.0, 0, 1))
            anim_line = math.ease.OutExpo(math.Clamp((t - 0.5) / 1.5, 0, 1))
            anim_text = math.ease.OutSine(math.Clamp((t - 0.8) / 1.0, 0, 1))
        else
            local dt = SysTime() - self.DieTime
            anim_text = 1 - math.ease.InSine(math.Clamp(dt / 0.5, 0, 1))
            anim_line = 1 - math.ease.InExpo(math.Clamp((dt - 0.3) / 0.8, 0, 1))
            anim_bg   = 1 - math.ease.InCubic(math.Clamp((dt - 0.8) / 1.0, 0, 1))
            if dt > 1.8 then self:Remove() return end
        end

        surface.SetDrawColor(0, 0, 0, 240 * anim_bg)
        surface.DrawRect(0, 0, w, h)

        if anim_line <= 0 then return end

        local cy = h / 2 + 30
        local startX = w * 0.15
        local lineW = w * 0.7 * anim_line

        surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, 255 * anim_line)
        surface.DrawRect(startX, cy, lineW, 2)

        if anim_text <= 0 then return end

        local alphaText = 255 * anim_text

        draw.SimpleText("УСПЕШНАЯ ЭВАКУАЦИЯ", "Void_Huge", startX, cy - 10, Color(230, 230, 230, alphaText), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

        draw.SimpleText(roleName .. "  ///  " .. name .. "  ///  T: " .. timeText, "Void_Small", startX, cy + 15, Color(150, 150, 150, alphaText), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("СТАТУС: " .. translatedStatus, "Void_Small", startX + lineW, cy + 15, Color(accentCol.r, accentCol.g, accentCol.b, alphaText), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
end

net.Receive( "Ending_HUD", function()

	local status = net.ReadString()

    local client = LocalPlayer()

	local current_team = client:GTeam()

	if ( current_team != TEAM_USA ) then

		Ending( status )

	else

		if ( status == "l:ending_mission_complete" ) then

			UIU_Ending( true )

		else

			UIU_Ending( false )

		end

	end

end )

local desc_clr_gray = Color( 198, 198, 198 )


local target_outline = Color(255,0,0)
hook.Add( "PreDrawOutlines", "UIU_SPY_TARGETS", function()
	local client = LocalPlayer()
	if client:GetRoleName() != role.SCI_SpyUSA then return end
	local plys = player.GetAll()
	local draw_ent = {}
	local mypos = client:GetPos()
	for i = 1, #plys do
		local ply = plys[i]
		if ply:HasWeapon("item_special_document") and ply:GetPos():DistToSqr(mypos) <= 120000 then
			draw_ent[#draw_ent + 1] = ply

			local bnmrgs = ply:LookupBonemerges()

			for i = 1, #bnmrgs do
				local bn = bnmrgs[i]
				if bn and bn:IsValid() then
					draw_ent[ #draw_ent + 1 ] = bn
				end
			end
		end
	end

	local rgdols = ents.FindByClass('prop_ragdoll')
	for i = 1, #rgdols do
		local rgdol = rgdols[i]
		if rgdol:GetNWBool("HasDocument") and rgdol:GetPos():DistToSqr(mypos) <= 120000 then
			draw_ent[#draw_ent + 1] = rgdol

		end
	end
	if ( #draw_ent > 0 ) then

			outline.Add( draw_ent, target_outline, 2 )

		end
end)

function Show_Spy( current_team )

	

	

	local spy_table = {}
	local all_players = player.GetAll()

	local client = LocalPlayer()

	local client_Team = LocalPlayer():GTeam()

	for i = 1, #all_players do

		local player = all_players[ i ]

		if ( player:GTeam() == current_team && player:GetRoleName():lower():find( "spy" ) && player != client ) then

			spy_table[ #spy_table + 1 ] = player

		end
		
		if client_Team == TEAM_CLASSD or client_Team == TEAM_CHAOS then
			
			if ( player:GetRoleName():find( "Stealthy" ) ) then

				spy_table[ #spy_table + 1 ] = player

			end

		end

	end

	local old_name_surv = LocalPlayer():GetNamesurvivor()
	local team_clr = color_white
	if current_team != TEAM_CHAOS then
		local team_clr = gteams.GetColor( current_team )
	end

	if team_clr == color_black then team_clr = color_white end

	hook.Add( "PreDrawOutlines", "ShowSpy", function()

		if ( client:Health() <= 0 || client:GTeam() != client_Team ) then

			hook.Remove( "PreDrawOutlines", "ShowSpy" )
			return
		end

		local draw_ent = {}

		for _, v in ipairs( spy_table ) do
			
			if ( ( v && v:IsValid() ) && v:Health() > 0 && ( ( v:GTeam() == current_team ) or (v:GetRoleName() == "Class-D Stealthy" and ( LocalPlayer():GTeam() == TEAM_CLASSD or LocalPlayer():GTeam() == TEAM_CHAOS ) ) ) ) then

				draw_ent[ #draw_ent + 1 ] = v

			else

				table.RemoveByValue( spy_table, v )

			end

		end

		if ( #draw_ent > 0 ) then

			outline.Add( draw_ent, team_clr, 2 )

		end

	end )

end

function EndRoundStats()

	local result = net.ReadString()

	local t_restart = net.ReadFloat()

	local client = LocalPlayer()

	local screenwidth, screenheight = ScrW(), ScrH()

	local general_panel = vgui.Create( "DPanel" )
	general_panel:SetText( "" )
	general_panel:SetSize( screenwidth, screenheight )
	general_panel:SetAlpha( 1 )
	general_panel.StartTime = RealTime()
	general_panel.StartFade = false
	timer.Simple( ( t_restart || 27 ) + 1, function()

		if ( general_panel && general_panel:IsValid() ) then

			general_panel.StartFade = true

		end

	end )

	general_panel.Paint = function( self, w, h )

		if ( self:GetAlpha() < 255 && general_panel.StartTime < RealTime() - .25 && !general_panel.StartFade ) then

			self:SetAlpha( math.Approach( self:GetAlpha(), 255, FrameTime() * 512 ) )

		elseif ( self:GetAlpha() > 0 && general_panel.StartTime < RealTime() - 20 && general_panel.StartFade ) then

			self:SetAlpha( math.Approach( self:GetAlpha(), 0, FrameTime() * 512 ) )

			if ( self:GetAlpha() == 0 && ( self && self:IsValid() ) ) then

				self:Remove()

			end

		end

	end
	local stats_panel = vgui.Create( "DPanel", general_panel )
	stats_panel:SetPos( screenwidth / 2.7, screenheight * .1 )
	stats_panel:SetSize( screenwidth / 4, screenheight / 3 )
	stats_panel:SetText( "" )
	stats_panel.NextSymbol = RealTime()




	local counter = 0
	local counter2 = 0
	local str1 = "Hello"
	local str2 = "Pe0ple"

	local time;

	stats_panel.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, math.Clamp( self:GetAlpha(), 0, 210 ) ) )
		draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( desc_clr_gray, 190 ) )

		draw.SimpleText( "Round complete", "MainMenuFontmini", w / 2, 24, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		draw.SimpleText( "Round result: " .. result, "MainMenuFont", w / 2, 64, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		time = CurTime() + 18

		time2 = tostring(string.ToMinutesSeconds( cltime ) )


		draw.SimpleText( "Next round in  " .. time2, "MainMenuFontmini", w / 2, h * .7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )



		if ( self.NextSymbol <= RealTime() ) then

			self.NextSymbol = RealTime() + .1
			counter = counter + 1

		elseif ( self.NextSymbol <= RealTime() ) then

			self.NextSymbol = RealTime() + .1
			counter2 = counter2 + 1

		end

		surface.SetDrawColor( color_white )
		surface.DrawLine( 0, 48, w, 48 )
		surface.DrawLine( 0, 49, w, 49 )

		draw.SimpleTextOutlined( str1, "MainMenuFontmini", 15, h * .3 + 30, ColorAlpha( color_white, 180 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1.5, ColorAlpha( color_black, 180 ) )
		draw.SimpleTextOutlined( str2, "MainMenuFontmini", 15, h * .3 + 60, ColorAlpha( color_white, 180 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1.5, ColorAlpha( color_black, 180 ) )

	end

end
net.Receive( "EndRoundStats", EndRoundStats )

local desc_clr = Color( 169, 169, 169 )
local desc_clr_gray = Color( 198, 198, 198 )

local mply = FindMetaTable( "Player" )

local mvpAnims = {}

function CreateMVPMenu(tab, first)
    if IsValid(MVP_MENU) then MVP_MENU:Remove() end

    MVP_MENU = vgui.Create("DPanel")
    local g = MVP_MENU

    local boxW, boxH = 400, 480
    g:SetSize(boxW, boxH)
    
    local targetX = 75
    local targetY = ScrH() / 2 - boxH / 2

    mvpAnims = {
        panel = {
            alpha = 0,
            xPos = first and -boxW or targetX,
        },
        closeTime = CurTime() + 7,
        players = {}
    }

    for i = 1, #tab.plys do
        mvpAnims.players[i] = {
            alpha = 0,
            xOffset = -20,
            delay = 0.3 + (i * 0.15)
        }
    end

    g.CreationTime = CurTime()

    g.Think = function(self)
        local t = CurTime()
        local elapsed = t - self.CreationTime
        local ft = FrameTime() * 10
        
        if first then
            mvpAnims.panel.xPos = Lerp(ft, mvpAnims.panel.xPos, targetX)
        end
        mvpAnims.panel.alpha = Lerp(ft, mvpAnims.panel.alpha, 1)
        
        self:SetPos(math.Round(mvpAnims.panel.xPos), targetY)
        self:SetAlpha(mvpAnims.panel.alpha * 255)

        for i = 1, #tab.plys do
            local anim = mvpAnims.players[i]
            if elapsed > anim.delay then
                if anim.alpha == 0 then
                    surface.PlaySound("UI/buttonrollove.wav")
                end
                anim.alpha = Lerp(ft, anim.alpha, 1)
                anim.xOffset = Lerp(ft, anim.xOffset, 0)
            end
        end

        local timeLeft = mvpAnims.closeTime - t
        if timeLeft <= 0 then
            self:AlphaTo(0, 0.3, 0, function() if IsValid(self) then self:Remove() end end)
        end
    end


    local title = string.upper(L(tab.title) or "ОТЧЕТ ОБ ЭФФЕКТИВНОСТИ")

    g.Paint = function(self, w, h)
        local a = mvpAnims.panel.alpha
        
        if DrawBlurPanel then DrawBlurPanel(self, 3) end

        surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 255 * a)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(255, 255, 255, 2 * a)
        for i = 0, h, 4 do surface.DrawLine(0, i, w, i) end

        local headerH = 100
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255 * a)
        surface.DrawRect(0, 0, w, headerH)
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * a)
        surface.DrawRect(0, headerH - 2, w, 2)

        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255 * a)
        surface.DrawLine(20, 40, w - 20, 40)

        draw.SimpleText("ИТОГИ ОПЕРАЦИИ", "MogM_6", 20, 15, ColorAlpha(rust_dim, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(title, "MogM_8", 20, 55, ColorAlpha(color_white, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255 * a)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local timeLeft = math.max(0, mvpAnims.closeTime - CurTime())
        local progress = timeLeft / 7
        
        surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 100 * a)
        surface.DrawRect(0, h - 3, w * progress, 3)
    end

    local plylist = vgui.Create("DListLayout", MVP_MENU)
    g.PlayersList = plylist
    plylist:SetSize(boxW, boxH - 105)
    plylist:SetPos(0, 105)

    local rankColors = {
        Color(255, 215, 0),
        Color(192, 192, 192),
        Color(205, 127, 50)
    }

    for i = 1, #tab.plys do
        local plyData = tab.plys[i]
        local anim = mvpAnims.players[i]

        local base = vgui.Create("DPanel", plylist)
        base:Dock(TOP)
        base:DockMargin(15, 10, 15, 0)
        base:SetTall(40)
        
        local rankColor = rankColors[i] or rust_dim

        base.Paint = function(self, w, h)
            local pAlpha = anim.alpha
            local offsetX = anim.xOffset
            
            if pAlpha <= 0.01 then return end

            surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255 * pAlpha)
            surface.DrawRect(offsetX, 0, w, h)

            surface.SetDrawColor(rankColor.r, rankColor.g, rankColor.b, 255 * pAlpha)
            surface.DrawRect(offsetX, 0, 4, h)

            surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255 * pAlpha)
            surface.DrawOutlinedRect(offsetX, 0, w, h, 1)

            draw.SimpleText("#" .. i, "MogM_6", offsetX + 15, h / 2 - 1, ColorAlpha(rankColor, 255 * pAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(string.upper(plyData.name), "MogM_6", offsetX + 80, h / 2 - 1, ColorAlpha(rust_text, 255 * pAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(plyData.value, "MogM_6", offsetX + w - 15, h / 2 - 1, ColorAlpha(rankColor, 255 * pAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        local plyavatar = vgui.Create("AvatarImage", base)
        plyavatar:SetSize(30, 30)
        plyavatar:SetPos(40, 5)
        plyavatar:SetSteamID(plyData.id, 32)
        
        plyavatar.Think = function(self)
            self:SetPos(40 + anim.xOffset, 5)
            self:SetAlpha(anim.alpha * 255)
        end
    end
end

net.Receive("MVPMenu", function(len)
    local data = net.ReadTable()
    CreateMVPMenu(data)
end)

surface.CreateFont( "HUDFontHead", {

    font = "Bauhaus",

	size = 36,

	weight = 100,

	blursize = 0,

	scanlines = 0,

	antialias = true,

	underline = false,

	italic = false,

	strikeout = false,

	symbol = false,

	rotary = false,

	shadow = false,

	additive = false,

	outline = false,

})


local LVLColorMax = Color( 220, 20, 60 )

local BrHeadIcons = {

  [ TEAM_CHAOS ] = Material( "nextoren_hud/faction_icons/chaosiconforhudspec.png" ),
  [ TEAM_GOC ] = Material( "nextoren_hud/faction_icons/gociconforhud.png" ),
  [ TEAM_DZ ] = Material( "nextoren_hud/faction_icons/dziconforhudspec.png" ),
  [ TEAM_NTF ] = Material( "nextoren_hud/faction_icons/ntfspec.png" ),
  [ TEAM_USA ] = Material( "nextoren_hud/faction_icons/fbispec.png" ),
  [ TEAM_COTSK ] = Material( "nextoren_hud/faction_icons/scarletspec.png" ),
  [ TEAM_GRU ] = Material( "nextoren_hud/faction_icons/gruspec.png" ),
  [ 1313 ] = Material( "nextoren_hud/faction_icons/fbi_agentspec.png" ),

}


  local Health    = "l:hud_health"
  local Level     = "l:scoreboard_level"
  local HighLevel = "l:hud_max_level"
  local offset    = Vector( 0, 0, 85 )
  local microphone_icon = Material( "nextoren_hud/microphone.png" )

  local getpixhandle = util.GetPixelVisibleHandle

  local plTable = {}
  local plTableNextUpdate = 0

  function DrawNameSpectator()

    local client = LocalPlayer()

    if ( client:GTeam() != TEAM_SPEC ) then return end
    if GetConVar("breach_config_screenshot_mode"):GetInt() == 1 then return end

    if ( ( plTableNextUpdate || 0 ) < CurTime() ) then

      plTable = GetActivePlayers()
      plTableNextUpdate = CurTime() + .8

    end

    for i = 1, #plTable do

      local ply = plTable[ i ]

      if ( !( ply && ply:IsValid() ) ) then continue end

      if ply:GetNoDraw() or ply:IsDormant() then continue end

      local plytable = ply:GetTable()
	  
	  if !plytable["pixhandle"] then
		plytable["pixhandle"] = getpixhandle()
	  end
	  
	  local Visible = util.PixelVisible(ply:GetPos(), 64, plytable.pixhandle)

	  if ( !Visible || Visible < 0.1 ) then continue end

      if ( client:GetPos():DistToSqr( ply:GetPos() ) < 65536 ) then

        local player_team = ply:GTeam()

        if ( player_team == TEAM_SPEC || ply:Health() <= 0 ) then continue end
        if ( client:GetObserverTarget() == ply ) then continue end

        local pos = ply:GetPos()
        pos:Add( offset )

        local color = gteams.GetColor( player_team )

        local ang  = client:EyeAngles()
        ang:RotateAroundAxis( ang:Forward(), 90 )
        ang:RotateAroundAxis( ang:Right(), 90 )

        local Mat

        if ( BrHeadIcons[ player_team ] ) then

        	if BREACH:IsUiuAgent(ply:GetRoleName()) then

	          Mat = BrHeadIcons[ 1313 ]

            else

	          Mat = BrHeadIcons[ player_team ]

	        end

        end

        local plcolor = color
        local lvl = ply:GetNLevel()

        local surv_name = ply:GetNamesurvivor()
        local name = ply:Name()

        cam.Start3D2D( pos, ang, .1 )

          --draw.SimpleText( L(Health) .. ": " .. ply:Health() .. " / " .. ply:GetMaxHealth(), "new_spec_2", 1, -30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

          if ( surv_name != "none" ) then

            draw.SimpleText( name .. " (" .. surv_name .. ")", "new_spec_2", 0, 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( name .. " (" .. surv_name .. ")", "new_spec_2", 1, 0, plcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

          else

            draw.SimpleText( name, "new_spec_2", 0, 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( name, "new_spec_2", 1, 0, plcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

          end

          --if ( lvl < 55 ) then
--
          --  draw.SimpleText( L(Level) .. " " .. lvl, "new_spec_2", 1, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
--
          --else
--
          --  draw.SimpleText( L(Level) .. ": " .. lvl, "new_spec_2", 1, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER  )
          --  draw.SimpleText( "★ " .. L(HighLevel), "new_spec_2", 1, -60, LVLColorMax, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
--
          --end

          local offset = -150

          if ( Mat ) then

            surface.SetDrawColor( color_white )
            surface.SetMaterial( Mat )
            surface.DrawTexturedRect( -28, -150, 64, 64 );

            offset = offset - 70

          end

          if ( ply:IsSpeaking() ) then

            surface.SetDrawColor( color_white )
            surface.SetMaterial( microphone_icon )
            surface.DrawTexturedRect( -28, offset, 64, 64 )

          end

        cam.End3D2D()

      end

    end

  end

  hook.Add( "PostDrawTranslucentRenderables", "DrawNames", DrawNameSpectator )




local ply = LocalPlayer()


function OpenAdminLogHistory(data)

	data = {
		{"ban", "5120512959", "2141251251", os.time() - 1000, 1250},
		{"ban", "5120512959", "2141251251", os.time() - 525, 1250},
		{"ban", "5120512959", "2141251251", os.time() - 61, 1250},
		{"ban", "5120512959", "2141251251", os.time() - 283, 1250},
		{"ban", "5120512959", "2141251251", os.time() - 43, 1250},
	}

	if IsValid(BREACH.AdminLogUI) then BREACH.AdminLogUI:Remove() end

	local scrw, scrh = ScrW(), ScrH()

	BREACH.AdminLogUI = vgui.Create("DFrame")
	BREACH.AdminLogUI:SetSize(scrw, scrh)

	BREACH.AdminLogUI.Think = function(self)
		gui.EnableScreenClicker(true)
	end

	BREACH.AdminLogUI.OnRemove = function(self)
		gui.EnableScreenClicker(false)
	end

	local list = vgui.Create("DListView", BREACH.AdminLogUI)
	list:Dock(FILL)

	list:AddColumn( "type" )
	list:AddColumn( "admin" )
	list:AddColumn( "victim" )
	list:AddColumn( "time" )
	list:AddColumn( "length" )

	for _, tab in pairs(data) do

		list:AddLine(tab[1], tab[2], tab[3], os.date("%H:%M:%S - %d/%m/%Y", tab[4]), string.NiceTime(tab[5]))

	end


end

local no_desc = CreateConVar("breach_config_no_role_description", 0, FCVAR_ARCHIVE, "Disables role description", 0, 1)

function DrawNewRoleDesc(str)
    local client = LocalPlayer()

    if not client:Alive() then return end
    if client:GTeam() == TEAM_SPEC then return end
    if client:Health() <= 0 then return end
    if no_desc and no_desc:GetBool() then return end
    if client.NoDesc then return end

    timer.Remove("Remove_Desc")

    if IsValid(BREACH_DESC_PANEL) then BREACH_DESC_PANEL:Remove() end
    if IsValid(BREACH_DESC_LOGO) then BREACH_DESC_LOGO:Remove() end 

    local scrw, scrh = ScrW(), ScrH()
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    local rust_bg       = Color(20, 19, 17, 250)
    local rust_panel    = Color(15, 14, 13, 240)
    local rust_outline  = Color(255, 255, 255, 10)
    local rust_yellow   = Color(218, 165, 32)
    local rust_dim      = Color(140, 140, 140)

    local mat = GetRoleIconByTeam(client:GTeam(), client:GetRoleName())
    local desc = BREACH.GetDescription(client:GetRoleName()) or L("l:roledesc_classified")
    local roleName = string.upper(GetLangRole(client:GetRoleName()) or L("l:roledesc_unknown"))

    local teamcol = gteams.GetColor(client:GTeam())
    if client:GTeam() == TEAM_USA then teamcol = color_white end

    local pnlW = sw(600)
    local padding = sw(25)
    local headerH = sh(80)
    
    local safeDesc = string.Replace(string.Replace(desc, "<", "&lt;"), ">", "&gt;")
    
    local parsedText = markup.Parse("<font=MM_Exp><color=230,230,230>" .. safeDesc .. "</color></font>", pnlW - padding * 2)
    local textH = parsedText:GetHeight()

    local pnlH = headerH + textH + sh(25) * 1.9

    BREACH_DESC_PANEL = vgui.Create("DPanel")
    local pnl = BREACH_DESC_PANEL
    pnl:SetSize(pnlW, pnlH)
    
    local targetX = ScrW() / 2 - pnlW / 2
    local targetY = ScrH() * 0.15

    pnl:SetPos(targetX, targetY)

    pnl.CreationTime = SysTime()
    pnl.LifeTime = 12
    pnl.IsDying = false

    pnl.Paint = function(self, w, h)
        local t = SysTime() - self.CreationTime

        if t > self.LifeTime and not self.IsDying then
            self.IsDying = true
            self.DieTime = SysTime()
        end

        local anim_line = 0
        local anim_box  = 0
        local anim_text = 0

        if not self.IsDying then
            anim_line = math.ease.OutExpo(math.Clamp(t / 0.4, 0, 1))
            anim_box  = math.ease.OutExpo(math.Clamp((t - 0.3) / 0.5, 0, 1))
            anim_text = math.ease.OutSine(math.Clamp((t - 0.7) / 0.5, 0, 1))
        else

            local dt = SysTime() - self.DieTime
            anim_text = 1 - math.ease.InSine(math.Clamp(dt / 0.3, 0, 1))
            anim_box  = 1 - math.ease.InExpo(math.Clamp((dt - 0.2) / 0.4, 0, 1))
            anim_line = 1 - math.ease.InExpo(math.Clamp((dt - 0.4) / 0.3, 0, 1))

            if dt > 0.8 then
                self:Remove()
                return
            end
        end

        if anim_line <= 0 then return end

        local currentLineWidth = w * anim_line
        local lineX = (w / 2) - (currentLineWidth / 2)

        surface.SetDrawColor(teamcol.r, teamcol.g, teamcol.b, 255 * (anim_line > 0.1 and 1 or anim_line * 10))
        surface.DrawRect(lineX, 0, currentLineWidth, sh(4))

        if anim_box <= 0 then return end

        local currentBoxHeight = h * anim_box
        render.SetScissorRect(targetX, targetY, targetX + w, targetY + currentBoxHeight, true)

            surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 240)
            surface.DrawRect(0, 0, w, h)

            if mat then
                surface.SetDrawColor(255, 255, 255, 10)
                surface.SetMaterial(mat)
                local wmSize = sh(300)
                surface.DrawTexturedRect(w/2 - wmSize/2, headerH + (h - headerH)/2 - wmSize/2, wmSize, wmSize)
            end

            surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
            surface.DrawRect(0, sh(4), w, headerH - sh(4))
            
            surface.SetDrawColor(rust_outline)
            surface.DrawLine(0, headerH - 1, w, headerH - 1)

            local iconSize = sh(50)
            local iconY = sh(15)
            surface.SetDrawColor(10, 9, 8, 255)
            surface.DrawRect(padding, iconY, iconSize, iconSize)
            surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 50)
            surface.DrawOutlinedRect(padding, iconY, iconSize, iconSize, 1)

            if mat then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(padding + sw(2), iconY + sh(2), iconSize - sw(4), iconSize - sh(4))
            end


            draw.SimpleText(roleName, "MM_ESC", padding + iconSize + sw(15), sh(48), teamcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 100)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

        render.SetScissorRect(0, 0, 0, 0, false)

        if anim_text <= 0 then return end

        surface.SetAlphaMultiplier(anim_text)
            draw.SimpleText(L("l:roledesc_directives"), "MM_SmallName", padding, headerH + sh(15), rust_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            parsedText:Draw(padding, headerH + sh(35), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetAlphaMultiplier(1)
    end
end

concommand.Add("br_description", DrawNewRoleDesc)

local BREACH = BREACH || {}
local gradient = Material("vgui/gradient-r")
local gradients = Material("gui/center_gradient")

function Camera_View( ply )

	ply.CameraEnabled = true

	if ply.CameraEnabled then

		fovcam = 60

		eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))

		if not CurView then
			CurView = angles
		else
			CurView = LerpAngle(mclamp(FrameTime() * (35 * (1 - mclamp(100, 0, 0.8))), 0, 1), CurView, angles + Angle(0, 0, eyeAtt.Ang.r * 0.1))
		end

		surface.PlaySound( "nextoren/Camera.ogg" )

		timer.Create("CameraSound", 5, 0, function()
			if !ply.CameraEnabled then return end
			surface.PlaySound( "nextoren/Camera.ogg" )
		end)

		hook.Add( "CalcView", "CameraView", function( ply, pos, ang, fov )

			if ply.CameraEnabled then

				local drawviewer = false

				local cameraviews = {
					origin = CamerasTable[ 1 ].Vector - Vector( 0, 0, 10 ),
					angles = CurView,
					fov = fovcam,
					drawviewer = true
				}

				return cameraviews
				  
			end

		end)
		

		BREACH.MainPanel_CamHud = vgui.Create( "DPanel" )
		BREACH.MainPanel_CamHud:SetSize( 1980, 1080 )
		BREACH.MainPanel_CamHud:SetPos( 0, 0 )
		BREACH.MainPanel_CamHud:SetText( "" )
		BREACH.MainPanel_CamHud.Paint = function( self, w, h )

			local cc_grain = surface.GetTextureID ( "overlays/cc_grain")
			local camcorder_noise = surface.GetTextureID ( "overlays/camcorder_noise")
			local camcorder_visor2 = surface.GetTextureID ( "overlays/camcorder_visor2")
			local camcorder_rec = surface.GetTextureID ( "overlays/camcorder_rec")
			local vignette = surface.GetTextureID ( "overlays/cc_vignette")
	
			local w,h = ScrW(),ScrH()
			surface.SetDrawColor ( 255, 255, 255, 255 )
			surface.SetTexture ( vignette )
			surface.DrawTexturedRect ( 0,0, w, h )
	
			local w,h = ScrW(),ScrH()
			surface.SetDrawColor ( 255, 255, 255, 255 )
			surface.SetTexture ( cc_grain )
			surface.DrawTexturedRect ( 0,0, w, h )
		
			local w,h = ScrW(),ScrH()
			surface.SetDrawColor ( 255, 255, 255, 255 )
			surface.SetTexture ( camcorder_noise )
			surface.DrawTexturedRect ( 0,0, w, h )
	
			local w,h = ScrW(),ScrH()
			
			surface.SetDrawColor ( 255, 255, 255, 255 )
			surface.SetTexture ( camcorder_visor2 )
			surface.DrawTexturedRect ( 0, 0, w, h )
			
			surface.SetDrawColor ( 255, 255, 255, 255 )
			surface.SetTexture ( camcorder_rec )
			surface.DrawTexturedRect ( w * 0.84, h * 0.14, 128, 64 )

			if camera_nvg == true then
			    local w,h = ScrW(),ScrH()

			    surface.SetDrawColor ( 136, 242, 173, 15 )
			    surface.DrawRect ( 0,0, w, h )

		    end
		

		end

		BREACH.MainPanel_Cameras = vgui.Create( "DPanel" )
		BREACH.MainPanel_Cameras:SetSize( 256, 256 )
		BREACH.MainPanel_Cameras:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
		BREACH.MainPanel_Cameras:SetText( "" )
		BREACH.MainPanel_Cameras.DieTime = CurTime() + 10
		BREACH.MainPanel_Cameras.Paint = function( self, w, h )

			if ( !vgui.CursorVisible() ) then

				gui.EnableScreenClicker( false )
			end

			if ( input.IsKeyDown( KEY_F3 ) ) then

				if ( ( self.NextCall || 0 ) >= CurTime() ) then return end
	
				self.NextCall = CurTime() + 1

				if ( vgui.CursorVisible() ) then
	
					gui.EnableScreenClicker( false )
					BREACH.MainPanel228:SetVisible( false )
	
				else
	
					gui.EnableScreenClicker( true )
					BREACH.MainPanel228:SetVisible( true )
	
				end
	
			end

			if ( input.IsKeyDown( KEY_N ) ) then

				if ( ( self.NextCall2 || 0 ) >= CurTime() ) then return end
	
				self.NextCall2 = CurTime() + 1

				if ( !camera_nvg ) then
	
					camera_nvg = true
	
				else
	
					camera_nvg = false
	
				end
	
			end

			if ( input.IsKeyDown( KEY_C ) ) then

				if fovcam == 10 then return end
	
				fovcam = fovcam - 1
	
			end

			if ( input.IsKeyDown( KEY_M ) ) then

				if fovcam == 90 then return end
	
				fovcam = fovcam + 1
	
			end
			
		end

		local CLOSE2225 = vgui.Create( "DButton", MainPanel_Cameras )
		CLOSE2225:SetPos( 0, 1000 )
		CLOSE2225:SetSize( 350, 40 )
		CLOSE2225:SetText("")
		CLOSE2225:MoveToFront()
		CLOSE2225.DoClick = function()
	  
		  BREACH.MainPanel_Cameras:Remove()
		  BREACH.MainPanel_CamHud.Paint = function( self, w, h )
		  end
		  BREACH.MainPanel_CamHud:Remove()
		  BREACH.MainPanel228:Remove()
		  hook.Remove("CalcView", "CameraView")
		  gui.EnableScreenClicker( false )
		  CLOSE2225:Remove()
		  ply.CameraEnabled = false

		end
	  
		CLOSE2225.OnCursorEntered = function()
	  
		  surface.PlaySound( "nextoren/gui/main_menu/cursorentered_1.wav" )
	  
		end
	  
		CLOSE2225.FadeAlpha = 0

		surface.CreateFont("MainMenuFont", {

			font = "Conduit ITC",
			size = 24,
			weight = 800,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = true,
			additive = false,
			outline = false
		  
		  })
	  
		CLOSE2225.Paint = function(self, w, h)
	  
		  draw.SimpleText( "Назад", "MainMenuFont", 75, h / 2, clr1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	  
		  if ( self:IsHovered() ) then
	  
			self.FadeAlpha = math.Approach( self.FadeAlpha, 255, RealFrameTime() * 256 )
	  
		  else
	  
			self.FadeAlpha = math.Approach( self.FadeAlpha, 0, RealFrameTime() * 512 )
	  
			end
	  
		  surface.SetDrawColor( 138, 138, 138, self.FadeAlpha )
		  surface.SetMaterial( gradient )
		  surface.DrawTexturedRect(0, 0, w, h )
	  
		end

		BREACH.MainPanel228 = vgui.Create( "DPanel" )
		BREACH.MainPanel228:SetSize( 256, 768 )
		BREACH.MainPanel228:SetPos( ScrW() / 2 - 896, ScrH() / 2 - 384 )
		BREACH.MainPanel228:SetText( "" )
		BREACH.MainPanel228.DieTime = CurTime() + 10

		BREACH.ScrollPanel_Cameras = vgui.Create( "DScrollPanel", BREACH.MainPanel228 )
		BREACH.ScrollPanel_Cameras:Dock( FILL )

		for i = 1, #CamerasTable do

			BREACH.Cameras = BREACH.ScrollPanel_Cameras:Add( "DButton" )
			BREACH.Cameras:SetText( "" )
			BREACH.Cameras:Dock( TOP )
			BREACH.Cameras:SetSize( 256, 64 )
			BREACH.Cameras:DockMargin( 0, 0, 0, 2 )
			BREACH.Cameras.CursorOnPanel = false
			BREACH.Cameras.gradientalpha = 0
	
			BREACH.Cameras.Paint = function( self, w, h )
	
				if ( self.CursorOnPanel ) then
	
					self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 64 )
	
				else
	
					self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 128 )
	
				end
	
				draw.RoundedBox( 0, 0, 0, w, h, color_black )
				draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )
	
				surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
				surface.SetMaterial( gradient )
				surface.DrawTexturedRect( 0, 0, w, h )
	
				draw.SimpleText( CamerasTable[ i ].Name, "ChatFont_new", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
			end
	
			BREACH.Cameras.OnCursorEntered = function( self )
	
				self.CursorOnPanel = true
	
			end
	
			BREACH.Cameras.OnCursorExited = function( self )
	
				self.CursorOnPanel = false
	
			end
	
			BREACH.Cameras.DoClick = function( self )

				hook.Add( "CalcView", "CameraView", function( ply, pos, ang, fov )

					if ply.CameraEnabled then

						local drawviewer = false
	
						local cameraviews = {
							origin = CamerasTable[ i ].Vector - Vector( 0, 0, 10 ),
							angles = CurView,
							fov = fovcam,
							drawviewer = true
						}
	
						return cameraviews
						  
					end
	
				end)

				ply.CurCam = CamerasTable[ i ]
						  
	
			end



			BREACH.MainPanel228:SetVisible( false )

		end

	end



end
concommand.Add( "cameranew", Camera_View )

function Pulsate(c) 
	return (math.abs(math.sin(CurTime()*c)))
end

local bg_106_lerp = 0
local appeartextlerp = 0

local scp_106_texts = {
	"DEATH",
	"FEAR",
	"PAIN",
	"DESPAIR",
	"HOPELESS",
	"AGONY",
	"IMPOSSIBLE",
}

surface.CreateFont( "SCP106_TEXT", {

	font = "Segoe UI",
	size = 35,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = true,
	italic = true,
	blursize = 1,
  
})


hook.Add( "HUDPaint", "SCP_106_creepy_visuals", function()

	if LocalPlayer():GetInDimension() and LocalPlayer():GTeam() != TEAM_SCP then

		local scrw, scrh = ScrW(), ScrH()

		bg_106_lerp = (math.abs(math.sin(CurTime()*math.Rand(0.3,0.4))))*100

		local bg_color = Color(0,0,0,bg_106_lerp)

		draw.RoundedBox(0, 0, 0, scrw, scrh, bg_color)

	end

end)

local XpAddInc = false
local XPPos = 0
local XPgained = 0
local newClassDescc = ""
local LevelUpAlpha = 0
local LevelUpAlpha3 = 0
local radiohud = 0
local expnotificationmat = Material("nextoren/gui/new_icons/notifications/breachiconfortips.png")

hook.Add( "HUDPaint", "EXPNotification", function()

	if ( !XpAddInc ) then return end

	if XpAddInc == true then
    
  	if XPPos < 100 then
    	XPPos = XPPos + 3
  	end
  else
    if XPPos > 0 then
      XPPos = XPPos - 3
    end
  end
	draw.RoundedBox(0, ScrW() - XPPos, ScrH() / 4, 100, 35, Color(0, 0, 0, 155))
	
	surface.SetDrawColor( Color( 255, 0, 0, Pulsate(2)*180 ) )
	surface.DrawOutlinedRect( ScrW() - XPPos, ScrH() / 4, 100, 35 )
	if XpAddInc == true then
		draw.RoundedBox(0, ScrW() - XPPos - 31, ScrH() / 4, 30, 35, Color(0, 0, 0, 155))
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawOutlinedRect( ScrW() - XPPos - 31, ScrH() / 4, 30, 35 )
		surface.SetDrawColor( Color(255, 255, 255, 255) )
		surface.SetMaterial(expnotificationmat)
		surface.DrawTexturedRect(ScrW() - XPPos - 31,	ScrH() / 3.96, 32, 32)
	end
	
	draw.DrawText("+"..XPgained.." XP", "HUDFontTitle", ScrW() - (XPPos - 24), (ScrH() / 4) + 6, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

end )

net.Receive("xpAwardnextoren", function(len) 
	XPgained = net.ReadFloat()
	XpAddInc = true
  
	timer.Simple(4, function()
	  XpAddInc = false
	end)
  
  
end)

BREACH.Demote = BREACH.Demote || {}

local textcd = 0

function Choose_Faction()
    if CurTime() >= textcd then
        textcd = CurTime() + 0.1
        RXSENDNotify("l:select_faction_ntfcmd")
    end

    if IsValid(BREACH.Demote.MainPanel) then
        return
    end

    local teams_table = {
        { name = "l:ClassD", team_id = TEAM_CLASSD, Icon = Material("nextoren/gui/roles_icon/class_d.png", "smooth") },
        { name = "SCP", team_id = TEAM_SCP, Icon = Material("nextoren/gui/roles_icon/scp.png", "smooth") },
        { name = "l:SCI", team_id = TEAM_SCI, Icon = Material("nextoren/gui/roles_icon/sci.png", "smooth") },
        { name = "l:ntfcmd_unknowns", team_id = 22, Icon = Material("nextoren/gui/roles_icon/scp.png", "smooth") }
    }

    
    

    local pnlW = 320 
    local headerH = 45
    local pnlH = 260 + headerH

    BREACH.Demote.MainPanel = vgui.Create("DPanel")
    local pnl = BREACH.Demote.MainPanel
    pnl:SetSize(pnlW, pnlH)
    
    pnl:SetText("")
    
    pnl.animAlpha = 0
    pnl.animYOffset = 30
    pnl.isClosing = false

    
    function pnl:CloseMenu()
        if self.isClosing then return end
        self.isClosing = true
        gui.EnableScreenClicker(false)
    end

    pnl.Think = function(self)
        local client = LocalPlayer()
        
        
        if client:GetRoleName() ~= role.NTF_Commander or client:Health() <= 0 then
            self:CloseMenu()
        end

        
        if self.isClosing then
            self.animAlpha = Lerp(FrameTime() * 15, self.animAlpha, 0)
            self.animYOffset = Lerp(FrameTime() * 15, self.animYOffset, 30)
            
            if self.animAlpha < 0.05 then
                self:Remove()
            end
        else
            self.animAlpha = Lerp(FrameTime() * 15, self.animAlpha, 1)
            self.animYOffset = Lerp(FrameTime() * 15, self.animYOffset, 0)
        end
        
        self:SetAlpha(self.animAlpha * 255)
        self:SetPos(ScrW() / 2 - (pnlW / 2), ScrH() / 2 - (pnlH / 2) + self.animYOffset)
        
        if not vgui.CursorVisible() and not self.isClosing then 
            gui.EnableScreenClicker(true) 
        end
        
        if input.IsKeyDown(KEY_BACKSPACE) then 
            self:CloseMenu() 
        end
    end

    pnl.Paint = function(self, w, h)
        if DrawBlurPanel then DrawBlurPanel(self) end
        
        
        surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 255)
        surface.DrawRect(0, 0, w, h)
        
        
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
        surface.DrawRect(0, 0, w, headerH)
        
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(0, headerH - 2, w, 2)
        
        
        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        
        local title = string.upper(L("l:ntfcmd_factionlist") or "ВЫБЕРИТЕ ФРАКЦИЮ")
        draw.DrawText(title, "MM_Exp", w / 2, headerH / 2 - 6, color_white, TEXT_ALIGN_CENTER)
    end

    
    
    
    local btnClose = vgui.Create("DButton", pnl)
    btnClose:SetSize(headerH, headerH)
    btnClose:SetPos(pnlW - headerH, 0)
    btnClose:SetText("")
    
    btnClose.hoverLerp = 0
    btnClose.Paint = function(self, w, h)
        self.hoverLerp = Lerp(FrameTime() * 15, self.hoverLerp, self:IsHovered() and 1 or 0)
        
        if self.hoverLerp > 0.01 then
            surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 255 * self.hoverLerp)
            surface.DrawRect(0, 0, w, h)
        end
        
        local clr = Color(255, Lerp(self.hoverLerp, 255, 200), Lerp(self.hoverLerp, 255, 200))
        draw.SimpleText("✕", "MM_Exp", w / 2, h / 2 - 1, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btnClose.DoClick = function()
        surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
        pnl:CloseMenu()
    end

    
    
    
    local scroll = vgui.Create("DScrollPanel", pnl)
    scroll:SetPos(0, headerH)
    scroll:SetSize(pnlW, pnlH - headerH)
    scroll:DockPadding(4, 4, 4, 4)

    local sbar = scroll:GetVBar()
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, w, h) 
        surface.SetDrawColor(10, 10, 10, 200) 
        surface.DrawRect(w/2 - 2, 0, 4, h) 
    end
    sbar.btnGrip.Paint = function(self, w, h)
        local a = self:IsHovered() and 150 or 80
        surface.SetDrawColor(a, a, a, 255)
        surface.DrawRect(w/2 - 2, 0, 4, h)
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end

    
    
    
    for i = 1, #teams_table do
        local btn = scroll:Add("DButton")
        btn:SetText("")
        btn:Dock(TOP)
        btn:SetTall(55)
        btn:DockMargin(0, 0, 0, 4)
        
        btn.hoverLerp = 0
        btn.pressLerp = 0
        local name = string.upper(L(teams_table[i].name))

        btn.Think = function(self)
            if pnl.isClosing then
                self.hoverLerp = Lerp(FrameTime() * 15, self.hoverLerp, 0)
                self.pressLerp = Lerp(FrameTime() * 15, self.pressLerp, 0)
            else
                self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
                self.pressLerp = Lerp(FrameTime() * 20, self.pressLerp, self.Depressed and 1 or 0)
            end
        end

        btn.Paint = function(self, w, h)
            self:SetCursor(pnl.isClosing and "arrow" or "hand")
            
            
            surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
            surface.DrawRect(0, 0, w, h)
            
            
            if self.hoverLerp > 0.01 then
                surface.SetDrawColor(255, 255, 255, 10 * self.hoverLerp)
                surface.DrawRect(0, 0, w, h)
                
                
                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * self.hoverLerp)
                surface.DrawRect(0, 0, 3, h)
            end

            
            if self.pressLerp > 0.01 then
                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 40 * self.pressLerp)
                surface.DrawRect(0, 0, w, h)
            end

            
            surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            
            local iconSize = 38
            surface.SetDrawColor(255, 255, 255, 180 + 75 * self.hoverLerp)
            surface.SetMaterial(teams_table[i].Icon)
            surface.DrawTexturedRect(15, h / 2 - iconSize / 2, iconSize, iconSize)

            
            local txtColorR = Lerp(self.hoverLerp, rust_text_dim.r, color_white.r)
            local txtColorG = Lerp(self.hoverLerp, rust_text_dim.g, color_white.g)
            local txtColorB = Lerp(self.hoverLerp, rust_text_dim.b, color_white.b)
            
            draw.SimpleText(name, "MM_Exp", 65, h / 2 - 1, Color(txtColorR, txtColorG, txtColorB, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        btn.OnCursorEntered = function(self)
            if not pnl.isClosing then
                surface.PlaySound("nextoren/gui/main_menu/button_hover.wav")
            end
        end

        btn.DoClick = function(self)
            if pnl.isClosing then return end

            surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
            
            net.Start("NTF_Special_1")
                net.WriteUInt(teams_table[i].team_id, 12)
            net.SendToServer()

            pnl:CloseMenu()
        end
    end
end


hook.Add("Initialize", "Remove_Xyi", function()
	hook.Remove("PlayerTick", "TickWidgets")
end)

current_observer = current_observer or nil

function CreateInspectPanel(ply)
    current_observer = ply
    local client = LocalPlayer()
    if IsValid(INSPECT_PANEL) then INSPECT_PANEL:Remove() end

    local scrw, scrh = ScrW(), ScrH()
    local boxW, boxH = 420, 80
    local targetX = scrw / 2 - boxW / 2
    local targetY = scrh - boxH - 30

    INSPECT_PANEL = vgui.Create("DPanel")
    local pnl = INSPECT_PANEL
    pnl:SetSize(boxW, boxH)
    pnl:SetPos(targetX, targetY)
    pnl:SetZPos(32767)
    pnl:SetAlpha(0)
    
    pnl.CurAlpha = 0
    pnl.IsDying = false
    pnl.hpLerp = ply:Health() / math.max(ply:GetMaxHealth(), 1)

    local isSCP = ply:GTeam() == TEAM_SCP
    local name = string.upper(ply:Nick())
    local charname = isSCP and "АНОМАЛИЯ" or string.upper(ply:GetNamesurvivor() or "НЕИЗВЕСТНО")
    local roleTxt = string.upper(GetLangRole(ply:GetRoleName()) or "ОПЕРАТИВНИК")
    local teamCol = gteams.GetColor(ply:GTeam()) or color_white
    if ply:GTeam() == TEAM_USA then teamCol = color_white end

    pnl.Think = function(self)
        if client:GetObserverTarget() ~= ply or client:GTeam() ~= TEAM_SPEC then self.IsDying = true end
        local ft = FrameTime() * 12
        if self.IsDying then
            self.CurAlpha = Lerp(ft * 1.5, self.CurAlpha, 0)
            if self.CurAlpha < 5 then self:Remove() end
        else
            self.CurAlpha = Lerp(ft, self.CurAlpha, 255)
        end
        self:SetAlpha(self.CurAlpha)
    end

    pnl.Paint = function(self, w, h)
        if DrawBlurPanel then DrawBlurPanel(self, 3) end

        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, h, h)

        local textX = h + 15
        draw.SimpleText(name, "MM_RoleName", textX, 15, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(charname .. " // " .. roleTxt, "MM_Exp", textX, 40, rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local hpTarget = math.Clamp(IsValid(ply) and (ply:Health() / math.max(ply:GetMaxHealth(), 1)) or 0, 0, 1)
        self.hpLerp = math.Approach(self.hpLerp, hpTarget, FrameTime() * 2)

        local hpColor = rust_green
        if self.hpLerp < 0.5 then hpColor = rust_yellow end
        if self.hpLerp < 0.2 then hpColor = rust_red end

        surface.SetDrawColor(10, 9, 8, 255)
        surface.DrawRect(0, h - 4, w, 4)
        
        surface.SetDrawColor(hpColor)
        surface.DrawRect(0, h - 4, w * self.hpLerp, 4)

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        surface.DrawLine(h, 0, h, h)
    end

    -- 3D Модель
    local mdl = vgui.Create("DModelPanel", pnl)
    mdl:SetPos(1, 1)
    mdl:SetSize(boxH - 2, boxH - 2)
    mdl:SetModel(ply:GetModel())
    mdl.Entity:SetSkin(ply:GetSkin())
    mdl:SetFOV(25)
	--mdl:SetCamPos(Vector(0, 0, -50))
    --mdl.Entity:SetSequence(mdl.Entity:LookupSequence("idle_all_01") or 0)
	mdl.RunAnimation = function() end

    mdl.LayoutEntity = function(self, ent)
        ent:SetAngles(Angle(0, 15, 0))
    end
    for i = 0, ply:GetNumBodyGroups() do mdl.Entity:SetBodygroup(i, ply:GetBodygroup(i)) end

    mdl:SetDirectionalLight(BOX_TOP, Color(150, 150, 150))
    mdl:SetDirectionalLight(BOX_FRONT, Color(200, 200, 200))
    mdl:SetAmbientLight(Color(50, 50, 50))

    timer.Simple(0, function()
        if not IsValid(mdl) or not IsValid(mdl.Entity) then return end
        local head = mdl.Entity:LookupBone("ValveBiped.Bip01_Head1")
        local camTarget = head and mdl.Entity:GetBonePosition(head) or mdl.Entity:GetPos() + Vector(0, 0, 60)
        mdl:SetLookAt(camTarget - Vector(0,0,0))
        mdl:SetCamPos(camTarget + Vector(40, -15, -5))
    end)

    local tbl_bonemerged = ents.FindByClassAndParent("ent_bonemerged", ply)
    timer.Simple(0.1, function()
        if not IsValid(mdl) then return end
        if tbl_bonemerged then
            for _, bonemerge in ipairs(tbl_bonemerged) do
                if not IsValid(bonemerge) then continue end
                local bnm = mdl:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin(), Color(255,255,255))
                if IsValid(bnm) then bnm:SetSkin(bonemerge:GetSkin()) end
            end
        end
        if ply:GTeam() == TEAM_SCP and not ply:GetModel():find("/scp/") and mdl.MakeZombie then mdl:MakeZombie() end
    end)
end

local uiu_doc_mat = Material( "nextoren/gui/new_icons/others/fbidocs_ico.png" )

local clr_bg = Color(0,0,0,200)


local hud_style = CreateConVar("breach_config_hud_style", 0, FCVAR_ARCHIVE, "Changes your HUD style", 0, 1)

function BreachHUDInitialize()

local scale = 100
	local width = ScrW() * scale
	local height = ScrH() * scale
	local offset = ScrH() - height
	local ply = LocalPlayer()
local evaccolor = Color(255,0,0,100)
local frankin_lost = Sound( "nextoren/round_sounds/franklinlost.wav" )
local icon_x, icon_y = ScrW() / 2 - 32, ScrH() / 1.1
local approved_team = {
	[ TEAM_DZ ] = true,
	[ TEAM_SCP ] = true
}
local team_scp_index, team_dz_index = TEAM_SCP, TEAM_DZ
local outline_clr = Color( 255, 12, 0, 210 )
local scpstab = {}
local dztab = {}
local widthz = ScrW() * scale
local heightz = ScrH() * scale
local offset = ScrH() - heightz

function Choose_Weapon()

		local clrgray = Color( 198, 198, 198, 200 )
		local gradient = Material( "vgui/gradient-r" )
	
		local sound_table = {
	
			[ 1 ] = { name = "Searching", class = "br_sound_searching" },
			[ 2 ] = { name = "Random", class = "br_sound_random" },
			[ 3 ] = { name = "Class-D found", class = "br_sound_classd" },
			[ 4 ] = { name = "Stop!", class = "br_sound_stop" },
			[ 5 ] = { name = "Target Lost", class = "br_sound_lost" }
	
		}
	
		BREACH.Demote.MainPanel = vgui.Create( "DPanel" )
		BREACH.Demote.MainPanel:SetSize( 256, 256 )
		BREACH.Demote.MainPanel:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
		BREACH.Demote.MainPanel:SetText( "" )
		BREACH.Demote.MainPanel.DieTime = CurTime() + 10
		BREACH.Demote.MainPanel.Paint = function( self, w, h )
	
			if ( !vgui.CursorVisible() ) then
	
				gui.EnableScreenClicker( true )
	
			end
	
			draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
			draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )
	
	
	
		end
	
		BREACH.Demote.MainPanel.Disclaimer = vgui.Create( "DPanel" )
		BREACH.Demote.MainPanel.Disclaimer:SetSize( 256, 64 )
		BREACH.Demote.MainPanel.Disclaimer:SetPos( ScrW() / 2 - 128, ScrH() / 2 - ( 128 * 1.5 ) )
		BREACH.Demote.MainPanel.Disclaimer:SetText( "" )
	
		local client = LocalPlayer()
	
		BREACH.Demote.MainPanel.Disclaimer.Paint = function( self, w, h )
	
			draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
			draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )
	
			draw.DrawText( "MTF Menu", "ChatFont_new", w / 2, h / 2 - 16, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
			if ( client:GTeam() != TEAM_GUARD || client:Health() <= 0 ) then
	
				if ( IsValid( BREACH.Demote.MainPanel ) ) then
	
					BREACH.Demote.MainPanel:Remove()
	
				end
	
				self:Remove()
	
				gui.EnableScreenClicker( false )
	
			end
	
		end
	
		BREACH.Demote.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.Demote.MainPanel )
		BREACH.Demote.ScrollPanel:Dock( FILL )
	
		for i = 1, #sound_table do
	
			BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add( "DButton" )
			BREACH.Demote.Users:SetText( "" )
			BREACH.Demote.Users:Dock( TOP )
			BREACH.Demote.Users:SetSize( 256, 64 )
			BREACH.Demote.Users:DockMargin( 0, 0, 0, 2 )
			BREACH.Demote.Users.CursorOnPanel = false
			BREACH.Demote.Users.gradientalpha = 0
	
			BREACH.Demote.Users.Paint = function( self, w, h )
	
				if ( self.CursorOnPanel ) then
	
					self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 64 )
	
				else
	
					self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 128 )
	
				end
	
				draw.RoundedBox( 0, 0, 0, w, h, color_black )
				draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )
	
				surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
				surface.SetMaterial( gradient )
				surface.DrawTexturedRect( 0, 0, w, h )
	
				draw.SimpleText( sound_table[ i ].name, "ChatFont_new", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
			end
	
			BREACH.Demote.Users.OnCursorEntered = function( self )
	
				self.CursorOnPanel = true
	
			end
	
			BREACH.Demote.Users.OnCursorExited = function( self )
	
				self.CursorOnPanel = false
	
			end
	
			BREACH.Demote.Users.DoClick = function( self )
	
				RunConsoleCommand(sound_table[ i ].class)
	
				BREACH.Demote.MainPanel.Disclaimer:Remove()
				BREACH.Demote.MainPanel:Remove()
				gui.EnableScreenClicker( false )
	
			end
	
		end
	
	end
	concommand.Add( "choose_weapon", Choose_Weapon )

local ntf_icon = Material( "nextoren/gui/roles_icon/ntf.png" )

local scp173_lerp = 0
local tazer_lerp = 0

function HelicopterStart()

	local client = LocalPlayer()
	local mtfntf = CreateSound(client, "no_music/factions_spawn/ntf_intro.ogg" )
	client:ConCommand( "stopsound" )
	timer.Simple( 1.5, function()
		if ( client && client:IsValid() && client:GTeam() == TEAM_GUARD ) then
			mtfntf:Play()
		end
	end )
	local CutSceneWindow = vgui.Create( "DPanel" )
	CutSceneWindow:SetText( "" )
	CutSceneWindow:SetSize( ScrW(), ScrH() )
	CutSceneWindow.StartAlpha = 255
	CutSceneWindow.StartTime = CurTime() + 15
	CutSceneWindow.Name = "Имя субъекта: " .. client:GetNamesurvivor()
	CutSceneWindow.Status = "Местонахождение: ??? ( Внешняя часть Зоны-19 )"
	CutSceneWindow.Operation = "Операция: Лисья Нора "
	CutSceneWindow.Squad = "Подразделение: Фокстрот-1 "
	CutSceneWindow.Time = " ( Время: " .. string.ToMinutesSeconds( GetRoundTime() - cltime ) .. " )"

	local ExplodedString = string.Explode( "", CutSceneWindow.Time, true )
	local ExplodedString2 = string.Explode( "", CutSceneWindow.Status, true )
	local ExplodedString3 = string.Explode( "", CutSceneWindow.Name, true )
	local ExplodedString4 = string.Explode( "", CutSceneWindow.Squad, true )
	local ExplodedString5 = string.Explode( "", CutSceneWindow.Operation, true )


	local str = ""
	local str1 = ""
	local str2 = ""
	local str3 = ""
	local str4 = ""

	local count = 0
	local count1 = 0
	local count2 = 0
	local count3 = 0
	local count4 = 0
	CutSceneWindow.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h,  color_black, self.StartAlpha  )
		surface.SetDrawColor( 255,255,255, 40  )
		surface.SetMaterial( ntf_icon )
		surface.DrawTexturedRect( ScrW() / 2 - 128, ScrH() / 2 - 128, 256, 256 )
		if ( CutSceneWindow.StartTime <= CurTime() + 10 ) then
			if ( CutSceneWindow.StartTime <= CurTime() ) then
				self.StartAlpha = math.Approach( self.StartAlpha, 0, RealFrameTime() * 40 )
			end
			if ( ( self.NextSymbol || 0 ) <= SysTime() && count2 != #ExplodedString3 ) then
				count2 = count2 + 1
				if ( ExplodedString3[count2] != " " ) then
					surface.PlaySound( "common/talk.wav" )
				end
				self.NextSymbol = SysTime() + .08
				str = str..ExplodedString3[ count2 ]
			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 != #ExplodedString2 ) then
				count1 = count1 + 1
				if ( ExplodedString2[count1] != " " ) then
					surface.PlaySound( "common/talk.wav" )
				end
				self.NextSymbol = SysTime() + .08
				str1 = str1..ExplodedString2[ count1 ]
			elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 == #ExplodedString2 && count != #ExplodedString ) then
				count = count + 1
				if ( ExplodedString[count] != " " ) then
					surface.PlaySound( "common/talk.wav" )
				end
				self.NextSymbol = SysTime() + .08
				str2 = str2..ExplodedString[ count ]
		    elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 == #ExplodedString2 && count == #ExplodedString && count3 != #ExplodedString4 ) then
			    count3 = count3 + 1
			    if ( ExplodedString[count] != " " ) then
				    surface.PlaySound( "common/talk.wav" )
			    end
			    self.NextSymbol = SysTime() + .08
			    str3 = str3..ExplodedString[ count ]
		    elseif ( ( self.NextSymbol || 0 ) <= SysTime() && count2 == #ExplodedString3 && count1 == #ExplodedString2 && count == #ExplodedString && count3 == #ExplodedString4 && count4 != #ExplodedString5) then
			    count4 = count4 + 1
			    if ( ExplodedString[count] != " " ) then
				    surface.PlaySound( "common/talk.wav" )
			    end
			    self.NextSymbol = SysTime() + .08
			    str4 = str4..ExplodedString[ count ]
			end
			draw.SimpleTextOutlined( str, "HUDFont", w / 2, h / 2, Color( 198, 198, 198 , self.StartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 180, self.StartAlpha ) )
			draw.SimpleTextOutlined( str1, "HUDFont", w / 2, h / 2 + 32, Color( 198, 198, 198 , self.StartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 180, self.StartAlpha ) )
			draw.SimpleTextOutlined( str2, "HUDFont", w / 2, h / 2 + 64, Color( 198, 198, 198 , self.StartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 180, self.StartAlpha ) )
			draw.SimpleTextOutlined( str3, "HUDFont", w / 2, h / 2 + 96, Color( 198, 198, 198 , self.StartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 180, self.StartAlpha ) )
			draw.SimpleTextOutlined( str4, "HUDFont", w / 2, h / 2 + 128, Color( 198, 198, 198 , self.StartAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 180, self.StartAlpha ) )
		end
		if ( self.StartAlpha <= 0 ) then
			timer.Simple( 25, function()
				if ( client:GTeam() == TEAM_GUARD ) then
					mtfntf:FadeOut( 10 )
				end
			end )
			self:Remove()
		end
	end
end


local clr_gray = Color( 198, 198, 198 )
local clr_green = Color( 0, 180, 0 )

local klasuniad = Material( "nextoren/gui/roles_icon/class_d.png")
local chaosad = Material( "nextoren/gui/roles_icon/chaos.png")
local dzad = Material( "nextoren/gui/roles_icon/dz.png")
local fbiad = Material( "nextoren/gui/roles_icon/fbi.png")
local gocad = Material( "nextoren/gui/roles_icon/goc.png")
local mtfad = Material( "nextoren/gui/roles_icon/mtf.png")
local ntfad = Material( "nextoren/gui/roles_icon/ntf.png")
local scpad = Material( "nextoren/gui/roles_icon/scp.png")
local sciad = Material( "nextoren/gui/roles_icon/sci.png")
local sbad = Material( "nextoren/gui/roles_icon/sb.png")

local sssci = Material( "nextoren/gui/roles_icon/sci_special.png")

local scpmat = Material("nextoren/gui/roles_icon/scp.png")
local mtfmat = Material("nextoren/gui/roles_icon/mtf.png")
local sbmat = Material("nextoren/gui/roles_icon/sb.png")
local dzmat = Material("nextoren/gui/roles_icon/dz.png")
local chaosmat = Material("nextoren/gui/roles_icon/chaos.png")
local classdmat = Material("nextoren/gui/roles_icon/class_d.png")
local scarletmat = Material("nextoren/gui/roles_icon/scarlet.png")
local gocmat = Material("nextoren/gui/roles_icon/goc.png")
local grumat = Material("nextoren/gui/roles_icon/gru.png")
local fbimat = Material("nextoren/gui/roles_icon/fbi.png")
local scimat = Material("nextoren/gui/roles_icon/sci.png")
local specialscimat = Material("nextoren/gui/roles_icon/sci_special.png")
local ntfmat = Material("nextoren/gui/roles_icon/ntf.png")
local osnmat = Material("nextoren/gui/roles_icon/osn.png")
local obrmat = Material("nextoren/gui/roles_icon/obr.png")
local armat = Material("nextoren/gui/roles_icon/ar.png")
local a1mat = Material("nextoren/gui/roles_icon/a1.png")
local crbmat = Material("nextoren/gui/roles_icon/crb.png")
local fbiagent = Material("nextoren/gui/roles_icon/fbi_agent.png")
local cmbmat = Material("nextoren/gui/roles_icon/cmb.png")
local rebelmat = Material("nextoren/gui/roles_icon/rebel.png")
local americamat = Material("nextoren/gui/roles_icon/america.png")
local reichmat = Material("nextoren/gui/roles_icon/reich.png")

function GetRoleIconByTeam(team, role)
	local roles_icons = scpmat
	if BREACH:IsUiuAgent(role) then return fbiagent end
	if team == TEAM_GUARD then
		roles_icons = mtfmat
	elseif team == TEAM_SECURITY then
		roles_icons = sbmat
	elseif team == TEAM_DZ then
		roles_icons = dzmat
	elseif team == TEAM_CHAOS then
		roles_icons = chaosmat
	elseif team == TEAM_CLASSD then
		roles_icons = classdmat
	elseif team == TEAM_COTSK then
		roles_icons = scarletmat
	elseif team == TEAM_GOC then
		roles_icons = gocmat
	elseif team == TEAM_GRU then
		roles_icons = grumat
	elseif team == TEAM_USA then
		roles_icons = fbimat
	elseif team == TEAM_SCI then
		roles_icons = scimat
	elseif team == TEAM_SPECIAL then
		roles_icons = specialscimat
	elseif team == TEAM_NTF then
		roles_icons = ntfmat
	elseif team == TEAM_OSN then
		roles_icons = osnmat
	elseif team == TEAM_QRT then
		roles_icons = obrmat
	elseif team == TEAM_AR then
		roles_icons = armat
	elseif team == TEAM_ALPHA1 then
		roles_icons = a1mat
	elseif team == TEAM_CBG then
		roles_icons = crbmat
	elseif team == TEAM_SCP then
		roles_icons = scpmat
	elseif team == TEAM_COMBINE then
		roles_icons = cmbmat
	elseif team == TEAM_RESISTANCE then
		roles_icons = rebelmat
	elseif team == TEAM_AMERICA then
		roles_icons = americamat
	elseif team == TEAM_NAZI then
		roles_icons = reichmat
	end

	return roles_icons
end

local blinkblack = Color(0, 0, 0)
local blinkalmostblack = Color(0, 0, 0, 200)
local blinkmat = Material("nextoren_hud/ico_blink.png")
local tazermat = Material("rxsend/ui/tazer_ammo.png")
local icoindex = Material("nextoren_hud/ico_index.png")
local icoindex2 = Material("nextoren_hud/ico_index2.png")
local eyedropeffectclr = Color(10, 45, 255, 0)
local roleblack = Color(0, 0, 0)
local rolealmostblack = Color(0, 0, 0, 200)
local rolealmostwhite = Color(255, 255, 255, 200)
local roleblankcolor = Color(0, 0, 0, 200)
local rolemat = Material("nextoren_hud/ico_role.png")
local boostcolor = Color( 10, 45, 255, 0)
local hpcoloralmostwhite = Color(255,255,255,230)
local venenomat = Material("veneno.png")
local healthmat = Material("nextoren_hud/ico_health.png")
local healthmatnew = Material("nextoren_hud/ico_health_new.png")
local staminamat = Material("nextoren_hud/ico_stamina.png")
local staminamatnew = Material("nextoren_hud/ico_stamina_new.png")
local newr = Material("nextoren_hud/round_box_3.png")
local newrb = Material("nextoren_hud/round_box_3_big.png")
local newrr = Material("nextoren_hud/round_box_3_r.png")
local newrl = Material("nextoren_hud/round_box_3_l.png")

local draw = draw
local surface = surface
local GetGlobalBool = GetGlobalBool
local ScrW = ScrW
local ScrH = ScrH
local IsValid = IsValid

local gru_task_translations = {
	["Evacuation"] = "l:gru_hud_task_evacuation",
	["Срыв эвакуации"] = "l:gru_hud_task_evacuation",
	["MilitaryHelp"] = "l:gru_hud_task_militaryhelp",
	["Помощь военному персоналу"] = "l:gru_hud_task_militaryhelp",
	["[none]"] = "l:gru_hud_task_none"
}

local vec_forward = Vector( 70 )

function CanSeePlayer(ply)

	local value = LocalPlayer():GetAimVector():Dot( ( ply:GetPos() - LocalPlayer():GetPos() + vec_forward ):GetNormalized() )

	if !LocalPlayer():IsLineOfSightClear(ply:GetPos()) then return false end

	return ( value > .39 )

end

local data_levels_hud = {}

local data_levels = {
	[5] = {ico = Material("nextoren/gui/new_icons/level/lvl1.png", "smooth")},
	[10] = {ico = Material("nextoren/gui/new_icons/level/lvl2.png", "smooth")},
	[15] = {ico = Material("nextoren/gui/new_icons/level/lvl3.png", "smooth")},
	[20] = {ico = Material("nextoren/gui/new_icons/level/lvl4.png", "smooth")},
	[25] = {ico = Material("nextoren/gui/new_icons/level/lvl5.png", "smooth")},
	[30] = {ico = Material("nextoren/gui/new_icons/level/lvl6.png", "smooth")},
	[35] = {ico = Material("nextoren/gui/new_icons/level/lvl7.png", "smooth")},
	[40] = {ico = Material("nextoren/gui/new_icons/level/lvl8.png", "smooth")},
	[45] = {ico = Material("nextoren/gui/new_icons/level/lvl9.png", "smooth")},
}

for i, v in pairs(data_levels) do
	data_levels[i].widthpercentage = v.ico:Width()/v.ico:Height()
end

for i = 0, 5 do
	data_levels_hud[i] = data_levels[5]
end
for i = 6, 10 do
	data_levels_hud[i] = data_levels[10]
end
for i = 11, 15 do
	data_levels_hud[i] = data_levels[15]
end
for i = 16, 20 do
	data_levels_hud[i] = data_levels[20]
end
for i = 21, 25 do
	data_levels_hud[i] = data_levels[25]
end
for i = 26, 30 do
	data_levels_hud[i] = data_levels[30]
end
for i = 31, 35 do
	data_levels_hud[i] = data_levels[35]
end
for i = 36, 44 do
	data_levels_hud[i] = data_levels[40]
end
data_levels_hud[45] = data_levels[45]


local tvar_health_smooth = 0
local tvar_health_last = 0
local tvar_shake = 0
local tvar_shake_time = 0


hook.Add( "HUDPaint", "Breach_HUD", function()
	
	if !IsValid(ply) then ply = LocalPlayer() end
	local client = ply
	local myteam = LocalPlayer():GTeam()
	local myrole = LocalPlayer():GetRoleName()
	if myteam == TEAM_CLASSD or myteam == TEAM_CHAOS then
		Show_Spy(TEAM_CHAOS)
	elseif myteam == TEAM_GOC then
		Show_Spy(TEAM_GOC)
	end

	if client:GTeam() == TEAM_SCP and client:GetPos().z < -4000 then
		
		for k,v in player.Iterator() do
			if v:GetPos().z < -4569 then
				outline.Add(v,Color(255,0,0),1)
			end
		end
	end
	
	if disablehud then return end
	if playing then return end
	
		
		
	
	local my_par = client:GetParent()
	if IsValid(client) and IsValid(my_par) and my_par:GetClass() == "prop_ragdoll" then return end
	if client:Health() <= 0 then return end 
	local clienttable = client:GetTable()
	if clienttable.CameraEnabled == true then return end
	if LocalPlayer():GetInDimension() then return end
	if myteam == TEAM_AR then return end
	if LocalPlayer().br_scp079_mode then return end
	if IsValid(MainMogFrame) then return end

	if client:GTeam() == TEAM_GRU then

				  
	   	

		DrawBlurRect(ScrW() / 128, ScrH() / 64, ScrW() / 8, ScrH() / 9)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(ScrW() / 128, ScrH() / 64, ScrW() / 8, ScrH() / 9, 1)
		SigmaYgliDraw(ScrW() / 128, ScrH() / 64, ScrW() / 8, ScrH() / 9, Color(255,255,255), ScrW() / 64)

		draw.SimpleText(L"l:tasks_GRU_Name", "BudgetLabel", ScrW() / 15, ScrH() / 32, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		draw.SimpleText(L"l:tasks_first", "BudgetLabel", ScrW() / 64, ScrH() / 22, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		draw.SimpleText(L"l:tasks_second", "BudgetLabel", ScrW() / 64, ScrH() / 13, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		if GetGlobalInt("TASKS_GRU_1") != 5 then
			draw.SimpleText(L"l:tasks_1".. GetGlobalInt("TASKS_GRU_1") .." / 5", "BudgetLabel", ScrW() / 64, ScrH() / 16, Color(255,95,95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		else
			draw.SimpleText(L"l:tasks_1".. GetGlobalInt("TASKS_GRU_1") .." / 5 | ".."Готово", "BudgetLabel", ScrW() / 64, ScrH() / 16, Color(95,255,95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		end
		if GetGlobalInt("TASKS_GRU_2") >= 3 then
			draw.SimpleText(L"l:tasks_2".. GetGlobalInt("TASKS_GRU_2") .." / 3 | ".."Готово", "BudgetLabel", ScrW() / 64, ScrH() / 11, Color(95,255,95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		else
			draw.SimpleText(L"l:tasks_2".. GetGlobalInt("TASKS_GRU_2") .." / 3", "BudgetLabel", ScrW() / 64, ScrH() / 11, Color(255,95,95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		end
		if GetGlobalInt("TASKS_GRU_3") >= 3 then
			draw.SimpleText(L"l:tasks_3".. GetGlobalInt("TASKS_GRU_3") .." / 3 | ".."Готово", "BudgetLabel", ScrW() / 64, ScrH() / 9.5, Color(95,255,95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		else
			draw.SimpleText(L"l:tasks_3".. GetGlobalInt("TASKS_GRU_3") .." / 3", "BudgetLabel", ScrW() / 64, ScrH() / 9.5, Color(255,95,95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		end
		
		
	  	
	  	

		
	  	
	  	


		
	  	
	  	

		
	  	
	  	
	elseif client:GTeam() == TEAM_GUARD and client:GetModel() == "models/cultist/humans/mog/mog.mdl" then
		


local bx = math.Round(ScrW() / 128)
		local by = math.Round(ScrH() / 64)
		local bw = math.max(ScrW() * 0.16, 320)
		local bh = 135

		surface.SetDrawColor(18, 16, 15, 240)
		surface.DrawRect(bx, by, bw, bh)

		surface.SetDrawColor(30, 28, 25, 255)
		surface.DrawRect(bx, by, bw, 25)

		surface.SetDrawColor(218, 165, 32, 255)
		surface.DrawRect(bx, by + 25, bw, 2)

		surface.SetDrawColor(255, 255, 255, 10)
		surface.DrawOutlinedRect(bx, by, bw, bh, 1)

		draw.SimpleText(string.upper(L"l:tasks_TG_Name" or "ОПЕРАТИВНЫЕ ЗАДАЧИ"), "MM_Exp", bx + 12, by + 12, Color(230, 230, 230, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		draw.SimpleText(string.upper(L"l:tasks_TG_first" or "ПЕРВИЧНАЯ ЦЕЛЬ"), "MM_SmallName", bx + 12, by + 35, Color(140, 140, 140, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		surface.SetDrawColor(10, 9, 8, 200)
		surface.DrawRect(bx + 12, by + 53, 10, 10)
		
		if GetGlobalInt("TASKS_TG_1") >= GetGlobalInt("TASKS_TG_1_min") then
			surface.SetDrawColor(112, 126, 73, 255)
			surface.DrawRect(bx + 14, by + 55, 6, 6)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(bx + 12, by + 53, 10, 10, 1)
			
			draw.SimpleText(string.upper(L"l:tasks_TG_1" or ""), "MM_Exp", bx + 30, by + 50, Color(140, 140, 140, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText("[ ВЫПОЛНЕНО ]", "MM_Exp", bx + bw - 12, by + 50, Color(112, 126, 73, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		else
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(bx + 12, by + 53, 10, 10, 1)
			
			draw.SimpleText(string.upper(L"l:tasks_TG_1" or ""), "MM_Exp", bx + 30, by + 50, Color(230, 230, 230, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(GetGlobalInt("TASKS_TG_1") .. " / " .. GetGlobalInt("TASKS_TG_1_min"), "MM_Exp", bx + bw - 12, by + 50, Color(188, 64, 43, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end

		draw.SimpleText(string.upper(L"l:tasks_TG_second" or "ВТОРИЧНЫЕ ЦЕЛИ"), "MM_SmallName", bx + 12, by + 75, Color(140, 140, 140, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		surface.SetDrawColor(10, 9, 8, 200)
		surface.DrawRect(bx + 12, by + 93, 10, 10)
		
		if GetGlobalInt("TASKS_TG_2") >= GetGlobalInt("TASKS_TG_2_min") then
			surface.SetDrawColor(112, 126, 73, 255)
			surface.DrawRect(bx + 14, by + 95, 6, 6)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(bx + 12, by + 93, 10, 10, 1)
			
			draw.SimpleText(string.upper(L"l:tasks_TG_2" or ""), "MM_Exp", bx + 30, by + 90, Color(140, 140, 140, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText("[ ВЫПОЛНЕНО ]", "MM_Exp", bx + bw - 12, by + 90, Color(112, 126, 73, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		else
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(bx + 12, by + 93, 10, 10, 1)
			
			draw.SimpleText(string.upper(L"l:tasks_TG_2" or ""), "MM_Exp", bx + 30, by + 90, Color(230, 230, 230, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(GetGlobalInt("TASKS_TG_2") .. " / " .. GetGlobalInt("TASKS_TG_2_min"), "MM_Exp", bx + bw - 12, by + 90, Color(188, 64, 43, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end

		surface.SetDrawColor(10, 9, 8, 200)
		surface.DrawRect(bx + 12, by + 113, 10, 10)
		
		if GetGlobalInt("TASKS_TG_3") >= GetGlobalInt("TASKS_TG_3_min") then
			surface.SetDrawColor(112, 126, 73, 255)
			surface.DrawRect(bx + 14, by + 115, 6, 6)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(bx + 12, by + 113, 10, 10, 1)
			
			draw.SimpleText(string.upper(L"l:tasks_TG_3" or ""), "MM_Exp", bx + 30, by + 110, Color(140, 140, 140, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText("[ ВЫПОЛНЕНО ]", "MM_Exp", bx + bw - 12, by + 110, Color(112, 126, 73, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		else
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(bx + 12, by + 113, 10, 10, 1)
			
			draw.SimpleText(string.upper(L"l:tasks_TG_3" or ""), "MM_Exp", bx + 30, by + 110, Color(230, 230, 230, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(GetGlobalInt("TASKS_TG_3") .. " / " .. GetGlobalInt("TASKS_TG_3_min"), "MM_Exp", bx + bw - 12, by + 110, Color(188, 64, 43, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end
		
		
	  	
	  	

		
	  	
	  	


		
	  	
	  	

		
	  	
	  	

		
	

	
	
	
	
	
	
	
	
	
	
	
	

	
	
	


	
	
	

	
	
	
	

	
	

	
	
	
	end
	local tvar = nil
	for k,v in player.Iterator() do
		if v:GTeam() == TEAM_XMAS_VRAG then
			tvar = v
		end
	end

	
	if tvar then
	    local current_health = tvar:Health()
	    local max_health = tvar:GetMaxHealth()
	
	    
	    if tvar_health_last != current_health then
	        tvar_health_last = current_health
	        tvar_shake = 5 
	        tvar_shake_time = CurTime() + 0.3 
	    end
	
	    
	    tvar_health_smooth = Lerp(FrameTime() * 5, tvar_health_smooth, current_health)
	
	    
	    local shake_offset_x = 0
	    local shake_offset_y = 0
	
	    if tvar_shake > 0 then
	        if CurTime() < tvar_shake_time then
	            
	            local shake_intensity = tvar_shake * (tvar_shake_time - CurTime()) / 0.3
	            shake_offset_x = math.sin(CurTime() * 30) * shake_intensity
	            shake_offset_y = math.cos(CurTime() * 25) * shake_intensity
	        else
	            tvar_shake = 0
	        end
	    end
	
	    
	    local center_x = ScrW() / 2 + shake_offset_x
	    local center_y = ScrH() / 32 + shake_offset_y
	    local bar_x = ScrW() / 4 + shake_offset_x
	    local bar_y = ScrH() / 16 + shake_offset_y
	
	    draw.SimpleText("НОВОГОДНЯЯ ТВАРЬ", "ImpactBig", center_x, center_y, Color(255,61,61), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	    
	    draw.RoundedBox(0, bar_x, bar_y, ScrW() / 2, ScrH() / 32, Color(255,255,255,10))
	
	    
	    local health_percent = tvar_health_smooth / max_health
	    local bar_width = ScrW() / 2 * math.max(0, health_percent)
	
	    
	    local pulse = 1
	    if health_percent < 0.3 then
	        pulse = 1 + math.sin(CurTime() * 5) * 0.1
	    end
	
	    
	    local bar_color = Color(196,39,39)
	    bar_color.r = math.min(255, bar_color.r * pulse)
	
	    draw.RoundedBox(0, bar_x, bar_y, bar_width, ScrH() / 32, bar_color)
	
	    
	    if tvar_health_smooth < current_health then
	        local missing_width = ScrW() / 2 * ((current_health - tvar_health_smooth) / max_health)
	        draw.RoundedBox(0, bar_x + bar_width, bar_y, missing_width, ScrH() / 32, Color(255, 100, 100, 100))
	    end
	
	    
	    draw.SimpleText(math.Round(tvar_health_smooth).." | "..max_health, "ImpactSmall", 
	                   center_x, ScrH() / 13 + shake_offset_y, 
	                   Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	    
	    local corner_size = ScrW() / 64
	
	    surface.SetDrawColor(255, 255, 255)
	    surface.SetMaterial(Material("nextoren_hud/round_boxe_1.png"))
	    surface.DrawTexturedRect(bar_x, ScrH() / 15 + shake_offset_y, corner_size, corner_size)
	
	    surface.SetDrawColor(255, 255, 255)
	    surface.SetMaterial(Material("nextoren_hud/round_boxe_2.png"))
	    surface.DrawTexturedRect(ScrW() / 1.36 + shake_offset_x, ScrH() / 15 + shake_offset_y, corner_size, corner_size)
	
	    surface.SetDrawColor(255, 255, 255)
	    surface.SetMaterial(Material("nextoren_hud/round_boxe_4.png"))
	    surface.DrawTexturedRect(bar_x, bar_y, corner_size, corner_size)
	
	    surface.SetDrawColor(255, 255, 255)
	    surface.SetMaterial(Material("nextoren_hud/round_boxe_3.png"))
	    surface.DrawTexturedRect(ScrW() / 1.36 + shake_offset_x, bar_y, corner_size, corner_size)
	
	    
	    if tvar_shake > 0 and CurTime() < tvar_shake_time then
	        local flash_alpha = (tvar_shake_time - CurTime()) / 0.3 * 30
	        draw.RoundedBox(0, bar_x, bar_y, ScrW() / 2, ScrH() / 32, Color(255, 100, 100, flash_alpha))
	    end
	end
	if table.HasValue({TEAM_AMERICA,TEAM_COMBINE,TEAM_RESISTANCE,TEAM_NAZI},client:GTeam()) then
		draw.RoundedBox(0, ScrW() / 128, ScrH() / 64, ScrW() / 8, ScrH() / 9, Color(255,255,255,10))
		
    	draw.SimpleText("ТОП 5 ИГРОКОВ", "BudgetLabel", ScrW() / 15, ScrH() / 32, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
    	local players = player.GetAll()
    	local playerScores = {}
		
    	for _, ply in ipairs(players) do
    	    if IsValid(ply) then
    	        local enemykill = ply:Frags()
    	        local score = enemykill
			
    	        table.insert(playerScores, {
    	            player = ply,
    	            score = score,
    	            name = ply:Nick()
    	        })
    	    end
    	end
	
    	table.sort(playerScores, function(a, b) 
    	    return a.score > b.score 
    	end)
	
    	local startY = ScrH() / 22
    	local lineHeight = ScrH() / 64
	
    	for i = 1, 5 do
    	    if playerScores[i] then
    	        local data = playerScores[i]
    	        local yPos = startY + (i-1) * lineHeight
    	        local color = i == 1 and Color(255, 215, 0) or Color(255, 255, 255)
			
    	        draw.SimpleText(
    	            i .. ". " .. string.sub(data.name, 1, 12) .. ": " .. math.Round(data.score, 2),
    	            "BudgetLabel", 
    	            ScrW() / 64, 
    	            yPos, 
    	            color, 
    	            TEXT_ALIGN_LEFT, 
    	            TEXT_ALIGN_CENTER
    	        )
    	    end
    	end
	
    	surface.SetDrawColor(255, 255, 255)
    	surface.SetMaterial(Material("nextoren_hud/round_boxe_1.png"))
    	surface.DrawTexturedRect(ScrW() / 128, ScrH() / 10, ScrW() / 64, ScrW() / 64)

    	surface.SetDrawColor(255, 255, 255)
    	surface.SetMaterial(Material("nextoren_hud/round_boxe_2.png"))
    	surface.DrawTexturedRect(ScrW() / 8.5, ScrH() / 10, ScrW() / 64, ScrW() / 64)

    	surface.SetDrawColor(255, 255, 255)
    	surface.SetMaterial(Material("nextoren_hud/round_boxe_4.png"))
    	surface.DrawTexturedRect(ScrW() / 128, ScrH() / 64, ScrW() / 64, ScrW() / 64)

    	surface.SetDrawColor(255, 255, 255)
    	surface.SetMaterial(Material("nextoren_hud/round_boxe_3.png"))
    	surface.DrawTexturedRect(ScrW() / 8.5, ScrH() / 64, ScrW() / 64, ScrW() / 64)
	end

	//surface.SetMaterial( MATS.menublack )
	//MATS.menublack:SetFloat("$blur", 5)
	//MATS.menublack:Recompute()
	//render.UpdateScreenEffectTexture()

	

	

	

	
	
	
	
	
	
	
	
	
	
	

	if client:GetRoleName() == role.SCI_SPECIAL_VISION then
		for k,v in player.Iterator() do
			if v:GTeam() == TEAM_SCP and v:GetNWBool("SCPCanSea") then
				outline.Add(v,Color(255,0,0),1)
			end
		end
	end




	

	if ( ply:GTeam() == TEAM_SCP ) then
	
		hook.Add( "PreDrawOutlines", "Draw_other_scps", function()
	
		    if ( client:GTeam() != team_scp_index  ) then
	
			    clienttable["NextCheckSCP"] = nil
			    hook.Remove( "PreDrawOutlines", "Draw_other_scps" )
			    return
		    end
	
		    if ( ( clienttable["NextCheckSCP"] || 0 ) < CurTime() ) then
	
			clienttable["NextCheckSCP"] = CurTime() + 0
	
			local players_table = player.GetAll()
	
			for i = 1, #players_table do
	
			  local player = players_table[ i ]
	
			  if ( player != client && approved_team[ player:GTeam() ] && !player:IsFrozen() && !( table.HasValue( scpstab, player ) || table.HasValue( dztab, player ) ) ) then
	
				if ( player:GTeam() == team_scp_index ) then

					if player:GetRoleName() != "SCP173" then
	
					  scpstab[ #scpstab + 1 ] = player

					
						
							
						

					end
	
				else
	
				  dztab[ #dztab + 1 ] = player

				    local bonemerged_tbl = ents.FindByClassAndParent("ent_bonemerged", dz)

				    if ( bonemerged_tbl && bonemerged_tbl:IsValid() ) then

					    for i = 1, #bonemerged_tbl do

					        dztab[ #dztab + 1 ] = bonemerged_tbl[i]

						end

					end
	
				end
	
			  end
	
			end
	
			if ( #scpstab > 0 ) then
	
			  for i = 1, #scpstab do
	
				local scp = scpstab[ i ]
	
				if ( !(IsValid(scp) and scp:IsPlayer()) or !( scp && scp:IsValid() ) || scp:Health() <= 0 || scp:GTeam() != team_scp_index ) then
					if IsValid(scp) and scp:GetClass() != "base_gmodentity" then
					  table.remove( scpstab, i )
					end
	
				end
	
			  end
	
			end
	
			if ( #dztab > 0 ) then
	
			  for i = 1, #dztab do
	
				local dz = dztab[ i ]
	
				if ( !( dz && dz:IsValid() ) || dz:Health() <= 0 || dz:GTeam() != team_dz_index ) then
	
				  table.remove( dztab, i )
	
				end
	
			  end
	
			end
	
		  end
	
		  if ( #scpstab > 0 ) then
	
			outline.Add( scpstab, outline_clr, 0 )
	
		  end
	
		  if ( #dztab > 0 ) then
			local dzcolor = gteams.GetColor( TEAM_DZ )
			outline.Add( dztab, dzcolor, 2 )
	
		  end
	
		end )
	end

	if IsValid( client ) then
		

		if ply:GTeam() == TEAM_SPEC then
			local ent = client:GetObserverTarget()
			
			if IsValid(ent) then
				if ent:IsPlayer() then
					if current_observer != ent then
						CreateInspectPanel(ent)
					end
				end
			end
		end
	    local role = "none"
	  if !clang then return end
		if not clienttable.GetRoleName then
			player_manager.RunClass( client, "SetupDataTables" )
		elseif client:GTeam() != TEAM_SPEC then
			
		else
			
			
			
				
					
					
					
				
			
		end
		local hp = ply:Health()
		local maxhp = ply:GetMaxHealth()
		if !client.Stamina then client.Stamina = 100 end
		local stamina = math.Round(client.Stamina)
		local exhausted = clienttable.exhausted
		local color = gteams.GetColor(ply:GTeam())

		



		local color = gteams.GetColor( ply:GTeam() )

		local scrw, scrh = ScrW(), ScrH()

	local width = 355
	local height = 120
	local x = 10
	local y = scrh - height - 10

	local lvlH = 70
	local lvlW = 95
	local vledOffsetH = scrh - 25 - 25

	local clientlevel = client:GetNLevel()

	local leveldata =	data_levels_hud[45]

	if data_levels_hud[clientlevel] then leveldata = data_levels_hud[clientlevel] end

	local defaultx = 45

	local icosize = 80

	local icowidth = math.floor(80*1)

	
	
	

    surface.SetFont( "TimeLeft" )

    
    

 	   if client:GTeam() != TEAM_SPEC and ply:GTeam() != TEAM_SCP then

		    
			

			local bd = 3
			local blink = blinkHUDTime
		    if var == nil then 
			    var = 100; 
		    end

		    local scp173 = nil
		    local scps = gteams.GetPlayers(TEAM_SCP)
		    for i = 1, #scps do
		    	if IsValid(scps[i]) and scps[i]:GetRoleName() == SCP173 then scp173 = scps[i]:GetNWEntity("SCP173Statue") end
		    end
		    if #scps > 0 and IsValid(scp173) and CanSeePlayer(scp173) then
		    	scp173_lerp = Lerp(FrameTime()*10, scp173_lerp, 1)
		    else
		    	scp173_lerp = Lerp(FrameTime()*8, scp173_lerp, 0)
		    end
		    if scp173_lerp > 0.05 then
	            draw.RoundedBox(0, 10, scrh-50-150, 40, 40, ColorAlpha(blinkblack, scp173_lerp*255));
	            draw.RoundedBox(0, 60, scrh-44-150, 211, 28, ColorAlpha(blinkalmostblack, scp173_lerp*200));
	            surface.SetDrawColor(255, 255, 255, scp173_lerp*255);

	            surface.SetMaterial(blinkmat);
	            surface.DrawTexturedRect(13, scrh-47-150, 34, 34);

	            surface.SetDrawColor(255, 255, 255, scp173_lerp*75);
	            surface.DrawOutlinedRect(10, scrh-50-150, 40, 40);

	            surface.DrawOutlinedRect(60, scrh-44-150, 211, 28);

	            surface.SetDrawColor(255, 255, 255, scp173_lerp*200);
	            surface.SetMaterial(icoindex2);
			    local bbars = 0
			    local bbars = blink / bd * 16
			    if bbars > 16 then 
				    bbars = 16 
			    end
			    local col = ColorAlpha(color_white, scp173_lerp*255)

			    if eyedropeffect > CurTime() then
			    	eyedropeffectclr["a"] = Pulsate( 2 ) * 120
			    	col = eyedropeffectclr
			    end
			    surface.SetDrawColor(col)
			    surface.SetMaterial(icoindex2)
			    for i=1, bbars do
				    surface.DrawTexturedRect(62 + (i-1)*13, scrh-42-150, 12, 24);
			    end
			  end
		    blink = string.format("%.1f", blink)
		    bd = string.format("%.1f", bd)
			

	end
	

	  if cl == nil then cl = rolealmostwhite; end

	
		

local activeweapon = LocalPlayer():GetActiveWeapon()

if IsValid(activeweapon) and activeweapon:GetClass() == "item_tazer" and activeweapon:Clip1() < 100 and ply:KeyDown(IN_RELOAD) then
    tazer_lerp = Lerp(FrameTime() * 8, tazer_lerp, 1)
else
    tazer_lerp = math.Approach(tazer_lerp, 0, FrameTime() * 4)
end

if tazer_lerp > 0.01 then
    local rust_panel   = Color(18, 16, 15, 245 * tazer_lerp)
    local rust_outline = Color(255, 255, 255, 15 * tazer_lerp)
    local rust_green   = Color(112, 126, 73, 255 * tazer_lerp)
    local rust_yellow  = Color(218, 165, 32, 255 * tazer_lerp)
    local rust_red     = Color(188, 64, 43, 255 * tazer_lerp)
    
    local boxW, boxH = 50, 65
    local boxX = scrw/2 - boxW/2
    local boxY = scrh/1.3 - 50

    surface.SetDrawColor(rust_panel)
    surface.DrawRect(boxX, boxY, boxW, boxH)

    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 1)

    if IsValid(activeweapon) and activeweapon:GetClass() == "item_tazer" then
        local clip = activeweapon:Clip1() or 0
        local max_clip = 15
        
        local statusColor = rust_green
        local textAlpha = 255 * tazer_lerp

        if clip <= 30 then
            statusColor = rust_yellow
        end
        if clip <= 5 then
            statusColor = rust_red
            textAlpha = (150 + Pulsate(6) * 105) * tazer_lerp 
        end

        surface.SetDrawColor(statusColor.r, statusColor.g, statusColor.b, textAlpha)
        surface.DrawRect(boxX, boxY, boxW, 2)

        surface.SetDrawColor(255, 255, 255, 200 * tazer_lerp)
        surface.SetMaterial(tazermat)
        local iconSize = 28
        surface.DrawTexturedRect(boxX + boxW/2 - iconSize/2, boxY + 8, iconSize, iconSize)

        draw.DrawText(clip .. "%", "MM_Exp", boxX + boxW/2, boxY + 38, ColorAlpha(statusColor, textAlpha), TEXT_ALIGN_CENTER)

        local barW = boxW - 12
        local barH = 4
        local barX = boxX + 6
        local barY = boxY + boxH - 8

        surface.SetDrawColor(10, 9, 8, 200 * tazer_lerp)
        surface.DrawRect(barX, barY, barW, barH)

        local fillW = math.Clamp((clip / max_clip) * barW, 0, barW)
        surface.SetDrawColor(statusColor.r, statusColor.g, statusColor.b, textAlpha)
        surface.DrawRect(barX, barY, fillW, barH)
    end
end

	
    
    


	
    
   
   	
   


 end
 	

end ) 

local offset = Vector( 0, 0, 85 )
local lvlcolor = Color(255, 255, 255, 255)
local angletoedit = Angle( 0, 0, 90 )
local talkcolor1 = Color( 255, 255, 255, 200 )
local talkcolor2 = Color( 0, 0, 0, 255 )
local cam = cam



local whiteblack = ColorAlpha( color_white, 200 )
local offset = Vector( 0, 0, 20 )
local alivepl = {}

local team_index_spec, team_index_scp = TEAM_SPEC, TEAM_SCP

local max_distance = 90000 

function DrawTextInformation()

  local client = LocalPlayer()
  if ( client:GTeam() == team_index_spec ) then return end
  if GetConVar("breach_config_screenshot_mode"):GetInt() == 1 then return end

  if ( ( alivepl.NextUpdate || 0 ) < CurTime() ) then

    alivepl = player.GetAll()
    alivepl.NextUpdate = CurTime() + .8

  end

  for i = 1, #alivepl do

    local player = alivepl[ i ]

    if ( player == client ) then continue end
    if ( !( player && player:IsValid() ) ) then continue end

    if ( player:GetNoDraw() ) then continue end

    local speaking = player:IsSpeaking()
    local typing = player:IsTyping()

    if ( !( typing || speaking ) ) then continue end

    local Distance = client:GetPos():DistToSqr( player:GetPos() )
    if ( Distance > max_distance ) then continue end

    local player_team = player:GTeam()

    local BoneIndx = player:LookupBone( "ValveBiped.Bip01_Head1" )

    

    if ( player_team == team_index_spec || player_team == team_index_scp ) then continue end

    if ( typing || speaking ) then

      if ( !isnumber( BoneIndx ) ) then continue end

      local BonePos = player:GetBonePosition( BoneIndx )
      BonePos:Add( offset )

      local eyeang = client:EyeAngles().y - 90
      local ang = Angle( 0, eyeang, 90 )

      cam.Start3D2D( BonePos, ang, .1 )

        if ( typing or speaking ) then

          draw.SimpleText( BREACH.TranslateString("l:speaks"), "char_title", 1, 45, whiteblack, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        end

      cam.End3D2D()

    end

  end

end
hook.Add( "PostDrawTranslucentRenderables", "TalkingSpeakinginfo", DrawTextInformation)



end 

hook.Add("InitPostEntity", "BreachHUDInitialize", BreachHUDInitialize)


if isfunction(BreachHUDInitialize) then
	BreachHUDInitialize()
end

local ANGLE = FindMetaTable("Angle")

function ANGLE:CalculateVectorDot( vec )
	local x = self:Forward():DotProduct( vec )
	local y = self:Right():DotProduct( vec )
	local z = self:Up():DotProduct( vec )

	return Vector( x, y, z )
end



local step = 0
local MovementDot = { x = 0, y = 0, z = 0 }
local vel = 0
local cos = 0
local plane = 0
local scale = 1
local y = 0

local team_spec_index, team_scp_index = TEAM_SPEC, TEAM_SCP

local forbidden_teams = {

	[ TEAM_SPEC ] = true,
	[ TEAM_SCP ] = true

}

hook.Add( "Think", "ViewBob_Think", function()

	local client = LocalPlayer()

	if ( !forbidden_teams[ client:GTeam() ] && client:Health() > 0 && client:GetMoveType() != MOVETYPE_NOCLIP ) then

		vel = client:GetVelocity()
		MovementDot = EyeAngles():CalculateVectorDot( vel )
		
		step = 18

		if ( client:Health() < client:GetMaxHealth() * .3 ) then

			scale = 2
			step = 20

		end

		cos = math.cos( SysTime() * step )
		plane = ( math.max( math.abs( MovementDot.x ) - 100, 0 ) + math.max( math.abs( MovementDot.y ) - 100, 0 ) ) / 128

		y = math.cos( SysTime() * step / 2 ) * plane * scale

	end

end )

local vec_zero = vector_origin

hook.Add( "CalcViewModelView", "CalcViewModel", function( wep, v, oldPos, oldAng, ipos, iang )

	local client = LocalPlayer()

	if client:GetInDimension() then return end

	if ( !forbidden_teams[ client:GTeam() ] && client:Health() > 0 && ( ( !isnumber( vel ) && vel:Length2DSqr() > .25 ) || client:GetVelocity():Length2DSqr() > .25 ) && client:GetMoveType() != MOVETYPE_NOCLIP ) then

		local pos, ang

		if ( isfunction( wep.GetViewModelPosition ) ) then

			pos, ang = wep:GetViewModelPosition( ipos, iang )

		else

			pos = ipos
			ang = iang

		end

		local origin = Vector( 0, y, ( cos * plane ) * scale )
		origin:Rotate( ang )

		return origin + pos - ( transition != 0 && Vector( 0, 0, transition ) || vec_zero ), ang

	end

end )



local cam_1_lerp = 0
local cam_wait = 0
local cam_mode = 0

local function drawmat(x,y,w,h,mat)

  surface.SetDrawColor(color_white)
  surface.SetMaterial(mat)
  surface.DrawTexturedRect(x,y,w,h)

end

local cam_fov = 100
local my_cam_fov = cam_fov

local gradient = Material("vgui/gradient-r")
local gradient2 = Material("vgui/gradient-l")
local gradients = Material("gui/center_gradient")
local grad1 = Material("vgui/gradient-u")
local grad2 = Material("vgui/gradient-d")

function BREACH.OpenCameraMenu()
	if IsValid(BREACH.CAMERA_PANEL) then BREACH.CAMERA_PANEL:Remove() end
	if !LocalPlayer().br_camera_mode then return end
	if LocalPlayer():Health() <= 0 then return end
	BREACH.CAMERA_PANEL = vgui.Create("DPanel")
	BREACH.CAMERA_PANEL:SetSize(ScrW(), ScrH())
	BREACH.CAMERA_PANEL:MakePopup()
	BREACH.CAMERA_PANEL.Paint = function()
		draw.DrawText("[Legacy] NetLink V2", "ScoreboardHeader", 10, 10, nil, TEXT_ALIGN_LEFT)
		draw.DrawText("Видеовыход：Пиздатый", "ScoreboardHeader", 10, 70, nil, TEXT_ALIGN_LEFT)
		draw.DrawText("Аудиовыход：Нормальный", "ScoreboardHeader", 10, 110, nil, TEXT_ALIGN_LEFT)
		draw.DrawText("Маштаб: "..tostring(math.floor((100/cam_fov)*100)).."%", "ScoreboardHeader", 10, 110+40, nil, TEXT_ALIGN_LEFT)
	end
	local scrw, scrh = ScrW(), ScrH()
	BREACH.CAMERA_PANEL.Think = function(self)
	
		if !LocalPlayer().br_camera_mode or LocalPlayer():Health() <= 0 then
			self:Remove()
		end

	end

	local close = vgui.Create("DButton", BREACH.CAMERA_PANEL)

	close:SetSize(100,60)
	close:SetText("")

	close:SetPos(20,scrh-80)

	local col_bg = Color(0,0,0,100)

	close.DoClick = function()

		surface.PlaySound("nextoren/gui/camera/button_click.wav")
	
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 1, 1)
		LocalPlayer().br_camera_mode = false
		BREACH.CAMERA_PANEL:Remove()
		net.Start("camera_exit")
		net.SendToServer()

	end

	close.Paint = function(self, w, h)

		draw.RoundedBox(0, 0, 0, w, h, col_bg)

		DrawBlurPanel(self)

		drawmat(0,0,w,1,gradients)
		drawmat(0,h-1,w,1,gradients)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(1, h/2, 1, h/2)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(w-1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(w-1, h/2, 1, h/2)
		draw.DrawText("End", "ScoreboardHeader", w/2,h/2-17, nil, TEXT_ALIGN_CENTER)
  end

  local next = vgui.Create("DButton", BREACH.CAMERA_PANEL)

	next:SetSize(100,60)
	next:SetText("")

	next.DoClick = function()
		surface.PlaySound("nextoren/gui/camera/button_click.wav")
		net.Start("camera_swap")
		net.WriteBool(true)
		net.SendToServer()
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 1, 1)
	end

	next:SetPos(scrw/2,scrh-140)

	next.Paint = function(self, w, h)

		draw.RoundedBox(0, 0, 0, w, h, col_bg)

		DrawBlurPanel(self)

		drawmat(0,0,w,1,gradients)
		drawmat(0,h-1,w,1,gradients)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(1, h/2, 1, h/2)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(w-1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(w-1, h/2, 1, h/2)
		draw.DrawText("Next", "ScoreboardHeader", w/2,h/2-17, nil, TEXT_ALIGN_CENTER)
  end

  local prev = vgui.Create("DButton", BREACH.CAMERA_PANEL)

	prev:SetSize(100,60)
	prev:SetText("")

	prev:SetPos(scrw/2-100,scrh-140)

	prev.DoClick = function()
		surface.PlaySound("nextoren/gui/camera/button_click.wav")
		net.Start("camera_swap")
		net.WriteBool(false)
		net.SendToServer()
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 1, 1)
	end

	prev.Paint = function(self, w, h)

		draw.RoundedBox(0, 0, 0, w, h, col_bg)

		DrawBlurPanel(self)

		drawmat(0,0,w,1,gradients)
		drawmat(0,h-1,w,1,gradients)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(1, h/2, 1, h/2)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(w-1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(w-1, h/2, 1, h/2)
		draw.DrawText("Last", "ScoreboardHeader", w/2,h/2-17, nil, TEXT_ALIGN_CENTER)
  end

  local zoomin = vgui.Create("DButton", BREACH.CAMERA_PANEL)

	zoomin:SetSize(170,60)
	zoomin:SetText("")

	zoomin:SetPos(scrw/2,scrh-80)

	zoomin.Paint = function(self, w, h)

		draw.RoundedBox(0, 0, 0, w, h, col_bg)

		DrawBlurPanel(self)

		drawmat(0,0,w,1,gradients)
		drawmat(0,h-1,w,1,gradients)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(1, h/2, 1, h/2)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(w-1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(w-1, h/2, 1, h/2)
		draw.DrawText("+Fov", "ScoreboardHeader", w/2,h/2-17, nil, TEXT_ALIGN_CENTER)
  end

  zoomin.DoClick = function()
  	surface.PlaySound("nextoren/gui/camera/button_click.wav")
  	cam_fov = math.max(cam_fov - 10, 60)
  end

  local zoomout = vgui.Create("DButton", BREACH.CAMERA_PANEL)

	zoomout:SetSize(170,60)
	zoomout:SetText("")

	zoomout:SetPos(scrw/2-170,scrh-80)

	zoomout.DoClick = function()
		surface.PlaySound("nextoren/gui/camera/button_click.wav")
  	cam_fov = math.min(cam_fov + 10, 100)
  end

	zoomout.Paint = function(self, w, h)

		draw.RoundedBox(0, 0, 0, w, h, col_bg)

		DrawBlurPanel(self)

		drawmat(0,0,w,1,gradients)
		drawmat(0,h-1,w,1,gradients)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(1, h/2, 1, h/2)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(grad2)
		surface.DrawTexturedRect(w-1, 0, 1, h/2)
		surface.SetMaterial(grad1)
		surface.DrawTexturedRect(w-1, h/2, 1, h/2)
		draw.DrawText("-Fov", "ScoreboardHeader", w/2,h/2-17, nil, TEXT_ALIGN_CENTER)
  end

end

net.Receive("camera_enter", function(len)

	LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 1, 1)
	LocalPlayer().br_camera_mode = true
	BREACH.OpenCameraMenu()

end)

concommand.Add("enter_camera_mode", function()
	net.Start("camera_enter")
	net.SendToServer()
end)

function GM:CalcView( ply, origin, angles, fov )

	local data = {}
	data.origin = origin
	data.angles = angles
	data.fov = fov
	data.drawviewer = false

	if ply:GetInDimension() and ply:GTeam() != TEAM_SCP then
		data.angles = angles + Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),0)
		return data
	end
	if ply:GetTable()["br_camera_mode"] then
		my_cam_fov = math.Approach(my_cam_fov, cam_fov, FrameTime()*30)
		data.fov = my_cam_fov
		data.angles.p = data.angles.p + 20
		if cam_wait == 0 then
			if cam_mode == 1 then
				cam_1_lerp = math.Approach(cam_1_lerp, -30, FrameTime()*8)
				if cam_1_lerp == -30 then
					cam_wait = 2
					cam_mode = 0
				end
			else
				cam_1_lerp = math.Approach(cam_1_lerp, 30, FrameTime()*8)
				if cam_1_lerp == 30 then
					cam_wait = 2
					cam_mode = 1
				end
			end
		else
			cam_wait = math.Approach(cam_wait, 0, FrameTime())
		end
		data.angles.y = data.angles.y - cam_1_lerp
		return data
	end

	if ( !forbidden_teams[ ply:GTeam() ] && ply:Health() > 0 && ( ( !isnumber( vel ) && vel:Length2DSqr() > .25 ) || ply:GetVelocity():Length2DSqr() > .25 ) && ply:GetMoveType() != MOVETYPE_NOCLIP ) then

		local pos = Vector( 0, y, ( cos * plane ) * scale )
		pos:Rotate( EyeAngles() )

		data.origin.x = origin.x + pos.x
		data.origin.y = origin.y + pos.y
		data.origin.z = origin.z + pos.z

		data.angles.p = angles.p + ( math.abs( math.cos( SysTime() * step / 2 ) ) * ( MovementDot.x || 1 ) / 400 ) * scale
		data.angles.y = angles.y + ( y / 6.4 )
		data.angles.r = angles.r + ( y / 4 ) * scale

	end

	local wep = ply:GetActiveWeapon()

	if ( wep != NULL && wep.CalcView ) then

		local vec, ang, ifov = wep:CalcView( ply, origin, angles, fov )

		data.origin = vec
		data.angles = ang
		data.fov = ifov

	end

	if ( ply.RealLean != 0 && ply:IsSolid() ) then

		if ( !ply.RealLean ) then

			ply.RealLean = 0

			return
		end

		local lean = ply.RealLean

		data.angles:RotateAroundAxis( data.angles:Forward(), lean )
		data.origin = data.origin + data.angles:Right() * lean

	end

	if ( ply.FOVTest && ply.FOVTest > 0 ) then

		if ( ply.FOVStartDecrease ) then

			ply.FOVTest = math.Approach( ply.FOVTest, 0, RealFrameTime() * 10 )

		end

		data.fov = data.fov - ply.FOVTest

	end

	
	

	
	

	if ply:GTeam() == TEAM_SPEC then
		data.angles.r = 0
	end

	return data

end


local flag_color = Color(255, 255, 0)
local cibase = Vector(-3647.96484375, 2575.8522949219, 10.03125)
local ci_color = Color(29, 81, 56, 255)
local qrtbase = Vector(1728.6828613281, 4175.8920898438, 10.03125)
local qrt_color = Color(90, 90, 255, 255)

local shawms = shawms or {}

hook.Add("OnEntityCreated", "CTF_SoftEntityList", function(ent)
	if ent:GetClass() == "item_ctf_doc" then
		table.insert(shawms, ent)
	end
end)

hook.Add("EntityRemoved", "CTF_SoftEntityList", function(ent)
	if ent:GetClass() == "item_ctf_doc" then
		for k, v in pairs(shawms) do
			if !IsValid(v) then
				table.remove(shawms, k)
			end
		end
	end
end)

hook.Add("HUDPaint", "CTF_Paint", function()
	local client = LocalPlayer()

	for i=1, #shawms do
		local v = shawms[i]
		if IsValid(v) then
			local vpos = v:GetPos()
			local point = v:GetAngles():Up() * 7 + vpos 
			local vec = point:ToScreen()

			if vec.visible then
				
			end
		end
	end

	if GetGlobalString("RoundName") != "CTF" then return end

	if client:GTeam() == TEAM_CHAOS then
		local cibase_screen = cibase:ToScreen()

		if cibase_screen.visible then
			draw.SimpleText("CI", "BudgetLabel", cibase_screen.x, cibase_screen.y, ci_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end

	if client:GTeam() == TEAM_QRT then
		local qrtbase_screen = qrtbase:ToScreen()

		if qrtbase_screen.visible then
			draw.SimpleText("QRT", "BudgetLabel", qrtbase_screen.x, qrtbase_screen.y, qrt_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end)

net.Receive("Special_outline", function(len)

	local team = net.ReadUInt(16)
	if team == TEAM_CLASSD then team = TEAM_CHAOS end
	Show_Spy(team)

end)

local scarletmat = Material("nextoren/gui/roles_icon/ar.png")

hook.Add("PostDrawTranslucentRenderables", "support_trigger_ui", function(bDepth, bSkybox)
	if bSkybox then return end
    local client = LocalPlayer()
    if not client:GetNWBool('ChipedByAndersonRobotik', false) then return end
    if not client:HasWeapon("kasanov_ar_disk") then return end
	
   
    
    
    
    

    local capos = Vector(1591, 4105, 64)
    local ang = client:EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    capos = capos + Vector(0, -25, 5)
    
    local dist = client:GetPos():Distance(Vector(1591, 4105, 64))
    local size = 140 * math.Clamp(dist * .005, 1, 30)
    
    cam.Start3D2D(capos, ang, 0.1)
        cam.IgnoreZ(true)
        surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
        surface.SetMaterial(scarletmat)
        surface.DrawTexturedRect(-(size / 2), -(size / 2), size, size)
        cam.IgnoreZ(false)
    cam.End3D2D()
end)

local scarletmat2 = Material("nextoren/gui/roles_icon/a1.png")

hook.Add("PostDrawTranslucentRenderables", "alpha_spec_ai", function(bDepth, bSkybox)
    local client = LocalPlayer()
    if not client:GetNWBool('can_sea_gaus', false) then return end
    
	
   
    
    
    
    
	for k,v in pairs(GAUS_PART) do
    	local capos = v
    	local ang = client:EyeAngles()
    	ang:RotateAroundAxis(ang:Forward(), 90)
    	ang:RotateAroundAxis(ang:Right(), 90)
    	capos = capos + Vector(0, -25, 5)
		
    	local dist = client:GetPos():Distance(v)
    	local size = 140 * math.Clamp(dist * .005, 1, 30)
		
    	cam.Start3D2D(capos, ang, 0.1)
    	    cam.IgnoreZ(true)
    	    surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
    	    surface.SetMaterial(scarletmat2)
    	    surface.DrawTexturedRect(-(size / 2), -(size / 2), size, size)
    	    cam.IgnoreZ(false)
    	cam.End3D2D()
	end
end)
local mask_overlay = Material( "nextoren_hud/overlay/gasmaskdmxmd" )
hook.Add( "RenderScreenspaceEffects", "SCP1499_Mask_Overlay_2", function()
  local client = LocalPlayer()
  if ( client:GetRoleName() == "Spectator" ) or !client:IIHasWeapon("item_scp_1499") then
	if ( client.Gasmask_Breathing ) then
		client.Gasmask_Breathing:Stop()
		client.Gasmask_Breathing = nil
	end
    hook.Remove( "RenderScreenspaceEffects", "SCP1499_Mask_Overlay" )
    return
  end
  if client:IIHasWeapon("item_scp_1499") and ( client:GetPos().y < -13000 ) then
	
  	render.SetMaterial( mask_overlay )
  	render.DrawScreenQuad()
  end
end )

