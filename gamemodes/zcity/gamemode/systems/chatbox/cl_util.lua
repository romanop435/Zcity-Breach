


function LOUNGE_CHAT.PaintScroll(panel)
	local styl = LOUNGE_CHAT.Style

	local scr = panel:GetVBar()
	scr.Paint = function(_, w, h)
		surface.SetDrawColor(styl.bg)
		surface.DrawRect(0, 0, w, h)
	end

	scr.btnUp.Paint = function(me, w, h)
		draw.RoundedBox(4, 2, 0, w - 4, h - 2, styl.inbg)

		if (me.Hovered) then
			draw.RoundedBox(4, 2, 0, w - 4, h - 2, styl.hover2)
		end

		if (me.Depressed) then
			draw.RoundedBox(4, 2, 0, w - 4, h - 2, styl.hover2)
		end
	end
	scr.btnDown.Paint = function(me, w, h)
		draw.RoundedBox(4, 2, 2, w - 4, h - 2, styl.inbg)

		if (me.Hovered) then
			draw.RoundedBox(4, 2, 2, w - 4, h - 2, styl.hover2)
		end

		if (me.Depressed) then
			draw.RoundedBox(4, 2, 2, w - 4, h - 2, styl.hover2)
		end
	end

	scr.btnGrip.Paint = function(me, w, h)
		draw.RoundedBox(4, 2, 0, w - 4, h, styl.inbg)

		if (vgui.GetHoveredPanel() == me) then
			draw.RoundedBox(4, 2, 0, w - 4, h, styl.hover2)
		end

		if (me.Depressed) then
			draw.RoundedBox(4, 2, 0, w - 4, h, styl.hover2)
		end
	end
end

function LOUNGE_CHAT.Menu()
	local styl = LOUNGE_CHAT.Style

	if (IsValid(_LOUNGE_CHAT_MENU)) then
		_LOUNGE_CHAT_MENU:Remove()
	end

	local th = 48 * _LOUNGE_CHAT_SCALE
	local m = th * 0.25

	local cancel = vgui.Create("DPanel")
	cancel:SetDrawBackground(false)
	cancel:StretchToParent(0, 0, 0, 0)
	cancel:MoveToFront()
	cancel:MakePopup()

	local pnl = vgui.Create("DPanel")
	pnl:SetDrawBackground(false)
	pnl:SetSize(20, 1)
	pnl.AddOption = function(me, text, callback)
		surface.SetFont("LOUNGE_CHAT_16")
		local wi, he = surface.GetTextSize(text)
		wi = wi + m * 2
		he = he + m

		me:SetWide(math.max(wi, me:GetWide()))
		me:SetTall(pnl:GetTall() + he)

		local btn = vgui.Create("DButton", me)
		btn:SetText(text)
		btn:SetFont("LOUNGE_CHAT_16")
		btn:SetColor(styl.text)
		btn:Dock(TOP)
		btn:SetSize(wi, he)
		btn.Paint = function(me, w, h)
			surface.SetDrawColor(styl.menu)
			surface.DrawRect(0, 0, w, h)

			if (me.Hovered) then
				surface.SetDrawColor(styl.hover)
				surface.DrawRect(0, 0, w, h)
			end

			if (me:IsDown()) then
				surface.SetDrawColor(styl.hover)
				surface.DrawRect(0, 0, w, h)
			end
		end
		btn.DoClick = function(me)
			callback()
			pnl:Close()
		end
	end
	pnl.Open = function(me)
		me:SetPos(gui.MouseX(), gui.MouseY())
		me:MakePopup()
	end
	pnl.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, LOUNGE_CHAT.Anims.FadeOutTime, 0, function()
			me:Remove()
		end)
	end
	_LOUNGE_CHAT_MENU = pnl

	cancel.OnMouseReleased = function(me, mc)
		pnl:Close()
	end
	cancel.Think = function(me)
		if (!IsValid(pnl)) then
			me:Remove()
		end
	end

	return pnl
end

function LOUNGE_CHAT.Label(text, font, color, parent)
	local label = vgui.Create("DLabel")
	label:SetFont(font)
	label:SetText(text)
	label:SetColor(color)
	if (parent) then
		label:SetParent(parent)
	end
	label:SizeToContents()
	label:SetMouseInputEnabled(false)

	return label
end

