BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

local rust_bg       = Color(20, 19, 18, 245)
local rust_panel    = Color(15, 14, 13, 250)
local rust_row      = Color(35, 33, 31, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local loading_gui   = Material("shlogs/loading.png", "noclamp smooth")

function BREACH.AdminLogs:CreatePlayerData(logid, playerdata)
	local sid64 = playerdata.sid64
	local w, h = 390, 200
	local this = vgui.Create("DFrame", self.UI._UI_LOGS_DFrame)
	self.UI.PlayerPanel = this
	
	self.UI.PlayerPanel:SetSize(w, h + 25)
	self.UI.PlayerPanel:SetPos(self.UI._UI_LOGS_DFrame:LocalCursorPos())
    this:SetTitle("")
    this:ShowCloseButton(true)

	this:SetPos(math.Clamp(this:GetX(), 0, self.UI._UI_LOGS_DFrame:GetWide()-this:GetWide()), math.Clamp(this:GetY(), 0, self.UI._UI_LOGS_DFrame:GetTall()-this:GetTall()))

	this.Paint = function(self, bw, bh)
        if DrawBlurPanel then DrawBlurPanel(self, 3) end
        surface.SetDrawColor(rust_bg)
        surface.DrawRect(0, 0, bw, bh)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, bw, 25)
        surface.SetDrawColor(rust_yellow)
        surface.DrawRect(0, 24, bw, 2)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, bw, bh, 1)
        draw.SimpleText("МЕНЮ ИГРОКА", "MM_Exp", 10, 12, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	self.UI.PlayerPanel.Main = vgui.Create("DPanel", self.UI.PlayerPanel)
	self.UI.PlayerPanel.Main:SetSize(w, h)
	self.UI.PlayerPanel.Main:SetPos(0, 25)
	self.UI.PlayerPanel.Main.loading = true

	function self.UI.PlayerPanel.Main:LoadPlayer(data)
		if self.load then return end
		self.load = true
		self.loading = false

		local avatar = vgui.Create("AvatarImage", self)
		avatar:SetSize(130, 130)
		avatar:SetSteamID(data.sid64, 128)
		avatar:SetPos(20, h-avatar:GetTall()-30)
		avatar.PaintOver = function(self, w, h)
			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0,0,w,h, 1)
		end

		local playername = vgui.Create("DPanel", self)
		playername:SetPos(avatar:GetPos())
		playername:SetSize(avatar:GetWide(), 20)
		playername:SetY(playername:GetY()-playername:GetTall()-5)
		playername.Paint = function(self, w, h)
			draw.DrawText(data.steamName, "MM_Exp", w/2, 0, color_white, TEXT_ALIGN_CENTER)
		end

		local buttons = {
			{
				name = "STEAMID",
				hover_name = util.SteamIDFrom64(data.sid64),
				onfunc = function()
					surface.PlaySound("buttons/button1.wav")
					SetClipboardText(util.SteamIDFrom64(data.sid64))
					BREACH.AdminLogs.UI:Tip("Скопировано!")
				end
			},
			{
				name = "STEAMID64",
				hover_name = data.sid64,
				onfunc = function()
					surface.PlaySound("buttons/button1.wav")
					SetClipboardText(data.sid64)
					BREACH.AdminLogs.UI:Tip("Скопировано!")
				end
			},
			{
				name = "ОТКРЫТЬ ПРОФИЛЬ",
				onfunc = function()
					gui.OpenURL("http://steamcommunity.com/profiles/"..data.sid64)
    				surface.PlaySound("buttons/button9.wav")
				end
			},
			{
				name = "ДЕТАЛЬНАЯ ИНФА",
				deepinfocheck = true,
				onfunc = function()
					BREACH.AdminLogs.UI:OpenDeepInfo(data, data.deepinfoid)
				end
			},
		}

		local offset = 0
		for i = 1, #buttons do
			local _b = buttons[i]
			local button = vgui.Create("DButton", self)
			button:SetSize(200, 25)
			button:SetPos(avatar:GetX() + avatar:GetWide() + 20, 20+offset)
			button:SetText("")
            button.hoverLerp = 0

			if _b.deepinfocheck and !data.deepinfoid then button.locked = true end

			function button:DoClick() _b.onfunc() end

			button.Paint = function(self, w, h)
                self.hoverLerp = math.Approach(self.hoverLerp, self:IsHovered() and 1 or 0, FrameTime() * 12)
				local text = _b.name

				if self:IsHovered() and !self.locked then
					if _b.hover_name then text = _b.hover_name end
				end

                surface.SetDrawColor(rust_row)
                surface.DrawRect(0, 0, w, h)

                if self.hoverLerp > 0 and not self.locked then
                    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * self.hoverLerp)
                    surface.DrawRect(0, 0, w, h)
                end

                surface.SetDrawColor(rust_outline)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                local txtCol = (self.hoverLerp > 0.5 and not self.locked) and Color(15,15,15) or rust_text
				draw.DrawText(text, "MM_Exp", w/2, h/2 - 6, txtCol, TEXT_ALIGN_CENTER)
			end

			if button.locked then button:SetCursor("none") button:SetAlpha(100) end
			offset = offset + button:GetTall() + 10
		end
	end

	if BREACH.RememberNames[sid64] then
		playerdata.steamName = BREACH.RememberNames[sid64]
		this.Main:LoadPlayer(playerdata)
	else
		steamworks.RequestPlayerInfo( sid64, function( steamName )
			playerdata.steamName = steamName
			BREACH.RememberNames[sid64] = steamName
			this.Main:LoadPlayer(playerdata)
		end )
	end

	self.UI.PlayerPanel.Main.Paint = function(self, w, h)
		if self.loading then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(loading_gui)
			surface.DrawTexturedRectRotated(w/2, h/2, 35, 35, (CurTime() * -300) % 360)
		end
	end
end