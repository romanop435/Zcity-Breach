local surface = surface
local Material = Material
local draw = draw
local DrawToyTown = DrawToyTown
local RunConsoleCommand = RunConsoleCommand;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
local table = table;
local pairs = pairs;
local ScrW = ScrW;
local ScrH = ScrH;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local draw = draw;
local vgui = vgui;
local util = util
local net = net
local player = player


BREACH = BREACH or {}

local blur = Material("pp/blurscreen")
function draw.Blur_New(_x, _y, _w, _h, panel, amount, heavyness)
	local x, y = panel:LocalToScreen( 0, 0 )


	  local scrW, scrH = ScrW(), ScrH()
	  surface.SetDrawColor( 255, 255, 255 )
	  surface.SetMaterial(blur)


	  local sx, sy = panel:LocalToScreen( _x, _y )
	  local sex, syx = panel:LocalToScreen( _x+_w, _y+_h )


	  for i = 1, ( heavyness || 3 ) do


	  	blur:SetFloat( "$blur", ( i / 3 ) * ( amount || 6 ) )
		blur:Recompute()
		render.UpdateScreenEffectTexture()


	  	render.SetScissorRect(sx, sy, sex, syx, true)


		    surface.DrawTexturedRect( x * -1, y * -1, scrW, scrH )


	    render.SetScissorRect( 0, 0, 0, 0, false )


	end
end


function draw.Blur(x, y, w, h)
	local X, Y = 0,0


	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)


	for i = 1, 5 do
		blur:SetFloat("$blur", (i / 3) * (2))
		blur:Recompute()


		render.UpdateScreenEffectTexture()


		render.SetScissorRect(x, y, x+w, y+h, true)
			surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
   
   
   surface.SetDrawColor(0,0,0, 50) 
   surface.DrawOutlinedRect(x,y,w,h)
end
 

surface.CreateFont("Waitingmini", {font = "Hitmarker Normal",
                                  size = 40,
								  extended = true,
                                  weight = 500,	outline = true})

surface.CreateFont("Waiting", {font = "Hitmarker Normal",
                                  size = 70,
								  extended = true,
                                  weight = 500,	outline = true})

surface.CreateFont("ImpactBig4", {font = "Hitmarker Normal",
                                  size = 150,
								  extended = true,
								  scanlines = 3,
                                  weight = 200})
surface.CreateFont("ImpactBig3", {font = "Hitmarker Normal",
                                  size = 100,
								  extended = true,
								  scanlines = 3,
                                  weight = 200})
surface.CreateFont("ImpactBig3m", {font = "Hitmarker Normal",
                                  size = 90,
								  extended = true,
								  scanlines = 3,
                                  weight = 200})
surface.CreateFont("ImpactBig2", {font = "Hitmarker Normal",
                                  size = 70,
								  extended = true,
								  scanlines = 3,
                                  weight = 200})

surface.CreateFont("ImpactBig", {font = "Hitmarker Normal",
                                  size = 45,
								  	extended = true,
								  scanlines = 3,
                                  weight = 700})
surface.CreateFont("ImpactSmall42", {font = "Hitmarker Normal",
                                  size = 35,
								  	extended = true,
								  scanlines = 3,
                                  weight = 700})
surface.CreateFont("ImpactSmall", {font = "Hitmarker Normal",
                                  size = 30,
								  	extended = true,
								  scanlines = 3,
                                  weight = 700})
surface.CreateFont("ImpactSmallest", {font = "Hitmarker Normal",
                                  size = 20,
								  	extended = true,
								  scanlines = 3,
                                  weight = 700})
surface.CreateFont("ImpactSmall2", {font = "Hitmarker Normal",
                                  size = 15,
								  	extended = true,
								  scanlines = 3,
                                  weight = 700})

surface.CreateFont("ImpactSmall2n", {font = "Hitmarker Normal",
                                  size = 15,
								  	extended = true,
								  scanlines = 0,
                                  weight = 500})

surface.CreateFont("ImpactSmall22", {font = "Hitmarker Normal",
                                  size = 5,
								  	extended = true,
								  scanlines = 3,
                                  weight = 300})

