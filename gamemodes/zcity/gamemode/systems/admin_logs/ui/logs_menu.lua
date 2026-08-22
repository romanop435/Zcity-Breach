BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}
BREACH.AdminLogs.UI.Tips = BREACH.AdminLogs.UI.Tips || {}

BREACH.AdminLogs._Cache_Pages = BREACH.AdminLogs._Cache_Pages || {}
BREACH.AdminLogs.UI.SelectedType = BREACH.AdminLogs.UI.SelectedType || "none"
BREACH.RememberNames = BREACH.RememberNames || {}

local rust_bg       = Color(20, 19, 18, 245)
local rust_panel    = Color(15, 14, 13, 250)
local rust_row      = Color(35, 33, 31, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)

local loading_gui = Material("shlogs/loading.png", "noclamp smooth")
BREACH.AdminLogs.CurrentLogs = BREACH.AdminLogs.CurrentLogs || {}

surface.CreateFont( "shlog_button_text", { font = "Hitmarker Normal", size = ScreenScale(6), weight = 300, extended = true } )
surface.CreateFont( "shlog_log_text", { font = "Hitmarker Normal", size = ScreenScale(5.5), weight = 300, extended = true } )
surface.CreateFont( "shlog_log_tip", { font = "Hitmarker Normal", size = ScreenScale(5), weight = 300, extended = true } )
surface.CreateFont( "shlog_switch_text", { font = "Hitmarker Normal", size = ScreenScale(6), weight = 300, extended = true } )

function BREACH.AdminLogs.UI:Tip(text, x, y, color)
	if !color then color = color_white end
	if !x and !y then x, y = gui.MousePos() y = y-20 end
	local tip = vgui.Create("DLabel")
	tip:SetFont("shlog_log_text")
	tip:SetTextColor(color)
	tip:SetText(text)
	tip:SizeToContents()
	tip:SetPos(x-tip:GetWide()/2, y)
	tip:MoveTo(tip:GetX(), y-100, 2, 0)
	tip:AlphaTo(0, 1, 0)
	tip.Think = function(self)
		self:MakePopup()
		self:SetMouseInputEnabled(false)
		self:SetKeyBoardInputEnabled(false)
	end
	timer.Simple(1, function() tip:Remove() end)
end

function BREACH.AdminLogs:CanAskForData()
	if self.UI._UI_LOGS.Logs.loading then return false end
	return true
end

function BREACH.AdminLogs:SwitchPage(page)
	if !self:CanAskForData() then return end
	if BREACH.AdminLogs._Cache_Pages[page] then
		BREACH.AdminLogs.UI._UI_LOGS.Logs:ClearLogs()
		BREACH.AdminLogs.UI:LoadLogs(BREACH.AdminLogs._Cache_Pages[page], page, self.UI._UI_LOGS.LowerPanel.Page_Switcher.pages)
		return
	end
	self.UI._UI_LOGS.Logs.loading = true
	BREACH.AdminLogs.UI._UI_LOGS.Logs:ClearLogs()
	BREACH.AdminLogs:SwtichPage(page, function(logs, page, pages)
		BREACH.AdminLogs.UI:LoadLogs(logs, page, pages)
	end)
end

function BREACH.AdminLogs.UI:CreateLogButton(name, log_class)
	local button = vgui.Create("DButton", self._UI_LOGS.ButtonList)
	local w, h = self._UI_LOGS.ButtonList:GetSize()
	button:SetSize(w-10, 35)
	button:SetText("")
	name = L(name)

	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(name)
	align = align/2

	button.hoverLerp = 0

	button.Paint = function(self, bw, bh)
        local isSelected = (BREACH.AdminLogs.UI.SelectedType == log_class)
        self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)

        local bgCol = Color(
            Lerp(self.hoverLerp, rust_panel.r, rust_row.r),
            Lerp(self.hoverLerp, rust_panel.g, rust_row.g),
            Lerp(self.hoverLerp, rust_panel.b, rust_row.b)
        )

        surface.SetDrawColor(bgCol)
        surface.DrawRect(0, 0, bw, bh)

        if isSelected then
            surface.SetDrawColor(rust_yellow)
            surface.DrawRect(0, 0, 3, bh)
        end

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, bw, bh, 1)

        local txtCol = isSelected and rust_yellow or (self.hoverLerp > 0 and color_white or rust_text)
		draw.DrawText(name, "shlog_button_text", bw/2, bh/2-align, txtCol, TEXT_ALIGN_CENTER)
	end
	button.OnCursorEntered = function(self) surface.PlaySound(BREACH.AdminLogs.Sounds["hover"]) end
	button.DoClick = function(self)
		if !BREACH.AdminLogs:CanAskForData() then return end
		BREACH.AdminLogs.UI.SelectedType = log_class
		BREACH.AdminLogs.UI._UI_LOGS.Logs:ClearLogs()
		BREACH.AdminLogs._Cache_Pages = {}
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
		BREACH.AdminLogs:GetLogs(1, log_class, _, function(logs, page, pages)
			BREACH.AdminLogs.UI:LoadLogs(logs, page, pages)
		end)
	end
	return button
