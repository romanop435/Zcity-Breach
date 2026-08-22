local surface = surface
local draw = draw
local math = math
local string = string
local vgui = vgui

RanksIcons = {}
RanksIcons["owner"] = "icon16/key.png"
RanksIcons["founder"] = "icon16/key.png"
RanksIcons["superadmin"] = "icon16/shield_add.png"
RanksIcons["admin"] = "icon16/shield.png"
RanksIcons["moderator"] = "icon16/star.png"
RanksIcons["vip"] = "icon16/star.png"
RanksIcons["user"] = "icon16/user.png"

GROUP_COUNT = 3

local SB_ROW_HEIGHT = ScrH() * 32 / 1080

BREACH.FLAGS = BREACH.FLAGS || {}

function PrecacheAllFlags()
  local materials = file.Find("materials/flags16/*", "GAME")
  for _, v in pairs(materials) do
    local name = string.upper(string.StripExtension(v))
    BREACH.FLAGS[name] = "flags16/"..v
  end
end

hook.Add("InitPostEntity", "precache_flags", function()
  PrecacheAllFlags()
end)

local function ScaleX(x) return math.ceil(ScrW() * x / 1920) end
local function ScaleY(y) return math.ceil(ScrH() * y / 1080) end

local rust_bg       = Color(25, 24, 22, 240)    
local rust_panel    = Color(18, 16, 15, 255)    
local rust_row      = Color(40, 38, 35, 255)    
local rust_outline  = Color(255, 255, 255, 10)  
local rust_green    = Color(112, 126, 73)       
local rust_red      = Color(188, 64, 43)        
local rust_yellow   = Color(218, 165, 32)       
local rust_text     = Color(230, 230, 230)      
local rust_text_dim = Color(140, 140, 140)      
local rust_superadmin = Color(220, 70, 70)      

local blurMat = Material("pp/blurscreen")
local function DrawModernBlur(x, y, w, h, amount)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blurMat)
    for i = 1, 3 do
        blurMat:SetFloat("$blur", (i / 3) * (amount or 6))
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

function ScoreGroup(p)
    if (!IsValid(p)) then return -999 end
    return p:GTeam()
end

function PaintVBar(vbar)
    vbar:SetHideButtons(true)
    vbar.Paint = function(self, w, h)
        surface.SetDrawColor(10, 10, 10, 200)
        surface.DrawRect(w / 2 - ScaleX(2), 0, ScaleX(4), h)
    end
    vbar.btnGrip.Paint = function(self, w, h)
        surface.SetDrawColor(self:IsHovered() and 100 or 80, 80, 80, 255)
        surface.DrawRect(w / 2 - ScaleX(2), 0, ScaleX(4), h)
    end
    vbar.btnUp.Paint = function() end
    vbar.btnDown.Paint = function() end
end

local PANEL = {}

local OFFSET_PING = ScaleX(60)
local OFFSET_KARMA = ScaleX(140)
local OFFSET_LEVEL = ScaleX(220)
local OFFSET_ACH = ScaleX(340)
local OFFSET_RANK = ScaleX(420)
local OFFSET_BOT = ScaleX(500)
-- local OFFSET_CODER = ScaleX(500)
function PANEL:Init()   
    self.hostname = vgui.Create("DLabel", self) 
    self.hostname:SetText("")

    self.ply_frame = vgui.Create("DScrollPanel", self)
    PaintVBar(self.ply_frame:GetVBar())

    self.ply_groups = {}
    for k, v in ipairs(gteams.Teams) do
        local GroupPos = k
        local t = vgui.Create("BrScoreGroup", self.ply_frame)
        t:Dock(TOP)
        t:DockMargin(0, 0, 0, ScaleY(10))
        self.ply_groups[GroupPos] = t
    end

    self.cols = {}
    self:AddColumn(BREACH.TranslateString("l:scoreboard_ping"), OFFSET_PING)
    self:AddColumn(BREACH.TranslateString("l:scoreboard_karma"), OFFSET_KARMA)
    self:AddColumn(BREACH.TranslateString("l:scoreboard_level"), OFFSET_LEVEL)
    self:AddColumn(BREACH.TranslateString("l:scoreboard_achievements"), OFFSET_ACH)

    hook.Call("BrScoreboardColumns", nil, self)

    self:UpdateScoreboard()
    self:StartUpdateTimer()