function LOUNGE_CHAT.NumSlider(parent)
	local slider = vgui.Create("DNumSlider", parent)
	slider.TextArea:SetTextColor(LOUNGE_CHAT.Color("text"))
	slider.TextArea:SetFont("LOUNGE_CHAT_16")
	slider.TextArea:SetDrawLanguageID(false)
	slider.TextArea:SetCursorColor(LOUNGE_CHAT.Color("text"))
	slider.Label:SetVisible(false)
	slider.Slider.Paint = function(me, w, h)
		draw.RoundedBox(0, 0, h * 0.5 - 1, w, 2, LOUNGE_CHAT.Color("bg"))
	end
	slider.Slider.Knob.Paint = function(me, w, h)
		draw.RoundedBox(4, 0, 0, w, h, LOUNGE_CHAT.Color("header"))

		if (me.Hovered) then
			surface.SetDrawColor(LOUNGE_CHAT.Color("hover"))
			surface.DrawRect(0, 0, w, h)
		end

		if (me:IsDown()) then
			surface.SetDrawColor(LOUNGE_CHAT.Color("hover"))
			surface.DrawRect(0, 0, w, h)
		end
	end

	return slider
end

local matChecked = Material("shenesis/chat/checked.png", "noclamp smooth")

function LOUNGE_CHAT.Checkbox(text, cvar, parent)
	local pnl = vgui.Create("DPanel", parent)
	pnl:SetDrawBackground(false)
	pnl:SetTall(draw.GetFontHeight("LOUNGE_CHAT_20_B"))

		local lbl = LOUNGE_CHAT.Label(LOUNGE_CHAT.Lang(text), "LOUNGE_CHAT_20", LOUNGE_CHAT.Color("text"), pnl)
		lbl:Dock(FILL)

		local chk = vgui.Create("DCheckBox", pnl)
		chk:SetConVar(cvar)
		chk:SetWide(pnl:GetTall() - 4)
		chk:Dock(RIGHT)
		chk:DockMargin(2, 2, 2, 2)
		chk.Paint = function(me, w, h)
			if (me:GetChecked()) then
				draw.RoundedBox(4, 0, 0, w, h, LOUNGE_CHAT.Color("header"))

				surface.SetDrawColor(LOUNGE_CHAT.Color("text"))
				surface.SetMaterial(matChecked)
				surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, h - 4, h - 4, 0)
			else
				draw.RoundedBox(4, 0, 0, w, h, LOUNGE_CHAT.Color("bg"))
			end
		end

	return pnl
end

function LOUNGE_CHAT.Button(text, parent, callback)
	local btn = vgui.Create("DButton", parent)
	if (istable(text)) then
		btn:SetText(LOUNGE_CHAT.Lang(unpack(text)))
	else
		btn:SetText(LOUNGE_CHAT.Lang(text))
	end
	btn:SetFont("LOUNGE_CHAT_16")
	btn:SetTextColor(LOUNGE_CHAT.Color("text"))
	btn.Paint = function(me, w, h)
		draw.RoundedBox(4, 0, 0, w, h, LOUNGE_CHAT.Color(me.m_bAlternateBG and "bg" or "inbg"))

		if (me.Hovered) then
			draw.RoundedBox(4, 0, 0, w, h, LOUNGE_CHAT.Color("hover"))
		end

		if (me:IsDown()) then
			draw.RoundedBox(4, 0, 0, w, h, LOUNGE_CHAT.Color("hover"))
		end
	end
	btn.DoClick = function(me)
		callback(me)
	end

	return btn
end

// https://facepunch.com/showthread.php?t=1522945&p=50524545&viewfull=1#post50524545
local sin, cos, rad = math.sin, math.cos, math.rad
local rad0 = rad(0)
local function DrawCircle(x, y, radius, seg)
	local cir = {
		{x = x, y = y}
	}

	for i = 0, seg do
		local a = rad((i / seg) * -360)
		table.insert(cir, {x = x + sin(a) * radius, y = y + cos(a) * radius})
	end

	table.insert(cir, {x = x + sin(rad0) * radius, y = y + cos(rad0) * radius})
	surface.DrawPoly(cir)
end

local chat_roundavatars = CreateClientConVar("lounge_chat_roundavatars", 1, true, false)

