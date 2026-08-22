include('shared.lua')

surface.CreateFont("Mon_Header", { font = "Hitmarker Normal", size = 35, weight = 800, extended = true })
surface.CreateFont("Mon_Label", { font = "Hitmarker Normal", size = 28, weight = 600, extended = true })
surface.CreateFont("Mon_Number", { font = "Hitmarker Normal", size = 55, weight = 800, extended = true })
surface.CreateFont("Mon_Nuke", { font = "Hitmarker Normal", size = 130, weight = 800, extended = true })

local PizzaDay = Material("kissing_boys/kiss12.png", "smooth")
local nukeicon = Material("nextoren/nuke/nuke_redux", "smooth")

local rust_bg      = Color(10, 9, 8, 255)
local rust_outline = Color(255, 255, 255, 10)
local rust_yellow  = Color(218, 165, 32)
local rust_red     = Color(200, 40, 40)
local rust_text    = Color(230, 230, 230)
local rust_dim     = Color(100, 100, 100)

ENT.Statistics = {}

function ENT:UpdateFakeStats()
	self.Statistics = {}
	local players = player.GetAll()
	for i = 1, #players do
		local ply = players[i]
		if ply:GTeam() ~= TEAM_SPEC and ply:Health() > 0 and not ply:Outside() then
			local team = ply:GTeam() + math.random(1, 2)
			self.Statistics[team] = (self.Statistics[team] or 0) + 1
		end
	end
end

function ENT:UpdateStats()
	self.Statistics = {}
	local players = player.GetAll()
	for i = 1, #players do
		local ply = players[i]
		if ply:GTeam() ~= TEAM_SPEC and ply:Health() > 0 and not ply:Outside() then
			local team = ply:GTeam()
			self.Statistics[team] = (self.Statistics[team] or 0) + 1
		end
	end
end

function ENT:Draw()
	self:DrawModel()

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 300000 then return end
	if not LocalPlayer():IsLineOfSightClear(self) then return end

	local oang = self:GetAngles()
	local ang = self:GetAngles()
	local pos = self:GetPos()

	ang:RotateAroundAxis(oang:Up(), 90)
	ang:RotateAroundAxis(oang:Right(), -90)
	ang:RotateAroundAxis(oang:Up(), 90)

	local w, h = 700, 370
	local startX, startY = -340, -45
	local cx, cy = startX + w/2, startY + h/2

	cam.Start3D2D(pos + oang:Up() * 11 + oang:Right() * -3, ang, 0.07)

		surface.SetDrawColor(rust_bg)
		surface.DrawRect(startX, startY, w, h)


		--surface.SetDrawColor(255, 255, 255, 2)
		--for i = 0, h, 6 do surface.DrawLine(startX, startY + i, startX + w, startY + i) end

		surface.SetDrawColor(rust_outline)
		surface.DrawOutlinedRect(startX, startY, w, h, 2)

		if preparing then

			surface.SetDrawColor(255, 255, 255, 200)
			surface.SetMaterial(PizzaDay)
			surface.DrawTexturedRect(startX, startY, w, h)

			surface.SetDrawColor(0, 0, 0, 180)
			surface.DrawRect(startX, startY, w, h)


		elseif GetGlobalBool("NukeTime") then

			local pulse = (math.sin(CurTime() * 10) + 1) / 2
			
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(startX, startY, w, h)

			surface.SetDrawColor(255, 255, 255, 10 + 20 * pulse)
			surface.SetMaterial(nukeicon)
			surface.DrawTexturedRect(cx - 150, cy - 150, 300, 300)

			draw.SimpleText("/// КРИТИЧЕСКАЯ УГРОЗА ///", "Mon_Header", cx, startY + 40, rust_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local timeStr = "СБОЙ"
			if timer.Exists("NukeTimer") then timeStr = string.ToMinutesSeconds(timer.TimeLeft("NukeTimer"))
			elseif timer.Exists("NukeTimer2") then timeStr = string.ToMinutesSeconds(timer.TimeLeft("NukeTimer2")) end

			draw.SimpleText(timeStr, "Mon_Nuke", cx, cy, ColorAlpha(rust_red, 150 + 105 * pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText("ПРОТОКОЛ АЛЬФА-БОЕГОЛОВКИ ИНИЦИИРОВАН", "Mon_Label", cx, startY + h - 40, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		else

			if (self.NextStatsUpdate or 0) < CurTime() then
				self.NextStatsUpdate = CurTime() + 3
				if (Monitors_Activated or 0) < 2 then self:UpdateStats() else self:UpdateFakeStats() end
			end


			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawRect(startX, startY, w, 50)
			
			surface.SetDrawColor(rust_yellow)
			surface.DrawRect(startX, startY + 50, w, 2)

			draw.SimpleText(string.upper(L("l:livetaboz_main") or "ЖИЗНЕННЫЕ ПОКАЗАТЕЛИ"), "Mon_Header", startX + 25, startY + 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText("T - " .. string.ToMinutesSeconds(cltime), "Mon_Header", startX + w - 25, startY + 25, rust_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			local countSci   = (self.Statistics[TEAM_SCI] or 0) + (self.Statistics[TEAM_SPECIAL] or 0)
			local countMil   = (self.Statistics[TEAM_GUARD] or 0) + (self.Statistics[TEAM_CB] or 0) + (self.Statistics[TEAM_OBR] or 0) + (self.Statistics[TEAM_OSN] or 0)
			local countD     = (self.Statistics[TEAM_CLASSD] or 0)
			local countAnon  = (self.Statistics[TEAM_DZ] or 0) + (self.Statistics[TEAM_AR] or 0) + (self.Statistics[TEAM_GRU] or 0) + (self.Statistics[TEAM_CHAOS] or 0) + (self.Statistics[TEAM_GOC] or 0) + (self.Statistics[TEAM_COTSK] or 0)

			local function DrawLineStat(yOffset, label, count, col)
				local py = startY + yOffset
				

				surface.SetDrawColor(col)
				surface.DrawRect(startX + 25, py + 12, 6, 6)

				draw.SimpleText(label, "Mon_Label", startX + 45, py, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				
				draw.SimpleText(tostring(count), "Mon_Number", startX + w - 30, py - 12, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				
				surface.SetDrawColor(255, 255, 255, 10)
				surface.DrawLine(startX + 25, py + 45, startX + w - 25, py + 45)
			end

			local langSci = string.upper(L("l:livetaboz_sci") or "НАУЧНЫЙ ПЕРСОНАЛ")
			local langMil = string.upper(L("l:livetaboz_mil") or "ВООРУЖЕННЫЕ СИЛЫ")
			local langD   = string.upper(L("l:livetaboz_d") or "РАСХОДНЫЙ КЛАСС")
			local langAno = string.upper(L("l:livetaboz_anon") or "НЕИЗВЕСТНЫЕ ЦЕЛИ")

			DrawLineStat(80,  langSci, countSci,  Color(80, 160, 220))
			DrawLineStat(150, langMil, countMil,  Color(112, 126, 73))
			DrawLineStat(220, langD,   countD,    rust_yellow)
			DrawLineStat(290, langAno, countAnon, rust_red)
		end

	cam.End3D2D()
end