end

function PANEL:AddColumn(label, rightOffset)
    local lbl = vgui.Create("DLabel", self)
    lbl:SetText(string.upper(label))
    lbl.IsHeading = true
    lbl.RightOffset = rightOffset
    table.insert(self.cols, lbl)
    return lbl
end

function PANEL:StartUpdateTimer()
    timer.Create("BrScoreboardUpdate", 0.5, 0, function()
        if IsValid(self) then 
            self:UpdateScoreboard() 
        else
            timer.Remove("BrScoreboardUpdate")
        end
    end)
end

function PANEL:Paint(w, h)
    local headHeight = ScaleY(40) 
    
    if SigmaYgliDraw then
        SigmaYgliDraw(0, headHeight, w, h - headHeight, color_white, 0)
    else
        DrawModernBlur(0, headHeight, w, h - headHeight, 5)
    end
    
    surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, rust_bg.a)
    surface.DrawRect(0, headHeight, w, h - headHeight)
    
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, headHeight)
    
    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
    surface.DrawRect(0, headHeight - 2, w, 2)

    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function PANEL:PerformLayout()
    local w = math.max(ScrW() * .6, ScaleX(800))
    local screenheight = ScrH()
    local headHeight = ScaleY(40)
    local padding = ScaleY(10)
    
    local startY = screenheight * 0.1 
    local maxH = screenheight - (startY * 2)

    local contentHeight = 0
    for _, group in pairs(self.ply_groups) do
        if group:IsVisible() then
            contentHeight = contentHeight + group:GetTall() + ScaleY(10)
        end
    end

    local h = headHeight + padding * 2 + contentHeight
    local scrolling = h > maxH
    h = math.Clamp(h, headHeight + padding * 2, maxH)

    self:SetSize(w, h)
    self:SetPos((ScrW() - w) / 2, startY)

    self.ply_frame:SetPos(ScaleX(10), headHeight + padding) 
    self.ply_frame:SetSize(self:GetWide() - ScaleX(20), self:GetTall() - headHeight - padding * 2)

    self.hostname:SetSize(w, headHeight)
    self.hostname:SetPos(ScaleX(20), 0)
    self.hostname:SetText("UTOPIA BREACH  //  " .. string.upper(BREACH.TranslateString("l:scoreboard_rounds_left")) .. ": " .. GetGlobalInt("RoundUntilRestart", 1))
    self.hostname:SetContentAlignment(4)

    local headerBaseRight = w - ScaleX(10) - (scrolling and ScaleX(16) or 0)

    for i, v in ipairs(self.cols) do
        v:SizeToContents()
        v:SetPos(headerBaseRight - v.RightOffset - (v:GetWide() / 2), (headHeight - v:GetTall()) / 2)
    end
end

function PANEL:ApplySchemeSettings()
    self.hostname:SetFont("MogM_6") 
    self.hostname:SetTextColor(rust_yellow)
    for _, v in ipairs(self.cols) do
        v:SetFont("MogM_5")
        v:SetTextColor(rust_text_dim)
    end
end