function LOUNGE_CHAT:Avatar(ply, siz, par)
	if (!isstring(ply) and !IsValid(ply)) then
		return end

	siz = siz or 32
	local hsiz = siz * 0.5

	local url = "http://steamcommunity.com/profiles/" .. (isstring(ply) and ply or ply:SteamID64())

	local pnl = vgui.Create("DPanel", par)
	pnl:SetSize(siz, siz)
	pnl:SetDrawBackground(false)
	pnl.Paint = function() end

		local av = vgui.Create("AvatarImage", pnl)
		if (isstring(ply)) then
			av:SetSteamID(ply, siz)
		else
			if LocalPlayer():CanSeeEnt(ply) or ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then
				av:SetPlayer(ply, siz)
			else
				av:SetSteamID("76561197960265734")
			end
		end
		av:SetPaintedManually(true)
		av:SetSize(siz, siz)
		av:Dock(FILL)

			-- TODO: refresh on lang change
			local btn = vgui.Create("DButton", av)
			btn:SetToolTip(self.Lang("click_here_to_view_x_profile", isstring(ply) and ply or ply:Nick()))
			btn:SetText("")
			btn:Dock(FILL)
			btn.Paint = function() end
			btn.DoClick = function(me)
				gui.OpenURL(url)
			end

	pnl.Paint = function(me, w, h)
		if (chat_roundavatars:GetBool()) then
			render.ClearStencil()
			render.SetStencilEnable(true)

			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilPassOperation(STENCILOPERATION_ZERO)
			render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
			render.SetStencilReferenceValue(1)

			draw.NoTexture()
			surface.SetDrawColor(color_black)
			DrawCircle(hsiz, hsiz, hsiz, hsiz)

			render.SetStencilFailOperation(STENCILOPERATION_ZERO)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetStencilReferenceValue(1)

			av:PaintManual()

			render.SetStencilEnable(false)
			render.ClearStencil()
		else
			av:PaintManual()
		end
	end

	return pnl
end

function LOUNGE_CHAT.Color(c)
	return LOUNGE_CHAT.Style[c]
end

function LOUNGE_CHAT.Lang(s, ...)
	return string.format(LOUNGE_CHAT.Language[s] or s, ...)
end

function LOUNGE_CHAT.ParseColor(col)
	if (istable(col) and col.r) then
		return col
	end

	if (isstring(col)) then
		local h = LOUNGE_CHAT.Colors[col:lower()]
		if (h) then
			return LOUNGE_CHAT.HexToColor(h)
		elseif (col:len() == 6) then
			return LOUNGE_CHAT.HexToColor(col)
		else
			local _, __, r, g, b = string.find(col, "(%d+),(%d+),(%d+)")
			if (r and g and b) then
				return Color(r, g, b)
			end
		end
	end

	return color_white
end

function LOUNGE_CHAT.ColorToHex(col)
	local nR, nG, nB = col.r, col.g, col.b

    local sColor = ""
    nR = string.format("%X", nR)
    sColor = sColor .. ((string.len(nR) == 1) and ("0" .. nR) or nR)
    nG = string.format("%X", nG)
    sColor = sColor .. ((string.len(nG) == 1) and ("0" .. nG) or nG)
    nB = string.format("%X", nB)
    sColor = sColor .. ((string.len(nB) == 1) and ("0" .. nB) or nB)

    return sColor
end

function LOUNGE_CHAT.HexToColor(hex)
	if (type(hex) ~= "string") then
		return end

	hex = hex:gsub("#","")
	local r, g, b = tonumber("0x"..hex:sub(1, 2)), tonumber("0x"..hex:sub(3, 4)), tonumber("0x"..hex:sub(5, 6))

	return Color(r or 255, g or 255, b or 255)
end

function LOUNGE_CHAT.Timestamp(time)
	return os.date(LOUNGE_CHAT.TimestampFormat, time or os.time())
end

function LOUNGE_CHAT.GetDownloadedImage(url)
	local filename = util.CRC(url)
	local path = LOUNGE_CHAT.ImageDownloadFolder .. "/" .. filename .. ".png"

	if (file.Exists(path, "DATA")) then
		return Material("data/" .. path, "noclamp smooth")
	else
		return false
	end
end

function LOUNGE_CHAT.DownloadImage(url, success, failed)
	local filename = util.CRC(url)
	local path = LOUNGE_CHAT.ImageDownloadFolder .. "/" .. filename .. ".png"

	failed = failed or function() end

	http.Fetch(url, function(body)
		if (!body) then
			failed()
			return
		end

		if (!file.IsDir(LOUNGE_CHAT.ImageDownloadFolder, "DATA")) then
			file.CreateDir(LOUNGE_CHAT.ImageDownloadFolder)
		end

		local ok = pcall(function()
			file.Write(path, body)
			success(Material("data/" .. path, "noclamp smooth"))
		end)

		if (!ok) then
			failed()
		end
	end)
