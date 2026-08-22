local surface = surface
local Material = Material
local draw = draw
local RunConsoleCommand = RunConsoleCommand
local tonumber = tonumber
local tostring = tostring
local CurTime = CurTime
local SysTime = SysTime
local Entity = Entity
local table = table
local pairs = pairs
local ipairs = ipairs
local ScrW = ScrW
local ScrH = ScrH
local concommand = concommand
local timer = timer
local hook = hook
local math = math
local vgui = vgui
local net = net






local rust_bg       = Color(20, 19, 18, 245)
local rust_panel    = Color(15, 14, 13, 250)
local rust_row      = Color(35, 33, 31, 255)
local rust_outline  = Color(255, 255, 255, 15)
local rust_outline_hov = Color(255, 255, 255, 40)
local rust_green    = Color(112, 126, 73)
local rust_red      = Color(188, 64, 43)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_text_dim = Color(140, 140, 140)

local rarity_omg    = Color(255, 180, 0, 255)
local rarity_scp    = Color(255, 50, 50, 255)

local function DrawTacticalHUD(pw, ph, xOff, yOff, health, maxHealth, stamina, maxStamina, roleName, roleCol)
    local barMaxWidth = math.Round(pw / 9.35)
    local barH = math.Round(ph / 50)
    local xPos = math.Round(pw / 128 + xOff)
    local yPos = math.Round(ph / 1.03 + yOff)
    local ply = LocalPlayer()
    
    if ply:GTeam() != TEAM_AR then
        local hpFraction = math.Clamp(health / maxHealth, 0, 1)

        if ply.organism then
            local org = ply.organism
            
            local fBlood = math.Clamp(((org.blood or 5000) - 2500) / 2500, 0, 1)
            local fPain  = math.Clamp(1 - ((org.pain or 0) / 100), 0, 1)
            local fBrain = math.Clamp(1 - ((org.brain or 0) / 0.7), 0, 1)
            local fO2    = org.o2 and math.Clamp((org.o2[1] or 30) / 30, 0, 1) or 1
            local fShock = math.Clamp(1 - ((org.shock or 0) / 100), 0, 1)

            hpFraction = math.min(fBlood, fPain, fBrain, fO2, fShock)
        end

        local hpBarWidth = math.Round(barMaxWidth * hpFraction)
        
        surface.SetDrawColor(15, 15, 15, 200)
        surface.DrawRect(xPos, yPos, barMaxWidth, barH)
        
        surface.SetDrawColor(roleCol.r, roleCol.g, roleCol.b, 200)
        surface.DrawRect(xPos, yPos, hpBarWidth, barH)
        
        surface.SetDrawColor(0, 0, 0, 150)
        for i = 1, 3 do surface.DrawRect(math.Round(xPos + (barMaxWidth / 4) * i - 1), yPos, 2, barH) end
        
        surface.SetDrawColor(rust_outline or Color(255, 255, 255, 10))
        surface.DrawOutlinedRect(xPos, yPos, barMaxWidth, barH, 1)
        
        local txtRole = GetLangRole and GetLangRole(roleName) or roleName
        draw.SimpleText(string.upper(txtRole), "ImpactSmall2n", math.Round(pw / 16 + xOff), math.Round(ph / 1.02 + yOff), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        local txtRole = GetLangRole and GetLangRole(roleName) or roleName
        draw.SimpleText(string.upper(txtRole), "ImpactSmallest", math.Round(pw / 16 + xOff), math.Round(ph / 1.025 + yOff), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    if stamina and ply:GTeam() != TEAM_AR then
        local stamFraction = math.Clamp(stamina / maxStamina, 0, 1)
        
        if ply.organism and ply.organism.stamina then
            local orgStamina = ply.organism.stamina[1] or 180
            local orgMaxStamina = ply.organism.stamina.max or 180
            stamFraction = math.Clamp(orgStamina / orgMaxStamina, 0, 1)
        end

        local stamBarWidth = math.Round(barMaxWidth * stamFraction)
        local stamY = math.Round(ph / 1.043 + yOff)
        local stamX = math.Round(pw / 128 + xOff)
        local stamH = math.Round(ph / 128)
        
        surface.SetDrawColor(15, 15, 15, 200)
        surface.DrawRect(stamX, stamY, barMaxWidth, stamH)
        surface.SetDrawColor(200, 200, 200, 200)
        surface.DrawRect(stamX, stamY, stamBarWidth, stamH)
        
        for i = 1, 3 do surface.DrawRect(math.Round(stamX + (barMaxWidth / 4) * i - 1), stamY, 2, stamH) end
        surface.SetDrawColor(rust_outline or Color(255, 255, 255, 10))
        surface.DrawOutlinedRect(stamX, stamY, barMaxWidth, stamH, 1)
    end
end

local blur = Material("pp/blurscreen")
function draw.Blur_New(_x, _y, _w, _h, panel, amount, heavyness)
	local x, y = panel:LocalToScreen( 0, 0 )
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial(blur)
	local sx, sy = panel:LocalToScreen( _x, _y )
	local sex, syx = panel:LocalToScreen( _x+_w, _y+_h )
	for i = 1, ( heavyness or 3 ) do
	  	blur:SetFloat( "$blur", ( i / 3 ) * ( amount or 6 ) )
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

surface.CreateFont("Waitingmini", {font = "Hitmarker Normal", size = 40, extended = true, weight = 500, outline = true})
surface.CreateFont("Waiting", {font = "Hitmarker Normal", size = 70, extended = true, weight = 500, outline = true})
surface.CreateFont("ImpactBig4", {font = "Hitmarker Normal", size = 150, extended = true, scanlines = 3, weight = 200})
surface.CreateFont("ImpactBig3", {font = "Hitmarker Normal", size = 100, extended = true, scanlines = 3, weight = 200})
surface.CreateFont("ImpactBig3m", {font = "Hitmarker Normal", size = 90, extended = true, scanlines = 3, weight = 200})
surface.CreateFont("ImpactBig2", {font = "Hitmarker Normal", size = 70, extended = true, scanlines = 3, weight = 200})
surface.CreateFont("ImpactBig", {font = "Hitmarker Normal", size = 45, extended = true, scanlines = 3, weight = 700})
surface.CreateFont("ImpactSmall42", {font = "Hitmarker Normal", size = 35, extended = true, scanlines = 3, weight = 700})
surface.CreateFont("ImpactSmall", {font = "Hitmarker Normal", size = 30, extended = true, scanlines = 3, weight = 700})
surface.CreateFont("ImpactSmallest", {font = "Hitmarker Normal", size = 20, extended = true, scanlines = 3, weight = 700})
surface.CreateFont("ImpactSmall2", {font = "Hitmarker Normal", size = 15, extended = true, scanlines = 3, weight = 700})
surface.CreateFont("ImpactSmall2n", {font = "Hitmarker Normal", size = 15, extended = true, scanlines = 0, weight = 500})
surface.CreateFont("ImpactSmall22", {font = "Hitmarker Normal", size = 5, extended = true, scanlines = 3, weight = 300})
surface.CreateFont( "RadioFont", {font = "Hitmarker Normal", extended = true, size = 26, weight = 7000, blursize = 0, scanlines = 2, antialias = true})
surface.CreateFont( "RadioFont_mini", {font = "Hitmarker Normal", extended = true, size = 11, weight = 100, blursize = 0, scanlines = 2, antialias = true})
surface.CreateFont("new_spec_2", {font = "Hitmarker Normal", size = 30, extended = true, scanlines = 0, weight = 700})
surface.CreateFont("MM_Desc", { font = "Hitmarker Normal", size = ScreenScale(4), extended = true, weight = 400 })
surface.CreateFont("MM_Form", { font = "Hitmarker Normal", size = ScreenScale(7), extended = true, weight = 300 })




local MatCache = {}
local function GetCachedMaterial(path)
    if not path or path == "" then return nil end
    if not MatCache[path] then MatCache[path] = Material(path, "smooth") end
    return MatCache[path]
end

local WepCache = {}
local function GetCachedWeapon(class)
    if not class then return nil end
    if WepCache[class] == nil then
        WepCache[class] = weapons.GetStored(class) or false
    end
    return WepCache[class] ~= false and WepCache[class] or nil
end

local matMissing = GetCachedMaterial("nextoren/gui/new_icons/missing.png")




local function DrawTacticalBox(x, y, w, h, hoverProgress, isSelected, rarityColor)
    hoverProgress = hoverProgress or 0

    
    local bgR = Lerp(hoverProgress, rust_panel.r, rust_row.r)
    local bgG = Lerp(hoverProgress, rust_panel.g, rust_row.g)
    local bgB = Lerp(hoverProgress, rust_panel.b, rust_row.b)
    surface.SetDrawColor(bgR, bgG, bgB, 255)
    surface.DrawRect(x, y, w, h)
    
    
    if hoverProgress > 0 then
        surface.SetDrawColor(255, 255, 255, 5 * hoverProgress)
        surface.DrawRect(x, y, w, h)
    end

    
    local outClr = isSelected and rust_yellow or (hoverProgress > 0 and rust_outline_hov or rust_outline)
    surface.SetDrawColor(outClr.r, outClr.g, outClr.b, outClr.a)
    surface.DrawOutlinedRect(x, y, w, h, 1)

    
    local botClr = rarityColor or (isSelected and rust_yellow or nil)
    if botClr then
        surface.SetDrawColor(botClr.r, botClr.g, botClr.b, 255)
        surface.DrawRect(x, y + h - 2, w, 2)
    end

    
    if hoverProgress > 0 or isSelected then
        local clen = 4 + (4 * hoverProgress) 
        local cthick = 2
        local coff = isSelected and 0 or (2 * (1 - hoverProgress)) 

        surface.SetDrawColor(outClr.r, outClr.g, outClr.b, 255)
        
        surface.DrawRect(x - coff, y - coff, clen, cthick)
        surface.DrawRect(x - coff, y - coff, cthick, clen)
        
        surface.DrawRect(x + w - clen + coff, y - coff, clen, cthick)
        surface.DrawRect(x + w - cthick + coff, y - coff, cthick, clen)
        
        surface.DrawRect(x - coff, y + h - cthick + coff, clen, cthick)
        surface.DrawRect(x - coff, y + h - clen + coff, cthick, clen)
        
        surface.DrawRect(x + w - clen + coff, y + h - cthick + coff, clen, cthick)
        surface.DrawRect(x + w - cthick + coff, y + h - clen + coff, cthick, clen)
    end
end

local function DrawFlatText(text, font, x, y, color, alignX, alignY)
    draw.DrawText(text, font, x, y, color, alignX, alignY)
end

local function GetSlotPos(index)
    local w, h = ScrW(), ScrH()
    local iconSize = math.Round(h / 16)
    local startX = math.Round(w / 128)
    local startY = math.Round(h / 1.12)
    local spacing = math.Round(w / 28)

    if index <= 3 then
        return startX + (index - 1) * spacing, startY, iconSize
    else
        local gap = math.Round(w * 0.02)
        return startX + (3 * spacing) + gap + (index - 4) * spacing, startY, iconSize
    end
end




local inv_oper_data = inv_oper_data or {}
local hudButtonAnimations = hudButtonAnimations or {}
local buttonAnimations = buttonAnimations or {} 
LocalPlayer().operdatainv = LocalPlayer().operdatainv or {}
local LocalInvVersion = -1 

timer.Create("CheckInventoryDesync_Client", 1, 0, function()
    local client = LocalPlayer()
    if not IsValid(client) then return end

    local srvVersion = client:GetNWInt("InvVersion", 0)
    
    if srvVersion ~= LocalInvVersion then
        LocalInvVersion = srvVersion
        net.Start("AskInventoryData")
        net.SendToServer()
    end
end)

Breach = Breach or {}
BREACH.AmmoTranslation = {
    ["AR2"] = "l:machinegun_ammo", ["GRU"] = "l:gru_ammo", ["SMG1"] = "l:smg_ammo",
    ["Pistol"] = "l:pistol_ammo", ["Revolver"] = "l:revolver_ammo", ["GOC"] = "l:goc_ammo",
    ["Shotgun"] = "l:shotgun_ammo", ["Sniper"] = "l:sniper_ammo",
}

function ReadInventoryData(ply)
    if LocalPlayer().operdatainv then NewLegacyInventoryFrame(LocalPlayer().operdatainv) else NewLegacyInventoryFrame({ Items = {} }) end
    net.Start("AskInventoryData") net.SendToServer()
end

local function TakeItem(id)
    local client = LocalPlayer()
    if (client.NextInvAction or 0) > CurTime() then return end
    
    local activeWep = client:GetActiveWeapon()
    if IsValid(activeWep) and activeWep.dt and activeWep.dt.PinPulled then return end
    
    client.NextInvAction = CurTime() + 0.3
    net.Start("InventoryTakeItem") net.WriteInt(id,8) net.SendToServer()
    client:SelectWeapon("br_holster")
end

local function TakeVictimItem(id) 
    net.Start("InventoryTakeVictimItem") net.WriteInt(id,8) net.SendToServer() 
    --ReadInventoryData() 
end
local function DropItem(id) 
    net.Start("InventoryDropItem") net.WriteInt(id,8) net.SendToServer() 
end

local dragData = {
    handledByButton = false, isDragging = false, startIndex = nil, itemData = nil,
    dragIcon = nil, dragTimerName = nil, mousePressed = false
}

function SwapItemsLocally(oldIndex, newIndex)
    local data = inv_oper_data["Items"]
    if not data then return end
    data[oldIndex], data[newIndex] = data[newIndex], data[oldIndex]
    if IsValid(Breach.InventoryMainFrame) then
        local btnOld = Breach.InventoryMainFrame["InventoryButton_" .. oldIndex]
        local btnNew = Breach.InventoryMainFrame["InventoryButton_" .. newIndex]
        if btnOld then btnOld.itemData = data[oldIndex] or {} end
        if btnNew then btnNew.itemData = data[newIndex] or {} end
    end
end




function NewLegacyInventoryFrame(data, loot_data)
    local client = LocalPlayer()
    if not IsValid(client) or IsValid(MainMogFrame) then return end

    local w, h = ScrW(), ScrH()
    local oldOpenTime = SysTime()
    local oldInspectedItem = nil
    
    if IsValid(Breach.InventoryMainFrame) then 
        oldOpenTime = Breach.InventoryMainFrame.OpenTime or SysTime()
        oldInspectedItem = Breach.InventoryMainFrame.InspectedItem
        Breach.InventoryMainFrame:Remove() 
    end

    gui.EnableScreenClicker(true)

    Breach.InventoryMainFrame = vgui.Create("DPanel")
    Breach.InventoryMainFrame:SetSize(w, h)
    Breach.InventoryMainFrame:SetPos(0, 0)
    Breach.InventoryMainFrame.OpenTime = oldOpenTime
    Breach.InventoryMainFrame.Closing = false
    Breach.InventoryMainFrame.InspectedItem = oldInspectedItem 

    Breach.InventoryMainFrame.Think = function(self)
        local fade
        local animSpeed = 15
        
        if self.Closing then
            fade = math.Clamp(1 - (SysTime() - self.CloseTime) * animSpeed, 0, 1)
            if fade <= 0 then self:Remove() return end
        else
            fade = math.Clamp((SysTime() - self.OpenTime) * animSpeed, 0, 1)
        end
        
        self.fade = fade 
        local currentAlpha = 255 * fade
        
        local slideY = (1 - fade) * 15
        self.OffsetY = slideY
        
        if IsValid(self.Survivor) then self.Survivor:SetAlpha(currentAlpha) end
        if IsValid(self.inspectArea) then self.inspectArea:SetAlpha(currentAlpha) end
        if IsValid(self.equipPanel) then self.equipPanel:SetAlpha(currentAlpha) end
        if IsValid(self.radio) then self.radio:SetAlpha(currentAlpha) end
        if IsValid(self.loot) then self.loot:SetAlpha(currentAlpha) end
        
        if not input.IsMouseDown(MOUSE_LEFT) and (dragData.mousePressed or dragData.isDragging) then
            timer.Simple(0, function()
                if not dragData.handledByButton and dragData.isDragging then
                    local dropAllowed = true
                    if dragData.startIndex then
                        local itemData = inv_oper_data["Items"] and inv_oper_data["Items"][dragData.startIndex]
                        if itemData and itemData.class then
                            local wepInfo = GetCachedWeapon(itemData.class)
                            if wepInfo and (wepInfo.droppable == false or wepInfo.UnDroppable) then
                                dropAllowed = false
                            end
                        end
                    end

                    if dropAllowed and dragData.startIndex then 
                        DropItem(dragData.startIndex) 
                    end
                    
                    dragData.isDragging = false 
                    dragData.startIndex = nil 
                    dragData.dragIcon = nil 
                    if IsValid(Breach.InventoryMainFrame) and IsValid(Breach.InventoryMainFrame.dragPanel) then 
                        Breach.InventoryMainFrame.dragPanel:SetVisible(false) 
                    end
                end
                
                dragData.handledByButton = false
                dragData.mousePressed = false
                if dragData.dragTimerName and timer.Exists(dragData.dragTimerName) then 
                    timer.Remove(dragData.dragTimerName) 
                    dragData.dragTimerName = nil 
                end
            end)
        end
    end

    Breach.InventoryMainFrame.Paint = function(self, pw, ph)
        local fade = self.fade or 0
        if DrawBlurPanel and fade > 0.1 then DrawBlurPanel(self) end
        
        surface.SetDrawColor(0, 0, 0, 190 * fade)
        surface.DrawRect(0, 0, pw, ph)
    end

    local rx, ry, _ = GetSlotPos(1)
    local contentHeight = ry - (h * 0.15) - (h * 0.1)

    Breach.InventoryMainFrame.inspectArea = vgui.Create("DPanel", Breach.InventoryMainFrame)
    local inspectArea = Breach.InventoryMainFrame.inspectArea
    inspectArea:SetPos(rx + w*0.18 + w*0.01, h * 0.68)
    inspectArea:SetSize(w * 0.258, contentHeight * 0.298)
    inspectArea.Cache = {}

    inspectArea.Paint = function(self, pw, ph)
        local yOff = Breach.InventoryMainFrame.OffsetY or 0
        local id = Breach.InventoryMainFrame.InspectedItem
        local btn = id and Breach.InventoryMainFrame["InventoryButton_" .. id]
        local item = btn and btn.itemData or nil

        if not item or table.IsEmpty(item) then return end

        if self.LastItemRef ~= item then
            self.LastItemRef = item
            local cache = self.Cache
            table.Empty(cache)
            
            cache.class = item.class
            cache.wepData = GetCachedWeapon(item.class)
            
            cache.rarityColor = rust_text_dim
            cache.rarityText = L("l:inv_std_item")
            
            if cache.wepData then
                if cache.wepData.red == "OMG" then 
                    cache.rarityColor = rarity_omg 
                    cache.rarityText = L("l:inv_uniq_item")
                elseif cache.wepData.red == "SCP" then 
                    cache.rarityColor = rarity_scp 
                    cache.rarityText = L("l:inv_anomaly") 
                end
            end

            cache.icon = item.icon and GetCachedMaterial(item.icon) or (cache.wepData and cache.wepData.InvIcon) or matMissing
            cache.itemName = string.upper((cache.wepData and cache.wepData.PrintName) or GetLangWeapon(item.class) or L("l:unknown"))
            
            cache.isDrink = item.drink ~= nil
            if cache.isDrink then
                cache.drinkName = string.upper(item.drink)
            else
                local desc = (cache.wepData and cache.wepData.Desc) or (GetLangWeaponDesc and GetLangWeaponDesc(item.class)) or L("l:inv_no_data")
                cache.lines = {}
                local line = ""
                for word in desc:gmatch("%S+") do
                    local testLine = line .. (line == "" and "" or " ") .. word
                    if surface.GetTextSize(testLine) > pw * 0.85 then
                        table.insert(cache.lines, line)
                        line = word
                    else 
                        line = testLine 
                    end
                end
                table.insert(cache.lines, line)
            end
        end

        local cache = self.Cache
        
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
        surface.DrawRect(0, yOff, pw, ph)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, yOff, pw, ph, 1)
        
        surface.SetDrawColor(cache.rarityColor)
        surface.DrawRect(0, yOff, 3, ph) 

        surface.SetDrawColor(rust_outline)
        surface.DrawLine(pw * 0.45, yOff, pw * 0.45, yOff + ph)

        if cache.icon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(cache.icon)
            local isize = ph * 0.5
            surface.DrawTexturedRectUV(pw * 0.225 - isize/2, yOff + ph/2 - isize/2, isize, isize, 0.05, 0.05, 0.95, 0.95)
        end

        local tx = pw * 0.48
        DrawFlatText(cache.rarityText, "MogM_6", tx, yOff + ph * 0.08, cache.rarityColor, TEXT_ALIGN_LEFT)
        DrawFlatText(cache.itemName, "MM_Form", tx, yOff + ph * 0.14, rust_text, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(rust_outline)
        surface.DrawLine(tx, yOff + ph * 0.25, pw - 20, yOff + ph * 0.25)

        if cache.isDrink then
            DrawFlatText(L("l:inv_content"), "MogM_5", tx, yOff + ph * 0.3, rust_text_dim, TEXT_ALIGN_LEFT)
            DrawFlatText(cache.drinkName, "MogM_6", tx, yOff + ph * 0.35, rarity_omg, TEXT_ALIGN_LEFT)
        else
            for i, textLine in ipairs(cache.lines) do
                DrawFlatText(textLine, "MogM_4", tx, yOff + ph * 0.3 + (i-1)*20, rust_text_dim, TEXT_ALIGN_LEFT)
            end
        end
    end

    if client:IIHasWeapon("item_radio") then
        Breach.InventoryMainFrame.radio = vgui.Create("DPanel", Breach.InventoryMainFrame)
        local radio = Breach.InventoryMainFrame.radio
        radio:SetPos(rx, ry - (h * 0.08))
        radio:SetSize(w * 0.18, h * 0.06)

        radio.Paint = function(self, pw, ph)
            local yOff = Breach.InventoryMainFrame.OffsetY or 0
            local radioEnabled = client:GetNWBool("radio_enbl", false)
            local radioFrequency = client:GetNWFloat("RadioChannel", 0) > 0 and client:GetNWFloat("RadioChannel", 0) or client:GetNWFloat("radio_chanel")

            surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
            surface.DrawRect(0, yOff, pw, ph)
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, yOff, pw, ph, 1)

            local pulse = radioEnabled and (math.sin(SysTime() * 8) * 0.5 + 0.5) or 0
            surface.SetDrawColor(radioEnabled and rust_green.r or rust_red.r, radioEnabled and rust_green.g or rust_red.g, radioEnabled and rust_green.b or rust_red.b, 100 + 155 * pulse)
            surface.DrawRect(10, yOff + 8, 8, 8)

            DrawFlatText(L("l:inv_comms"), "MM_Exp", 25, yOff + 5, rust_text, TEXT_ALIGN_LEFT)
            
            if not radioEnabled then 
                DrawFlatText(L("l:inv_offline"), "MM_Exp", pw - 10, yOff + 5, rust_red, TEXT_ALIGN_RIGHT)
            else 
                DrawFlatText(math.Round(radioFrequency,1) .. " MHZ", "MM_Exp", pw - 10, yOff + 5, rust_green, TEXT_ALIGN_RIGHT) 
            end
        end

        radio.EnableCheckbox = vgui.Create("DCheckBox", radio)
        radio.EnableCheckbox:SetPos(10, h * 0.03)
        radio.EnableCheckbox:SetSize(16, 16)
        radio.EnableCheckbox:SetChecked(client:GetNWBool("radio_enbl", false))
        radio.EnableCheckbox.OnChange = function() 
            net.Start("Breach:SENDRadio") 
            net.SendToServer() 
        end

        local presetFrequencies = {{0,"C1"},{1,"C2"},{2,"C3"},{3,"C4"},{4,"C5"},{5,"C6"},{6,"C7"}}
        for i, preset in ipairs(presetFrequencies) do
            local btnW = (w * 0.18 - 40) / 8
            
            local presetBtn = vgui.Create("DButton", radio)
            presetBtn:SetText("")
            presetBtn:SetPos(35 + (i-1) * (btnW + 2), h * 0.03)
            presetBtn:SetSize(btnW, 16)
            
            presetBtn.Think = function(self)
                self.PressMult = Lerp(FrameTime() * 15, self.PressMult or 0, self:IsDown() and 1 or 0)
                self.HoverMult = Lerp(FrameTime() * 15, self.HoverMult or 0, self:IsHovered() and 1 or 0)
            end
            presetBtn.DoClick = function()
                if not client:GetNWBool("radio_enbl", false) then 
                    if RXSENDNotify then RXSENDNotify("l:turn_up_the_radio") end 
                    return 
                end
                net.Start("Breach:SENDRadioChanel") 
                net.WriteFloat(preset[1]) 
                net.SendToServer()
            end
            presetBtn.Paint = function(self, bw, bh)
                local yOff = Breach.InventoryMainFrame.OffsetY or 0
                local radioEnabled = client:GetNWBool("radio_enbl", false)
                local radioFrequency = client:GetNWFloat("RadioChannel", 0) > 0 and client:GetNWFloat("RadioChannel", 0) or client:GetNWFloat("radio_chanel")
                local isActive = (radioFrequency == preset[1] and radioEnabled)

                local scale = 1 - ((self.PressMult or 0) * 0.1)
                local drawW, drawH = bw * scale, bh * scale
                local offX, offY = (bw - drawW)/2, (bh - drawH)/2 + yOff

                DrawTacticalBox(offX, offY, drawW, drawH, self.HoverMult, isActive, isActive and rust_green or nil)
                DrawFlatText(preset[2], "MM_Desc", bw/2, offY + drawH/2 - 5, isActive and rust_green or rust_text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    local StatsOverlay = vgui.Create("DPanel", Breach.InventoryMainFrame)
    StatsOverlay:SetSize(w, h)
    StatsOverlay:SetPos(0, 0)
    StatsOverlay:SetMouseInputEnabled(false)

    StatsOverlay.Think = function(self)
        if not IsValid(client) then return end
        self.smoothHealth = Lerp(FrameTime() * 10, self.smoothHealth or client:Health(), client:Health())

        if client:GTeam() ~= TEAM_SCP then
            self.smoothStamina = Lerp(FrameTime() * 10, self.smoothStamina or (client.Stamina or 100), client.Stamina or 100)
        end
    end

    StatsOverlay.Paint = function(self, pw, ph)
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local healthFractionTarget = GetPlayerVitality(ply)
		local health = healthFractionTarget * 100 
        DrawTacticalHUD(
            ScrW(), ScrH(), 0, 0, 
            health, 
            100, 
            ply.organism.stamina[1] or 180,
            ply.organism.stamina.max or 180, 
            client:GetRoleName(), 
            gteams.GetColor(client:GTeam())
        )
    end

    Breach.InventoryMainFrame.Survivor = vgui.Create("DModelPanel", Breach.InventoryMainFrame)
    local surv = Breach.InventoryMainFrame.Survivor
    surv:SetPos(rx, h * 0.15)
    surv:SetSize(w * 0.18, contentHeight) 

    local oldPaint = surv.Paint

    surv.Paint = function(self, pw, ph)
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
        surface.DrawRect(0, 0, pw, ph)

        if oldPaint then
            oldPaint(self, pw, ph)
        end
    end

    surv.PaintOver = function(self, pw, ph)
        local yOff = Breach.InventoryMainFrame.OffsetY or 0
        self:SetPos(rx, h * 0.15 + yOff) 
        
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)

        DrawFlatText(client:GetNamesurvivor(), "MM_Exp", 10, 10, rust_text, TEXT_ALIGN_LEFT)
        
        surface.SetDrawColor(rust_outline)
        surface.DrawLine(10, 30, pw - 10, 30)
    end
    surv:SetModel(client:GetModel())
    surv.Entity:SetSkin(client:GetSkin())
    surv.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
    surv:SetFOV(25)
    local vec = Vector(0,0,-15)
    surv.Angles = Angle(0,50,0)
    surv.LayoutEntity = function(self, ent)
        ent:SetPos(vec) ent:SetAngles(self.Angles)
        if ent:GetCycle() == 1 then ent:SetCycle(0) end
        ent:SetCycle(math.Approach(ent:GetCycle(), 1, 0.00039172791875899))
    end
    surv.Entity:ManipulateBoneAngles(surv.Entity:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(5,0,0))
    surv.Entity:ManipulateBoneAngles(surv.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm"), Angle(-2,0,0))
    surv.Entity:ResetSequence(surv.Entity:LookupSequence("mpf_batonidle1"))
    for i = 0, client:GetNumBodyGroups() do surv.Entity:SetBodygroup(i, client:GetBodygroup(i)) end

    local gloves_bl_models = {"models/cultist/humans/class_d/shaky/class_d_bor_new.mdl", "models/cultist/humans/class_d/shaky/class_d_fat_new.mdl", "models/cultist/humans/class_d/class_d_cleaner.mdl", "models/cultist/humans/class_d/class_d_cleaner_female.mdl", "models/cultist/humans/sci/scientist_female.mdl"}
    if LEFACY_GLOVES_BOY and (LEFACY_GLOVES_BOY[client:SteamID64()] or LEFACY_GLOVES_MGE[client:SteamID64()] or client:IsPremium() or LEFACY_GLOVES_d_1[client:SteamID64()]) then
        for _, bonemerge in pairs(client:LookupBonemerges()) do
            if not IsValid(bonemerge) then continue end
            if bonemerge:GetModel() == "models/imperator/hands/skins/stanadart.mdl" then
                if client:GTeam() ~= TEAM_SPEC and client:GTeam() ~= TEAM_SCP and client:GTeam() ~= TEAM_ARENA and client:GTeam() ~= TEAM_NAZI and client:GTeam() ~= TEAM_AMERICA and client:GTeam() ~= TEAM_RESISTANCE and client:GTeam() ~= TEAM_COMBINE and client:GTeam() ~= TEAM_AR and client:GTeam() ~= TEAM_ALPHA1 and not table.HasValue(gloves_bl_models,client:GetModel()) then 
                    local have_gloves = false
                    for k1,v1 in pairs(surv.Entity:GetMaterials()) do if v1 == "models/weapons/c_arms_combine/c_arms_combinesoldier_hands" then have_gloves = true end end
                    for k1,v1 in pairs(surv.Entity:GetMaterials()) do
                        if v1 == "models/weapons/c_arms_combine/c_arms_combinesoldier_hands" or v1 == "models/all_scp_models/class_d/arms" or v1 == "models/all_scp_models/class_d/arms_b" or v1 == "models/all_scp_models/shared/f_hands/f_hands_black" or (v1 == "models/all_scp_models/shared/f_hands/f_hands_white" and not have_gloves) or v1 == "models/all_scp_models/sci/sci_hands" or v1 == "models/all_scp_models/shared/f_hands/f_hands_gloves" then
                            surv.Entity:SetSubMaterial(k1 - 1,"models/imperator/female/no_draw")
                        end
                    end
                end
            end
        end
    end

    for _, bonemerge in pairs(client:LookupBonemerges()) do
        if not IsValid(bonemerge) then continue end
        local head
        if CORRUPTED_HEADS and CORRUPTED_HEADS[bonemerge:GetModel()] then head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(1), bonemerge:GetInvisible(), bonemerge:GetSkin(), Color(255,255,255))
        elseif bonemerge:GetModel():find('/hair/') then head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin(), string.ToColor(client:GetNWString("HairColor")))
        else head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin(), Color(255,255,255)) end
        
        if IsValid(head) then head:SetRenderMode(RENDERMODE_TRANSALPHA) end
        if bonemerge:GetModel():find('male_head') then surv.headply = bonemerge surv.headpanel = head end
        for i = 0, 3 do head:SetBodygroup(i, bonemerge:GetBodygroup(i)) end
    end

    Breach.InventoryMainFrame.equipPanel = vgui.Create("DPanel", Breach.InventoryMainFrame)
    local equipPanel = Breach.InventoryMainFrame.equipPanel
    equipPanel:SetPos(rx + w*0.18 + w*0.01, h * 0.15)
    equipPanel:SetSize(w * 0.16, contentHeight*0.8)

    equipPanel.Paint = function(self, pw, ph)
        local yOff = Breach.InventoryMainFrame.OffsetY or 0
        self:SetPos(rx + w*0.18 + w*0.01, h * 0.15 + yOff)
        
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
        surface.DrawRect(0, 0, pw, ph)
        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)

        DrawFlatText(L("l:inv_equip"), "MM_Exp", 10, 10, rust_text, TEXT_ALIGN_LEFT)
        surface.DrawLine(10, 30, pw-10, 30)
    end

    local equipScroll = vgui.Create("DScrollPanel", equipPanel)
    equipScroll:Dock(FILL) equipScroll:DockMargin(5, 35, 5, 5)
    local sbarEq = equipScroll:GetVBar()
    function sbarEq:Paint(w,h) surface.SetDrawColor(10,10,10,200) surface.DrawRect(w/2-2, 0, 4, h) end 
    function sbarEq.btnUp:Paint() end 
    function sbarEq.btnDown:Paint() end 
    function sbarEq.btnGrip:Paint(gw,gh) surface.SetDrawColor(rust_yellow) surface.DrawRect(gw/2-2, 0, 4, gh) end
    Breach.InventoryMainFrame.RebuildEquip = function()
        equipScroll:Clear()

        local function CreateEquipButton(id, title, func, isArmor, isEffect)
            local btn = vgui.Create("DButton", equipScroll)
            btn:SetText(" ") btn:Dock(TOP) btn:SetSize(0, h * 0.05) btn:DockMargin(0, 0, 0, 5)
            
            local btnMat = isEffect and GetCachedMaterial(id) or nil
            
            btn.Think = function(self) 
                self.PressMult = Lerp(FrameTime() * 15, self.PressMult or 0, self:IsDown() and 1 or 0) 
                self.HoverMult = Lerp(FrameTime() * 15, self.HoverMult or 0, self:IsHovered() and 1 or 0)
            end
            btn.DoClick = func btn.DoRightClick = func
            btn.Paint = function(self, bw, bh)
                local scale = 1 - ((self.PressMult or 0) * 0.05)
                local drawW, drawH = bw * scale, bh * scale
                local offX, offY = (bw - drawW)/2, (bh - drawH)/2

                DrawTacticalBox(offX, offY, drawW, drawH, self.HoverMult, false, nil)
                
                if isArmor then
                    local entT = scripted_ents.GetStored(id)
                    if entT and entT.t then
                        surface.SetDrawColor(255,255,255) 
                        surface.SetMaterial(entT.t.InvIcon or GetCachedMaterial("chemer.png")) 
                        surface.DrawTexturedRectUV(offX + 5, offY + 5, drawH-10, drawH-10, 0.06, 0.06, 0.94, 0.94)
                        DrawFlatText(string.upper(L(entT.t.PrintName)), "MM_Exp", offX + drawH + 5, offY + drawH/2 - 6, rust_text, TEXT_ALIGN_LEFT)
                    end
                elseif isEffect and btnMat then
                    surface.SetDrawColor(255,255,255,255) 
                    surface.SetMaterial(btnMat) 
                    surface.DrawTexturedRectUV(offX + 5, offY + 5, drawH-10, drawH-10, 0.06, 0.06, 0.94, 0.94)
                    DrawFlatText(string.upper(title), "MM_Exp", offX + drawH + 5, offY + drawH/2 - 6, rust_text, TEXT_ALIGN_LEFT)
                end
            end
        end

        if table.HasValue(GetRoleTableSH(client:GetRoleName()).weapons, "weapon_cqc") then CreateEquipButton("nextoren/gui/new_icons/disarm.png", L("l:inv_disarm"), function() net.Start("InventoryEffect_CQC") net.SendToServer() end, false, true) end
        if table.HasValue(GetRoleTableSH(client:GetRoleName()).weapons, "weapon_cannibal") then CreateEquipButton("nextoren/gui/new_icons/canibalism.png", L("l:inv_cannibalism"), function() net.Start("InventoryEffect_cannibal") net.SendToServer() end, false, true) end
        if table.HasValue(GetRoleTableSH(client:GetRoleName()).weapons, "weapon_checker") then CreateEquipButton("nextoren/gui/new_icons/player_check.png", L("l:inv_class_check"), function() net.Start("InventoryEffect_checker") net.SendToServer() end, false, true) end

        if (client.GetUsingHelmet and client:GetUsingHelmet() ~= "") then CreateEquipButton(client:GetUsingHelmet(), "", function() net.Start("DropAdditionalArmor", true) net.WriteString(client:GetUsingHelmet()) net.SendToServer() timer.Simple(0.1, function() if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame.RebuildEquip() end end) end, true, false) end
        if (client.GetUsingArmor and client:GetUsingArmor() ~= "") then CreateEquipButton(client:GetUsingArmor(), "", function() net.Start("DropAdditionalArmor", true) net.WriteString(client:GetUsingArmor()) net.SendToServer() timer.Simple(0.1, function() if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame.RebuildEquip() end end) end, true, false) end
        if (client.GetUsingBag and client:GetUsingBag() ~= "") then CreateEquipButton(client:GetUsingBag(), "", function() net.Start("DropAdditionalArmor", true) net.WriteString(client:GetUsingBag()) net.SendToServer() timer.Simple(0.1, function() if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame.RebuildEquip() end end) end, true, false) end
        if (client.GetUsingCloth and client:GetUsingCloth() ~= "") then CreateEquipButton(client:GetUsingCloth(), "", function() if DropCurrentVest then DropCurrentVest() end timer.Simple(0.1, function() if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame.RebuildEquip() end end) end, true, false) end

        for ammotype, amount in pairs(LocalPlayer():GetAmmo()) do
            if ammotype == 101 then continue end
            if amount <= 0 then continue end
            local btn = vgui.Create("DButton", equipScroll)
            btn:SetText(" ") btn:Dock(TOP) btn:SetSize(0, h * 0.04) btn:DockMargin(0, 0, 0, 2)
            
            local rawAmmoName = BREACH.AmmoTranslation[game.GetAmmoName(ammotype)] or game.GetAmmoName(ammotype)
            local ammoName = string.upper(BREACH.TranslateString(rawAmmoName)) .. L" l:looted_ammo_pt2"
            
            btn.Think = function(self) 
                self.PressMult = Lerp(FrameTime() * 15, self.PressMult or 0, self:IsDown() and 1 or 0)
                self.HoverMult = Lerp(FrameTime() * 15, self.HoverMult or 0, self:IsHovered() and 1 or 0)
            end
            btn.Paint = function(self, bw, bh)
                local scale = 1 - ((self.PressMult or 0) * 0.05)
                local drawW, drawH = bw * scale, bh * scale
                local offX, offY = (bw - drawW)/2, (bh - drawH)/2

                DrawTacticalBox(offX, offY, drawW, drawH, self.HoverMult, false, nil)
                DrawFlatText(ammoName, "MM_Exp", offX + 10, offY + drawH/2 - 6, rust_text_dim, TEXT_ALIGN_LEFT)
                DrawFlatText("x"..amount, "MM_Level", offX + drawW - 10, offY + drawH/2 - 10, rarity_omg, TEXT_ALIGN_RIGHT)
            end
            
            btn.DoRightClick = function(self)
                surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
                net.Start("InventoryDropAmmo")
                net.WriteUInt(ammotype, 16)
                net.WriteUInt(amount, 16)
                net.SendToServer()
                timer.Simple(0.1, function() if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame.RebuildEquip() end end)
            end
            
            btn.DoClick = function(self)
                surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
                if IsValid(Breach.InventoryMainFrame.AmmoDropFrame) then
                    Breach.InventoryMainFrame.AmmoDropFrame:Remove()
                end
                
                local f = vgui.Create("DPanel", Breach.InventoryMainFrame)
                Breach.InventoryMainFrame.AmmoDropFrame = f
                f:SetSize(250, 95)
                local mx, my = gui.MousePos()
                f:SetPos(mx - 260, my - 45)
                f.Paint = function(s, bw, bh)
                    if DrawBlurPanel then DrawBlurPanel(s) end
                    surface.SetDrawColor(18, 16, 15, 245)
                    surface.DrawRect(0, 0, bw, bh)
                    surface.SetDrawColor(218, 165, 32, 255)
                    surface.DrawRect(0, 0, bw, 2)
                    surface.SetDrawColor(255, 255, 255, 10)
                    surface.DrawOutlinedRect(0, 0, bw, bh, 1)
                    draw.SimpleText(L("l:inv_drop_ammo"), "MM_Exp", 10, 8, color_white, TEXT_ALIGN_LEFT)
                end
                
                local slider = vgui.Create("DNumSlider", f)
                slider:SetPos(10, 30)
                slider:SetSize(230, 30)
                slider:SetText(L("l:inv_amount"))
                slider:SetMin(1)
                slider:SetMax(amount)
                slider:SetDecimals(0)
                slider:SetValue(math.floor(amount / 2))
                slider.Label:SetTextColor(color_white)
                
                local btnDrop = vgui.Create("DButton", f)
                btnDrop:SetPos(10, 65)
                btnDrop:SetSize(230, 20)
                btnDrop:SetText("")
                btnDrop.Paint = function(s, bw, bh)
                    local clr = s:IsHovered() and Color(112, 126, 73, 200) or Color(40, 38, 35, 255)
                    surface.SetDrawColor(clr)
                    surface.DrawRect(0, 0, bw, bh)
                    surface.SetDrawColor(255, 255, 255, 10)
                    surface.DrawOutlinedRect(0, 0, bw, bh, 1)
                    draw.SimpleText(L("l:inv_confirm"), "MM_Exp", bw/2, bh/2 - 6, color_white, TEXT_ALIGN_CENTER)
                end
                btnDrop.DoClick = function()
                    local val = math.Round(slider:GetValue())
                    if val > 0 then
                        net.Start("InventoryDropAmmo")
                        net.WriteUInt(ammotype, 16)
                        net.WriteUInt(val, 16)
                        net.SendToServer()
                        timer.Simple(0.1, function() if IsValid(Breach.InventoryMainFrame) then Breach.InventoryMainFrame.RebuildEquip() end end)
                    end
                    f:Remove()
                end
                
                local btnClose = vgui.Create("DButton", f)
                btnClose:SetSize(24, 24)
                btnClose:SetPos(226, 0)
                btnClose:SetText("")
                btnClose.Paint = function(s, bw, bh)
                    draw.SimpleText("✕", "MM_Exp", bw/2, bh/2 - 6, s:IsHovered() and Color(188, 64, 43) or Color(140, 140, 140), TEXT_ALIGN_CENTER)
                end
                btnClose.DoClick = function() f:Remove() end
            end
        end
    end
    Breach.InventoryMainFrame.RebuildEquip()

    Breach.InventoryMainFrame.dragPanel = vgui.Create("DPanel", Breach.InventoryMainFrame)
    local dragPanel = Breach.InventoryMainFrame.dragPanel
    dragPanel:SetSize(w, h)
    dragPanel:SetMouseInputEnabled(false) dragPanel:SetKeyboardInputEnabled(false)
    dragPanel.Paint = function(self, pw, ph)
        if dragData.isDragging and dragData.dragIcon then
            local mx, my = gui.MousePos()
            local iconSize = h / 16
            
            surface.SetDrawColor(0, 0, 0, 200)
            surface.SetMaterial(dragData.dragIcon)
            surface.DrawTexturedRectUV(mx - iconSize/2 + 6, my - iconSize/2 + 6, iconSize, iconSize, 0.05, 0.05, 0.95, 0.95)

            surface.SetDrawColor(255, 255, 255, 200)
            surface.SetMaterial(dragData.dragIcon)
            surface.DrawTexturedRectUV(mx - iconSize/2, my - iconSize/2, iconSize, iconSize, 0.05, 0.05, 0.95, 0.95)
        end
    end

    local function StartDrag(button, index, itemData)
        if dragData.isDragging then return end
        dragData.isDragging = true dragData.startIndex = index dragData.itemData = itemData
        
        local wepData = GetCachedWeapon(itemData.class)
        if itemData.icon then dragData.dragIcon = GetCachedMaterial(itemData.icon) 
        elseif wepData and wepData.InvIcon then dragData.dragIcon = wepData.InvIcon 
        else dragData.dragIcon = matMissing end
        
        dragPanel:SetVisible(true) dragPanel:MoveToFront()
    end

    local function FinishDrag(targetIndex)
        if not dragData.isDragging or not dragData.startIndex then return end
        local old, new = dragData.startIndex, targetIndex
        if old and new and old ~= new then
            SwapItemsLocally(old, new)
            net.Start("InventoryDragAnDrop") net.WriteInt(old, 8) net.WriteInt(new, 8) net.SendToServer()
        end
        dragData.isDragging = false dragData.startIndex = nil dragData.dragIcon = nil dragPanel:SetVisible(false)
    end

    for k = 1, 12 do
        local v = data["Items"][k] or {}
        local btn = vgui.Create("DButton", Breach.InventoryMainFrame)
        btn:SetText(" ") btn.id = k btn.itemData = v
        Breach.InventoryMainFrame["InventoryButton_" .. k] = btn
        
        local posX, posY, size = GetSlotPos(k)
        btn:SetPos(posX, posY)
        btn:SetSize(size, size)
        
        buttonAnimations[k] = buttonAnimations[k] or { hover=0, press=0 }
        
        btn.Think = function(self)
            local anim = buttonAnimations[k]
            local yOff = Breach.InventoryMainFrame.OffsetY or 0
            
            local t = math.Clamp((SysTime() - Breach.InventoryMainFrame.OpenTime - (k * 0.02)) * 3, 0, 1)

            if k <= 3 then
                self:SetPos(posX, posY)
                self:SetAlpha(255)
            else
                self:SetPos(posX, Lerp(math.ease.OutBack(t), posY + 30 + yOff, posY + yOff))
                self:SetAlpha(255 * t)
            end

            anim.hover = Lerp(FrameTime() * 15, anim.hover, (self:IsHovered() and not dragData.isDragging) and 1 or 0)
            anim.press = Lerp(FrameTime() * 15, anim.press, (dragData.mousePressed and dragData.startIndex == k) and 1 or 0)
            
            if dragData.mousePressed and not dragData.isDragging and dragData.startIndex == k then
                local mx, my = gui.MousePos()
                if math.sqrt((mx - dragData.startMouseX)^2 + (my - dragData.startMouseY)^2) > 10 and dragData.dragTimerName and timer.Exists(dragData.dragTimerName) then
                    timer.Remove(dragData.dragTimerName) dragData.dragTimerName = nil StartDrag(self, k, self.itemData)
                end
            end
        end
        
        btn.OnMousePressed = function(self, mouseCode)
            if mouseCode == MOUSE_LEFT and not table.IsEmpty(self.itemData) then
                dragData.mousePressed = true 
                dragData.handledByButton = false
                dragData.startMouseX, dragData.startMouseY = gui.MousePos()
                dragData.startIndex = k
                
                local timerName = "InventoryDrag_" .. self.id
                dragData.dragTimerName = timerName
                timer.Create(timerName, 0.1, 1, function()
                    if IsValid(self) and not dragData.isDragging and dragData.mousePressed then StartDrag(self, k, self.itemData) end
                end)
            end
        end
        
        btn.OnMouseReleased = function(self, mouseCode)
            if mouseCode == MOUSE_LEFT then
                dragData.handledByButton = true
                dragData.mousePressed = false 
                if dragData.dragTimerName and timer.Exists(dragData.dragTimerName) then timer.Remove(dragData.dragTimerName) dragData.dragTimerName = nil end
                if dragData.isDragging then
                    if dragData.startIndex ~= k then FinishDrag(k) else dragData.isDragging = false dragPanel:SetVisible(false) end
                else
                    if not dragData.isDragging then TakeItem(k) end
                end
            elseif mouseCode == MOUSE_RIGHT then
                local wepInfo = not table.IsEmpty(self.itemData) and GetCachedWeapon(self.itemData.class)
                if not (wepInfo and (wepInfo.droppable == false or wepInfo.UnDroppable)) then
                    DropItem(k)
                end
            elseif mouseCode == MOUSE_MIDDLE then
                if not self.itemData or table.IsEmpty(self.itemData) then return end

                if self.itemData.class == "battery_1" and client:IIHasWeapon("item_tazer") then
                    local menu = DermaMenu()
                    menu:AddOption( L"l:load_tazer", function() 
						net.Start("tazer_load") 
						net.WriteInt(k,8) 
						net.SendToServer() 
					end ):SetIcon( "icon16/lightning_add.png" )
                    menu:Open()
                end
                
                local wepData = GetCachedWeapon(self.itemData.class)
                if not wepData then return end
                
                local isFirearm = wepData.ishgweapon or (wepData.Primary and wepData.Primary.Ammo and wepData.Primary.Ammo ~= "none" and wepData.Primary.Ammo ~= "")
                
                if wepData.ismelee or wepData.IsMelee or wepData.HoldType == "melee" or wepData.HoldType == "grenade" then
                    isFirearm = false
                end
                
                if isFirearm then
                    local menu = DermaMenu()
                    
                    menu:AddOption(L("l:inv_change_posture"), function()
                        RunConsoleCommand("hg_change_posture")
                    end):SetIcon("icon16/arrow_refresh.png")
                    menu:AddOption(L("l:inv_unload_ammo"), function()
                        RunConsoleCommand("hg_unload_ammo")
                    end):SetIcon("icon16/arrow_undo.png")
                    menu:AddOption(L("l:inv_inspect"), function()
                        RunConsoleCommand("hg_inspect")
                    end):SetIcon("icon16/magnifier.png")
                    if self.itemData.class == "weapon_revolver357" then
                        menu:AddOption(L("l:inv_roll_drum"), function()
                            RunConsoleCommand("hg_rolldrum")
                        end):SetIcon("icon16/arrow_rotate_anticlockwise.png")
                        menu:AddOption(L("l:inv_insert_bullet"), function()
                            RunConsoleCommand("hg_insertbullet", "1")
                        end):SetIcon("icon16/basket_put.png")
                    end
                    
                    menu:Open()
                end
            end
        end
        
        btn.OnCursorExited = function(self)
            if dragData.dragTimerName and timer.Exists(dragData.dragTimerName) and not dragData.isDragging then timer.Remove(dragData.dragTimerName) dragData.dragTimerName = nil end
            if Breach.InventoryMainFrame.InspectedItem == k then Breach.InventoryMainFrame.InspectedItem = nil end
        end
        btn.OnCursorEntered = function(self) if not table.IsEmpty(self.itemData) and not dragData.isDragging then Breach.InventoryMainFrame.InspectedItem = k end end

        btn.Paint = function(self, bw, bh)
            local anim = buttonAnimations[k]
            local rarityColor = nil
            local wepData = not table.IsEmpty(self.itemData) and GetCachedWeapon(self.itemData.class)
            local isUndroppable = wepData and (wepData.droppable == false or wepData.UnDroppable)
            
            if wepData then
                local rarity = wepData.red
                if rarity == "OMG" then rarityColor = rarity_omg elseif rarity == "SCP" then rarityColor = rarity_scp end
            end

            local isAct = client:GetNWInt("ActiveSlot", 0) == k 

            local scale = 1 - (anim.press * 0.1) - (anim.hover * 0.05)
            local drawW, drawH = bw * scale, bh * scale
            local offX, offY = (bw - drawW)/2, (bh - drawH)/2

            if k > tonumber(LocalPlayer():GetNWInt("InventoryMaxSlots", 8)) then
                surface.SetDrawColor(10, 10, 10, 200) surface.DrawRect(offX, offY, drawW, drawH)
                surface.SetDrawColor(rust_red) surface.DrawOutlinedRect(offX, offY, drawW, drawH, 1)
                surface.DrawLine(offX, offY, offX+drawW, offY+drawH) surface.DrawLine(offX+drawW, offY, offX, offY+drawH)
                return
            end

            DrawTacticalBox(offX, offY, drawW, drawH, anim.hover, isAct, rarityColor)

            if not table.IsEmpty(self.itemData) then
                surface.SetDrawColor(255, 255, 255, 255)
                local icon = self.itemData.icon and GetCachedMaterial(self.itemData.icon) or (wepData and wepData.InvIcon) or matMissing
                surface.SetMaterial(icon)
                surface.DrawTexturedRectUV(offX + 4, offY + 4, drawW - 8, drawH - 8, 0.05, 0.05, 0.95, 0.95)
                
                if isUndroppable then
                    surface.SetDrawColor(rust_red)
                    surface.DrawRect(offX + drawW - 35, offY + 3, 33, 14)
                    DrawFlatText(L("l:inv_block"), "MM_Desc", offX + drawW - 18, offY + 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end
            end

            DrawFlatText(tostring(k), "MM_Exp", offX + 6, offY + 4, rust_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    if loot_data ~= nil and not table.IsEmpty(loot_data) then
        Breach.InventoryMainFrame.loot = vgui.Create("DPanel", Breach.InventoryMainFrame)
        Breach.InventoryMainFrame.loot:SetPos(w * 0.8, h * 0.15)
        Breach.InventoryMainFrame.loot:SetSize(w * 0.18, contentHeight)
        
        local targetName = loot_data.Name or L("l:inv_unknown_subject")
        
        Breach.InventoryMainFrame.loot.Paint = function(self, pw, ph)
            local yOff = Breach.InventoryMainFrame.OffsetY or 0
            self:SetPos(w * 0.8, h * 0.15 + yOff)

            surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
            surface.DrawRect(0, 0, pw, ph)
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, pw, ph, 1)
            
            DrawFlatText(L("l:inv_search") .. string.upper(targetName), "MM_Level", 10, 10, rust_text, TEXT_ALIGN_LEFT)
            surface.DrawLine(10, 30, pw-10, 30)
        end
        
        local sp = vgui.Create("DScrollPanel", Breach.InventoryMainFrame.loot)
        sp:Dock(FILL) sp:DockMargin(5, 35, 5, 5)
        local sbarLt = sp:GetVBar()
        function sbarLt:Paint(w,h) surface.SetDrawColor(10,10,10,200) surface.DrawRect(w/2-2, 0, 4, h) end 
        function sbarLt.btnUp:Paint() end 
        function sbarLt.btnDown:Paint() end 
        function sbarLt.btnGrip:Paint(gw,gh) surface.SetDrawColor(rust_yellow) surface.DrawRect(gw/2-2, 0, 4, gh) end

        for k = 1, 12 do
            local v = loot_data.Items[k] or {}
            if table.IsEmpty(v) then continue end
            local wepData = GetCachedWeapon(v.class)
            if wepData and (wepData.droppable == false or wepData.UnDroppable) then continue end

            local btn = vgui.Create("DButton", sp) btn:SetText(" ") btn:Dock(TOP) btn:SetSize(0, h*0.06) btn:DockMargin(0, 0, 0, 5)
            
            local icon = wepData and wepData.InvIcon or nil
            local name = string.upper((wepData and wepData.PrintName) or "?")

            btn.Think = function(self) 
                self.PressMult = Lerp(FrameTime() * 15, self.PressMult or 0, self:IsDown() and 1 or 0) 
                self.HoverMult = Lerp(FrameTime() * 15, self.HoverMult or 0, self:IsHovered() and 1 or 0)
            end
            btn.Paint = function(self, bw, bh)
                local scale = 1 - ((self.PressMult or 0) * 0.05)
                local drawW, drawH = bw * scale, bh * scale
                local offX, offY = (bw - drawW)/2, (bh - drawH)/2

                DrawTacticalBox(offX, offY, drawW, drawH, self.HoverMult, false, nil)
                if icon then surface.SetDrawColor(255,255,255) surface.SetMaterial(icon) surface.DrawTexturedRectUV(offX + 5, offY + 5, drawH-10, drawH-10, 0.06, 0.06, 0.94, 0.94) end
                DrawFlatText(name, "MM_Exp", offX + drawH + 5, offY + drawH/2 - 6, rust_text, TEXT_ALIGN_LEFT)
            end
            btn.DoClick = function() TakeVictimItem(k) btn:Remove() end
        end
        if loot_data.Ammo then
            for ammotype, amount in pairs(loot_data.Ammo) do
                if amount <= 0 or ammotype == 101 then continue end

                local btn = vgui.Create("DButton", sp)
                btn:SetText(" ") 
                btn:Dock(TOP) 
                btn:SetSize(0, h * 0.04)
                btn:DockMargin(0, 0, 0, 5)
                
                local rawAmmoName = BREACH.AmmoTranslation[game.GetAmmoName(ammotype)] or game.GetAmmoName(ammotype)
                local ammoName = string.upper(BREACH.TranslateString(rawAmmoName)) .. L" l:looted_ammo_pt2"

                btn.Think = function(self) 
                    self.PressMult = Lerp(FrameTime() * 15, self.PressMult or 0, self:IsDown() and 1 or 0) 
                    self.HoverMult = Lerp(FrameTime() * 15, self.HoverMult or 0, self:IsHovered() and 1 or 0)
                end
                
                btn.Paint = function(self, bw, bh)
                    local scale = 1 - ((self.PressMult or 0) * 0.05)
                    local drawW, drawH = bw * scale, bh * scale
                    local offX, offY = (bw - drawW)/2, (bh - drawH)/2

                    DrawTacticalBox(offX, offY, drawW, drawH, self.HoverMult, false, nil)
                    
                    DrawFlatText(ammoName, "MM_Exp", offX + 10, offY + drawH/2 - 6, rust_text_dim, TEXT_ALIGN_LEFT)
                    DrawFlatText("x" .. amount, "MM_Level", offX + drawW - 10, offY + drawH/2 - 10, rarity_omg, TEXT_ALIGN_RIGHT)
                end
                
                btn.DoClick = function()
                    surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
                    net.Start("InventoryTakeVictimAmmo")
                    net.WriteUInt(ammotype, 16)
                    net.WriteUInt(amount, 16)
                    net.SendToServer()
                    
                    btn:Remove() 
                end
            end
        end
    end

    Breach.InventoryMainFrame.OnRemove = function(self)
        gui.EnableScreenClicker(false)
    end

    gui.EnableScreenClicker(true)
end

net.Receive("SendInventoryDataOper", function(len)
    local data = net.ReadTable()
    inv_oper_data = data
    LocalPlayer().operdatainv = data
    LocalInvVersion = LocalPlayer():GetNWInt("InvVersion", 0)

    if IsValid(Breach.InventoryMainFrame) then
        for k = 1, 12 do
            local btn = Breach.InventoryMainFrame["InventoryButton_" .. k]
            if IsValid(btn) then
                btn.itemData = data["Items"][k] or {}
            end
        end
    end
end)

net.Receive("SendInventoryDataTryp", function(len)
    local data = net.ReadTable()
    local loot_data = net.ReadTable()
    inv_oper_data = data
    LocalPlayer().operdatainv = data
    LocalInvVersion = LocalPlayer():GetNWInt("InvVersion", 0)

    if IsValid(Breach.InventoryMainFrame) and not Breach.InventoryMainFrame.Closing then
        for k = 1, 12 do
            local btn = Breach.InventoryMainFrame["InventoryButton_" .. k]
            if IsValid(btn) then btn.itemData = data["Items"][k] or {} end
        end
    else
        NewLegacyInventoryFrame(data, loot_data)
    end
end)

function NewLegacyInventoryClose() 
    if IsValid(Breach.InventoryMainFrame) and not Breach.InventoryMainFrame.Closing then 
        Breach.InventoryMainFrame.Closing = true 
        Breach.InventoryMainFrame.CloseTime = SysTime()
        gui.EnableScreenClicker(false) 
    end 
end

local scp542_health_states = {
    "l:scp542_hp_1",
    "l:scp542_hp_2",
    "l:scp542_hp_3",
    "l:scp542_hp_4",
    "l:scp542_hp_5",
    "l:scp542_hp_6",
    "l:scp542_hp_7",
    "l:scp542_hp_8",
    "l:scp542_hp_9",
    "l:scp542_hp_10",
    "l:scp542_hp_11",
    "l:scp542_hp_12",
    "l:scp542_hp_13",
    "l:scp542_hp_14",
    "l:scp542_hp_15",
    "l:scp542_hp_16",
    "l:scp542_hp_17",
    "l:scp542_hp_18",
    "l:scp542_hp_19",
    "l:scp542_hp_20",
    "l:scp542_hp_21",
    "l:scp542_hp_22",
    "l:scp542_hp_23",
    "l:scp542_hp_24",
    "l:scp542_hp_25",
    "l:scp542_hp_26",
    "l:scp542_hp_27",
    "l:scp542_hp_28",
    "l:scp542_hp_29",
    "l:scp542_hp_30"
}


hook.Add("HUDPaint", "HotBar_HUD", function()
    local client = LocalPlayer()
    if IsValid(Breach.InventoryMainFrame) or table.IsEmpty(inv_oper_data) or disablehud or client:Health() <= 0 then return end
    if IsValid(client:GetParent()) and client:GetParent():GetClass() == "prop_ragdoll" then return end
    if client:GetModel() == "models/cultist/scp/scp_542.mdl" then
        local hp = client:Health()
        
        local idx = math.Clamp(math.ceil(hp / 100), 1, #scp542_health_states)
        local state_text = L(scp542_health_states[idx])

        local text_col = rust_red
        if idx >= 20 then text_col = rust_green
        elseif idx >= 10 then text_col = rust_yellow end

        draw.SimpleText(state_text, "MM_Level", ScrW()/2, ScrH()/1.01, text_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    if client:GTeam() == TEAM_SCP or client:GTeam() == TEAM_SPEC or client.br_scp079_mode then return end

    local healthFractionTarget = GetPlayerVitality(client)
	local health = healthFractionTarget * 100 
    DrawTacticalHUD(
        ScrW(), ScrH(), 0, 0, 
        health, 
        100, 
        client.organism.stamina[1] or 180,
        client.organism.stamina.max or 180, 
        client:GetRoleName(), 
        gteams.GetColor(client:GTeam())
    )

    local activeSlot = client:GetNWInt("ActiveSlot") or 0
    local w, h = ScrW(), ScrH()

    local have_radio = false 
    for k,v in pairs(inv_oper_data["Items"] or {}) do 
        if v.class == "item_radio" then have_radio = true break end 
    end
    
    if have_radio then
        local radioEnabled = client:GetNWBool("radio_enbl")
        local pulse = radioEnabled and (math.sin(SysTime() * 8) * 0.5 + 0.5) or 0
        surface.SetDrawColor(radioEnabled and rust_green.r or rust_red.r, radioEnabled and rust_green.g or rust_red.g, radioEnabled and rust_green.b or rust_red.b, 100 + 155 * pulse)
        surface.DrawRect(w/128, h/1.17 + 8, 8, 8)

        if radioEnabled then
            DrawFlatText(L("l:inv_comms_on"), "MM_Exp", w/128 + 15, h/1.17 + 5, rust_text)
            DrawFlatText("CH: " .. math.Round(client:GetNWFloat("radio_chanel"),1), "MM_Exp", w/128 + 15, h/1.15, rust_green)
        else
            DrawFlatText(L("l:inv_comms_off"), "MM_Exp", w/128 + 15, h/1.17 + 5, rust_red)
        end
    end

    for i = 1, 3 do
        local isAct = activeSlot == i
        local x, y, iconSize = GetSlotPos(i)
        
        local item = inv_oper_data["Items"] and inv_oper_data["Items"][i]
        local rarityColor = nil
        
        if item and not table.IsEmpty(item) then
            local wep = GetCachedWeapon(item.class)
            if wep then
                if wep.red == "OMG" then rarityColor = rarity_omg
                elseif wep.red == "SCP" then rarityColor = rarity_scp end
            end
        end

        local anim = hudButtonAnimations[i] or {}
        local press = 0
        if anim.pressTime then
            local timeSincePress = CurTime() - anim.pressTime
            if timeSincePress <= 0.2 then press = 1 - (timeSincePress / 0.2) else hudButtonAnimations[i] = nil end
        end

        local scale = 1 - 0.1 * press
        local drawW, drawH = iconSize * scale, iconSize * scale
        local dx, dy = x + (iconSize - drawW)/2, y + (iconSize - drawH)/2

        DrawTacticalBox(dx, dy, drawW, drawH, 0, isAct, rarityColor)
        
        if item and not table.IsEmpty(item) then
            local wep = GetCachedWeapon(item.class)
            local icon = item.icon and GetCachedMaterial(item.icon) or (wep and wep.InvIcon) or matMissing
            surface.SetMaterial(icon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectUV(dx + 4, dy + 4, drawW - 8, drawH - 8, 0.05, 0.05, 0.95, 0.95)
        end

        DrawFlatText(tostring(i), "MM_Exp", dx + 6, dy + 4, rust_text_dim)
    end
end)

hook.Add("PlayerButtonDown", "HotBar_Button", function(ply, button)
    if IsValid(Breach.InventoryMainFrame) or IsValid(MainMogFrame) then return end
    if IsValid(BREACH.QuickChatPanel) then return end
    if IsValid(BREACH.EMOTECOOLMENU) then return end
    if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP or ply.cantopeninventory then return end
    
    local slot = 0
    if button == KEY_1 then slot = 1
    elseif button == KEY_2 then slot = 2
    elseif button == KEY_3 then slot = 3 end

    if slot > 0 and IsFirstTimePredicted() then 
        hudButtonAnimations[slot] = {pressTime = CurTime()} 
        TakeItem(slot) 
    end
end)

hook.Add("OnNetVarSet", "Inventory_Sync_DrawBullet", function(index, key, var)
    if key == "drawBullet" then
        local wep = Entity(index)
        if IsValid(wep) then
            wep.drawBullet = var
        end
    end
end)