function PANEL:UpdateScoreboard(force)
    if (!force and !self:IsVisible()) then return end

    for k, v in ipairs(gteams.Teams) do
        local GroupPos = k - 1
        if (!self.ply_groups[GroupPos]) then
            local t = vgui.Create("BrScoreGroup", self.ply_frame)
            t:Dock(TOP)
            t:DockMargin(0, 0, 0, ScaleY(10))
            self.ply_groups[GroupPos] = t
        end
        self.ply_groups[GroupPos]:SetGroupInfo(BREACH.TranslateNonPrefixedString(v.name), v.color, GroupPos)
    end

    for _, p in player.Iterator() do
        if (p and p:IsValid()) then
            local group = ScoreGroup(p)
            if (self.ply_groups[group] and !self.ply_groups[group]:HasPlayerRow(p)) then
                self.ply_groups[group]:AddPlayerRow(p)
            end
        end
    end

    for _, group in pairs(self.ply_groups) do
        if (ValidPanel(group)) then
            group:UpdatePlayerData()
        end
    end
    
    self:InvalidateLayout(true) 
end
vgui.Register("BrScoreboard", PANEL, "Panel")




local function SuperadminIndicatorText(ply)
    if (ply:IsSuperAdmin()) then
        return "Super Admin"
    elseif (ply:IsAdmin()) then
        return "Admin"
    elseif (ply:IsUserGroup("moderator")) then
        return "Moderator"
    elseif (ply:IsUserGroup("vip")) then
        return "VIP"
    end
    return ""
end

local function IsBot(ply)
    return ply:IsBot()
end


local PANEL_ROW = {}

function PANEL_ROW:Init()
    self.HoverLerp = 0 
    self.cols = {}
    
    self:AddColumn("Ping", function(p) return "" end, OFFSET_PING)
    self:AddColumn("Karma", function(p) return tonumber(p:GetNWInt("karma", 0)) end, OFFSET_KARMA)
    self:AddColumn("Level", function(p) return p.GetNLevel and p:GetNLevel() or 0 end, OFFSET_LEVEL)
    self:AddColumn("Ach", function(p) return (p:GetAchievementsNum() or 0) .. " / 31" end, OFFSET_ACH)
    self.rankLabel = self:AddColumn("Rank", function(p) return SuperadminIndicatorText(p) end, OFFSET_RANK)
    self.botLabel = self:AddColumn("Bot", function(p) return IsBot(p) and "IS BOT" or "" end, OFFSET_BOT)

    self.tag = vgui.Create("DLabel", self)
    self.tag:SetMouseInputEnabled(false)

    self.rank = vgui.Create("DImage", self)
    self.avatar = vgui.Create("AvatarImage", self)
    self.avatar:SetMouseInputEnabled(false)

    self.nick = vgui.Create("DLabel", self)
    self.nick:SetMouseInputEnabled(false)

    self.voice = vgui.Create("DImageButton", self)
    self:SetCursor("hand")
end

function PANEL_ROW:AddColumn(label, func, rightOffset)
    local lbl = vgui.Create("DLabel", self)
    lbl.GetPlayerText = func
    lbl.RightOffset = rightOffset
    table.insert(self.cols, lbl)
    return lbl
end

local function DrawPingBars(ping, x, y)
    local bars = 3
    local clr = rust_green
    if ping > 200 then bars = 1 clr = rust_red
    elseif ping > 100 then bars = 2 clr = rust_yellow end

    for i = 1, 3 do
        local h = ScaleY(6) + (i * ScaleY(4))
        local drawClr = i <= bars and clr or Color(60, 60, 60, 150)
        surface.SetDrawColor(drawClr)
        surface.DrawRect(x + (i * ScaleX(5)), y - h / 2, ScaleX(3), h)
    end
    draw.DrawText(ping, "MogM_5", x + ScaleX(22), y - ScaleY(6), rust_text, TEXT_ALIGN_LEFT)
end

function PANEL_ROW:Paint(w, h)
    if (!IsValid(self.Player)) then return end
    
    local targetLerp = (self:IsHovered() or self.Player == LocalPlayer()) and 1 or 0
    self.HoverLerp = math.Approach(self.HoverLerp, targetLerp, FrameTime() * 10)

    surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
    surface.DrawRect(0, 0, w, h)

    local teamColor = gteams.GetColor(self.Player:GTeam()) or color_white
    surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, 255)
    surface.DrawRect(0, 0, ScaleX(4), h)

    if self.HoverLerp > 0 then
        surface.SetDrawColor(255, 255, 255, 10 * self.HoverLerp)
        surface.DrawRect(0, 0, w, h)
    end

    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    if (self.Player and self.Player:IsValid()) then
        local pingX = w - self.cols[1].RightOffset - ScaleX(18) 
        DrawPingBars(self.Player:Ping(), pingX, h / 2)
    end
    return true
