BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

BREACH.AdminLogs.CurrentFilter = BREACH.AdminLogs.CurrentFilter || {Players = {}, round = 0}

local rust_bg       = Color(20, 19, 18, 245)
local rust_panel    = Color(15, 14, 13, 250)
local rust_row      = Color(35, 33, 31, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)

local function drawbutton(self, w, h)
	self.hoverLerp = math.Approach(self.hoverLerp or 0, self:IsHovered() and 1 or 0, FrameTime() * 12)
    
    surface.SetDrawColor(rust_row)
    surface.DrawRect(0, 0, w, h)

    if self.hoverLerp > 0 then
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * self.hoverLerp)
        surface.DrawRect(0, 0, w, h)
    end

    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    local txtCol = self.hoverLerp > 0.5 and Color(15,15,15) or rust_text
	draw.DrawText(self.Text, "shlog_button_text", w/2, h/2 - self.align, txtCol, TEXT_ALIGN_CENTER)
end

function BREACH.AdminLogs.UI:CreateFilterButton(panel)
	self._FilterPanel = vgui.Create("DPanel", panel)
	self._FilterPanel:SetSize(panel:GetWide()*0.3, panel:GetTall()-20)
	self._FilterPanel:SetPos(10, 10)
	self._FilterPanel.Paint = function() end

	self._FilterPanel.Button = vgui.Create("DButton", self._FilterPanel)
	self._FilterPanel.Button:SetSize(self._FilterPanel:GetSize())
	self._FilterPanel.Button.Text = L"l:shlogs_setfilter"
	self._FilterPanel.Button:SetText("")

	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(self._FilterPanel.Button.Text)
	self._FilterPanel.Button.align = align/2
	self._FilterPanel.Button.hoverLerp = 0
	self._FilterPanel.Button.Paint = drawbutton
	self._FilterPanel.Button.OnCursorEntered = function(self) surface.PlaySound(BREACH.AdminLogs.Sounds["hover"]) end
	self._FilterPanel.Button.DoClick = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
		BREACH.AdminLogs.UI:OpenFilterMenu()
	end
end