end

local function appearance(pnl, startx, starty)
	local savex, savey = pnl:GetPos()
	pnl:SetPos(startx, starty)
	pnl:MoveTo(savex, savey, 0.6, 0, 0.3)
end

function BREACH.AdminLogs.UI:OpenLogs()
	if !BREACH.AdminLogs:HaveAccess(LocalPlayer()) then return end

	BREACH.AdminLogs.UI.SelectedType = "none"
	local scrw, scrh = ScrW()*.85, ScrH()*.85

	for i, v in player.Iterator() do
		BREACH.RememberNames[v:SteamID64()] = v:Name()
	end

	if IsValid(self._UI_LOGS_DFrame) then self._UI_LOGS_DFrame:Remove() end
	surface.PlaySound(BREACH.AdminLogs.Sounds["log_open"])
    
	self._UI_LOGS_DFrame = vgui.Create("DFrame")
	self._UI_LOGS_DFrame:SetAlpha(0)
	self._UI_LOGS_DFrame:AlphaTo(255, 0.3, 0)
	self._UI_LOGS_DFrame:MakePopup()
	self._UI_LOGS_DFrame:SetZPos(100)
	self._UI_LOGS_DFrame:SetSize(scrw, scrh+30)
	self._UI_LOGS_DFrame:Center()
	self._UI_LOGS_DFrame:SetTitle("")
    self._UI_LOGS_DFrame:ShowCloseButton(true)

	self._UI_LOGS_DFrame.Paint = function(self, w, h)
        if DrawBlurPanel then DrawBlurPanel(self, 3) else BREACH:Blur(self, 5, 255) end
        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, 30)
        
        surface.SetDrawColor(rust_yellow)
        surface.DrawRect(0, 29, w, 2)
        
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleText("АДМИН ЛОГИ", "MM_Exp", 10, 15, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	self._UI_LOGS = vgui.Create("DPanel", self._UI_LOGS_DFrame)
	self._UI_LOGS:SetSize(scrw, scrh)
	self._UI_LOGS:SetPos(0, 30)
	self._UI_LOGS.Paint = function() end

	self._UI_LOGS.ButtonList = vgui.Create("DPanel", BREACH.AdminLogs.UI._UI_LOGS)
	self._UI_LOGS.ButtonList:SetSize(math.floor(scrw*.2), scrh)
	self._UI_LOGS.ButtonList.Paint = function(self, w, h)
		surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(w - 1, 0, w - 1, h)
	end

	appearance(self._UI_LOGS.ButtonList, -self._UI_LOGS.ButtonList:GetWide()-50, 0)

	self._UI_LOGS.Logs = vgui.Create("DScrollPanel", BREACH.AdminLogs.UI._UI_LOGS)
	self._UI_LOGS.Logs:SetSize(scrw-self._UI_LOGS.ButtonList:GetWide(), scrh-50)
	self._UI_LOGS.Logs:SetPos(self._UI_LOGS.ButtonList:GetWide(), 0)

	local vbar = self._UI_LOGS.Logs:GetVBar()
    vbar:SetWide(8)
	function vbar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 200) surface.DrawRect(w/2 - 2, 0, 4, h) end
	function vbar.btnUp:Paint() end
	function vbar.btnDown:Paint() end
	function vbar.btnGrip:Paint(w, h) surface.SetDrawColor(100, 100, 100, 255) surface.DrawRect(w/2 - 2, 0, 4, h) end

	self._UI_LOGS.LowerPanel = vgui.Create("DPanel", BREACH.AdminLogs.UI._UI_LOGS)
	self._UI_LOGS.LowerPanel:SetSize(scrw-self._UI_LOGS.ButtonList:GetWide(), 50)
	self._UI_LOGS.LowerPanel:SetPos(self._UI_LOGS.ButtonList:GetWide(), scrh-50)
	self._UI_LOGS.LowerPanel.Paint = function(self, w, h)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(0, 0, w, 0)
	end

	appearance(self._UI_LOGS.LowerPanel, self._UI_LOGS.LowerPanel:GetX(), scrh+self._UI_LOGS.LowerPanel:GetTall()+50)
	BREACH.AdminLogs.UI:CreateFilterButton(self._UI_LOGS.LowerPanel)

	self._UI_LOGS.LowerPanel.Page_Switcher = vgui.Create("DPanel", self._UI_LOGS.LowerPanel)
	self._UI_LOGS.LowerPanel.Page_Switcher:SetVisible(false)
	self._UI_LOGS.LowerPanel.Page_Switcher:SetSize(210, 33)
	self._UI_LOGS.LowerPanel.Page_Switcher:SetPos(self._UI_LOGS.LowerPanel:GetWide() - 220, self._UI_LOGS.LowerPanel:GetTall()/2-33/2)
	self._UI_LOGS.LowerPanel.Page_Switcher.Paint = function() end
	self._UI_LOGS.LowerPanel.Page_Switcher.pages = 1

	local TextEntry = vgui.Create( "DTextEntry", self._UI_LOGS.LowerPanel.Page_Switcher )
	self._UI_LOGS.LowerPanel.Page_Switcher.TextEntry = TextEntry
	TextEntry:SetSize(40, 23)
	TextEntry:SetText("1")
	TextEntry.page = 1
	TextEntry:SetUpdateOnType(true)
	TextEntry:SetPos(self._UI_LOGS.LowerPanel.Page_Switcher:GetWide()/2-TextEntry:GetWide()/2, 5)

	TextEntry.Paint = function(self, w, h)
        surface.SetDrawColor(10, 9, 8, 255)
		surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0,0,w,h,1)
		draw.DrawText(self:GetText(), "shlog_switch_text", w/2, 2, rust_yellow, TEXT_ALIGN_CENTER)
	end

	TextEntry.OnGetFocus = function(self) self:SetValue("") end
	TextEntry.OnChange = function(self)
		if tonumber(self:GetText()) == nil then self:SetText("") end
	end
	TextEntry.OnEnter = function()
		local num = tonumber(TextEntry:GetValue())
		if isnumber(num) then
			BREACH.AdminLogs:SwitchPage(math.Clamp(num, 1, self._UI_LOGS.LowerPanel.Page_Switcher.pages))
		end
	end

	for i = 1, 2 do
		local _t = self._UI_LOGS.LowerPanel.Page_Switcher:GetTable()
		local _b = vgui.Create("DButton", self._UI_LOGS.LowerPanel.Page_Switcher)
		local label = vgui.Create("DLabel", self._UI_LOGS.LowerPanel.Page_Switcher)
		label:SetFont("shlog_switch_text")
		label:SetText("1  /")
		if i == 2 then label:SetText("\\  1") end
		label:SetTextColor(rust_text_dim)
		_t["button"..i] = _b
		_t["label"..i] = label

		_b:SetSize(50, 33)
		if i == 2 then _b:SetPos(self._UI_LOGS.LowerPanel.Page_Switcher:GetWide()-_b:GetWide(), 0) end
		label:SizeToContents()

		if i == 1 then
			label:SetPos(_b:GetWide() + 10, self._UI_LOGS.LowerPanel.Page_Switcher:GetTall()/2-label:GetTall()/2)
		else
			label:SetPos(_b:GetX()-label:GetWide()-10, self._UI_LOGS.LowerPanel.Page_Switcher:GetTall()/2-label:GetTall()/2)
		end

		local text = (i == 1) and "ПРЕД" or "СЛЕД"
		_b:SetText("")
        _b.hoverLerp = 0
		_b.Paint = function(self, w, h)
            self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
            surface.SetDrawColor(Lerp(self.hoverLerp, rust_row.r, rust_panel.r), Lerp(self.hoverLerp, rust_row.g, rust_panel.g), Lerp(self.hoverLerp, rust_row.b, rust_panel.b), 255)
			surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0,0,w,h,1)
			draw.DrawText(text, "shlog_switch_text", w/2, 5, self.hoverLerp > 0 and color_white or rust_text, TEXT_ALIGN_CENTER)
		end
		_b.DoClick = function()
			if i == 1 then BREACH.AdminLogs:SwitchPage(math.max(1, TextEntry.page - 1))
			else BREACH.AdminLogs:SwitchPage(math.min(self._UI_LOGS.LowerPanel.Page_Switcher.pages, TextEntry.page + 1)) end
		end
	end

	function self._UI_LOGS.LowerPanel:UpdateSwitcher(pages)
		self.Page_Switcher.pages = pages
		local prevsize = self.Page_Switcher.label2:GetWide()
		self.Page_Switcher.label2:SetText("\\  "..pages)
		self.Page_Switcher.label2:SizeToContents()
		local offs = (self.Page_Switcher.label2:GetWide() - prevsize)
		self.Page_Switcher:SetWide(self.Page_Switcher:GetWide() + offs)
		self.Page_Switcher:SetX(self.Page_Switcher:GetX() - offs)
		self.Page_Switcher.button2:SetPos(BREACH.AdminLogs.UI._UI_LOGS.LowerPanel.Page_Switcher:GetWide()-self.Page_Switcher.button2:GetWide(), 0)
		self.Page_Switcher.label2:SetX(self.Page_Switcher.button2:GetX()-self.Page_Switcher.label2:GetWide()-10)
	end

	function self._UI_LOGS.Logs:ClearLogs()
		self:Clear()
		self.loading = true
	end

	self._UI_LOGS.clicker = vgui.Create("DPanel", self._UI_LOGS)
	self._UI_LOGS.clicker:SetSize(0,0)
	self._UI_LOGS.clicker.Paint = function() end
	self._UI_LOGS.clicker:MakePopup()

	self._UI_LOGS.Logs.Paint = function(self, w, h)
		if self.loading then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(loading_gui)
			surface.DrawTexturedRectRotated(w/2, h/2, 35, 35, (RealTime() * 300) % 360)
		end
	end

	self._UI_LOGS.ButtonList.list = {}
	for _, log in pairs(BREACH.AdminLogs.RegisteredLogTypes) do
		local button = BREACH.AdminLogs.UI:CreateLogButton(log.name, log.class)
		button:SetPos(5, 15+button:GetTall()*#self._UI_LOGS.ButtonList.list+5*#self._UI_LOGS.ButtonList.list)
		table.insert(self._UI_LOGS.ButtonList.list, button)
	end
end

function BREACH.AdminLogs.UI:CreateLog(logdata)
	local offset = 20
	local logpanel = vgui.Create("DPanel", self._UI_LOGS.Logs:GetCanvas())
	logpanel:Dock(TOP)
    logpanel:DockMargin(10, 5, 10, 0)
	logpanel:SetSize(self._UI_LOGS.Logs:GetWide() - 20, 50)

	if self.gridcolnext == 0 then self.gridcolnext = 1 else self.gridcolnext = 0 logpanel.dogridcol = true end

	logpanel.Paint = function(self, w, h)
        surface.SetDrawColor(self.dogridcol and Color(30, 28, 25, 200) or Color(0, 0, 0, 100))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 5))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local module = BREACH.AdminLogs:GetLogTypeModule(logdata.type)
	local text = L(module:GetText(logdata))
	text = string.Replace(text, ",", " ,") 
	local current_text = string.Split(text, " ")

	table.insert(current_text, 1, {
			type = ShLogs_RT_date,
			date = logdata.date,
			round = logdata.round,
		})

	local nospaces = {}
	for i, v in pairs(current_text) do
		if v == "," and current_text[i-1] then nospaces[i-1] = true end
		if logdata[v] then
			local col = color_white
			if module.supa_colors and module.supa_colors[v] then col = module.supa_colors[v] end

			if isstring(logdata[v]) then
				local tab = string.Explode(" ", logdata[v])
				for d = 1, #tab do
					local datext = string.Replace(tab[d], " ", "")
					local value = { color = col, text = datext }
					if istable(logdata[datext]) and logdata[datext].isply then
						value = BREACH.AdminLogs:NiceTextPlayer(logdata[datext])
					end
					if d == 1 then current_text[i] = value else table.insert(current_text, i+d-1, value) end
				end
				continue
			end

			current_text[i] = { color = col, text = "NULL" }
			if logdata[v].isply then
				current_text[i] = BREACH.AdminLogs:NiceTextPlayer(logdata[v])
				current_text[i].onclick = function(panel, text_data) BREACH.AdminLogs:CreatePlayerData(logdata.id, logdata[v]) end
				current_text[i].onrightclick = function(panel, text_data)
					local name = logdata[v].sid64
					if BREACH.RememberNames[logdata[v].sid64] then name = BREACH.RememberNames[logdata[v].sid64] end
					local menu = DermaMenu()
					menu:AddOption( name, function() end ):SetIcon("icon16/user.png")
					menu:AddSpacer()
					menu.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color(30,28,25, 240) ) surface.SetDrawColor(Color(255,255,255,10)) surface.DrawOutlinedRect(0,0,w,h,1) end
					if logdata[v].hasnapshot then 
						menu:AddOption( L"l:shlogs_checksnapshot", function() BREACH.AdminLogs:LoadSnapshot(logdata.id) end ):SetIcon( "icon16/chart_bar.png" )
					end
					menu:AddOption( L"l:shlogs_close", function() end )
					menu:Open()
				end
			end
		end
	end

	for i = 1, #current_text - 1 do
		if isstring(current_text[i]) then
			if current_text[i] != " " and current_text[i].text != "" and not nospaces[i] then current_text[i] = current_text[i] .. " " end
		elseif (istable(current_text[i]) and current_text[i].text) then
			if current_text[i].text != " " and current_text[i].text != "" and not nospaces[i] then current_text[i].text = current_text[i].text.." " end
		end
	end

	local rtext_pan = BREACH.AdminLogs.UI:CreateRichText(current_text, 10, 5, logpanel:GetWide()-20, 5, logpanel)
	logpanel:SetTall(rtext_pan:GetTall()+offset)