end

function PANEL_ROW:SetPlayer(ply)
    self.Player = ply
    self.avatar:SetPlayer(ply)
    self.voice.DoClick = function()
        if (IsValid(ply) and ply ~= LocalPlayer()) then ply:SetMuted(!ply:IsMuted()) end
    end
    self:UpdatePlayerData()
end
function PANEL_ROW:GetPlayer() return self.Player end

function PANEL_ROW:UpdatePlayerData()
    if (!IsValid(self.Player)) then return end
    local ply = self.Player

    for i = 1, #self.cols do
        self.cols[i]:SetText(self.cols[i].GetPlayerText(ply, self.cols[i]))
        self.cols[i]:SetFont("MogM_5")
        self.cols[i]:SetTextColor(rust_text)
    end
    local rankColor = ply:IsSuperAdmin() and rust_superadmin or rust_text
    self.rankLabel:SetTextColor(rankColor)

    local name = ply:Nick()
    if ply:GTeam() != TEAM_SPEC and ply.GetNamesurvivor and ply:GetNamesurvivor() != "none" then
        name = name .. " (" .. ply:GetNamesurvivor() .. ")"
    end
    self.nick:SetText(name)
    self.nick:SetFont("MogM_5")
    self.nick:SetTextColor(rust_text)
    self.nick:SizeToContents()
    
    local ug = ply:GetUserGroup()

    local icon = "icon16/user.png"
    local countryCode = ply:GetNWString("country", "")

    if countryCode != "" then
        icon = "flags16/" .. string.lower(countryCode) .. ".png"
    end

    if RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[ply:SteamID64()] then
        icon = "icon16/user_red.png"
    elseif ug == "superadmin" then 
        icon = "flags16/ua.png"
    elseif ug == "headadmin" then 
        icon = "icon16/shield_add.png"
    elseif ug == "event" then 
        icon = "icon16/flag_purple.png"
    elseif ply:IsAdmin() then
        icon = "nextoren_hud/scoreboard/shield.png"
    elseif ug == "cm" then 
        icon = "icon16/user_gray.png"
    elseif ug == "donator" then
        icon = "icon16/ruby.png"
    elseif ug == "premium" and ply:GetNWBool("display_premium_icon", true) then
        icon = "icon16/medal_gold_1.png"
    elseif RanksIcons[ug] and ug != "user" then 
        icon = RanksIcons[ug]
    end

    self.rank:SetImage(icon)
    
    local displayRank = ug
    if RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[ply:SteamID64()] then displayRank = "YouTube" end
    self.rank:SetTooltip(string.upper(string.sub(displayRank, 1, 1)) .. string.sub(displayRank, 2))

    local roleName = GetLangRole and GetLangRole(ply:GetRoleName()) or ply:GetRoleName() or ""
    local pl_team = ply:GTeam() or TEAM_SPEC

    self.tag:SetText(roleName)
    
    if (pl_team == TEAM_USA or pl_team == TEAM_QRT or pl_team == TEAM_NAZI) then
        self.tag:SetTextColor(ColorAlpha(color_white, 190))
    else
        self.tag:SetTextColor(gteams.GetColor(pl_team) or color_white)
    end

    self.tag:SetFont("MogM_5")
    self:LayoutColumns()
end

function PANEL_ROW:LayoutColumns()
    local w = self:GetWide()
    local cy = (SB_ROW_HEIGHT - ScaleY(14)) / 2

    for i, v in ipairs(self.cols) do
        v:SizeToContents()