surface.CreateFont( "RadioFont", {
	font = "Hitmarker Normal",
	extended = true,
	size = 26,
	weight = 7000,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "RadioFont_mini", {
	font = "Hitmarker Normal",
	extended = true,
	size = 11,
	weight = 100,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont("new_spec_2", {font = "Hitmarker Normal",
                                  size = 30,
								  	extended = true,
								  scanlines = 0,
                                  weight = 700})

local custom_vector = Vector( 1, 1, 1 )

hook.Remove("HUDPaint", "BreachTEST")

local ANGLE = FindMetaTable( "Angle" )

local client = LocalPlayer()

net.Receive("create_Headshot", function(len)

	local en = net.ReadEntity()
	local origin = net.ReadVector()
	local Normal = net.ReadVector()

	local efdata = EffectData()
	efdata:SetEntity(en)
	efdata:SetOrigin(origin)
	efdata:SetNormal(Normal)
	util.Effect( "headshot", efdata )

end)

local clr_green = Color( 0, 255, 0 )

net.Receive("LevelBar", function()
    local stats = net.ReadTable()
    local my_xp = net.ReadUInt(32)
    local extra_data = net.ReadTable() or {}
    NewProgressLevelBar(stats, my_xp, extra_data)
end)


surface.CreateFont("EXP_Title", { font = "Hitmarker Normal", size = 22, weight = 300, extended = true })
surface.CreateFont("EXP_Numbers", { font = "Hitmarker Normal", size = 20, weight = 300, extended = true })
surface.CreateFont("EXP_Reason", { font = "Hitmarker Normal", size = 16, weight = 300, extended = true })
surface.CreateFont("EXP_Sub", { font = "Hitmarker Normal", size = 14, weight = 300, extended = true })

local rust_bg       = Color(15, 14, 13, 220)
local rust_panel    = Color(25, 23, 21, 255)
local rust_outline  = Color(255, 255, 255, 15)
local rust_yellow   = Color(218, 165, 32)
local rust_red      = Color(190, 40, 30)
local rust_green    = Color(112, 126, 73)
local rust_blue     = Color(80, 160, 220)
local rust_purple   = Color(160, 80, 200)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(100, 100, 100)

function NewProgressLevelBar(stats, my_xp, extra_data)
    local client = LocalPlayer()
    extra_data = extra_data or {}
    
    local total_exp = 0
    for _, v in ipairs(stats) do
        v.value = math.floor(v.value)
        total_exp = total_exp + v.value
    end
    table.SortByMember(stats, "value", true)

    if not BREACH.Level then BREACH.Level = {} end
    if IsValid(BREACH.Level.main_panel) then BREACH.Level.main_panel:Remove() end
    if IsValid(BREACH.Level.EXP_Panel) then BREACH.Level.EXP_Panel:Remove() end

    local sw, sh = ScrW(), ScrH()
    local targetX = sw * 0.3 
    local targetY_main = sh * 0.85 
    local listHeight = math.max(150, #stats * 30 + 40)
    local targetY_panel = targetY_main - listHeight + 10

    BREACH.Level.main_panel = vgui.Create("DPanel")
    local pnl = BREACH.Level.main_panel
    pnl.BaseW, pnl.BaseH = sw * 0.4, 60
    pnl:SetSize(pnl.BaseW, pnl.BaseH)
    pnl:SetPos(targetX, targetY_main + 50)
    pnl:SetAlpha(0)
    pnl:SetZPos(32767)

    pnl.VisualValue = my_xp or 0
    pnl.VisualLevel = client.GetNLevel and client:GetNLevel() or 0
    pnl.MaxXP = math.max(client:RequiredEXP() or 1000, 1)
    
    pnl.TotalExpectedXP = math.max(total_exp, 1)
    pnl.DrainedXP = 0
    
    pnl.CreationTime = SysTime()
    pnl.FinishTime = nil
    pnl.FlashAlpha = 0

    pnl.Anim = { scale = 0.8, yOffset = 30, alpha = 0, exit = false, exitAlpha = 255 }

    pnl.Think = function(self)
        local ft = FrameTime()
        local t = SysTime()
        local anim = self.Anim

        if self.FinishTime and t > self.FinishTime + 5.0 and not anim.exit then
            anim.exit = true
        end

        if not anim.exit then
            anim.scale = Lerp(ft * 8, anim.scale, 1)
            anim.yOffset = Lerp(ft * 10, anim.yOffset, 0)
            anim.alpha = Lerp(ft * 8, anim.alpha, 1)

            self:SetAlpha(anim.alpha * 255)
            self:SetPos(targetX + (self.BaseW - self.BaseW * anim.scale) / 2, targetY_main + anim.yOffset)
        else
            anim.exitAlpha = Lerp(ft * 5, anim.exitAlpha, 0)
            self:SetAlpha(anim.exitAlpha)
            self:SetPos(targetX, targetY_main + (255 - anim.exitAlpha) * 0.1)

            if anim.exitAlpha < 1 then
                self:Remove()
                BREACH.Level.main_panel = nil
            end
        end

        if self.FlashAlpha > 0 then
            self.FlashAlpha = math.max(0, self.FlashAlpha - ft * 400)
        end
    end

    pnl.Paint = function(self, w, h)
        local alphaMult = self:GetAlpha() / 255

        draw.SimpleText(L("l:level_bar_level") .. " " .. self.VisualLevel, "EXP_Title", 0, 0, ColorAlpha(rust_text, 255 * alphaMult), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(math.floor(self.VisualValue) .. " / " .. self.MaxXP .. " XP", "EXP_Numbers", w, 2, ColorAlpha(rust_dim, 255 * alphaMult), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

        local barY = 28
        local barH = 4
        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 50 * alphaMult)
        surface.DrawRect(0, barY, w, barH)

        local fillWidth = math.Clamp(w * (self.VisualValue / self.MaxXP), 0, w)
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * alphaMult)
        surface.DrawRect(0, barY, fillWidth, barH)

        if fillWidth > 0 and fillWidth < w then
            surface.SetDrawColor(255, 255, 255, 200 * alphaMult)
            surface.DrawRect(fillWidth - 2, barY - 2, 4, barH + 4)
        end

        if self.FlashAlpha > 0 then
            surface.SetDrawColor(255, 255, 255, self.FlashAlpha * alphaMult)
            surface.DrawRect(0, barY - 4, w, barH + 8)
        end

        local subY = barY + 12
        local curX = 0
        local progressPct = math.Clamp(self.DrainedXP / self.TotalExpectedXP, 0, 1)

        local function DrawDataBlock(title, maxVal, color)
            if not maxVal or maxVal <= 0 then return end
            
            local curVal = math.floor(maxVal * progressPct)
            local txt = title .. " +" .. curVal
            
            surface.SetFont("EXP_Sub")
            local tw, th = surface.GetTextSize(txt)

            surface.SetDrawColor(10, 9, 8, 200 * alphaMult)
            surface.DrawRect(curX, subY, tw + 16, th + 4)

            surface.SetDrawColor(color.r, color.g, color.b, 255 * alphaMult)
            surface.DrawRect(curX, subY, 2, th + 4)

            draw.SimpleText(txt, "EXP_Sub", curX + 8, subY + 2, ColorAlpha(rust_text, 255 * alphaMult), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            curX = curX + tw + 24
        end

        DrawDataBlock(L("l:level_bar_free"), extra_data.free_xp, rust_blue)
        DrawDataBlock(L("l:level_bar_role"), extra_data.target_xp, rust_yellow)
        DrawDataBlock(L("l:level_bar_faction"), extra_data.faction_xp, rust_green)
        DrawDataBlock(L("l:level_bar_module"), extra_data.upg_xp, rust_purple)
    end

    BREACH.Level.EXP_Panel = vgui.Create("DPanel")
    local listPnl = BREACH.Level.EXP_Panel
    listPnl:SetSize(sw * 0.4, listHeight)
    listPnl:SetPos(targetX, targetY_panel + 30)
    listPnl:SetAlpha(0)
    listPnl:SetZPos(32767)
    listPnl.Paint = function() end 

    listPnl.Anim = { alpha = 0, yOffset = 30 }

    listPnl.Think = function(self)
        local ft = FrameTime()
        if not IsValid(pnl) then self:Remove() return end

        if not pnl.Anim.exit then
            self.Anim.alpha = Lerp(ft * 8, self.Anim.alpha, 1)
            self.Anim.yOffset = Lerp(ft * 10, self.Anim.yOffset, 0)
            self:SetAlpha(self.Anim.alpha * 255)
            self:SetPos(targetX, targetY_panel + self.Anim.yOffset)
        else
            self:SetAlpha(pnl:GetAlpha())
            self:SetPos(targetX, targetY_panel + (255 - pnl:GetAlpha()) * 0.1)
        end
    end

    listPnl.ChildrenItems = {}
    local parentW = listPnl:GetWide()
    local parentH = listPnl:GetTall()

    for i, stat in ipairs(stats) do
        local child = vgui.Create("DPanel", listPnl)
        
        child.Value = math.floor(stat.value)
        child.Remaining = child.Value
        child.Reason = string.upper(BREACH.TranslateString(stat.reason) or stat.reason)
        child.Index = i 
        
        child.clr = child.Value < 0 and rust_red or rust_yellow
        child:SetSize(parentW, 25)
        child.CurY = parentH - 30 - 30 * (i - 1)
        child:SetPos(0, child.CurY)
        child:SetAlpha(0)

        child.IsActive = false
        child.IsDying = false
        child.Speed = math.max(math.abs(child.Value) * 1.5, 300)

        child.Think = function(self)
            local ft = FrameTime()
            if not IsValid(pnl) then return end

            local targetY = parentH - 30 - 30 * (self.Index - 1)
            self.CurY = Lerp(ft * 12, self.CurY, targetY)
            self:SetPos(0, self.CurY)

            local targetAlpha = self.IsActive and 255 or 100
            if self.IsDying then targetAlpha = 0 end
            self:SetAlpha(math.Approach(self:GetAlpha(), targetAlpha, ft * 800))

            if self.IsActive and not self.IsDying then
                if not self.SoundPlayed then
                    --surface.PlaySound("UI/buttonrollove.wav")
                    self.SoundPlayed = true
                end

                local drain = ft * self.Speed
                if math.abs(self.Remaining) > 0 then
                    drain = math.min(drain, math.abs(self.Remaining))
                    
                    if self.Remaining > 0 then
                        self.Remaining = self.Remaining - drain
                        pnl.VisualValue = pnl.VisualValue + drain
                        pnl.DrainedXP = pnl.DrainedXP + drain
                    else
                        self.Remaining = self.Remaining + drain
                        pnl.VisualValue = pnl.VisualValue - drain
                    end

                    if pnl.VisualValue >= pnl.MaxXP then
                        --surface.PlaySound("garrysmod/save_load1.wav")
                        pnl.FlashAlpha = 255
                        pnl.VisualLevel = pnl.VisualLevel + 1
                        pnl.VisualValue = pnl.VisualValue - pnl.MaxXP
                        pnl.MaxXP = pnl.MaxXP + math.floor(pnl.MaxXP / pnl.VisualLevel) 
                    end
                else
                    self.Remaining = 0
                    self.IsDying = true

                    timer.Simple(0.2, function()
                        if not IsValid(self) or not IsValid(listPnl) then return end
                        table.RemoveByValue(listPnl.ChildrenItems, self)
                        
                        for k, v in ipairs(listPnl.ChildrenItems) do
                            v.Index = k
                        end

                        if listPnl.ChildrenItems[1] then
                            listPnl.ChildrenItems[1].IsActive = true
                        else
                            pnl.FinishTime = SysTime()
                            pnl.DrainedXP = pnl.TotalExpectedXP
                        end
                        self:Remove()
                    end)
                end
            end
        end

        child.Paint = function(self, w, h)
            local alphaMult = self:GetAlpha() / 255
            local displayVal = self.Remaining
            local sign = self.Value > 0 and "+" or "-"
            local valText = sign .. math.ceil(math.abs(displayVal)) .. " XP"

            if self.IsActive then
                surface.SetDrawColor(self.clr.r, self.clr.g, self.clr.b, 15 * alphaMult)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(self.clr.r, self.clr.g, self.clr.b, 255 * alphaMult)
                surface.DrawRect(0, 0, 3, h)
            end

            draw.SimpleText(self.Reason, "EXP_Reason", 15, h/2 - 1, ColorAlpha(rust_text, 255 * alphaMult), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(valText, "EXP_Numbers", w - 10, h/2 - 1, ColorAlpha(self.clr, 255 * alphaMult), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        listPnl.ChildrenItems[i] = child
    end

    timer.Simple(1.5, function()
        if IsValid(listPnl) and listPnl.ChildrenItems[1] then
            listPnl.ChildrenItems[1].IsActive = true
        end
    end)
end

local banned_Teams = {

  [ TEAM_SPEC ] = true,
  [ TEAM_SCP ] = true

}

local LCSpacing = -30
local wepclr = Color( 198, 198, 198, 210 )
local txtclr = Color( 127, 127, 127, 180 )

local scp_049_text_col1 = Color( 0, 180, 127, 180 )
local scp_049_text_col2 = Color( 200, 127, 127, 180 )
local chaoscolor = Color(29, 81, 56)

hook.Add("PreDrawOutlines", "CHAOS_SPY", function()

	local client = LocalPlayer()
  local client_team = client:GTeam()
  
  	if client_team == TEAM_CHAOS or client_team == TEAM_CLASSD then
	  for i = 1, player.GetCount() do

	  	local ply = player.GetAll()[i]

	  	if ply == client then continue end
	  	if ply:GetRoleName() != role.SECURITY_Spy then continue end
	  	if ply:Health() < 0 then continue end

	  	

			local entstab = ply:LookupBonemerges()
			entstab[#entstab + 1] = ply

			outline.Add(entstab, chaoscolor, OUTLINE_MODE_VISIBLE)

	  end
	end
	if client_team == TEAM_CBG then
	  for i = 1, player.GetCount() do

	  	local ply = player.GetAll()[i]

	  	if ply == client then continue end
	  	if ply:GetRoleName() != role.CBG_Spec then continue end
	  	if ply:Health() < 0 then continue end

	  	

			local entstab = ply:LookupBonemerges()
			entstab[#entstab + 1] = ply

			outline.Add(entstab, Color(200, 127, 127), OUTLINE_MODE_VISIBLE)

	  end
	end
end)





local rust_panel    = Color(15, 14, 13, 240)
local rust_outline  = Color(255, 255, 255, 15)
local rust_yellow   = Color(218, 165, 32)
local rust_green    = Color(112, 126, 73)
local rust_red      = Color(188, 64, 43)
local rust_text     = Color(230, 230, 230)
local rust_text_dim = Color(140, 140, 140)

local rarity_omg    = Color(255, 180, 0, 200)
local rarity_scp    = Color(255, 50, 50, 200)
local wep_default   = Color(200, 200, 200, 150)

local function ColorAlphaMult(col, alphaMult)
    return Color(col.r, col.g, col.b, col.a * alphaMult)
end

local function ForceMoveProgress(pBar, targetX, targetY, targetW, targetH)
    if not IsValid(pBar) then return end
    
    if not pBar.HookedByRustUI then
        pBar.HookedByRustUI = true
        local oldThink = pBar.Think or function() end
        pBar.Think = function(self)
            oldThink(self)
            if self.IsEmbedded and self.RustX and self.RustY then
                self:SetPos(self.RustX, self.RustY)
                self:SetSize(self.RustW, self.RustH)
            end
        end
    end

    pBar.IsEmbedded = true
    pBar.RustX = targetX
    pBar.RustY = targetY
    pBar.RustW = targetW
    pBar.RustH = targetH
end

hook.Add("HUDPaint", "DrawBoxInfoOnRagdoll", function()
    local client = LocalPlayer()
    local client_team = client:GTeam()

    if (banned_Teams[client_team] and client:GetRoleName() ~= "SCP049") or client:Health() <= 0 then return end

    local pBar = client.progressbar
    local isLooting = IsValid(pBar)
    
    if IsValid(pBar) then
        pBar.IsEmbedded = false 
    end

    local startPos, aimDirScaled, filter = hg.eye(client, 150)
    if not startPos then 
        startPos = client:GetShootPos() 
        aimDirScaled = client:GetAimVector() * 150
        filter = client
    end

    local tr = util.TraceLine({
        start = startPos,
        endpos = startPos + aimDirScaled,
        filter = filter
    })
    
    local ent = tr.Entity

    if not IsValid(ent) or ent:IsPlayer() or ent:IsWorld() then
        tr = util.TraceHull({
            start = startPos,
            endpos = startPos + aimDirScaled,
            mins = Vector(-8, -8, -8),
            maxs = Vector(8, 8, 8),
            filter = filter
        })
        ent = tr.Entity
    end

    if not IsValid(ent) or ent:IsPlayer() or ent:IsWorld() then return end

    local class = ent:GetClass()
    local is_ragdoll = (class == "prop_ragdoll")
    local is_item = ent:IsWeapon() or string.find(class, "item_") or string.find(class, "kasanov_") or ent.Equipableitem

    if not is_ragdoll and not is_item then return end

    local distSqr = ent:GetPos():DistToSqr(startPos)
    if distSqr > 20000 then return end 

    local alphaMult = math.Clamp(math.Remap(math.sqrt(distSqr), 100, 140, 1, 0), 0, 1)
    if alphaMult <= 0.05 then return end

    local centerPos = ent:WorldSpaceCenter()
    local scr = centerPos:ToScreen()
    if not scr.visible then return end

    local c_panel   = ColorAlphaMult(rust_panel, alphaMult)
    local c_outline = ColorAlphaMult(rust_outline, alphaMult)
    local c_yellow  = ColorAlphaMult(rust_yellow, alphaMult)
    local c_green   = ColorAlphaMult(rust_green, alphaMult)
    local c_red     = ColorAlphaMult(rust_red, alphaMult)
    local c_text    = ColorAlphaMult(rust_text, alphaMult)
    local c_dim     = ColorAlphaMult(rust_text_dim, alphaMult)

    local boxX = scr.x + 40
    local use_key = input.LookupBinding("+use") and string.upper(input.LookupBinding("+use")) or "E"

    if is_item then
        local wepclr = wep_default
        if ent.red == "OMG" then wepclr = rarity_omg
        elseif ent.red == "SCP" then wepclr = rarity_scp end
        
        outline.Add({ent}, wepclr, OUTLINE_MODE_VISIBLE)

        local itemName = ent.PrintName or class
        if ent:IsWeapon() and ent.GetPrintName then 
            itemName = ent:GetPrintName() 
        end
        itemName = string.upper(L(itemName) or itemName)

        local boxW = 250
        local boxH = isLooting and 45 or 75
        local boxY = scr.y - boxH / 2

        surface.SetDrawColor(c_yellow)
        surface.DrawRect(scr.x - 2, scr.y - 2, 4, 4)
        surface.SetDrawColor(c_outline)
        surface.DrawLine(scr.x, scr.y, boxX, scr.y)

        surface.SetDrawColor(c_panel)
        surface.DrawRect(boxX, boxY, boxW, boxH)
        surface.SetDrawColor(c_outline)
        surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 1)

        surface.SetDrawColor(ColorAlphaMult(wepclr, alphaMult))
        surface.DrawRect(boxX, boxY, 4, boxH)

        draw.SimpleText(itemName, "MM_Exp", boxX + 15, boxY + 12, ColorAlphaMult(color_white, alphaMult), TEXT_ALIGN_LEFT)

        if isLooting then
            ForceMoveProgress(pBar, boxX, boxY + boxH + 5, boxW, 40)
            
            if IsValid(client.progressbaricon) then 
                client.progressbaricon:SetPos(-9999, -9999) 
            end
        else
            surface.SetDrawColor(c_green)
            surface.DrawRect(boxX + 15, boxY + 40, 20, 18)
            draw.SimpleText(use_key, "MM_SmallName", boxX + 25, boxY + 49, Color(15, 15, 15, 255 * alphaMult), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            local takeTxt = "ПОДОБРАТЬ"
            draw.SimpleText(takeTxt, "MM_SmallName", boxX + 45, boxY + 49, c_green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

    elseif is_ragdoll then

        if client:HasWeapon("weapon_scp_049_redux") then
            outline.Add({ent}, wep_default, OUTLINE_MODE_VISIBLE)

            if ent:GetNWBool("Death_SCP049_IsVictim", false) then
                local can_res = ent:GetNWBool("Death_SCP049_CanRessurect", false)
                
                local boxW = 340
                local boxH = can_res and 75 or 45
                local boxY = scr.y - boxH / 2

                surface.SetDrawColor(can_res and c_green or c_red)
                surface.DrawRect(scr.x - 2, scr.y - 2, 4, 4)
                surface.SetDrawColor(c_outline)
                surface.DrawLine(scr.x, scr.y, boxX, scr.y)

                surface.SetDrawColor(c_panel)
                surface.DrawRect(boxX, boxY, boxW, boxH)
                surface.SetDrawColor(c_outline)
                surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 1)

                if can_res then
                    surface.SetDrawColor(c_green)
                    surface.DrawRect(boxX, boxY, 4, boxH)
                    draw.SimpleText(string.upper(L("l:scp049_targetisalive") or "БИОМАТЕРИАЛ ПРИГОДЕН"), "MM_Exp", boxX + 15, boxY + 12, c_green, TEXT_ALIGN_LEFT)

                    surface.SetDrawColor(c_text)
                    surface.DrawRect(boxX + 15, boxY + 40, 20, 18)
                    draw.SimpleText("E", "MM_SmallName", boxX + 25, boxY + 49, Color(15,15,15, 255*alphaMult), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(string.upper(L("l:scp049_press_e") or "ВЫЛЕЧИТЬ"), "MM_SmallName", boxX + 40, boxY + 49, c_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    surface.SetDrawColor(c_red)
                    surface.DrawRect(boxX + boxW/2, boxY + 40, 20, 18)
                    draw.SimpleText("R", "MM_SmallName", boxX + boxW/2 + 10, boxY + 49, Color(15,15,15, 255*alphaMult), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(string.upper(L("l:scp049_press_r") or "ЗОМБИРОВАТЬ"), "MM_SmallName", boxX + boxW/2 + 25, boxY + 49, c_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(c_red)
                    surface.DrawRect(boxX, boxY, 4, boxH)
                    draw.SimpleText(string.upper(L("l:scp049_targetisdead") or "БИОМАТЕРИАЛ ИСПОРЧЕН"), "MM_Exp", boxX + 15, boxY + 12, c_red, TEXT_ALIGN_LEFT)
                end
            end

        elseif not IsValid(LC_LootMenu) and client_team ~= TEAM_SCP then
            local tab = {ent}
            local bnmrgtab = ents.FindByClassAndParent("ent_bonemerged", ent)
            if istable(bnmrgtab) then
                tab = bnmrgtab
                tab[#tab + 1] = ent
            end
            outline.Add(tab, wep_default, OUTLINE_MODE_VISIBLE)

            local body_time = ent:GetNWInt("DiedWhen", false)
            local minutes_str = BREACH.TranslateString("l:body_cant_determine_death_time")
            if body_time and body_time > 0 then
                local timesincedeath = os.time() - body_time
                local minutes = timesincedeath / 60
                if minutes < 1 then
                    minutes_str = BREACH.TranslateString("l:body_died_right_now")
                else
                    minutes = math.Round(minutes)
                    local lastdigit = math.floor(minutes % 10)
                    local suffix = ""
                    if (minutes >= 10 and minutes <= 20) or lastdigit > 4 or lastdigit == 0 then
                        suffix = "  l:body_minutes_ago"
                    elseif lastdigit == 1 then
                        suffix = "  l:body_1minute_ago"
                    elseif lastdigit > 1 and lastdigit < 5 then
                        suffix = "  l:body_2to4minutes_ago"
                    end
                    minutes_str = BREACH.TranslateString("l:body_death_happened  " .. minutes .. suffix)
                end
            end

            local r1 = string.upper(BREACH.TranslateString(ent:GetNWString("DeathReason1", "l:body_death_unknown")))
            local r2 = string.upper(BREACH.TranslateString(ent:GetNWString("DeathReason2", "")))

            local boxW = 380
            local boxH = (r2 == "") and 90 or 110 
            local boxY = scr.y - boxH / 2

            surface.SetDrawColor(c_yellow)
            surface.DrawRect(scr.x - 2, scr.y - 2, 4, 4)
            surface.SetDrawColor(c_outline)
            surface.DrawLine(scr.x, scr.y, boxX, scr.y)

            surface.SetDrawColor(c_panel)
            surface.DrawRect(boxX, boxY, boxW, boxH)
            surface.SetDrawColor(c_outline)
            surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 1)

            surface.SetDrawColor(c_yellow)
            surface.DrawRect(boxX, boxY, 4, boxH)

            local survName = string.upper(ent:GetNWString("SurvivorName", "ТРУП"))
            if survName == "" then survName = "ТРУП" end
            draw.SimpleText(survName, "MM_Exp", boxX + 15, boxY + 12, ColorAlphaMult(color_white, alphaMult), TEXT_ALIGN_LEFT)

            draw.SimpleText(string.upper(minutes_str), "MM_SmallName", boxX + boxW - 15, boxY + 14, c_dim, TEXT_ALIGN_RIGHT)

            surface.SetDrawColor(c_outline)
            surface.DrawLine(boxX + 15, boxY + 35, boxX + boxW - 15, boxY + 35)

            draw.SimpleText(r1, "MM_SmallName", boxX + 15, boxY + 45, c_text, TEXT_ALIGN_LEFT)
            if r2 ~= "" then
                draw.SimpleText(r2, "MM_SmallName", boxX + 15, boxY + 60, c_red, TEXT_ALIGN_LEFT)
            end

            surface.SetDrawColor(c_green)
            surface.DrawRect(boxX + 15, boxY + boxH - 28, 20, 18)
            draw.SimpleText(use_key, "MM_SmallName", boxX + 25, boxY + boxH - 19, Color(15, 15, 15, 255 * alphaMult), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            local searchTxt = string.upper(BREACH.TranslateString("l:body_search") or "ОБЫСКАТЬ")
            draw.SimpleText(searchTxt, "MM_SmallName", boxX + 45, boxY + boxH - 19, c_green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end)



hook.Add("Think", "RestoreProgressBarPos", function()
    local ply = LocalPlayer()
    local pnl = ply.progressbar
    
    if IsValid(pnl) and pnl.IsEmbedded then
        local tr = ply:GetEyeTrace()
        local ent = tr.Entity
        local dist = IsValid(ent) and ent:GetPos():DistToSqr(ply:GetPos()) or 999999
        
        
        if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" or dist > 2500 or IsValid(LC_LootMenu) then
            pnl.IsEmbedded = false
            
            pnl:SetSize(400, 50)
            pnl:SetPos(ScrW() / 2 - 200, ScrH() * 0.8)
            
            if IsValid(ply.progressbaricon) then
                ply.progressbaricon:SetPos(ScrW() / 2 - 260, ScrH() * 0.8)
            end
        end
    end
end)

local scarletmat = Material("nextoren/gui/roles_icon/crb.png")
	hook.Add( "PostDrawTranslucentRenderables", "crb_draw_mark", function( bDepth, bSkybox )
    	local client = LocalPlayer()
		local capos = RB_HEAD
		if RB_HEAD then
		if capos == Vector(0, 0, 0) then return end
			local ang = client:EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			capos = capos + Vector(0,0, 50)
			local dist = client:GetPos():Distance(capos)
			local size = 140 * (math.Clamp(dist * .005, 1, 30))
			if client:GTeam() == TEAM_CBG then
				cam.Start3D2D( capos, ang, 0.1 )
				cam.IgnoreZ(true)
					surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
					surface.SetMaterial(Material( "nextoren/gui/new_icons/rb_head.png" ))
					surface.DrawTexturedRect(-(size/2), -(size/2), size, size);
				cam.End3D2D()
				cam.IgnoreZ(false)
			end
		end

		local capos = RB_HAND
		if RB_HAND then
		if capos == Vector(0, 0, 0) then return end
			local ang = client:EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			capos = capos + Vector(0,0, 50)
			local dist = client:GetPos():Distance(capos)
			local size = 140 * (math.Clamp(dist * .005, 1, 30))
			if client:GTeam() == TEAM_CBG then
				cam.Start3D2D( capos, ang, 0.1 )
				cam.IgnoreZ(true)
					surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
					surface.SetMaterial(Material( "nextoren/gui/new_icons/rb_hands.png" ))
					surface.DrawTexturedRect(-(size/2), -(size/2), size, size);
				cam.End3D2D()
				cam.IgnoreZ(false)
			end
		end

		local capos = RB_BODY
		if RB_BODY then
		if capos == Vector(0, 0, 0) then return end
			local ang = client:EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			capos = capos + Vector(0,0, 50)
			local dist = client:GetPos():Distance(capos)
			local size = 140 * (math.Clamp(dist * .005, 1, 30))
			if client:GTeam() == TEAM_CBG then
				cam.Start3D2D( capos, ang, 0.1 )
				cam.IgnoreZ(true)
					surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
					surface.SetMaterial(Material( "nextoren/gui/new_icons/rb_body.png" ))
					surface.DrawTexturedRect(-(size/2), -(size/2), size, size);
				cam.End3D2D()
				cam.IgnoreZ(false)
			end
		end

		local capos = RB_LEGS
		if RB_LEGS then
		if capos == Vector(0, 0, 0) then return end
			local ang = client:EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			capos = capos + Vector(0,0, 50)
			local dist = client:GetPos():Distance(capos)
			local size = 140 * (math.Clamp(dist * .005, 1, 30))
			if client:GTeam() == TEAM_CBG then
				cam.Start3D2D( capos, ang, 0.1 )
				cam.IgnoreZ(true)
					surface.SetDrawColor(ColorAlpha(color_white, 255 - Pulsate(5) * 40))
					surface.SetMaterial(Material( "nextoren/gui/new_icons/rb_legs.png" ))
					surface.DrawTexturedRect(-(size/2), -(size/2), size, size);
				cam.End3D2D()
				cam.IgnoreZ(false)
			end
		end

	end)

--net.Receive("LevelBar", function()
--	local client = LocalPlayer()
--	local stats = net.ReadTable()
--	local exp = net.ReadUInt(32)
--	NewProgressLevelBar(stats, exp)
--end)





surface.CreateFont("SecondWind_Text", {
    font = "lapkoi Light",
    size = ScreenScale(16),
    weight = 100,
    extended = true,
})

surface.CreateFont("SecondWind_Epic", {
    font = "lapkoi Light",
    size = ScreenScale(45),
    weight = 100,
    extended = true,
})

surface.CreateFont("SecondWind_Epic_Glow", {
    font = "lapkoi Light",
    size = ScreenScale(45),
    weight = 100,
    extended = true,
    blursize = 6,
})


local dialogues = {
    
    {
        {speaker = 1, text = "Ты видишь свет?"},
        {speaker = 2, text = "Только пустоту... Мне так холодно..."},
        {speaker = 1, text = "Это конец. Твое тело больше не выдержит."},
        {speaker = 2, text = "Я ничего не чувствую. Вся боль ушла."},
        {speaker = 1, text = "Просто закрой глаза. Позволь тишине забрать тебя."},
        {speaker = 2, text = "Нет... Там, впереди... Меня еще ждут."},
        {speaker = 1, text = "Ты всего лишь человек. Смирись с судьбой."},
        {speaker = 2, text = "Я... еще... не закончил!"}
    },
    
    
    {
        {speaker = 1, text = "Ты чувствуешь, как замирает сердце? Как замедляется время?"},
        {speaker = 2, text = "Словно... я погружаюсь в глубокий сон..."},
        {speaker = 1, text = "Это вечность. Здесь нет ни страха, ни войны. Отдай мне свою боль."},
        {speaker = 2, text = "Но моя боль... это все, что делает меня живым."},
        {speaker = 1, text = "Разве ты не хочешь свободы от страданий?"},
        {speaker = 2, text = "Без боли я забуду, ради чего я проливал кровь."},
        {speaker = 1, text = "В этой тьме уже не за что сражаться."},
        {speaker = 2, text = "Значит, я стану тем, кто принесет в нее свет."}
    },

    
    {
        {speaker = 1, text = "Твои руки в крови. Оставь их здесь. Дальше пути нет."},
        {speaker = 2, text = "Я так устал... нести весь этот груз..."},
        {speaker = 1, text = "Смерть прощает любые грехи. Шагни в бездну, и ты обретешь покой."},
        {speaker = 2, text = "Покой... Звучит так легко..."},
        {speaker = 1, text = "Один выдох, и все закончится. Ни страха, ни сожалений."},
        {speaker = 2, text = "Но если я уйду сейчас... мои грехи останутся с теми, кто жив."},
        {speaker = 1, text = "Мертвым нет дела до живых."},
        {speaker = 2, text = "Тогда я отказываюсь быть мертвым!"}
    },

    
    {
        {speaker = 1, text = "Твоя нить оборвалась. Спектакль окончен. Занавес опущен."},
        {speaker = 2, text = "Я не слышу своих шагов... Я исчезаю?"},
        {speaker = 1, text = "Ты возвращаешься туда, откуда пришел. В ничто. Растворись."},
        {speaker = 2, text = "Лица... Я начинаю забывать их лица..."},
        {speaker = 1, text = "Память — лишь жалкая иллюзия живых. Тебе она больше не нужна."},
        {speaker = 2, text = "Нет. Моя память — это мое проклятие. И моя сила."},
        {speaker = 1, text = "Никто не в силах обмануть смерть."},
        {speaker = 2, text = "Я не буду её обманывать. Я заставлю её ждать."}
    }

}

local function StartSecondWindScene()
    StopMusic()
    
    
    --LocalPlayer():EmitSound("player/damage3.wav", 100, 80)
    --LocalPlayer():SetDSP(130)

    local sceneData = table.Random(dialogues)
    local bgPanel = vgui.Create("DPanel")
    bgPanel:SetSize(ScrW(), ScrH())
    bgPanel:MakePopup() 
    
    local messageHistory = {}
    local currentLineIdx = 0
    
    local isEpicFinale = false
    local epicStartTime = 0
    
    local screenFadeAlpha = 0
    local sceneStarted = false
    
    bgPanel.Paint = function(self, w, h)
        
        screenFadeAlpha = math.Approach(screenFadeAlpha, 255, FrameTime() * 85)
        
        surface.SetDrawColor(0, 0, 0, screenFadeAlpha)
        surface.DrawRect(0, 0, w, h)

        
        if screenFadeAlpha >= 255 and not sceneStarted then
            sceneStarted = true
            
            
            surface.PlaySound("heartbeat/heartbeat_single.wav")
            timer.Simple(1, AdvanceDialogue) 
        end

        if not sceneStarted then return end

        if not isEpicFinale then
            
            local yOffset = h * 0.75

            for i = #messageHistory, 1, -1 do
                local msg = messageHistory[i]
                
                
                local timeElapsed = CurTime() - msg.startTime
                local time_one_symbol = 0.06
                local time_to_read = utf8.len(msg.text) * time_one_symbol
                local part = math.Clamp(timeElapsed / time_to_read, 0, 1)
                
                local click = math.ceil(part * utf8.len(msg.text))
                
                
                if click ~= msg.lastClick and click > 0 and click <= utf8.len(msg.text) then
                    local char = utf8.sub(msg.text, click, click)
                    if char ~= " " and char ~= "." and char ~= "?" and char ~= "!" then
                        
                        LocalPlayer():EmitSound("snd_jack_peep.wav", 40, 150, 0.5)
                    end
                    msg.lastClick = click
                end
                
                local visibleText = utf8.sub(msg.text, 1, click)
                
                
                local age = CurTime() - msg.endTime
                local alpha = 255
                if msg.isFinished and age > 2 then
                    alpha = math.Clamp(255 - ((age - 2) * 100), 0, 255)
                end

                local xPos = w / 2
                local align = TEXT_ALIGN_CENTER
                local col = Color(255, 255, 255, alpha)

                
                if msg.speaker == 1 then
                    xPos = w * 0.15
                    align = TEXT_ALIGN_LEFT
                    col = Color(200, 100, 100, alpha) 
                else
                    xPos = w * 0.85
                    align = TEXT_ALIGN_RIGHT
                    col = Color(200, 200, 200, alpha) 
                end

                if alpha > 0 then
                    draw.SimpleTextOutlined(visibleText, "SecondWind_Text", xPos, yOffset, col, align, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0, alpha))
                end

                yOffset = yOffset - ScreenScale(25)
            end
        else
            
            local elapsed = CurTime() - epicStartTime
            local progress = math.Clamp(elapsed / 5.5, 0, 1)
            
            
            local easedProgress = math.ease.InOutCubic(progress)
            local epicAlpha = 255 * easedProgress
            
            
            local maxShake = 4 * easedProgress
            local shakeX = math.Rand(-maxShake, maxShake)
            local shakeY = math.Rand(-maxShake, maxShake)

            local textX = (w / 2) + shakeX
            local textY = (h / 2) + shakeY

            local clr = Color(255, 0, 0, epicAlpha)
            local glowClr = Color(255, 0, 0, epicAlpha * 0.6) 
            local outlineClr = Color(30, 0, 0, epicAlpha)

            
            draw.SimpleText("НО ОН НЕ СДАЛСЯ", "SecondWind_Epic_Glow", textX, textY, glowClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            draw.SimpleTextOutlined("НО ОН НЕ СДАЛСЯ", "SecondWind_Epic", textX, textY, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, outlineClr)
        end
    end

    
    local AdvanceDialogueFunc
    AdvanceDialogueFunc = function()
        currentLineIdx = currentLineIdx + 1
        
        if currentLineIdx <= #sceneData then
            local line = sceneData[currentLineIdx]
            
            
            local time_one_symbol = 0.06
            local time_to_read = utf8.len(line.text) * time_one_symbol
            local totalDuration = time_to_read + 2.0 

            local newMsg = {
                text = line.text,
                speaker = line.speaker,
                startTime = CurTime(),
                endTime = CurTime() + time_to_read,
                lastClick = 0,
                isFinished = false
            }

            table.insert(messageHistory, newMsg)

            surface.PlaySound("heartbeat/heartbeat_single.wav")

            
            timer.Simple(time_to_read, function()
                if IsValid(bgPanel) then newMsg.isFinished = true end
            end)

            
            timer.Simple(totalDuration, function()
                if IsValid(bgPanel) then AdvanceDialogueFunc() end
            end)
        else
            
            isEpicFinale = true
            epicStartTime = CurTime() 
            
            surface.PlaySound("utopia/respawn/laststanddrone.ogg")
            
            
            timer.Simple(3.5, function()
                if IsValid(bgPanel) then
					timer.Simple(1.3, function()
                    bgPanel:Remove()
                    LocalPlayer():SetDSP(0)
					end)
                    
                    net.Start("hg_second_wind_end")
                    net.SendToServer()
                end
            end)
        end
    end

    
    AdvanceDialogue = AdvanceDialogueFunc
end

net.Receive("hg_second_wind_start", function()
    Death_Scene = false
    
    if type(Dead_Body) == "Entity" and IsValid(Dead_Body) and Dead_Body:GetClass() == "base_gmodentity" then
        Dead_Body:Remove()
    end
    Dead_Body = false
	timer.Simple(6,function()
		    StartSecondWindScene()
	end)
end)

local Dead_Body = false
local Death_Scene = false
local Death_Blur_Intensity = 0
local Death_Desaturation_Intensity = 1



surface.CreateFont("Void_Huge", { font = "Segoe UI", size = 80, weight = 400, extended = true })
surface.CreateFont("Void_Small", { font = "Courier New", size = 20, weight = 400, extended = true })

function CorpsedMessage(msg)
    local me = msg or LocalPlayer()
    if not IsValid(me) then return end

    local name = LocalPlayer():GTeam() == TEAM_SCP and L("l:corpsed_anomaly") or string.upper(LocalPlayer():GetNamesurvivor())
    local roleName = string.upper(GetLangRole(LocalPlayer():GetRoleName()))
    local timeText = tostring(os.date("%H:%M:%S"))

    if IsValid(BREACH_KIA_WINDOW) then BREACH_KIA_WINDOW:Remove() end
    --surface.PlaySound("hl1/fvox/flatline.wav")

    BREACH_KIA_WINDOW = vgui.Create("DPanel")
    local pnl = BREACH_KIA_WINDOW
    pnl:SetSize(ScrW(), ScrH())
    pnl:SetPos(0, 0)
    pnl:SetZPos(32767)

    pnl.CreationTime = SysTime()
    pnl.LifeTime = 8
    pnl.IsDying = false

    pnl.Paint = function(self, w, h)
        local t = SysTime() - self.CreationTime

        if t > self.LifeTime and not self.IsDying then
            self.IsDying = true
            self.DieTime = SysTime()
        end

        local anim_bg, anim_line, anim_text = 0, 0, 0
        if not self.IsDying then
            anim_bg   = math.ease.OutCubic(math.Clamp(t / 1.0, 0, 1))
            anim_line = math.ease.OutExpo(math.Clamp((t - 0.5) / 1.5, 0, 1))
            anim_text = math.ease.OutSine(math.Clamp((t - 0.8) / 1.0, 0, 1))
        else
            local dt = SysTime() - self.DieTime
            anim_text = 1 - math.ease.InSine(math.Clamp(dt / 0.5, 0, 1))
            anim_line = 1 - math.ease.InExpo(math.Clamp((dt - 0.3) / 0.8, 0, 1))
            anim_bg   = 1 - math.ease.InCubic(math.Clamp((dt - 0.8) / 1.0, 0, 1))
            if dt > 1.8 then self:Remove() return end
        end

        surface.SetDrawColor(0, 0, 0, 240 * anim_bg)
        surface.DrawRect(0, 0, w, h)

        if anim_line <= 0 then return end

        local cy = h / 2 + 30
        local startX = w * 0.15
        local lineW = w * 0.7 * anim_line

        surface.SetDrawColor(200, 30, 30, 255 * anim_line)
        surface.DrawRect(startX, cy, lineW, 2)

        if anim_text <= 0 then return end

        local alphaText = 255 * anim_text

        draw.SimpleText(L("l:corpsed_fatal_outcome"), "Void_Huge", startX, cy - 10, Color(230, 230, 230, alphaText), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

        draw.SimpleText(roleName .. "  ///  " .. name .. "  ///  T: " .. timeText, "Void_Small", startX, cy + 15, Color(150, 150, 150, alphaText), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        draw.SimpleText(L("l:corpsed_status_kia"), "Void_Small", startX + lineW, cy + 15, Color(200, 30, 30, alphaText), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
end

local function FirstPerson_CutScene(ply, pos, angles, fov)
	if Dead_Body then
		local target = Dead_Body

		if !IsValid(target) then
			return
		end

		local head = target:GetAttachment( target:LookupAttachment( "eyes" ) )
		local view = {}
		if head then
			view.origin = head.Pos + head.Ang:Forward() * -5
			view.angles = head.Ang
		end
		local target = Dead_Body

		if !timer.Exists("DeathScene_RestoreHead_"..target:EntIndex()) then
			timer.Create("DeathScene_RestoreHead_"..target:EntIndex(), 8, 1, function()
				if !IsValid(target) then
					return
				end

				Dead_Body = false

				local matrix

				  for bone = 0, ( target:GetBoneCount() || 1 ) do
					if target:GetBoneName( bone ):lower():find( "head" ) then
						  matrix = target:GetBoneMatrix( bone )
						  target:ManipulateBoneScale(bone, Vector(1,1,1))
						  break
					end
				  end

				  if ( IsValid( matrix ) ) then
					matrix:SetScale(Vector(1,1,1))
				end
			end)
		end
		Death_Blur_Intensity = math.Approach(Death_Blur_Intensity, 10, 0.05)
		Death_Desaturation_Intensity = math.Approach(Death_Desaturation_Intensity, 0, 0.01)

		local matrix

		  for bone = 0, ( target:GetBoneCount() || 1 ) do
			if target:GetBoneName( bone ):lower():find( "head" ) then
				  matrix = target:GetBoneMatrix( bone )
				  target:ManipulateBoneScale(bone, vector_origin)
				  break
			end
		  end

		  if ( IsValid( matrix ) ) then
			matrix:SetScale( vector_origin )
		end
		view.fov = fov
		view.drawviewer = true
		return view
	end

	if ply && ply:GetNWEntity("NTF1Entity", NULL) != NULL then
		local target = ply:GetNWEntity("NTF1Entity", NULL)
		local view = {}
		local head = target:GetAttachment( target:LookupAttachment( "eyes" ) )
		if head then
			if target == ply then
				view.origin = head.Pos + head.Ang:Up() * 5 + head.Ang:Forward() * 5
				view.angles = head.Ang

			elseif target:GetClass() == "ntf_cutscene_2" then
				view.origin = head.Pos
				view.angles = head.Ang - Angle(0, -70, 0)
			else
				view.origin = head.Pos + head.Ang:Forward() * -5
				view.angles = head.Ang
			end
		end

		view.fov = fov
		view.drawviewer = true
		return view

	end

	
end
hook.Add( "CalcView", "FirstPerson_CutScene", FirstPerson_CutScene )

hook.Add( "CalcView", "firstpersondeathkk", function( ply, origin, angles, fov )

  if ( ply:GetNWEntity( "NTF1Entity" ) == NULL ) then return end

	local ragdoll = ply:GetNWEntity( "NTF1Entity" )

	if ( !( ragdoll && ragdoll:IsValid() ) ) then return end
	local head = ragdoll:LookupAttachment( "eyes" )
	head = ragdoll:GetAttachment( head )

	local view = {}

  if ( !head || !head.Pos ) then return end

	if ( !ragdoll.BonesRattled ) then

	  ragdoll.BonesRattled = true
	  ragdoll:InvalidateBoneCache()
	  ragdoll:SetupBones()
	  local matrix

	  for bone = 0, ( ragdoll:GetBoneCount() || 1 ) do

	    if ragdoll:GetBoneName( bone ):lower():find( "head" ) then

	      matrix = ragdoll:GetBoneMatrix( bone )
	      ragdoll:ManipulateBoneScale(bone, vector_origin)

	      break

	    end

	  end

	  if ( IsValid( matrix ) ) then

	    matrix:SetScale( vector_origin )

    end

	end

	view.origin = head.Pos + head.Ang:Up() * 5 + head.Ang:Forward() * 5
	view.angles = head.Ang
  	view.drawviewer = true

	return view

end )

local Death_Anims = {
	"wos_bs_shared_death_neck_slice",
	"wos_bs_shared_death_belly_slice_side",
	"wos_bs_shared_death_belly_slice",
}

function Death_Scene( ply )
	if LocalPlayer():GTeam() == TEAM_ARENA then
		return
	end

	LocalPlayer():SetNWEntity("NTF1Entity", NULL)

	StopMusic()

	local camtorag = net.ReadBool()
	local sent_rag = net.ReadEntity()

	if LocalPlayer():GTeam() == TEAM_SCP then
		camtorag = true
	end

	hook.Run("CalcView", LocalPlayer(), EyePos(), EyeAngles(), LocalPlayer():GetFOV(), 0, 0)

	if !camtorag then

	Death_Scene = true
	Dead_Body = ents.CreateClientside( "base_gmodentity" )
	Death_Blur_Intensity = 0
	Death_Desaturation_Intensity = 1
		
	local dead_pos = LocalPlayer():GetPos()

	Dead_Body:SetPos( dead_pos )

	Dead_Body:SetAngles( Angle(0, LocalPlayer():GetAngles().y, 0) )
	
	Dead_Body:SetModel(  LocalPlayer():GetModel()  )
	Dead_Body:SetBodyGroups(LocalPlayer():GetBodyGroupsString())
	Dead_Body:Spawn()
	local sequence = table.Random( Death_Anims )
	Dead_Body:SetSequence(  sequence  )
	Dead_Body:SetCycle( 0 )
	Dead_Body:SetPlaybackRate( 0.5 )
	Dead_Body.AutomaticFrameAdvance = true
	
	Dead_Body.Think = function( self )
	
		self:NextThink( CurTime() )
	
		self:SetCycle( math.Approach( cycle, 1, FrameTime() * 0.4 ) )
	
		cycle = self:GetCycle()
	
		return true
	
	end

	end

	if camtorag then
		Dead_Body = sent_rag
	end

	LocalPlayer():SetNoDraw(true)
	

	timer.Simple(1.5, function()
		
	end)
		surface.PlaySound( "utopia/death/new_death_"..math.random(1,5)..".wav" )
	timer.Simple(2, function()
		if LocalPlayer():GTeam() == TEAM_SCP then
			CorpsedMessage(sent_rag)
		else
			CorpsedMessage(sent_rag)
		end
	end)
	
	local cycle = 0

	timer.Simple( 1, function()
		LocalPlayer():ScreenFade( SCREENFADE.OUT, color_black, 7, 9.1)
	end)
	timer.Simple( 14, function()
		LocalPlayer():SetDSP(0)
		Death_Blur_Intensity = 0
		Death_Desaturation_Intensity = 1
		Death_Scene = false
		Dead_Body = false
		LocalPlayer():SetNWEntity("RagdollEntityNO", NULL)
		LocalPlayer():SetNWEntity("NTF1Entity", NULL)

		if IsValid(Dead_Body) then
			LocalPlayer():SetNoDraw(false)
			if !camtorag then
		    	Dead_Body:Remove()
			end
		    Dead_Body = false
			show_spec_role = true
			if show_spec_role then
				DrawNewRoleDesc()
				show_spec_role = false
			end
		end
		if IsValid(LocalPlayer():GetNWEntity("RagdollEntityNO")) then
			for _, bnmrg in pairs(LocalPlayer():GetNWEntity("RagdollEntityNO"):LookupBonemerges()) do
				bnmrg:SetNoDraw(false)
			end
			LocalPlayer():GetNWEntity("RagdollEntityNO"):SetNoDraw(false)
		end
	end )
	if !camtorag then
		timer.Create("FINDRAGDOLLBODY", FrameTime(), 9999, function()
			if IsValid(LocalPlayer():GetNWEntity("RagdollEntityNO")) then
				for _, bnmrg in pairs(LocalPlayer():GetNWEntity("RagdollEntityNO"):LookupBonemerges()) do
					bnmrg:SetNoDraw(true)
				end
				LocalPlayer():GetNWEntity("RagdollEntityNO"):SetNoDraw(true)
				timer.Remove("FINDRAGDOLLBODY")
			end
		end)
		LocalPlayer():SetNWEntity("NTF1Entity", Dead_Body)
	else
		
		local rag = LocalPlayer():GetNWEntity("NTF1Entity")
		local times = 0
		timer.Create("FINDRAGDOLLBODY", FrameTime(), 9999, function()
			if IsValid(LocalPlayer():GetNWEntity("RagdollEntityNO")) then
				LocalPlayer():SetNWEntity("NTF1Entity", LocalPlayer():GetNWEntity("RagdollEntityNO"))
				timer.Remove("FINDRAGDOLLBODY")
				if IsValid(rag) then
					rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Head1"), Vector(0,0,0))
				end
			end
			timer.Simple(14, function()
				if IsValid(rag) then
					rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Head1"), Vector(1,1,1))
					local head = rag:GetAttachment( rag:LookupAttachment( "eyes" ) )

					local matrix

	  				for bone = 0, ( rag:GetBoneCount() || 1 ) do
	    				if rag:GetBoneName( bone ):lower():find( "head" ) then
	      					matrix = rag:GetBoneMatrix( bone )
	      					rag:ManipulateBoneScale(bone, Vector(1,1,1))
	      					break
	    				end
	  				end

	  				if ( IsValid( matrix ) ) then
	    				matrix:SetScale( Vector(1,1,1) )
    				end
				end
			end)
		end)
		if !camtorag then
			Dead_Body:Remove()
		end
	end

	
	
end
net.Receive("Death_Scene", Death_Scene)

function ANGLE:CalculateVectorDot( vec )



	local x = self:Forward():DotProduct( vec )

	local y = self:Right():DotProduct( vec )

	local z = self:Up():DotProduct( vec )



	return Vector( x, y, z )



end


function GM:DrawDeathNotice( x,  y )
end


function DrawInfo(pos, txt, clr)
	pos = pos:ToScreen()
	draw.TextShadow( {
		text = txt,
		pos = { pos.x, pos.y },
		font = "HealthAmmo",
		color = clr,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	}, 2, 255 )
end



SCPMarkers = {}

tab_scarlet = {
	["$pp_colour_addr"] = 0.07,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 2,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local client = LocalPlayer()

function Scarlet_King_Shake()

	util.ScreenShake( Vector(0, 0, 0), 2, 2, 10, 1000 )

	surface.PlaySound( "nextoren/others/helicopter/helicopter_distant_explosion.wav" )

end

hook.Add("Think", "Check_Scarlet_Skybox", function()
	if GetGlobalBool("Scarlet_King_Scarlet_Skybox", false) then
		if ( ( NextShake || 0 ) >= CurTime() ) then return end
	
		NextShake = CurTime() + 50

	    Scarlet_King_Shake()
	end
end)

local bloomtab = {
	pp_bloom_passes = "0",
	pp_bloom_darken = "0.20",
	pp_bloom_multiply = "0.15",
	pp_bloom_sizex = "6.42",
	pp_bloom_sizey = "4.65",
	pp_bloom_color = "20.00",
	pp_bloom_color_r = "255",
	pp_bloom_color_g = "0",
	pp_bloom_color_b = "0"
}

local outsidescarlettab = {
	["$pp_colour_addr"] = 0.07,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1.2,
	["$pp_colour_mulr"] = 2,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local outsidenoscarlettab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1.2,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local notoutsidetab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.01,
	["$pp_colour_contrast"] = 0.7,
	["$pp_colour_colour"] = 1.5,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local notoutsidetabfurryevent = {
	["$pp_colour_addr"] = 0.05,
	["$pp_colour_addg"] = -0.01,
	["$pp_colour_addb"] = -0.01,
	["$pp_colour_brightness"] = 0.04,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = -0.5,
	["$pp_colour_mulg"] = -0.5,
	["$pp_colour_mulb"] = -0.5
}

local podvaltab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.18,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1.1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local evactab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0.01,
	["$pp_colour_contrast"] = 0.9,
	["$pp_colour_colour"] = 2.2,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local forscptab = {
	["$pp_colour_addr"] = 0.05,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0.01,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local forartab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0.05,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 2,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local generatorsactivated = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0.01,
	["$pp_colour_contrast"] = 1.2,
	["$pp_colour_colour"] = 1.2,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local _DrawColorModify = DrawColorModify

local scpvision = CreateConVar("breach_config_scp_red_screen", 1, FCVAR_ARCHIVE, "Enables the red screen for SCP", 0, 1)

hook.Add( "RenderScreenspaceEffects", "ToytownEffect", function()

    
    

	local client = LocalPlayer()
	local tab2
	if OUTSIDE_BUFF and OUTSIDE_BUFF( client:GetPos() ) then
		if GetGlobalBool("Scarlet_King_Scarlet_Skybox", false) then
			tab2 = outsidescarlettab
		else
			tab2 = outsidenoscarlettab
		end
	else
		tab2 = notoutsidetab
	end

	if client:GetPos():WithinAABox( Vector(-984.122070, -3499.068115, -1405), Vector(2166.351318, -6167.319824, -782) ) then
		tab2 = podvaltab
	end

	if BREACH["Round"] and BREACH["Round"]["GeneratorsActivated"] and !client:Outside() then
		tab2 = generatorsactivated
	end

	if GetGlobalBool("Evacuation_HUD", false) and !client:Outside() then
		tab2 = evactab
		tab2["$pp_colour_addr"] = Pulsate(1.4) * 0.04
		tab2["$pp_colour_colour"] = 1 + Pulsate(1.4) * 0.4
	end

	local oldcolor = tab2["$pp_colour_colour"]
	if Dead_Body then
		local tab2 = table.Copy(tab2)
    DrawToyTown(Death_Blur_Intensity, ScrH())
    tab2["$pp_colour_colour"] = Death_Desaturation_Intensity
  end

  if client:GTeam() == TEAM_SCP and GetConVar("breach_config_scp_red_screen"):GetBool() then
  	tab2 = forscptab
  end

  if client:GTeam() == TEAM_AR then
  	tab2 = forartab
  end

  if GetGlobalBool("FurryRound") then
	tab2 = notoutsidetabfurryevent
  end

	_DrawColorModify( tab2 )

	tab2["$pp_colour_colour"] = oldcolor
	

end )

local clr = color_white
local clr1 = Color( 255, 69, 0 )

local hud_style = CreateConVar("breach_config_hud_style", 0, FCVAR_ARCHIVE, "Changes your HUD style", 0, 1)
local hide_title = CreateConVar("breach_config_hide_title", 0, FCVAR_ARCHIVE, "Disable bottom title", 0, 1)

local red = Color(255,0,0)

local function BreachVersionIndicator()

	local widthz = ScrW()
	local heightz = ScrH()

	if ( LocalPlayer():Health() <= 0 ) then return end
	if clang == nil then return end
	if GetGlobalBool("NewEventRound") then
		draw.SimpleText( "ИВЕНТОВЫЙ РАУНД (Опыт не начисляется)", "ScoreboardContent", widthz * 0.5, heightz * 0.972, clr1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	if LocalPlayer():GetNWBool("priorityvoice") then
		draw.SimpleText( "Режим Интеркома (Вас все слышат)", "ScoreboardContent", widthz * 0.5, heightz * 0.952, clr1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	if hud_style:GetInt() != 0 then return end
	if LocalPlayer():GetTable().IN_106_DIMENSION then return end
	
	local clang = clang

	surface.SetDrawColor(Color(255,255,255,255))
    surface.SetMaterial(Material("nextoren/forge_logo_cumtent.png", "noclamp smooth"))
    surface.DrawTexturedRect(ScrW() / 1.02,ScrH()/1.035,ScrH() / 30,ScrH() / 30)

	
	draw.SimpleText( "OPEN BETA - UB_OBT_2_fix1", "MM_Exp", widthz * 0.98, heightz * 0.975, clr1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	

	

	

	draw.SimpleText( "Legacy UTOPIA Breach", "MM_Exp", widthz * 0.98, heightz * 0.99, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	

end
hook.Add( "HUDPaintBackground", "BreachVersionIndicator", BreachVersionIndicator )




local rust_panel    = Color(18, 16, 15, 245)
local rust_outline  = Color(255, 255, 255, 15)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_text_dim = Color(140, 140, 140)

BREACH = BREACH or {}

function ShowAbillityDesc(name, text, cooldown, x, y)
    
    if BREACH.Abilities and IsValid(BREACH.Abilities.TipWindow) then
        BREACH.Abilities.TipWindow:Remove()
    end

    BREACH.Abilities = BREACH.Abilities or {}

    local panelW = 280

    BREACH.Abilities.TipWindow = vgui.Create("DPanel")
    local tip = BREACH.Abilities.TipWindow
    tip:SetAlpha(0)
    tip:SetPos(x + 15, y + 15)
    tip:SetZPos(32767) 

    tip.isClosing = false
    tip.lerpAlpha = 0
    tip.slideY = 15 

    
    function tip:CloseWithAnim()
        if self.isClosing then return end
        self.isClosing = true
    end

    local lblTitle = vgui.Create("DLabel", tip)
    lblTitle:SetFont("MM_Exp")
    lblTitle:SetText(string.upper(name))
    lblTitle:SetTextColor(rust_yellow)
    lblTitle:SizeToContents()
    lblTitle:SetPos(15, 10)

    local lblDesc = vgui.Create("DLabel", tip)
    lblDesc:SetFont("MM_SmallName")
    lblDesc:SetText(text)
    lblDesc:SetTextColor(rust_text_dim)
    lblDesc:SetWrap(true) 
    lblDesc:SetAutoStretchVertical(true) 
    lblDesc:SetWide(panelW - 30)
    lblDesc:SetPos(15, 35)

    local lblCd = vgui.Create("DLabel", tip)
    lblCd:SetFont("MM_SmallName")
    lblCd:SetText(string.upper("COOLDOWN: " .. cooldown .. " SEC"))
    lblCd:SetTextColor(rust_text)
    lblCd:SizeToContents()

    timer.Simple(0, function()
        if not IsValid(tip) then return end
        local descH = lblDesc:GetTall()
        local totalH = 35 + descH + 35
        tip:SetSize(panelW, totalH)
        lblCd:SetPos(panelW - lblCd:GetWide() - 15, totalH - 25)
    end)

    tip:SetSize(panelW, 100) 

    tip.Think = function(self)
        
        if not vgui.CursorVisible() and not self.isClosing then
            self:CloseWithAnim()
        end

        
        local targetAlpha = self.isClosing and 0 or 1
        local targetSlide = self.isClosing and 15 or 0

        self.lerpAlpha = Lerp(FrameTime() * 15, self.lerpAlpha, targetAlpha)
        self.slideY = Lerp(FrameTime() * 15, self.slideY, targetSlide)

        self:SetAlpha(self.lerpAlpha * 255)

        
        if self.isClosing and self.lerpAlpha < 0.05 then
            self:Remove()
        end
    end

    tip.Paint = function(self, w, h)
        
        if not self.isClosing then
            local mx, my = gui.MouseX(), gui.MouseY()
            local targetX, targetY = mx + 15, my + 15

            if targetX + w > ScrW() then targetX = mx - w - 10 end
            if targetY + h > ScrH() then targetY = my - h - 10 end

            self.targetX = targetX
            self.targetY = targetY
        end

        if self.targetX and self.targetY then
            self:SetPos(self.targetX, self.targetY + self.slideY)
        end

        if DrawBlurPanel then DrawBlurPanel(self) end
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(0, 0, 3, h)

        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255)
        surface.DrawRect(15, 30, w - 30, 1)
        surface.DrawRect(15, h - 30, w - 30, 1)

        surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end




local rust_bg       = Color(25, 24, 22, 245)
local rust_panel    = Color(18, 16, 15, 255)
local rust_row      = Color(40, 38, 35, 255)
local rust_outline  = Color(255, 255, 255, 15)
local rust_green    = Color(112, 126, 73)
local rust_red      = Color(188, 64, 43)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_text_dim = Color(140, 140, 140)

local abilityAnim = {
    press = 0,
    hover = 0,
    scale = 1,
    appear = 0,
    readyPulse = 0,
    laserProgress = 1,
    laserAlpha = 0
}

function DrawSpecialAbility(tbl)
    if not istable(tbl) then return end
    
    local client = LocalPlayer()
    if not IsValid(client) then return end

    local bindCode = GetConVar("breach_config_useability"):GetInt()
    local bindName = input.GetKeyName(bindCode)
    client.AbilityKey = bindName and string.upper(bindName) or "NONE"
    client.AbilityKeyCode = bindCode

    BREACH = BREACH or {}
    
    if type(BREACH.Abilities) ~= "table" then
        BREACH.Abilities = {}
    end
    
    if type(BREACH.Abilities.HumanSpecial) == "Panel" and IsValid(BREACH.Abilities.HumanSpecial) then 
        BREACH.Abilities.HumanSpecial:Remove() 
    end
    if type(BREACH.Abilities.HumanSpecialButt) == "Panel" and IsValid(BREACH.Abilities.HumanSpecialButt) then 
        BREACH.Abilities.HumanSpecialButt:Remove() 
    end

    local abilityAnim = {
        press = 0,
        hover = 0,
        scale = 1,
        appear = 0,
        readyPulse = 0,
        laserProgress = 1,
        laserAlpha = 0
    }

    local pnl = vgui.Create("DPanel")
    if type(pnl) ~= "Panel" or not IsValid(pnl) then return end 
    
    BREACH.Abilities.HumanSpecial = pnl
    
    local size = 68 
    pnl:SetSize(size, size)
    pnl:SetPos(ScrW() / 2 - (size/2), ScrH() / 1.122)
    pnl:SetAlpha(0)
    pnl:SetZPos(32000) 
    
    local iconmat = Material(tbl.Icon or "error", "smooth")
    local is_countable = tbl.Countable
    local maxCd = tbl.Cooldown or 1
    if maxCd <= 0 then maxCd = 1 end

    pnl.is_initialized = false
    pnl.cached_team = nil
    pnl.cached_name = nil
    local creationTime = SysTime()

    pnl.Think = function(self)
        if not IsValid(self) then return end
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local currentTime = CurTime()
        local currentRole = ply.GetRoleName and ply:GetRoleName() or ""
        local currentName = ply.GetNamesurvivor and ply:GetNamesurvivor() or ""

        if not self.is_initialized then
            if ply:Health() > 0 and ply:GTeam() ~= TEAM_SPEC and currentName ~= "" and currentName ~= "none" then
                self.cached_team = ply:GTeam()
                self.cached_name = currentName
                self.is_initialized = true 
            end
        else
            local roleHitman = (role and role.ClassD_Hitman) or "ClassD_Hitman"
            
            if SysTime() - creationTime < 3 then
                self.cached_team = ply:GTeam()
                self.cached_name = currentName
            else
                if ply:Health() <= 0 or ply:GTeam() == TEAM_SPEC or self.cached_team ~= ply:GTeam() or (self.cached_name ~= currentName and currentRole ~= roleHitman) then
                    if type(ply) == "Player" then ply.SpecialTable = nil end
                    self:Remove()
                    return
                end
            end
        end

        if self.is_initialized then
            abilityAnim.appear = math.Approach(abilityAnim.appear, 1, FrameTime() * 5)
            self:SetAlpha(abilityAnim.appear * 255)
        end

        local isPressed = false
        if ply.AbilityKeyCode and ply.AbilityKeyCode > 0 then
            isPressed = input.IsMouseDown(ply.AbilityKeyCode) or input.IsKeyDown(ply.AbilityKeyCode)
        end

        if isPressed then
            abilityAnim.press = Lerp(FrameTime() * 20, abilityAnim.press, 1)
            abilityAnim.scale = Lerp(FrameTime() * 20, abilityAnim.scale, 0.9)
        else
            abilityAnim.press = Lerp(FrameTime() * 10, abilityAnim.press, 0)
            abilityAnim.scale = Lerp(FrameTime() * 15, abilityAnim.scale, 1)
        end

        if self:IsHovered() then
            abilityAnim.hover = Lerp(FrameTime() * 10, abilityAnim.hover, 1)
        else
            abilityAnim.hover = Lerp(FrameTime() * 10, abilityAnim.hover, 0)
        end
        
        local cdTime = (ply.GetSpecialCD and ply:GetSpecialCD() or 0) - currentTime

        if cdTime > 0 then
            local rawProgress = math.Clamp(1 - (cdTime / maxCd), 0, 1)
            
            if abilityAnim.laserProgress > 0.95 and rawProgress < 0.1 then
                abilityAnim.laserProgress = 0
            end

            abilityAnim.laserProgress = Lerp(FrameTime() * 10, abilityAnim.laserProgress, rawProgress)
            abilityAnim.laserAlpha = Lerp(FrameTime() * 15, abilityAnim.laserAlpha, 1)
            abilityAnim.readyPulse = 0
        else
            abilityAnim.laserProgress = Lerp(FrameTime() * 15, abilityAnim.laserProgress, 1)
            abilityAnim.laserAlpha = Lerp(FrameTime() * 10, abilityAnim.laserAlpha, 0)
            
            if not self.Blocked then
                abilityAnim.readyPulse = math.sin(currentTime * 4) * 0.5 + 0.5
            end
        end
    end

    pnl.Paint = function(self, w, h)
        if not IsValid(self) then return end
        if type(INTRO_PANEL) == "Panel" and IsValid(INTRO_PANEL) and INTRO_PANEL:IsVisible() then return end

        local currentTime = CurTime()
        local currentAlpha = abilityAnim.appear

        if currentAlpha <= 0.01 then return end

        local currentScale = abilityAnim.scale
        local appearScale = 0.5 + abilityAnim.appear * 0.5
        local finalScale = currentScale * appearScale
        
        local finalW = w * finalScale
        local finalH = h * finalScale
        local finalX = (w - finalW) / 2
        local finalY = (h - finalH) / 2

        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local cdTime = (ply.GetSpecialCD and ply:GetSpecialCD() or 0) - currentTime
        local isReady = (cdTime <= 0 and not self.Blocked)

        surface.SetDrawColor(15, 15, 15, 240 * currentAlpha)
        surface.DrawRect(finalX, finalY, finalW, finalH)

        if iconmat and not iconmat:IsError() then
            surface.SetDrawColor(255, 255, 255, 255 * currentAlpha)
            surface.SetMaterial(iconmat)
            surface.DrawTexturedRectUV(finalX, finalY, finalW, finalH, 0.06, 0.06, 0.94, 0.94)
        end

        if abilityAnim.press > 0 then
            surface.SetDrawColor(0, 0, 0, 180 * abilityAnim.press * currentAlpha)
            surface.DrawRect(finalX, finalY, finalW, finalH)
        end

        if abilityAnim.laserAlpha > 0.01 then
            local coverH = finalH * (1 - abilityAnim.laserProgress)

            surface.SetDrawColor(5, 5, 5, 210 * currentAlpha * abilityAnim.laserAlpha)
            surface.DrawRect(finalX, finalY, finalW, coverH)

            surface.SetDrawColor(218, 165, 32, 50 * currentAlpha * abilityAnim.laserAlpha)
            surface.DrawRect(finalX, finalY + coverH - 4, finalW, 4)

            surface.SetDrawColor(218, 165, 32, 255 * currentAlpha * abilityAnim.laserAlpha)
            surface.DrawRect(finalX, finalY + coverH - 1, finalW, 1)

            if cdTime > 0 then
                local cdText = math.Round(cdTime, 1)
                draw.SimpleTextOutlined(cdText, "MM_Exp", w / 2, h / 2, Color(255, 255, 255, 255 * currentAlpha * abilityAnim.laserAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200 * currentAlpha * abilityAnim.laserAlpha))
            end
        end
        
        if self.Blocked and abilityAnim.laserAlpha < 0.99 then
            local emptyAlpha = (1 - abilityAnim.laserAlpha) * currentAlpha
            surface.SetDrawColor(188, 64, 43, 120 * emptyAlpha)
            surface.DrawRect(finalX, finalY, finalW, finalH)
            draw.SimpleTextOutlined("EMPTY", "MM_SmallName", w / 2, h / 2, Color(255, 100, 100, 255 * emptyAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200 * emptyAlpha))
        end

        surface.SetDrawColor(255, 255, 255, 15 * currentAlpha)
        surface.DrawOutlinedRect(finalX, finalY, finalW, finalH, 1)

        if isReady then
            surface.SetDrawColor(218, 165, 32, 255 * currentAlpha)
            surface.DrawRect(finalX, finalY + finalH - 3, finalW, 3)
            
            if abilityAnim.readyPulse > 0 then
                surface.SetDrawColor(218, 165, 32, 30 * abilityAnim.readyPulse * currentAlpha)
                surface.DrawOutlinedRect(finalX - 1, finalY - 1, finalW + 2, finalH + 2, 2)
            end
        end

        if abilityAnim.hover > 0 then
            surface.SetDrawColor(255, 255, 255, 10 * abilityAnim.hover * currentAlpha)
            surface.DrawRect(finalX, finalY, finalW, finalH)
            surface.SetDrawColor(218, 165, 32, 150 * abilityAnim.hover * currentAlpha)
            surface.DrawOutlinedRect(finalX, finalY, finalW, finalH, 1)
        end

        draw.NoTexture()

        local keyTxt = ply.AbilityKey or "NONE"
        surface.SetFont("MM_SmallName")
        local tw, th = surface.GetTextSize(keyTxt)
        
        surface.SetDrawColor(15, 15, 15, 240 * currentAlpha)
        surface.DrawPoly({
            {x = finalX, y = finalY},
            {x = finalX + tw + 10, y = finalY},
            {x = finalX + tw + 4, y = finalY + th + 4},
            {x = finalX, y = finalY + th + 4}
        })
        draw.SimpleText(keyTxt, "MM_SmallName", finalX + 4, finalY + 2, Color(200, 200, 200, 255 * currentAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if is_countable then
            local n_max = ply.GetSpecialMax and ply:GetSpecialMax() or 0
            local countTxt = tostring(n_max)
            surface.SetFont("MM_Exp")
            local cw, ch = surface.GetTextSize(countTxt)
            
            surface.SetDrawColor(15, 15, 15, 240 * currentAlpha)
            surface.DrawPoly({
                {x = finalX + finalW - cw - 10, y = finalY + finalH},
                {x = finalX + finalW - cw - 4, y = finalY + finalH - ch - 4},
                {x = finalX + finalW, y = finalY + finalH - ch - 4},
                {x = finalX + finalW, y = finalY + finalH}
            })
            
            local chargeColor = (n_max > 0) and Color(218, 165, 32) or Color(188, 64, 43)
            draw.SimpleText(countTxt, "MM_Exp", finalX + finalW - 4, finalY + finalH - 2, ColorAlpha(chargeColor, 255 * currentAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

            if not self.Blocked and n_max <= 0 then
                self.Blocked = true
            elseif self.Blocked and n_max > 0 then
                self.Blocked = nil
            end
        end

        if input.IsKeyDown(KEY_F3) then
            if (self.NextCall or 0) >= CurTime() then return end
            self.NextCall = CurTime() + 1
            gui.EnableScreenClicker(not vgui.CursorVisible())
        end
    end

    local btn = vgui.Create("DButton", pnl)
    if type(btn) ~= "Panel" or not IsValid(btn) then return end 
    
    BREACH.Abilities.HumanSpecialButt = btn
    
    btn:SetSize(size, size)
    btn:SetText("")
    btn.Paint = function() end
    
    btn.OnCursorEntered = function()
        if ShowAbillityDesc then
            local nameTxt = (L and tbl.Name and L(tbl.Name)) or tbl.Name or "UNKNOWN"
            local descTxt = (L and tbl.Description and L(tbl.Description)) or tbl.Description or "NO DATA"
            ShowAbillityDesc(nameTxt, descTxt, tostring(maxCd), gui.MouseX(), gui.MouseY())
        end
    end
    
    btn.OnCursorExited = function()
        if type(BREACH.Abilities) == "table" and type(BREACH.Abilities.TipWindow) == "Panel" and IsValid(BREACH.Abilities.TipWindow) then
            BREACH.Abilities.TipWindow:CloseWithAnim()
        end
    end
    
    btn.DoClick = function()
    end
end

local info1 = Material( "breach/info_mtf.png")
hook.Add( "HUDPaint", "Breach_DrawHUD", function()
	for i, v in ipairs( SCPMarkers ) do
		local scr = v.data.pos:ToScreen()

		if scr.visible then
			surface.SetDrawColor( Color( 255, 100, 100, 200 ) )
			//surface.DrawRect( scr.x - 5, scr.y - 5, 10, 10 )
			surface.DrawPoly( {
				{ x = scr.x, y = scr.y - 10 },
				{ x = scr.x + 5, y = scr.y },
				{ x = scr.x, y = scr.y + 10 },
				{ x = scr.x - 5, y = scr.y },
			} )

			draw.Text( {
				text = v.data.name,
				font = "HUDFont",
				color = Color( 255, 100, 100, 200 ),
				pos = { scr.x, scr.y + 10 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_TOP,
			} )

			draw.Text( {
				text = math.Round( v.data.pos:Distance( LocalPlayer():GetPos() ) * 0.019 ) .. "m",
				font = "HUDFont",
				color = Color( 255, 100, 100, 200 ),
				pos = { scr.x, scr.y + 25 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_TOP,
			} )
		end

		if v.time < CurTime() then
			table.remove( SCPMarkers, i )
		end
	end

	if disablehud then return end


	if shoulddrawinfo == true then
		if LocalPlayer():GTeam() == TEAM_SPEC then
			timer.Simple(0.1, function()
				DrawNewRoleDesc()
			end)
		else
			local client = LocalPlayer()
			if (client:GTeam() != TEAM_QRT and client:GTeam() != TEAM_OSN and client:GTeam() != TEAM_AR and client:GTeam() != TEAM_ALPHA1 and client:GTeam() != TEAM_CBG and client:GTeam() != TEAM_GUARD and ( client:GTeam() != TEAM_DZ or client:GetRoleName() == role.SCI_SpyDZ ) and client:GTeam() != TEAM_NTF and ( client:GTeam() != TEAM_USA or client:GetRoleName() == role.SCI_SpyUSA ) and client:GTeam() != TEAM_GRU and ( client:GTeam() != TEAM_GOC or client:GetRoleName() == role.ClassD_GOCSpy ) and client:GTeam() != TEAM_COTSK and ( client:GTeam() != TEAM_CHAOS or client:GetRoleName() == role.SECURITY_Spy )) or client:GetRoleName() == role.NTF_Pilot then
				DrawNewRoleDesc()
			end

		end

		shoulddrawinfo = false
	end
	if isnumber(drawendmsg) then
		local ndtext = clang.lang_end2
		if drawendmsg == 2 then
			ndtext = clang.lang_end3
		end
		//if clang.endmessages[drawendmsg] then
			shoulddrawinfo = false
			
		//else
		//	drawendmsg = nil
		//end
	else
		if isnumber(shoulddrawescape) then
			if CurTime() > lastescapegot then
				shoulddrawescape = nil
			end
			if clang.escapemessages[shoulddrawescape] then
				local tab = clang.escapemessages[shoulddrawescape]
				draw.TextShadow( {
					text = tab.main,
					pos = { ScrW() / 2, ScrH() / 15 },
					font = "ImpactBig",
					color = tab.clr,
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
				}, 2, 255 )
				draw.TextShadow( {
					text = string.Replace( tab.txt, "{t}", string.ToMinutesSecondsMilliseconds(esctime) ),
					pos = { ScrW() / 2, ScrH() / 15 + 45 },
					font = "ImpactSmall",
					color = Color(255,255,255),
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
				}, 2, 255 )
				draw.TextShadow( {
					text = tab.txt2,
					pos = { ScrW() / 2, ScrH() / 15 + 75 },
					font = "ImpactSmall",
					color = Color(255,255,255),
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
				}, 2, 255 )
			end
		end
	end
end )




local Visor = {
    Active = false,
    StartTime = 0,
    Duration = 15,
    TeamToScan = 0,
    Targets = {},
    GlitchIntensity = 0
}

local color_red = Color(255, 50, 30)
local color_glitch_r = Color(255, 0, 0, 150)
local color_glitch_b = Color(0, 255, 255, 150)


local function UpdateVisorTargets()
    Visor.Targets = {}
    for _, v in player.Iterator() do
        if v:GTeam() == Visor.TeamToScan and v:Alive() and not v:GetNoDraw() then
            table.insert(Visor.Targets, v)
            
            
            local bonemerged = ents.FindByClassAndParent("ent_bonemerged", v)
            if bonemerged then
                for i = 1, #bonemerged do
                    table.insert(Visor.Targets, bonemerged[i])
                end
            end
        end
    end
end

net.Receive("NTF_Special_1", function()
    local target_team = net.ReadUInt(8)
    local client = LocalPlayer()
    
    if client:GTeam() ~= TEAM_NTF then return end

    
    Visor.Active = true
    Visor.StartTime = CurTime()
    Visor.TeamToScan = target_team
    UpdateVisorTargets()

    
    surface.PlaySound("weapons/c4/c4_click.wav")
    timer.Simple(0.2, function() surface.PlaySound("weapons/c4/c4_click.wav") end)
    timer.Simple(0.4, function() surface.PlaySound("items/nvg_on.wav") end)

    
    
    
    hook.Add("PreDrawOutlines", "TacticalVisor_Outline", function()
        if not Visor.Active or client:GTeam() ~= TEAM_NTF or not client:Alive() then
            hook.Remove("PreDrawOutlines", "TacticalVisor_Outline")
            hook.Remove("HUDPaint", "TacticalVisor_HUD")
            Visor.Active = false
            return
        end

        local elapsed = CurTime() - Visor.StartTime
        local timeLeft = Visor.Duration - elapsed

        
        if timeLeft <= 0 then
            surface.PlaySound("items/nvg_off.wav")
            Visor.Active = false
            return
        end

        
        local alphaMulti = 1
        if elapsed < 1 then
            alphaMulti = elapsed 
        elseif timeLeft < 2 then
            alphaMulti = timeLeft / 2 
        end

        
        if math.random() > 0.92 then
            Visor.GlitchIntensity = math.random(30, 100) / 100
        else
            Visor.GlitchIntensity = Lerp(FrameTime() * 10, Visor.GlitchIntensity, 0)
        end

        
        local pulse = (math.sin(CurTime() * 8) + 1) / 2
        
        
        local finalAlpha = (150 + 105 * pulse) * alphaMulti
        
        
        if Visor.GlitchIntensity > 0.5 then
            finalAlpha = finalAlpha * math.random(0.1, 0.5)
        end

        
        if math.Round(CurTime() * 10) % 10 == 0 then
            UpdateVisorTargets()
        end

        
        if #Visor.Targets > 0 then
            local drawColor = Color(color_red.r, color_red.g, color_red.b, finalAlpha)
            outline.Add(Visor.Targets, drawColor, 0) 
        end
    end)

    
    
    
    hook.Add("HUDPaint", "TacticalVisor_HUD", function()
        if not Visor.Active then return end

        local elapsed = CurTime() - Visor.StartTime
        local timeLeft = Visor.Duration - elapsed

        local alphaMulti = 1
        if elapsed < 1 then alphaMulti = elapsed
        elseif timeLeft < 2 then alphaMulti = timeLeft / 2 end

        
        if Visor.GlitchIntensity > 0.7 then
            surface.SetDrawColor(255, 255, 255, 5 * Visor.GlitchIntensity * alphaMulti)
            for i = 1, 10 do
                local h = math.random(1, 4)
                surface.DrawRect(0, math.random(0, ScrH()), ScrW(), h)
            end
        end

        
        for _, ent in ipairs(Visor.Targets) do
            if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent:GTeam() == Visor.TeamToScan then
                local pos = ent:GetPos() + Vector(0, 0, 45) 
                local scr = pos:ToScreen()

                if scr.visible then
                    local dist = math.Round(client:GetPos():Distance(ent:GetPos()) * 0.019)
                    
                    
                    local gx = (Visor.GlitchIntensity > 0.5) and math.random(-5, 5) or 0
                    local gy = (Visor.GlitchIntensity > 0.5) and math.random(-3, 3) or 0
                    
                    local boxSize = 25
                    local a = 200 * alphaMulti

                    
                    local function DrawBrackets(x, y, size, clr)
                        surface.SetDrawColor(clr)
                        local len = 8
                        
                        surface.DrawLine(x - size, y - size, x - size + len, y - size)
                        surface.DrawLine(x - size, y - size, x - size, y + size)
                        surface.DrawLine(x - size, y + size, x - size + len, y + size)
                        
                        surface.DrawLine(x + size, y - size, x + size - len, y - size)
                        surface.DrawLine(x + size, y - size, x + size, y + size)
                        surface.DrawLine(x + size, y + size, x + size - len, y + size)
                    end

                    
                    if Visor.GlitchIntensity > 0.4 then
                        DrawBrackets(scr.x + gx, scr.y + gy, boxSize, ColorAlpha(color_glitch_r, a))
                        DrawBrackets(scr.x - gx, scr.y - gy, boxSize, ColorAlpha(color_glitch_b, a))
                    end

                    
                    DrawBrackets(scr.x, scr.y, boxSize, ColorAlpha(color_red, a))

                    
                    local txtAlpha = a * (math.random() > 0.8 and 0.5 or 1) 
                    
                    draw.SimpleTextOutlined("TARGET", "MM_SmallName", scr.x + boxSize + 5 + gx, scr.y - 10, Color(255, 50, 30, txtAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0, txtAlpha))
                    draw.SimpleTextOutlined(dist .. "m", "MM_SmallName", scr.x + boxSize + 5 - gx, scr.y + 10, Color(200, 200, 200, txtAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0, txtAlpha))
                end
            end
        end

        
        local sysTxt = "VISOR SCAN ACTIVE // " .. string.format("%.1f", timeLeft) .. "s"
        if Visor.GlitchIntensity > 0.8 then sysTxt = "V!S0R S#AN ERROR // $.$s" end
        draw.SimpleTextOutlined(sysTxt, "MM_Exp", ScrW()/2, 50, Color(255, 50, 30, 200 * alphaMulti), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0, 150 * alphaMulti))
    end)
end)

BREACH.Demote = BREACH.Demote || {}

function SCP062de_Menu()

	if Select_Menu_enabled then return end

	local clrgray = Color( 198, 198, 198, 200 )
	local gradient = Material( "vgui/gradient-r" )

	local weapons_table = {

		[ 1 ] = { name = "MP40", class = "cw_kk_ins2_doi_mp40" },
		[ 2 ] = { name = "K98", class = "cw_kk_ins2_doi_k98k" },
		[ 3 ] = { name = "G43", class = "cw_kk_ins2_doi_g43" }

	}

	BREACH.Demote.MainPanel = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel:SetSize( 256, 256 )
	BREACH.Demote.MainPanel:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
	BREACH.Demote.MainPanel:SetText( "" )
	BREACH.Demote.MainPanel.DieTime = CurTime() + 10
	BREACH.Demote.MainPanel.Paint = function( self, w, h )

		if ( !vgui.CursorVisible() ) then

			gui.EnableScreenClicker( true )

		end

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
		draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )

		if ( self.DieTime <= CurTime() ) then

			net.Start( "GiveWeaponFromClient" )

				net.WriteString( weapons_table[ math.random( 1, #weapons_table ) ].class )

			net.SendToServer()

			self.Disclaimer:Remove()
			self:Remove()
			gui.EnableScreenClicker( false )

		end

	end

	BREACH.Demote.MainPanel.Disclaimer = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel.Disclaimer:SetSize( 256, 64 )
	BREACH.Demote.MainPanel.Disclaimer:SetPos( ScrW() / 2 - 128, ScrH() / 2 - ( 128 * 1.5 ) )
	BREACH.Demote.MainPanel.Disclaimer:SetText( "" )

	local client = LocalPlayer()

	local text = L("l:select_weapon")

	BREACH.Demote.MainPanel.Disclaimer.Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
		draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )

		draw.DrawText( text, "ChatFont_new", w / 2, h / 2 - 16, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if ( client:GetRoleName() != "SCP062DE" || client:Health() <= 0 ) then

			if ( IsValid( BREACH.Demote.MainPanel ) ) then

				BREACH.Demote.MainPanel:Remove()

			end

			self:Remove()

			gui.EnableScreenClicker( false )

		end

	end

	BREACH.Demote.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.Demote.MainPanel )
	BREACH.Demote.ScrollPanel:Dock( FILL )

	for i = 1, #weapons_table do

		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add( "DButton" )
		BREACH.Demote.Users:SetText( "" )
		BREACH.Demote.Users:Dock( TOP )
		BREACH.Demote.Users:SetSize( 256, 64 )
		BREACH.Demote.Users:DockMargin( 0, 0, 0, 2 )
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0

		BREACH.Demote.Users.Paint = function( self, w, h )

			if ( self.CursorOnPanel ) then

				self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 64 )

			else

				self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 128 )

			end

			draw.RoundedBox( 0, 0, 0, w, h, color_black )
			draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )

			surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
			surface.SetMaterial( gradient )
			surface.DrawTexturedRect( 0, 0, w, h )

			draw.SimpleText( weapons_table[ i ].name, "HUDFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

		BREACH.Demote.Users.OnCursorEntered = function( self )

			self.CursorOnPanel = true

		end

		BREACH.Demote.Users.OnCursorExited = function( self )

			self.CursorOnPanel = false

		end

		BREACH.Demote.Users.DoClick = function( self )

			net.Start( "GiveWeaponFromClient" )

				net.WriteString( weapons_table[ i ].class )

			net.SendToServer()

			BREACH.Demote.MainPanel.Disclaimer:Remove()
			BREACH.Demote.MainPanel:Remove()
			gui.EnableScreenClicker( false )

		end

	end

end

BREACH.Demote = BREACH.Demote || {}

local lockedcolor = Color(155,0,0)

net.Receive("SelectRole_Sync", function(len)

	local data = net.ReadTable()

	if BREACH.Demote and BREACH.Demote.MainPanel then
		BREACH.SelectedRoles = data
	end	

end)


function SelectDefaultClass(team)
	local quicktables_def = {
		[TEAM_CLASSD] = BREACH_ROLES.CLASSD.classd.roles,
		[TEAM_SCI] = BREACH_ROLES.SCI.sci.roles,
		[TEAM_SECURITY] = BREACH_ROLES.SECURITY.security.roles,
		[TEAM_GUARD] = BREACH_ROLES.MTF.mtf.roles,
	}
	
	if team == TEAM_GUARD then return end
	
	local clrgray = Color(198, 198, 198, 200)
	local gradient = Material("vgui/gradient-r")
	
	
	local menu_animation_time = 0.6
	local menu_start_time = RealTime()
	
	BREACH.Player:ChatPrint(true, true, "l:supp_pickcancel")
	
	local tab = quicktables_def[team]
	Select_Menu_enabled = true
	
	local weapons_table = {}
	if tab == nil then return end
	
	for id, role in pairs(tab) do
		if LocalPlayer():SteamID64() == "76561198376629308" then
			weapons_table[#weapons_table + 1] = {name = GetLangRole(role.name), class = role.name, id = id, max = role.max, level = role.level}
		else
			if !role.name:find('Spy') then 
				weapons_table[#weapons_table + 1] = {name = GetLangRole(role.name), class = role.name, id = id, max = role.max, level = role.level}
			end
		end
	end
	
	
	if LocalPlayer():SteamID64() == "76561198966614836" then
		if team == TEAM_GUARD then
			weapons_table = {}
			for id, role in pairs(quicktables_def[TEAM_GUARD]) do
				if role.name == "MTF Guard" or role.name == "Head of Security" or role.name == "MTF Shock trooper" or role.name == "MTF Specialist" or role.name == "MTF Juggernaut" or role.name == "MTF Security" then 
					weapons_table[#weapons_table + 1] = {name = GetLangRole(role.name), class = role.name, id = id, max = role.max, level = role.level}
				end
			end
		end
		if team == TEAM_SCI then
			weapons_table = {}
			for id, role in pairs(quicktables_def[TEAM_SCI]) do
				if role.name == "Cleaner" or role.name == "Medic" or role.name == "Scientist" or role.name == "Ethics Comitee" then 
					weapons_table[#weapons_table + 1] = {name = GetLangRole(role.name), class = role.name, id = id, max = role.max, level = role.level}
				end
			end
		end
		if team == TEAM_CLASSD then
			weapons_table = {}
			for id, role in pairs(quicktables_def[TEAM_CLASSD]) do
				if role.name == "Class-D Bor" or role.name == "Class-D Killer" or role.name == "Class-D Hacker" or role.name == "Class-D Stealthy" then 
					weapons_table[#weapons_table + 1] = {name = GetLangRole(role.name), class = role.name, id = id, max = role.max, level = role.level}
				end
			end
		end
	end
	
	
	BREACH.Demote.MainPanel = vgui.Create("DPanel")
	BREACH.Demote.MainPanel:SetSize(256 * 2, 262 * 1.4)
	BREACH.Demote.MainPanel:SetPos(ScrW() / 2 - 128 * 2, ScrH() / 1.8 - 128)
	BREACH.Demote.MainPanel:SetText("")
	BREACH.Demote.MainPanel.DieTime = CurTime() + 65
	BREACH.Demote.MainPanel.menuAlpha = 0
	BREACH.Demote.MainPanel.menuScale = 0.7
	BREACH.Demote.MainPanel.slideY = 20
	BREACH.Demote.MainPanel.startTime = RealTime()
	BREACH.Demote.MainPanel.closing = false
	BREACH.Demote.MainPanel.buttons = {} 

	BREACH.Demote.MainPanel.Paint = function(self, w, h)
		if (!vgui.CursorVisible()) then
			gui.EnableScreenClicker(true)
		end

		local progress = 0
		if self.closing then
			progress = math.min((RealTime() - self.closeStart) / (menu_animation_time * 0.4), 1)
			self.menuAlpha = Lerp(progress, 255, 0)
			self.menuScale = Lerp(progress, 1, 0.7)
			self.slideY = Lerp(progress, 0, -20)
		else
			progress = math.min((RealTime() - self.startTime) / (menu_animation_time * 0.8), 1)
			local easeOut = 1 - math.pow(1 - progress, 3)
			self.menuAlpha = Lerp(easeOut, 0, 255)
			self.menuScale = Lerp(easeOut, 0.7, 1)
			self.slideY = Lerp(easeOut, 20, 0)
		end

		
		local center_x, center_y = w/2, h/2
		local scaled_w, scaled_h = w * self.menuScale, h * self.menuScale
		local scaled_x, scaled_y = center_x - scaled_w/2, center_y - scaled_h/2 + self.slideY
		
		
		draw.RoundedBox(0, scaled_x - 5, scaled_y - 5, scaled_w + 10, scaled_h + 10, 
		               Color(0, 0, 0, 60 * (self.menuAlpha/255)))
		
		
		draw.RoundedBox(0, scaled_x, scaled_y, scaled_w, scaled_h, Color(0, 0, 0, 120 * (self.menuAlpha/255)))
		
		
		local pulse = math.sin(RealTime() * 2) * 0.2 + 0.8
		surface.SetDrawColor(255, 255, 255, self.menuAlpha * pulse)
		surface.DrawOutlinedRect(scaled_x, scaled_y, scaled_w, scaled_h, 2)
		
		
		local corner_size = 6
		draw.RoundedBox(0, scaled_x, scaled_y, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x, scaled_y, 2, corner_size, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - corner_size, scaled_y, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - 2, scaled_y, 2, corner_size, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x, scaled_y + scaled_h - 2, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x, scaled_y + scaled_h - corner_size, 2, corner_size, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - corner_size, scaled_y + scaled_h - 2, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - 2, scaled_y + scaled_h - corner_size, 2, corner_size, Color(255, 255, 255, self.menuAlpha))

		if (self.DieTime <= CurTime() and !self.closing) then
			self:CloseMenu()
		end
	end

	
	BREACH.Demote.MainPanel.CloseMenu = function(self)
		if self.closing then return end
		self.closing = true
		self.closeStart = RealTime()
		
		
		for _, button in pairs(self.buttons) do
			if IsValid(button) then
				button.closing = true
				button.closeStart = RealTime()
			end
		end
		
		
		if IsValid(self.Disclaimer) then
			self.Disclaimer.closing = true
			self.Disclaimer.closeStart = RealTime()
		end
		
		timer.Simple(menu_animation_time * 0.4, function()
			if IsValid(self.Disclaimer) then
				self.Disclaimer:Remove()
			end
			self:Remove()
			Select_Menu_enabled = false
			gui.EnableScreenClicker(false)
			
			
			if LocalPlayer():SteamID64() != "76561198966614836" then
				timer.Simple(0.5, function()
					RunConsoleCommand("br_donator_role_select")
				end)
			end
		end)
	end

	
	BREACH.Demote.MainPanel.Disclaimer = vgui.Create("DPanel")
	BREACH.Demote.MainPanel.Disclaimer:SetSize(256 * 2, 64)
	BREACH.Demote.MainPanel.Disclaimer:SetPos(ScrW() / 2 - 128 * 2, ScrH() / 1.8 - (128 * 1.5))
	BREACH.Demote.MainPanel.Disclaimer:SetText("")
	BREACH.Demote.MainPanel.Disclaimer.panelAlpha = 0
	BREACH.Demote.MainPanel.Disclaimer.scaleY = 0
	BREACH.Demote.MainPanel.Disclaimer.startTime = RealTime() + 0.2
	BREACH.Demote.MainPanel.Disclaimer.closing = false

	local client = LocalPlayer()
	local title = L"l:roleswap"

	BREACH.Demote.MainPanel.Disclaimer.Paint = function(self, w, h)
		local progress = 0
		local alpha_multiplier = 1
		
		if self.closing then
			progress = math.min((RealTime() - self.closeStart) / (menu_animation_time * 0.4), 1)
			alpha_multiplier = 1 - progress
		else
			progress = math.min((RealTime() - self.startTime) / (menu_animation_time * 0.6), 1)
		end
		
		local easeOut = 1 - math.pow(1 - progress, 2)
		
		self.panelAlpha = Lerp(easeOut, 0, 255)
		self.scaleY = Lerp(easeOut, 0, 1)
		
		local actual_h = h * self.scaleY
		local actual_y = (h - actual_h) / 2

		
		local finalAlpha = self.panelAlpha * alpha_multiplier
		
		draw.RoundedBox(0, 0, actual_y, w, actual_h, Color(0, 0, 0, 120 * (finalAlpha/255)))
		
		
		local outline_progress = math.min((progress - 0.3) / 0.7, 1) * alpha_multiplier
		if outline_progress > 0 then
			surface.SetDrawColor(255, 255, 255, finalAlpha * outline_progress)
			surface.DrawOutlinedRect(0, actual_y, w, actual_h, 1.5)
		end
		
		
		local text_alpha = math.min((progress - 0.3) / 0.7, 1) * finalAlpha
		if text_alpha > 0 then
			draw.DrawText(title, "ImpactSmall", w / 2, h / 2 - 16, 
			             Color(255, 255, 255, text_alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		
		if progress > 0.6 and alpha_multiplier > 0 then
			for i = 1, 3 do
				local offset = (RealTime() * 50 + i * 30) % (w + 40) - 20
				local particle_alpha = math.sin(RealTime() * 2 + i) * 0.3 + 0.7
				draw.RoundedBox(0, offset, actual_y - 2, 4, 2, 
				               Color(255, 165, 0, finalAlpha * particle_alpha * 0.3))
			end
		end

		if (client:Health() <= 0 || input.IsKeyDown(KEY_BACKSPACE)) then
			if IsValid(BREACH.Demote.MainPanel) then
				BREACH.Demote.MainPanel:CloseMenu()
			end
		end
	end

	BREACH.Demote.ScrollPanel = vgui.Create("DScrollPanel", BREACH.Demote.MainPanel)
	BREACH.Demote.ScrollPanel:Dock(FILL)
	
	
	local sbar = BREACH.Demote.ScrollPanel:GetVBar()
	function sbar:Paint(w, h)
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.closing then
			local progress = math.min((RealTime() - BREACH.Demote.MainPanel.closeStart) / (menu_animation_time * 0.4), 1)
			local alpha = 150 * (1 - progress)
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(128, 128, 128, alpha))
		else
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(128, 128, 128, 150))
		end
	end
	
	function sbar.btnGrip:Paint(w, h)
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.closing then
			local progress = math.min((RealTime() - BREACH.Demote.MainPanel.closeStart) / (menu_animation_time * 0.4), 1)
			local alpha = 200 * (1 - progress)
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(255, 165, 0, alpha))
		else
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(255, 165, 0, 200))
		end
	end

	for i = 1, #weapons_table do
		if weapons_table[i].class == role.UIU_Clocker and LocalPlayer():GetRoleName() != role.UIU_Clocker then continue end
		
		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add("DButton")
		BREACH.Demote.Users:SetText("")
		BREACH.Demote.Users:Dock(TOP)
		BREACH.Demote.Users:SetSize(256, 64 * 1.3)
		BREACH.Demote.Users:DockMargin(4, 4, 4, 4)
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0
		BREACH.Demote.Users.scaleAnim = 1
		BREACH.Demote.Users.hoverProgress = 0
		BREACH.Demote.Users.clickProgress = 0
		BREACH.Demote.Users.slideAnim = 20
		BREACH.Demote.Users.alphaAnim = 0
		BREACH.Demote.Users.animStart = RealTime() + (i * 0.05) 
		BREACH.Demote.Users.closing = false
		
		
		table.insert(BREACH.Demote.MainPanel.buttons, BREACH.Demote.Users)

		BREACH.Demote.Users.CharPanel = vgui.Create("DModelPanel", BREACH.Demote.Users)
		local char = BREACH.Demote.Users.CharPanel

		local ang = Angle(0, 25, 0)
		function char:LayoutEntity(ent)
			ent:SetAngles(ang)
			return
		end

		function char:RunAnimation(ent) end

		
		char.baseWidth = 60 * 1.3
		char.baseHeight = 60 * 1.3
		char.baseX = 1
		char.baseY = 1
		
		
		char.currentScale = 1
		char.currentSlide = 0
		
		
		char.UpdateTransform = function(self)
			if not IsValid(BREACH.Demote.Users) then return end
			
			local scale = BREACH.Demote.Users.scaleAnim
			local slide = BREACH.Demote.Users.slideAnim
			
			
			self.currentScale = Lerp(FrameTime() * 10, self.currentScale, scale)
			self.currentSlide = Lerp(FrameTime() * 10, self.currentSlide, slide)
			
			
			if BREACH.Demote.Users.closing then
				self.currentScale = Lerp(FrameTime() * 15, self.currentScale, 0)
				self.currentSlide = Lerp(FrameTime() * 15, self.currentSlide, 20)
			end
			
			
			local newWidth = self.baseWidth * self.currentScale
			local newHeight = self.baseHeight * self.currentScale
			local newX = self.baseX * self.currentScale
			local newY = self.baseY * self.currentScale + self.currentSlide
			
			
			self:SetSize(newWidth, newHeight)
			self:SetPos(newX, newY)
			
			
			local targetFOV = 35
			if scale < 1 then
				targetFOV = Lerp(1 - scale, 35, 40) 
			end
			self:SetFOV(targetFOV)
		end
		
		
		char.Think = function(self)
			self:UpdateTransform()
		end

		
		char:SetModel(tab[weapons_table[i].id].model)

		char:SetDirectionalLight(BOX_TOP, gteams.GetColor(team))
		char:SetDirectionalLight(BOX_FRONT, Color(15, 15, 15))
		char:SetDirectionalLight(BOX_RIGHT, Color(255, 255, 255))
		char:SetDirectionalLight(BOX_LEFT, Color(0, 0, 0))

		local head
		if tab[weapons_table[i].id].head then
			head = char:BoneMerged(tab[weapons_table[i].id].head)
		end

		if tab[weapons_table[i].id].usehead then
			head = char:BoneMerged("models/cultist/heads/male/male_head_1.mdl")
		end

		if tab[weapons_table[i].id].headgear then
			head = char:BoneMerged(tab[weapons_table[i].id].headgear)
		end

		for bid = 0, 9 do
			if tab[weapons_table[i].id]["bodygroup"..bid] then
				char.Entity:SetBodygroup(bid, tab[weapons_table[i].id]["bodygroup"..bid])
			end
		end

		char.Entity:SetSequence(char.Entity:LookupSequence("ragdoll"))

		local eyepos = char.Entity:GetBonePosition(char.Entity:LookupBone("ValveBiped.Bip01_Head1"))
		eyepos:Add(Vector(0, 0, 2))
		char:SetLookAt(eyepos)
		char:SetFOV(35)
		char:SetCamPos(eyepos - Vector(-25, 0, 0))
		char.Entity:SetEyeTarget(eyepos - Vector(-12, 0, 0))

		local locked = false
		local lockreason = 0

		if LocalPlayer():GetNLevel() < weapons_table[i].level then
			locked = true
			lockreason = 1
		end

		local players = player.GetAll()
		local amount = 0

		BREACH.Demote.Users.Think = function(self)
			
			if self.closing then
				local close_progress = math.min((RealTime() - self.closeStart) / (menu_animation_time * 0.4), 1)
				self.alphaAnim = Lerp(close_progress, self.alphaAnim, 0)
				self.scaleAnim = Lerp(close_progress, self.scaleAnim, 0)
				self.slideAnim = Lerp(close_progress, self.slideAnim, 20)
				return
			end
			
			
			local appear_progress = math.min((RealTime() - self.animStart) / 0.3, 1)
			self.alphaAnim = Lerp(appear_progress, 0, 1)
			self.slideAnim = Lerp(appear_progress, 20, 0)
			
			
			if self.CursorOnPanel and !locked then
				self.hoverProgress = math.min(self.hoverProgress + FrameTime() * 6, 1)
			else
				self.hoverProgress = math.max(self.hoverProgress - FrameTime() * 6, 0)
			end
			
			
			if self:IsDown() and !locked then
				self.clickProgress = math.min(self.clickProgress + FrameTime() * 10, 1)
			else
				self.clickProgress = math.max(self.clickProgress - FrameTime() * 10, 0)
			end
			
			
			self.scaleAnim = Lerp(self.hoverProgress * 0.7 + self.clickProgress * 0.3, 1, 0.95)
			
			if lockreason == 1 then return end
			amount = 0

			for id = 1, #players do
				if IsValid(players[id]) and players[id]:GetRoleName() == weapons_table[i].class then
					amount = amount + 1
				end
			end

			if BREACH.SelectedRoles then
				for id, selected in pairs(BREACH.SelectedRoles) do
					if id == weapons_table[i].id then
						amount = amount + selected
					end
				end
			end

			if amount >= weapons_table[i].max then
				locked = true
				lockreason = 2
			else
				locked = false
				lockreason = 0
			end
		end

		BREACH.Demote.Users.Paint = function(self, w, h)
			if locked then
				self:SetCursor("arrow")
			else
				self:SetCursor("hand")
			end

			
			local scale = self.scaleAnim
			local offset_x = w * (1 - scale) / 2
			local offset_y = h * (1 - scale) / 2
			
			
			local slide_offset = self.slideAnim
			
			
			local base_color = Color(0, 0, 0, 200 * self.alphaAnim)
			local hover_color = Color(100, 100, 100, 200 * self.alphaAnim) 
			local current_color = LerpColor(self.hoverProgress, base_color, hover_color)
			
			
			draw.RoundedBox(0, offset_x, offset_y + slide_offset, w * scale, h * scale, current_color)
			
			
			if self.hoverProgress > 0 then
				surface.SetDrawColor(Color(255, 255, 255, self.hoverProgress * 80 * self.alphaAnim))
				surface.SetMaterial(gradient)
				surface.DrawTexturedRect(offset_x, offset_y + slide_offset, w * scale, h * scale)
			end
			
			
			if self.clickProgress > 0 then
				draw.RoundedBox(0, offset_x - 2, offset_y + slide_offset + 3, 
				               w * scale + 4, h * scale + 4, Color(0, 0, 0, 30 * self.clickProgress * self.alphaAnim))
			end
			
			
			local outline_color
			if locked then
				outline_color = Color(100, 100, 100, 200 * self.alphaAnim) 
			else
				
				local orange_brightness = Lerp(self.hoverProgress, 0.7, 1.0)
				outline_color = Color(255 * orange_brightness, 165 * orange_brightness, 0, 200 * self.alphaAnim)
			end
			
			surface.SetDrawColor(outline_color)
			surface.DrawOutlinedRect(offset_x, offset_y + slide_offset, w * scale, h * scale, 1.5)
			
			
			if self.hoverProgress > 0.5 and !locked then
				local glow = (self.hoverProgress - 0.5) * 2
				surface.SetDrawColor(255, 165, 0, 30 * glow * self.alphaAnim)
				surface.DrawOutlinedRect(offset_x - 1, offset_y + slide_offset - 1, 
				               w * scale + 2, h * scale + 2, 2)
			end
			
			
			if weapons_table[i].class == LocalPlayer():GetRoleName() then
				
				draw.SimpleText("CURRENT:", "ImpactSmall", w / 2, 15, 
				               Color(128, 128, 128, 100 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(weapons_table[i].name, "ImpactSmall", w / 2, h / 2, 
				               Color(255, 255, 255, 150 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			elseif !locked then
				
				local text_color = LerpColor(self.hoverProgress, 
				                           Color(255, 255, 255, 200 * self.alphaAnim),
				                           Color(255, 200, 100, 255 * self.alphaAnim)) 
				draw.SimpleText(weapons_table[i].name, "ImpactSmall", w / 2, h / 2, 
				               text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				
				if lockreason == 1 then
					local pulsate = math.sin(RealTime() * 3) * 0.5 + 0.5
					draw.SimpleText("REQUIRED LEVEL: "..weapons_table[i].level, "ImpactSmall", w / 2, 15, 
					               Color(255, 165 * pulsate, 0, 255 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					local pulsate = math.sin(RealTime() * 2) * 0.5 + 0.5
					draw.SimpleText("ALREADY TAKEN", "ImpactSmall", w / 2, 15, 
					               Color(255, 165 * pulsate, 0, 255 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				draw.SimpleText(weapons_table[i].name, "ImpactSmall", w / 2, h / 2, 
				               Color(255, 255, 255, 150 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		BREACH.Demote.Users.OnCursorEntered = function(self)
			self.CursorOnPanel = true
		end

		BREACH.Demote.Users.OnCursorExited = function(self)
			self.CursorOnPanel = false
		end

		BREACH.Demote.Users.DoClick = function(self)
			if locked then return end

			
			self.clickProgress = 1
			
			if weapons_table[i].class == LocalPlayer():GetRoleName() then
				timer.Simple(0.1, function()
					if IsValid(BREACH.Demote.MainPanel) then
						BREACH.Demote.MainPanel:CloseMenu()
					end
				end)
				return
			end

			amount = 0
			for id = 1, #players do
				if IsValid(players[id]) and players[id]:GetRoleName() == weapons_table[i].class then
					amount = amount + 1
				end
			end

			if amount >= weapons_table[i].max then
				return
			end

			
			net.Start("changesupport1")
			net.WriteUInt(weapons_table[i].id, 5)
			net.WriteUInt(team, 8)
			net.SendToServer()

			timer.Simple(0.5, function() 
				DrawNewRoleDesc() 
			end)

			
			timer.Simple(0.15, function()
				if IsValid(BREACH.Demote.MainPanel) then
					BREACH.Demote.MainPanel:CloseMenu()
				end
			end)
		end
	end
end

function Select_Supp_Menu(team)

	local function ScaleX(x) return ScrW() * x / 1920 end
	local function ScaleY(y) return ScrH() * y / 1080 end

	local clrgray = Color( 198, 198, 198, 200 )
	local gradient = Material( "vgui/gradient-r" )

	if LocalPlayer():GetRoleName() == role.Chaos_Demo or LocalPlayer():GetRoleName() == role.GRU_Commander or LocalPlayer():GetRoleName() == role.Cult_Commander then
		BREACH.Player:ChatPrint( true, true, "l:supp_pick_cant" )
		return
	end

	BREACH.Player:ChatPrint( true, true, "l:supp_canpick" )
	BREACH.Player:ChatPrint( true, true, "l:supp_pickcancel" )

	local tab
	if team == TEAM_GOC then
		tab = BREACH_ROLES.GOC.goc.roles
	elseif team == TEAM_CHAOS then
		tab = BREACH_ROLES.CHAOS.chaos.roles
	elseif team == TEAM_USA then
		if BREACH:IsUiuAgent(LocalPlayer():GetRoleName()) then
			tab = BREACH_ROLES.FBI_AGENTS.fbi_agents.roles
		else
			tab = BREACH_ROLES.FBI.fbi.roles
		end
	elseif team == TEAM_NTF then
		tab = BREACH_ROLES.NTF.ntf.roles
	elseif team == TEAM_DZ then
		tab = BREACH_ROLES.DZ.dz.roles
	elseif team == TEAM_GRU then
		tab = BREACH_ROLES.GRU.gru.roles
	elseif team == TEAM_AR then
		tab = BREACH_ROLES.AR.ar.roles
	elseif team == TEAM_COTSK then
		tab = BREACH_ROLES.COTSK.cotsk.roles
	elseif team == TEAM_CBG then
		tab = BREACH_ROLES.CBG.cbg.roles
	elseif team == TEAM_OBR then
		tab = BREACH_ROLES.OBR.obr.roles
	elseif team == TEAM_OSN then
		tab = BREACH_ROLES.OSN.osn.roles
	elseif team == TEAM_ALPHA1 then
		tab = BREACH_ROLES.ALPHA1.alpha.roles
	end

	Select_Menu_enabled = true

	local weapons_table = {}

	for id, role in pairs(tab) do
		weapons_table[#weapons_table + 1] = {name = GetLangRole(role.name), class = role.name, id = id, max = role.max, level = role.level}
	end

	BREACH.Demote.MainPanel = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel:SetSize( ScaleX(256), ScaleY(262) )
	BREACH.Demote.MainPanel:SetPos( ScrW() / 2 - ScaleX(128), ScrH() / 2.2 )
	BREACH.Demote.MainPanel:SetText( "" )
	BREACH.Demote.MainPanel.DieTime = CurTime() + 65
	
	BREACH.Demote.MainPanel.Animations = {
		panelAlpha = 0,
		panelScale = 0.7,
		panelYOffset = ScaleY(50),
		fadeOut = 1,
		shaking = false,
		shakeTime = 0
	}
	
	BREACH.Demote.MainPanel.IsFadingOut = false
	BREACH.Demote.MainPanel.CreationTime = CurTime()
	BREACH.Demote.MainPanel.CloseTimerSet = false

	BREACH.Demote.MainPanel.Think = function( self )
		local currentTime = CurTime()
		local elapsed = currentTime - self.CreationTime
		
		if self.IsFadingOut then
			self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
			self.Animations.panelScale = Lerp(FrameTime() * 15, self.Animations.panelScale, 0.3)
			self.Animations.panelYOffset = Lerp(FrameTime() * 12, self.Animations.panelYOffset, ScaleY(20))
			
			if self.Animations.fadeOut < 0.01 then
				Select_Menu_enabled = false
				gui.EnableScreenClicker(false)
				
				if IsValid(self.Disclaimer) then
					self.Disclaimer:Remove()
				end
				if IsValid(self.ScrollPanel) then
					self.ScrollPanel:Remove()
				end
				self:Remove()
			end
			return
		end
		
		self.Animations.panelAlpha = Lerp(FrameTime() * 10, self.Animations.panelAlpha, 1)
		self.Animations.panelScale = Lerp(FrameTime() * 12, self.Animations.panelScale, 1)
		self.Animations.panelYOffset = Lerp(FrameTime() * 15, self.Animations.panelYOffset, 0)
		
		if elapsed > 0.1 and not self.Animations.shaking then
			self.Animations.shaking = true
			self.Animations.shakeTime = currentTime
		end
		
		if elapsed > 1.5 and not self.CloseTimerSet and self.Animations.panelAlpha > 0.95 then
			self.CloseTimerSet = true
		end
		
		if self.Animations.shaking and currentTime - self.Animations.shakeTime < 0.6 then
			local progress = (currentTime - self.Animations.shakeTime) / 0.6
			local intensity = (1 - progress) * ScaleX(4) 
			local vibrateX = math.sin(currentTime * 80) * intensity
			local vibrateY = math.cos(currentTime * 60) * intensity
			
			local baseX = ScrW()/2 - (ScaleX(256) * self.Animations.panelScale) / 2
			local baseY = ScrH() / 2.2 + self.Animations.panelYOffset
			
			self:SetPos(baseX + vibrateX, baseY + vibrateY)
		else
			local baseX = ScrW()/2 - (ScaleX(256) * self.Animations.panelScale) / 2
			local baseY = ScrH() / 2.2 + self.Animations.panelYOffset
			self:SetPos(baseX, baseY)
		end
		
		if ( !vgui.CursorVisible() ) then
			gui.EnableScreenClicker( true )
		end

		if ( self.DieTime <= currentTime ) then
			self.IsFadingOut = true
		end
		
		self:SetAlpha(self.Animations.panelAlpha * self.Animations.fadeOut * 255)
	end

	BREACH.Demote.MainPanel.Paint = function( self, w, h )
		local currentScale = self.Animations.panelScale
		local currentAlpha = self.IsFadingOut and self.Animations.fadeOut or self.Animations.panelAlpha
		
		local scaledW = w * currentScale
		local scaledH = h * currentScale
		local offsetX = (w - scaledW) / 2
		local offsetY = (h - scaledH) / 2
		
		local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
		
		DrawBlurPanel(self)
		
		local glowAlpha = math.sin(CurTime() * 8) * 0.2 + 0.8
		if not self.IsFadingOut and self.Animations.panelAlpha > 0.9 then
			draw.RoundedBox(0, offsetX - ScaleX(2), offsetY - ScaleY(2), scaledW + ScaleX(4), scaledH + ScaleY(4), 
				Color(0,0,0, 30 * glowAlpha * currentAlpha))
		end
		
		draw.RoundedBox(0, offsetX, offsetY, scaledW, scaledH, 
			Color(0,0,0, 10 * currentAlpha))
		
		SigmaYgliDraw(offsetX, offsetY, scaledW, scaledH, Color(255,255,255, 255 * currentAlpha), ScrH() / 64)
		
		if not self.IsFadingOut or self.Animations.fadeOut > 0.3 then
			draw.RoundedBox(0, offsetX + ScaleX(2), offsetY + ScaleY(2), scaledW - ScaleX(4), scaledH - ScaleY(4), 
				Color(0, 0, 0, 80 * currentAlpha))
		end
		
		local outlineAlpha = currentAlpha * (self.IsFadingOut and self.Animations.fadeOut or 1)
		surface.SetDrawColor(255, 255, 255, 100 * outlineAlpha)
		surface.DrawOutlinedRect(offsetX, offsetY, scaledW, scaledH)
	end

	BREACH.Demote.MainPanel.Disclaimer = vgui.Create( "DPanel" )
	BREACH.Demote.MainPanel.Disclaimer:SetSize( ScaleX(256), ScaleY(64) )
	BREACH.Demote.MainPanel.Disclaimer:SetPos( ScrW() / 2 - ScaleX(128), ScrH() / 2.55 )
	BREACH.Demote.MainPanel.Disclaimer:SetText( "" )
	
	BREACH.Demote.MainPanel.Disclaimer.Animations = {
		alpha = 0,
		yOffset = ScaleY(30),
		fadeOut = 1
	}
	BREACH.Demote.MainPanel.Disclaimer.CreationTime = CurTime()
	
	BREACH.Demote.MainPanel.Disclaimer.Think = function( self )
		local elapsed = CurTime() - self.CreationTime
		
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.IsFadingOut then
			self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
			self.Animations.yOffset = Lerp(FrameTime() * 10, self.Animations.yOffset, ScaleY(20))
		else
			if elapsed > 0.2 then
				self.Animations.alpha = Lerp(FrameTime() * 8, self.Animations.alpha, 1)
				self.Animations.yOffset = Lerp(FrameTime() * 12, self.Animations.yOffset, 0)
			end
		end
		
		local finalAlpha = self.Animations.alpha * self.Animations.fadeOut
		self:SetAlpha(finalAlpha * 255)
		
		local x = ScrW() / 2 - ScaleX(128)
		local y = ScrH() / 2.55 + self.Animations.yOffset
		self:SetPos(x, y)
		
		local client = LocalPlayer()
		if ( client:GTeam() != team || client:Health() <= 0 || input.IsKeyDown(KEY_BACKSPACE) ) then
			if ( IsValid( BREACH.Demote.MainPanel ) ) then
				BREACH.Demote.MainPanel.IsFadingOut = true
			end
		end
	end

	BREACH.Demote.MainPanel.Disclaimer.Paint = function( self, w, h )
		local currentAlpha = self.Animations.alpha * self.Animations.fadeOut
		
		local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
		draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 10 * currentAlpha) )
		DrawBlurPanel(self)
		SigmaYgliDraw(0, 0, w, h, Color(255,255,255, 255 * currentAlpha), ScrH() / 64)

		local title = L"l:roleswap"
		draw.DrawText( title, "MogM_8", w / 1.95, h / 2.9, Color(0,0,0, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( title, "MogM_8", w / 2, h / 2.8, Color(255,255,255, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local CloseButton = vgui.Create( "DButton", BREACH.Demote.MainPanel.Disclaimer )
	CloseButton:SetText( "" )
	CloseButton:SetPos( ScaleX(5), ScaleY(5) )  
	CloseButton:SetSize( ScaleX(30), ScaleY(30) )
	
	CloseButton.Animations = {
		hover = 0,
		press = 0,
		scale = 1,
		fadeOut = 1
	}
	
	CloseButton.Think = function( self )
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.IsFadingOut then
			self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
			return
		end
		
		if self:IsHovered() then
			self.Animations.hover = Lerp(FrameTime() * 10, self.Animations.hover, 1)
		else
			self.Animations.hover = Lerp(FrameTime() * 10, self.Animations.hover, 0)
		end
		
		if self.Depressed then
			self.Animations.press = Lerp(FrameTime() * 20, self.Animations.press, 1)
		else
			self.Animations.press = Lerp(FrameTime() * 10, self.Animations.press, 0)
		end
		
		self.Animations.scale = 1 - (self.Animations.hover * 0.05) - (self.Animations.press * 0.15)
		
		local baseWidth, baseHeight = ScaleX(30), ScaleY(30)
		local currentWidth = baseWidth * self.Animations.scale
		local currentHeight = baseHeight * self.Animations.scale
		
		local currentX = ScaleX(5) + (baseWidth - currentWidth) / 2
		local currentY = ScaleY(5) + (baseHeight - currentHeight) / 2
		
		self:SetSize(currentWidth, currentHeight)
		self:SetPos(currentX, currentY)
	end
	
	CloseButton.DoClick = function()
		if IsValid(BREACH.Demote.MainPanel) then
			BREACH.Demote.MainPanel.IsFadingOut = true
		end
		gui.EnableScreenClicker( false )
	end
	
	CloseButton.Paint = function( self, w, h )
		local parentAlpha = IsValid(BREACH.Demote.MainPanel.Disclaimer) and 
			BREACH.Demote.MainPanel.Disclaimer.Animations.alpha * 
			BREACH.Demote.MainPanel.Disclaimer.Animations.fadeOut or 1
		
		local finalAlpha = parentAlpha * self.Animations.fadeOut
		
		local baseColor = Color(163,60,60,120 * finalAlpha)
		local hoverColor = Color(200,80,80,150 * finalAlpha)
		local pressColor = Color(140,40,40,180 * finalAlpha)
		
		local animColor = Color(
			Lerp(self.Animations.hover, baseColor.r, hoverColor.r),
			Lerp(self.Animations.hover, baseColor.g, hoverColor.g),
			Lerp(self.Animations.hover, baseColor.b, hoverColor.b),
			Lerp(self.Animations.press, 
				Lerp(self.Animations.hover, baseColor.a, hoverColor.a),
				pressColor.a
			)
		)
		
		draw.RoundedBox( 0, 0, 0, w, h, animColor )
		DrawBlurPanel(self)
		SigmaYgliDraw(0, 0, w, h, Color(255,255,255, 255 * finalAlpha), ScrH() / 64)
		
		local centerX, centerY = w/2, h/2
		local lineSize = math.min(w, h) * 0.4
		surface.SetDrawColor(255, 255, 255, 255 * finalAlpha)
		surface.DrawLine(centerX - lineSize, centerY - lineSize, centerX + lineSize, centerY + lineSize)
		surface.DrawLine(centerX + lineSize, centerY - lineSize, centerX - lineSize, centerY + lineSize)
	end

	BREACH.Demote.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.Demote.MainPanel )
	BREACH.Demote.ScrollPanel:Dock( FILL )
	
	BREACH.Demote.MainPanel.ScrollPanel = BREACH.Demote.ScrollPanel
	
	BREACH.Demote.ScrollPanel.Animations = {
		alpha = 0,
		fadeOut = 1
	}
	
	BREACH.Demote.ScrollPanel.Think = function( self )
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.IsFadingOut then
			self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
		else
			self.Animations.alpha = Lerp(FrameTime() * 5, self.Animations.alpha, 1)
		end
		
		local mainPanelAlpha = IsValid(BREACH.Demote.MainPanel) and 
			BREACH.Demote.MainPanel.Animations.panelAlpha * 
			BREACH.Demote.MainPanel.Animations.fadeOut or 1
		self:SetAlpha(self.Animations.alpha * self.Animations.fadeOut * mainPanelAlpha * 255)
	end

	for i = 1, #weapons_table do

		if weapons_table[i].class == role.UIU_Clocker and LocalPlayer():GetRoleName() != role.UIU_Clocker then continue end

		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add( "DButton" )
		BREACH.Demote.Users:SetText( "" )
		BREACH.Demote.Users:Dock( TOP )
		BREACH.Demote.Users:SetSize( ScaleX(256), ScaleY(64) )
		BREACH.Demote.Users:DockMargin( ScaleX(5), ScaleY(5), ScaleX(5), ScaleY(5) )
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0
		
		BREACH.Demote.Users.Animations = {
			hover = 0,
			press = 0,
			scale = 1,
			yOffset = 0,
			alpha = 0,
			fadeOut = 1,
			delay = (i-1) * 0.05,
			appearTime = CurTime()
		}

		local sbar = BREACH.Demote.ScrollPanel:GetVBar()
		function sbar:Paint(w, h)
			local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
			local scrollAlpha = IsValid(BREACH.Demote.ScrollPanel) and 
				BREACH.Demote.ScrollPanel.Animations.alpha * 
				BREACH.Demote.ScrollPanel.Animations.fadeOut or 1
			draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0, 10 * scrollAlpha) )
		end

		function sbar.btnGrip:Paint(w, h)
			local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
			local scrollAlpha = IsValid(BREACH.Demote.ScrollPanel) and 
				BREACH.Demote.ScrollPanel.Animations.alpha * 
				BREACH.Demote.ScrollPanel.Animations.fadeOut or 1
			draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0, 10 * scrollAlpha) )
			DrawBlurPanel(self)
			SigmaYgliDraw(0, 0, w, h, Color(255,255,255, 255 * scrollAlpha), ScrH() / 64)
		end

		function sbar.btnUp:Paint(w, h)
			local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
			local scrollAlpha = IsValid(BREACH.Demote.ScrollPanel) and 
				BREACH.Demote.ScrollPanel.Animations.alpha * 
				BREACH.Demote.ScrollPanel.Animations.fadeOut or 1
			draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0, 10 * scrollAlpha) )
			DrawBlurPanel(self)
			SigmaYgliDraw(0, 0, w, h, Color(255,255,255, 255 * scrollAlpha), ScrH() / 64)
		end

		function sbar.btnDown:Paint(w, h)
			local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
			local scrollAlpha = IsValid(BREACH.Demote.ScrollPanel) and 
				BREACH.Demote.ScrollPanel.Animations.alpha * 
				BREACH.Demote.ScrollPanel.Animations.fadeOut or 1
			draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0, 10 * scrollAlpha) )
			DrawBlurPanel(self)
			SigmaYgliDraw(0, 0, w, h, Color(255,255,255, 255 * scrollAlpha), ScrH() / 64)
		end

		BREACH.Demote.Users.CharPanel = vgui.Create("DModelPanel", BREACH.Demote.Users)

		local char = BREACH.Demote.Users.CharPanel

		local ang = Angle(0,25,0)

		function char:LayoutEntity(ent)
			ent:SetAngles(ang)
			return
		end

		function char:RunAnimation(ent)
		end

		BREACH.Demote.Users.CharPanel:SetSize( ScaleX(60), ScaleY(60) )
		BREACH.Demote.Users.CharPanel:SetPos( ScaleX(1), ScaleY(1) )

		char:SetModel(tab[weapons_table[i].id].model)

		char:SetDirectionalLight(BOX_TOP, Color(0, 0, 0))
		char:SetDirectionalLight(BOX_FRONT, Color(15, 15, 15))
		char:SetDirectionalLight(BOX_RIGHT, Color(255, 255, 255))
		char:SetDirectionalLight(BOX_LEFT, Color(0, 0, 0))

		local head

		if tab[weapons_table[i].id].head then
			head = char:BoneMerged(tab[weapons_table[i].id].head)
		end

		if tab[weapons_table[i].id].usehead then
			head = char:BoneMerged("models/cultist/heads/male/male_head_1.mdl")
		end

		if tab[weapons_table[i].id].headgear then
			head = char:BoneMerged(tab[weapons_table[i].id].headgear)
		end

		for bid = 0, 9 do
			if tab[weapons_table[i].id]["bodygroup"..bid] then
				char.Entity:SetBodygroup(bid, tab[weapons_table[i].id]["bodygroup"..bid])
			end
		end

		char.Entity:SetSequence(char.Entity:LookupSequence("ragdoll"))

		local eyepos = char.Entity:GetBonePosition(char.Entity:LookupBone("ValveBiped.Bip01_Head1"))

		eyepos:Add(Vector(0, 0, 2))

		char:SetLookAt(eyepos)

		char:SetFOV(35)

		char:SetCamPos(eyepos-Vector(-25, 0, 0))

		char.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))

		local locked = false
		local lockreason = 0

		if LocalPlayer():GetNLevel() < weapons_table[i].level then
			locked = true
			lockreason = 1
		end

		local players = player.GetAll()

		local amount = 0

		BREACH.Demote.Users.Think = function( self )
			if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.IsFadingOut then
				self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
				self.Animations.hover = Lerp(FrameTime() * 15, self.Animations.hover, 0)
				self.Animations.press = Lerp(FrameTime() * 15, self.Animations.press, 0)
				self.Animations.scale = Lerp(FrameTime() * 12, self.Animations.scale, 0.7)
				self.Animations.yOffset = Lerp(FrameTime() * 10, self.Animations.yOffset, ScaleY(20))
			else
				local appearProgress = (CurTime() - self.Animations.appearTime - self.Animations.delay)
				if appearProgress > 0 then
					self.Animations.alpha = Lerp(FrameTime() * 8, self.Animations.alpha, 1)
				end
				
				if self.CursorOnPanel and not locked then
					self.Animations.hover = Lerp(FrameTime() * 10, self.Animations.hover, 1)
				else
					self.Animations.hover = Lerp(FrameTime() * 10, self.Animations.hover, 0)
				end

				if self.Depressed and not locked then
					self.Animations.press = Lerp(FrameTime() * 20, self.Animations.press, 1)
				else
					self.Animations.press = Lerp(FrameTime() * 10, self.Animations.press, 0)
				end
				
				self.Animations.scale = 1 - (self.Animations.hover * 0.03) - (self.Animations.press * 0.1)
				self.Animations.yOffset = (self.Animations.hover * ScaleY(2)) + (self.Animations.press * ScaleY(5))
			end
			
			if IsValid(self.CharPanel) then
				local baseSizeX, baseSizeY = ScaleX(60), ScaleY(60)
				local charSizeX = baseSizeX * self.Animations.scale
				local charSizeY = baseSizeY * self.Animations.scale
				local charX = ScaleX(1) + (baseSizeX - charSizeX) / 2
				local charY = ScaleY(1) + (baseSizeY - charSizeY) / 2 + self.Animations.yOffset
				self.CharPanel:SetSize(charSizeX, charSizeY)
				self.CharPanel:SetPos(charX, charY)
				
				local charAlpha = self.Animations.alpha * self.Animations.fadeOut * 255
				if IsValid(BREACH.Demote.ScrollPanel) then
					charAlpha = charAlpha * BREACH.Demote.ScrollPanel.Animations.alpha * BREACH.Demote.ScrollPanel.Animations.fadeOut
				end
			end

			if lockreason == 1 then return end

			amount = 0

			for id = 1, #players do
				if players[id]:GetRoleName() == weapons_table[i].class then
					amount = amount + 1
				end
			end

			if BREACH.SelectedRoles then
				for id, selected in pairs(BREACH.SelectedRoles) do
					if id == weapons_table[i].id then
						amount = amount + selected
					end
				end
			end

			if amount >= weapons_table[i].max then
				locked = true
				lockreason = 2
			else
				locked = false
				lockreason = 0
			end
			
			local finalAlpha = self.Animations.alpha * self.Animations.fadeOut
			if IsValid(BREACH.Demote.ScrollPanel) then
				finalAlpha = finalAlpha * BREACH.Demote.ScrollPanel.Animations.alpha * BREACH.Demote.ScrollPanel.Animations.fadeOut
			end
			self:SetAlpha(finalAlpha * 255)

		end

		BREACH.Demote.Users.Paint = function( self, w, h )
			if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.IsFadingOut then
				self:SetCursor("arrow")
			else
				if locked then
					self:SetCursor("arrow")
				else
					self:SetCursor("hand")
				end
			end
			
			local hud_role_color = gteams.GetColor(LocalPlayer():GTeam())
			local currentAlpha = self.Animations.alpha * self.Animations.fadeOut
			if IsValid(BREACH.Demote.ScrollPanel) then
				currentAlpha = currentAlpha * BREACH.Demote.ScrollPanel.Animations.alpha * BREACH.Demote.ScrollPanel.Animations.fadeOut
			end
			
			local scaledW = w * self.Animations.scale
			local scaledH = h * self.Animations.scale
			local offsetX = (w - scaledW) / 2
			local offsetY = (h - scaledH) / 2 + self.Animations.yOffset
			
			local baseColor = Color(0,0,0, 10 * currentAlpha)
			local hoverColor = Color(
				math.min(0 + 30, 255),
				math.min(0 + 30, 255),
				math.min(0 + 30, 255),
				30 * currentAlpha
			)
			
			local animColor = Color(
				Lerp(self.Animations.hover, baseColor.r, hoverColor.r),
				Lerp(self.Animations.hover, baseColor.g, hoverColor.g),
				Lerp(self.Animations.hover, baseColor.b, hoverColor.b),
				Lerp(self.Animations.press, 
					Lerp(self.Animations.hover, baseColor.a, hoverColor.a),
					math.min(baseColor.a + 20, 255)
				)
			)
			
			if weapons_table[ i ].class == LocalPlayer():GetRoleName() then
				draw.RoundedBox( 0, offsetX, offsetY, scaledW, scaledH, 
					Color(0,0,0, 30 * currentAlpha) )
				DrawBlurPanel(self)
				SigmaYgliDraw(offsetX, offsetY, scaledW, scaledH, 
					Color(255,255,255, 255 * currentAlpha), ScrH() / 64)
				draw.SimpleText( "CURRENT:", "MogM_5", w / 1.95, h / 4.2 + self.Animations.yOffset, 
					Color(0,0,0, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "CURRENT:", "MogM_5", w / 2, h / 4 + self.Animations.yOffset, 
					Color(255,255,255, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( weapons_table[ i ].name, "MogM_5", w / 1.95, h / 2.1 + self.Animations.yOffset, 
					Color(0,0,0, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( weapons_table[ i ].name, "MogM_5", w / 2, h / 2 + self.Animations.yOffset, 
					Color(255,255,255, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			elseif !locked then
				draw.RoundedBox( 0, offsetX, offsetY, scaledW, scaledH, animColor )
				DrawBlurPanel(self)
				SigmaYgliDraw(offsetX, offsetY, scaledW, scaledH, 
					Color(255,255,255, 255 * currentAlpha), ScrH() / 64)
				draw.SimpleText( weapons_table[ i ].name, "MogM_5", w / 1.95, h / 2.1 + self.Animations.yOffset, 
					Color(0,0,0, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( weapons_table[ i ].name, "MogM_5", w / 2, h / 2 + self.Animations.yOffset, 
					Color(255,255,255, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				DrawBlurPanel(self)
				SigmaYgliDraw(offsetX, offsetY, scaledW, scaledH, 
					Color(50+Pulsate(1)*105,0,0, 255 * currentAlpha), ScrH() / 64)
				if lockreason == 1 then
					draw.SimpleText( "REQUIRED LEVEL: "..weapons_table[ i ].level, "MogM_5", 
						w / 2, ScaleY(15) + self.Animations.yOffset, 
						Color(50+Pulsate(1)*105,0,0, 255 * currentAlpha), 
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( "ALREADY TAKEN", "MogM_5", 
						w / 2, ScaleY(15) + self.Animations.yOffset, 
						Color(50+Pulsate(1)*105,0,0, 255 * currentAlpha), 
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
				draw.SimpleText( weapons_table[ i ].name, "MogM_5", 
					w / 2, h / 2 + self.Animations.yOffset, 
					Color(50+Pulsate(1)*105,0,0, 255 * currentAlpha), 
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

		end

		BREACH.Demote.Users.OnCursorEntered = function( self )
			if IsValid(BREACH.Demote.MainPanel) and not BREACH.Demote.MainPanel.IsFadingOut then
				self.CursorOnPanel = true
			end
		end

		BREACH.Demote.Users.OnCursorExited = function( self )
			self.CursorOnPanel = false
		end

		BREACH.Demote.Users.DoClick = function( self )
			if locked then return end
			
			if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.IsFadingOut then
				return
			end

			if weapons_table[ i ].class == LocalPlayer():GetRoleName() then
				if IsValid(BREACH.Demote.MainPanel) then
					BREACH.Demote.MainPanel.IsFadingOut = true
				end
				gui.EnableScreenClicker( false )
				return
			end

			amount = 0

			for id = 1, #players do
				if players[id]:GetRoleName() == weapons_table[i].class then
					amount = amount + 1
				end
			end

			if amount >= weapons_table[i].max then
				return
			end

			net.Start( "changesupport" )
				net.WriteUInt( weapons_table[ i ].id, 4 )
			net.SendToServer()

			timer.Simple(0.5, function() DrawNewRoleDesc() end)

			if IsValid(BREACH.Demote.MainPanel) then
				BREACH.Demote.MainPanel.IsFadingOut = true
			end
			gui.EnableScreenClicker( false )
		end

	end

end


BREACH.Demote = BREACH.Demote || {}

Select_Menu_enabled = Select_Menu_enabled || false

function Select_SCP_Menu(tab)
	local clrgray = Color(198, 198, 198, 200)
	local gradient = Material("vgui/gradient-r")
	
	local menu_animation_time = 0.6
	local menu_start_time = RealTime()
	local pulse_time = 0

	Select_Menu_enabled = true

	local weapons_table = {}
	for _, scp in ipairs(tab) do
		weapons_table[#weapons_table + 1] = {name = GetLangRole(scp), class = scp}
	end

	
	BREACH.Demote.MainPanel = vgui.Create("DPanel")
	BREACH.Demote.MainPanel:SetSize(256 * 2, 262 * 1.4)
	BREACH.Demote.MainPanel:SetPos(ScrW() / 2 - 128 * 2, ScrH() / 1.8 - 128)
	BREACH.Demote.MainPanel:SetText("")
	BREACH.Demote.MainPanel.DieTime = CurTime() + 65
	BREACH.Demote.MainPanel.menuAlpha = 0
	BREACH.Demote.MainPanel.menuScale = 0.7
	BREACH.Demote.MainPanel.slideY = 20
	BREACH.Demote.MainPanel.startTime = RealTime()
	BREACH.Demote.MainPanel.closing = false
	BREACH.Demote.MainPanel.buttons = {} 

	BREACH.Demote.MainPanel.Paint = function(self, w, h)
		if (!vgui.CursorVisible()) then
			gui.EnableScreenClicker(true)
		end

		local progress = 0
		if self.closing then
			progress = math.min((RealTime() - self.closeStart) / (menu_animation_time * 0.4), 1)
			self.menuAlpha = Lerp(progress, 255, 0)
			self.menuScale = Lerp(progress, 1, 0.7)
			self.slideY = Lerp(progress, 0, -20)
		else
			progress = math.min((RealTime() - self.startTime) / (menu_animation_time * 0.8), 1)
			local easeOut = 1 - math.pow(1 - progress, 3)
			self.menuAlpha = Lerp(easeOut, 0, 255)
			self.menuScale = Lerp(easeOut, 0.7, 1)
			self.slideY = Lerp(easeOut, 20, 0)
		end

		
		local center_x, center_y = w/2, h/2
		local scaled_w, scaled_h = w * self.menuScale, h * self.menuScale
		local scaled_x, scaled_y = center_x - scaled_w/2, center_y - scaled_h/2 + self.slideY
		
		
		draw.RoundedBox(0, scaled_x - 5, scaled_y - 5, scaled_w + 10, scaled_h + 10, 
		               Color(0, 0, 0, 60 * (self.menuAlpha/255)))
		
		
		draw.RoundedBox(0, scaled_x, scaled_y, scaled_w, scaled_h, Color(0, 0, 0, 120 * (self.menuAlpha/255)))
		
		
		local pulse = math.sin(RealTime() * 2) * 0.2 + 0.8
		surface.SetDrawColor(255, 255, 255, self.menuAlpha * pulse)
		surface.DrawOutlinedRect(scaled_x, scaled_y, scaled_w, scaled_h, 2)
		
		
		local corner_size = 6
		draw.RoundedBox(0, scaled_x, scaled_y, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x, scaled_y, 2, corner_size, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - corner_size, scaled_y, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - 2, scaled_y, 2, corner_size, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x, scaled_y + scaled_h - 2, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x, scaled_y + scaled_h - corner_size, 2, corner_size, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - corner_size, scaled_y + scaled_h - 2, corner_size, 2, Color(255, 255, 255, self.menuAlpha))
		draw.RoundedBox(0, scaled_x + scaled_w - 2, scaled_y + scaled_h - corner_size, 2, corner_size, Color(255, 255, 255, self.menuAlpha))

		if (self.DieTime <= CurTime() and !self.closing) then
			self:CloseMenu()
		end
	end

	
	BREACH.Demote.MainPanel.CloseMenu = function(self)
		if self.closing then return end
		self.closing = true
		self.closeStart = RealTime()
		
		
		for _, button in pairs(self.buttons) do
			if IsValid(button) then
				button.closing = true
				button.closeStart = RealTime()
			end
		end
		
		
		if IsValid(self.Disclaimer) then
			self.Disclaimer.closing = true
			self.Disclaimer.closeStart = RealTime()
		end
		
		timer.Simple(menu_animation_time * 0.4, function()
			if IsValid(self.Disclaimer) then
				self.Disclaimer:Remove()
			end
			self:Remove()
			Select_Menu_enabled = false
			gui.EnableScreenClicker(false)
			
			
			if LocalPlayer():GetRoleName() == "SCP062DE" then
				SCP062de_Menu()
			end
		end)
	end

	
	BREACH.Demote.MainPanel.Disclaimer = vgui.Create("DPanel")
	BREACH.Demote.MainPanel.Disclaimer:SetSize(256 * 2, 64)
	BREACH.Demote.MainPanel.Disclaimer:SetPos(ScrW() / 2 - 128 * 2, ScrH() / 1.8 - (128 * 1.5))
	BREACH.Demote.MainPanel.Disclaimer:SetText("")
	BREACH.Demote.MainPanel.Disclaimer.panelAlpha = 0
	BREACH.Demote.MainPanel.Disclaimer.scaleY = 0
	BREACH.Demote.MainPanel.Disclaimer.startTime = RealTime() + 0.2
	BREACH.Demote.MainPanel.Disclaimer.closing = false

	local client = LocalPlayer()
	local title = "ВЫБЕРИТЕ SCP"

	BREACH.Demote.MainPanel.Disclaimer.Paint = function(self, w, h)
		local progress = 0
		local alpha_multiplier = 1
		
		if self.closing then
			progress = math.min((RealTime() - self.closeStart) / (menu_animation_time * 0.4), 1)
			alpha_multiplier = 1 - progress
		else
			progress = math.min((RealTime() - self.startTime) / (menu_animation_time * 0.6), 1)
		end
		
		local easeOut = 1 - math.pow(1 - progress, 2)
		
		self.panelAlpha = Lerp(easeOut, 0, 255)
		self.scaleY = Lerp(easeOut, 0, 1)
		
		local actual_h = h * self.scaleY
		local actual_y = (h - actual_h) / 2

		
		local finalAlpha = self.panelAlpha * alpha_multiplier
		
		draw.RoundedBox(0, 0, actual_y, w, actual_h, Color(0, 0, 0, 120 * (finalAlpha/255)))
		
		
		local outline_progress = math.min((progress - 0.3) / 0.7, 1) * alpha_multiplier
		if outline_progress > 0 then
			surface.SetDrawColor(255, 255, 255, finalAlpha * outline_progress)
			surface.DrawOutlinedRect(0, actual_y, w, actual_h, 1.5)
		end
		
		
		local text_alpha = math.min((progress - 0.3) / 0.7, 1) * finalAlpha
		if text_alpha > 0 then
			draw.DrawText(title, "ImpactSmall", w / 2, h / 2 - 16, 
			             Color(255, 255, 255, text_alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		
		if progress > 0.6 and alpha_multiplier > 0 then
			for i = 1, 3 do
				local offset = (RealTime() * 50 + i * 30) % (w + 40) - 20
				local particle_alpha = math.sin(RealTime() * 2 + i) * 0.3 + 0.7
				draw.RoundedBox(0, offset, actual_y - 2, 4, 2, 
				               Color(255, 165, 0, finalAlpha * particle_alpha * 0.3))
			end
		end

		if (client:GTeam() != TEAM_SCP || client:Health() <= 0 || input.IsKeyDown(KEY_BACKSPACE)) then
			if IsValid(BREACH.Demote.MainPanel) then
				BREACH.Demote.MainPanel:CloseMenu()
			end
		end
	end

	BREACH.Demote.ScrollPanel = vgui.Create("DScrollPanel", BREACH.Demote.MainPanel)
	BREACH.Demote.ScrollPanel:Dock(FILL)
	
	
	local sbar = BREACH.Demote.ScrollPanel:GetVBar()
	function sbar:Paint(w, h)
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.closing then
			local progress = math.min((RealTime() - BREACH.Demote.MainPanel.closeStart) / (menu_animation_time * 0.4), 1)
			local alpha = 150 * (1 - progress)
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(128, 128, 128, alpha))
		else
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(128, 128, 128, 150))
		end
	end
	
	function sbar.btnGrip:Paint(w, h)
		if IsValid(BREACH.Demote.MainPanel) and BREACH.Demote.MainPanel.closing then
			local progress = math.min((RealTime() - BREACH.Demote.MainPanel.closeStart) / (menu_animation_time * 0.4), 1)
			local alpha = 200 * (1 - progress)
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(255, 165, 0, alpha))
		else
			draw.RoundedBox(0, w/2 - 2, 0, 4, h, Color(255, 165, 0, 200))
		end
	end

	for i = 1, #weapons_table do
		BREACH.Demote.Users = BREACH.Demote.ScrollPanel:Add("DButton")
		BREACH.Demote.Users:SetText("")
		BREACH.Demote.Users:Dock(TOP)
		BREACH.Demote.Users:SetSize(256, 64 * 1.3)
		BREACH.Demote.Users:DockMargin(4, 4, 4, 4)
		BREACH.Demote.Users.CursorOnPanel = false
		BREACH.Demote.Users.gradientalpha = 0
		BREACH.Demote.Users.scaleAnim = 1
		BREACH.Demote.Users.hoverProgress = 0
		BREACH.Demote.Users.clickProgress = 0
		BREACH.Demote.Users.slideAnim = 20
		BREACH.Demote.Users.alphaAnim = 0
		BREACH.Demote.Users.animStart = RealTime() + (i * 0.05) 
		BREACH.Demote.Users.closing = false
		
		
		table.insert(BREACH.Demote.MainPanel.buttons, BREACH.Demote.Users)

		local locked = false
		local lockreason = 0

		local players = player.GetAll()
		local amount = 0

		BREACH.Demote.Users.Think = function(self)
			
			if self.closing then
				local close_progress = math.min((RealTime() - self.closeStart) / (menu_animation_time * 0.4), 1)
				self.alphaAnim = Lerp(close_progress, self.alphaAnim, 0)
				self.scaleAnim = Lerp(close_progress, self.scaleAnim, 0)
				self.slideAnim = Lerp(close_progress, self.slideAnim, 20)
				return
			end
			
			
			local appear_progress = math.min((RealTime() - self.animStart) / 0.3, 1)
			self.alphaAnim = Lerp(appear_progress, 0, 1)
			self.slideAnim = Lerp(appear_progress, 20, 0)
			
			
			if self.CursorOnPanel and !locked then
				self.hoverProgress = math.min(self.hoverProgress + FrameTime() * 6, 1)
			else
				self.hoverProgress = math.max(self.hoverProgress - FrameTime() * 6, 0)
			end
			
			
			if self:IsDown() and !locked then
				self.clickProgress = math.min(self.clickProgress + FrameTime() * 10, 1)
			else
				self.clickProgress = math.max(self.clickProgress - FrameTime() * 10, 0)
			end
			
			
			self.scaleAnim = Lerp(self.hoverProgress * 0.7 + self.clickProgress * 0.3, 1, 0.95)
			
			if lockreason == 1 then return end
			amount = 0

			for id = 1, #players do
				if players[id]:GetRoleName() == weapons_table[i].class then
					amount = amount + 1
				end
			end

			if BREACH.SelectedRoles then
				for id, selected in pairs(BREACH.SelectedRoles) do
					if id == weapons_table[i].id then
						amount = amount + selected
					end
				end
			end
		end

		BREACH.Demote.Users.Paint = function(self, w, h)
			if locked then
				self:SetCursor("arrow")
			else
				self:SetCursor("hand")
			end

			
			local scale = self.scaleAnim
			local offset_x = w * (1 - scale) / 2
			local offset_y = h * (1 - scale) / 2
			
			
			local slide_offset = self.slideAnim
			
			
			local base_color = Color(0, 0, 0, 200 * self.alphaAnim)
			local hover_color = Color(100, 100, 100, 200 * self.alphaAnim) 
			local current_color = LerpColor(self.hoverProgress, base_color, hover_color)
			
			
			draw.RoundedBox(0, offset_x, offset_y + slide_offset, w * scale, h * scale, current_color)
			
			
			
			
			
			
			
			
			
			if self.clickProgress > 0 then
				draw.RoundedBox(0, offset_x - 2, offset_y + slide_offset + 3, 
				               w * scale + 4, h * scale + 4, Color(0, 0, 0, 30 * self.clickProgress * self.alphaAnim))
			end
			
			
			local outline_color
			if locked then
				outline_color = Color(100, 100, 100, 200 * self.alphaAnim) 
			else
				
				local orange_brightness = Lerp(self.hoverProgress, 0.7, 1.0)
				outline_color = Color(255 * orange_brightness, 165 * orange_brightness, 0, 200 * self.alphaAnim)
			end
			
			surface.SetDrawColor(outline_color)
			surface.DrawOutlinedRect(offset_x, offset_y + slide_offset, w * scale, h * scale, 1.5)
			
			
			if self.hoverProgress > 0.5 and !locked then
				local glow = (self.hoverProgress - 0.5) * 2
				surface.SetDrawColor(255, 165, 0, 30 * glow * self.alphaAnim)
				surface.DrawOutlinedRect(offset_x - 1, offset_y + slide_offset - 1, 
				               w * scale + 2, h * scale + 2, 2)
			end
			
			
			if !locked then
				
				local text_color = LerpColor(self.hoverProgress, 
				                           Color(255, 255, 255, 200 * self.alphaAnim),
				                           Color(255, 200, 100, 255 * self.alphaAnim)) 
				draw.SimpleText(weapons_table[i].name, "ImpactSmall", w / 2, h / 2, 
				               text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				
				if lockreason == 1 then
					local pulsate = math.sin(RealTime() * 3) * 0.5 + 0.5
					draw.SimpleText("REQUIRED LEVEL: "..weapons_table[i].level, "ImpactSmall", w / 2, 15, 
					               Color(255, 165 * pulsate, 0, 255 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					local pulsate = math.sin(RealTime() * 2) * 0.5 + 0.5
					draw.SimpleText("ALREADY TAKEN", "ImpactSmall", w / 2, 15, 
					               Color(255, 165 * pulsate, 0, 255 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				draw.SimpleText(weapons_table[i].name, "ImpactSmall", w / 2, h / 2, 
				               Color(255, 255, 255, 150 * self.alphaAnim), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		BREACH.Demote.Users.OnCursorEntered = function(self)
			self.CursorOnPanel = true
		end

		BREACH.Demote.Users.OnCursorExited = function(self)
			self.CursorOnPanel = false
		end

		BREACH.Demote.Users.DoClick = function(self)
			if locked then return end

			
			self.clickProgress = 1
			
			net.Start("SelectSCPClientside")
			net.WriteString(weapons_table[i].class)
			net.SendToServer()

			
			timer.Simple(0.15, function()
				if IsValid(BREACH.Demote.MainPanel) then
					BREACH.Demote.MainPanel:CloseMenu()
				end
			end)
			
			
			timer.Simple(1, function()
				if LocalPlayer():GetRoleName() == "SCP062DE" then
					SCP062de_Menu()
				end
			end)
		end
	end
end

net.Receive("SCPSelect_Menu", function(len)
	local tab = net.ReadTable()
	timer.Simple(4,function()
		Select_SCP_Menu(tab)
	end)
end)

net.Receive( "ShowText", function( len )
	local com = net.ReadString()
	if com == "vote_fail" then
		LocalPlayer():PrintMessage( HUD_PRINTTALK, clang.votefail )
	elseif	com == "text_punish" then
		local name = net.ReadString()
		LocalPlayer():PrintMessage( HUD_PRINTTALK, string.format( clang.votepunish, name ) )
		LocalPlayer():PrintMessage( HUD_PRINTTALK, clang.voterules )
	elseif	com == "text_punish_end" then
		local data = net.ReadTable()
		local result
		if data.punish then 
			result = clang.punish
		else 
			result = clang.forgive
		end
		local vp, vf = data.punishvotes, data.forgivevotes
		//print( vp, vf )
		LocalPlayer():PrintMessage( HUD_PRINTTALK, string.format( clang.voteresult, data.punished, result ) )
		LocalPlayer():PrintMessage( HUD_PRINTTALK, string.format( clang.votes, vp + vf, vp, vf ) )
	elseif com == "text_punish_cancel" then
		LocalPlayer():PrintMessage( HUD_PRINTTALK, clang.votecancel )
	end
end)

    


//kasanov side


local PLAYER = FindMetaTable('Player')


function PLAYER:HasPremiumSub()


    return self:GetNWInt("premium_sub", 0) > os.time()


end


if CLIENT then

    surface.CreateFont("RobotVision_Text", {
		font = "Hitmarker Normal",
        size = 15,
			extended = true,
		scanlines = 3,
        weight = 300
    })
    
    surface.CreateFont("RobotVision_Alert", {
		font = "Hitmarker Normal",
        size = 18,
			extended = true,
		scanlines = 3,
        weight = 400
    })

    local XRAY_DISTANCE = 1000
    local SCAN_RADIUS = 1500

    local colors = {
        biological = Color(255, 50, 50, 200),  
        weapon     = Color(218, 165, 32, 200), 
        interact   = Color(50, 255, 200, 200), 
        deceased   = Color(150, 150, 150, 200),
        objective  = Color(255, 0, 255, 255)   
    }

    local function DrawTargetCorners(x, y, w, h, col, thickness)
        surface.SetDrawColor(col)
        local l = math.Clamp(math.min(w, h) / 4, 5, 30)
        local t = thickness or 2

        surface.DrawRect(x, y, l, t)
        surface.DrawRect(x, y, t, l)
        surface.DrawRect(x + w - l, y, l, t)
        surface.DrawRect(x + w - t, y, t, l)
        surface.DrawRect(x, y + h - t, l, t)
        surface.DrawRect(x, y + h - l, t, l)
        surface.DrawRect(x + w - l, y + h - t, l, t)
        surface.DrawRect(x + w - t, y + h - l, t, l)
    end

    local function GetEntityData(ent)
        if not IsValid(ent) then return nil end
        if ent:GetNoDraw() or ent:IsEffectActive(EF_NODRAW) then return nil end 

        local cls = ent:GetClass()

        if cls == "item_scp_079" then
            return "ГЛАВНАЯ ЦЕЛЬ", colors.objective, "ИЗВЛЕЧЬ ЛЮБОЙ ЦЕНОЙ", true
        end

        if ent:IsPlayer() and ent:Alive() and ent ~= LocalPlayer() then
            return "БИО-ЦЕЛЬ", colors.biological, " ", false
        end

        if ent:IsWeapon() and not IsValid(ent:GetOwner()) then
            local ammo = ent:Clip1()
            local addText = "meow"
            return "ВООРУЖЕНИЕ", colors.weapon, addText, false
        end

        if cls == "prop_ragdoll" then
            return "НЕЙТРАЛИЗОВАН", colors.deceased, "ЖИЗНЕННЫХ СИЛ: 0", false
        end

        if string.find(cls, "door") then
            return "ОБЪЕКТ: ДВЕРЬ", colors.interact, "ДОСТУП ВОЗМОЖЕН", false
        end

        if cls == "func_button" or cls == "gmod_button" then
            return "ИНТЕРФЕЙС", colors.interact, "КЛАВИША АКТИВАЦИИ", false
        end

        return nil
    end

    local TargetCache = {}
    local NextScan = 0

    hook.Add("HUDPaint", "RobotVision_HUD", function()
        local ply = LocalPlayer()
        
        if not IsValid(ply) or ply:GTeam() ~= TEAM_AR or not ply:Alive() then return end

        local eyePos = ply:EyePos()
        local aimVec = ply:GetAimVector()



        if CurTime() > NextScan then
            NextScan = CurTime() + 0.5
            TargetCache = {}
            for _, ent in ipairs(ents.FindInSphere(eyePos, SCAN_RADIUS)) do
                local name, col, add, isObj = GetEntityData(ent)
                if name then 
                    table.insert(TargetCache, {ent = ent, name = name, col = col, add = add, isObj = isObj})
                end
            end
        end

        for _, data in ipairs(TargetCache) do
            local ent = data.ent
            if not IsValid(ent) then continue end

            local center = ent:WorldSpaceCenter()
            local distReal = eyePos:Distance(center)

            local dirToEnt = (center - eyePos):GetNormalized()
            if aimVec:Dot(dirToEnt) < 0.3 then continue end

            local isBehindWall = false
            local tr = util.TraceLine({
                start = eyePos,
                endpos = center,
                filter = {ply, ent},
                mask = MASK_OPAQUE
            })
            
            if tr.Hit then 
                isBehindWall = true 
            end

            if isBehindWall then
                if data.isObj and distReal <= XRAY_DISTANCE then
                else
                    continue
                end
            end

            local min, max = ent:OBBMins(), ent:OBBMaxs()
            local corners = {
                Vector(min.x, min.y, min.z), Vector(min.x, min.y, max.z),
                Vector(min.x, max.y, min.z), Vector(min.x, max.y, max.z),
                Vector(max.x, min.y, min.z), Vector(max.x, min.y, max.z),
                Vector(max.x, max.y, min.z), Vector(max.x, max.y, max.z)
            }

            local minX, minY, maxX, maxY = ScrW(), ScrH(), 0, 0
            local onScreen = false

            for _, corner in ipairs(corners) do
                local scr = ent:LocalToWorld(corner):ToScreen()
                if scr.visible then onScreen = true end
                minX = math.min(minX, scr.x)
                minY = math.min(minY, scr.y)
                maxX = math.max(maxX, scr.x)
                maxY = math.max(maxY, scr.y)
            end

            if not onScreen or minX < 0 or maxX > ScrW() or minY < 0 or maxY > ScrH() then continue end

            local w = maxX - minX
            local h = maxY - minY
            if w > ScrW() * 0.8 or h > ScrH() * 0.8 then continue end

            local drawCol = Color(data.col.r, data.col.g, data.col.b, data.col.a)
            local thickness = 2

            if data.isObj then
                local pulse = math.abs(math.sin(CurTime() * 8))
                drawCol.a = 100 + 155 * pulse
                thickness = 4

                if isBehindWall then
                    drawCol.a = 50 + 100 * pulse
                    drawCol.g = 100
                end

                local cx, cy = minX + w/2, minY + h/2
                surface.SetDrawColor(drawCol)
                surface.DrawLine(cx - 10, cy, cx + 10, cy)
                surface.DrawLine(cx, cy - 10, cx, cy + 10)
            end

            DrawTargetCorners(minX, minY, w, h, drawCol, thickness)

            local distMeters = math.Round(distReal * 0.01905, 1)
            
            local lineStartX = minX
            local lineStartY = minY + 10
            local textX = minX - 15
            local textY = minY - 15

            surface.SetDrawColor(drawCol)
            surface.DrawLine(lineStartX, lineStartY, minX - 10, lineStartY)
            surface.DrawLine(minX - 10, lineStartY, textX, textY + 20)

            local bgH = data.isObj and 60 or 45
            local bgW = data.isObj and 180 or 140
            
            surface.SetDrawColor(0, 0, 0, data.isObj and 220 or 150)
            surface.DrawRect(textX - bgW - 5, textY - 2, bgW + 10, bgH)

            local font1 = data.isObj and "RobotVision_Alert" or "RobotVision_Text"
            local font2 = "RobotVision_Text"

            draw.SimpleText("[" .. data.name .. "]", font1, textX - 5, textY, drawCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            
            local distText = "ДИСТ: " .. distMeters .. "m"
            if isBehindWall and data.isObj then
                distText = distText .. " [ПРЕГРАДА]"
            end
            
            draw.SimpleText(distText, font2, textX - 5, textY + 16, drawCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText(data.add, font2, textX - 5, textY + 30, drawCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            
            if data.isObj then
                draw.SimpleText("!!! ПРИОРИТЕТ !!!", font2, textX - 5, textY + 44, drawCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
        end
    end)
end