end

local floor = math.floor

function LOUNGE_CHAT.SecondsToEnglish(d, s)
	s = s or false
	d = math.max(0, math.Round(d))
	local tbl = {}

	if (d >= 31556926) then
		local i = floor(d / 31556926)
		table.insert(tbl, i .. (s and "y" or " year" .. (i > 1 and "s" or "")))
		d = d % 31556926
	end
	if (d >= 2678400) then
		local i = floor(d / 2678400)
		table.insert(tbl, i .. (s and "m" or " month" .. (i > 1 and "s" or "")))
		d = d % 2678400
	end
	if (d >= 86400) then
		local i = floor(d / 86400)
		table.insert(tbl, i .. (s and "d" or " day" .. (i > 1 and "s" or "")))
		d = d % 86400
	end
	if (d >= 3600) then
		local i = floor(d / 3600)
		table.insert(tbl, i .. (s and "h" or " hour" .. (i > 1 and "s" or "")))
		d = d % 3600
	end
	if (d >= 60) then
		local i = floor(d / 60)
		table.insert(tbl, i .. (s and "min" or " minute" .. (i > 1 and "s" or "")))
		d = d % 60
	end
	if (d > 0) then
		table.insert(tbl, d .. (s and "s" or " second" .. (d > 1 and "s" or "")))
	end

	return table.concat(tbl, ", ")
end

LOUNGE_CHAT.utf8 = {}

function LOUNGE_CHAT.utf8.sub(str, s, e)
	str = utf8.force(str)

	s = s or 1
	e = e or str:len()

	local maxchars = -1
	if (e < 0) then -- starting from the end
		maxchars = utf8.len(str) - math.abs(e)
		e = str:len()
	end

	local ns = ""
	for p, c in utf8.codes(str) do
		if (p < s) or (c == 2560) then
			continue
		elseif (p > e) then
			break end

		local ch
		local ok = pcall(function()
			ch = utf8.char(c)
		end)

		if (!ok) then
			continue end

		ns = ns .. ch

		if (maxchars > 0) then
			maxchars = maxchars - 1

			if (maxchars == 0) then
				break
			end
		end
	end

	return ns
end

function LOUNGE_CHAT.sub(str, s, e)
	if (LOUNGE_CHAT.UseUTF8) then
		return LOUNGE_CHAT.utf8.sub(str, s, e)
	else
		return string.sub(str, s, e)
	end
end

local _material = Material("effects/flashlight001")




local default_clr = Color( 198, 198, 198 )
local scp_clr = Color( 180, 0, 0 )
local intercom_clr = Color( 0, 0, 180, 180 )

function LOUNGE_CHAT:Underscore( player, siz )

	local emphasize = vgui.Create( "DLabel" )
	emphasize:SetPos( 64, 64 );
	emphasize:SetFont( "MM_Exp" )

	local client = LocalPlayer()
	local team = client:GTeam()

	local col = default_clr

	if ( player.UsingIntercom ) then

		role = "<<INTERCOM>>"
		col = intercom_clr

	elseif ( team != TEAM_SPEC && !client:CanSee( player ) && !player.UsingIntercom && !( team == TEAM_SCP && player:GTeam() == TEAM_SCP ) ) then

		role 	= "<Неизвестный>"

	elseif ( player:GTeam() == TEAM_SCP ) then

		role = player:GetNamesurvivor()
		col = scp_clr

	else

		role = player:GetNamesurvivor()

	end
	emphasize:SetTextColor( col )
	emphasize:SetText( role );
	emphasize:SizeToContents()

	emphasize.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 15, w, 2, col )

	end

	return emphasize;
end

local gas_monitor = Model( "models/next_breach/gas_monitor.mdl" )
local angle_front = Angle( 0, 90, 0 )
local vec_offset = Vector( 0, 0, -30 )

-- ============================================================================
-- НАСТРОЙКА 3D-АВАТАРОК В ЧАТЕ (СТИЛЬ CORPSES / KIA)
-- ============================================================================