--         [ERROR] gamemodes/zcity/gamemode/game/client/scoreboard.lua:414: attempt to perform arithmetic on field 'RightOffset' (a nil value)
--   1. LayoutColumns - gamemodes/zcity/gamemode/game/client/scoreboard.lua:414
--    2. unknown - gamemodes/zcity/gamemode/game/client/scoreboard.lua:431
-- я просто не добавил оффсет рангов (  - by jiner
        v:SetPos(w - v.RightOffset - (v:GetWide() / 2), cy)
    end
    
    self.tag:SizeToContents()
    self.tag:SetPos((w - self.tag:GetWide()) / 2, cy)
end

function PANEL_ROW:PerformLayout()
    self.avatar:SetPos(ScaleX(12), ScaleY(4))
    self.avatar:SetSize(SB_ROW_HEIGHT - ScaleY(8), SB_ROW_HEIGHT - ScaleY(8))

    self.rank:SetPos(SB_ROW_HEIGHT + ScaleX(8), (SB_ROW_HEIGHT - ScaleY(16)) / 2)
    self.rank:SetSize(ScaleX(16), ScaleY(16))

    self.nick:SetPos(SB_ROW_HEIGHT + ScaleX(32), (SB_ROW_HEIGHT - self.nick:GetTall()) / 2)
    self:SetSize(self:GetWide(), SB_ROW_HEIGHT)

    self:LayoutColumns()

    self.voice:SetSize(ScaleX(16), ScaleY(16))
    self.voice:SetPos(self:GetWide() - ScaleX(24), (SB_ROW_HEIGHT - ScaleY(16))/2 )
end

function PANEL_ROW:DoRightClick()
    local menu = DermaMenu(self)
    menu.Player = self:GetPlayer()

    local close = hook.Call("BrScoreboardMenu", nil, menu)
    if (close) then menu:Remove() end

    if RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[menu.Player:SteamID64()] then
        menu:AddOption("YouTube Channel", function()
            gui.OpenURL(RXSEND_YOUTUBERS[menu.Player:SteamID64()])
            surface.PlaySound("buttons/button9.wav")
        end):SetIcon("icon16/user_red.png")
    end

    menu:AddSpacer()

    local CopyMenu = menu:AddSubMenu("Copy")
    CopyMenu:AddOption(menu.Player:Nick(true), function() SetClipboardText(menu.Player:Nick(true)) surface.PlaySound("buttons/button9.wav") end):SetIcon("icon16/page_copy.png")
    CopyMenu:AddOption("SteamID", function() SetClipboardText(menu.Player:SteamID()) surface.PlaySound("buttons/button9.wav") end):SetIcon("icon16/page_copy.png")
    CopyMenu:AddOption("SteamID64", function() SetClipboardText(menu.Player:SteamID64()) surface.PlaySound("buttons/button9.wav") end):SetIcon("icon16/page_copy.png")

    if not menu.Player:IsBot() then
        menu:AddOption("Open Achievements", function()
            if OpenAchievementTab then OpenAchievementTab(menu.Player) end
            surface.PlaySound("buttons/button9.wav")
        end):SetIcon("icon16/chart_bar.png")
    end

    menu:AddOption("Open Steam Community URL", function()
        gui.OpenURL("http://steamcommunity.com/profiles/"..menu.Player:SteamID64())
        surface.PlaySound("buttons/button9.wav")
    end):SetIcon("icon16/world_link.png")

    menu:AddSpacer()
    menu:Open()

    menu.Paint = function(self_menu, w, h)
        if (!GAMEMODE.ShowScoreboard) then self_menu:Remove() end
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end
vgui.Register("BrScoreboardPlayerRow", PANEL_ROW, "Button")


local PANEL_GROUP = {}

function PANEL_GROUP:Init()
    self.color = Color(255, 255, 255)
    self.rows = {}
    self.rowcount = 0
    self.rows_sorted = {}
end

function PANEL_GROUP:SetGroupInfo(name, color, group)
    self.name = name
    self.color = color or color_white
    self.group = group
end

function PANEL_GROUP:Paint(w, h)
    local headerHeight = ScaleY(24)
    
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, headerHeight)
    
    surface.SetDrawColor(self.color.r, self.color.g, self.color.b, 255)
    surface.DrawRect(0, 0, ScaleX(4), headerHeight)

    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, headerHeight, 1)

    local txt = string.upper(self.name) .. " — " .. self.rowcount
    draw.SimpleText(txt, "MogM_5", ScaleX(12), headerHeight / 2, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL_GROUP:AddPlayerRow(ply)
    if (!self.rows[ply]) then
        local row = vgui.Create("BrScoreboardPlayerRow", self)
        row:SetPlayer(ply)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, ScaleY(2))
        row:SetTall(SB_ROW_HEIGHT)

        self.rows[ply] = row
        self.rowcount = table.Count(self.rows)
        self:InvalidateLayout(true)
    end
