local MenuTable = {}
MenuTable.start = "Play"
MenuTable.Leave = "Leave"
MenuTable.OurGroup = "Wiki"
MenuTable.FAQ = "Information"
MenuTable.Settings = "Settings"

MenuTable.Current_Build = "1.1.4"

local gifFrames = {}
for i = 1, 30 do
    gifFrames[i] = Material("nextoren/LeOrb/" .. i .. ".png")
end

local currentFrame = 1
local frameDelay = 0.1

timer.Create("GIFAnimation", frameDelay, 0, function()
    currentFrame = currentFrame + 1
    if currentFrame > #gifFrames then
        currentFrame = 1
    end
end)

local offset_height = 0





local dark_clr = Color(0,0,0,155)

local gray_clr = Color(27,27,27,255)

local gradient = Material("vgui/gradient-r")
local gradient2 = Material("vgui/gradient-l")
local gradients = Material("gui/center_gradient")
local grad1 = Material("vgui/gradient-u")
local grad2 = Material("vgui/gradient-d")
local backgroundlogo = Material("nextoren/menu")
local scp = Material("nextoren/gui/new_icons/notifications/breachiconfortips.png", "noclamp smooth")
local garland = Material("happy_new_year/happy_new_year.png", "noclamp smooth")
local donatelist = include(GM.FolderName .. "/gamemode/config/donatelist.lua")

local function drawmat(x,y,w,h,mat)

  surface.SetDrawColor(color_white)
  surface.SetMaterial(mat)
  surface.DrawTexturedRect(x,y,w,h)

end

local sin, cos, rad = math.sin, math.cos, math.rad
local rad0 = rad(0)


surface.CreateFont( "dev_desc", {
  font = "Univers LT Std 47 Cn Lt",
  size = 16,
  weight = 0,
  antialias = true,
  italic = false,
  extended = true,
  shadow = false,
  outline = false,
  
})

surface.CreateFont( "dev_name", {
  font = "Univers LT Std 47 Cn Lt",
  size = 21,
  weight = 0,
  antialias = true,
  extended = true,
  shadow = false,
  outline = false,
  
})

surface.CreateFont("MM_BigNameB", {
  font = "Hitmarker Normal",
  size = ScreenScale( 20 ),
	extended = true,
	
  weight = 700
})

surface.CreateFont("MM_BigName", {
  font = "Hitmarker Normal",
  size = ScreenScale( 14 ),
	extended = true,
	
  weight = 700
})

surface.CreateFont("MM_ESC", {
  font = "Hitmarker Normal",
  size = ScreenScale( 12 ),
	extended = true,
	
  weight = 700
})


surface.CreateFont("MM_RoleName", {
  font = "Hitmarker Normal",
  size = ScreenScale( 10 ),
	extended = true,
	
  weight = 700
})

surface.CreateFont("MM_SmallName", {
  font = "Hitmarker Normal",
  size = ScreenScale( 4 ),
	extended = true,
	
  weight = 700
})

surface.CreateFont("MM_SmallName2", {
  font = "Hitmarker Normal",
  size = ScreenScale( 4 ),
	extended = true,
	
  weight = 300
})
--char_title
surface.CreateFont("MM_Level", {
  font = "Hitmarker Normal",
  size = ScreenScale( 8 ),
	extended = true,
	
  weight = 300
})

surface.CreateFont("ZCity_Tiny", {
  font = "Hitmarker Normal",
  size = ScreenScale( 8 ),
	extended = true,
	
  weight = 300
})

surface.CreateFont("ZCity_SuperTiny", {
  font = "Hitmarker Normal",
  size = ScreenScale( 8 ),
	extended = true,
	
  weight = 300
})

--ZCity_SuperTiny

surface.CreateFont("MM_Exp", {
  font = "Hitmarker Normal",
  size = ScreenScale( 5 ),
	extended = true,
	
  weight = 300
})

local PATCHIE = include(GM.FolderName .. "/gamemode/config/changelogs.lua")

function draw.RotatedText( text, x, y, font, color, ang )
  render.PushFilterMag( TEXFILTER.ANISOTROPIC )
  render.PushFilterMin( TEXFILTER.ANISOTROPIC )

  local m = Matrix()
  m:Translate( Vector( x, y, 0 ) )
  m:Rotate( Angle( 0, ang, 0 ) )

  surface.SetFont( font )
  local w, h = surface.GetTextSize( text )

  m:Translate( -Vector( w / 2, h / 2, 0 ) )

  cam.PushModelMatrix( m )
    draw.DrawText( text, font, 0, 0, color )
  cam.PopModelMatrix()

  render.PopFilterMag()
  render.PopFilterMin()
end

function createdonationmenu()

  if IsValid(MAIN_MENU_DERMA_DONATE) then MAIN_MENU_DERMA_DONATE:Remove() end

  if IsValid(INTRO_PANEL.donate) then
    INTRO_PANEL.donate:AlphaTo(0, 1, 0, function() INTRO_PANEL.donate:Remove() INTRO_PANEL.donate = nil end)
    return
  end

  local creditspanel = vgui.Create("DScrollPanel", INTRO_PANEL)
  local sbar = creditspanel:GetVBar()
  function sbar:Paint(w, h)
  end
  function sbar.btnUp:Paint(w, h)
  end
  function sbar.btnDown:Paint(w, h)
  end
  function sbar.btnGrip:Paint(w, h)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, w-3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, w-3, h/2)
  end
  INTRO_PANEL.donate = creditspanel
  INTRO_PANEL.donate:SetAlpha(0)
  INTRO_PANEL.donate:SetSize(400,400)
  INTRO_PANEL.donate:Center()
  INTRO_PANEL.donate:AlphaTo(255, 1)
  INTRO_PANEL.donate.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,dark_clr)
    DrawBlurPanel(INTRO_PANEL.donate)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, 3, h/2)
    surface.DrawTexturedRect(w-3, 0, 3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, 3, h/2)
    surface.DrawTexturedRect(w-3, h/2, 3, h/2)
    INTRO_PANEL.donate:MakePopup()
  end

  for i = 1, #donation_list do
    local data = donation_list[i]
    local label = vgui.Create("DLabel", creditspanel)
    label:Dock(TOP)
    label:SetSize(0,20)
    label:SetFont("ChatFont_new")
    label:SetText("  "..data.category)
  end

end



local button_lang = {
  play = "l:menu_play",

  resume = "l:menu_resume",

  disconnect = "l:menu_disconnect",

  credits = "l:menu_credits",

  kill = "l:suiside",

  settings = "l:menu_settings",

  guide = "l:menu_guide",

  discord = "l:discord",

  xmas = "l:xmas",

  donate = "l:menu_donate",

  ach = "l:scoreboard_achievements",

  wiki = "l:menu_wiki",

  rules = "l:menu_my_life_my_rules",
  
  roles = "l:menu_roles",
}


surface.CreateFont("MainMenuFont", {

  font = "Hitmarker Normal",
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

surface.CreateFont("MainMenuFontmini", {

  font = "Hitmarker Normal",
  size = 26,
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

BREACH = BREACH || {}

ShowMainMenu = ShowMainMenu || false
local clr1 = Color( 128, 128, 128 )
local whitealpha = Color( 255, 255, 255, 90 )
local clrblackalpha = Color( 0, 0, 0, 220 )

local Material_To_Check = {

  "nextoren_hud/overlay/frost_texture",
  "weapons/weapon_flashlight",
  "cultist/door_1",
  "models/balaclavas/balaclava",
  "models/cultist/heads/zombie_face",
  "models/all_scp_models/shared/arms_new",
  "nextoren/gui/special_abilities/special_fbi_commander.png",
  "models/breach_items/ammo_box/ammocrate_smg1"

}


local rust_panel    = Color(18, 16, 15, 245)
local rust_row      = Color(40, 38, 35, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_green    = Color(112, 126, 73)
local rust_red      = Color(188, 64, 43)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)


local function CreateQueryButton(parent, text, x, y, w, h, isPrimary, isSingle, onClick)
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x, y)
    btn:SetSize(w, h)
    btn:SetText("")
    btn.hoverLerp = 0
    
    local safe_text = tostring(text or "КНОПКА")

    local rust_row     = Color(40, 38, 35, 255)
    local rust_yellow  = Color(218, 165, 32)
    local rust_green   = Color(112, 126, 73)
    local rust_red     = Color(188, 64, 43)
    local rust_outline = Color(255, 255, 255, 10)
    local rust_text    = Color(230, 230, 230)

    btn.Paint = function(self, bw, bh)
        self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)

        surface.SetDrawColor(rust_row)
        surface.DrawRect(0, 0, bw, bh)

        if self.hoverLerp > 0 then
            local hoverColor = isSingle and rust_yellow or (isPrimary and rust_green or rust_red)
            surface.SetDrawColor(hoverColor.r, hoverColor.g, hoverColor.b, 255 * self.hoverLerp)
            surface.DrawRect(0, 0, bw, bh)
        end

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, bw, bh, 1)

        local txtColor = (self.hoverLerp > 0.5 and isSingle) and Color(15, 15, 15) or rust_text
        local textY_offset = math.Round(6 * (ScrH() / 1080))
        
        draw.DrawText(safe_text, "MM_Exp", bw/2, bh/2 - textY_offset, txtColor, TEXT_ALIGN_CENTER)
    end

    btn.DoClick = function()
        surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
        if onClick then onClick() end
    end
    btn.OnCursorEntered = function() surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end

    return btn
end


local function CreateMainMenuQueryWithHover(text, str1, hoverstr1, func1, str2, hoverstr2, func2)
    local scrw, scrh = ScrW(), ScrH()
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end
    
    MAIN_MENU_DERMA_QUERY = vgui.Create("EditablePanel")
    MAIN_MENU_DERMA_QUERY:SetSize(scrw, scrh)
    MAIN_MENU_DERMA_QUERY:SetPos(0, 0)
    MAIN_MENU_DERMA_QUERY:MakePopup()
    MAIN_MENU_DERMA_QUERY:DoModal() 

    local safe_text = tostring(text or "ВНИМАНИЕ")
    MAIN_MENU_DERMA_QUERY.StartTime = SysTime()

    MAIN_MENU_DERMA_QUERY.Paint = function(self, w, h)
        local alpha = math.Clamp((SysTime() - self.StartTime) * 4, 0, 1) * 200
        surface.SetDrawColor(0, 0, 0, alpha)
        surface.DrawRect(0, 0, w, h)
    end

    local prompt = vgui.Create("DPanel", MAIN_MENU_DERMA_QUERY)
    prompt:SetSize(sw(450), sh(130))
    prompt:Center()

    prompt.Paint = function(self, w, h)
        surface.SetDrawColor(18, 16, 15, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(218, 165, 32, 255)
        surface.DrawRect(0, 0, w, sh(2))
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.DrawText(safe_text, "MM_Level", w/2, sh(35), color_white, TEXT_ALIGN_CENTER)
    end

    local btn1, btn2

    if not str2 then
        btn1 = CreateQueryButton(prompt, str1, sw(25), sh(80), sw(400), sh(30), true, true, function()
            if func1 then func1() end
            if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end
        end)
    else
        btn1 = CreateQueryButton(prompt, str1, sw(25), sh(80), sw(190), sh(30), true, false, function()
            if func1 then func1() end
            if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end
        end)
        btn2 = CreateQueryButton(prompt, str2, sw(235), sh(80), sw(190), sh(30), false, false, function()
            if func2 then func2() end
            if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end
        end)
    end

    local hovertextlabel = vgui.Create("DPanel", MAIN_MENU_DERMA_QUERY)
    hovertextlabel:SetSize(scrw, scrh)
    hovertextlabel:SetPos(0, 0)
    hovertextlabel:SetMouseInputEnabled(false) 
    
    local safe_hstr1 = tostring(hoverstr1 or "")
    local safe_hstr2 = tostring(hoverstr2 or "")

    hovertextlabel.Paint = function(self, w, h)
        if not IsValid(prompt) then return end

        local cx, cy = input.GetCursorPos()
        local drawStr = nil

        if IsValid(btn1) and btn1:IsHovered() and safe_hstr1 ~= "" then
            drawStr = safe_hstr1
        elseif IsValid(btn2) and btn2:IsHovered() and safe_hstr2 ~= "" then
            drawStr = safe_hstr2
        end

        if drawStr then
            surface.SetFont("MM_Exp")
            local tw, th = surface.GetTextSize(drawStr)
            local padX, padY = sw(12), sh(8)
            
            local bx = cx + sw(15)
            local by = cy + sh(15)
            
            if bx + tw + padX*2 > w then bx = cx - tw - padX*2 - sw(5) end
            if by + th + padY*2 > h then by = cy - th - padY*2 - sh(5) end

            surface.SetDrawColor(10, 9, 8, 250)
            surface.DrawRect(bx, by, tw + padX*2, th + padY*2)
            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawOutlinedRect(bx, by, tw + padX*2, th + padY*2, 1)
            draw.DrawText(drawStr, "MM_Exp", bx + padX, by + padY - sh(1), Color(230, 230, 230), TEXT_ALIGN_LEFT)
        end
    end
end

local function OpenExitConfirmation()
    if IsValid(INTRO_PANEL.ExitPromptOverlay) then return end

    local scrw, scrh = ScrW(), ScrH()
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    surface.PlaySound("nextoren/gui/main_menu/button_click.wav")

    local overlay = vgui.Create("EditablePanel")
    overlay:SetSize(scrw, scrh)
    overlay:SetPos(0, 0)
    overlay:SetZPos(32767) 
    overlay:MakePopup()
    overlay:DoModal() 
    INTRO_PANEL.ExitPromptOverlay = overlay

    overlay.StartTime = SysTime()

    overlay.Paint = function(self, w, h)
        local alpha = math.Clamp((SysTime() - self.StartTime) * 4, 0, 1) * 200
        DrawBlurPanel(self, 3, 3)
        surface.SetDrawColor(0, 0, 0, alpha)
        surface.DrawRect(0, 0, w, h)
    end

    local prompt = vgui.Create("DPanel", overlay)
    prompt:SetSize(sw(450), sh(130))
    prompt:Center()
    
    prompt.Paint = function(self, w, h)
        surface.SetDrawColor(18, 16, 15, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(218, 165, 32, 255)
        surface.DrawRect(0, 0, w, sh(2))
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.DrawText(L("l:nav_exit_confirm_title"), "MM_Level", w/2, sh(25), color_white, TEXT_ALIGN_CENTER)
        draw.DrawText(L("l:nav_exit_confirm_desc"), "MM_Exp", w/2, sh(48), Color(140, 140, 140), TEXT_ALIGN_CENTER)
    end

    CreateQueryButton(prompt, L("l:nav_exit_cancel"), sw(25), sh(80), sw(190), sh(30), true, false, function()
        if IsValid(overlay) then overlay:Remove() end
    end)

    CreateQueryButton(prompt, L("l:nav_exit_disconnect"), sw(235), sh(80), sw(190), sh(30), false, false, function()
        LocalPlayer():ConCommand("disconnect")
    end)
end

function GM:DrawDeathNotice( x,  y ) end

function StartIntro()
    local w, h = ScrW(), ScrH()
    
    local plyName = string.upper(LocalPlayer():GetName())
    local roundstring = ""
    
    if gamestarted then
        roundstring = L("l:startintro_round_will_begin") .. " " .. string.ToMinutesSeconds(cltime)
    else
        roundstring = L("l:startintro_no_round")
    end
    roundstring = string.upper(roundstring)

    local intropanel = vgui.Create("DPanel")
    intropanel:SetSize(w, h)
    intropanel:SetPos(0, 0)
    intropanel:SetZPos(32767)
    intropanel:SetMouseInputEnabled(false)
    intropanel:SetKeyboardInputEnabled(false)

    local StartTime = SysTime()

    local line_color = Color(218, 165, 32, 255)
    local text_color = Color(230, 230, 230, 255)
    local dim_color  = Color(140, 140, 140, 255)


    intropanel.Paint = function(self, pw, ph)
        local t = SysTime() - StartTime
        local cy = ph / 2

        local anim_line = 0
        local anim_text = 0

        if t < 0.6 then
            anim_line = math.ease.OutExpo(t / 0.6)
        elseif t < 1.4 then
            anim_line = 1
            anim_text = math.ease.OutExpo((t - 0.6) / 0.8)
        elseif t < 5.0 then
            anim_line = 1
            anim_text = 1
        elseif t < 5.6 then
            anim_line = 1
            anim_text = 1 - math.ease.InOutExpo((t - 5.0) / 0.6)
        elseif t < 6.2 then
            anim_line = 1 - math.ease.InOutExpo((t - 5.6) / 0.6)
            anim_text = 0
        else
            self:Remove()
            return
        end

        local maxLineWidth = pw * 0.55
        local currentLineWidth = maxLineWidth * anim_line
        local lx = (pw - currentLineWidth) / 2

        line_color.a = 255 * (anim_line > 0.1 and 1 or anim_line * 10)
        surface.SetDrawColor(line_color)
        surface.DrawRect(lx, cy - 1, currentLineWidth, 2)

        if anim_text <= 0 then return end

        text_color.a = 255 * anim_text
        dim_color.a  = 255 * anim_text
        line_color.a = 255 * anim_text

        local topTextY = cy + 50 - (60 * anim_text)

        render.SetScissorRect(0, 0, pw, cy - 1, true)
            draw.SimpleText("ZCITY BREACH", "MM_BigNameB", pw / 2, topTextY, line_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        render.SetScissorRect(0, 0, 0, 0, false)


        local botTextY = cy - 50 + (60 * anim_text)

        render.SetScissorRect(0, cy + 1, pw, ph, true)
        --tostring( L"l:startintro_welcome_pt1 " .. LocalPlayer():GetName() .. "!\n " .. L(roundstring) .. L" l:startintro_welcome_pt2" )
            draw.SimpleText(tostring( L"l:startintro_welcome_pt1 " .. LocalPlayer():GetName() .. "!\n " .. L(roundstring) .. L" l:startintro_welcome_pt2" ), "MM_Exp", pw / 3, botTextY, text_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            --draw.SimpleText(tostring(L(roundstring) .. L" l:startintro_welcome_pt2" )), "MM_Exp", pw / 2, botTextY + 25, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            --draw.SimpleText("СТАТУС: " .. roundstring, "MM_Exp", pw / 2, botTextY, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

function music_menu()
  surface.PlaySound( "nextoren/unity/scpu_menu_theme_v3.01.ogg" )
end
concommand.Add( "music_menu", music_menu )

function Fluctuate(c) 
  return (math.cos(CurTime()*c)+1)/2
end

function Pulsate(c) 
  return (math.abs(math.sin(CurTime()*c)))
end

weareprecaching = weareprecaching or false
if FIRSTTIME_MENU == nil then FIRSTTIME_MENU = true end

local credits = {
  "----------------------------------------------------------",
  "| Cultist_kun - Creator of 1.0, inspired to make this server",
  "| Ghelid - Creator of 1.0, inspired to make this server",
  "----------------------------------------------------------",
  "| You - thanks for playing on the server!",
  "----------------------------------------------------------",
}

local credits2 = {
  "----------------------------------------------------------",
  "| Покупка доната происходит в нашем дискорде",
  "----------------------------------------------------------",
  "| Покупка не моментальна однако в случае долгого ожидания!",
  "| Возможны компенсации в ввиде увеличеного товара!",
  "----------------------------------------------------------",
}

local rust_dark       = Color(28, 26, 24, 245)  
local rust_darker     = Color(18, 16, 15, 250)  
local rust_red        = Color(188, 64, 43)      
local rust_red_hover  = Color(210, 80, 50)      
local rust_yellow     = Color(218, 165, 32)     
local rust_green      = Color(112, 126, 73)     
local rust_text       = Color(230, 230, 230)    
local rust_text_dim   = Color(150, 150, 150)    
local rust_outline    = Color(255, 255, 255, 15)

function OpenXmasMenu()

  if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end

  if IsValid(INTRO_PANEL.credits) then
    INTRO_PANEL.credits:AlphaTo(0, 1, 0, function() INTRO_PANEL.credits:Remove() INTRO_PANEL.credits = nil end)
    return
  end

  local creditspanel = vgui.Create("DScrollPanel", INTRO_PANEL)
  local sbar = creditspanel:GetVBar()
  function sbar:Paint(w, h)
  end
  function sbar.btnUp:Paint(w, h)
  end
  function sbar.btnDown:Paint(w, h)
  end
  function sbar.btnGrip:Paint(w, h)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, w-3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, w-3, h/2)
  end
  INTRO_PANEL.credits = creditspanel
  INTRO_PANEL.credits:SetAlpha(0)
  INTRO_PANEL.credits:SetSize(550,800)
  INTRO_PANEL.credits:Center()
  INTRO_PANEL.credits:AlphaTo(255, 1)
  INTRO_PANEL.credits.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,dark_clr)
    DrawBlurPanel(INTRO_PANEL.credits)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, 3, h/2)
    surface.DrawTexturedRect(w-3, 0, 3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, 3, h/2)
    surface.DrawTexturedRect(w-3, h/2, 3, h/2)
    
    draw.DrawText("НОВОГОДНИЙ ИВЕНТ", "ImpactSmall", w/2, h/64, _, TEXT_ALIGN_CENTER)
    
    
    
    
    
    

    
    
    
    
    
  end

  
  
  local label = vgui.Create("DLabel", creditspanel)
  label:Dock(TOP)
  label:SetSize(0,300)
  label:SetFont("ChatFont_new")
  label:SetText("  ")
  label.Paint = function(self, w, h)
    draw.DrawText("Искатель конфет", "ImpactSmall", w/64, h/8, _, TEXT_ALIGN_LEFT)
    draw.DrawText("По комплексу раскиданы конфеты ты должен их найти и собрать", "ImpactSmall2", w/64, h/4.5, _, TEXT_ALIGN_LEFT)
    if tonumber(LocalPlayer():GetNWInt("event_xmas_candy")) >= 150 then
      draw.DrawText("✔ - "..LocalPlayer():GetNWInt("event_xmas_candy").." / 150", "ImpactSmall", w/1.05, h/8, Color(136,255,112), TEXT_ALIGN_RIGHT)
    else
      draw.DrawText(LocalPlayer():GetNWInt("event_xmas_candy").." / 150", "ImpactSmall", w/1.05, h/8, Color(253,122,122), TEXT_ALIGN_RIGHT)
    end
    surface.SetDrawColor(color_white)
    surface.SetMaterial(Material("nextoren/gui/event_xmas_candy.jpg"))
    surface.DrawTexturedRect(w/8, h/3.5, 400, 200)
  end

  local label = vgui.Create("DLabel", creditspanel)
  label:Dock(TOP)
  label:SetSize(0,300)
  label:SetFont("ChatFont_new")
  label:SetText("  ")
  label.Paint = function(self, w, h)
    draw.DrawText("Спаситель нового года", "ImpactSmall", w/64, h/8, _, TEXT_ALIGN_LEFT)
    draw.DrawText("Примите участиве в спец. раунде выживите и убейте зло!", "ImpactSmall2", w/64, h/4.5, _, TEXT_ALIGN_LEFT)
    if tonumber(LocalPlayer():GetNWInt("event_xmas_tvar")) >= 1 then
      draw.DrawText("✔ - "..LocalPlayer():GetNWInt("event_xmas_tvar").." / 1", "ImpactSmall", w/1.05, h/8, Color(136,255,112), TEXT_ALIGN_RIGHT)
    else
      draw.DrawText(LocalPlayer():GetNWInt("event_xmas_tvar").." / 1", "ImpactSmall", w/1.05, h/8, Color(253,122,122), TEXT_ALIGN_RIGHT)
    end
    surface.SetDrawColor(color_white)
    surface.SetMaterial(Material("nextoren/gui/event_xmas_snowman.jpg"))
    surface.DrawTexturedRect(w/8, h/3.5, 400, 200)
  end

  local label = vgui.Create("DLabel", creditspanel)
  label:Dock(TOP)
  label:SetSize(0,300)
  label:SetFont("ChatFont_new")
  label:SetText("  ")
  label.Paint = function(self, w, h)
    draw.DrawText("Новогодний марафон", "ImpactSmall", w/64, h/8, _, TEXT_ALIGN_LEFT)
    draw.DrawText("Соберите подарок под елкой 3 дня подряд", "ImpactSmall2", w/64, h/4.5, _, TEXT_ALIGN_LEFT)
    if tonumber(LocalPlayer():GetNWInt("event_xmas_gift")) >= 3 then
      draw.DrawText("✔ - "..LocalPlayer():GetNWInt("event_xmas_gift").." / 1", "ImpactSmall", w/1.05, h/8, Color(136,255,112), TEXT_ALIGN_RIGHT)
    else
      draw.DrawText(LocalPlayer():GetNWInt("event_xmas_gift").." / 3", "ImpactSmall", w/1.05, h/8, Color(253,122,122), TEXT_ALIGN_RIGHT)
    end
    surface.SetDrawColor(color_white)
    surface.SetMaterial(Material("nextoren/gui/event_xmas_gift.jpg"))
    surface.DrawTexturedRect(w/8, h/3.5, 400, 200)
  end

  local label2 = vgui.Create("DLabel", creditspanel)
  label2:Dock(TOP)
  label2:SetSize(0,200)
  label2:SetFont("ChatFont_new")
  label2:SetText("  ")
  label2.Paint = function(self, w, h)
    draw.DrawText("Награда за работу", "ImpactSmall", w/2, h/8, _, TEXT_ALIGN_CENTER)
    draw.DrawText("- 30 дней према", "ImpactSmall", w/64, h/4.5, Color(226,103,103), TEXT_ALIGN_LEFT)
    draw.DrawText("- Новогодние перчатки", "ImpactSmall", w/64, h/3.1, Color(226,103,103), TEXT_ALIGN_LEFT)
    
    
    
    
    
    
    
    
  end

  local finalbutton = vgui.Create("DButton", creditspanel)
  finalbutton:SetText("")
  finalbutton:SetSize(0, 100)
  finalbutton:Dock(TOP)
  

  finalbutton.animPress = 0
  finalbutton.animHover = 0
  finalbutton.animHoverPress = 0

  local btnHover = false
  finalbutton.Paint = function(self, w, h)
  	local hoverPressScale = 1 - self.animHoverPress * 0.03
  	local pressScale = 1 - self.animPress * 0.05
  	local totalScale = hoverPressScale * pressScale
  
  	local scaledW = w * totalScale
  	local scaledH = h * totalScale
  	local offsetX = (w - scaledW) / 2
  	local offsetY = (h - scaledH) / 2
  
  	local colorLerp = self.animHover
  	local r = Lerp(colorLerp, 255, 255)
  	local g = Lerp(colorLerp, 255, 50)
  	local b = Lerp(colorLerp, 255, 50)

  	if timer.Exists("NewTG_SpanwTimer") then
  		r = Lerp(colorLerp, 255, 255)
  		g = Lerp(colorLerp, 255, 0)
  		b = Lerp(colorLerp, 255, 0)
  	end
  

  	draw.RoundedBox(6, offsetX, offsetY, scaledW, scaledH, Color(70, 70, 70, 200))
  
  	local textColor = Color(r, g, b, 255)
  	if timer.Exists("NewTG_SpanwTimer") then
  		draw.SimpleText(string.ToMinutesSeconds(timer.TimeLeft("NewTG_SpanwTimer")), "ImpactBig2", w * 0.5, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  	else
  		draw.SimpleText("Проверить", "ImpactBig2", w * 0.5, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  	end
  
  	surface.SetDrawColor(r, g, b, 50)
  	surface.DrawOutlinedRect(offsetX, offsetY, scaledW, scaledH, 2)
  end

  finalbutton.OnCursorEntered = function(self)
  	btnHover = true
  	self:LerpAnim("animHover", 1, 0.2)
  	self:LerpAnim("animHoverPress", 1, 0.15)
  end

  finalbutton.OnCursorExited = function(self)
  	btnHover = false
  	self:LerpAnim("animHover", 0, 0.2)
  	self:LerpAnim("animHoverPress", 0, 0.15)
  end

  function finalbutton:LerpAnim(animName, target, time)
  	if self[animName] == target then return end
  
  	local start = self[animName] or 0
  	local anim = self:NewAnimation(time, 0, -1, function()
  		self[animName] = target
  	end)
  
  	anim.Think = function(anim, panel, fraction)
  		self[animName] = Lerp(fraction, start, target)
  	end
  end

  function finalbutton:DoClickAnim()
  	self.animPress = 1
  	self:LerpAnim("animPress", 0, 0.3)
  end

  function finalbutton:DoClick()
  	self:DoClickAnim()

    if ( !FIRSTTIME_MENU ) then
      surface.PlaySound( "nextoren/gui/main_menu/confirm.wav" )
      INTRO_PANEL:SetVisible( false )
      if COLOR_PANEL_SETTINGS then COLOR_PANEL_SETTINGS:Remove() end
      if INTRO_PANEL.settings_frame then INTRO_PANEL.settings_frame:Remove() end
      if INTRO_PANEL.credits then INTRO_PANEL.credits:Remove() end
      if IsValid(choices_panel_settings) then choices_panel_settings:Remove() end
      gui.EnableScreenClicker( false )
      if mainmenumusic then
        mainmenumusic:Stop()
      end
      ShowMainMenu = false
    end

    net.Start("Breach:XMASCHECK")
    net.SendToServer()
  end

end

function OpenCreditsMenu()

  if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end

  if IsValid(INTRO_PANEL.credits) then
    INTRO_PANEL.credits:AlphaTo(0, 1, 0, function() INTRO_PANEL.credits:Remove() INTRO_PANEL.credits = nil end)
    return
  end

  local creditspanel = vgui.Create("DScrollPanel", INTRO_PANEL)
  local sbar = creditspanel:GetVBar()
  function sbar:Paint(w, h)
  end
  function sbar.btnUp:Paint(w, h)
  end
  function sbar.btnDown:Paint(w, h)
  end
  function sbar.btnGrip:Paint(w, h)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, w-3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, w-3, h/2)
  end
  INTRO_PANEL.credits = creditspanel
  INTRO_PANEL.credits:SetAlpha(0)
  INTRO_PANEL.credits:SetSize(400,400)
  INTRO_PANEL.credits:Center()
  INTRO_PANEL.credits:AlphaTo(255, 1)
  INTRO_PANEL.credits.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,dark_clr)
    DrawBlurPanel(INTRO_PANEL.credits)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, 3, h/2)
    surface.DrawTexturedRect(w-3, 0, 3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, 3, h/2)
    surface.DrawTexturedRect(w-3, h/2, 3, h/2)
    INTRO_PANEL.credits:MakePopup()
  end

  for i = 1, #credits do
    local text = credits[i]
    local label = vgui.Create("DLabel", creditspanel)
    label:Dock(TOP)
    label:SetSize(0,20)
    label:SetFont("ChatFont_new")
    label:SetText("  "..text)
  end

end

function OpenCreditsMenu2()

  if IsValid(MAIN_MENU_DERMA_QUERY) then MAIN_MENU_DERMA_QUERY:Remove() end

  if IsValid(INTRO_PANEL.credits) then
    INTRO_PANEL.credits:AlphaTo(0, 1, 0, function() INTRO_PANEL.credits:Remove() INTRO_PANEL.credits = nil end)
    return
  end

  local creditspanel = vgui.Create("DScrollPanel", INTRO_PANEL)
  local sbar = creditspanel:GetVBar()
  function sbar:Paint(w, h)
  end
  function sbar.btnUp:Paint(w, h)
  end
  function sbar.btnDown:Paint(w, h)
  end
  function sbar.btnGrip:Paint(w, h)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, w-3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, w-3, h/2)
  end
  INTRO_PANEL.credits = creditspanel
  INTRO_PANEL.credits:SetAlpha(0)
  INTRO_PANEL.credits:SetSize(400,400)
  INTRO_PANEL.credits:Center()
  INTRO_PANEL.credits:AlphaTo(255, 1)
  INTRO_PANEL.credits.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,dark_clr)
    DrawBlurPanel(INTRO_PANEL.credits)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(0, 0, 3, h/2)
    surface.DrawTexturedRect(w-3, 0, 3, h/2)
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(0, h/2, 3, h/2)
    surface.DrawTexturedRect(w-3, h/2, 3, h/2)
    INTRO_PANEL.credits:MakePopup()
  end

  for i = 1, #credits2 do
    local text = credits2[i]
    local label = vgui.Create("DLabel", creditspanel)
    label:Dock(TOP)
    label:SetSize(0,20)
    label:SetFont("ChatFont_new")
    label:SetText("  "..text)
  end

