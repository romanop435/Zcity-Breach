BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

local initiator_color = Color(193, 24, 24)
local victim_color = Color(0,128,255)
local dead_color = Color(255,0,0)
local rust_outline = Color(255, 255, 255, 10)

function BREACH.AdminLogs.UI:CreateProgress(progress, summ)
	local pgr = vgui.Create("DPanel")
	pgr.draws = {}

	function pgr:UpdateInfoSize()
		self.draws = {}
		local offs = 0
		local a_summ = 0
		for i, pr in pairs(progress) do
			local _w = math.floor(pgr:GetWide()*(pr.value/summ))
			if i == #progress then
				_w = self:GetWide()-a_summ
			else
				a_summ = a_summ + _w
			end
			table.insert(self.draws, {col = pr.color, x = offs, w = _w, value = pr.value, status = pr.status})
			offs = offs + _w
		end
	end

	pgr:UpdateInfoSize()

	pgr.Paint = function(self, w, h)
		for i = 1, #self.draws do
			local _v = self.draws[i]
			draw.RoundedBox(0,_v.x,0,_v.w,h,_v.col)
		end
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	return pgr
end

function BREACH.AdminLogs.UI:CreateCombatPanel(initiator, victim, combat_data, x, y, w, h, parent, logdata)
	local CombatPanel = vgui.Create("DPanel", parent)
	CombatPanel:SetSize(w, h)
	CombatPanel:SetPos(x, y)

	local initiator_avatar = vgui.Create("AvatarImage", CombatPanel)
	initiator_avatar:SetSize(h-14, h-14)
	initiator_avatar:SetPos(7,7)
	initiator_avatar:SetSteamID(initiator.sid64, 184)

	local col_shadow = Color(0,0,0,250)
	local _dead = L"l:shlogs_dead"

	local function paint_avatar(self, aw, ah, col, col2)
		if self.dead then
			draw.RoundedBox(0,0,ah-20,aw,20,col_shadow)
			draw.DrawText(_dead, "MM_Exp", aw/2, ah-18, col2, TEXT_ALIGN_CENTER)
		end
		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(0,0,aw,ah,1)
	end

	initiator_avatar.PaintOver = function(self, aw, ah) paint_avatar(self, aw, ah, initiator_color, victim_color) end

	local victim_avatar = vgui.Create("AvatarImage", CombatPanel)
	victim_avatar:SetSize(h-14, h-14)
	victim_avatar:SetPos(w-7-victim_avatar:GetWide(),7)
	victim_avatar:SetSteamID(victim.sid64, 184)
	victim_avatar.PaintOver = function(self, aw, ah) paint_avatar(self, aw, ah, victim_color, initiator_color) end

	CombatPanel.Paint = function(self, cw, ch)
		draw.RoundedBox(0, 0, 0, cw, ch, Color(20, 19, 18, 150))
		surface.SetDrawColor(rust_outline)
		surface.DrawOutlinedRect(0, 0, cw, ch, 1)
	end

	local progress = {}
	local summ = 0

	for _, v in pairs(combat_data) do
		if v.damage then
			local damage = math.floor(v.damage)
			summ = summ + damage
			local col = victim_color
			if v.initiator then col = initiator_color end
			table.insert(progress, { color = col, value = damage, status = v.status })
		end
		
		if isnumber(v.status) then
			if v.status == SHLOG_COMBAT_STATUS_INITIATOR_DEAD then initiator_avatar.dead = true
			else victim_avatar.dead = true end
		end
	end

	local pgr_bg = vgui.Create("DPanel", CombatPanel)
	pgr_bg:SetSize(w-(initiator_avatar:GetWide()+15)*2, 25)
	pgr_bg:SetPos(initiator_avatar:GetWide()+15, h*0.5)
	pgr_bg.Paint = function(self, cw, ch) draw.RoundedBox(0,0,0,cw,ch,Color(10,9,8,255)) end

	local pgr = BREACH.AdminLogs.UI:CreateProgress(progress, summ)
	pgr:SetParent(pgr_bg)
	pgr:SetSize(pgr_bg:GetWide() - 4, pgr_bg:GetTall() - 4)
	pgr:SetPos(2, 2)
	pgr:UpdateInfoSize()

	local text = BREACH.AdminLogs.UI:CreateRichText({
		BREACH.AdminLogs:NiceTextPlayer(initiator),
		" vs ",
		BREACH.AdminLogs:NiceTextPlayer(victim),
	}, 0, 0, CombatPanel:GetWide()/1.6, 30, CombatPanel)
	text:SetPos(CombatPanel:GetWide()*.09, 10)

	local l_id = 0
	for i, v in pairs(pgr.draws) do
		l_id = l_id + 1
		local btn = vgui.Create("DButton", pgr)
		btn:SetSize(v.w, pgr:GetTall())
		btn:SetPos(v.x, 0)
		btn:SetText("")
		btn.id = l_id
		btn.damage = v.value
		btn.hoverlerp = 0

		btn.Paint = function(self, cw, ch)
			self.hoverlerp = math.Approach(self.hoverlerp, self:IsHovered() and 1 or 0, FrameTime()*10)
			if self.hoverlerp > 0 then
				draw.RoundedBox(0,0,0,cw,ch,ColorAlpha(color_white, self.hoverlerp*100))
				local txt = v.status and "СМЕРТЬ" or tostring(self.damage)
				draw.DrawText(txt, "MM_Exp", cw/2, ch/2 - 6, ColorAlpha(color_black, self.hoverlerp*255), TEXT_ALIGN_CENTER)
			end
		end

		btn.DoClick = function(self)
			BREACH.AdminLogs:LoadSnapshot(logdata.id, self.id)
		end
	end
end