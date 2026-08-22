BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

BREACH.AdminLogs._DeepInfoCache = BREACH.AdminLogs._DeepInfoCache || {}

local rust_bg       = Color(20, 19, 18, 245)
local rust_panel    = Color(15, 14, 13, 250)
local rust_row      = Color(35, 33, 31, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)

local loading_gui = Material("shlogs/loading.png", "noclamp smooth")
local missingicon = Material("nextoren/gui/new_icons/missing.png", "noclamp smooth")

net.Receive("ShLogs_ReceiveDEEPINFO", function(len)
	local data = net.ReadTable()
	if IsValid(BREACH.AdminLogs.UI.deep_info_loading) then
		BREACH.AdminLogs.UI.deep_info_loading:LoadData(data)
	end
	BREACH.AdminLogs.UI.deep_info_loading = nil
end)

function BREACH.AdminLogs.UI:OpenDeepInfo(playerdata, deep_info)
	if self.deep_info_loading and IsValid(self.deep_info_loading) then return end

	local this = vgui.Create("DFrame", self._UI_LOGS_DFrame)
	self.deep_info_loading = this

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
        draw.SimpleText("ДЕТАЛЬНАЯ ИНФОРМАЦИЯ", "MM_Exp", 10, 12, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if self.loading then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(loading_gui)
			surface.DrawTexturedRectRotated(w/2, h/2, 35, 35, (CurTime() * -300) % 360)
		end
	end

	this.loading = true
	this:SetSize(425, 480)
    this:SetTitle("")
    this:ShowCloseButton(true)
	this:SetPos(self._UI_LOGS_DFrame:GetWide()/2-this:GetWide()/2, self._UI_LOGS_DFrame:GetTall()/2-this:GetTall()/2)

	function this:LoadData(data)
		BREACH.AdminLogs._DeepInfoCache[deep_info] = data
		self.loading = false

		local avatar = vgui.Create("DPanel", self)
		avatar:SetPos(10, 35)
		avatar:SetSize(144, 160)
		avatar.Paint = function(self, w, h)
            surface.SetDrawColor(rust_row)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		local name = vgui.Create("DLabel", avatar)
		name:SetTextColor(color_white)
		name:SetFont("MM_Exp")
		name:SetText( BREACH.RememberNames[playerdata.sid64] )
		name:SizeToContents()
		name:SetPos(avatar:GetWide()/2-name:GetWide()/2, 5)

		local avatarimage = vgui.Create("AvatarImage", avatar)
		avatarimage:SetPos(10, avatar:GetTall()-134)
		avatarimage:SetSize(124,124)
		avatarimage:SetSteamID(playerdata.sid64, 124)

		if data.inventory then
			local Inventory = vgui.Create("DPanel", self)
			Inventory:SetSize(250, 250)
			Inventory:SetPos(10, 35+160+20)
			Inventory.Paint = function(self, w, h)
                surface.SetDrawColor(rust_row)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(rust_outline)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			local scrollweapons = vgui.Create("DScrollPanel", Inventory)
			scrollweapons:SetSize(Inventory:GetWide()-20, Inventory:GetTall()-20)
			scrollweapons:SetPos(10, 10)

			function scrollweapons:AddWeapons(class)
				local weapon = weapons.Get(class)
				local panel = vgui.Create("DPanel", self)
				panel:SetSize(0, 60)
				panel:Dock(TOP)
				panel:DockMargin( 0, 0, 0, 10 )

				panel.Paint = function(self, w, h)
                    surface.SetDrawColor(Color(25, 25, 25, 200))
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(rust_outline)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
				end

				local avatar = vgui.Create("DPanel", panel)
				avatar:SetSize(panel:GetTall()-10, panel:GetTall()-10)
				avatar:SetPos(5, 5)

				if weapon and weapon.InvIcon then avatar.Icon = weapon.InvIcon else avatar.Icon = missingicon end

				avatar.Paint = function(self, w, h)
					surface.SetDrawColor(color_white)
					surface.SetMaterial(self.Icon)
					surface.DrawTexturedRect(0,0,w,h)
				end

				local text = vgui.Create("DLabel", panel)
				local name = class
				if weapon and weapon.PrintName then name = weapon.PrintName end

				text:SetFont("MM_Exp")
				text:SetTextColor(color_white)
				text:SetText(string.upper(name))
				text:SizeToContents()
				text:SetPos(avatar:GetX() + avatar:GetWide() + 10, panel:GetTall()/2-text:GetTall()/2)

				if class == data.activeweapon then
					local awpn = vgui.Create("DLabel", panel)
					awpn:SetFont("MM_SmallName")
					awpn:SetTextColor(rust_yellow)
					awpn:SetText("(В РУКАХ)")
					awpn:SizeToContents()
					awpn:SetPos(text:GetX(), text:GetY()-2-awpn:GetTall())
				end
			end

			for i, v in pairs(data.inventory) do scrollweapons:AddWeapons(v) end
			scrollweapons:GetVBar():SetSize(0, 0)
		end

		local info = vgui.Create("DPanel", self)
		info:SetPos(avatar:GetWide()+avatar:GetX()+10, 35)
		info:SetSize(250,160)
		info.Paint = function(self, w, h)
            surface.SetDrawColor(rust_row)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		local text = {
			"ИМЯ: "..data.charactername,
			"РОЛЬ: "..GetLangRole(playerdata.role),
			"ФРАКЦИЯ: "..gteams.GetName(playerdata.team)
		}

		local y = 10
		for i, v in pairs(text) do
			local text_lbl = vgui.Create("DLabel", info)
			text_lbl:SetFont("MM_Exp")
			text_lbl:SetText(string.upper(L(v)))
			text_lbl:SetTextColor(color_white)
			text_lbl:SizeToContents()
			text_lbl:SetPos(10,y)
			y = y + text_lbl:GetTall() + 10
		end

		info:SetTall(y + 10)
		info:SetY(avatar:GetY()+avatar:GetTall()/2-info:GetTall()/2)

		if data.uniform and #data.uniform > 0 then
			local entity = scripted_ents.Get(data.uniform)
			local uniform = vgui.Create("DPanel", self)
			uniform:SetPos(250+10+10, 250)
			uniform:SetSize(144,160)
			uniform.Paint = function(self, w, h)
                surface.SetDrawColor(rust_row)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(rust_outline)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			local uniform_name = vgui.Create("DLabel", uniform)
			uniform_name:SetTextColor(color_white)
			uniform_name:SetFont("MM_Exp")
			uniform_name:SetText( string.upper(BREACH.TranslateString(entity.PrintName)) )
			uniform_name:SizeToContents()
			uniform_name:SetPos(uniform:GetWide()/2-uniform_name:GetWide()/2, 5)

			local uniform_image = vgui.Create("DPanel", uniform)
			uniform_image:SetPos(10, uniform:GetTall()-134)
			uniform_image:SetSize(124,124)

			if entity and entity.InvIcon then uniform_image.Icon = entity.InvIcon else uniform_image.Icon = missingicon end

			uniform_image.Paint = function(self, w, h)
				surface.SetDrawColor(color_white)
				surface.SetMaterial(self.Icon)
				surface.DrawTexturedRect(0,0,w,h)
			end
		end
	end

	if BREACH.AdminLogs._DeepInfoCache[deep_info] then
		if IsValid(BREACH.AdminLogs.UI.deep_info_loading) then
			BREACH.AdminLogs.UI.deep_info_loading:LoadData(BREACH.AdminLogs._DeepInfoCache[deep_info])
		end
		BREACH.AdminLogs.UI.deep_info_loading = nil
	else
		net.Start("ShLogs_ReceiveDEEPINFO")
		net.WriteUInt(deep_info, 32)
		net.SendToServer()
	end
end