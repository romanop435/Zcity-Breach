local function BreachAchiv_GetTable()
	net.Start("GetAchievementTable")
	net.SendToServer()
end

hook.Add("InitPostEntity", "BreachAchiv_GetTable", BreachAchiv_GetTable)

BreachAchievements = BreachAchievements or {}
BreachAchievements.AchievementTable = BreachAchievements.AchievementTable or {}

local mply = FindMetaTable("Player")

net.Receive("GetAchievementTable", function()
	local _t = net.ReadTable()
	BreachAchievements = BreachAchievements or {}
	BreachAchievements.AchievementTable = _t
end)

function OpenAchievementTab(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	net.Start("OpenAchievementMenu")
	net.WriteEntity(ply)
	net.SendToServer()
end

function mply:GetAchievementsNum()
	return self:GetNWInt("CompletedAchievements", 0)
end

function mply:CompleteAchievement(achivname)
	net.Start("CompleteAchievement_Clientside")
	net.WriteString(achivname)
	net.SendToServer()
end

FUNNYACHIEVEMENTS = {
	{
		achievements_name = "Developer",
		desc = "",
		image = "nextoren/achievements/ahive5.jpg",
		owners = {},
		ownersusergroup = {"headadmin"},
	},
	{
		achievements_name = "Admin",
		desc = "Следит за твоей попкой",
		image = "nextoren/achievements/ahive146.jpg",
		owners = {},
		ownersusergroup = {"spectator", "admin", "headadmin"},
	},
	{
		achievements_name = "Alpha-Tester",
		desc = "",
		image = "nextoren/achievements/ahive2.jpg",
		owners = {},
		ownersusergroup = {},
		customcheck = function(ply) return ply:GetNWBool("AlphaTester") end,
	},
	{
		achievements_name = "Застройщик",
		desc = "Помощь в застройке карты",
		image = "nextoren/achievements/ahive147.jpg",
		owners = {"STEAM_0:1:451986387" , "STEAM_0:0:453237891" ,"STEAM_0:0:34907980" , "76561198359356778"  },
		ownersusergroup = {},
	},
	{
		achievements_name = "Мастер",
		desc = "Собрал все ачивки первее всех",
		image = "nextoren/achievements/ahive5.jpg",
		owners = {"76561198180995835"},
		ownersusergroup = {}
	}
}

if CLIENT then

	surface.CreateFont("Achiv_Title", { font = "Hitmarker Normal", size = 18, weight = 800, extended = true })
	surface.CreateFont("Achiv_Text", { font = "Hitmarker Normal", size = 16, weight = 600, extended = true })
	surface.CreateFont("Achiv_Small", { font = "Hitmarker Normal", size = 12, weight = 600, extended = true })
	surface.CreateFont("Achiv_Header", { font = "Hitmarker Normal", size = 26, weight = 800, extended = true })

	local rust_bg       = Color(25, 24, 22, 250)
	local rust_card     = Color(45, 43, 40, 255)
	local rust_outline  = Color(255, 255, 255, 10)
	local rust_green    = Color(112, 126, 73)
	local rust_red      = Color(188, 64, 43)
	local rust_yellow   = Color(218, 165, 32)
	local rust_text     = Color(230, 230, 230)
	local rust_dim      = Color(140, 140, 140)
	local rust_panel    = Color(30, 28, 25, 255)

	function OpenAchievementList(ply, tab, completedtab)
		BreachAchievements.GUI = BreachAchievements.GUI or {}

		if IsValid(BreachAchievements.GUI.Panel) then BreachAchievements.GUI.Panel:Remove() end

		local w, h = 900, ScrH() - 150

		BreachAchievements.GUI.Panel = vgui.Create("EditablePanel")
		local main_pnl = BreachAchievements.GUI.Panel
		main_pnl:SetSize(w, h)
		main_pnl:Center()
		main_pnl:MakePopup()

		main_pnl.Paint = function(self, pw, ph)
			surface.SetDrawColor(rust_bg)
			surface.DrawRect(0, 0, pw, ph)

			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0, 0, pw, ph, 2)

			draw.SimpleText("ЗАЛ ДОСТИЖЕНИЙ", "Achiv_Header", 30, 25, rust_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText("" .. string.upper(ply:Name()), "Achiv_Title", 30, 55, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			surface.SetDrawColor(rust_yellow)
			surface.DrawRect(30, 85, pw - 60, 2)
		end

		local closeBtn = vgui.Create("DButton", main_pnl)
		closeBtn:SetSize(40, 40)
		closeBtn:SetPos(w - 50, 15)
		closeBtn:SetText("X")
		closeBtn:SetFont("Achiv_Header")
		closeBtn:SetTextColor(rust_dim)
		closeBtn.Paint = function(self, bw, bh)
			if self:IsHovered() then
				self:SetTextColor(rust_red)
			else
				self:SetTextColor(rust_dim)
			end
		end
		closeBtn.DoClick = function()
			main_pnl:Remove()
		end

		local Scroll = vgui.Create("DScrollPanel", main_pnl)
		Scroll:SetPos(30, 105)
		Scroll:SetSize(w - 60, h - 125)

		local sbar = Scroll:GetVBar()
		sbar:SetWide(8)
		function sbar:Paint(bw, bh) surface.SetDrawColor(10, 10, 10, 255) surface.DrawRect(0, 0, bw, bh) end
		function sbar.btnUp:Paint() end
		function sbar.btnDown:Paint() end
		function sbar.btnGrip:Paint(bw, bh) surface.SetDrawColor(140, 140, 140, 255) surface.DrawRect(0, 0, bw, bh) end

		local Grid = vgui.Create("DIconLayout", Scroll)
		Grid:Dock(FILL)
		Grid:SetSpaceX(15)
		Grid:SetSpaceY(15)

		local cardW = math.floor((Scroll:GetWide() - 15 - 15) / 2)
		local cardH = 100

		for i = 1, #FUNNYACHIEVEMENTS do
			local tabl = FUNNYACHIEVEMENTS[i]
			if not table.HasValue(tabl.owners, ply:SteamID()) and not table.HasValue(tabl.owners, ply:SteamID64()) and not table.HasValue(tabl.ownersusergroup, ply:GetUserGroup()) and not tabl.customcheck then continue end
			if (isfunction(tabl.customcheck) and not tabl.customcheck(ply)) then continue end
			
			local Card = Grid:Add("DPanel")
			Card:SetSize(cardW, cardH)
			
			local image = Material(tabl.image, "smooth")
			local accent = Color(0, 200, 220) 
			
			Card.Paint = function(self, pw, ph)
				surface.SetDrawColor(rust_card)
				surface.DrawRect(0, 0, pw, ph)

				surface.SetDrawColor(accent.r, accent.g, accent.b, 15)
				surface.DrawRect(0, 0, pw, ph)

				surface.SetDrawColor(accent)
				surface.DrawRect(0, 0, pw, 4)

				surface.SetDrawColor(rust_outline)
				surface.DrawOutlinedRect(0, 0, pw, ph, 1)

				draw.RoundedBox(0, 15, 15, 70, 70, Color(15, 15, 15, 200))
				surface.SetDrawColor(color_white)
				surface.SetMaterial(image)
				surface.DrawTexturedRect(18, 18, 64, 64)
				surface.SetDrawColor(accent)
				surface.DrawOutlinedRect(15, 15, 70, 70, 1)

				draw.SimpleText(string.upper(tabl.achievements_name), "Achiv_Title", 100, 18, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

				surface.SetFont("Achiv_Small")
				local tw, th = surface.GetTextSize("УНИКАЛЬНАЯ")
				local tagW = tw + 20
				draw.RoundedBox(0, pw - tagW - 10, ph - 30, tagW, 20, Color(20, 20, 20, 230))
				draw.SimpleText("УНИКАЛЬНАЯ", "Achiv_Small", pw - tagW/2 - 10, ph - 20, accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local DescLabel = vgui.Create("DLabel", Card)
			DescLabel:SetPos(100, 42)
			DescLabel:SetSize(cardW - 115, 45)
			DescLabel:SetFont("Achiv_Small")
			DescLabel:SetTextColor(rust_dim)
			DescLabel:SetText(tabl.desc)
			DescLabel:SetWrap(true)
			DescLabel:SetContentAlignment(7)
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
			
			if tabl.secret and not iscompleted then continue end
			
			local Card = Grid:Add("DPanel")
			Card:SetSize(cardW, cardH)
			
			local image = Material(tabl.image, "smooth")
			
			local accent = iscompleted and rust_green or rust_red
			local glowAlpha = 0
			local rarityText = nil

			if tabl.mega then 
				accent = Color(164, 90, 214) 
				glowAlpha = iscompleted and 30 or 0
				rarityText = "МЕГА"
			elseif tabl.secret then 
				accent = Color(255, 187, 0) 
				glowAlpha = iscompleted and 20 or 0
				rarityText = "СЕКРЕТНАЯ"
			end

			local addon = tabl.countable and (" (" .. tostring(cnt) .. " / " .. tabl.countnum .. ")") or ""
			local statusText = iscompleted and "ВЫПОЛНЕНО" or "ЗАБЛОКИРОВАНО"

			Card.Paint = function(self, pw, ph)
				surface.SetDrawColor(rust_card)
				surface.DrawRect(0, 0, pw, ph)
				
				if glowAlpha > 0 then
					surface.SetDrawColor(accent.r, accent.g, accent.b, glowAlpha)
					surface.DrawRect(0, 0, pw, ph)
				end
				
				surface.SetDrawColor(accent)
				surface.DrawRect(0, 0, pw, 4)

				surface.SetDrawColor(rust_outline)
				surface.DrawOutlinedRect(0, 0, pw, ph, 1)

				draw.RoundedBox(0, 15, 15, 70, 70, Color(15, 15, 15, 200))
				surface.SetDrawColor(iscompleted and color_white or Color(80, 80, 80, 255))
				surface.SetMaterial(image)
				surface.DrawTexturedRect(18, 18, 64, 64)
				surface.SetDrawColor(accent)
				surface.DrawOutlinedRect(15, 15, 70, 70, 1)

				local titleColor = iscompleted and color_white or rust_dim
				draw.SimpleText(string.upper(tabl.achievements_name) .. addon, "Achiv_Title", 100, 18, titleColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

				surface.SetFont("Achiv_Small")
				
				local sw, sh = surface.GetTextSize(statusText)
				local statusW = sw + 20
				local curX = pw - statusW - 10
				
				draw.RoundedBox(0, curX, ph - 30, statusW, 20, Color(20, 20, 20, 230))
				local statColor = (iscompleted and not rarityText) and rust_green or (not iscompleted and rust_red or color_white)
				draw.SimpleText(statusText, "Achiv_Small", curX + statusW/2, ph - 20, statColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if rarityText then
					local rw, rh = surface.GetTextSize(rarityText)
					local rarityW = rw + 20
					curX = curX - rarityW - 5
					
					draw.RoundedBox(0, curX, ph - 30, rarityW, 20, Color(20, 20, 20, 230))
					draw.SimpleText(rarityText, "Achiv_Small", curX + rarityW/2, ph - 20, accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			local DescLabel = vgui.Create("DLabel", Card)
			DescLabel:SetPos(100, 42)
			DescLabel:SetSize(cardW - 115, 45)
			DescLabel:SetFont("Achiv_Small")
			DescLabel:SetTextColor(rust_dim)
			DescLabel:SetText(tabl.desc)
			DescLabel:SetWrap(true)
			DescLabel:SetContentAlignment(7)
		end
	end
	
	local ActiveAchivPopups = ActiveAchivPopups or {}
	local nextsound = nextsound or 0

	local function RecalculateAchivPopups()
		local padding = 10
		local currentY = ScrH() - 100 

		for i = #ActiveAchivPopups, 1, -1 do
			local pnl = ActiveAchivPopups[i]
			if IsValid(pnl) and not pnl.IsDying then
				pnl.TargetY = currentY - pnl:GetTall()
				currentY = pnl.TargetY - padding
			end
		end
	end

	function AchievementNotification(data)
		if nextsound < CurTime() then
			if data.secret then
				surface.PlaySound("rxsend/achievement/secret_achievement_unlock.ogg")
			else
				surface.PlaySound("rxsend/achievement/achievement_unlock.ogg")
			end
			nextsound = CurTime() + 2
		end
		
		local pnlW, pnlH = 320, 64
		local AchievementPanel = vgui.Create("DPanel")
		table.insert(ActiveAchivPopups, AchievementPanel)
		
		AchievementPanel:SetSize(pnlW, pnlH)
		AchievementPanel:SetZPos(32767)
		
		AchievementPanel.TargetX = ScrW() - pnlW - 20
		AchievementPanel.CurX = ScrW() + 20
		AchievementPanel.TargetY = ScrH()
		AchievementPanel.CurY = ScrH() + 20
		AchievementPanel.CurAlpha = 0
		
		AchievementPanel:SetPos(AchievementPanel.CurX, AchievementPanel.CurY)
		
		AchievementPanel.LifeTime = 6
		AchievementPanel.SpawnTime = SysTime()
		AchievementPanel.EndTime = AchievementPanel.SpawnTime + AchievementPanel.LifeTime
		AchievementPanel.IsDying = false
		
		RecalculateAchivPopups()
		
		AchievementPanel.CurY = AchievementPanel.TargetY + 15

		local image = Material(data.image, "smooth")
		local accentCol = data.secret and Color(164, 90, 214) or rust_yellow

		AchievementPanel.Think = function(self)
			local ft = FrameTime() * 12
			
			if SysTime() >= self.EndTime and not self.IsDying then
				self.IsDying = true
				self.TargetX = ScrW() + 20
				RecalculateAchivPopups()
			end
			
			self.CurX = Lerp(ft, self.CurX, self.TargetX)
			self.CurY = Lerp(ft, self.CurY, self.TargetY)
			
			if self.IsDying then
				self.CurAlpha = Lerp(ft * 1.5, self.CurAlpha, 0)
				if self.CurAlpha < 5 or self.CurX > ScrW() then
					table.RemoveByValue(ActiveAchivPopups, self)
					self:Remove()
					return
				end
			else
				self.CurAlpha = Lerp(ft, self.CurAlpha, 255)
			end
			
			self:SetPos(math.Round(self.CurX), math.Round(self.CurY))
			self:SetAlpha(self.CurAlpha)
		end

		AchievementPanel.Paint = function(self, pw, ph)
			surface.SetDrawColor(rust_panel)
			surface.DrawRect(0, 0, pw, ph)
			
			surface.SetDrawColor(accentCol)
			surface.DrawRect(0, 0, 4, ph)
			
			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0, 0, pw, ph, 1)
			
			surface.SetDrawColor(10, 9, 8, 255)
			surface.DrawRect(10, 7, 50, 50)
			
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(image)
			surface.DrawTexturedRect(12, 9, 46, 46)
			
			draw.SimpleText("ОТКРЫТО ДОСТИЖЕНИЕ:", "Achiv_Small", 70, 12, rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(string.upper(data.achievements_name), "Achiv_Title", 70, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			if not self.IsDying then
				local timeLeft = math.max(0, self.EndTime - SysTime())
				local progress = timeLeft / self.LifeTime
				
				surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, 150)
				surface.DrawRect(70, ph - 3, (pw - 72) * progress, 2)
			end
			
			return true
		end
	end

	net.Receive("OpenAchievementMenu", function()
		local readentity = net.ReadEntity()
		local readtable = net.ReadTable()
		local completedtable = net.ReadTable()
		OpenAchievementList(readentity, readtable, completedtable)
	end)

	net.Receive("AchievementBar", function()
		local tab = net.ReadTable()
		AchievementNotification(tab)
	end)

end