end

function PANEL_GROUP:HasPlayerRow(ply) return self.rows[ply] != nil end
function PANEL_GROUP:HasRows() return self.rowcount > 0 end

function PANEL_GROUP:UpdateSortCache()
    self.rows_sorted = {}
    for _, v in pairs(self.rows) do table.insert(self.rows_sorted, v) end
    table.sort(self.rows_sorted, function(a, b)
        if (!ValidPanel(a) or !IsValid(a:GetPlayer())) then return false end
        if (!ValidPanel(b) or !IsValid(b:GetPlayer())) then return true end
        return a:GetPlayer():Frags() > b:GetPlayer():Frags()
    end)
    
    for i, row in ipairs(self.rows_sorted) do
        row:SetZPos(i)
    end
end

function PANEL_GROUP:UpdatePlayerData()
    local to_remove = {}
    for k, v in pairs(self.rows) do
        if (ValidPanel(v) and IsValid(v:GetPlayer()) and ScoreGroup(v:GetPlayer()) == self.group) then
            v:UpdatePlayerData()
        else
            table.insert(to_remove, k)
        end
    end
    for _, ply in pairs(to_remove) do
        if (ValidPanel(self.rows[ply])) then self.rows[ply]:Remove() end
        self.rows[ply] = nil
    end
    self.rowcount = table.Count(self.rows)
    self:UpdateSortCache()
    self:InvalidateLayout(true) 
end

function PANEL_GROUP:PerformLayout()
    if (self.rowcount < 1) then
        self:SetVisible(false)
        return
    end
    self:SetVisible(true)
    self:UpdateSortCache()
    
    local headerHeight = ScaleY(24)
    self:DockPadding(0, headerHeight, 0, 0)
    
    local expectedHeight = headerHeight + (self.rowcount * (SB_ROW_HEIGHT + ScaleY(2)))
    self:SetTall(expectedHeight)
end
vgui.Register("BrScoreGroup", PANEL_GROUP, "Panel")


GM = GM or GAMEMODE
local sboard_panel = nil

local function ScoreboardRemove()
    if (sboard_panel) then
        sboard_panel:Remove()
        sboard_panel = nil
    end
end

function GM:ScoreboardCreate()
    ScoreboardRemove()
    sboard_panel = vgui.Create("BrScoreboard")
end

function GM:ScoreboardShow()
    if not LocalPlayer():IsSuperAdmin() then
        if not (LocalPlayer():GTeam() == TEAM_SPEC or LocalPlayer():GTeam() == TEAM_ARENA) then return end
    end
    self.ShowScoreboard = true
    if (!IsValid(sboard_panel)) then self:ScoreboardCreate() end
    gui.EnableScreenClicker(true)
    sboard_panel:SetVisible(true)
    sboard_panel:UpdateScoreboard(true)
end

function GM:ScoreboardHide()
    self.ShowScoreboard = false
    gui.EnableScreenClicker(false)
    if (IsValid(sboard_panel)) then sboard_panel:SetVisible(false) end
end