end

local function firsttimeshit(precache)
  RunConsoleCommand("stopsound")

  local __mainmenuspawn_dist = math.huge
  local __mainmenuspawn_found = BREACH.MainMenu_Spawns[1][2]

  for i, v in pairs(BREACH.MainMenu_Spawns) do
    local _d = LocalPlayer():GetPos():DistToSqr(v[1])
    if __mainmenuspawn_dist > _d then
      __mainmenuspawn_found = v[2]
      __mainmenuspawn_dist = _d
    end
  end

  LocalPlayer():SetEyeAngles(__mainmenuspawn_found)

  
  local loadingscreen = vgui.Create("DPanel") 
  loadingscreen:SetSize(ScrW(), ScrH())
  loadingscreen:SetDrawOnTop(true) 
  loadingscreen:MakePopup()
  
  loadingscreen.Paint = function(self, w, h)
      surface.SetDrawColor(0, 0, 0, 255)
      surface.DrawRect(0, 0, w, h)
      
      
      if precache then
          surface.SetDrawColor(255, 255, 255)
          surface.SetMaterial(Material("nextoren/gui/dev_loading.png"))
          surface.DrawTexturedRect(0, 0, w, h)
          draw.DrawText("ПРОГРУЖАЕМ...", "MM_BigNameB", w/128, h/1.08, color_white, TEXT_ALIGN_LEFT)
          draw.DrawText("ПОЖАЛУЙСТА ПОДОЖДИТЕ, ИГРА МОЖЕТ ЗАВИСНУТЬ НА ПАРУ СЕКУНД.", "MM_Exp", w/128, h/1.02, Color(140, 140, 140), TEXT_ALIGN_LEFT)
      end
  end

  
  loadingscreen:AlphaTo(0, 2, 1, function()
    if IsValid(loadingscreen) then loadingscreen:Remove() end
  end)

  net.Start("Player_FullyLoadMenu", true)
  net.SendToServer()

  timer.Create("Player_FullyLoadMenu", 1, 0, function()
    if LocalPlayer():GetNWBool("Player_IsPlaying", false) then
      timer.Remove("Player_FullyLoadMenu")
      return
    end
    net.Start("Player_FullyLoadMenu")
    net.SendToServer()
  end)

  if precache then
    weareprecaching = true
  end

  
  timer.Simple(0.1, function()

    if precache then
      PrecachePlayerSounds()
      weareprecaching = false
    end

    FIRSTTIME_MENU = false
    surface.PlaySound( "nextoren/gui/main_menu/confirm.wav" )

    if ( mainmenumusic ) then
      mainmenumusic:Stop()
    end

    INTRO_PANEL:SetVisible( false )
    if COLOR_PANEL_SETTINGS then COLOR_PANEL_SETTINGS:Remove() end
    if INTRO_PANEL.settings_frame then INTRO_PANEL.settings_frame:Remove() end
    if INTRO_PANEL.credits then INTRO_PANEL.credits:Remove() end
    if IsValid(choices_panel_settings) then choices_panel_settings:Remove() end
    gui.EnableScreenClicker( false )
    
    ShowMainMenu = false

    MenuTable.start = L"l:menu_resume"

    local ply = LocalPlayer()
    ply:CompleteAchievement("firsttime")
    --surface.PlaySound( "nextoren/unity/scpu_objective_completed_v1.01.ogg" )
    surface.PlaySound( "utopia/load/new_load_"..math.random(1,4)..".wav" )

    ply:ConCommand("r_decals 4096")
    ply:ConCommand("gmod_mcore_test", "1")
    ply:ConCommand("mat_queue_mode", "2")
    ply:ConCommand("cl_threaded_bone_setup", "1")
    ply:ConCommand("cl_threaded_client_leaf_system", "1")
    ply:ConCommand("r_threaded_client_shadow_manager", "1")
    ply:ConCommand("r_threaded_particles", "1")
    ply:ConCommand("r_threaded_renderables", "1")
    ply:ConCommand("r_queued_ropes", "1")
    ply:ConCommand("studio_queue_mode", "1")
    ply:ConCommand("r_queued_props", "1")
    ply:ConCommand("r_occludermincount", "1")
    timer.Simple(0.5, function()
        StartIntro()
    end)


    ply:ConCommand( "lounge_chat_clear" )
  end)
end

local current_update_likes = 0
local current_update_dislikes = 0
local current_update_voted = false

net.Receive("Breach_SendUpdateRating", function()
    current_update_likes = net.ReadInt(32)
    current_update_dislikes = net.ReadInt(32)
    current_update_voted = net.ReadBool()
end)

