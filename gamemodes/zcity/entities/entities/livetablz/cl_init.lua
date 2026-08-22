include('shared.lua')

surface.CreateFont("LZ_Monitor_Title", { font = "Hitmarker Normal", size = 48, weight = 800, extended = true })
surface.CreateFont("LZ_Monitor_Sub", { font = "Hitmarker Normal", size = 32, weight = 600, extended = true })
surface.CreateFont("LZ_Monitor_Huge", { font = "Hitmarker Normal", size = 90, weight = 800, extended = true })

local rust_bg       = Color(15, 14, 13, 250)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 15)
local rust_yellow   = Color(218, 165, 32, 255)
local rust_red      = Color(188, 64, 43, 255)
local rust_green    = Color(112, 126, 73, 255)
local rust_text     = Color(230, 230, 230, 255)
local rust_dim      = Color(140, 140, 140, 255)

function ENT:UpdateStats()
	local players = player.GetAll()
	
	for i = 1, #players do
		if players[i]:GTeam() == TEAM_AR then return end
	end

	self.TotalSciencePlayers = 0
	self.TotalPlayers = 0

	for i = 1, #players do
		local ply = players[i]

		if ply:GTeam() ~= TEAM_SPEC and ply:Health() > 0 and ply:IsLZ() then
			self.TotalPlayers = self.TotalPlayers + 1
			if ply:GTeam() == TEAM_SCI or ply:GTeam() == TEAM_SPECIAL then
				self.TotalSciencePlayers = self.TotalSciencePlayers + 1
			end
		end
	end
end

function ENT:Draw()
	self:DrawModel()

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 250000 then return end

	local oang = self:GetAngles()
	local ang = self:GetAngles()
	local pos = self:GetPos()

	ang:RotateAroundAxis(oang:Up(), 90)
	ang:RotateAroundAxis(oang:Right(), -90)
	ang:RotateAroundAxis(oang:Up(), 90)

	local w, h = 700, 370
	local startX, startY = -425, -10
	local cx = startX + w / 2
	local cy = startY + h / 2

	cam.Start3D2D(pos + oang:Forward() * -6 + oang:Up() * 13 + oang:Right() * -3, ang, 0.07)

		surface.SetDrawColor(rust_bg)
		surface.DrawRect(startX, startY, w, h)

		surface.SetDrawColor(255, 255, 255, 2)
		for i = 0, h, 6 do surface.DrawLine(startX, startY + i, startX + w, startY + i) end

		surface.SetDrawColor(rust_panel)
		surface.DrawRect(startX, startY, w, 60)

		local emergency_mode = self:GetEmergencyMode()

		if emergency_mode then

			if not self.TotalPlayers then
				self:UpdateStats()
				self.NextUpdateStats = CurTime() + 2
			elseif self.NextUpdateStats < CurTime() then
				self:UpdateStats()
				self.NextUpdateStats = CurTime() + 2 
			end

			surface.SetDrawColor(rust_yellow)
			surface.DrawRect(startX, startY + 60, w, 4)

			draw.SimpleText(string.upper(L("l:livetablz_1") or "АВАРИЙНЫЙ РЕЖИМ"), "LZ_Monitor_Title", cx, startY + 30, rust_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.SimpleText(string.upper(L("l:livetablz_2") or "СУБЪЕКТОВ В ЗОНЕ: ") .. self.TotalPlayers, "LZ_Monitor_Sub", cx, startY + 160, rust_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.upper(L("l:livetablz_3") or "НАУЧНЫЙ ПЕРСОНАЛ: ") .. self.TotalSciencePlayers, "LZ_Monitor_Sub", cx, startY + 220, rust_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		else
			draw.SimpleText(string.upper(L("l:livetablz_4") or "СИСТЕМА УПРАВЛЕНИЯ ЗОНОЙ"), "LZ_Monitor_Title", cx, startY + 30, rust_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if preparing or not gamestarted then
				surface.SetDrawColor(rust_green)
				surface.DrawRect(startX, startY + 60, w, 4)

				draw.SimpleText(string.upper(L("l:livetablz_5") or "СТАТУС: БЕЗОПАСНО"), "LZ_Monitor_Sub", cx, startY + 160, rust_green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(string.upper(L("l:livetablz_6") or "ПЕРИМЕТР ПОД КОНТРОЛЕМ"), "LZ_Monitor_Sub", cx, startY + 220, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			elseif (cltime - self:GetDecontTimer() > 0) then
				self.Decontamination_Time = timer.TimeLeft("LZDecont") or 0
				local isDanger = self.Decontamination_Time < 90
				local statusCol = isDanger and rust_red or rust_yellow

				surface.SetDrawColor(statusCol)
				surface.DrawRect(startX, startY + 60, w, 4)

				draw.SimpleText(string.upper(L("l:livetablz_7") or "ДО ИНИЦИАЛИЗАЦИИ ПРОТОКОЛА ОЧИСТКИ:"), "LZ_Monitor_Sub", cx, startY + 120, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				local boxW, boxH = 350, 110
				local boxX = cx - boxW / 2
				local boxY = startY + 160

				surface.SetDrawColor(statusCol.r, statusCol.g, statusCol.b, 15)
				surface.DrawRect(boxX, boxY, boxW, boxH)
				
				surface.SetDrawColor(statusCol)
				surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 2)

				if isDanger then
					local pulse = (math.sin(CurTime() * 8) + 1) / 2
					surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 60 * pulse)
					surface.DrawRect(boxX, boxY, boxW, boxH)
				end

				draw.SimpleText(string.ToMinutesSeconds(self.Decontamination_Time), "LZ_Monitor_Huge", cx, boxY + boxH / 2 - 5, statusCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			else
				local pulse = (math.sin(CurTime() * 10) + 1) / 2
				local drawCol = ColorAlpha(rust_red, 150 + 105 * pulse)

				surface.SetDrawColor(drawCol)
				surface.DrawRect(startX, startY + 60, w, 4)

				surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 40 * pulse)
				surface.DrawRect(startX, startY + 64, w, h - 64)

				draw.SimpleText(string.upper(L("l:livetablz_8") or "ЗОНА ИЗОЛИРОВАНА"), "LZ_Monitor_Huge", cx, cy + 20, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		surface.SetDrawColor(rust_outline)
		surface.DrawOutlinedRect(startX, startY, w, h, 2)

	cam.End3D2D()
end