end

function BREACH.AdminLogs.UI:CreateCombat(logdata)
	local offset = 20
	local logpanel = vgui.Create("DPanel", self._UI_LOGS.Logs:GetCanvas())
	logpanel:Dock(TOP)
    logpanel:DockMargin(10, 5, 10, 0)
	logpanel:SetSize(self._UI_LOGS.Logs:GetWide() - 20, 120)

	if self.gridcolnext == 0 then self.gridcolnext = 1 else self.gridcolnext = 0 logpanel.dogridcol = true end
	logpanel.Paint = function(self, w, h)
        surface.SetDrawColor(self.dogridcol and Color(30, 28, 25, 200) or Color(0, 0, 0, 100))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 5))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local module = BREACH.AdminLogs:GetLogTypeModule(logdata.type)
	BREACH.AdminLogs.UI:CreateCombatPanel(logdata.initiator, logdata.victim, logdata.combat_data, 10, 30, logpanel:GetWide()-40, 80, logpanel, logdata)
	local rtext_pan = BREACH.AdminLogs.UI:CreateRichText({{type = ShLogs_RT_date, date = logdata.date, round = logdata.round}}, 10, 10, logpanel:GetWide()-20, 5, logpanel)
end

function BREACH.AdminLogs.UI:LoadLogs(tab, page, pages)
	self._UI_LOGS.Logs.loading = false
	self.gridcolnext = 0
	BREACH.AdminLogs._Cache_Pages[page] = tab

	self._UI_LOGS.LowerPanel.Page_Switcher:SetVisible(true)
	self._UI_LOGS.LowerPanel.Page_Switcher.TextEntry:SetText(tostring(page))
	self._UI_LOGS.LowerPanel.Page_Switcher.TextEntry.page = page
	self._UI_LOGS.LowerPanel:UpdateSwitcher(pages)

	if tab then
		for _, log in pairs(tab) do
			if log.combat_data then BREACH.AdminLogs.UI:CreateCombat(log)
			else BREACH.AdminLogs.UI:CreateLog(log) end
		end
	end
end

hook.Add( "OnPlayerChatCheck", "shlogs_openmenu", function( ply, strText, bTeam, bDead ) 
	strText = string.lower( strText )
	if ( strText:StartWith("!shlog" ) ) then
		if ply == LocalPlayer() and BREACH.AdminLogs:HaveAccess(ply) then
			LocalPlayer():ConCommand("shlogs_openmenu")
		end
		return true
	end
end )