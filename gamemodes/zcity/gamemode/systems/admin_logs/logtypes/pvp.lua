BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.Combat = BREACH.AdminLogs.Combat || {}
BREACH.AdminLogs._Combat_table = BREACH.AdminLogs._Combat_table || {}

SHLOG_COMBAT_STATUS_INITIATOR_DEAD = 0
SHLOG_COMBAT_STATUS_VICTIM_DEAD = 1

local function GetActualPlayer(ent)
	if not IsValid(ent) then return nil end
	if ent:IsPlayer() then return ent end
	if ent:IsVehicle() and IsValid(ent:GetDriver()) then return ent:GetDriver() end
	if ent.GetOwner and IsValid(ent:GetOwner()) then return ent:GetOwner() end
	if ent.owner and IsValid(ent.owner) then return ent.owner end
	if hg and hg.RagdollOwner and IsValid(hg.RagdollOwner(ent)) then return hg.RagdollOwner(ent) end
	return nil
end

local hitgroup_names = {
	[0] = "Тело",
	[1] = "Голову",
	[2] = "Грудь",
	[3] = "Живот",
	[4] = "Левую руку",
	[5] = "Правую руку",
	[6] = "Левую ногу",
	[7] = "Правую ногу",
	[10] = "Снаряжение",
}

function BREACH.AdminLogs.Combat:LogCombat(attacker, victim, damage, hitgroup, weapon)

	local lockedteams = {}
	if TEAM_SCP then lockedteams[TEAM_SCP] = true end
	if TEAM_SPEC then lockedteams[TEAM_SPEC] = true end

	if not IsValid(victim) or not victim:IsPlayer() then return end
	if not IsValid(attacker) or not attacker:IsPlayer() then return end	
	if attacker == victim then return end

	local att_team = attacker.GTeam and attacker:GTeam() or attacker:Team()
	local vic_team = victim.GTeam and victim:GTeam() or victim:Team()

	if lockedteams[att_team] or lockedteams[vic_team] then return end

	local combat_name = "COMBAT_"..math.min(attacker:UserID(), victim:UserID()).."_"..math.max(attacker:UserID(), victim:UserID())
	local timeout_time = 15

	if not timer.Exists(combat_name) then
		BREACH.AdminLogs._Combat_table[combat_name] = {keys = {}, initiator = attacker, victim = victim}
		
		timer.Create(combat_name, timeout_time, 1, function()
			BREACH.AdminLogs.Combat:EndCombat(attacker, victim, 0)
		end)
	else
		timer.Adjust(combat_name, timeout_time, 1, function()
			BREACH.AdminLogs.Combat:EndCombat(attacker, victim, 0)
		end)
	end

	if damage == 0 then return end

	local is_initiator = BREACH.AdminLogs._Combat_table[combat_name].initiator:SteamID64() == attacker:SteamID64()

	local tab = {
		attacker = BREACH.AdminLogs:FormatPlayer(attacker),
		victim = BREACH.AdminLogs:FormatPlayer(victim),
		initiator = is_initiator,
		damage = damage,
		hitgroup = hitgroup or 0,
		weapon = weapon or "Неизвестно"
	}

	table.insert(BREACH.AdminLogs._Combat_table[combat_name].keys, tab)
end

function BREACH.AdminLogs.Combat:EndCombat(attacker, victim, damage)

	if not IsValid(victim) or not victim:IsPlayer() then return end
	if not IsValid(attacker) or not attacker:IsPlayer() then return end

	local combat_name = "COMBAT_"..math.min(attacker:UserID(), victim:UserID()).."_"..math.max(attacker:UserID(), victim:UserID())

	if BREACH.AdminLogs._Combat_table[combat_name] then
		local is_initiator = BREACH.AdminLogs._Combat_table[combat_name].initiator == attacker
		local real_victim, initiator

		if is_initiator then
			real_victim = victim
			initiator = attacker
		else
			real_victim = attacker
			initiator = victim
		end

		local status = nil
		if (!is_initiator and !attacker:Alive()) or (is_initiator and !victim:Alive()) then
			status = SHLOG_COMBAT_STATUS_VICTIM_DEAD
		elseif (!is_initiator and !victim:Alive()) or (is_initiator and !attacker:Alive()) then
			status = SHLOG_COMBAT_STATUS_INITIATOR_DEAD
		end

		if status ~= nil then
			local tab = {
				attacker = BREACH.AdminLogs:FormatPlayer(attacker),
				victim = BREACH.AdminLogs:FormatPlayer(victim),
				initiator = is_initiator,
				status = status,
			}
			table.insert(BREACH.AdminLogs._Combat_table[combat_name].keys, tab)
		end

		timer.Remove(combat_name)

		if #BREACH.AdminLogs._Combat_table[combat_name].keys > 0 then
			BREACH.AdminLogs:Log("pvp", {
				initiator = initiator,
				victim = real_victim,
				combat_data = BREACH.AdminLogs._Combat_table[combat_name].keys,
			})
		end

		BREACH.AdminLogs._Combat_table[combat_name] = nil
	end
