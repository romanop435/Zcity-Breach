if CLIENT then
    surface.CreateFont("Cyb_HudTEXT", {
        font = "Segoe UI",
        size = 20,
        weight = 600,
        extended = true,
    })

    local TipPanels = TipPanels or {}
    
    local iconMaterials = {
        default = Material("nextoren/gui/new_icons/notifications/breachiconfortips.png", "smooth"),
    }

    local function sw(val) return math.Round(val * (ScrW() / 1920)) end
    local function sh(val) return math.Round(val * (ScrH() / 1080)) end

    local function RecalculateTipPositions()
        local padding = sh(10)
        local currentY = ScrH() - sh(50) 

        for i = #TipPanels, 1, -1 do
            local pnl = TipPanels[i]
            if IsValid(pnl) and not pnl.IsDying then
                pnl.TargetY = currentY - pnl:GetTall()
                currentY = pnl.TargetY - padding
            end
        end
    end

    function MakeTip(icontype, str1, col1, str2, col2)
        local translated_str1 = BREACH.TranslateString and BREACH.TranslateString(str1 or "") or (L and L(str1 or "") or str1 or "")
        local translated_str2 = BREACH.TranslateString and BREACH.TranslateString(str2 or "") or (L and L(str2 or "") or str2 or "")

        local lang1 = string.upper(translated_str1)
        local lang2 = string.upper(translated_str2)
        
        surface.SetFont("MM_Exp")

        local s1 = surface.GetTextSize(lang1)
        local s2 = surface.GetTextSize(lang2)
        if lang2 == "" then s2 = 0 end
        
        local minWidth = sw(250)
        local panelHeight = sh(50)
        local panelWidth = math.max(minWidth, s1 + s2 + sw(80))
        
        local tippanel = vgui.Create("DPanel")
        table.insert(TipPanels, tippanel)
        
        local rust_panel   = Color(18, 16, 15, 245)
        local rust_outline = Color(255, 255, 255, 15)
        local icon_bg      = Color(30, 28, 25, 255)
        
        local accent_color = col1 or color_white
        if accent_color.r == 255 and accent_color.g == 255 and accent_color.b == 255 then
            accent_color = Color(218, 165, 32, 255) 
        end
        
        tippanel:SetSize(panelWidth, panelHeight)
        tippanel:SetZPos(32767)
        
        tippanel.TargetX = ScrW() - panelWidth - sw(20)
        tippanel.CurX = ScrW() + sw(20)
        tippanel.TargetY = ScrH()
        tippanel.CurY = ScrH() + sh(20)
        tippanel.CurAlpha = 0
        
        tippanel:SetPos(tippanel.CurX, tippanel.CurY)
        
        tippanel.LifeTime = 5
        tippanel.SpawnTime = SysTime()
        tippanel.EndTime = tippanel.SpawnTime + tippanel.LifeTime
        tippanel.IsDying = false
        
        RecalculateTipPositions()
        
        tippanel.CurY = tippanel.TargetY + sh(15)
        
        tippanel.Think = function(self)
            local ft = FrameTime() * 12
            
            if SysTime() >= self.EndTime and not self.IsDying then
                self.IsDying = true
                self.TargetX = ScrW() + sw(20)
                RecalculateTipPositions()
            end
            
            self.CurX = Lerp(ft, self.CurX, self.TargetX)
            self.CurY = Lerp(ft, self.CurY, self.TargetY)
            
            if self.IsDying then
                self.CurAlpha = Lerp(ft * 1.5, self.CurAlpha, 0)
                if self.CurAlpha < 5 or self.CurX > ScrW() then
                    table.RemoveByValue(TipPanels, self)
                    self:Remove()
                    return
                end
            else
                self.CurAlpha = Lerp(ft, self.CurAlpha, 255)
            end
            
            self:SetPos(math.Round(self.CurX), math.Round(self.CurY))
            self:SetAlpha(self.CurAlpha)
        end
        
        local maticon = iconMaterials[icontype] or iconMaterials.default
        
        tippanel.Paint = function(self, w, h)
            surface.SetDrawColor(rust_panel)
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(icon_bg)
            surface.DrawRect(0, 0, h, h)
            
            surface.SetDrawColor(rust_outline)
            surface.DrawLine(h, 0, h, h)
            
            surface.SetDrawColor(accent_color)
            surface.DrawRect(0, 0, sw(3), h)
            
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            surface.SetDrawColor(255, 255, 255, 200)
            surface.SetMaterial(maticon)
            local iconSize = sh(48)
            surface.DrawTexturedRect(h/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
            
            local textX = h + sw(15)
            draw.SimpleText(lang1, "MM_Exp", textX, h/2 - sh(1), col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            if lang2 ~= "" then
                draw.SimpleText(" " .. lang2, "MM_Exp", textX + s1, h/2 - sh(1), col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            if not self.IsDying then
                local timeLeft = math.max(0, self.EndTime - SysTime())
                local progress = timeLeft / self.LifeTime
                
                surface.SetDrawColor(accent_color.r, accent_color.g, accent_color.b, 150)
                surface.DrawRect(h + sw(1), h - sh(2), (w - h - sw(2)) * progress, sh(2))
            end
        end
    end

    local UpdateDelay = 0
    net.Receive("Shaky_TipSend", function()
        local icontype = net.ReadUInt(2)
        local str1 = net.ReadString()
        local col1 = net.ReadColor()
        local str2 = net.ReadString()
        local col2 = net.ReadColor()
        
        timer.Simple(UpdateDelay, function()
            MakeTip(icontype, str1, col1, str2, col2)
            if UpdateDelay ~= 0 then
                UpdateDelay = math.Clamp(UpdateDelay - 0.2, 0, 1)
            end
        end)
        UpdateDelay = UpdateDelay + 0.2
    end)

else
    util.AddNetworkString("Shaky_TipSend")
    local mply = FindMetaTable("Player")
    function mply:BrTip(icontype, str1, col1, str2, col2)
        net.Start("Shaky_TipSend", true)
        net.WriteUInt(icontype, 2)
        net.WriteString(str1)
        net.WriteColor(col1)
        net.WriteString(str2)
        net.WriteColor(col2)
        net.Send(self)
    end
end