function BREACH.AdminLogs.UI:OpenFilterMenu()
	if IsValid(self.FilterMenu) then self.FilterMenu:Remove() end

	local currentfilter = table.Copy(BREACH.AdminLogs.CurrentFilter)
	local this = vgui.Create("DFrame", self._UI_LOGS_DFrame)

	this.Paint = function(self, w, h)
        if DrawBlurPanel then DrawBlurPanel(self, 3) end
        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, w, 25)
        surface.SetDrawColor(rust_yellow)
        surface.DrawRect(0, 24, w, 2)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("ФИЛЬТРЫ", "MM_Exp", 10, 12, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	self.FilterMenu = this
	this:SetSize(300, self._UI_LOGS_DFrame:GetTall()*.8)
	this:SetPos(self._UI_LOGS_DFrame:GetWide()/2-this:GetWide()/2, self._UI_LOGS_DFrame:GetTall()/2-this:GetTall()/2)
    this:SetTitle("")
    this:ShowCloseButton(true)

	local playerlist = vgui.Create("DScrollPanel", this)
	playerlist:SetSize(this:GetWide()-20, this:GetTall()-60-110)
	playerlist:SetPos(10, 35)
	playerlist.FilterName = ""
	playerlist.Paint = function(self, w, h) end

    local vbar = playerlist:GetVBar()
    vbar:SetWide(4)
	function vbar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 200) surface.DrawRect(0, 0, w, h) end
	function vbar.btnUp:Paint() end
	function vbar.btnDown:Paint() end
	function vbar.btnGrip:Paint(w, h) surface.SetDrawColor(100, 100, 100, 255) surface.DrawRect(0, 0, w, h) end

	function playerlist:AddPlayer(sid64, isadd)
		local panel = vgui.Create("DPanel", self)
		panel:SetSize(0, 40)
		panel:Dock(TOP)
		panel:DockMargin( 0, 0, 0, 5 )
		panel.sid64 = sid64
		self.isadd = isadd == true

		panel.Paint = function(self, w, h)
            surface.SetDrawColor(rust_row)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

			if isadd then
				draw.DrawText("+", "shlog_button_text", w-15, h/2 - 8, rust_green, TEXT_ALIGN_RIGHT)
			end
		end

		local avatar = vgui.Create("AvatarImage", panel)
		avatar:SetSize(panel:GetTall()-10, panel:GetTall()-10)
		avatar:SetPos(5, 5)
		avatar:SetSteamID(sid64, 64)

		local text = vgui.Create("DLabel", panel)
		local name = sid64

		if BREACH.RememberNames[name] then
			if BREACH.RememberNames[sid64] and self.FilterName != "" and !string.lower(BREACH.RememberNames[sid64]):find(self.FilterName) then
				panel:Remove()
				return
			end
			name = BREACH.RememberNames[name]
		else
			steamworks.RequestPlayerInfo( name, function( steamName )
				BREACH.RememberNames[name] = steamName
				if BREACH.RememberNames[sid64] and self.FilterName != "" and !string.lower(BREACH.RememberNames[sid64]):find(self.FilterName) then
					if IsValid(panel) then panel:Remove() end
					return
				end
				text:SetText(steamName)
				text:SizeToContents()
			end )
		end

		text:SetFont("shlog_log_text")
		text:SetTextColor(color_white)
		text:SetText(name)
		text:SizeToContents()
		text:SetPos(avatar:GetX() + avatar:GetWide() + 10, panel:GetTall()/2-text:GetTall()/2)

		local butt = vgui.Create("DButton", panel)
		butt:Dock(FILL)
		butt:SetText("")
		butt.Paint = function() end
		butt.DoClick = function(self)
			if isadd then
				if !table.HasValue(currentfilter.Players, sid64) then table.insert(currentfilter.Players, sid64) end
			else
				table.RemoveByValue(currentfilter.Players, sid64)
			end
			playerlist:LoadCurrentFIlter()
		end
	end

	function playerlist:LoadCurrentFIlter()
		playerlist:Clear()
		if currentfilter.Players then
			local list = {}
			for i, v in pairs(currentfilter.Players) do
				table.insert(list, {id = v, name = BREACH.RememberNames[v]})
			end
			table.SortByMember(list, "name")
			for i, v in pairs(list) do playerlist:AddPlayer(v.id) end
		end
	end
	playerlist:LoadCurrentFIlter()

	this.Clear = vgui.Create("DButton", this)
	this.Clear:SetSize(this:GetWide()/3-10, 30)
	this.Clear.Text = "СБРОСИТЬ"
	this.Clear:SetText("")
	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(this.Clear.Text)
	this.Clear.align = align/2
	this.Clear.hoverLerp = 0
	this.Clear.Paint = drawbutton
	this.Clear:SetPos(10, this:GetTall()-40)
	this.Clear.OnCursorEntered = function(self) surface.PlaySound(BREACH.AdminLogs.Sounds["hover"]) end
	this.Clear.DoClick = function(self)
		table.Empty(currentfilter)
		currentfilter.Players = {}
		currentfilter.round = 0
		this.RoundPicker.Trigger.CurValue = 0
		playerlist:LoadCurrentFIlter()
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
	end

	this.RoundPicker = vgui.Create("DPanel", this)
	this.RoundPicker:SetSize(this:GetWide()-20, 30)
	this.RoundPicker:SetPos(10, playerlist:GetY()+playerlist:GetTall()+40)
	this.RoundPicker.Trigger = vgui.Create("DButton", this.RoundPicker)
	this.RoundPicker.Trigger:Dock(FILL)
	this.RoundPicker.Trigger:SetText("")
	this.RoundPicker.Trigger.Paint = function() end
	this.RoundPicker.Trigger.Activated = false
	this.RoundPicker.Trigger.CurValue = currentfilter.round

    this.RoundPicker.Trigger.OnMousePressed = function(self)
        self.savex, self.savey = gui.MousePos()
        self:SetCursor("blank")
        self.Activated = true
    end
    this.RoundPicker.Trigger.OnMouseReleased = function(self)
        self:SetCursor("hand")
        self.Activated = false
    end
    this.RoundPicker.Trigger.Think = function(self)
        if !self:IsHovered() and !input.IsMouseDown(MOUSE_LEFT) and self.Activated then self:OnMouseReleased() end
        if self.Activated then
    		self.CurValue = math.Clamp(self.CurValue - (self.savex - gui.MousePos())*0.01, 0, 10)
    		currentfilter.round = math.floor(self.CurValue)
        	gui.SetMousePos(self.savex, self.savey)
    	end
    end
    this.RoundPicker.Paint = function(self, w, h)
        surface.SetDrawColor(rust_row)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

    	local text = "ВСЕ РАУНДЫ"
    	if self.Trigger.CurValue >= 1 then text = "РАУНД "..tostring(math.floor(self.Trigger.CurValue)) end
    	draw.DrawText(text, "shlog_log_text", w/2, 5, rust_text, TEXT_ALIGN_CENTER)
   	end

	this.Add = vgui.Create("DButton", this)
	this.Add:SetSize(this:GetWide()/3-10, 30)
	this.Add.Text = "ДОБАВИТЬ"
	this.Add:SetText("")
	local _, align2 = surface.GetTextSize(this.Add.Text)
	this.Add.align = align2/2
	this.Add.hoverLerp = 0
	this.Add.Paint = drawbutton
	this.Add:SetPos(10+this:GetWide()/3, this:GetTall()-40)
	this.Add.OnCursorEntered = function(self) surface.PlaySound(BREACH.AdminLogs.Sounds["hover"]) end
	this.Add.DoClick = function(self, forceful)
		if !forceful then surface.PlaySound(BREACH.AdminLogs.Sounds["click"]) end
		if playerlist.isadd and !forceful then
			playerlist:LoadCurrentFIlter()
			playerlist.isadd = false
			return
		end
		local list = {}
		for i, v in player.Iterator() do
			if table.HasValue(currentfilter, v:SteamID64()) then continue end
			BREACH.RememberNames[v:SteamID64()] = v:Name()
			table.insert(list, {id = v:SteamID64(), name = BREACH.RememberNames[v:SteamID64()]})
		end
		if #list == 0 then return end
		playerlist:Clear()
		table.SortByMember(list, "name")
		for i, v in pairs(list) do playerlist:AddPlayer(v.id, true) end
	end

	this.Done = vgui.Create("DButton", this)
	this.Done:SetSize(this:GetWide()/3-10, 30)
	this.Done.Text = "ПРИМЕНИТЬ"
	this.Done:SetText("")
	local _, align3 = surface.GetTextSize(this.Done.Text)
	this.Done.align = align3/2
	this.Done.hoverLerp = 0
	this.Done.Paint = drawbutton
	this.Done:SetPos(this:GetWide()-10-this.Done:GetWide(), this:GetTall()-40)
	this.Done.OnCursorEntered = function(self) surface.PlaySound(BREACH.AdminLogs.Sounds["hover"]) end
	this.Done.DoClick = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
		table.Empty(BREACH.AdminLogs.CurrentFilter)
		BREACH.AdminLogs.CurrentFilter = currentfilter

		net.Start("ShLogs_UpdateFilters")
		net.WriteTable(currentfilter)
		net.SendToServer()
		this:Remove()
	end

	this.TextEntry = vgui.Create( "DTextEntry", this )
	this.TextEntry:SetSize(this:GetWide()-20, 25)
	this.TextEntry:SetPos(10, playerlist:GetY()+playerlist:GetTall()+10)
    this.TextEntry:SetDrawBackground(false)
    this.TextEntry:SetTextColor(color_white)
    this.TextEntry.Paint = function(self, w, h)
        surface.SetDrawColor(10, 9, 8, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(self:HasFocus() and rust_yellow or rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(color_white, rust_yellow, color_white)
        if self:GetText() == "" and not self:HasFocus() then
            draw.SimpleText("ПОИСК ИГРОКА...", "shlog_log_text", 5, h/2, rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
	this.TextEntry.Think = function( self )
		local value = string.lower(self:GetValue())
		if value != playerlist.FilterName then
			playerlist.FilterName = string.lower(self:GetValue())
			if playerlist.isadd then
				this.Add.DoClick(this.Add, true)
			else
				playerlist:LoadCurrentFIlter()
			end
		end
	end
end