function LOUNGE_CHAT:DrawCharacterAvatar(ply)
    if not IsValid(ply) then return nil end

    local size = 32 -- Стандартный размер аватарки в чате
    local char = vgui.Create("DModelPanel",self)
    char:SetSize(size, size)
    char:SetModel(ply:GetModel())
    
    -- Bodygroups (Переносим бодигруппы игрока)
    for i = 0, 9 do
        if IsValid(char.Entity) then
            char.Entity:SetBodygroup(i, ply:GetBodygroup(i))
        end
    end

    -- Bonemerges (Одежда, шлемы, аксессуары)
    if IsValid(char.Entity) then
        for _, bonemerge in pairs(ply:LookupBonemerges()) do
            if not IsValid(bonemerge) then continue end
            char:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin())
        end
    end

    -- Направление света (Мрачный красный отсвет справа, как в KIA панели)
    char:SetDirectionalLight(BOX_TOP, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_FRONT, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_RIGHT, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_LEFT, Color(158, 130, 130))

    if IsValid(char.Entity) and table.IsEmpty(char.Entity:LookupBonemerges()) then
        char:SetDirectionalLight(BOX_TOP, Color(0, 0, 0))
        char:SetDirectionalLight(BOX_FRONT, Color(0, 0, 0))
        char:SetDirectionalLight(BOX_RIGHT, Color(0, 0, 0))
        char:SetDirectionalLight(BOX_LEFT, Color(46, 28, 28))
    end

    -- Замораживаем скелет в позе трупа
    if IsValid(char.Entity) then
        local seq = char.Entity:LookupSequence("ragdoll")
        if seq and seq ~= -1 then
            char.Entity:SetSequence(seq)
        else
            char.Entity:SetSequence(0)
        end
        char.Entity:SetPlaybackRate(0) -- Полностью останавливаем анимацию
    end

    -- Фокусировка камеры на голову
    local eyepos
    if IsValid(char.Entity) and char.Entity:LookupBone("ValveBiped.Bip01_Head1") then
        eyepos = char.Entity:GetBonePosition(char.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    else
        char:SetModel("models/cultist/humans/corpse.mdl")
        if IsValid(char.Entity) and char.Entity:LookupBone("ValveBiped.Bip01_Head1") then
            eyepos = char.Entity:GetBonePosition(char.Entity:LookupBone("ValveBiped.Bip01_Head1"))
        end
    end

    if eyepos then
        eyepos:Add(Vector(0, 0, 2))
        char:SetLookAt(eyepos)
        char:SetFOV(35)
        char:SetCamPos(eyepos - Vector(-25, 0, 0))
        if IsValid(char.Entity) then
            char.Entity:SetEyeTarget(eyepos - Vector(-12, 0, 0))
        end
    end

    local ang = Angle(0, 25, 0)
    function char:LayoutEntity(ent)
        ent:SetAngles(ang)
        ent:SetCycle(0) -- Жестко фиксируем кадр в статике, чтобы голова не уплывала
        return
    end

    function char:RunAnimation(ent)
    end

    return char
end

function LOUNGE_CHAT:DrawUnknownCharacter(ply)
    local size = 32
    local char = vgui.Create("DModelPanel",self)
    char:SetSize(size, size)
    char:SetModel("models/cultist/humans/corpse.mdl")

    -- Свет для неизвестного персонажа
    char:SetDirectionalLight(BOX_TOP, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_FRONT, Color(0, 0, 0))
    char:SetDirectionalLight(BOX_RIGHT, Color(0,0,0))
    char:SetDirectionalLight(BOX_LEFT, Color(145, 102, 102))

    if IsValid(char.Entity) then
        char.Entity:SetSequence(0)
        char.Entity:SetPlaybackRate(0)
    end

    local eyepos
    if IsValid(char.Entity) and char.Entity:LookupBone("ValveBiped.Bip01_Head1") then
        eyepos = char.Entity:GetBonePosition(char.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    end

    if eyepos then
        eyepos:Add(Vector(0, 0, 2))
        char:SetLookAt(eyepos)
        char:SetFOV(35)
        char:SetCamPos(eyepos - Vector(-25, 0, 0))
        if IsValid(char.Entity) then
            char.Entity:SetEyeTarget(eyepos - Vector(-12, 0, 0))
        end
    end

    local ang = Angle(0, -25, 0)
    function char:LayoutEntity(ent)
        ent:SetAngles(ang)
        ent:SetCycle(0)
        return
    end

    function char:RunAnimation(ent)
    end

    return char
end