function StartBreach( firsttime )

  local scrw, scrh = ScrW(), ScrH()
  
  local function sw(val) return math.Round(val * (scrw / 1920)) end
  local function sh(val) return math.Round(val * (scrh / 1080)) end

  INTRO_PANEL = vgui.Create( "DPanel" )
  INTRO_PANEL:SetSize( scrw, scrh )
  INTRO_PANEL:SetPos( 0, 0 )
  INTRO_PANEL.OpenTime = RealTime()

  INTRO_PANEL.Paint = function(self, w, h)
    if not FIRSTTIME_MENU then
        DrawBlurPanel(self, 3, 3)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80))
    else
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
    end
    
    if (input.IsKeyDown(KEY_ESCAPE) && INTRO_PANEL.OpenTime < RealTime() - .2 && !FIRSTTIME_MENU) then
        ShowMainMenu = CurTime() + .1
        gui.HideGameUI()
        INTRO_PANEL:SetVisible(false)
        gui.EnableScreenClicker(false)
        if mainmenumusic then mainmenumusic:Stop() end
    end
  end

  local function closeMainMenu()
      if (!FIRSTTIME_MENU) then
          surface.PlaySound("nextoren/gui/main_menu/confirm.wav")
          INTRO_PANEL:SetVisible(false)
          if COLOR_PANEL_SETTINGS then COLOR_PANEL_SETTINGS:Remove() end
          if INTRO_PANEL.settings_frame then INTRO_PANEL.settings_frame:Remove() end
          if INTRO_PANEL.credits then INTRO_PANEL.credits:Remove() end
          if IsValid(choices_panel_settings) then choices_panel_settings:Remove() end
          gui.EnableScreenClicker(false)
          if mainmenumusic then mainmenumusic:Stop() end
          ShowMainMenu = false
      end
  end

  local tabHome = L("l:nav_home")
  local tabPlay = L("l:nav_play")
  local tabJoin = L("l:nav_join")
  local tabRoles = L("l:nav_roles")
  local tabInv = L("l:nav_inventory")
  local tabAch = L("l:nav_achievements")
  local tabSettings = L("l:nav_settings")
  local tabExit = L("l:nav_exit")

  local ActiveTab = tabHome

  local function ClearPanels()
      if IsValid(INTRO_PANEL.settings_frame) then INTRO_PANEL.settings_frame:Remove() end
      if IsValid(INTRO_PANEL.class_frame) then INTRO_PANEL.class_frame:Remove() end
      if IsValid(INTRO_PANEL.Hands) then INTRO_PANEL.Hands:Remove() end
      if IsValid(INTRO_PANEL.BreachAchievements) then INTRO_PANEL.BreachAchievements:Remove() end
      if IsValid(INTRO_PANEL.GuidePanel) then INTRO_PANEL.GuidePanel:Remove() end 
  end

  local function HideMainElements()
      if IsValid(INTRO_PANEL.NewsPanel) then INTRO_PANEL.NewsPanel:Hide() end
      if IsValid(INTRO_PANEL.ProfilePanel) then INTRO_PANEL.ProfilePanel:Hide() end
      if IsValid(INTRO_PANEL.DevPanel) then INTRO_PANEL.DevPanel:Hide() end
      if IsValid(INTRO_PANEL.PenaltyPanel) then INTRO_PANEL.PenaltyPanel:Hide() end
  end

  local function GoToHome()
      ActiveTab = tabHome
      ClearPanels()
      if IsValid(INTRO_PANEL.NewsPanel) then INTRO_PANEL.NewsPanel:Show() end
      if IsValid(INTRO_PANEL.ProfilePanel) then INTRO_PANEL.ProfilePanel:Show() end
      if IsValid(INTRO_PANEL.DevPanel) then INTRO_PANEL.DevPanel:Show() end
      if IsValid(INTRO_PANEL.PenaltyPanel) then INTRO_PANEL.PenaltyPanel:Show() end
  end

  local TopBarHeight = sh(70) 
  local TopBar = vgui.Create("DPanel", INTRO_PANEL)
  TopBar:SetSize(scrw, TopBarHeight)
  TopBar:SetPos(0, -TopBarHeight)
  TopBar:MoveTo(0, 0, 0.4, 0, 0.1)

  TopBar.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, rust_dark)
      surface.SetDrawColor(rust_outline)
      surface.DrawLine(0, h-1, w, h-1)
  end

  local LogoIco = Material("nextoren/forge_logo_cumtent.png", "noclamp smooth")
  local LogoPanel = vgui.Create("DPanel", TopBar)
  LogoPanel:SetSize(scrw * 0.15, TopBarHeight)
  LogoPanel:SetPos(sw(38), 0)
  LogoPanel.Paint = function(self, w, h)
      surface.SetDrawColor(255, 255, 255)
      surface.SetMaterial(LogoIco)
      local iconSize = h * 0.7
      surface.DrawTexturedRect(0, h/2 - iconSize/2, iconSize, iconSize)
      draw.DrawText("ZCITY BREACH", "MM_Level", iconSize + sw(10), h/4, rust_text, TEXT_ALIGN_LEFT)
      draw.DrawText("[BETA]", "MM_Level", iconSize + sw(10) + w/1.75, h/4, rust_red_hover, TEXT_ALIGN_LEFT)
      draw.DrawText("ZCITY PROJECT", "MM_Exp", iconSize + sw(10), h/1.9, rust_text, TEXT_ALIGN_LEFT)
  end

  local function CreateTopNavButton(parent, text, iconPath, isRightAligned, onClick)
      local btn = vgui.Create("DButton", parent)
      surface.SetFont("MM_Exp")
      local tw, th = surface.GetTextSize(text)
      btn:SetSize(tw + (iconPath and sw(50) or sw(30)), TopBarHeight)
      if isRightAligned then btn:Dock(RIGHT) else btn:Dock(LEFT) end
      btn:SetText("")
      
      btn.hoverLerp = 0
      btn.Paint = function(self, w, h)
          local isActive = (ActiveTab == text)
          self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 10)
          
          if isActive then
              draw.RoundedBox(0, 0, 0, w, h, Color(188, 64, 43, 30))
              draw.RoundedBox(0, 0, 0, w, sh(3), rust_red)
          elseif self.hoverLerp > 0 then
              draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10 * self.hoverLerp))
          end

          local textX = w/2
          if iconPath then
              surface.SetDrawColor(isActive and rust_text or Color(200,200,200))
              surface.SetMaterial(Material(iconPath, "smooth"))
              surface.DrawTexturedRect(sw(15), h/2 - sh(10), sh(20), sh(20))
              textX = sw(40)
              draw.DrawText(text, "MM_Exp", textX, h/2 - sh(6), isActive and rust_text or Color(200,200,200), TEXT_ALIGN_LEFT)
          else
              draw.DrawText(text, "MM_Exp", textX, h/2 - sh(6), isActive and rust_text or Color(200,200,200), TEXT_ALIGN_CENTER)
          end
      end
      
      btn.DoClick = function(self)
          surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
          if ActiveTab == text and text ~= tabHome and text ~= tabExit and text ~= tabPlay and text ~= tabJoin then
              GoToHome()
              return
          end
          if text ~= tabPlay and text ~= tabJoin then
            ActiveTab = text
          end
          onClick()
      end
      btn.OnCursorEntered = function(self) surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end
      return btn
  end

  local CenterNav = vgui.Create("DPanel", TopBar)
  CenterNav:SetSize(scrw * 0.4, TopBarHeight)
  CenterNav:SetPos(scrw/2 - (scrw * 0.4)/2, 0)
  CenterNav.Paint = function() end

  CreateTopNavButton(CenterNav, tabHome, "nextoren/gui/home.png", false, function() GoToHome() end)
  
  CreateTopNavButton(CenterNav, FIRSTTIME_MENU and tabPlay or tabJoin, "nextoren/gui/play.png", false, function() 
      if (FIRSTTIME_MENU) then
          CreateMainMenuQueryWithHover(L"l:menu_do_precache_or_nah", L"l:menu_yes", L"l:menu_precache_hover", function() firsttimeshit(true) end, L"l:menu_no", L"l:menu_no_precache_hover", function() firsttimeshit(false) end)
      else
          closeMainMenu()
      end
  end)
  
  CreateTopNavButton(CenterNav, tabRoles, "nextoren/gui/roles.png", false, function() 
      ClearPanels()
      HideMainElements()
      OpenClassMenu() 
  end)
  
  CreateTopNavButton(CenterNav, tabInv, "nextoren/gui/hands.png", false, function() 
      ClearPanels()
      HideMainElements()
      OpenHandsListInMenu() 
  end)

  CreateTopNavButton(CenterNav, tabAch, "nextoren/gui/ach.png", false, function() 
      ClearPanels()
      HideMainElements()
      ShowAchievementsLoading()
      net.Start("OpenAchievementMenuInMenu") 
      net.SendToServer()
  end)

  CreateTopNavButton(TopBar, tabExit, "nextoren/gui/out.png", true, function() 
    OpenExitConfirmation() 
  end)
  
  CreateTopNavButton(TopBar, tabSettings, "nextoren/gui/settings.png", true, function() 
      ClearPanels()
      HideMainElements()
      OpenConfigMenu() 
  end)

  local BalancesPanel = vgui.Create("DPanel", TopBar)
  BalancesPanel:Dock(RIGHT)
  BalancesPanel:SetWide(sw(180))
  BalancesPanel:DockMargin(0, 0, sw(20), 0)
  BalancesPanel.Paint = function(self, w, h)
      local ply = LocalPlayer()
      if not IsValid(ply) then return end
      
      local freeExp = ply:GetNWInt("WTh_FreeEXP", 0)
      local donCurrency = (IGS and ply:IGSFunds()) or 0

      draw.SimpleText(L("l:nav_free_exp") .. " " .. freeExp, "MM_Exp", w, h/2 - sh(8), Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
      draw.SimpleText(L("l:nav_balance") .. " " .. donCurrency .. " ₽", "MM_Exp", w, h/2 + sh(8), Color(255, 236, 188), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
  end

  local CURRENT_UPDATE_VERSION = "UB_OBT_2_fix1" 
  
  local UPDATE_TIERS = {
      [1] = { text = "БАГ ФИКС", color = Color(100, 130, 150), glow = 0 }, 
      [2] = { text = "ПАТЧ", color = Color(112, 126, 73), glow = 0 },
      [3] = { text = "МЕЛКОЕ ОБНОВЛЕНИЕ", color = Color(60, 180, 160), glow = 0 },
      [4] = { text = "ОБЫЧНОЕ ОБНОВЛЕНИЕ", color = Color(218, 165, 32), glow = 0 },
      [5] = { text = "КРУПНОЕ ОБНОВЛЕНИЕ", color = Color(220, 80, 40), glow = 0 },
      [6] = { text = "ГЛОБАЛЬНОЕ ОБНОВЛЕНИЕ", color = Color(164, 90, 214), glow = 0 },
      [7] = { text = "ОТКРЫТИЕ СЕРВЕРА!", color = Color(255, 215, 0), glow = 0, rainbow = true }
  }

  local ALL_UPDATES = PATCHIE or {
      { version = "UNKNOWN", tier = 4, title = "Нет данных", text = { "Файл changelogs.lua не найден или пуст." } }
  }

  local current_update_index = 1
  local current_tier = UPDATE_TIERS[ALL_UPDATES[current_update_index].tier] or UPDATE_TIERS[4]

  local NewsW = scrw * 0.22
  local NewsH = scrh * 0.83
  INTRO_PANEL.NewsPanel = vgui.Create("DPanel", INTRO_PANEL)
  local NewsPanel = INTRO_PANEL.NewsPanel
  NewsPanel:SetSize(NewsW, NewsH)
  NewsPanel:SetPos(scrw, sh(86))
  NewsPanel:MoveTo(scrw - NewsW - sw(20), sh(86), 0.6, 0.2, 0.1)
  
  local grad_down = Material("vgui/gradient-d")
  local news_bg_mat = Material("rxsend/mainmenu/scp_096.png", "smooth")

  NewsPanel.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, rust_darker)
      if news_bg_mat then
          surface.SetDrawColor(255, 255, 255, 45)
          surface.SetMaterial(news_bg_mat)
          surface.DrawTexturedRect(0, 0, w, h * 0.5)
      end
      surface.SetDrawColor(rust_darker.r, rust_darker.g, rust_darker.b, 255)
      surface.SetMaterial(grad_down)
      surface.DrawTexturedRect(0, 0, w, h * 0.6)
      draw.RoundedBox(0, 0, h * 0.5, w, h * 0.5, rust_darker)
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
      
      surface.SetFont("MM_RoleName")
      local txtW, txtH = surface.GetTextSize(current_tier.text)
      local badgeW = txtW + sw(20)
      local badgeX = w - badgeW - sw(15)
      local badgeY = sh(15)
      local badgeH = sh(22)
      
      local badgeColor = current_tier.color
      if current_tier.rainbow then badgeColor = HSVToColor((CurTime() * 120) % 360, 0.8, 1) end
      local pulse = current_tier.glow > 0 and math.abs(math.sin(CurTime() * current_tier.glow)) or 0
      
      if current_tier.glow >= 4 then
          for i = 1, 3 do
              draw.RoundedBox(2, badgeX - i, badgeY - i, badgeW + i*2, badgeH + i*2, ColorAlpha(badgeColor, 20 * pulse))
          end
      end
      
      draw.RoundedBox(2, badgeX, badgeY, badgeW, badgeH, ColorAlpha(badgeColor, 255 - (50 * pulse)))
      draw.DrawText(current_tier.text, "MM_RoleName", badgeX + badgeW/2, badgeY + sh(-3), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.DrawText(CURRENT_UPDATE_VERSION, "MM_Exp", w - sw(15), badgeY + badgeH + sh(5), rust_text_dim, TEXT_ALIGN_RIGHT)
  end

  local NewsTitle = vgui.Create("DLabel", NewsPanel)
  NewsTitle:SetPos(sw(20), sh(45))
  NewsTitle:SetSize(NewsW - sw(100), sh(70))
  NewsTitle:SetFont("MM_BigName")
  NewsTitle:SetTextColor(color_white)

  local TextScroll = vgui.Create("DScrollPanel", NewsPanel)
  TextScroll:SetPos(sw(20), sh(125))
  TextScroll:SetSize(NewsW - sw(40), NewsH - sh(230))
  TextScroll:GetVBar():SetWide(0) 

  local function LoadUpdate(index)
      local data = ALL_UPDATES[index]
      if not data then return end

      current_update_index = index
      CURRENT_UPDATE_VERSION = data.version
      current_tier = UPDATE_TIERS[data.tier] or UPDATE_TIERS[4]

      NewsTitle:SetText(data.title)
      TextScroll:Clear()

      for _, line in ipairs(data.text) do
          local lbl = vgui.Create("DLabel", TextScroll)
          lbl:Dock(TOP)
          lbl:SetWrap(true)
          lbl:SetAutoStretchVertical(true)
          if line == "" then
              lbl:SetText("")
              lbl:DockMargin(0, sh(5), 0, 0)
          elseif string.StartWith(line, "#") then
              lbl:SetText(string.sub(line, 3))
              lbl:SetFont("MM_Level")
              lbl:SetTextColor(rust_yellow)
              lbl:DockMargin(0, sh(10), 0, sh(2))
          elseif string.StartWith(line, "-") then
              lbl:SetText(" " .. line)
              lbl:SetFont("MM_Exp")
              lbl:SetTextColor(color_white)
              lbl:DockMargin(sw(5), sh(2), 0, 0)
          elseif string.StartWith(line, "(") then
              lbl:SetText(line)
              lbl:SetFont("MM_Exp")
              lbl:SetTextColor(rust_text_dim)
              lbl:DockMargin(sw(15), 0, 0, sh(2))
          else
              lbl:SetText(line)
              lbl:SetFont("MM_Exp")
              lbl:SetTextColor(color_white)
              lbl:DockMargin(0, sh(2), 0, 0)
          end
      end

      current_update_likes = 0
      current_update_dislikes = 0
      current_update_voted = false
      net.Start("Breach_RequestUpdateRating")
      net.WriteString(CURRENT_UPDATE_VERSION)
      net.SendToServer()
  end

  local BtnPrevUpdate = vgui.Create("DButton", NewsPanel)
  BtnPrevUpdate:SetSize(sw(30), sh(30))
  BtnPrevUpdate:SetPos(NewsW - sw(75), sh(80))
  BtnPrevUpdate:SetText("<")
  BtnPrevUpdate:SetFont("MM_Level")
  BtnPrevUpdate:SetTextColor(color_white)
  BtnPrevUpdate.Paint = function(self, w, h)
      if current_update_index >= #ALL_UPDATES then self:SetTextColor(rust_text_dim) else self:SetTextColor(rust_yellow) end
      if self:IsHovered() and current_update_index < #ALL_UPDATES then draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,10)) end
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
  end
  BtnPrevUpdate.DoClick = function()
      if current_update_index < #ALL_UPDATES then
          surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
          LoadUpdate(current_update_index + 1)
      end
  end

  local BtnNextUpdate = vgui.Create("DButton", NewsPanel)
  BtnNextUpdate:SetSize(sw(30), sh(30))
  BtnNextUpdate:SetPos(NewsW - sw(40), sh(80))
  BtnNextUpdate:SetText(">")
  BtnNextUpdate:SetFont("MM_Level")
  BtnNextUpdate:SetTextColor(color_white)
  BtnNextUpdate.Paint = function(self, w, h)
      if current_update_index <= 1 then self:SetTextColor(rust_text_dim) else self:SetTextColor(rust_yellow) end
      if self:IsHovered() and current_update_index > 1 then draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,10)) end
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
  end
  BtnNextUpdate.DoClick = function()
      if current_update_index > 1 then
          surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
          LoadUpdate(current_update_index - 1)
      end
  end

  LoadUpdate(1)

  local BtnDiscord = vgui.Create("DButton", NewsPanel)
  BtnDiscord:SetSize(NewsW - sw(40), sh(45))
  BtnDiscord:SetPos(sw(20), NewsH - sh(95))
  BtnDiscord:SetText("")
  BtnDiscord.hoverLerp = 0
  BtnDiscord.Paint = function(self, bw, bh)
      self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
      local bgColor = Color(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * self.hoverLerp)
      draw.RoundedBox(0, 0, 0, bw, bh, bgColor)
      surface.SetDrawColor(self.hoverLerp > 0 and rust_yellow or rust_outline)
      surface.DrawOutlinedRect(0, 0, bw, bh, 1)
      local txtColor = self.hoverLerp > 0.5 and rust_darker or color_white
      draw.DrawText("ВСТУПИТЬ В DISCORD", "MM_Exp", bw/2, bh/2 - sh(6), txtColor, TEXT_ALIGN_CENTER)
  end
  BtnDiscord.DoClick = function() surface.PlaySound("nextoren/gui/main_menu/button_click.wav") gui.OpenURL("https://discord.gg/4KmXXWcZFp") end
  BtnDiscord.OnCursorEntered = function() surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end

  local voteW = (NewsW - sw(45)) * 0.3
  
  local BtnLike = vgui.Create("DButton", NewsPanel)
  BtnLike:SetSize(voteW, sh(25))
  BtnLike:SetPos(sw(20), NewsH - sh(40))
  BtnLike:SetText("")
  BtnLike.hoverLerp = 0
  BtnLike.Paint = function(self, bw, bh)
      self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
      draw.RoundedBox(0, 0, 0, bw, bh, Color(35, 35, 35, current_update_voted and 100 or 240))
      if not current_update_voted and self.hoverLerp > 0 then
          draw.RoundedBox(0, 0, 0, bw, bh, Color(112, 126, 73, 150 * self.hoverLerp)) 
      end
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, bw, bh, 1)
      draw.DrawText("Нравится - " .. current_update_likes, "MM_Exp", bw/2, bh/2 - sh(6), current_update_voted and rust_text_dim or color_white, TEXT_ALIGN_CENTER)
  end
  BtnLike.DoClick = function()
      if current_update_voted then return end
      surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
      current_update_voted = true
      current_update_likes = current_update_likes + 1
      net.Start("Breach_VoteUpdate")
      net.WriteString(CURRENT_UPDATE_VERSION)
      net.WriteBool(true)
      net.SendToServer()
  end
  BtnLike.OnCursorEntered = function() if not current_update_voted then surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end end

  local BtnDislike = vgui.Create("DButton", NewsPanel)
  BtnDislike:SetSize(voteW, sh(25))
  BtnDislike:SetPos(sw(20) + voteW + sw(5), NewsH - sh(40))
  BtnDislike:SetText("")
  BtnDislike.hoverLerp = 0
  BtnDislike.Paint = function(self, bw, bh)
      self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
      draw.RoundedBox(0, 0, 0, bw, bh, Color(35, 35, 35, current_update_voted and 100 or 240))
      if not current_update_voted and self.hoverLerp > 0 then
          draw.RoundedBox(0, 0, 0, bw, bh, Color(188, 64, 43, 150 * self.hoverLerp)) 
      end
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, bw, bh, 1)
      draw.DrawText("Не нравится - " .. current_update_dislikes, "MM_Exp", bw/2, bh/2 - sh(6), current_update_voted and rust_text_dim or color_white, TEXT_ALIGN_CENTER)
  end
  BtnDislike.DoClick = function()
      if current_update_voted then return end
      surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
      current_update_voted = true
      current_update_dislikes = current_update_dislikes + 1
      net.Start("Breach_VoteUpdate")
      net.WriteString(CURRENT_UPDATE_VERSION)
      net.WriteBool(false)
      net.SendToServer()
  end
  BtnDislike.OnCursorEntered = function() if not current_update_voted then surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end end

  local RatingPanel = vgui.Create("DPanel", NewsPanel)
  RatingPanel:SetSize(NewsW - sw(40) - (voteW * 2 + sw(5)), sh(25))
  RatingPanel:SetPos(sw(20) + voteW * 2 + sw(5), NewsH - sh(40))
  RatingPanel.Paint = function(self, bw, bh)
      local total = current_update_likes + current_update_dislikes
      local ratingStr = "ОЦЕНОК: 0"
      local ratingColor = rust_text_dim
      if total > 0 then
          local percent = math.Round((current_update_likes / total) * 100)
          ratingStr = "РЕЙТИНГ: " .. percent .. "%"
          if percent >= 70 then ratingColor = rust_green       
          elseif percent <= 40 then ratingColor = rust_red     
          else ratingColor = rust_yellow end                   
      end
      draw.DrawText(ratingStr, "MM_Exp", bw, bh/2 - sh(6), ratingColor, TEXT_ALIGN_RIGHT)
  end

  local DevW = scrw * 0.18
  local DevH = scrh * 0.22 
  
  INTRO_PANEL.DevPanel = vgui.Create("DPanel", INTRO_PANEL)
  local DevPanel = INTRO_PANEL.DevPanel
  DevPanel:SetSize(DevW, DevH)
  DevPanel:SetPos(sw(10), scrh * 0.99 - DevH)

  DevPanel.Paint = function(self, w, h)
      surface.SetDrawColor(rust_panel)
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor(rust_yellow)
      surface.DrawRect(0, 0, w, 2)
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
  end

  local HeaderBlock = vgui.Create("DPanel", DevPanel)
  HeaderBlock:Dock(FILL) 
  HeaderBlock:DockMargin(sw(10), sh(10), sw(10), sh(5))
  HeaderBlock.Paint = function(self, w, h)
      
      surface.SetDrawColor(255, 255, 255, 200)
      surface.SetMaterial(Material("nextoren/gui/zcity.png", "smooth")) 
      surface.DrawTexturedRect(w - sw(120), sh(85), sh(54), sh(54))

      surface.SetDrawColor(229, 158, 212)
      surface.SetMaterial(Material("nextoren/gui/love.png", "smooth")) 
      surface.DrawTexturedRect(w - sw(65), sh(100), sh(24), sh(24))

      surface.SetDrawColor(255, 255, 255, 200)
      surface.SetMaterial(LogoIco) 
      surface.DrawTexturedRect(w - sw(40), sh(90), sh(44), sh(44))
      
      draw.DrawText(L("l:devpanel_title"), "MM_Exp", sw(14), sh(4), color_white, TEXT_ALIGN_LEFT)
      surface.SetDrawColor(rust_outline)
      surface.DrawLine(0, sh(32), w, sh(32))
  end

  local DescText = vgui.Create("DLabel", HeaderBlock)
  DescText:Dock(FILL)
  DescText:DockMargin(0, sh(40), 0, 0) 
  DescText:SetFont("MM_SmallName")
  DescText:SetTextColor(rust_text_dim)
  DescText:SetWrap(true) 
  DescText:SetContentAlignment(7) 
  DescText:SetText(L("l:devpanel_desc"))

  local BtnContainer = vgui.Create("DPanel", DevPanel)
  BtnContainer:Dock(BOTTOM)
  BtnContainer:SetTall(sh(65))
  BtnContainer:DockMargin(sw(10), 0, sw(10), sh(10))
  BtnContainer.Paint = function() end

  local function CreateNavBtn(text, url)
      local btn = vgui.Create("DButton", BtnContainer)
      btn:Dock(TOP)
      btn:DockMargin(0, 0, 0, sh(5))
      btn:SetTall(sh(30))
      btn:SetText("")
      btn.Paint = function(self, w, h)
          local isHov = self:IsHovered()
          local bgCol = isHov and rust_yellow or Color(255, 255, 255, 5)
          local txtCol = isHov and Color(15, 15, 15) or rust_text
          
          surface.SetDrawColor(bgCol)
          surface.DrawRect(0, 0, w, h)
          surface.SetDrawColor(rust_outline)
          surface.DrawOutlinedRect(0, 0, w, h, 1)
          
          draw.DrawText(text, "MM_Desc", w/2, h/2 - sh(5), txtCol, TEXT_ALIGN_CENTER)
      end
      btn.DoClick = function() 
          surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
          gui.OpenURL(url) 
      end
      btn.OnCursorEntered = function() surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end
  end

  CreateNavBtn(L("l:devpanel_btn_legacy"), "мяу я еще не закончил структурировать код")
  CreateNavBtn(L("l:devpanel_btn_original"), "https://github.com/uzelezz123/Z-City")

  local ProfileW = scrw * 0.22
  local ProfileH = scrh * 0.07
  INTRO_PANEL.ProfilePanel = vgui.Create("DPanel", INTRO_PANEL)
  local ProfilePanel = INTRO_PANEL.ProfilePanel
  ProfilePanel:SetSize(ProfileW, ProfileH)
  ProfilePanel:SetPos(scrw - ProfileW - sw(20), scrh * 0.99 - ProfileH)
  ProfilePanel:MoveTo(scrw - ProfileW - sw(20), scrh * 0.99 - ProfileH, 0.6, 0.2, 0.1)

  local av_size = ProfileH - sh(24)
  local AvatarBG = vgui.Create("DPanel", ProfilePanel)
  AvatarBG:SetSize(av_size, av_size)
  AvatarBG:SetPos(ProfileW - av_size - sw(12), sh(12)) 
  AvatarBG.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 200))
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
  end

  local AvatarPanel = vgui.Create("AvatarImage", AvatarBG)
  AvatarPanel:Dock(FILL)
  AvatarPanel:DockMargin(1, 1, 1, 1)
  AvatarPanel:SetPlayer(LocalPlayer(), 64)

  ProfilePanel.Paint = function(self, w, h)
      local ply = LocalPlayer()
      local isPrem = ply:IsPremium()
      local nameColor = isPrem and rust_yellow or rust_text
      local textX = w - av_size - sw(25) 

      draw.RoundedBox(0, 0, 0, w, h, rust_darker)
      draw.RoundedBox(0, 0, 0, w, sh(2), rust_green)
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
      
      surface.SetFont("MM_Exp")
      local nameText = string.upper(ply:Name())
      local nw, nh = surface.GetTextSize(nameText)
      draw.DrawText(nameText, "MM_Exp", textX, sh(14), nameColor, TEXT_ALIGN_RIGHT)
      
      local lvlText = "LVL " .. ply:GetNLevel()
      surface.SetFont("MM_SmallName")
      local lw, lh = surface.GetTextSize(lvlText)
      local badgeW = lw + sw(8)
      local badgeX = textX - nw - sw(10) - badgeW 
      local badgeY = sh(14)
      draw.RoundedBox(2, badgeX, badgeY, badgeW, nh - sh(2), rust_red)
      draw.DrawText(lvlText, "MM_SmallName", badgeX + sw(4), badgeY + sh(1), color_white, TEXT_ALIGN_LEFT)
      
      local btnSpace = sw(45) 
      local exp_w = w - av_size - sw(25) - btnSpace 
      local exp_x = btnSpace 
      local exp_h = sh(10)
      local exp_y = h - sh(22)
      local req = math.max(ply:RequiredEXP(), 1)
      local expProgress = math.Clamp(ply:GetNEXP() / req, 0, 1)
      
      draw.RoundedBox(0, exp_x, exp_y, exp_w, exp_h, Color(15, 15, 15, 250))
      draw.RoundedBox(0, exp_x, exp_y, exp_w * expProgress, exp_h, rust_green)
      
      surface.SetDrawColor(0, 0, 0, 180)
      local steps = 10
      for i=1, steps-1 do
          local stepX = exp_x + (exp_w / steps) * i
          surface.DrawLine(stepX, exp_y, stepX, exp_y + exp_h)
      end
      
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(exp_x, exp_y, exp_w, exp_h, 1)

      draw.DrawText(ply:GetNEXP() .. " / " .. req .. " XP", "MM_SmallName", textX, sh(35), rust_text_dim, TEXT_ALIGN_RIGHT)
  end

  local KillBtn = vgui.Create("DButton", ProfilePanel)
  KillBtn:SetSize(sh(30), sh(30))
  KillBtn:SetPos(sw(10), ProfileH - sh(42)) 
  KillBtn:SetText("")
  KillBtn.hoverLerp = 0
  KillBtn.Paint = function(self, w, h)
      self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 10)
      draw.RoundedBox(0, 0, 0, w, h, Color(35, 33, 31))
      if self.hoverLerp > 0 then
          draw.RoundedBox(0, 0, 0, w, h, Color(rust_red.r, rust_red.g, rust_red.b, 150 * self.hoverLerp))
      end
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
      surface.SetDrawColor(255, 255, 255, 150 + (105 * self.hoverLerp))
      surface.SetMaterial(Material("nextoren/gui/dead.png", "smooth"))
      surface.DrawTexturedRect(sw(6), sh(6), w-sw(12), h-sh(12))
  end
  KillBtn.DoClick = function()
      if (!FIRSTTIME_MENU) then closeMainMenu() net.Start("Breach:Kill") net.SendToServer() end 
  end
  KillBtn.OnCursorEntered = function() surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end

  local PenW = sw(700)
  local PenH = sh(90)
  
  INTRO_PANEL.PenaltyPanel = vgui.Create("DPanel", INTRO_PANEL)
  local PenaltyPanel = INTRO_PANEL.PenaltyPanel
  PenaltyPanel:SetSize(PenW, PenH)
  
  local pX = scrw - ProfileW - sw(20) - PenW - sw(15)
  local pY = scrh * 0.99 - PenH
  
  PenaltyPanel:SetPos(pX, scrh)
  PenaltyPanel:MoveTo(pX, pY, 0.6, 0.2, 0.1)

  PenaltyPanel.CurrentAlpha = 0

  PenaltyPanel.Think = function(self)
      if not IsValid(LocalPlayer()) then return end
      
      local currentAmt = tonumber(LocalPlayer():GetPenaltyAmount()) or 0
      
      local targetAlpha = (currentAmt > 0 and ActiveTab == tabHome) and 255 or 0
      
      self.CurrentAlpha = math.Approach(self.CurrentAlpha, targetAlpha, FrameTime() * 1000)
      self:SetAlpha(self.CurrentAlpha)
  end

  PenaltyPanel.Paint = function(self, w, h)
      if self.CurrentAlpha <= 0 then return end 

      local currentAmt = tonumber(LocalPlayer():GetPenaltyAmount()) or 0
      if currentAmt <= 0 then currentAmt = 0 end 

      draw.RoundedBox(0, 0, 0, w, h, rust_darker)
      draw.RoundedBox(0, 0, 0, w, sh(2), rust_red)
      surface.SetDrawColor(rust_outline)
      surface.DrawOutlinedRect(0, 0, w, h, 1)

      draw.SimpleText(tostring(currentAmt), "MM_BigNameB", sw(50), h/2, rust_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
      surface.SetDrawColor(rust_outline)
      surface.DrawLine(sw(100), sh(15), sw(100), h - sh(15))

      local tX = sw(115)
      draw.SimpleText(L("l:penalty_active_title"), "MM_Exp", tX, sh(18), rust_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      draw.SimpleText(L("l:penalty_active_desc_pt1") .. currentAmt .. L("l:penalty_active_desc_pt2"), "MM_Exp", tX, sh(45), rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      draw.SimpleText(L("l:penalty_active_note"), "MM_Exp", tX, sh(65), rust_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)  end

  local Loading = vgui.Create("DPanel", INTRO_PANEL)
  Loading:SetSize(scrw, scrh)
  Loading:Center()
  Loading.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, color_black)
      surface.SetDrawColor(color_white)
      surface.SetMaterial(LogoIco)
      --draw.SimpleText("Z-Project", "MM_Level", w / 1.5, h, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      local s = scrh * 0.25
      surface.DrawTexturedRect(w/2 - s/2, h/2 - s/2, s, s)
  end
  Loading:AlphaTo(0, 1.5, 1, function() Loading:Remove() end)
end


local gU = Material("vgui/gradient_up")

function OpenHandsListInMenu()
	if IsValid(INTRO_PANEL.Hands) then INTRO_PANEL.Hands:Remove() return end

    local scrw, scrh = ScrW(), ScrH()
    
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end
    
    local rust_bg       = Color(25, 24, 22, 250)
    local rust_card     = Color(45, 43, 40, 255)
    local rust_card_btm = Color(30, 28, 25, 255)
    local rust_outline  = Color(255, 255, 255, 10)
    local rust_green    = Color(112, 126, 73)
    local rust_red      = Color(188, 64, 43)
    local rust_yellow   = Color(218, 165, 32)
    local rust_text     = Color(230, 230, 230)
    local rust_text_dim = Color(140, 140, 140)
    local neon_glow     = Color(255, 241, 48) 

    local TopBarHeight = sh(70)
    
	INTRO_PANEL.Hands = vgui.Create("DPanel", INTRO_PANEL)
	INTRO_PANEL.Hands:SetSize(scrw, scrh - TopBarHeight)
	INTRO_PANEL.Hands:SetPos(0, TopBarHeight)
    INTRO_PANEL.Hands:SetAlpha(0)
    INTRO_PANEL.Hands:AlphaTo(255, 0.2, 0)
	INTRO_PANEL.Hands.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, rust_bg)
	end

    local SubNav = vgui.Create("DPanel", INTRO_PANEL.Hands)
    SubNav:SetSize(scrw - sw(80), sh(45))
    SubNav:SetPos(sw(40), sh(30))
    SubNav.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, rust_card_btm)
        
        draw.RoundedBox(0, 0, 0, sw(200), h, rust_green)
        draw.DrawText(L("l:hands_gloves"), "MM_Exp", sw(100), h/2 - sh(6), color_white, TEXT_ALIGN_CENTER)
        
        draw.RoundedBox(0, sw(201), 0, sw(180), h, Color(40, 40, 40))
        draw.DrawText(L("l:hands_emotes"), "MM_Exp", sw(201) + sw(90), h/2 - sh(6), rust_text_dim, TEXT_ALIGN_CENTER)
    end

	local HandsList = vgui.Create("DScrollPanel", INTRO_PANEL.Hands)
	HandsList:SetPos(sw(40), sh(100))
    HandsList:SetSize(scrw - sw(80), INTRO_PANEL.Hands:GetTall() - sh(130))
	HandsList.Paint = function() end

    local sbar = HandsList:GetVBar()
	sbar:SetWide(math.max(sw(8), 4))
	function sbar:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100)) end
	function sbar.btnUp:Paint() end
	function sbar.btnDown:Paint() end
	function sbar.btnGrip:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100)) end

    local Grid = vgui.Create("DIconLayout", HandsList)
    Grid:Dock(FILL)
    Grid:SetSpaceY(sh(20))
    Grid:SetSpaceX(sw(20))

	local handslist = {
		["prem"] = { id = "prem", name = L("l:hand_prem_name"), desc = L("l:hand_prem_desc"), model = "models/shakytest/prem" },
		["boykisser"] = { id = "boykisser", name = L("l:hand_boykisser_name"), desc = L("l:hand_boykisser_desc"), model = "models/shakytest/boykisser", glow = true }, 
		["mge"] = { id = "mge", name = L("l:hand_mge_name"), desc = L("l:hand_mge_desc"), model = "models/shakytest/mge" },
		["donate1"] = { id = "donate1", name = L("l:hand_anime_name"), desc = L("l:hand_anime_desc"), model = "models/shakytest/donate_gloves_1" },
		["pyz"] = { id = "pyz", name = L("l:hand_pyz_name"), desc = L("l:hand_pyz_desc"), model = "models/shakytest/pyzirik" },
		["fisher"] = { id = "fisher", name = L("l:hand_fisher_name"), desc = L("l:hand_fisher_desc"), model = "models/shakytest/fisher" },
		["xmas"] = { id = "xmas", name = L("l:hand_xmas_name"), desc = L("l:hand_xmas_desc"), model = "models/shakytest/ny" },
		["antifurry"] = { id = "antifurry", name = L("l:hand_antifurry_name"), desc = L("l:hand_antifurry_desc"), model = "models/shakytest/antifurry" },
	}

	local myhandslist = {}
	if LEFACY_GLOVES_BOY and LEFACY_GLOVES_BOY[LocalPlayer():SteamID64()] then table.insert(myhandslist, handslist["boykisser"]) end
	if LocalPlayer():IsPremium() then table.insert(myhandslist, handslist["prem"]) end
	if LEFACY_GLOVES_MGE and LEFACY_GLOVES_MGE[LocalPlayer():SteamID64()] then table.insert(myhandslist, handslist["mge"]) end
	if LEFACY_GLOVES_d_1 and LEFACY_GLOVES_d_1[LocalPlayer():SteamID64()] then table.insert(myhandslist, handslist["donate1"]) end
	if LEFACY_GLOVES_pyz and LEFACY_GLOVES_pyz[LocalPlayer():SteamID64()] then table.insert(myhandslist, handslist["pyz"]) end
	if LEFACY_GLOVES_fisher and LEFACY_GLOVES_fisher[LocalPlayer():SteamID64()] then table.insert(myhandslist, handslist["fisher"]) end
	if tonumber(LocalPlayer():GetNWInt("gloves_xmas")) == 1 then table.insert(myhandslist, handslist["xmas"]) end
	if tonumber(LocalPlayer():GetNWInt("gloves_antifurry")) == 1 or (LEFACY_GLOVES_ANTIFURRY and LEFACY_GLOVES_ANTIFURRY[LocalPlayer():SteamID64()]) then table.insert(myhandslist, handslist["antifurry"]) end

    local cardW = math.floor((HandsList:GetWide() - (sw(20) * 4) - sw(20)) / 5)
    local cardH = cardW * 1.15

	for i = 1, #myhandslist do
		local tabl = myhandslist[i]
		
        local CardBtn = Grid:Add("DButton")
		CardBtn:SetSize(cardW, cardH)
        CardBtn:SetText("")
        CardBtn.hoverLerp = 0

		CardBtn.Paint = function(self, w, h)
            local isEquipped = GetConVar("breach_config_prem_gloves"):GetString() == tabl.id
            
            if self:IsHovered() then
                self.hoverLerp = math.Approach(self.hoverLerp, 1, FrameTime() * 15)
            else
                self.hoverLerp = math.Approach(self.hoverLerp, 0, FrameTime() * 10)
            end

			draw.RoundedBox(0, 0, 0, w, h, rust_card)
            
            if self.hoverLerp > 0 then
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10 * self.hoverLerp))
            end

            local topColor = isEquipped and rust_green or rust_red
            draw.RoundedBox(0, 0, 0, w, sh(4), topColor)

            surface.SetFont("MM_SmallName")
            local tagText = isEquipped and L("l:hands_equipped") or L("l:hands_in_inventory")
            local tw, th = surface.GetTextSize(tagText)
            local tagW = tw + sw(20)
            draw.RoundedBox(0, w - tagW, sh(10), tagW, sh(24), Color(20, 20, 20, 230))
            draw.DrawText(tagText, "MM_SmallName", w - tagW/2, sh(15), isEquipped and rust_green or rust_text_dim, TEXT_ALIGN_CENTER)

            if tabl.glow then
                local pulse = math.abs(math.sin(CurTime() * 4)) 
                
                surface.SetFont("MM_SmallName")
                local gw, gh = surface.GetTextSize(L("l:hands_glowing"))
                local glowTagW = gw + sw(16)
                local glowTagX = sw(10)
                local glowTagY = sh(10)
                
                for glow_layer = 1, 3 do
                    draw.RoundedBox(2, glowTagX - glow_layer, glowTagY - glow_layer, glowTagW + glow_layer*2, sh(24) + glow_layer*2, ColorAlpha(neon_glow, 15 * 1))
                end
                
                draw.RoundedBox(0, glowTagX, glowTagY, glowTagW, sh(24), Color(20, 20, 20, 230))
                draw.DrawText(L("l:hands_glowing"), "MM_SmallName", glowTagX + glowTagW/2, sh(15), ColorAlpha(neon_glow, 180 + 75 * 1), TEXT_ALIGN_CENTER)
            end

            local infoH = sh(70)
            draw.RoundedBox(0, 0, h - infoH, w, infoH, rust_card_btm)
            
            draw.DrawText(tabl.name, "MM_Exp", sw(15), h - infoH + sh(12), color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(tabl.desc, "MM_SmallName", sw(15), h - infoH + sh(35), rust_text_dim, TEXT_ALIGN_LEFT)

            if self.hoverLerp > 0 then
                local btnH = sh(40) * self.hoverLerp
                draw.RoundedBox(0, 0, h - btnH, w, btnH, rust_yellow)
                if self.hoverLerp > 0.8 then
                    local actionText = isEquipped and L("l:hands_unequip") or L("l:hands_equip")
                    draw.DrawText(actionText, "MM_Exp", w/2, h - sh(25), Color(15, 15, 15), TEXT_ALIGN_CENTER)
                end
            end

            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

        CardBtn.DoClick = function(self)
            surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
            if GetConVar("breach_config_prem_gloves"):GetString() == tabl.id then
                GetConVar("breach_config_prem_gloves"):SetString("Нэма")
            else
                GetConVar("breach_config_prem_gloves"):SetString(tabl.id)
            end
        end
        CardBtn.OnCursorEntered = function(self) surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end

		local CharPanel = vgui.Create("DModelPanel", CardBtn)
		CharPanel:SetSize(cardW, cardH - sh(70))
		CharPanel:SetPos(0, sh(10))
        CharPanel:SetMouseInputEnabled(false)

		local ang = Angle(80, -50, 90)
		function CharPanel:LayoutEntity(ent)
			ent:SetAngles(ang)
			self:SetFOV(80)
		end
		function CharPanel:RunAnimation(ent) end

		CharPanel:SetModel("models/imperator/hands/primer_hands.mdl")
		CharPanel:SetDirectionalLight(BOX_TOP, Color(0, 0, 0))
		CharPanel:SetDirectionalLight(BOX_FRONT, Color(0, 0, 0))
		CharPanel:SetDirectionalLight(BOX_RIGHT, Color(160, 66, 66))
		CharPanel:SetDirectionalLight(BOX_LEFT, Color(0, 0, 0))
		CharPanel.Entity:SetSubMaterial(0, tabl.model)

		if table.IsEmpty(CharPanel.Entity:LookupBonemerges()) then
			CharPanel:SetDirectionalLight(BOX_RIGHT, Color(0, 0, 0))
			CharPanel:SetDirectionalLight(BOX_LEFT, Color(46, 28, 28))
		end
		CharPanel:SetCamPos(Vector(0, 0, -10))
	end
end


function send_prefix_data()

  local data = util.JSONToTable(file.Read("breach_prefix_settings.txt", "DATA"))

  net.Start("SendPrefixData")
  net.WriteString(data.prefix)
  net.WriteBool(data.enabled)
  net.WriteString(data.color)
  net.WriteBool(data.rainbow)
  net.SendToServer()

end

BREACH_BETA_WARNING_SHOWN = BREACH_BETA_WARNING_SHOWN or false

local function ShowBetaWarningPanel()
    if BREACH_BETA_WARNING_SHOWN then return end
    BREACH_BETA_WARNING_SHOWN = true

    local scrw, scrh = ScrW(), ScrH()
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    local rust_panel    = Color(30, 28, 25, 255)
    local rust_outline  = Color(255, 255, 255, 10)
    local rust_yellow   = Color(218, 165, 32)
    local rust_text     = Color(230, 230, 230)
    local rust_dim      = Color(140, 140, 140)

    local overlay = vgui.Create("EditablePanel")
    overlay:SetSize(scrw, scrh)
    overlay:SetPos(0, 0)
    overlay:SetZPos(32768)
    overlay:MakePopup()
    overlay:DoModal() 
    
    overlay.StartTime = SysTime()
    overlay.Paint = function(self, w, h)
        local alpha = math.Clamp((SysTime() - self.StartTime) * 4, 0, 1)
        DrawBlurPanel(self, 3, 3)
        surface.SetDrawColor(0, 0, 0, 220 * alpha)
        surface.DrawRect(0, 0, w, h)
    end

    local pnlW, pnlH = sw(700), sh(380)
    local prompt = vgui.Create("DPanel", overlay)
    prompt:SetSize(pnlW, pnlH)
    prompt:Center()
    prompt:SetAlpha(0)
    prompt:AlphaTo(255, 0.2)

    prompt.Paint = function(self, w, h)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(rust_yellow)
        surface.DrawRect(0, 0, w, sh(4))

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleText("ВНИМАНИЕ: ОТКРЫТОЕ БЕТА-ТЕСТИРОВАНИЕ", "MM_RoleName", w/2, sh(25), rust_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(sw(20), sh(50), w - sw(20), sh(50))
    end

    local textLabel = vgui.Create("DLabel", prompt)
    textLabel:SetPos(sw(30), sh(65))
    textLabel:SetSize(pnlW - sw(60), pnlH - sh(140))
    textLabel:SetFont("MM_Exp")
    textLabel:SetTextColor(rust_text)
    textLabel:SetWrap(true)
    textLabel:SetContentAlignment(7)
    
    local txt = "«ZCITY BREACH» НАХОДИТСЯ В СТАДИИ АКТИВНОЙ РАЗРАБОТКИ.\n\n" ..
                "ИГРОВОЙ ПРОЦЕСС, БАЛАНС РОЛЕЙ И ВИЗУАЛЬНЫЙ КОНТЕНТ МОГУТ БЫТЬ ПОДВЕРГНУТЫ СЕРЬЕЗНЫМ ИЗМЕНЕНИЯМ В ЛЮБОЙ МОМЕНТ БЕЗ ПРЕДВАРИТЕЛЬНОГО УВЕДОМЛЕНИЯ.\n\n" ..
                "ВО ВРЕМЯ ИГРЫ ВОЗМОЖНО ВОЗНИКНОВЕНИЕ КРИТИЧЕСКИХ ОШИБОК, ПАДЕНИЙ ПРОИЗВОДИТЕЛЬНОСТИ И НЕДОРАБОТОК МЕХАНИК. МЫ ПРОСИМ ОБО ВСЕХ НАЙДЕННЫХ БАГАХ И УЯЗВИМОСТЯХ НЕЗАМЕДЛИТЕЛЬНО СООБЩАТЬ ТЕХНИЧЕСКОМУ ПЕРСОНАЛУ В НАШЕМ DISCORD-КАНАЛЕ.\n\n" ..
                "БЛАГОДАРИМ ЗА ВАШЕ УЧАСТИЕ И ПОНИМАНИЕ."
    textLabel:SetText(txt)

    local btn = vgui.Create("DButton", prompt)
    btn:SetSize(sw(300), sh(40))
    btn:SetPos(pnlW/2 - sw(150), pnlH - sh(60))
    btn:SetText("")
    btn.hoverLerp = 0
    
    btn.Paint = function(self, w, h)
        self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
        
        surface.SetDrawColor(40, 38, 35, 255) -- rust_row
        surface.DrawRect(0, 0, w, h)

        if self.hoverLerp > 0 then
            surface.SetDrawColor(218, 165, 32, 255 * self.hoverLerp)
            surface.DrawRect(0, 0, w, h)
        end

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local txtCol = self.hoverLerp > 0.5 and Color(15,15,15) or rust_text
        draw.SimpleText("ОЗНАКОМЛЕН И СОГЛАСЕН", "MM_Exp", w/2, h/2 - sh(2), txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btn.DoClick = function()
        overlay:AlphaTo(0, 0.15, 0, function()
            if IsValid(overlay) then overlay:Remove() end
            timer.Simple(0.1, function()
            CreateMainMenuQueryWithHover(L"l:menu_do_precache_or_nah", L"l:menu_yes", L"l:menu_precache_hover", function() firsttimeshit(true) end, L"l:menu_no", L"l:menu_no_precache_hover", function() firsttimeshit(false) end)
            end)
        end)
    end
    
    btn.OnCursorEntered = function()
        surface.PlaySound("nextoren/gui/main_menu/button_hover.wav")
    end
end

hook.Add("InitPostEntity", "StartBreachIntro", function()
  StartBreach(true)
  timer.Simple(0.5, function()
      ShowBetaWarningPanel()
  end)
  if !file.Exists("breach_prefix_settings.txt", "DATA") then
    file.Write("breach_prefix_settings.txt", util.TableToJSON({
      enabled = false,
      prefix = "my prefix",
      color = "255,255,255",
      rainbow = false,
    }, true))
  end
  send_prefix_data()
end)

concommand.Add("send_prefix_data", send_prefix_data)


CreateConVar("breach_config_cw_viewmodel_fov", 70, FCVAR_ARCHIVE, "Change CW 2.0 weapon viewmodel FOV", 50, 100)
CreateConVar("breach_config_cw_viewmodel_offset_z", 0, FCVAR_ARCHIVE, "Change CW 2.0 weapon viewmodel FOV", 0, 30)
CreateConVar("breach_config_announcer_volume", GetConVar("volume"):GetFloat() * 100, FCVAR_ARCHIVE, "Change announcer's volume", 0, 100)

CreateConVar("breach_config_language", GetConVar("cvar_br_language"):GetString() or "english", FCVAR_ARCHIVE, "Change gamemode language")
CreateConVar("breach_config_name_color", "255,255,255", FCVAR_ARCHIVE, "Change your nick color in chat. Example: 150,150,150. Premium or higher only")
CreateConVar("breach_config_mge_mode", 0, FCVAR_ARCHIVE, "MGE MODE", 0, 1)

CreateConVar("breach_config_hair_color", "255,255,255", FCVAR_ARCHIVE, "Change your nick color in chat. Example: 150,150,150. Premium or higher only")


CreateConVar("breach_config_overall_music_volume", 100, FCVAR_ARCHIVE, "Change music volume", 0, 200)

CreateConVar("breach_config_music_ambient_volume", 25, FCVAR_ARCHIVE, "Change music volume", 0, 100)
CreateConVar("breach_config_music_spawn_volume", 100, FCVAR_ARCHIVE, "Change music volume", 0, 100)
CreateConVar("breach_config_music_panic_volume", 100, FCVAR_ARCHIVE, "Change music volume", 0, 100)
CreateConVar("breach_config_music_misc_volume", 100, FCVAR_ARCHIVE, "Change music volume", 0, 100)


CreateConVar("breach_config_event_mode", 0, FCVAR_NONE, "Completely disables HUD. Can be buggy", 0, 1)
CreateConVar("breach_config_screenshot_mode", 0, FCVAR_NONE, "Completely disables HUD. Can be buggy", 0, 1)
CreateConVar("breach_config_blur", 1, FCVAR_NONE, "Blur or not", 0, 1)
CreateConVar("breach_config_snow", 0, FCVAR_NONE, "Snow or not", 0, 1)
CreateConVar("breach_config_screen_effects", 1, FCVAR_ARCHIVE, "Enables bloom and toytown", 0, 1)
CreateConVar("breach_config_filter_textures", 1, FCVAR_ARCHIVE, "Disabling this will decrease texture quality. Alias: mat_filtertextures", 0, 1)
CreateConVar("breach_config_filter_lightmaps", 1, FCVAR_ARCHIVE, "Disabling this will decrease lightmap(shadows) quality. Alias: mat_filterlightmaps", 0, 1)
CreateConVar("breach_config_display_premium_icon", 1, FCVAR_ARCHIVE, "Disabling display on scoreboard/chat/voice", 0, 1)
CreateConVar("breach_config_spawn_female_only", 0, FCVAR_ARCHIVE, "Spawn only as female characters", 0, 1)
CreateConVar("breach_config_prem_gloves", "Нэма", FCVAR_ARCHIVE, "Type of hands", 0, 1)

CreateConVar("breach_config_spawn_male_only", 0, FCVAR_ARCHIVE, "Spawn only as male characters", 0, 1)
CreateConVar("breach_config_no_role_description", 0, FCVAR_ARCHIVE, "Disables role description", 0, 1)
CreateConVar("breach_config_scp_red_screen", 1, FCVAR_ARCHIVE, "Enables the red screen for SCP", 0, 1)
CreateConVar("breach_config_spawn_support", 1, FCVAR_ARCHIVE, "Spawn as support", 0, 1)
CreateConVar("breach_config_hud_style", 0, FCVAR_ARCHIVE, "Changes your HUD style", 0, 1)
CreateConVar("breach_config_contrast", 0, FCVAR_ARCHIVE, "contrast screen", 0, 1)


CreateConVar("breach_config_filter_yellow", 0, FCVAR_ARCHIVE, "Patrolling the Site-19 makes you wish for a nuclear winter.", 0, 1)
CreateConVar("breach_config_filter_blue", 0, FCVAR_ARCHIVE, "Enables blue color filter", 0, 1)
CreateConVar("breach_config_filter_outside", 0, FCVAR_ARCHIVE, "Enables color filter outside", 0, 1)
CreateConVar("breach_config_filter_intensity", 0, FCVAR_ARCHIVE, "Changes intensity of color filter", 1, 10)
CreateConVar("breach_config_hide_title", 0, FCVAR_ARCHIVE, "Disable bottom title", 0, 1)
CreateConVar("breach_config_sexual_chemist", 1, FCVAR_ARCHIVE, "Sexy Chemist", 0, 1)
CreateConVar("breach_config_disable_voice_spec", 0, FCVAR_NONE, "You won't hear other spectators as a spectator", 0, 1)
CreateConVar("breach_config_disable_voice_alive", 0, FCVAR_NONE, "You won't hear alive people as a spectator", 0, 1)
CreateConVar("breach_config_useability", KEY_H, FCVAR_ARCHIVE, "number you will use ability with")
CreateConVar("breach_config_openinventory", KEY_Q, FCVAR_ARCHIVE, "number you will open inventory with")
CreateConVar("breach_config_leanright", KEY_3, FCVAR_ARCHIVE, "Leans to the right")
CreateConVar("breach_config_leanleft", KEY_1, FCVAR_ARCHIVE, "Leans to the left")
CreateConVar("breach_config_quickchat", KEY_C, FCVAR_ARCHIVE, "Quick chat menu")
CreateConVar("breach_config_draw_legs", 1, FCVAR_ARCHIVE, "Draw legs")
CreateConVar("breach_config_killfeed", 1, FCVAR_ARCHIVE, "Show killfeed")
CreateConVar("breach_config_scphudleft", 0, FCVAR_ARCHIVE, "SCP Ability style")


function GetAnnouncerVolume()
  return GetConVar("breach_config_announcer_volume"):GetInt() or 50
end


RunConsoleCommand("mat_filtertextures", GetConVar("breach_config_filter_textures"):GetInt())
RunConsoleCommand("mat_filterlightmaps", GetConVar("breach_config_filter_lightmaps"):GetInt())

cvars.AddChangeCallback("breach_config_filter_textures", function(cvar, old, new)
  RunConsoleCommand("mat_filtertextures", tonumber(new))
end)

cvars.AddChangeCallback("breach_config_filter_lightmaps", function(cvar, old, new)
  RunConsoleCommand("mat_filterlightmaps", tonumber(new))
end)

cvars.AddChangeCallback("breach_config_contrast", function(cvar, old, new)
  
end)

cvars.AddChangeCallback("breach_config_screenshot_mode", function(_,_, new)
  
end)


RunConsoleCommand("breach_config_language", GetConVar("breach_config_language"):GetString())

cvars.AddChangeCallback("breach_config_language", function(cvar, old, new)
  RunConsoleCommand("cvar_br_language", new)
end)

BREACH.AllowedNameColorGroups = {
  ["superadmin"] = true,
  ["spectator"] = true,
  ["admin"] = true,
  ["premium"] = true,
}


function NameColorSend(cvar, old, new)
if LocalPlayer():IsPremium() then
  if !new:find(",") then return end
    local color_tbl = string.Explode(",", new)

    if isnumber(tonumber(color_tbl[1])) and isnumber(tonumber(color_tbl[2])) and isnumber(tonumber(color_tbl[3])) then
      color = Color(tonumber(color_tbl[1]), tonumber(color_tbl[2]), tonumber(color_tbl[3]))
      if IsColor(color) then
        color.a = 255 
        
        net.Start("NameColor")
          net.WriteColor(color)
        net.SendToServer()
      end
    end
  end
end
cvars.AddChangeCallback("breach_config_name_color", NameColorSend)

function HairColorSend(cvar, old, new)
if LEGACY_HAIRCOLOR[LocalPlayer():SteamID64()] then
  if !new:find(",") then return end
    local color_tbl = string.Explode(",", new)

    if isnumber(tonumber(color_tbl[1])) and isnumber(tonumber(color_tbl[2])) and isnumber(tonumber(color_tbl[3])) then
      color = Color(tonumber(color_tbl[1]), tonumber(color_tbl[2]), tonumber(color_tbl[3]))
      if IsColor(color) then
        color.a = 255 
        
        net.Start("HairColor")
          net.WriteColor(color)
        net.SendToServer()
      end
    end
  end
end
cvars.AddChangeCallback("breach_config_hair_color", HairColorSend)

local function ChangeServerValue(id, bool)

  net.Start("Change_player_settings")
  net.WriteUInt(id, 12)
  net.WriteBool(bool)
  net.SendToServer()

end

local function ChangeServerValueStr(id, str)

  net.Start("Change_player_settings_str")
  net.WriteUInt(id, 12)
  net.WriteString(str)
  net.SendToServer()

end

local function ChangeServerValueInt(id, int)

  net.Start("Change_player_settings_id")
  net.WriteUInt(id, 12)
  net.WriteUInt(int, 32)
  net.SendToServer()

end

cvars.AddChangeCallback("breach_config_disable_voice_spec", function(_, _, new)
  ChangeServerValue(5,tobool(new))
end)

cvars.AddChangeCallback("breach_config_sexual_chemist", function(_, _, new)
  ChangeServerValue(7,tobool(new))
end)

cvars.AddChangeCallback("breach_config_disable_voice_alive", function(_, _, new)
  ChangeServerValue(6,tobool(new))
end)

cvars.AddChangeCallback("breach_config_spawn_female_only", function(_, _, new)

  ChangeServerValue(2, tobool(new))

end)

cvars.AddChangeCallback("breach_config_prem_gloves", function(_, _, new)

  
  ChangeServerValueStr(8,tostring(new))

end)

cvars.AddChangeCallback("breach_config_xmas_gloves", function(_, _, new)

  ChangeServerValue(9, tobool(new))

end)

cvars.AddChangeCallback("breach_config_useability", function(_, _, new)

  LocalPlayer().AbilityKey = string.upper(input.GetKeyName(new))
  LocalPlayer().AbilityKeyCode = new
  ChangeServerValueInt(1, new)

end)

cvars.AddChangeCallback("breach_config_spawn_male_only", function(_, _, new)

  ChangeServerValue(3, tobool(new))

end)

cvars.AddChangeCallback("breach_config_spawn_support", function(_, _, new)

  ChangeServerValue(1, tobool(new))

end)

cvars.AddChangeCallback("breach_config_display_premium_icon", function(_, _, new)

  ChangeServerValue(4, tobool(new))

end)

hook.Add("InitPostEntity", "NameColorSend", function()
  timer.Simple(30, function()
    local tab = {
      spawnsupport = GetConVar("breach_config_spawn_support"):GetBool(),
      spawnmale = GetConVar("breach_config_spawn_male_only"):GetBool(),
      spawnfemale = GetConVar("breach_config_spawn_female_only"):GetBool(),
      displaypremiumicon = GetConVar("breach_config_display_premium_icon"):GetBool(),
      useability = GetConVar("breach_config_useability"):GetInt(),
      sexychemist = GetConVar("breach_config_sexual_chemist"):GetBool(),
      premgloves = GetConVar("breach_config_prem_gloves"):GetString(),
      
    }
    net.Start("Load_player_data")
    net.WriteTable(tab)
    net.SendToServer()
    NameColorSend("pidr", "pidr", GetConVar("breach_config_name_color"):GetString())
    HairColorSend("pidr", "pidr", GetConVar("breach_config_hair_color"):GetString())
  end)
end)

hook.Add("HUDShouldDraw", "Breach_Screenshot_Mode", function(name)
  if GetConVar("breach_config_screenshot_mode"):GetInt() == 0 then return end

  
  
  

  return false

end)


  



  


local yellow = GetConVar("breach_config_filter_yellow")
local blue = GetConVar("breach_config_filter_blue")
local mult = GetConVar("breach_config_filter_intensity")
local noutisde = GetConVar("breach_config_filter_outside")
local colormodify_yellow = {
  ["$pp_colour_addr"] = 0,
  ["$pp_colour_addg"] = 0,
  ["$pp_colour_addb"] = 0,
  ["$pp_colour_brightness"] = 0,
  ["$pp_colour_contrast"] = 1,
  ["$pp_colour_colour"] = 1,
  ["$pp_colour_mulr"] = 0,
  ["$pp_colour_mulg"] = 0,
  ["$pp_colour_mulb"] = 0,
}

local colormodify_blue = {
  ["$pp_colour_addr"] = 0,
  ["$pp_colour_addg"] = 0,
  ["$pp_colour_addb"] = 0,
  ["$pp_colour_brightness"] = 0,
  ["$pp_colour_contrast"] = 1,
  ["$pp_colour_colour"] = 1,
  ["$pp_colour_mulr"] = 0,
  ["$pp_colour_mulg"] = 0,
  ["$pp_colour_mulb"] = 0,
}


local translate_translations = {
  ["english"] = "English",
  ["russian"] = "Русский",
  ["chinese"] = "中文",
  
}

BREACH.Options = {
  {
    name = "l:menu_settings",
    settings = {
      {
        name = "SEXY CHEMIST",
        checkplayer = RXSEND_SEXY_CHEMISTS,
        cvar = "breach_config_sexual_chemist",
        type = "bool",
      },
      {
        name = "Смещение вперед/назад (X)",
        cvar = "hg_gunorigin_x",
        type = "slider",
        min = -4,
        max = 4,
        decimals = 2 
      },
      {
        name = "Смещение вправо/влево (Y)",
        cvar = "hg_gunorigin_y",
        type = "slider",
        min = -4,
        max = 4,
        decimals = 2
      },
      {
        name = "Смещение вверх/вниз (Z)",
        cvar = "hg_gunorigin_z",
        type = "slider",
        min = -4,
        max = 4,
        decimals = 2
      },
      
      {
        name = "Сила размытия при стрельбе",
        cvar = "hg_weaponshotblur_mul",
        type = "slider",
        min = 0,
        max = 1,
        decimals = 2
      },
      {
        name = "l:menu_no_role_desc",
        cvar = "breach_config_no_role_description",
        type = "bool",
      },
      {
        name = "l:menu_spawn_as_sup",
        cvar = "breach_config_spawn_support",
        type = "bool",
      },
      {
        name = "l:menu_useability",
        cvar = "breach_config_useability",
        type = "bind",
      },
      {
        name = "l:menu_inventory_key",
        cvar = "breach_config_openinventory",
        type = "bind",
      },
      {
        name = "l:menu_quickchat",
        cvar = "breach_config_quickchat",
        type = "bind",
      },
      {
        name = "l:menu_lang",
        cvar = "breach_config_language",
        type = "choice",
        value = {
          "english",
          "russian",
          "chinese",
          
        },
      },
    },
  },
  {
    name = "l:menu_chat_voice",
    settings = {
      {
        name = "l:menu_gradient_voice",
        cvar = "br_gradient_voice_chat",
        type = "bool"
      },
      {
        name = "l:menu_voice_show_alive",
        cvar = "br_voicechat_showalive",
        type = "bool"
      },
      {
        name = "l:menu_disable_flashes",
        cvar = "lounge_chat_disable_flashes",
        type = "bool"
      },
      {
        name = "l:menu_disable_avatars",
        cvar = "lounge_chat_hide_avatars",
        type = "bool"
      },
      {
        name = "l:menu_roundavatars",
        cvar = "lounge_chat_roundavatars",
        type = "bool"
      },
      {
        name = "l:menu_clearemoji",
        cvar = "br_voicechat_showalive",
        type = "unique",
        createpanel = function(panel)

          local siz = 0

          local pa = LOUNGE_CHAT.ImageDownloadFolder .. "/"
          local fil = file.Find(pa .. "*.png", "DATA")
          for _, f in pairs (fil) do
            siz = siz + file.Size(pa .. f, "DATA")
          end

          local clear_dpanel = vgui.Create("DPanel", panel)
          clear_dpanel:Dock(TOP)
          clear_dpanel:SetSize(0,30)
          clear_dpanel.Paint = function() end
          local clear_panel = vgui.Create("DButton", clear_dpanel)
          clear_panel:Dock(FILL)
          clear_panel:DockMargin(3,3,3,3)
          clear_panel:SetText("")
          clear_panel.Text = "l:menu_clear_downloaded_images ("..string.NiceSize(siz)..")"
          local col = Color(255,255,255,100)
          clear_panel.Paint = function(self, w, h)
            if self:IsHovered() then
              draw.RoundedBox(0,0,0,w,h,col)
            end
            drawmat(5,0,w-10,1,gradients)
            drawmat(5,h-1,w-10,1,gradients)

            draw.DrawText(L(self.Text), "ScoreboardContent", w/2,4, nil, TEXT_ALIGN_CENTER)
          end

          clear_panel.DoClick = function(self)
            local pa = LOUNGE_CHAT.ImageDownloadFolder .. "/"
            local fil = file.Find(pa .. "*.png", "DATA")
            for _, f in pairs (fil) do
              file.Delete(pa .. f)
            end
            self.Text = "l:menu_clear_downloaded_images ("..string.NiceSize(0)..")"
          end

        end
      },
    },
  },
  {
    name = "l:menu_audio",
    settings = {
      {
        name = "l:menu_mute_spec",
        cvar = "breach_config_disable_voice_spec",
        type = "bool",
      },
      {
        name = "l:menu_mute_spec_if_alive",
        cvar = "breach_config_disable_voice_alive",
        type = "bool",
      },
      {
        name = "l:menu_announcer_volume",
        cvar = "breach_config_announcer_volume",
        type = "slider",
        min = 0,
        max = 100,
      },
    },
  },
  {
    name = "l:menu_music_title",
    settings = {
      {
        name = "l:menu_overall_music_volume",
        cvar = "breach_config_overall_music_volume",
        type = "slider",
        min = 0,
        max = 200,
      },
      {
        name = "l:menu_spawn_music_volume",
        cvar = "breach_config_music_spawn_volume",
        type = "slider",
        min = 0,
        max = 100,
      },
      {
        name = "l:menu_panic_music_volume",
        cvar = "breach_config_music_panic_volume",
        type = "slider",
        min = 0,
        max = 100,
      },
      {
        name = "l:menu_ambience_music_volume",
        cvar = "breach_config_music_ambient_volume",
        type = "slider",
        min = 0,
        max = 100,
      },
      {
        name = "l:menu_misc_music_volume",
        cvar = "breach_config_music_misc_volume",
        type = "slider",
        min = 0,
        max = 100,
      },
    },
  },
  {
    name = "Настройки Оптимизации",
    settings = {
      {
        name = "Режим картошки (слабый ПК)",
        cvar = "hg_potatopc",
        type = "bool"
      },
      {
        name = "Дальность анимаций",
        cvar = "hg_anims_draw_distance",
        type = "slider",
        min = 0,
        max = 4096,
      },
      {
        name = "Дальность обвесов (Attachments)",
        cvar = "hg_attachment_draw_distance",
        type = "slider",
        min = 0,
        max = 4096,
      },
      {
        name = "Оптимизация прицелов",
        cvar = "hg_optimise_scopes",
        type = "slider",
        min = 0,
        max = 2,
      },
      {
        name = "Макс. дымных следов от пуль",
        cvar = "hg_maxsmoketrails",
        type = "slider",
        min = 0,
        max = 30,
      },
      {
        name = "Размытие при стрельбе",
        cvar = "hg_weaponshotblur_enable",
        type = "bool"
      },
    }
  },
  {
    name = "l:menu_visual_settings",
    settings = {
      
      {
        name = "l:menu_drawlegs",
        cvar = "breach_config_draw_legs",
        type = "bool"
      },
      {
        name = "l:menu_killfeed",
        cvar = "breach_config_killfeed",
        type = "bool"
      },
      {
        name = "l:menu_hide_title",
        cvar = "breach_config_hide_title",
        type = "bool"
      },
      {
        name = "l:menu_scp_red_vision",
        cvar = "breach_config_scp_red_screen",
        type = "bool"
      },
      {
        name = "l:menu_screenshot_mode",
        cvar = "breach_config_screenshot_mode",
        type = "bool",
      },
      --{
      --  name = "l:menu_screen_effects",
      --  cvar = "breach_config_screen_effects",
      --  type = "bool",
      --},
      {
        name = "l:menu_filter_textures",
        cvar = "breach_config_filter_textures",
        type = "bool",
      },
      {
        name = "l:menu_filter_lightmaps",
        cvar = "breach_config_filter_lightmaps",
        type = "bool",
      },
      
      
      
      
      
      {
        name = "l:menu_snow",
        cvar = "breach_config_snow",
        type = "bool",
      },
      {
        name = "l:menu_blur",
        cvar = "breach_config_blur",
        type = "bool",
      },
      
    }
  },
  
  
  
  
  
  
  
  
  
  
  
  {
    name = "l:menu_premium_settings",
    premium = true,
    settings = {
      {
        name = "l:menu_nick_grb_color",
        cvar = "breach_config_name_color",
        type = "color",
        premium = true,
      },
      {
        name = "l:menu_display_premium_icon",
        cvar = "breach_config_display_premium_icon",
        type = "bool",
        premium = true,
      },
      {
        name = "l:menu_spawn_male_only",
        cvar = "breach_config_spawn_male_only",
        type = "bool",
        premium = true,
      },
      {
        name = "l:menu_spawn_female_only",
        cvar = "breach_config_spawn_female_only",
        type = "bool",
        premium = true,
      },
      
      
      
      
      
      
    }
  },
  {
    name = "l:other",
    settings = {
      {
        name = "l:haircolor",
        cvar = "breach_config_hair_color",
        type = "color",
        hair = true,
      },
      
      
      
      
      
      
    }
  },
  {
    name = "Ивентерам",
    settings = {
      {
        name = "Включить ивент меню",
        cvar = "breach_config_event_mode",
        type = "bool"
      },
    }
  }
  
}

local TEXTENTRY_FRAME 
local function niceSum(i, iFallback)
    return math.Truncate(tonumber(i) or iFallback, 2)
end

function Deposit2(iRealSum)
    iRealSum = tonumber(iRealSum)
    local scrw, scrh = ScrW(), ScrH()
    if IsValid(INTRO_PANEL.settings_frame) then
        INTRO_PANEL.settings_frame:AlphaTo(0, 1, 0, function()
            INTRO_PANEL.settings_frame:Remove()
            INTRO_PANEL.settings_frame = nil
            Deposit2()
        end)
        return
    end

    local settings_frame = vgui.Create("EditablePanel", INTRO_PANEL)
    INTRO_PANEL.settings_frame = settings_frame
    settings_frame:SetSize(scrw * 0.3, scrh * 0.3)
    settings_frame:Center()
    settings_frame:SetAlpha(0)
    settings_frame:SetKeyboardInputEnabled(true)
    settings_frame:SetMouseInputEnabled(true)
    settings_frame:AlphaTo(255, 1)
    settings_frame:MoveToFront()
    local padding = 20
    local inner_width = settings_frame:GetWide() - padding * 2
    settings_frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, dark_clr)
        DrawBlurPanel(self)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(grad2)
        surface.DrawTexturedRect(0, 0, 3, h / 2)
        surface.DrawTexturedRect(w - 3, 0, 3, h / 2)
        surface.SetMaterial(grad1)
        surface.DrawTexturedRect(0, h / 2, 3, h / 2)
        surface.DrawTexturedRect(w - 3, h / 2, 3, h / 2)
        settings_frame:MakePopup()
    end

    hook.Run("IGS.OnDepositWinOpen", iRealSum)
    local realSum = math.max(IGS.GetMinCharge(), niceSum(iRealSum, 0))
    local dlabel = vgui.Create("DLabel", settings_frame)
    dlabel:SetSize(inner_width, 25)
    dlabel:SetPos(padding, padding)
    dlabel:SetText("Введи сумму на которую хочешь пополнить")
    dlabel:SetFont("donate_text")
    dlabel:SetTextColor(color_white)
    dlabel:SetContentAlignment(5)
    local real_m = vgui.Create("DTextEntry", settings_frame)
    real_m:SetPos(padding, padding + 30)
    real_m:SetSize(inner_width, 32)
    real_m:SetNumeric(true)
    real_m:SetTextColor(color_white)
    real_m:SetValue(realSum)
    real_m:RequestFocus()
    real_m.Paint = function(self2, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 255))
        self2:DrawTextEntryText(self2:GetTextColor(), self2:GetHighlightColor(), self2:GetCursorColor())
        if self2:GetText() == "" and not self2:HasFocus() then draw.SimpleText(self2:GetPlaceholderText() or "", "donate_text", 5, h / 2, ColorAlpha(color_white, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
    end

    real_m.PaintOver = nil
    local purchase = vgui.Create("DButton", settings_frame)
    purchase:SetSize(inner_width, 40)
    purchase:SetPos(padding, padding + 75)
    purchase:SetText("Пополнить счет")
    purchase:SetFont("donate_text")
    purchase:SetTextColor(color_white)
    purchase.Paint = function(self2, w, h)
        local clr = self2:IsHovered() and Color(60, 60, 60) or Color(45, 45, 45)
        draw.RoundedBox(4, 0, 0, w, h, clr)
    end

    purchase.DoClick = function()
        local want_money = niceSum(real_m:GetValue())
        if not want_money then return end
        if want_money < realSum then return end
        IGS.GetPaymentURL(want_money, function(url)
            IGS.OpenURL(url)
            if not IsValid(m) then return end
        end)
    end

    real_m.Think = function()
        local sum = tonumber(real_m:GetValue())
        if sum then
            purchase:SetText("Пополнить счет на " .. niceSum(sum, 0) .. " руб")
            purchase:SetEnabled(sum > 0)
        else
            purchase:SetText("Пополнить счет")
            purchase:SetEnabled(false)
        end
    end
end



surface.CreateFont( "donate_text", {
  font = "Univers LT Std 47 Cn Lt",
  size = 22,
  weight = 0,
  antialias = true,
  extended = true,
  shadow = false,
  outline = false,
  
})





function OpenClassMenu()
    net.Start("WTh_RequestSync")
    net.SendToServer()
    local scrw, scrh = ScrW(), ScrH()

    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    if IsValid(INTRO_PANEL.class_frame) then
        INTRO_PANEL.class_frame:Remove()
        INTRO_PANEL.class_frame = nil
        return
    end

    local rust_bg       = Color(20, 19, 17, 250)
    local rust_panel    = Color(15, 14, 13, 240)
    local rust_card     = Color(35, 33, 30, 255)
    local rust_card_btm = Color(25, 23, 20, 255)
    local rust_dark     = Color(10, 9, 8, 255)
    local rust_outline  = Color(255, 255, 255, 10)
    local rust_green    = Color(112, 126, 73)
    local rust_red      = Color(188, 64, 43)
    local rust_yellow   = Color(218, 165, 32)
    local rust_text     = Color(230, 230, 230)
    local rust_dim      = Color(140, 140, 140)

    local shine_mat = Material("gui/center_gradient")

    local function DrawHazardStripes(w, h, alpha)
        surface.SetDrawColor(0, 0, 0, alpha)
        local step = sw(15)
        local offset = (CurTime() * 20) % step
        for i = -h - step, w, step do
            local x = i + offset
            surface.DrawLine(x, 0, x + h, h)
            surface.DrawLine(x + 1, 0, x + h + 1, h)
            surface.DrawLine(x + 2, 0, x + h + 2, h)
        end
    end

    local function DrawTechCorners(x, y, w, h, col, len, th)
        surface.SetDrawColor(col)
        surface.DrawRect(x, y, len, th)
        surface.DrawRect(x, y, th, len)
        
        surface.DrawRect(x + w - len, y, len, th)
        surface.DrawRect(x + w - th, y, th, len)
        
        surface.DrawRect(x, y + h - th, len, th)
        surface.DrawRect(x, y + h - len, th, len)
        
        surface.DrawRect(x + w - len, y + h - th, len, th)
        surface.DrawRect(x + w - th, y + h - len, th, len)
    end

    local faction_table = {
        [1] = { name = clang.ClassD, icon = "nextoren/gui/roles_icon/class_d.png", roles = BREACH_ROLES.CLASSD },
        [2] = { name = clang.SECURITY, icon = "nextoren/gui/roles_icon/sb.png", roles = BREACH_ROLES.SECURITY },
        [3] = { name = clang.SCI, icon = "nextoren/gui/roles_icon/sci.png", roles = BREACH_ROLES.SCI },
        [4] = { name = clang.MTF, icon = "nextoren/gui/roles_icon/mtf.png", roles = BREACH_ROLES.MTF },
        [5] = { name = clang.QRT, icon = "nextoren/gui/roles_icon/obr.png", roles = BREACH_ROLES.OBR },
        [6] = { name = clang.NTF, icon = "nextoren/gui/roles_icon/ntf.png", roles = BREACH_ROLES.NTF },
        [7] = { name = clang.Chaos, icon = "nextoren/gui/roles_icon/chaos.png", roles = BREACH_ROLES.CHAOS },
        [8] = { name = clang.Goc, icon = "nextoren/gui/roles_icon/goc.png", roles = BREACH_ROLES.GOC },
        [9] = { name = clang.DZ, icon = "nextoren/gui/roles_icon/dz.png", roles = BREACH_ROLES.DZ },
        [10] = { name = "SCP", icon = "nextoren/gui/roles_icon/scp.png", roles = BREACH_ROLES.SCP },
    }

    local small_box_adjust = {
        ["SCP-096"] = { ang = Angle(0, 45, 0), pos = Vector(30, 30, -20), seq = "Wall Stand Boy" },
        ["SCP-966"] = { ang = Angle(0, -45, 0), pos = Vector(0, 30, -20) },
        ["SCP-682"] = { ang = Angle(0,75,0), pos = Vector(15,-25,-6), seq = "0_Stand_0" },
        ["SCP-082"] = { ang = Angle(0,75,0), pos = Vector(39,39,-32), seq = "idle_knife" },
        ["SCP-2012"] = { ang = Angle(0,0,0), pos = Vector(0,0,3) },
        ["SCP-811"] = { ang = Angle(0,0,0), pos = Vector(0,0,2) },
        ["SCP-973"] = { ang = Angle(0,0,0), pos = Vector(0,0,2) },
        ["SCP-638"] = { ang = Angle(0,0,0), pos = Vector(0,0,0) },
        ["SCP-999"] = { ang = Angle(0,95,0), pos = Vector(33,5,11) },
        ["SCP-062-FR"] = { ang = Angle(0,75,-5), pos = Vector(40,30,-20) },
        ["SCP-939"] = { ang = Angle(0,0,0), pos = Vector(5,37,-2) },
    }

    local function adjust_position(pn, model, rolename)
        pn._ang = Angle(0, 45, 0)
        pn._pos = Vector(0, 0, 0)
        pn.customseq = nil

        if model == "models/cultist/scp/scp_939.mdl" then
            pn._ang = Angle(0, 45, 0)
            pn._pos = Vector(-33, -33, 0)
            pn.customseq = "idle_knife"
        elseif model == "models/cultist/scp/scp_999_new.mdl" then
            pn._ang = Angle(0, 45, 0)
            pn._pos = Vector(-33, -33, 0)
            pn.customseq = "idle_knife"
        elseif model == "models/cultist/scp/scp_062fr_new.mdl" then
            pn._ang = Angle(0, 45, 0)
            pn._pos = Vector(-15, -15, 0)
            pn.customseq = "stand_idle_2"
        elseif model == "models/rainval_breach/1000shells/charachers/scp/082.mdl" then
            pn._ang = Angle(0, 45, 0)
            pn._pos = Vector(-24, -24, -6)
            pn.customseq = "idle_knife"
            pn.Entity:SetPlaybackRate(0.4)
        elseif model == "models/cultist/scp/scp_811.mdl" then
            pn.customseq = "811_Walk_01"
            pn.Entity:SetPlaybackRate(0.4)
        elseif model == "models/cultist/scp/scp_049.mdl" then
            pn.customseq = "0_049_idle"
        elseif model == "models/1000shells/scp966/scp_966.mdl" then
            pn.customseq = "idle2"
        elseif model == "models/cultist/scp/scp_106.mdl" then
            pn.customseq = "0_106_Idle_new"
        elseif model == "models/rainval_breach/1000shells/charachers/scp/096.mdl" then
            pn._ang = Angle(0, 45, 0)
            pn._pos = Vector(-5, -5, 0)
            pn.customseq = "Wall Stand Boy"
        elseif model == "models/cultist/scp/scp638/scp_638.mdl" then
            pn._ang = Angle(0, 45, 0)
            pn._pos = Vector(-5, -5, 0)
            pn.customseq = "idle_standing"
        elseif model == "models/cultist/scp/scp_682.mdl" then
            pn._ang = Angle(0, 35, 0)
            pn._pos = Vector(-65, -55, -10)
            pn.customseq = "0_Stand_0"
        elseif model == "models/cultist/humans/class_d/shaky/class_d_bor_new.mdl" then 
            pn.Entity:SetPlaybackRate(0.4)
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_UpperArm") or 0, Angle(7,5,0))
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm") or 0, Angle(-9,0,0))
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_ForeArm") or 0, Angle(9,0,0))
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_ForeArm") or 0, Angle(-5,0,0))
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_Thigh") or 0, Angle(5,0,0))
        elseif model == "models/cultist/humans/class_d/shaky/class_d_fat_new.mdl" then 
            pn.Entity:SetPlaybackRate(0.4)
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_UpperArm") or 0, Angle(7,0,0))
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm") or 0, Angle(-6,0,0))
            pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_Thigh") or 0, Angle(5,0,0))
        else
            pn.Entity:SetPlaybackRate(0.4)
            local rup = pn.Entity:LookupBone("ValveBiped.Bip01_R_UpperArm")
            if rup then
                pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_Hand") or 0, Angle(0,17,0))
                pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_R_Thigh") or 0, Angle(5,0,0))
                if model:find("class_d") or model:find("head_site") or model:find("sci") or model:find("secur") then
                    pn.Entity:ManipulateBoneAngles(rup, Angle(3,0,0))
                    if model:find("head_site") then
                        pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm") or 0, Angle(2,0,0))
                        pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_Hand") or 0, Angle(0,17,0))
                    else
                        pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm") or 0, Angle(-1,0,0))
                    end
                else
                    pn.Entity:ManipulateBoneAngles(rup, Angle(3,0,0))
                    pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm") or 0, Angle(-3,0,0))
                end
                if rolename == "GOC Juggernaut" then
                    pn.Entity:ManipulateBoneAngles(rup, Angle(8,0,0))
                    pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm") or 0, Angle(-6,0,0))
                end
                pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_Spine4") or 0, Angle(0,10,0))
                pn.Entity:ManipulateBoneAngles(pn.Entity:LookupBone("ValveBiped.Bip01_Spine1") or 0, Angle(0,-10,0))
            end
        end
    end

    local TopBarHeight = sh(70)
    local main_container = vgui.Create("DPanel", INTRO_PANEL)
    INTRO_PANEL.class_frame = main_container
    main_container:SetSize(scrw, scrh - TopBarHeight)
    main_container:SetPos(0, TopBarHeight)
    main_container:SetAlpha(0)
    main_container:AlphaTo(255, 0.3, 0)
    main_container.Paint = function(self, w, h)
        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(0, 0, w, 0)
    end

    local LeftCol = vgui.Create("DScrollPanel", main_container)
    LeftCol:SetSize(scrw * 0.35, main_container:GetTall())
    LeftCol:SetPos(0, 0)
    LeftCol:GetVBar():SetWide(0)
    LeftCol.Paint = function(self, w, h)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    local TitlePanel = vgui.Create("DPanel", LeftCol)
    TitlePanel:Dock(TOP)
    TitlePanel:SetTall(sh(80))
    TitlePanel.Paint = function(self, w, h)
        draw.DrawText(L("l:classmenu_factions"), "MM_BigNameB", sw(5), sh(30), color_white, TEXT_ALIGN_LEFT)
    end

    local CenterCol = vgui.Create("DPanel", main_container)
    CenterCol:SetSize(scrw * 0.30, main_container:GetTall())
    CenterCol:SetPos(scrw * 0.15, 0)
    
    local grad_down = Material("vgui/gradient-d")
    local grad_up = Material("vgui/gradient-u")

    CenterCol.Paint = function(self, w, h)
        surface.SetDrawColor(rust_dark)
        surface.DrawRect(0, 0, w, h)
        local yOffset = (CurTime() * 15) % sh(40)
        surface.SetDrawColor(255, 255, 255, 2)
        for x = 0, w, sw(40) do surface.DrawLine(x, 0, x, h) end
        for y = -sh(40), h, sh(40) do surface.DrawLine(0, y + yOffset, w, y + yOffset) end
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    CenterCol.Think = function(self)
        local w, h = self:GetSize()
        if IsValid(self.InfoOverlay) then self.InfoOverlay:SetSize(w, h) end
        if IsValid(self.BottomInfoScroll) then
            self.BottomInfoScroll:SetSize(w, h * 0.5)
            self.BottomInfoScroll:SetPos(0, h * 0.5)
        end
    end

    local preview_model = vgui.Create("DModelPanel", CenterCol)
    preview_model:Dock(FILL)
    preview_model:SetFOV(25)
    preview_model.yaw = 75
    preview_model.Pressed = false

    preview_model.Think = function(self)
        local w, h = self:GetSize()
        local ideal_w = ScrW() * 0.22 
        local extra_width = math.max(0, w - ideal_w) 
        
        local dist_scale = 1
        local cam_x = 10 * dist_scale
        local cam_y = 90 * dist_scale
        local cam_z = 35 + (extra_width * 0.01) 
        local look_z = 36 + (extra_width * 0.025) 
        
        self:SetCamPos(Vector(cam_x, cam_y, cam_z))
        self:SetLookAt(Vector(0, 0, look_z))
    end

    function preview_model:DragMousePress()
        self.PressX, self.PressY = input.GetCursorPos()
        self.Pressed = true
    end
    function preview_model:DragMouseRelease() self.Pressed = false end
    
    local char = preview_model
    char:SetDirectionalLight(BOX_TOP, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_FRONT, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_RIGHT, Color(160, 66, 66))
    char:SetDirectionalLight(BOX_LEFT, Color(0, 0, 0))
    
    preview_model.LayoutEntity = function(self, Entity)
        if self.Pressed then
            local mx, my = input.GetCursorPos()
            self.yaw = self.yaw + ((mx - (self.PressX or mx)) / 1.5)
            self.PressX, self.PressY = mx, my
        end
        
        local custom_pos = self._pos or Vector(0,0,0)
        Entity:SetPos(custom_pos)
        
        local custom_yaw = (self._ang and self._ang.y) or 0
        Entity:SetAngles(Angle(0, self.yaw + custom_yaw - 45, 0))
        
        if self.customseq then
            local seq = Entity:LookupSequence(self.customseq)
            if seq then Entity:SetSequence(seq) end
        else
            Entity:SetSequence(Entity:LookupSequence("lineidle02") or 0)
            self:RunAnimation()
        end
    end

    local InfoOverlay = vgui.Create("DPanel", CenterCol)
    CenterCol.InfoOverlay = InfoOverlay
    InfoOverlay:SetSize(CenterCol:GetSize())
    InfoOverlay.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 220)
        surface.SetMaterial(grad_down)
        surface.DrawTexturedRect(0, 0, w, h * 1)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.SetMaterial(grad_up)
        surface.DrawTexturedRect(0, h * 0.4, w, h * 0)
    end

    local lblTitle = vgui.Create("DLabel", InfoOverlay)
    lblTitle:SetPos(sw(20), sh(20))
    lblTitle:SetFont("MM_BigNameB")
    lblTitle:SetTextColor(rust_yellow)
    lblTitle:SetText(L("l:classmenu_choose_class"))
    lblTitle:SizeToContents()

    local lblLevel = vgui.Create("DLabel", InfoOverlay)
    lblLevel:SetPos(sw(20), sh(85))
    lblLevel:SetFont("MM_SmallName")
    lblLevel:SetTextColor(rust_dim)
    lblLevel:SetText(L("l:classmenu_classified"))
    lblLevel:SizeToContents()

    local BottomInfoScroll = vgui.Create("DScrollPanel", InfoOverlay)
    CenterCol.BottomInfoScroll = BottomInfoScroll
    BottomInfoScroll:SetSize(CenterCol:GetWide(), CenterCol:GetTall() * 0.5)
    BottomInfoScroll:SetPos(0, CenterCol:GetTall() * 0.5)
    BottomInfoScroll:GetVBar():SetWide(0)

    local lblTasksTitle = vgui.Create("DLabel", BottomInfoScroll)
    lblTasksTitle:SetPos(sw(20), 0)
    lblTasksTitle:SetFont("MM_Exp")
    lblTasksTitle:SetTextColor(rust_green)
    lblTasksTitle:SetText(L("l:classmenu_directives"))
    lblTasksTitle:SizeToContents()

    local lblTasks = vgui.Create("DLabel", BottomInfoScroll)
    lblTasks:SetPos(sw(20), sh(25))
    lblTasks:SetWide(CenterCol:GetWide() - sw(40))
    lblTasks:SetFont("MM_Exp")
    lblTasks:SetTextColor(color_white)
    lblTasks:SetText("")
    lblTasks:SetWrap(true)
    lblTasks:SetAutoStretchVertical(true)
    lblTasks.Think = function(s)
        if IsValid(CenterCol) then s:SetWide(CenterCol:GetWide() - sw(40)) end
    end

    local ActionContainer = vgui.Create("DPanel", BottomInfoScroll)
    ActionContainer:SetWide(CenterCol:GetWide())
    ActionContainer.Paint = function() end
    local lastLblTall = 0
    ActionContainer.Think = function(s)
        if IsValid(CenterCol) then s:SetWide(CenterCol:GetWide()) end
        if IsValid(lblTasks) and lblTasks:GetTall() ~= lastLblTall then
            lastLblTall = lblTasks:GetTall()
            s:SetPos(0, lblTasks:GetY() + lastLblTall + sh(20))
        end
    end

    local RightCol = vgui.Create("DPanel", main_container)
    RightCol:SetSize(scrw * 0.55, main_container:GetTall())
    RightCol:SetPos(scrw * 0.45, 0)
    RightCol.Paint = function() end

    local GridPanel = vgui.Create("DScrollPanel", RightCol)
    GridPanel:Dock(FILL)
    
    local g_sbar = GridPanel:GetVBar()
    g_sbar:SetWide(math.max(sw(8), 4))
    function g_sbar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 255) surface.DrawRect(0,0,w,h) end
    function g_sbar.btnUp:Paint() end
    function g_sbar.btnDown:Paint() end
    function g_sbar.btnGrip:Paint(w, h) surface.SetDrawColor(80, 80, 80, 255) surface.DrawRect(0,0,w,h) end

    local RolesGrid = vgui.Create("DPanel", GridPanel)
    RolesGrid:SetSize(RightCol:GetWide() - sw(20), 2000)
    RolesGrid.Paint = function() end

    local current_faction_index = 1
    local selected_class = nil
    local nodes_map = {} 

    local function CreateSquishButton(parent, text, x, y, w, h, colPrimary)
        local btn = vgui.Create("DButton", parent)
        btn:SetPos(x, y)
        btn:SetSize(w, h)
        btn:SetText("")
        btn.clickScale = 1
        btn.hoverLerp = 0
        
        btn.Paint = function(s, bw, bh)
            s.hoverLerp = math.Approach(s.hoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 12)
            if s:IsDown() then 
                s.clickScale = math.Approach(s.clickScale, 0.92, FrameTime() * 10)
            else 
                s.clickScale = math.Approach(s.clickScale, 1, FrameTime() * 8) 
            end

            local cW = bw * s.clickScale
            local cH = bh * s.clickScale
            local cX = (bw - cW)/2
            local cY = (bh - cH)/2

            local baseCol = Color(
                Lerp(s.hoverLerp, rust_panel.r, colPrimary.r),
                Lerp(s.hoverLerp, rust_panel.g, colPrimary.g),
                Lerp(s.hoverLerp, rust_panel.b, colPrimary.b)
            )

            surface.SetDrawColor(baseCol)
            surface.DrawRect(cX, cY, cW, cH)
            
            surface.SetDrawColor(colPrimary)
            surface.DrawOutlinedRect(cX, cY, cW, cH, 1)

            local txtCol = s:IsHovered() and rust_dark or colPrimary
            draw.DrawText(text, "MM_Exp", bw/2, bh/2 - sh(6), txtCol, TEXT_ALIGN_CENTER)
        end
        return btn
    end

    local function PopulateActionContainer(cls)
        ActionContainer:Clear()
        
        local dynY = 0
        local isLocked = not LocalPlayer():IsRoleUnlocked(cls.name)
        
        if isLocked then
            local canResearch = (cls.req == nil or LocalPlayer():IsRoleUnlocked(cls.req))
            if canResearch then
                if LocalPlayer():GetActiveResearch() ~= cls.name then
                    local btnRes = CreateSquishButton(ActionContainer, L("l:classmenu_start_research"), sw(20), dynY, sw(220), sh(35), rust_yellow)
                    btnRes.Think = function(s) if IsValid(ActionContainer) then s:SetWide(ActionContainer:GetWide() - sw(40)) end end
                    btnRes.DoClick = function(s)
                        if (s.NextClick or 0) > CurTime() then return end
                        s.NextClick = CurTime() + 0.5
                    
                        net.Start("WTh_SetResearch") net.WriteString(cls.name) net.SendToServer()
                        timer.Simple(0.3, function() if selected_class == cls then PopulateActionContainer(cls) end end)
                        net.Start("WTh_RequestSync")
                        net.SendToServer()
                    end
                    dynY = dynY + sh(45)
                end
                
                local cost = cls.cost or 0
                local invested = LocalPlayer():GetRoleInvestedEXP(cls.name)
                local needed = cost - invested
                local freeExp = LocalPlayer():GetFreeEXP()

                if freeExp > 0 and needed > 0 then
                    local toInvest = math.min(freeExp, needed)
                    local btnFree = CreateSquishButton(ActionContainer, L("l:classmenu_invest_exp") .. " (" .. toInvest .. ")", sw(20), dynY, sw(220), sh(35), Color(100,200,255))
                    btnFree.Think = function(s) if IsValid(ActionContainer) then s:SetWide(ActionContainer:GetWide() - sw(40)) end end
                    btnFree.DoClick = function(s)
                        if (s.NextClick or 0) > CurTime() then return end
                        s.NextClick = CurTime() + 0.15
                    
                        net.Start("WTh_BuyWithFreeEXP") net.WriteString(cls.name) net.WriteInt(toInvest, 32) net.SendToServer()
                        timer.Simple(0.3, function() if selected_class == cls then PopulateActionContainer(cls) end end)
                    end
                    dynY = dynY + sh(45)
                end
            end
        else
            local isDefault = (cls.cost == nil or cls.cost <= 0)
            if not isDefault then
                local btnBL = CreateSquishButton(ActionContainer, "", sw(20), dynY, sw(220), sh(30), rust_red)
                btnBL.Think = function(s) 
                    if IsValid(ActionContainer) then s:SetWide(ActionContainer:GetWide() - sw(40)) end 
                    
                    local bl = LocalPlayer():GetBlacklistedRoles()
                    local isBlacklisted = bl[cls.name] == true
                    
                    s.DynText = isBlacklisted and L("l:classmenu_remove_blacklist") or L("l:classmenu_add_blacklist")
                    s.DynColor = isBlacklisted and Color(150, 150, 150) or rust_red
                end
                btnBL.Paint = function(s, bw, bh)
                    s.hoverLerp = math.Approach(s.hoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 12)
                    if s:IsDown() then 
                        s.clickScale = math.Approach(s.clickScale, 0.92, FrameTime() * 10)
                    else 
                        s.clickScale = math.Approach(s.clickScale, 1, FrameTime() * 8) 
                    end

                    local cW = bw * s.clickScale
                    local cH = bh * s.clickScale
                    local cX = (bw - cW)/2
                    local cY = (bh - cH)/2

                    local colPrimary = s.DynColor or rust_red
                    local baseCol = Color(
                        Lerp(s.hoverLerp, rust_panel.r, colPrimary.r),
                        Lerp(s.hoverLerp, rust_panel.g, colPrimary.g),
                        Lerp(s.hoverLerp, rust_panel.b, colPrimary.b)
                    )

                    surface.SetDrawColor(baseCol)
                    surface.DrawRect(cX, cY, cW, cH)
                    
                    surface.SetDrawColor(colPrimary)
                    surface.DrawOutlinedRect(cX, cY, cW, cH, 1)

                    local txtCol = s:IsHovered() and rust_dark or colPrimary
                    draw.DrawText(s.DynText or "", "MM_Exp", bw/2, bh/2 - sh(6), txtCol, TEXT_ALIGN_CENTER)
                end
                btnBL.DoClick = function()
                    net.Start("WTh_ToggleBlacklist")
                    net.WriteString(cls.name)
                    net.SendToServer()
                    
                    LocalPlayer().WTh_BlacklistCache = LocalPlayer().WTh_BlacklistCache or {}
                    if LocalPlayer().WTh_BlacklistCache[cls.name] then
                        LocalPlayer().WTh_BlacklistCache[cls.name] = nil
                    else
                        local count = 0
                        for k,v in pairs(LocalPlayer().WTh_BlacklistCache) do if v then count = count + 1 end end
                        if count < 2 then LocalPlayer().WTh_BlacklistCache[cls.name] = true end
                    end
                end
                dynY = dynY + sh(40)
            end

            if cls.upgrades then
                local lblMod = vgui.Create("DLabel", ActionContainer)
                lblMod:SetPos(sw(20), dynY)
                lblMod:SetFont("MM_Exp")
                lblMod:SetTextColor(rust_yellow)
                lblMod:SetText(L("l:classmenu_upgrades"))
                lblMod:SizeToContents()
                dynY = dynY + sh(30)

                for upg_id, upg in pairs(cls.upgrades) do
                    local isUpgUnlocked = LocalPlayer():IsUpgradeUnlocked(cls.name, upg_id)
                    local actRole, actUpg = LocalPlayer():GetActiveUpgradeResearch()
                    local isUpgResearching = (actRole == cls.name and actUpg == upg_id)
                    local canUpgResearch = (upg.req == nil or LocalPlayer():IsUpgradeUnlocked(cls.name, upg.req))

                    local upgHeight = (not isUpgUnlocked and canUpgResearch) and sh(80) or sh(60)

                    local upgPnl = vgui.Create("DPanel", ActionContainer)
                    upgPnl:SetPos(sw(20), dynY)
                    upgPnl:SetSize(ActionContainer:GetWide() - sw(40), upgHeight)
                    upgPnl.visExp = LocalPlayer():GetUpgradeInvestedEXP(cls.name, upg_id)
                    
                    upgPnl.Think = function(s) if IsValid(ActionContainer) then s:SetWide(ActionContainer:GetWide() - sw(40)) end end

                    upgPnl.Paint = function(s, w, h)
                        local curUnlocked = LocalPlayer():IsUpgradeUnlocked(cls.name, upg_id)
                        local curInvested = LocalPlayer():GetUpgradeInvestedEXP(cls.name, upg_id)
                        local cR, cU = LocalPlayer():GetActiveUpgradeResearch()
                        local curResearching = (cR == cls.name and cU == upg_id)

                        s.visExp = Lerp(FrameTime() * 5, s.visExp, curInvested)

                        if curUnlocked then
                            surface.SetDrawColor(rust_green.r, rust_green.g, rust_green.b, 20)
                            surface.DrawRect(0, 0, w, h)
                        else
                            surface.SetDrawColor(rust_panel)
                            surface.DrawRect(0, 0, w, h)
                        end
                        
                        local barColor = curUnlocked and rust_green or (curResearching and rust_yellow or rust_red)
                        surface.SetDrawColor(barColor)
                        surface.DrawRect(0, 0, sw(4), h)
                        
                        surface.SetDrawColor(rust_outline)
                        surface.DrawOutlinedRect(0, 0, w, h)
                        
                        draw.DrawText(upg.name, "MM_Exp", sw(15), sh(5), color_white, TEXT_ALIGN_LEFT)
                        draw.DrawText(upg.desc or "", "MM_SmallName", sw(15), sh(25), rust_dim, TEXT_ALIGN_LEFT)

                        if not curUnlocked then
                            local maxCost = math.max(upg.cost, 1)
                            local pct = math.Clamp(s.visExp / maxCost, 0, 1)
                            
                            local barWidth = w - sw(165)
                            if barWidth > sw(140) then barWidth = sw(140) end

                            surface.SetDrawColor(0, 0, 0, 150)
                            surface.DrawRect(sw(15), upgHeight - sh(12), barWidth, sh(6))
                            surface.SetDrawColor(rust_yellow)
                            surface.DrawRect(sw(15), upgHeight - sh(12), barWidth * pct, sh(6))
                            draw.DrawText(math.floor(s.visExp) .. " / " .. upg.cost, "MM_SmallName", sw(15) + barWidth + sw(10), upgHeight - sh(15), color_white, TEXT_ALIGN_LEFT)
                        else
                            draw.DrawText(L("l:classmenu_researched"), "MM_SmallName", sw(15), sh(40), rust_green, TEXT_ALIGN_LEFT)
                        end
                    end

                    if not isUpgUnlocked and canUpgResearch then
                        if not isUpgResearching then
                            local btnUpgRes = CreateSquishButton(upgPnl, L("l:classmenu_research"), upgPnl:GetWide() - sw(130), sh(5), sw(120), sh(30), rust_yellow)
                            btnUpgRes.Think = function(s) s:SetPos(upgPnl:GetWide() - sw(130), sh(5)) end
                            btnUpgRes.DoClick = function()
                                net.Start("WTh_SetUpgradeResearch")
                                net.WriteString(cls.name)
                                net.WriteString(upg_id)
                                net.SendToServer()
                                timer.Simple(0.3, function() if selected_class == cls then PopulateActionContainer(cls) end end)
                            end
                        end

                        local upgInvested = LocalPlayer():GetUpgradeInvestedEXP(cls.name, upg_id)
                        local upgNeeded = upg.cost - upgInvested
                        local freeExp = LocalPlayer():GetFreeEXP()
                        
                        if freeExp > 0 and upgNeeded > 0 then
                            local toInvest = math.min(freeExp, upgNeeded)
                            local btnUpgFree = CreateSquishButton(upgPnl, L("l:classmenu_exp") .. " (" .. toInvest .. ")", upgPnl:GetWide() - sw(130), sh(40), sw(120), sh(30), Color(100,200,255))
                            btnUpgFree.Think = function(s) s:SetPos(upgPnl:GetWide() - sw(130), sh(40)) end
                            btnUpgFree.DoClick = function()
                                net.Start("WTh_BuyUpgradeWithFreeEXP")
                                net.WriteString(cls.name)
                                net.WriteString(upg_id)
                                net.WriteInt(toInvest, 32)
                                net.SendToServer()
                                timer.Simple(0.3, function() if selected_class == cls then PopulateActionContainer(cls) end end)
                            end
                        end
                    end

                    dynY = dynY + upgHeight + sh(10)
                end
            end
        end
        ActionContainer:SetTall(dynY + sh(20))
    end

    main_container.RefreshActionContainer = function()
        if selected_class then
            PopulateActionContainer(selected_class)
        end
    end

    lblLevel.Think = function(s)
        if not selected_class then return end
        local isLocked = not LocalPlayer():IsRoleUnlocked(selected_class.name)
        if isLocked then
            local cost = selected_class.cost or 0
            local node = nodes_map[selected_class.name]
            local visExp = node and math.floor(node.visExp) or LocalPlayer():GetRoleInvestedEXP(selected_class.name)
            
            s:SetText(L("l:classmenu_req_exp") .. " " .. visExp .. " / " .. cost)
            s:SetTextColor(rust_red)
        else
            s:SetText(L("l:classmenu_access_granted"))
            s:SetTextColor(rust_green)
        end
        s:SizeToContents()
    end

    local function CreateClassesPanel(faction_data)
        RolesGrid:Clear()
        ActionContainer:Clear()
        selected_class = nil
        nodes_map = {}
        lblTasks:SetText("")

        if IsValid(GridPanel:GetVBar()) then GridPanel:GetVBar():SetScroll(0) end

        if not faction_data.roles or type(faction_data.roles) ~= "table" then 
            local no_roles = vgui.Create("DLabel", RolesGrid)
            no_roles:SetText(L("l:classmenu_no_roles"))
            no_roles:SetFont("MM_BigName")
            no_roles:SetTextColor(rust_dim)
            no_roles:SizeToContents()
            no_roles:SetPos(sw(40), sh(40))
            return 
        end

        local cardW, cardH = sw(160), sh(210)
        local spacingX, spacingY = sw(60), sh(70) 
        local offsetX, offsetY = sw(60), sh(60)
        local max_x_pos = 1
        local max_y_pos = 0

        for category_name, category in pairs(faction_data.roles) do
            if type(category) == "table" and type(category.roles) == "table" then
                for _, cls in ipairs(category.roles) do
                    if cls["level"] and cls["level"] > 500 then continue end
                    if cls.model == 'models/imperator/humans/crb/rb.mdl' then continue end
                    
                    local tx = cls.tree_x or 1
                    local ty = cls.tree_y or 1
                    local py = offsetY + (ty - 1) * (cardH + spacingY)
                    
                    if tx > max_x_pos then max_x_pos = tx end
                    if py > max_y_pos then max_y_pos = py end
                end
            end
        end

        local right_needed_w = offsetX + (max_x_pos * cardW) + ((max_x_pos - 1) * spacingX) + offsetX
        local available_w = scrw * 0.85
        local min_center_w = scrw * 0.22
        
        right_needed_w = math.Clamp(right_needed_w, scrw * 0.25, available_w - min_center_w)
        local center_needed_w = available_w - right_needed_w

        RightCol:SizeTo(right_needed_w, main_container:GetTall(), 0.3, 0, -1)
        RightCol:MoveTo(scrw - right_needed_w, 0, 0.3, 0, -1)
        CenterCol:SizeTo(center_needed_w, main_container:GetTall(), 0.3, 0, -1)
        RolesGrid:SetSize(right_needed_w - sw(20), max_y_pos + cardH + sh(100))

        for category_name, category in pairs(faction_data.roles) do
            if type(category) == "table" and type(category.roles) == "table" then
                for _, cls in ipairs(category.roles) do
                    if cls["level"] and cls["level"] > 500 then continue end
                    if cls.model == 'models/imperator/humans/crb/rb.mdl' then continue end

                    local tx = cls.tree_x or 1
                    local ty = cls.tree_y or 1
                    local px = offsetX + (tx - 1) * (cardW + spacingX)
                    local py = offsetY + (ty - 1) * (cardH + spacingY)

                    local teamColor = gteams.GetColor(cls["team"])
                    if cls["team"] == TEAM_SCP then teamColor = cls["major"] and Color(255, 58, 58) or Color(241, 170, 88) end

                    nodes_map[cls.name] = { 
                        x = px, y = py, 
                        cls = cls, 
                        visExp = LocalPlayer():GetRoleInvestedEXP(cls.name),
                        teamColor = teamColor,
                    }
                end
            end
        end

        RolesGrid.Paint = function(self, w, h)
            local pulse = (math.sin(CurTime() * 5) + 1) / 2
            local flowOffset = (CurTime() * 50) % sw(20)

            for name, data in pairs(nodes_map) do
                local req = data.cls.req
                if req and nodes_map[req] then
                    local parent = nodes_map[req]
                    local child = data
                    
                    local startX = parent.x + cardW / 2
                    local startY = parent.y + cardH
                    local endX = child.x + cardW / 2
                    local endY = child.y
                    local midY = startY + (endY - startY) / 2

                    local isPathLocked = not LocalPlayer():IsRoleUnlocked(parent.cls.name)
                    local baseColor = isPathLocked and Color(30, 30, 30) or parent.teamColor
                    
                    surface.SetDrawColor(20, 20, 20, 255)
                    local th_bg = sw(8)
                    surface.DrawRect(startX - th_bg/2, startY, th_bg, midY - startY)
                    if startX < endX then
                        surface.DrawRect(startX - th_bg/2, midY - th_bg/2, (endX - startX) + th_bg, th_bg)
                    elseif startX > endX then
                        surface.DrawRect(endX - th_bg/2, midY - th_bg/2, (startX - endX) + th_bg, th_bg)
                    end
                    surface.DrawRect(endX - th_bg/2, midY, th_bg, endY - midY)

                    local coreAlpha = isPathLocked and 100 or (155 + 100 * pulse)
                    local th_core = isPathLocked and sw(2) or sw(4)
                    surface.SetDrawColor(baseColor.r, baseColor.g, baseColor.b, coreAlpha)
                    
                    surface.DrawRect(startX - th_core/2, startY, th_core, midY - startY)
                    if startX < endX then
                        surface.DrawRect(startX - th_core/2, midY - th_core/2, (endX - startX) + th_core, th_core)
                    elseif startX > endX then
                        surface.DrawRect(endX - th_core/2, midY - th_core/2, (startX - endX) + th_core, th_core)
                    end
                    surface.DrawRect(endX - th_core/2, midY, th_core, endY - midY)

                    if not isPathLocked then
                        surface.SetDrawColor(255, 255, 255, 150)
                        
                        for py = startY + flowOffset, midY - 1, sh(20) do
                            surface.DrawRect(startX - sw(1), py, sw(2), sh(4))
                        end
                        
                        if startX < endX then
                            for px = startX + flowOffset, endX - 1, sw(20) do
                                surface.DrawRect(px, midY - sh(1), sw(4), sh(2))
                            end
                        elseif startX > endX then
                            for px = startX - flowOffset, endX + 1, -sw(20) do
                                surface.DrawRect(px, midY - sh(1), sw(4), sh(2))
                            end
                        end
                        
                        for py = midY + flowOffset, endY - 1, sh(20) do
                            surface.DrawRect(endX - sw(1), py, sw(2), sh(4))
                        end
                    end

                    surface.SetDrawColor(20, 20, 20, 255)
                    surface.DrawRect(startX - sw(6), startY - sh(2), sw(12), sh(12))
                    surface.DrawRect(endX - sw(6), endY - sh(10), sw(12), sh(12))

                    surface.SetDrawColor(baseColor.r, baseColor.g, baseColor.b, coreAlpha)
                    surface.DrawRect(startX - sw(3), startY + sh(1), sw(6), sh(6))
                    surface.DrawRect(endX - sw(3), endY - sh(7), sw(6), sh(6))
                end
            end
        end

        local eye_offset = Vector(2, 0, 2)
        local pos_offset = Vector(-13, 0, 0)

        for name, data in pairs(nodes_map) do
            local cls = data.cls
            local teamColor = data.teamColor

            local isblack = math.random(1,3) == 1
            if cls.name == "CI Spy" then
                local values = BREACH.ChaosSpy_CanBe or {}
                local val = values[math.random(1, #values)]
                local tab
                for i, v in pairs(BREACH_ROLES.SECURITY.security.roles) do 
                    if v.name == val then tab = v end 
                end
                if tab then
                    cls.weapons = tab.weapons
                    cls.headgear = tab.headgear
                    cls.head = tab.head
                    for i = 0, 20 do cls["bodygroup"..i] = tab["bodygroup"..i] end
                end
            end
            if cls["white"] then isblack = false end

            local headtext = PickFaceSkin and PickFaceSkin(isblack) or ""
            local HeadModel = istable(cls["head"]) and table.Random(cls["head"]) or cls["head"]
            if cls["usehead"] then
                if cls["randomizehead"] and PickHeadModel then HeadModel = PickHeadModel()
                else HeadModel = "models/cultist/heads/male/male_head_1.mdl" end
            end
            
            local HairModel = nil
            if math.random(1, 5) > 1 then
                if isblack and cls["blackhairm"] then HairModel = cls["blackhairm"][math.random(1, #cls["blackhairm"])]
                elseif cls["hairm"] then HairModel = cls["hairm"][math.random(1, #cls["hairm"])] end
            end

            local CardBtn = vgui.Create("DButton", RolesGrid)
            CardBtn:SetSize(cardW, cardH)
            CardBtn:SetPos(data.x, data.y)
            CardBtn:SetText("")
            CardBtn.hoverLerp = 0
            CardBtn.shineOffset = -cardW

            local infoH = sh(60)
            
            local face_model = vgui.Create("DModelPanel", CardBtn)
            face_model:SetSize(cardW, cardH - infoH)
            face_model:SetPos(0, 0)
            face_model:SetMouseInputEnabled(false)
            face_model:SetModel(cls["model"] or "models/player/Group01/male_01.mdl")
            face_model.LayoutEntity = function() end 
            
            local h_color = ColorToHSV(teamColor)
            face_model:SetDirectionalLight(BOX_FRONT, HSVToColor(h_color, 0.4, 1))
            face_model:SetDirectionalLight(BOX_TOP, Color(40, 40, 40))
            
            local anim_origbones = {}
            local anim_savepos, anim_saveang
            local aimang = Angle(-5, 5, 0)
            local aimpos = Vector(-5, 0.3, 1)

            face_model.Think = function(self)
                local ent = self.Entity
                if IsValid(ent) and not self.Initialized then
                    self.Initialized = true
                    
                    local head = ent:LookupBone("ValveBiped.Bip01_Head1")
                    if small_box_adjust[cls["name"]] and small_box_adjust[cls["name"]].seq then 
                        ent:ResetSequence(ent:LookupSequence(small_box_adjust[cls["name"]].seq)) 
                    end
                    if cls["name"] == "SCP-638" then ent:ManipulateBoneAngles(9, Angle(15,0,80)) end
                    
                    if head and cls["name"] ~= SCP106 then
                        local eyepos = ent:GetBonePosition(head)
                        eyepos:Add(eye_offset)
                        self:SetLookAt(eyepos)
                        self:SetFOV(40)
                        
                        ent:SetAngles(Angle(-5, math.Rand(25, 35), 0))
                        ent:SetPos(Vector(-5, math.Rand(2.5, 3), math.Rand(-0.25, 0.25)))
                        ent:ManipulateBoneAngles(head, Angle(math.Rand(-2, -7), 5, math.Rand(-20, -10)))
                        if cls["name"] == "UIU Clocker" then ent:ManipulateBoneAngles(head, Angle(math.Rand(-2, -7), -7, math.Rand(10, 15))) end

                        if cls["team"] ~= TEAM_SCP then
                            local l1, l2 = 10, -10
                            if math.random(0,1) == 1 then l1 = l2; l2 = 10 end
                            local lClav = ent:LookupBone("ValveBiped.Bip01_L_Clavicle")
                            local rClav = ent:LookupBone("ValveBiped.Bip01_R_Clavicle")
                            if lClav then ent:ManipulateBoneAngles(lClav, Angle(math.Rand(-10,10), math.Rand(0, l1), 0)) end
                            if rClav then ent:ManipulateBoneAngles(rClav, Angle(math.Rand(-10,10), math.Rand(0, l2), 0)) end
                        end
                        self:SetCamPos(eyepos - pos_offset)
                        ent:SetEyeTarget(eyepos - pos_offset)
                    end

                    if cls["skin"] then ent:SetSkin(cls["skin"]) end
                    if isblack and ent:GetModel():find("class_d") then ent:SetSkin(1) end
                    for i = 0, 20 do if cls["bodygroup"..i] then ent:SetBodygroup(i, cls["bodygroup"..i]) end end
                    
                    if cls["head"] ~= nil or cls["usehead"] then
                        if HeadModel and (HeadModel:find("male_head") or HeadModel:find("balaclava")) then 
                            self:BoneMerged(HeadModel, headtext)
                        elseif HeadModel then 
                            self:BoneMerged(HeadModel) 
                        end
                    end
                    if HairModel then self:BoneMerged(HairModel) end
                    if cls["headgear"] then self:BoneMerged(cls["headgear"]) end
                    if cls["hackerhat"] then self:BoneMerged(cls["hackerhat"]) end
                end
                
                if IsValid(ent) and self.Initialized then
                    local curLocked = not LocalPlayer():IsRoleUnlocked(cls.name)
                    if curLocked then
                        ent:SetMaterial("lights/white001")
                        ent:SetColor(color_black)
                        if ent.BoneMergedEnts then
                            for _, merged in pairs(ent.BoneMergedEnts) do
                                if IsValid(merged) then 
                                    merged:SetMaterial("lights/white001")
                                    merged:SetColor(color_black) 
                                end
                            end
                        end
                    else
                        ent:SetMaterial("")
                        ent:SetColor(color_white)
                        if ent.BoneMergedEnts then
                            for _, merged in pairs(ent.BoneMergedEnts) do
                                if IsValid(merged) then 
                                    merged:SetMaterial("")
                                    merged:SetColor(color_white) 
                                end
                            end
                        end
                    end
                end
            end

            CardBtn.Think = function(self)
                self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
                if self:IsHovered() then
                    self.shineOffset = self.shineOffset + FrameTime() * 300
                    if self.shineOffset > cardW * 2 then self.shineOffset = -cardW end
                else
                    self.shineOffset = -cardW
                end
                data.visExp = Lerp(FrameTime() * 5, data.visExp, LocalPlayer():GetRoleInvestedEXP(cls.name))
            end

            CardBtn.Paint = function(self, w, h)
                local pop = math.max(1, sw(2)) * self.hoverLerp
                local curLocked = not LocalPlayer():IsRoleUnlocked(cls.name)

                draw.RoundedBox(0, -pop, -pop, w + pop*2, h + pop*2, rust_card)
                
                if self.hoverLerp > 0 then
                    local hovCol = selected_class == cls and rust_yellow or teamColor
                    draw.RoundedBox(0, -pop, -pop, w + pop*2, h + pop*2, ColorAlpha(hovCol, 15 * self.hoverLerp))
                end

                local topColor = curLocked and Color(60,60,60) or teamColor
                draw.RoundedBox(0, -pop, -pop, sw(4) + pop, h + pop*2, topColor)
            end

            CardBtn.PaintOver = function(self, w, h)
                local pop = math.max(1, sw(2)) * self.hoverLerp
                local ent = face_model.Entity
                local curLocked = not LocalPlayer():IsRoleUnlocked(cls.name)

                if cls["team"] ~= TEAM_SCP and not curLocked and IsValid(ent) then
                    if not anim_saveang or not anim_savepos then
                        anim_saveang = ent:GetAngles()
                        anim_savepos = ent:GetPos()
                        for i = 0, ent:GetBoneCount() - 1 do
                            local ang = ent:GetManipulateBoneAngles(i)
                            if ang ~= angle_zero then anim_origbones[i] = ang end
                        end
                    end

                    local target_aimang = aimang or Angle(-5, 5, 0)
                    local target_aimpos = aimpos or Vector(-5, 0.3, 1)

                    if self:IsHovered() then
                        ent:SetAngles(LerpAngle(math.min(0.5, FrameTime()*20), ent:GetAngles(), target_aimang))
                        ent:SetPos(LerpVector(math.min(0.5, FrameTime()*13), ent:GetPos(), target_aimpos))
                        for i, _ in pairs(anim_origbones) do
                            ent:ManipulateBoneAngles(i, LerpAngle(math.min(0.5, FrameTime()*10), ent:GetManipulateBoneAngles(i), angle_zero))
                        end
                    else
                        ent:SetAngles(LerpAngle(math.min(0.5, FrameTime()*15), ent:GetAngles(), anim_saveang or angle_zero))
                        ent:SetPos(LerpVector(math.min(0.5, FrameTime()*8), ent:GetPos(), anim_savepos or vector_origin))
                        for i, orig_ang in pairs(anim_origbones) do
                            ent:ManipulateBoneAngles(i, LerpAngle(math.min(0.5, FrameTime()*8), ent:GetManipulateBoneAngles(i), orig_ang))
                        end
                    end
                end

                if curLocked then
                    DrawHazardStripes(w, h - infoH, 180)

                    local isResearching = (LocalPlayer():GetActiveResearch() == cls.name)
                    local canResearch = (cls.req == nil or LocalPlayer():IsRoleUnlocked(cls.req))
                
                    if isResearching then
                        surface.SetDrawColor(0, 0, 0, 255)
                        surface.DrawRect(0, (h - infoH)/2 - sh(15), w, sh(40))
                        draw.DrawText(L("l:classmenu_researching"), "MM_SmallName", w/2, (h - infoH)/2 - sh(10), rust_yellow, TEXT_ALIGN_CENTER)
                        
                        local pct = math.Clamp(data.visExp / math.max(cls.cost or 1, 1), 0, 1)
                        surface.SetDrawColor(143, 143, 143)
                        surface.DrawRect(sw(15), (h - infoH)/2 + sh(8), w - sw(30), sh(4))
                        surface.SetDrawColor(rust_yellow)
                        surface.DrawRect(sw(15), (h - infoH)/2 + sh(8), (w - sw(30)) * pct, sh(4))
                        
                        if pct > 0 and pct < 1 then
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.DrawRect(sw(15) + (w - sw(30)) * pct - sw(2), (h - infoH)/2 + sh(6), sw(4), sh(8))
                        end
                    elseif canResearch then
                        surface.SetDrawColor(0, 0, 0, 255)
                        surface.DrawRect(0, (h - infoH)/2 - sh(10), w, sh(20))
                        draw.DrawText(L("l:classmenu_available"), "MM_SmallName", w/2, (h - infoH)/2 - sh(5), rust_green, TEXT_ALIGN_CENTER)
                    else
                        surface.SetDrawColor(0, 0, 0, 255)
                        surface.DrawRect(0, (h - infoH)/2 - sh(10), w, sh(20))
                        draw.DrawText(L("l:classmenu_locked"), "MM_SmallName", w/2, (h - infoH)/2 - sh(5), rust_red, TEXT_ALIGN_CENTER)
                    end
                end

                surface.SetDrawColor(rust_card_btm)
                surface.DrawRect(sw(4) - pop, h - infoH, w - sw(4) + pop*2, infoH + pop)
                
                local lineCol = curLocked and Color(60,60,60) or teamColor
                surface.SetDrawColor(lineCol)
                surface.DrawRect(sw(4) - pop, h - infoH, w - sw(4) + pop*2, sh(2))

                local titleName = cls["team"] == TEAM_SCP and string.upper(cls.name) or string.upper(GetLangRole(cls.name) or cls.name)
                draw.DrawText(titleName, "MM_Exp", sw(14), h - infoH + sh(12), curLocked and rust_dim or color_white, TEXT_ALIGN_LEFT)
                
                local statusTxt = curLocked and L("l:classmenu_req_access") or L("l:classmenu_available")
                local statusCol = curLocked and rust_red or rust_green
                draw.DrawText(statusTxt, "MM_SmallName", sw(14), h - sh(20), statusCol, TEXT_ALIGN_LEFT)

                if selected_class == cls then
                    DrawTechCorners(-pop, -pop, w + pop*2, h + pop*2, rust_yellow, sw(15), sw(3))
                    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 50)
                    surface.DrawOutlinedRect(-pop, -pop, w + pop*2, h + pop*2, 1)
                else
                    surface.SetDrawColor(rust_outline)
                    surface.DrawOutlinedRect(-pop, -pop, w + pop*2, h + pop*2, 1)
                end
            end

            CardBtn.DoClick = function()
                if selected_class == cls then return end
                selected_class = cls
                
                InfoOverlay:SetAlpha(0)
                InfoOverlay:AlphaTo(255, 0.4, 0)
                InfoOverlay:SetPos(0, sh(20))
                InfoOverlay:MoveTo(0, 0, 0.3, 0, 0.5)

                local titleName = cls["team"] == TEAM_SCP and string.upper(cls.name) or string.upper(GetLangRole(cls.name) or cls.name)
                lblTitle:SetText(titleName)
                lblTitle:SizeToContents()

                lblTasks:SetText(cls.tasks and L(cls.tasks) or L("l:classmenu_classified"))
                lblTasks:SizeToContents()

                preview_model:SetModel(cls["model"])
                adjust_position(preview_model, cls["model"], cls["name"])
                
                local pm_ent = preview_model.Entity
                if IsValid(pm_ent) then
                    if preview_model.BoneMergedEnts then
                        for _, v in pairs(preview_model.BoneMergedEnts) do
                            if IsValid(v) then v:Remove() end
                        end
                        preview_model.BoneMergedEnts = nil
                    end

                    if cls["skin"] then pm_ent:SetSkin(cls["skin"]) end
                    if isblack and pm_ent:GetModel():find("class_d") then pm_ent:SetSkin(1) end
                    for i = 0, 20 do if cls["bodygroup"..i] then pm_ent:SetBodygroup(i, cls["bodygroup"..i]) end end
                    
                    if cls.random_accessories then
                        for i = 0, 15 do
                            if cls.random_accessories["bodygroup"..i] then 
                                pm_ent:SetBodygroup(i, math.random(cls.random_accessories["bodygroup"..i][1], cls.random_accessories["bodygroup"..i][2])) 
                            end
                        end
                    end
                    
                    if cls["head"] ~= nil or cls["usehead"] then
                        if HeadModel and (HeadModel:find("male_head") or HeadModel:find("balaclava")) then 
                            preview_model:BoneMerged(HeadModel, headtext)
                        elseif HeadModel then 
                            preview_model:BoneMerged(HeadModel) 
                        end
                    end
                    if HairModel then preview_model:BoneMerged(HairModel) end
                    if cls["headgear"] then preview_model:BoneMerged(cls["headgear"]) end
                    if cls["hackerhat"] then preview_model:BoneMerged(cls["hackerhat"]) end
                end

                PopulateActionContainer(cls)
            end
            CardBtn.OnCursorEntered = function() 
                if not LocalPlayer():IsRoleUnlocked(cls.name) then end 
            end
        end
    end

    for i, faction_data in ipairs(faction_table) do
        local fac_btn = vgui.Create("DButton", LeftCol)
        fac_btn:Dock(TOP)
        fac_btn:SetTall(sh(50))
        fac_btn:SetText("")
        fac_btn.hoverLerp = 0
        
        fac_btn.Paint = function(self, w, h)
            local is_active = (current_faction_index == i)
            self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
            
            if is_active then
                surface.SetDrawColor(rust_card)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(rust_green)
                surface.DrawRect(0, 0, sw(4), h)
            else
                surface.SetDrawColor(14, 13, 12, 255)
                surface.DrawRect(0, 0, w, h)
                if self.hoverLerp > 0 then
                    surface.SetDrawColor(255, 255, 255, 5 * self.hoverLerp)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * self.hoverLerp)
                    surface.DrawRect(0, 0, sw(2), h)
                end
            end

            local icon_mat = Material(faction_data.icon, "smooth")
            surface.SetDrawColor(255, 255, 255, (is_active or self:IsHovered()) and 255 or 80)
            surface.SetMaterial(icon_mat)
            surface.DrawTexturedRect(sw(15), h/2 - sh(12), sh(24), sh(24))

            local text_color = is_active and color_white or (self:IsHovered() and rust_text or rust_dim)
            local textOffset = Lerp(self.hoverLerp, sw(50), sw(55))
            if is_active then textOffset = sw(55) end
            
            draw.DrawText(string.upper(faction_data.name), "MM_Exp", textOffset, h/2 - sh(6), text_color, TEXT_ALIGN_LEFT)
            surface.SetDrawColor(rust_outline)
            surface.DrawLine(0, h-1, w, h-1)
        end
        
        fac_btn.DoClick = function()
            current_faction_index = i
            
            GridPanel:SetAlpha(0)
            GridPanel:AlphaTo(255, 0.3)
            GridPanel:SetPos(0, sh(20))
            GridPanel:MoveTo(0, 0, 0.3, 0, 0.5)

            CreateClassesPanel(faction_data)
        end
        fac_btn.OnCursorEntered = function() surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end
    end

    if #faction_table > 0 then
        current_faction_index = 1
        CreateClassesPanel(faction_table[1])
    end
end


function OpenDonateMenu()
  local scrw, scrh = ScrW(), ScrH()
  
  local function AnimateButtonPress(btn)
      if not IsValid(btn) then return end
      
      local origX, origY = btn:GetPos()
      local origW, origH = btn:GetSize()
      
      btn:SetPos(origX, origY + scrh * 0.00185) 
      btn:SetSize(origW, origH - scrh * 0.00185) 
      
      timer.Simple(0.1, function()
          if IsValid(btn) then
              btn:SetPos(origX, origY)
              btn:SetSize(origW, origH)
          end
      end)
  end

  if IsValid(INTRO_PANEL.settings_frame) then
    INTRO_PANEL.settings_frame:Remove()
    INTRO_PANEL.settings_frame = nil
    return
  end

  local tbl_italia_brainrot = {
      "рублей", "рублей", "рублей", "рублей", "рублей", 
      "рублей", "рублей", "рублей", "рублей", "рублей",
      "бр-бр патапимов", "тралалело тралалей", 
      "примогемов", "тенге", "тубриков", "анонимусов"
  }
  
  local curency = table.Random(tbl_italia_brainrot)
  local doante_now = GetGlobalInt("DonateCount")

  local main_container = vgui.Create("DPanel", INTRO_PANEL)
  INTRO_PANEL.settings_frame = main_container
  main_container:SetSize(scrw * 0.735, scrh * 0.87) 
  main_container:SetPos(scrw * 0.0156, scrh * 0.1) 
  
  main_container.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,dark_clr)
    DrawBlurPanel(self)
    SigmaYgliDraw(0, 0, w, h, Color(255,255,255), scrh * 0.0156) 
    
    draw.DrawText(L("l:menu_balance") .. ": " .. LocalPlayer():IGSFunds() .. " " .. L("l:menu_rub"), 
                 "MM_Exp", w - scrw * 0.0052, scrh * 0.00926, color_white, TEXT_ALIGN_RIGHT) 
  end

  local categories_panel = vgui.Create("DScrollPanel", main_container)
  categories_panel:SetSize(scrw * 0.104, main_container:GetTall() - scrh * 0.0185) 
  categories_panel:SetPos(scrw * 0.0052, scrh * 0.00926) 
  
  categories_panel.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,50))
  end

  local sbar_cat = categories_panel:GetVBar()
  function sbar_cat:Paint(w, h) end
  function sbar_cat.btnUp:Paint(w, h) end
  function sbar_cat.btnDown:Paint(w, h) end
  function sbar_cat.btnGrip:Paint(w, h)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(grad2)
    surface.DrawTexturedRect(scrw * 0.00313, 0, scrw * 0.00313, h/2) 
    surface.SetMaterial(grad1)
    surface.DrawTexturedRect(scrw * 0.00313, h/2, scrw * 0.00313, h/2) 
  end

  local content_panel = vgui.Create("DPanel", main_container)
  content_panel:SetSize(main_container:GetWide() - scrw * 0.12, main_container:GetTall() - scrh * 0.0185) 
  content_panel:SetPos(scrw * 0.115, scrh * 0.00926) 
  
  content_panel.Paint = function(self, w, h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,50))
  end

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
  

  
  
  
  

  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  local current_category_index = 1
  local current_items_panel = nil
  local selected_item = nil
  local curlevel = 1

  local function CreateItemsPanel(category_data, category_index)
    if IsValid(current_items_panel) then
      current_items_panel:Remove()
    end

    local items_panel = vgui.Create("DScrollPanel", content_panel)
    current_items_panel = items_panel
    items_panel:SetSize(content_panel:GetWide(), content_panel:GetTall() - scrh * 0.074) 
    items_panel:SetPos(0, 0)

    local sbar = items_panel:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
      surface.SetDrawColor(color_white)
      surface.SetMaterial(grad2)
      surface.DrawTexturedRect(scrw * 0.00313, 0, scrw * 0.00313, h/2) 
      surface.SetMaterial(grad1)
      surface.DrawTexturedRect(scrw * 0.00313, h/2, scrw * 0.00313, h/2) 
    end

    local header = vgui.Create("DPanel", items_panel)
    header:Dock(TOP)
    header:SetTall(scrh * 0.0278) 
    header:DockMargin(0,0,0,scrh * 0.00926) 
    
    header.Paint = function(self, w, h)
      draw.DrawText(L(category_data.name), "MM_Exp", w/2, scrh * 0.00463, color_white, TEXT_ALIGN_CENTER) 
      surface.SetDrawColor(color_white)
      surface.DrawLine(scrw * 0.0104, h - scrh * 0.00185, w - scrw * 0.0104, h - scrh * 0.00185) 
    end

    for _, item in pairs(category_data.items) do
      local panel = vgui.Create("DPanel", items_panel)
      panel:Dock(TOP)
      panel:SetTall(scrh * 0.074) 
      panel:DockMargin(0,0,0,scrh * 0.00926) 
      panel.item = item
      
      panel.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h,Color(0,0,0,30))
        
        if selected_item == self then
          surface.SetDrawColor(255,255,255,50)
          surface.DrawRect(0,0,w,h)
          SigmaYgliDraw(0, 0, w, h, Color(255,255,255), scrh * 0.0078) 
        end
        
        if self.item.icon then
          surface.SetDrawColor(255,255,255)
          surface.SetMaterial(self.item.icon)
          surface.DrawTexturedRect(scrw * 0.0052, scrh * 0.00926, scrw * 0.03125, scrh * 0.0556) 
        end
        
        local name = L(self.item.name)
        draw.DrawText(name, "MM_Exp", scrw * 0.0417, scrh * 0.00926, color_white) 
        
        local predesc = self.item.predesc or ""
        draw.DrawText(predesc, "ScoreboardContent", scrw * 0.0417, scrh * 0.0324, Color(255,140,0)) 
        
        if self.item.ispremcock or self.item.islevelcock then
          draw.DrawText(L("l:donate_click_for_info"), "ScoreboardContent", scrw * 0.0417, scrh * 0.0463, Color(200,200,200)) 
        end
      end
      
      local select_btn = vgui.Create("DButton", panel)
      select_btn:Dock(FILL)
      select_btn:SetText("")
      select_btn.Paint = function() end
      
      select_btn.DoClick = function()
        selected_item = panel
        
        if IsValid(level_slider) then level_slider:Remove() end
        if IsValid(level_display) then level_display:Remove() end
        
        if panel.item.islevelcock then
          local function UpdateLevelPrice()
            local price = CalculateRequiredMoneyForLevel(LocalPlayer():GetNLevel(), curlevel)
            if IsValid(level_display) then
              level_display:SetText(L("l:donate_howmanylevels") .. ": " .. curlevel .. " | " .. 
                                   L("l:donate_willcostyou") .. ": " .. price .. "₽")
            end
          end
          
          level_slider = vgui.Create("DNumSlider", content_panel)
          level_slider:SetPos(scrw * 0.0104, content_panel:GetTall() - scrh * 0.139) 
          level_slider:SetSize(content_panel:GetWide() - scrw * 0.0208, scrh * 0.037) 
          level_slider:SetText(L("l:donate_levels_count"))
          level_slider:SetMin(1)
          level_slider:SetMax(100)
          level_slider:SetValue(curlevel)
          level_slider:SetDecimals(0)
          
          level_slider.OnValueChanged = function(self, value)
            curlevel = math.Round(value)
            UpdateLevelPrice()
          end
          
          level_display = vgui.Create("DLabel", content_panel)
          level_display:SetPos(scrw * 0.0104, content_panel:GetTall() - scrh * 0.0926) 
          level_display:SetSize(content_panel:GetWide() - scrw * 0.0208, scrh * 0.0278) 
          level_display:SetFont("ScoreboardContent")
          UpdateLevelPrice()
          
        elseif panel.item.ispremcock then
          local function UpdatePremPrice()
            local price = CalculateRequiredMoneyForLevel2(LocalPlayer():GetNLevel(), curlevel)
            if IsValid(level_display) then
              level_display:SetText(L("l:donate_howmanylevels2") .. ": " .. curlevel .. " | " .. 
                                   L("l:donate_willcostyou2") .. ": " .. price .. "₽")
            end
          end
          
          level_slider = vgui.Create("DNumSlider", content_panel)
          level_slider:SetPos(scrw * 0.0104, content_panel:GetTall() - scrh * 0.139) 
          level_slider:SetSize(content_panel:GetWide() - scrw * 0.0208, scrh * 0.037) 
          level_slider:SetText(L("l:donate_prem_days"))
          level_slider:SetMin(1)
          level_slider:SetMax(365)
          level_slider:SetValue(curlevel)
          level_slider:SetDecimals(0)
          
          level_slider.OnValueChanged = function(self, value)
            curlevel = math.Round(value)
            UpdatePremPrice()
          end
          
          level_display = vgui.Create("DLabel", content_panel)
          level_display:SetPos(scrw * 0.0104, content_panel:GetTall() - scrh * 0.0926) 
          level_display:SetSize(content_panel:GetWide() - scrw * 0.0208, scrh * 0.0278) 
          level_display:SetFont("ScoreboardContent")
          UpdatePremPrice()
        end
      end
    end

    return items_panel
  end

  local purchase_btn = vgui.Create("DButton", content_panel)
  purchase_btn:SetSize(scrw * 0.0781, scrh * 0.037) 
  purchase_btn:SetPos(content_panel:GetWide() - scrw * 0.0885, content_panel:GetTall() - scrh * 0.0463) 
  purchase_btn:SetText("")
  purchase_btn:SetEnabled(false)
  
  purchase_btn.hoverScale = 1.0
  purchase_btn.targetScale = 1.0
  purchase_btn.animSpeed = 8
  purchase_btn.isHovered = false
  purchase_btn.clickScale = 1.0
  purchase_btn.clickAnimating = false
  purchase_btn.clickStartTime = 0
  purchase_btn.shakeOffset = 0
  purchase_btn.shakeIntensity = 0
  purchase_btn.shakeTime = 0
  purchase_btn.pulseAlpha = 0
  purchase_btn.pulseDir = 1
  purchase_btn.pulseSpeed = 3
  
  purchase_btn.Paint = function(self, w, h)
    local enabled = self:IsEnabled()
    
    if enabled and self:IsHovered() then
      self.targetScale = 1.05
      if not self.isHovered then
        self.shakeIntensity = 2
        self.shakeTime = CurTime()
        self.isHovered = true
      end
    else
      self.targetScale = 1.0
      self.isHovered = false
    end
    
    self.hoverScale = Lerp(FrameTime() * self.animSpeed, self.hoverScale, self.targetScale)
    
    if self.shakeIntensity > 0 then
      local elapsed = CurTime() - self.shakeTime
      if elapsed < 0.3 then
        local decay = (0.3 - elapsed) / 0.3
        self.shakeOffset = math.sin(elapsed * 50) * self.shakeIntensity * decay
      else
        self.shakeOffset = 0
        self.shakeIntensity = 0
      end
    end
    
    if enabled and self:IsHovered() then
      self.pulseAlpha = self.pulseAlpha + FrameTime() * self.pulseSpeed * self.pulseDir
      if self.pulseAlpha >= 1 then
        self.pulseAlpha = 1
        self.pulseDir = -1
      elseif self.pulseAlpha <= 0 then
        self.pulseAlpha = 0
        self.pulseDir = 1
      end
    else
      self.pulseAlpha = 0
    end
    
    if self.clickAnimating then
      local elapsed = CurTime() - self.clickStartTime
      if elapsed < 0.1 then
        self.clickScale = 0.92
      elseif elapsed < 0.2 then
        self.clickScale = Lerp((elapsed - 0.1) * 10, 0.92, 1.0)
      else
        self.clickAnimating = false
        self.clickScale = 1.0
      end
    end
    
    local totalScale = self.hoverScale * self.clickScale
    local scaledW = w * totalScale
    local scaledH = h * totalScale
    local offsetX = (w - scaledW) / 2 + self.shakeOffset
    local offsetY = (h - scaledH) / 2
    
    local bgColor = enabled and Color(255,140,0,100) or Color(100,100,100,50)
    draw.RoundedBox(0, offsetX, offsetY, scaledW, scaledH, bgColor)
    
    if enabled then
      SigmaYgliDraw(offsetX, offsetY, scaledW, scaledH, Color(255,255,255), scrh * 0.0078) 
      
      if not self.clickAnimating and self.pulseAlpha > 0 then
        local pulseColor = Color(255, 255, 255, 30 + self.pulseAlpha * 70)
        surface.SetDrawColor(pulseColor)
        surface.DrawOutlinedRect(offsetX, offsetY, scaledW, scaledH)
        
        for i = 1, 2 do
          local glowAlpha = self.pulseAlpha * 20
          surface.SetDrawColor(255, 255, 255, glowAlpha)
          surface.DrawOutlinedRect(offsetX - i, offsetY - i, scaledW + i*2, scaledH + i*2)
        end
      end

      if self:IsHovered() then
        surface.SetDrawColor(0, 0, 0, 40)
        surface.DrawRect(offsetX + scrw * 0.00104, offsetY + scrh * 0.00185, scaledW, scaledH) 
      end
    end

    local textColor = enabled and color_white or Color(150,150,150)
    draw.DrawText("Купить", "MM_Exp", w/2 + self.shakeOffset, scaledH/2.5 - scrh * 0.0037, 
                  textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
  end

  purchase_btn.DoClick = function(self)
    if not selected_item then return end
    
    self.shakeIntensity = 4
    self.shakeTime = CurTime()
    self.clickAnimating = true
    self.clickStartTime = CurTime()
    self.pulseAlpha = 0
    
    AnimateButtonPress(self)
    
    local item = selected_item.item
    if item.islevelcock then
      net.Start("fastbuymehouse")
      net.WriteUInt(curlevel, 8)
      net.SendToServer()
    elseif item.ispremcock then
      if curlevel > 0 then
        net.Start("fastbuymehouse1")
        net.WriteUInt(curlevel, 8)
        net.SendToServer()
      end
    elseif item.uid ~= nil then
      IGS.Purchase(item.uid)
    end
    
    if IsValid(INTRO_PANEL.settings_frame) then
      INTRO_PANEL.settings_frame:AlphaTo(0, 0.5, 0, function()
        INTRO_PANEL.settings_frame:Remove()
        INTRO_PANEL.settings_frame = nil
      end)
    end
  end
  
  purchase_btn.OnCursorEntered = function(self)
    if self:IsEnabled() then
      sound.PlayFile("sound/nextoren/gui/main_menu/button_hover.wav", "noplay", function(station, errCode, errStr)
        if IsValid(station) then
          station:SetVolume(0.15)
          station:Play()
        end
      end)
    end
  end

  local category_buttons = {}
  local default_category_index = nil

  for i, category_data in ipairs(donatelist.categories) do
    local cat_button = vgui.Create("DButton", categories_panel)
    cat_button:Dock(TOP)
    cat_button:SetTall(scrh * 0.037) 
    cat_button:DockMargin(scrw * 0.0026, scrw * 0.0026, scrw * 0.0026, 0) 
    cat_button:SetText("")
    
    cat_button.hoverScale = 1.0
    cat_button.targetScale = 1.0
    cat_button.animSpeed = 8
    cat_button.isHovered = false
    cat_button.clickScale = 1.0
    cat_button.clickAnimating = false
    cat_button.clickStartTime = 0
    cat_button.shakeOffset = 0
    cat_button.shakeIntensity = 0
    cat_button.shakeTime = 0
    cat_button.pulseAlpha = 0
    cat_button.pulseDir = 1
    cat_button.pulseSpeed = 3
    
    cat_button.Paint = function(self, w, h)
      local is_active = current_category_index == i
      
      if self:IsHovered() then
        self.targetScale = 1.05
        if not self.isHovered then
          self.shakeIntensity = 2
          self.shakeTime = CurTime()
          self.isHovered = true
        end
      else
        self.targetScale = 1.0
        self.isHovered = false
      end
      
      self.hoverScale = Lerp(FrameTime() * self.animSpeed, self.hoverScale, self.targetScale)
      
      if self.shakeIntensity > 0 then
        local elapsed = CurTime() - self.shakeTime
        if elapsed < 0.3 then
          local decay = (0.3 - elapsed) / 0.3
          self.shakeOffset = math.sin(elapsed * 50) * self.shakeIntensity * decay
        else
          self.shakeOffset = 0
          self.shakeIntensity = 0
        end
      end
      
      if self:IsHovered() and not is_active then
        self.pulseAlpha = self.pulseAlpha + FrameTime() * self.pulseSpeed * self.pulseDir
        if self.pulseAlpha >= 1 then
          self.pulseAlpha = 1
          self.pulseDir = -1
        elseif self.pulseAlpha <= 0 then
          self.pulseAlpha = 0
          self.pulseDir = 1
        end
      else
        self.pulseAlpha = 0
      end
      
      if self.clickAnimating then
        local elapsed = CurTime() - self.clickStartTime
        if elapsed < 0.1 then
          self.clickScale = 0.92
        elseif elapsed < 0.2 then
          self.clickScale = Lerp((elapsed - 0.1) * 10, 0.92, 1.0)
        else
          self.clickAnimating = false
          self.clickScale = 1.0
        end
      end
      
      local totalScale = self.hoverScale * self.clickScale
      local centerX = w / 2
      local centerY = h / 2
      local scaledW = w * totalScale
      local scaledH = h * totalScale
      local offsetX = (w - scaledW) / 2 + self.shakeOffset
      local offsetY = (h - scaledH) / 2
      
      local bg_color = is_active and Color(255,140,0,50) or Color(34,34,34,50)
      
      draw.RoundedBox(0, offsetX, offsetY, scaledW, scaledH, bg_color)
      SigmaYgliDraw(offsetX, offsetY, scaledW, scaledH, Color(255,255,255), scrh * 0.0156) 
      
      if not self.clickAnimating and self.pulseAlpha > 0 then
        local pulseColor = Color(255, 255, 255, 30 + self.pulseAlpha * 70)
        surface.SetDrawColor(pulseColor)
        surface.DrawOutlinedRect(offsetX, offsetY, scaledW, scaledH)
        
        for i = 1, 2 do
          local glowAlpha = self.pulseAlpha * 20
          surface.SetDrawColor(255, 255, 255, glowAlpha)
          surface.DrawOutlinedRect(offsetX - i, offsetY - i, scaledW + i*2, scaledH + i*2)
        end
      end

      if self:IsHovered() then
        surface.SetDrawColor(0, 0, 0, 40)
        surface.DrawRect(offsetX + scrw * 0.00104, offsetY + scrh * 0.00185, scaledW, scaledH) 
      end
      
      draw.DrawText(L(category_data.name), "MM_Exp", w/2 + self.shakeOffset, scaledH/2.5 - scrh * 0.0037, 
                    color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
    end
    
    cat_button.DoClick = function(self)
      self.shakeIntensity = 4
      self.shakeTime = CurTime()
      self.clickAnimating = true
      self.clickStartTime = CurTime()
      self.pulseAlpha = 0
      
      current_category_index = i
      selected_item = nil
      purchase_btn:SetEnabled(false)
      CreateItemsPanel(category_data, i)
      
      for idx, btn in pairs(category_buttons) do
        if IsValid(btn) then
          btn:InvalidateLayout()
        end
      end
    end
    
    cat_button.OnCursorEntered = function(self)
      if current_category_index ~= i then
        sound.PlayFile("sound/nextoren/gui/main_menu/button_hover.wav", "noplay", function(station, errCode, errStr)
          if IsValid(station) then
            station:SetVolume(0.15)
            station:Play()
          end
        end)
      end
    end
    
    category_buttons[i] = cat_button
    
    if i == 1 then
      default_category_index = i
    end
  end

  if default_category_index then
    current_category_index = default_category_index
    CreateItemsPanel(donatelist.categories[default_category_index], default_category_index)
  end
end

function OpenConfigMenu()
  local scrw, scrh = ScrW(), ScrH()

  local function sw(val) return math.Round(val * (scrw / 1920)) end
  local function sh(val) return math.Round(val * (scrh / 1080)) end

  local rust_bg       = Color(25, 24, 22, 250)    
  local rust_panel    = Color(18, 16, 15, 255)    
  local rust_row      = Color(40, 38, 35, 255)    
  local rust_outline  = Color(255, 255, 255, 10)  
  local rust_green    = Color(112, 126, 73)       
  local rust_red      = Color(188, 64, 43)        
  local rust_yellow   = Color(218, 165, 32)       
  local rust_text     = Color(230, 230, 230)      
  local rust_text_dim = Color(140, 140, 140)      

  if IsValid(INTRO_PANEL.settings_frame) then
    INTRO_PANEL.settings_frame:Remove()
    INTRO_PANEL.settings_frame = nil
    return
  end

  local TopBarHeight = sh(70)
  local main_container = vgui.Create("DPanel", INTRO_PANEL)
  INTRO_PANEL.settings_frame = main_container
  main_container:SetSize(scrw, scrh - TopBarHeight)
  main_container:SetPos(0, TopBarHeight)
  main_container:SetAlpha(0)
  main_container:AlphaTo(255, 0.15, 0)
  
  main_container.Paint = function(self, w, h)
      surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, rust_bg.a)
      surface.DrawRect(0, 0, w, h)
  end

  local categories_panel = vgui.Create("DScrollPanel", main_container)
  categories_panel:SetSize(scrw * 0.18, main_container:GetTall())
  categories_panel:SetPos(0, 0)
  categories_panel.Paint = function(self, w, h)
      surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, rust_panel.a)
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor(rust_outline)
      surface.DrawLine(w - 1, 0, w - 1, h)
  end
  categories_panel:GetVBar():SetWide(0) 

  local TitlePanel = vgui.Create("DPanel", categories_panel)
  TitlePanel:Dock(TOP)
  TitlePanel:SetTall(sh(80))
  TitlePanel.Paint = function(self, w, h)
      draw.DrawText(L("l:configmenu_options"), "MM_BigNameB", sw(25), sh(30), color_white, TEXT_ALIGN_LEFT)
  end

  local content_panel = vgui.Create("DPanel", main_container)
  content_panel:SetSize(scrw * 0.65, main_container:GetTall() - sh(80))
  content_panel:SetPos(scrw * 0.18 + sw(50), sh(40))
  content_panel.Paint = function() end

  local current_category_index = 1 
  local current_settings_panel = nil

  local function CloseModal()
      if IsValid(MODAL_BG_OVERLAY) then MODAL_BG_OVERLAY:Remove() end
  end

  local function choicepanel(choices, convar)
      CloseModal()
      
      MODAL_BG_OVERLAY = vgui.Create("DPanel", INTRO_PANEL)
      MODAL_BG_OVERLAY:SetSize(scrw, scrh)
      MODAL_BG_OVERLAY.Paint = function() end 
      MODAL_BG_OVERLAY.OnMousePressed = function() CloseModal() end 
      MODAL_BG_OVERLAY:MoveToFront() 

      choices_panel_settings = vgui.Create("DPanel", MODAL_BG_OVERLAY)
      
      local mx, my = gui.MousePos()
      local panel_height = #choices * sh(35) + sh(2)
      
      if my + panel_height > scrh then
          my = scrh - panel_height
      end
      
      choices_panel_settings:SetSize(sw(250), panel_height)
      choices_panel_settings:SetPos(mx - sw(250), my)

      choices_panel_settings.Paint = function(self, w, h)
          surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
          surface.DrawRect(0, 0, w, h)
          surface.SetDrawColor(rust_outline)
          surface.DrawOutlinedRect(0, 0, w, h, 1)
      end

      local y = sh(1)
      for _, value in pairs(choices) do
          local btn = vgui.Create("DButton", choices_panel_settings)
          btn:SetSize(sw(248), sh(35))
          btn:SetPos(sw(1), y)
          btn:SetText("")
          btn.Paint = function(self, w, h)
              if self:IsHovered() then
                  surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
                  surface.DrawRect(0, 0, w, h)
              end
              local text = translate_translations and translate_translations[value] or value
              local isCur = GetConVar(convar):GetString() == value
              draw.DrawText(string.upper(text), "MM_Exp", sw(15), h/2 - sh(6), isCur and rust_yellow or rust_text, TEXT_ALIGN_LEFT)
          end
          btn.DoClick = function()
              GetConVar(convar):SetString(value)
              CloseModal()
          end
          y = y + sh(35)
      end
  end

  
  local function CreateSettingsPanel(category_data, category_index)
    if IsValid(current_settings_panel) then current_settings_panel:Remove() end

    local settings_panel = vgui.Create("DScrollPanel", content_panel)
    current_settings_panel = settings_panel
    settings_panel:Dock(FILL)

    local sbar = settings_panel:GetVBar()
    sbar:SetWide(math.max(sw(6), 4))
    function sbar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 255) surface.DrawRect(0,0,w,h) end
    function sbar.btnUp:Paint() end
    function sbar.btnDown:Paint() end
    function sbar.btnGrip:Paint(w, h) surface.SetDrawColor(80, 80, 80, 255) surface.DrawRect(0,0,w,h) end

    local header = vgui.Create("DPanel", settings_panel)
    header:Dock(TOP)
    header:SetTall(sh(55))
    header.Paint = function(self, w, h)
        local clr = category_data.premium and rust_yellow or color_white
        draw.DrawText(string.upper(L(category_data.name)), "MM_BigName", 0, sh(10), clr, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(0, h-1, w - sw(20), h-1)
    end

    for _, data in pairs(category_data.settings) do
      if data.premium and not LocalPlayer():IsPremium() then continue end
      if data.checkplayer and not data.checkplayer[LocalPlayer():SteamID64()] and not LocalPlayer():IsSuperAdmin() then continue end
      if data.hair and not (LEGACY_HAIRCOLOR and LEGACY_HAIRCOLOR[LocalPlayer():SteamID64()]) then continue end
      if data.xmasgloves and LocalPlayer():GetNWInt("gloves_xmas") == 0 then continue end
      
      local convar = data.cvar and GetConVar(data.cvar) or nil

      local rowH = sh(50)
      if data.type == "color" then rowH = sh(220) end
      if data.type == "prefix" then rowH = sh(270) end

      local row = vgui.Create("DPanel", settings_panel)
      row:Dock(TOP)
      row:SetTall(rowH)
      row.Paint = function(self, w, h)
          if self:IsHovered() then
              surface.SetDrawColor(255, 255, 255, 5)
              surface.DrawRect(0, 0, w - sw(20), h)
          end
          surface.SetDrawColor(rust_outline)
          surface.DrawLine(0, h-1, w - sw(20), h-1)
          
          local textY = (h > sh(50)) and sh(25) or (h/2 - sh(6))
          draw.DrawText(string.upper(L(data.name)), "MM_Exp", sw(10), textY, rust_text, TEXT_ALIGN_LEFT)
      end

      if data.type == "bool" then
          local btn = vgui.Create("DButton", row)
          btn:SetSize(sw(160), sh(30))
          btn:SetPos(content_panel:GetWide() - sw(190), sh(10))
          btn:SetText("")
          btn.Paint = function(self, w, h)
              local val = convar:GetBool()
              surface.SetDrawColor(val and Color(25,25,25) or Color(80,80,80))
              surface.DrawRect(0, 0, w/2, h)
              draw.DrawText(L("l:configmenu_off"), "MM_Exp", w/4, h/2 - sh(6), not val and color_white or rust_text_dim, TEXT_ALIGN_CENTER)

              surface.SetDrawColor(val and rust_green or Color(25,25,25))
              surface.DrawRect(w/2, 0, w/2, h)
              draw.DrawText(L("l:configmenu_on"), "MM_Exp", w*0.75, h/2 - sh(6), val and Color(10,10,10) or rust_text_dim, TEXT_ALIGN_CENTER)

              surface.SetDrawColor(rust_outline)
              surface.DrawLine(w/2, 0, w/2, h)
              surface.DrawOutlinedRect(0, 0, w, h, 1)
          end
          btn.DoClick = function()
              surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
              convar:SetBool(not convar:GetBool())
          end

      elseif data.type == "slider" then
          local SliderPanel = vgui.Create("DPanel", row)
          SliderPanel:SetSize(sw(300), sh(30))
          SliderPanel:SetPos(content_panel:GetWide() - sw(330), sh(10))
          SliderPanel.Paint = function(self, w, h)
              local val = convar:GetInt()
              local pct = math.Clamp((val - data.min) / (data.max - data.min), 0, 1)
              local barW = w - sw(60)
              local barY = h/2 - sh(2)

              surface.SetDrawColor(10, 10, 10, 255)
              surface.DrawRect(0, barY, barW, sh(4))
              
              surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 255)
              surface.DrawRect(0, barY, barW * pct, sh(4))
              
              surface.SetDrawColor(200, 200, 200, 255)
              surface.DrawRect((barW * pct) - sw(3), h/2 - sh(8), sw(6), sh(16))

              draw.DrawText(tostring(val), "MM_Exp", w, h/2 - sh(6), color_white, TEXT_ALIGN_RIGHT)
          end

          local btn = vgui.Create("DButton", SliderPanel)
          btn:SetSize(sw(240), sh(30))
          btn:SetPos(0, 0)
          btn:SetText("")
          btn.Paint = function() end
          btn.Activated = false

          btn.OnMousePressed = function(self)
              self.savex, self.savey = gui.MousePos()
              self:SetCursor("blank")
              self.CurValue = convar:GetInt()
              self.Activated = true
          end
          btn.OnMouseReleased = function(self) self:SetCursor("hand") self.Activated = false end
          btn.Think = function(self)
              if not self:IsHovered() and self.Activated and not input.IsMouseDown(MOUSE_LEFT) then self:OnMouseReleased() end
              if self.Activated then
                  self.CurValue = self.CurValue - (self.savex - gui.MousePos()) * 0.1 
                  local newVal = math.floor(math.Clamp(self.CurValue, data.min, data.max))
                  
                  if math.floor(convar:GetInt()) ~= newVal and (not btn.sndcd or btn.sndcd <= SysTime()) then
                      btn.sndcd = SysTime() + 0.05
                      surface.PlaySound("nextoren/gui/main_menu/numslider_change_1.wav")
                  end
                  convar:SetInt(newVal)
                  gui.SetMousePos(self.savex, self.savey)
              end
          end

      elseif data.type == "choice" then
          local btn = vgui.Create("DButton", row)
          btn:SetSize(sw(160), sh(30))
          btn:SetPos(content_panel:GetWide() - sw(190), sh(10))
          btn:SetText("")
          btn.Paint = function(self, w, h)
              surface.SetDrawColor(self:IsHovered() and 35 or 25, 33, 30, 255)
              surface.DrawRect(0, 0, w, h)
              surface.SetDrawColor(rust_outline)
              surface.DrawOutlinedRect(0, 0, w, h, 1)

              local translation = translate_translations and translate_translations[convar:GetString()] or convar:GetString()
              draw.DrawText(string.upper(translation), "MM_Exp", sw(10), h/2 - sh(6), rust_text, TEXT_ALIGN_LEFT)
              draw.DrawText("▼", "MM_SmallName", w - sw(15), h/2 - sh(4), rust_text_dim, TEXT_ALIGN_CENTER)
          end
          btn.DoClick = function()
              surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
              choicepanel(data.value, data.cvar)
          end

      elseif data.type == "bind" then
          local swap = vgui.Create("DBinder", row)
          swap:SetSize(sw(120), sh(30))
          swap:SetPos(content_panel:GetWide() - sw(150), sh(10))
          swap:SetText("")
          swap.Paint = function(self, w, h)
              if self.editmode then
                  surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
                  surface.DrawRect(0, 0, w, h)
                  draw.DrawText(L("l:configmenu_press_key"), "MM_SmallName", w/2, h/2 - sh(4), Color(20,20,20), TEXT_ALIGN_CENTER)
              else
                  surface.SetDrawColor(self:IsHovered() and 35 or 20, 33, 30, 255)
                  surface.DrawRect(0, 0, w, h)
                  surface.SetDrawColor(rust_outline)
                  surface.DrawOutlinedRect(0, 0, w, h, 1)
                  
                  local keyName = input.GetKeyName(convar:GetInt())
                  draw.DrawText(keyName and string.upper(keyName) or L("l:configmenu_none"), "MM_Exp", w/2, h/2 - sh(6), rust_text, TEXT_ALIGN_CENTER)
              end
          end
          swap.DoClick = function(self)
              surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
              self.editmode = true
              input.StartKeyTrapping()
              self.Trapping = true
          end
          swap.OnChange = function(self, new)
              self.editmode = false
              self:SetText("")
              if new ~= KEY_END and isstring(input.GetKeyName(new)) then
                  convar:SetInt(new)
              end
          end

      elseif data.type == "color" or data.type == "prefix" then
          local isPrefix = (data.type == "prefix")
          local rightX = content_panel:GetWide() - sw(320)
          local currentY = sh(15)

          local TextEntry
          if isPrefix then
              local prefData = util.JSONToTable(file.Read("breach_prefix_settings.txt", "DATA") or "{}") or {}
              TextEntry = vgui.Create("DTextEntry", row)
              TextEntry:SetPos(rightX, currentY)
              TextEntry:SetSize(sw(300), sh(35))
              TextEntry:SetFont("MM_Exp")
              TextEntry:SetText(prefData.prefix or "")
              TextEntry:SetDrawBackground(false)
              TextEntry:SetTextColor(color_white)
              TextEntry.Paint = function(self, w, h)
                  surface.SetDrawColor(15, 15, 15, 255)
                  surface.DrawRect(0, 0, w, h)
                  surface.SetDrawColor(rust_outline)
                  surface.DrawOutlinedRect(0, 0, w, h, 1)
                  self:DrawTextEntryText(color_white, rust_yellow, color_white)
                  if self:GetText() == "" and not self:HasFocus() then
                      draw.DrawText(L("l:configmenu_enter_prefix"), "MM_Exp", sw(10), h/2 - sh(6), rust_text_dim, TEXT_ALIGN_LEFT)
                  end
              end
              currentY = currentY + sh(45)
          end

          local mixerBG = vgui.Create("DPanel", row)
          mixerBG:SetPos(rightX, currentY)
          mixerBG:SetSize(sw(300), sh(140))
          mixerBG.Paint = function(self, w, h)
              surface.SetDrawColor(20, 20, 20, 255)
              surface.DrawRect(0, 0, w, h)
              surface.SetDrawColor(rust_outline)
              surface.DrawOutlinedRect(0, 0, w, h, 1)
          end

          local mixer = vgui.Create("DColorMixer", mixerBG)
          mixer:Dock(FILL)
          mixer:DockMargin(sw(5), sh(5), sw(5), sh(5))
          mixer:SetPalette(false) 
          mixer:SetAlphaBar(false)
          mixer:SetWangs(true)
          
          local defColor = color_white
          local cStr = "255,255,255"
          if isPrefix then
              local prefData = util.JSONToTable(file.Read("breach_prefix_settings.txt", "DATA") or "{}") or {}
              cStr = prefData.color or cStr
          else
              cStr = convar:GetString() or cStr
          end
          local t = string.Split(cStr, ",")
          defColor = Color(tonumber(t[1]) or 255, tonumber(t[2]) or 255, tonumber(t[3]) or 255)
          mixer:SetColor(defColor)
          
          currentY = currentY + sh(150)

          local applyBtn = vgui.Create("DButton", row)
          applyBtn:SetPos(rightX, currentY)
          applyBtn:SetSize(sw(300), sh(35))
          applyBtn:SetText("")
          applyBtn.Paint = function(self, w, h)
              surface.SetDrawColor(self:IsHovered() and Color(230,180,40) or rust_yellow)
              surface.DrawRect(0, 0, w, h)
              draw.DrawText(L("l:configmenu_apply"), "MM_Exp", w/2, h/2 - sh(6), Color(20,20,20), TEXT_ALIGN_CENTER)
          end
          applyBtn.DoClick = function()
              surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
              local c = mixer:GetColor()
              local colorStr = c.r .. "," .. c.g .. "," .. c.b
              
              if isPrefix then
                  local prefData = util.JSONToTable(file.Read("breach_prefix_settings.txt", "DATA") or "{}") or {}
                  prefData.color = colorStr
                  prefData.prefix = TextEntry:GetText()
                  file.Write("breach_prefix_settings.txt", util.TableToJSON(prefData, true))
                  send_prefix_data()
              else
                  convar:SetString(colorStr)
              end
          end

      elseif data.type == "unique" then
          data.createpanel(row)
      end
    end
  end

  local category_buttons = {}

  for i, category_data in ipairs(BREACH.Options) do
    if category_data.premium and not LocalPlayer():IsPremium() then continue end
    if category_data.prefix and not LocalPlayer():GetNWBool("have_prefix") then continue end

    local cat_btn = vgui.Create("DButton", categories_panel)
    cat_btn:Dock(TOP)
    cat_btn:SetTall(sh(40))
    cat_btn:SetText("")
    
    cat_btn.Paint = function(self, w, h)
        local is_active = (current_category_index == i)
        
        if is_active then
            surface.SetDrawColor(30, 28, 25, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(rust_green.r, rust_green.g, rust_green.b, 255)
            surface.DrawRect(0, 0, sw(4), h)
        elseif self:IsHovered() then
            surface.SetDrawColor(255, 255, 255, 5)
            surface.DrawRect(0, 0, w, h)
        end

        local text_color = rust_text_dim
        if is_active then text_color = color_white end
        if category_data.premium then text_color = rust_yellow end
        
        local textX = is_active and sw(15) or sw(10)
        draw.DrawText(string.upper(L(category_data.name)), "MM_Exp", textX, h/2 - sh(6), text_color, TEXT_ALIGN_LEFT)
    end
    
    cat_btn.DoClick = function()
        surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
        current_category_index = i
        CreateSettingsPanel(category_data, i)
    end
    cat_btn.OnCursorEntered = function() surface.PlaySound("nextoren/gui/main_menu/button_hover.wav") end
    
    category_buttons[i] = cat_btn
  end

  if #category_buttons > 0 then
      current_category_index = 1
      CreateSettingsPanel(BREACH.Options[1], 1)
  end
end

local bgmat = Material("nextoren_hud/inventory/menublack.png")
local bgmat2 = Material("nextoren_hud/inventory/texture_blanc.png")
local gradient = Material("vgui/gradient-l")




function ShowAchievementsLoading()
    if IsValid(INTRO_PANEL.BreachAchievements) then INTRO_PANEL.BreachAchievements:Remove() end

    local scrw, scrh = ScrW(), ScrH()
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    local rust_bg       = Color(25, 24, 22, 250)
    local rust_yellow   = Color(218, 165, 32)
    local rust_text_dim = Color(140, 140, 140)

    local TopBarHeight = sh(70)

    INTRO_PANEL.BreachAchievements = vgui.Create("DPanel", INTRO_PANEL)
    local Pnl = INTRO_PANEL.BreachAchievements
    Pnl:SetSize(scrw, scrh - TopBarHeight)
    Pnl:SetPos(0, TopBarHeight)
    Pnl:SetAlpha(0)
    Pnl:AlphaTo(255, 0.2, 0)
    
    Pnl.StartTime = SysTime()
    
    Pnl.Paint = function(self, w, h)
        surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, rust_bg.a)
        surface.DrawRect(0, 0, w, h)
        
        local pulse = math.abs(math.sin((SysTime() - self.StartTime) * 3))
        local alpha = 100 + 155 * pulse

        draw.DrawText("СИНХРОНИЗАЦИЯ ДАННЫХ...", "MM_BigNameB", w/2, h/2.1, ColorAlpha(rust_yellow, alpha), TEXT_ALIGN_CENTER)
        
        local barW = sw(400)
        local barH = sh(4)
        local barX = w/2 - barW/2
        local barY = h/2 + sh(45)
        
        surface.SetDrawColor(10, 10, 10, 255)
        surface.DrawRect(barX, barY, barW, barH)
        
        local runnerW = sw(100)
        local runnerProgress = (math.sin((SysTime() - self.StartTime) * 4) + 1) / 2
        local runnerX = barX + runnerProgress * (barW - runnerW)
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(runnerX, barY, runnerW, barH)
    end