end

local LOGDATA = {}

LOGDATA.name = "PVP"
LOGDATA.color = BREACH.AdminLogs.LogTypeColors[1]
LOGDATA.supa_colors = {
	["weapon"] = Color(89, 160, 232),
}

function LOGDATA:GetText(values)
	return ""
end

LOGDATA.Filters = {
	["initiator"] = { name = "Нападающий", type = ShLog_FILTERTYPE_PLAYER },
	["victim"] = { name = "Жертва", type = ShLog_FILTERTYPE_PLAYER },
}

if CLIENT then
	local initiator_color = Color(193, 24, 24)
	local victim_color    = Color(40, 140, 255)
	local dead_color      = Color(188, 64, 43)

	local rust_bg       = Color(20, 19, 18, 245)
	local rust_panel    = Color(15, 14, 13, 250)
	local rust_outline  = Color(255, 255, 255, 10)
	local rust_yellow   = Color(218, 165, 32)
	local rust_text     = Color(230, 230, 230)
	local rust_dim      = Color(140, 140, 140)

	local v_r = Material("vgui/gradient-r")
	local v_l = Material("vgui/gradient-l")
	local v_d = Material("vgui/gradient-d")

	function BREACH.AdminLogs.UI:CreateCombatPanel(initiator, victim, combat_data, x, y, w, h, parent, logdata)

		h = 180 
		parent:SetTall(h + 40)

		local CombatPanel = vgui.Create("DPanel", parent)
		CombatPanel:SetSize(w, h)
		CombatPanel:SetPos(x, y)

		local initiator_avatar = vgui.Create("AvatarImage", CombatPanel)
		initiator_avatar:SetSize(h - 14, h - 14)
		initiator_avatar:SetPos(7, 7)
		initiator_avatar:SetSteamID(initiator.sid64, 184)

		local _dead = string.upper(L"l:shlogs_dead" or "МЁРТВ")
		local function paint_avatar(self, aw, ah, col, col2)
			if self.dead then
				surface.SetDrawColor(rust_panel)
				surface.SetMaterial(v_d)
				surface.DrawTexturedRect(0, ah - 30, aw, 30)

				draw.RoundedBox(0, 0, ah - 25, aw, 25, rust_panel)
				draw.DrawText(_dead, "MM_Exp", aw / 2, ah - 20, col2, TEXT_ALIGN_CENTER)
			end
			surface.SetDrawColor(col)
			surface.DrawOutlinedRect(0, 0, aw, ah, 1)
		end

		initiator_avatar.PaintOver = function(self, aw, ah)
			paint_avatar(self, aw, ah, initiator_color, victim_color)
		end

		local victim_avatar = vgui.Create("AvatarImage", CombatPanel)
		victim_avatar:SetSize(h - 14, h - 14)
		victim_avatar:SetPos(w - 7 - victim_avatar:GetWide(), 7)
		victim_avatar:SetSteamID(victim.sid64, 184)

		victim_avatar.PaintOver = function(self, aw, ah)
			paint_avatar(self, aw, ah, victim_color, initiator_color)
		end

		CombatPanel.Paint = function(self, cw, ch)
			surface.SetDrawColor(rust_panel)
			surface.DrawRect(0, 0, cw, ch)

			surface.SetDrawColor(ColorAlpha(initiator_color, 15))
			surface.SetMaterial(v_l)
			surface.DrawTexturedRect(0, 0, cw / 2, ch)

			surface.SetDrawColor(ColorAlpha(victim_color, 15))
			surface.SetMaterial(v_r)
			surface.DrawTexturedRect(cw / 2, 0, cw / 2, ch)

			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0, 0, cw, ch, 1)

			surface.SetDrawColor(initiator_color)
			surface.DrawRect(0, 0, cw/2, 2)
			surface.SetDrawColor(victim_color)
			surface.DrawRect(cw/2, 0, cw/2, 2)
		end

		local text = BREACH.AdminLogs.UI:CreateRichText({
			BREACH.AdminLogs:NiceTextPlayer(initiator),
			{color = rust_text_dim, text = " VS "},
			BREACH.AdminLogs:NiceTextPlayer(victim),
		}, 0, 0, CombatPanel:GetWide() / 1.6, 30, CombatPanel)
		text:SetPos(initiator_avatar:GetWide() + 15, 10)

		local history_bg = vgui.Create("DPanel", CombatPanel)
		history_bg:SetSize(w - (initiator_avatar:GetWide() + 15) * 2, h - 45)
		history_bg:SetPos(initiator_avatar:GetWide() + 15, 35)
		history_bg.Paint = function(self, pw, ph)
			surface.SetDrawColor(rust_bg)
			surface.DrawRect(0, 0, pw, ph)
			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0, 0, pw, ph, 1)
		end

		local scroll = vgui.Create("DScrollPanel", history_bg)
		scroll:Dock(FILL)
		scroll:DockMargin(2, 2, 2, 2)

		local sbar = scroll:GetVBar()
		sbar:SetWide(6)
		sbar:SetHideButtons(true)
		sbar.Paint = function(self, bw, bh)
			surface.SetDrawColor(10, 10, 10, 200)
			surface.DrawRect(0, 0, bw, bh)
		end
		sbar.btnGrip.Paint = function(self, bw, bh)
			surface.SetDrawColor(80, 80, 80, 255)
			surface.DrawRect(0, 0, bw, bh)
		end

		local total_dmg_initiator = 0
		local total_dmg_victim = 0

		for i, hit in ipairs(combat_data) do
			if hit.status then
				if hit.status == SHLOG_COMBAT_STATUS_INITIATOR_DEAD then
					initiator_avatar.dead = true
				else
					victim_avatar.dead = true
				end

				local row = vgui.Create("DPanel", scroll)
				row:Dock(TOP)
				row:SetTall(24)
				row.Paint = function(self, rw, rh)
					surface.SetDrawColor(dead_color.r, dead_color.g, dead_color.b, 20)
					surface.DrawRect(0, 0, rw, rh)
					draw.SimpleText("ЛЕТАЛЬНЫЙ ИСХОД", "MM_Exp", rw / 2, rh / 2 - 1, dead_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				continue
			end

			if hit.damage then
				local is_initiator = hit.initiator
				local attColor = is_initiator and initiator_color or victim_color

				local dmgText = string.format("-%.1f HP", hit.damage)
				local wepText = hit.weapon and (string.upper(hit.weapon)) or "НЕИЗВЕСТНО"
				local partText = hitgroup_names[hit.hitgroup] and string.upper(hitgroup_names[hit.hitgroup]) or "ТЕЛО"

				if is_initiator then total_dmg_initiator = total_dmg_initiator + hit.damage
				else total_dmg_victim = total_dmg_victim + hit.damage end

				local row = vgui.Create("DPanel", scroll)
				row:Dock(TOP)
				row:SetTall(22)
				
				row.Paint = function(self, rw, rh)
					if self:IsHovered() then
						surface.SetDrawColor(255, 255, 255, 5)
						surface.DrawRect(0, 0, rw, rh)
					end
					surface.SetDrawColor(rust_outline)
					surface.DrawLine(0, rh - 1, rw, rh - 1)

					local cx = 5
					draw.SimpleText("[" .. wepText .. "]", "MM_Exp", cx, rh/2 - 1, rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					
					surface.SetFont("MM_Exp")
					cx = cx + surface.GetTextSize("[" .. wepText .. "]") + 5
					draw.SimpleText("В", "MM_Exp", cx, rh/2 - 1, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					
					cx = cx + surface.GetTextSize("В") + 5
					draw.SimpleText(partText, "MM_Exp", cx, rh/2 - 1, rust_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					draw.SimpleText(dmgText, "MM_Exp", rw - 5, rh/2 - 1, attColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end

				local btn = vgui.Create("DButton", row)
				btn:Dock(FILL)
				btn:SetText("")
				btn.Paint = function() end
				btn.DoClick = function()
					BREACH.AdminLogs:LoadSnapshot(logdata.id, i)
				end
			end
		end

		local total_row = vgui.Create("DPanel", scroll)
		total_row:Dock(TOP)
		total_row:SetTall(26)
		total_row.Paint = function(self, rw, rh)
			surface.SetDrawColor(rust_outline)
			surface.DrawRect(0, 0, rw, 1)
			
			draw.SimpleText("ОБЩИЙ УРОН:", "MM_Exp", 5, rh/2 - 1, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(tostring(math.Round(total_dmg_initiator)), "MM_Exp", rw/2 - 10, rh/2 - 1, initiator_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(" | ", "MM_Exp", rw/2, rh/2 - 1, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(tostring(math.Round(total_dmg_victim)), "MM_Exp", rw/2 + 10, rh/2 - 1, victim_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		
		timer.Simple(0.01, function()
			if IsValid(scroll) and IsValid(sbar) then
				sbar:SetScroll(sbar.CanvasSize)
			end
		end)
	end
end


if SERVER then

	hook.Add("ScalePlayerDamage", "SHLOGS_CATCH_HITGROUP", function(ply, hitgroup, dmginfo)
		ply.shlogs_last_hitgroup = hitgroup
		ply.shlogs_last_hittime = CurTime()
	end)

	hook.Add("HomigradDamage", "SHLOGS_PVP_DAMAGERECEIVE", function(victim, dmgInfo, hitgroup, ent, harm)
		if not IsValid(victim) or not victim:IsPlayer() then return end
		
		local attacker = GetActualPlayer(dmgInfo:GetAttacker())
		if not IsValid(attacker) or not attacker:IsPlayer() then return end
		
		local damage = dmgInfo:GetDamage()
		if damage > 0 then
			local wep_name = "Неизвестно"
			if IsValid(dmgInfo:GetInflictor()) then
				local inf = dmgInfo:GetInflictor()
				if inf:IsWeapon() then
					wep_name = inf.PrintName or inf:GetClass()
				else
					wep_name = inf:GetClass()
				end
			elseif IsValid(attacker:GetActiveWeapon()) then
				wep_name = attacker:GetActiveWeapon().PrintName or attacker:GetActiveWeapon():GetClass()
			end

			local final_hitgroup = hitgroup

			if victim.shlogs_last_hitgroup and victim.shlogs_last_hittime == CurTime() then
				final_hitgroup = victim.shlogs_last_hitgroup
			elseif ent:IsRagdoll() and hg and hg.GetTraceDamage then
				local tr = hg.GetTraceDamage(ent, dmgInfo:GetDamagePosition(), dmgInfo:GetDamageForce())
				if tr and tr.Hit and tr.PhysicsBone then
					local bone = ent:TranslatePhysBoneToBone(tr.PhysicsBone)
					local bonename = ent:GetBoneName(bone)
					final_hitgroup = hg.bonetohitgroup and hg.bonetohitgroup[bonename] or hitgroup
				end
			end

			BREACH.AdminLogs.Combat:LogCombat(attacker, victim, damage, final_hitgroup, wep_name)
		end
	end)

	hook.Add("PlayerDeath", "SHLOGS_PVP_KILL", function(victim, inflictor, attacker)
		if not IsValid(victim) or not victim:IsPlayer() then return end

		local realAttacker = GetActualPlayer(attacker)
		if IsValid(realAttacker) and realAttacker:IsPlayer() and realAttacker ~= victim then
			BREACH.AdminLogs.Combat:LogCombat(realAttacker, victim, 0)
			timer.Simple(0.1, function()
				BREACH.AdminLogs.Combat:EndCombat(realAttacker, victim, 0)
			end)
		end

		for combat_name, data in pairs(BREACH.AdminLogs._Combat_table) do
			if data.victim == victim or data.initiator == victim then
				BREACH.AdminLogs.Combat:EndCombat(data.initiator, data.victim, 0)
			end
		end
	end)

end

return LOGDATA