end

function OpenAchievementListInMenu(tab, completedtab)
    if IsValid(INTRO_PANEL.BreachAchievements) then INTRO_PANEL.BreachAchievements:Remove() end

    local scrw, scrh = ScrW(), ScrH()
    local function sw(val) return math.Round(val * (scrw / 1920)) end
    local function sh(val) return math.Round(val * (scrh / 1080)) end

    local rust_bg       = Color(25, 24, 22, 250)
    local rust_card     = Color(45, 43, 40, 255)
    local rust_card_btm = Color(30, 28, 25, 255)
    local rust_outline  = Color(255, 255, 255, 10)
    local rust_green    = Color(112, 126, 73)
    local rust_red      = Color(188, 64, 43)
    local rust_yellow   = Color(218, 165, 32)
    local rust_text     = Color(230, 230, 230)
    local rust_text_dim = Color(140, 140, 140)

    local TopBarHeight = sh(70)

    INTRO_PANEL.BreachAchievements = vgui.Create("DPanel", INTRO_PANEL)
    local Pnl = INTRO_PANEL.BreachAchievements
    Pnl:SetSize(scrw, scrh - TopBarHeight)
    Pnl:SetPos(0, TopBarHeight)
    Pnl:SetAlpha(0)
    Pnl:AlphaTo(255, 0.2, 0)
    Pnl.Paint = function(self, w, h)
        surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, rust_bg.a)
        surface.DrawRect(0, 0, w, h)
    end

    local SubNav = vgui.Create("DPanel", Pnl)
    SubNav:SetSize(scrw - sw(80), sh(45))
    SubNav:SetPos(sw(40), sh(30))

    local Scroll = vgui.Create("DScrollPanel", Pnl)
    Scroll:SetPos(sw(40), sh(100))
    Scroll:SetSize(scrw - sw(80), Pnl:GetTall() - sh(130))

    local scrollbar_w = math.max(sw(8), 4)
    local sbar = Scroll:GetVBar()
    sbar:SetWide(scrollbar_w)
    function sbar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 255) surface.DrawRect(0, 0, w, h) end
    function sbar.btnUp:Paint() end
    function sbar.btnDown:Paint() end
    function sbar.btnGrip:Paint(w, h) surface.SetDrawColor(80, 80, 80, 255) surface.DrawRect(0, 0, w, h) end

    local Grid = vgui.Create("DIconLayout", Scroll)
    Grid:Dock(FILL)
    Grid:SetSpaceY(sh(20))
    Grid:SetSpaceX(sw(20))

    local cardW = math.floor((Scroll:GetWide() - (sw(20) * 2) - scrollbar_w) / 3) 
    local cardH = sh(100)
    local completedCount = 0

    local ply = LocalPlayer()

    if FUNNYACHIEVEMENTS then
        for i = 1, #FUNNYACHIEVEMENTS do
            local tabl = FUNNYACHIEVEMENTS[i]
            
            if not table.HasValue(tabl.owners, ply:SteamID()) and not table.HasValue(tabl.owners, ply:SteamID64()) and not table.HasValue(tabl.ownersusergroup, ply:GetUserGroup()) and not tabl.customcheck then continue end
            if isfunction(tabl.customcheck) and not tabl.customcheck(ply) then continue end
            
            local Card = Grid:Add("DPanel")
            Card:SetSize(cardW, cardH)
            
            local image = Material(tabl.image)
            local accent = Color(0, 200, 220) 
            
            Card.Paint = function(self, w, h)
                surface.SetDrawColor(rust_card.r, rust_card.g, rust_card.b, 255)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(accent.r, accent.g, accent.b, 15)
                surface.DrawRect(0, 0, w, h)

                surface.SetDrawColor(accent.r, accent.g, accent.b, 255)
                surface.DrawRect(0, 0, w, sh(4))
                surface.SetDrawColor(rust_outline)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                draw.RoundedBox(0, sw(15), sh(15), sh(70), sh(70), Color(15, 15, 15, 200))
                surface.SetDrawColor(color_white)
                surface.SetMaterial(image)
                surface.DrawTexturedRect(sw(15) + sw(3), sh(15) + sh(3), sh(64), sh(64))
                surface.SetDrawColor(accent)
                surface.DrawOutlinedRect(sw(15), sh(15), sh(70), sh(70), 1)

                draw.DrawText(string.upper(tabl.achievements_name), "MM_Exp", sw(100), sh(18), color_white, TEXT_ALIGN_LEFT)

                surface.SetFont("MM_SmallName")
                local tw, th = surface.GetTextSize(L("l:achievements_unique"))
                local tagW = tw + sw(20)
                draw.RoundedBox(0, w - tagW - sw(10), h - sh(35), tagW, sh(20), Color(20, 20, 20, 230))
                draw.DrawText(L("l:achievements_unique"), "MM_SmallName", w - tagW/2 - sw(10), h - sh(30), accent, TEXT_ALIGN_CENTER)
            end

            local DescLabel = vgui.Create("DLabel", Card)
            DescLabel:SetPos(sw(100), sh(42))
            DescLabel:SetSize(cardW - sw(115), sh(45))
            DescLabel:SetFont("MM_SmallName")
            DescLabel:SetTextColor(rust_text_dim)
            DescLabel:SetText(tabl.desc)
            DescLabel:SetWrap(true)
            DescLabel:SetContentAlignment(7)
        end
    end

    for i = 1, #tab do
        local tabl = tab[i]
        local iscompleted = false
        local cnt = 0

        for _, v in pairs(completedtab) do
            if v.achivid == tabl.name then
                cnt = tonumber(v.count) or 0
                if not tabl.countable then
                    iscompleted = true
                else
                    if tabl.countnum <= cnt then
                        iscompleted = true
                    end
                end
                break
            end
        end

        if iscompleted then completedCount = completedCount + 1 end
        if tabl.secret and not iscompleted then continue end 

        local Card = Grid:Add("DPanel")
        Card:SetSize(cardW, cardH)

        local image = Material(tabl.image)
        local accent = iscompleted and rust_green or rust_red
        local glowAlpha = 0
        local rarityText = nil

        if tabl.mega then 
            accent = Color(164, 90, 214) 
            glowAlpha = iscompleted and 30 or 0
            rarityText = L("l:achievements_mega")
        elseif tabl.secret then 
            accent = Color(255, 187, 0) 
            glowAlpha = iscompleted and 20 or 0
            rarityText = L("l:achievements_secret")
        end

        local addon = tabl.countable and (tostring(cnt) .. " / " .. tabl.countnum) or ""
        local statusText = iscompleted and L("l:achievements_completed") or L("l:achievements_locked")

        Card.Paint = function(self, w, h)
            surface.SetDrawColor(rust_card.r, rust_card.g, rust_card.b, 255)
            surface.DrawRect(0, 0, w, h)
            
            if glowAlpha > 0 then
                surface.SetDrawColor(accent.r, accent.g, accent.b, glowAlpha)
                surface.DrawRect(0, 0, w, h)
            end
            
            surface.SetDrawColor(accent.r, accent.g, accent.b, 255)
            surface.DrawRect(0, 0, w, sh(4))

            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            draw.RoundedBox(0, sw(15), sh(15), sh(70), sh(70), Color(15, 15, 15, 200))
            surface.SetDrawColor(iscompleted and color_white or Color(80, 80, 80, 255))
            surface.SetMaterial(image)
            surface.DrawTexturedRect(sw(15) + sw(3), sh(15) + sh(3), sh(64), sh(64))
            surface.SetDrawColor(accent)
            surface.DrawOutlinedRect(sw(15), sh(15), sh(70), sh(70), 1)

            draw.DrawText(string.upper(tabl.achievements_name), "MM_Exp", sw(100), sh(18), iscompleted and color_white or rust_text_dim, TEXT_ALIGN_LEFT)
            
            if tabl.countable then
                draw.DrawText(addon, "MM_Exp", w - sw(15), sh(18), iscompleted and accent or rust_text_dim, TEXT_ALIGN_RIGHT)
            end

            surface.SetFont("MM_SmallName")
            
            local sw_w, sh_w = surface.GetTextSize(statusText)
            local statusW = sw_w + sw(20)
            local curX = w - statusW - sw(10)
            
            draw.RoundedBox(0, curX, h - sh(35), statusW, sh(20), Color(20, 20, 20, 230))
            draw.DrawText(statusText, "MM_SmallName", curX + statusW/2, h - sh(30), (iscompleted and not rarityText) and rust_green or (not iscompleted and rust_red or color_white), TEXT_ALIGN_CENTER)

            if rarityText then
                local rw, rh = surface.GetTextSize(rarityText)
                local rarityW = rw + sw(20)
                curX = curX - rarityW - sw(5)
                
                draw.RoundedBox(0, curX, h - sh(35), rarityW, sh(20), Color(20, 20, 20, 230))
                draw.DrawText(rarityText, "MM_SmallName", curX + rarityW/2, h - sh(30), accent, TEXT_ALIGN_CENTER)
            end
        end

        local DescLabel = vgui.Create("DLabel", Card)
        DescLabel:SetPos(sw(100), sh(42))
        DescLabel:SetSize(cardW - sw(115), sh(45))
        DescLabel:SetFont("MM_SmallName")
        DescLabel:SetTextColor(rust_text_dim)
        DescLabel:SetText(tabl.desc)
        DescLabel:SetWrap(true)
        DescLabel:SetContentAlignment(7)
    end

    SubNav.Paint = function(self, w, h)
        surface.SetDrawColor(rust_card_btm.r, rust_card_btm.g, rust_card_btm.b, 255)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(0, 0, sw(220), h)
        draw.DrawText(L("l:achievements_hall"), "MM_Exp", sw(110), h/2 - sh(6), Color(15, 15, 15), TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(40, 40, 40, 255)
        surface.DrawRect(sw(221), 0, sw(250), h)
        draw.DrawText(L("l:achievements_unlocked") .. completedCount .. " / " .. #tab, "MM_Exp", sw(221) + sw(125), h/2 - sh(6), color_white, TEXT_ALIGN_CENTER)
    end
end


net.Receive("OpenAchievementMenuInMenu", function()
    local readtable = net.ReadTable()
    local completedtable = net.ReadTable()
    OpenAchievementListInMenu(readtable, completedtable)
end)

function GM:PreRender()

  local ply = LocalPlayer()

  if IsValid(INTRO_PANEL) && !gui.IsGameUIVisible() then INTRO_PANEL:MakePopup() end

  if ( input.IsKeyDown( KEY_ESCAPE ) && gui.IsGameUIVisible()  ) then
    if ( isnumber( ShowMainMenu ) ) then

      gui.HideGameUI()
        if ( ShowMainMenu < CurTime() ) then

          ShowMainMenu = false

        end

        return
    end

    if ( !ShowMainMenu ) then

      gui.HideGameUI()

      if ( INTRO_PANEL && INTRO_PANEL:IsValid() ) then

        INTRO_PANEL.OpenTime = RealTime()
        INTRO_PANEL:SetVisible( true )
        ShowMainMenu = true
        if !(BREACH.Music and BREACH.Music and BREACH.Music.MusicPatch and BREACH.Music.MusicPatch:IsValid() ) then
          
      
    end

      else

        StartBreach(false) 
        ShowMainMenu = true
        if !(BREACH.Music and BREACH.Music and BREACH.Music.MusicPatch and BREACH.Music.MusicPatch:IsValid() ) then
          
      
    end

      end

    end

  end

end

net.Receive("WTh_SyncData", function()
    local syncType = net.ReadString()
    local ply = LocalPlayer()

    if IsValid(ply) then
        if syncType == "initial_sync" then
            ply.WTh_UnlockedCache = net.ReadTable() or {}
            ply.WTh_RolesEXPCache = net.ReadTable() or {}
            ply.WTh_BlacklistCache = net.ReadTable() or {} 
            ply.WTh_FreeEXPCache = net.ReadInt(32)
        elseif syncType == "active_research" then
            ply.WTh_ActiveResearch_Cache = net.ReadString()
        elseif syncType == "role_unlocked" then
            local rName = net.ReadString()
            ply.WTh_UnlockedCache = ply.WTh_UnlockedCache or {}
            ply.WTh_UnlockedCache[rName] = true
            ply.WTh_ActiveResearch_Cache = "" 
        elseif syncType == "update_exp" then
            local roleName = net.ReadString()
            ply.WTh_RolesEXPCache = ply.WTh_RolesEXPCache or {}
            ply.WTh_RolesEXPCache[roleName] = net.ReadInt(32)
        elseif syncType == "update_blacklist" then 
            ply.WTh_BlacklistCache = net.ReadTable() or {}
        elseif syncType == "update_free_exp" then
            ply.WTh_FreeEXPCache = net.ReadInt(32)
        elseif syncType == "active_upgrade" then
            ply.WTh_ActiveUpgrade_Cache = net.ReadString()
        elseif syncType == "unlocked_upgrades" then
            ply.WTh_UpgUnlockedCache = net.ReadTable() or {}
            ply.WTh_UpgEXPCache = net.ReadTable() or {}
            ply.WTh_ActiveUpgrade_Cache = ""
        elseif syncType == "update_upg_exp" then
            local roleName = net.ReadString()
            local upgId = net.ReadString()
            ply.WTh_UpgEXPCache = ply.WTh_UpgEXPCache or {}
            ply.WTh_UpgEXPCache[roleName] = ply.WTh_UpgEXPCache[roleName] or {}
            ply.WTh_UpgEXPCache[roleName][upgId] = net.ReadInt(32)
        end
    end

    timer.Simple(0.05, function()
        if IsValid(INTRO_PANEL) and IsValid(INTRO_PANEL.class_frame) and isfunction(INTRO_PANEL.class_frame.RefreshActionContainer) then
            INTRO_PANEL.class_frame.RefreshActionContainer()
        end
    end)
end)