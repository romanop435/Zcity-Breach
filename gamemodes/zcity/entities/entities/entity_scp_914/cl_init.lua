include( "shared.lua" )

surface.CreateFont( "SelectionFontBig", {

  font = "Conduit ITC",
  size = 24,
  weight = 800,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = true,
  additive = false,
  outline = false

} )

surface.CreateFont( "SelectionFont", {

  font = "Conduit ITC",
  size = 22,
  weight = 800,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = true,
  additive = false,
  outline = false

} )

local status_text = {

  "Очень грубо",
  "Грубо",
  "1:1",
  "Тонко",
  "Очень тонко"

}

local vector_offset = Vector( 5, 3.2, 12 )
local angle_offset = Angle( 0, 180, 90 )
local nukeicon = Material( "nextoren/nuke/loading" )
function ENT:Draw()

  self:DrawModel()

  local client = LocalPlayer()

  if ( client:GetPos():DistToSqr( self:GetPos() ) > 62500 ) then return end

  local campos = self:LocalToWorld( vector_offset )
  cam.Start3D2D( campos, self:LocalToWorldAngles( angle_offset, .1 ), .1 )

    if self:GetStatus() == -1 then

      draw.DrawText( "СБОРКА БОГА", "ImpactBig", 60, 35, Color(220, 20, 20), 1 )

    else

      draw.DrawText( "Режим: " .. status_text[ self:GetStatus() ], "ImpactBig", 60, 35, color_white, 1 )
      if self:GetWorking() then
        surface.SetDrawColor( 255, 255, 255, 255 )
			  surface.SetMaterial( nukeicon )
			  surface.DrawTexturedRect( 0, 80, 128, 128 )
      end
    end

  cam.End3D2D()

end

function Open914Menu()
    local scp914 = LocalPlayer():GetEyeTrace().Entity
    local client = LocalPlayer()
    if client:GTeam() == TEAM_SCP or client:GTeam() == TEAM_SPEC then return end
    if !IsValid(scp914) or scp914:GetClass() != "entity_scp_914" then return end
    
    if istable(BREACH.Menu914Options) then
        for i, v in pairs(BREACH.Menu914Options) do
            if IsValid(v) then v:Remove() end
        end
    end
    
    BREACH.Menu914Options = BREACH.Menu914Options || {}
    
    local teams_table = {
        { name = "Сменить режим", func = function() 
            net.Start("Changestatus_SCP914") 
            net.WriteEntity(scp914) 
            net.SendToServer() 
        end },
        { name = "Запустить", func = function() 
            net.Start("Activate_SCP914") 
            net.WriteEntity(scp914) 
            net.SendToServer() 
        end },
    }

    BREACH.Menu914Options.MainPanel = vgui.Create("DPanel")
    BREACH.Menu914Options.MainPanel:SetSize(256, 256)
    BREACH.Menu914Options.MainPanel:SetPos(ScrW() / 2 - 128, ScrH() / 2 - 128)
    BREACH.Menu914Options.MainPanel:SetText("")
    
    BREACH.Menu914Options.MainPanel.Animations = {
        panelAlpha = 0,
        panelScale = 0.7,
        panelYOffset = 50,
        fadeOut = 1,
        shaking = false,
        shakeTime = 0
    }
    
    BREACH.Menu914Options.MainPanel.IsFadingOut = false
    BREACH.Menu914Options.MainPanel.CreationTime = CurTime()
    BREACH.Menu914Options.MainPanel.CloseTimerSet = false
    BREACH.Menu914Options.MainPanel.scp914 = scp914
    
    BREACH.Menu914Options.MainPanel.Think = function(self)
        local currentTime = CurTime()
        local elapsed = currentTime - self.CreationTime
        
        if self.IsFadingOut then
            self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
            self.Animations.panelScale = Lerp(FrameTime() * 15, self.Animations.panelScale, 0.3)
            self.Animations.panelYOffset = Lerp(FrameTime() * 12, self.Animations.panelYOffset, 20)
            
            if self.Animations.fadeOut < 0.01 then
                if IsValid(self.Disclaimer) then self.Disclaimer:Remove() end
                if IsValid(self.ScrollPanel) then self.ScrollPanel:Remove() end
                self:Remove()
                gui.EnableScreenClicker(false)
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
        
        if self.Animations.shaking and currentTime - self.Animations.shakeTime < 0.6 then
            local progress = (currentTime - self.Animations.shakeTime) / 0.6
            local intensity = (1 - progress) * 4
            local vibrateX = math.sin(currentTime * 80) * intensity
            local vibrateY = math.cos(currentTime * 60) * intensity
            
            local baseX = ScrW()/2 - (256 * self.Animations.panelScale) / 2
            local baseY = ScrH() / 2 - 128 + self.Animations.panelYOffset
            
            self:SetPos(baseX + vibrateX, baseY + vibrateY)
        else
            local baseX = ScrW()/2 - (256 * self.Animations.panelScale) / 2
            local baseY = ScrH() / 2 - 128 + self.Animations.panelYOffset
            self:SetPos(baseX, baseY)
        end
        
        if not vgui.CursorVisible() then
            gui.EnableScreenClicker(true)
        end
        
        if input.IsKeyDown(KEY_BACKSPACE) then
            self.IsFadingOut = true
        end
        
        local player = LocalPlayer()
        if player:GTeam() == TEAM_SPEC or player:GTeam() == TEAM_SCP or player:Health() <= 0 or 
           not IsValid(self.scp914) or self.scp914:GetPos():DistToSqr(player:GetPos()) > 7000 or 
           player:GetEyeTrace().Entity != self.scp914 then
            self.IsFadingOut = true
        end
        
        self:SetAlpha(self.Animations.panelAlpha * self.Animations.fadeOut * 255)
    end

    BREACH.Menu914Options.MainPanel.Paint = function(self, w, h)
        local currentScale = self.Animations.panelScale
        local currentAlpha = self.IsFadingOut and self.Animations.fadeOut or self.Animations.panelAlpha
        
        local scaledW = w * currentScale
        local scaledH = h * currentScale
        local offsetX = (w - scaledW) / 2
        local offsetY = (h - scaledH) / 2
        
        DrawBlurPanel(self)
        
        local glowAlpha = math.sin(CurTime() * 8) * 0.2 + 0.8
        if not self.IsFadingOut and self.Animations.panelAlpha > 0.9 then
            draw.RoundedBox(0, offsetX - 2, offsetY - 2, scaledW + 4, scaledH + 4, 
                Color(255, 255, 255, 30 * glowAlpha * currentAlpha))
        end
        
        draw.RoundedBox(0, offsetX, offsetY, scaledW, scaledH, Color(255, 255, 255, 120 * currentAlpha))
        
        if not self.IsFadingOut or self.Animations.fadeOut > 0.3 then
            draw.RoundedBox(0, offsetX + 2, offsetY + 2, scaledW - 4, scaledH - 4, 
                Color(0, 0, 0, 80 * currentAlpha))
        end
        
        local outlineAlpha = currentAlpha * (self.IsFadingOut and self.Animations.fadeOut or 1)
        surface.SetDrawColor(255, 255, 255, 100 * outlineAlpha)
        surface.DrawOutlinedRect(offsetX, offsetY, scaledW, scaledH)
    end

    BREACH.Menu914Options.MainPanel.Disclaimer = vgui.Create("DPanel")
    BREACH.Menu914Options.MainPanel.Disclaimer:SetSize(256, 64)
    BREACH.Menu914Options.MainPanel.Disclaimer:SetPos(ScrW() / 2 - 128, ScrH() / 2 - 192)
    BREACH.Menu914Options.MainPanel.Disclaimer:SetText("")
    
    BREACH.Menu914Options.MainPanel.Disclaimer.Animations = {
        alpha = 0,
        yOffset = 30,
        fadeOut = 1
    }
    BREACH.Menu914Options.MainPanel.Disclaimer.CreationTime = CurTime()
    
    BREACH.Menu914Options.MainPanel.Disclaimer.Think = function(self)
        local elapsed = CurTime() - self.CreationTime
        
        if IsValid(BREACH.Menu914Options.MainPanel) and BREACH.Menu914Options.MainPanel.IsFadingOut then
            self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
            self.Animations.yOffset = Lerp(FrameTime() * 10, self.Animations.yOffset, 20)
        else
            if elapsed > 0.2 then
                self.Animations.alpha = Lerp(FrameTime() * 8, self.Animations.alpha, 1)
                self.Animations.yOffset = Lerp(FrameTime() * 12, self.Animations.yOffset, 0)
            end
        end
        
        local finalAlpha = self.Animations.alpha * self.Animations.fadeOut
        self:SetAlpha(finalAlpha * 255)
        
        local x = ScrW() / 2 - 128
        local y = ScrH() / 2 - 192 + self.Animations.yOffset
        self:SetPos(x, y)
    end

    BREACH.Menu914Options.MainPanel.Disclaimer.Paint = function(self, w, h)
        local currentAlpha = self.Animations.alpha * self.Animations.fadeOut
        
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 120 * currentAlpha))
        DrawBlurPanel(self)
        
        draw.DrawText("SCP-914", "ChatFont_new", w / 2, h / 2 - 16, 
            Color(0, 0, 0, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    BREACH.Menu914Options.ScrollPanel = vgui.Create("DScrollPanel", BREACH.Menu914Options.MainPanel)
    BREACH.Menu914Options.ScrollPanel:Dock(FILL)
    
    BREACH.Menu914Options.MainPanel.ScrollPanel = BREACH.Menu914Options.ScrollPanel
    
    BREACH.Menu914Options.ScrollPanel.Animations = {
        alpha = 0,
        fadeOut = 1
    }
    
    BREACH.Menu914Options.ScrollPanel.Think = function(self)
        if IsValid(BREACH.Menu914Options.MainPanel) and BREACH.Menu914Options.MainPanel.IsFadingOut then
            self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
        else
            self.Animations.alpha = Lerp(FrameTime() * 5, self.Animations.alpha, 1)
        end
        
        local mainPanelAlpha = IsValid(BREACH.Menu914Options.MainPanel) and 
            BREACH.Menu914Options.MainPanel.Animations.panelAlpha * 
            BREACH.Menu914Options.MainPanel.Animations.fadeOut or 1
        self:SetAlpha(self.Animations.alpha * self.Animations.fadeOut * mainPanelAlpha * 255)
    end

    for i = 1, #teams_table do
        BREACH.Menu914Options.Users = BREACH.Menu914Options.ScrollPanel:Add("DButton")
        BREACH.Menu914Options.Users:SetText("")
        BREACH.Menu914Options.Users:Dock(TOP)
        BREACH.Menu914Options.Users:SetSize(256, 64)
        BREACH.Menu914Options.Users:DockMargin(0, 0, 0, 2)
        BREACH.Menu914Options.Users.CursorOnPanel = false
        
        BREACH.Menu914Options.Users.Animations = {
            hover = 0,
            press = 0,
            scale = 1,
            yOffset = 0,
            alpha = 0,
            fadeOut = 1,
            delay = (i-1) * 0.05,
            appearTime = CurTime()
        }

        BREACH.Menu914Options.Users.Think = function(self)
            if IsValid(BREACH.Menu914Options.MainPanel) and BREACH.Menu914Options.MainPanel.IsFadingOut then
                self.Animations.fadeOut = Lerp(FrameTime() * 8, self.Animations.fadeOut, 0)
                self.Animations.hover = Lerp(FrameTime() * 15, self.Animations.hover, 0)
                self.Animations.press = Lerp(FrameTime() * 15, self.Animations.press, 0)
                self.Animations.scale = Lerp(FrameTime() * 12, self.Animations.scale, 0.7)
                self.Animations.yOffset = Lerp(FrameTime() * 10, self.Animations.yOffset, 20)
            else
                local appearProgress = (CurTime() - self.Animations.appearTime - self.Animations.delay)
                if appearProgress > 0 then
                    self.Animations.alpha = Lerp(FrameTime() * 8, self.Animations.alpha, 1)
                end
                
                if self.CursorOnPanel then
                    self.Animations.hover = Lerp(FrameTime() * 10, self.Animations.hover, 1)
                else
                    self.Animations.hover = Lerp(FrameTime() * 10, self.Animations.hover, 0)
                end
                
                if self.Depressed then
                    self.Animations.press = Lerp(FrameTime() * 20, self.Animations.press, 1)
                else
                    self.Animations.press = Lerp(FrameTime() * 10, self.Animations.press, 0)
                end
                
                self.Animations.scale = 1 - (self.Animations.hover * 0.03) - (self.Animations.press * 0.1)
                self.Animations.yOffset = (self.Animations.hover * 2) + (self.Animations.press * 5)
            end
            
            local finalAlpha = self.Animations.alpha * self.Animations.fadeOut
            if IsValid(BREACH.Menu914Options.ScrollPanel) then
                finalAlpha = finalAlpha * BREACH.Menu914Options.ScrollPanel.Animations.alpha * 
                    BREACH.Menu914Options.ScrollPanel.Animations.fadeOut
            end
            self:SetAlpha(finalAlpha * 255)
        end

        BREACH.Menu914Options.Users.Paint = function(self, w, h)
            if IsValid(BREACH.Menu914Options.MainPanel) and BREACH.Menu914Options.MainPanel.IsFadingOut then
                self:SetCursor("arrow")
            else
                self:SetCursor("hand")
            end
            
            local currentAlpha = self.Animations.alpha * self.Animations.fadeOut
            if IsValid(BREACH.Menu914Options.ScrollPanel) then
                currentAlpha = currentAlpha * BREACH.Menu914Options.ScrollPanel.Animations.alpha * 
                    BREACH.Menu914Options.ScrollPanel.Animations.fadeOut
            end
            
            local scaledW = w * self.Animations.scale
            local scaledH = h * self.Animations.scale
            local offsetX = (w - scaledW) / 2
            local offsetY = (h - scaledH) / 2 + self.Animations.yOffset
            
            local baseColor = Color(0, 0, 0, 255 * currentAlpha)
            local hoverColor = Color(50, 50, 50, 255 * currentAlpha)
            
            local animColor = Color(
                Lerp(self.Animations.hover, baseColor.r, hoverColor.r),
                Lerp(self.Animations.hover, baseColor.g, hoverColor.g),
                Lerp(self.Animations.hover, baseColor.b, hoverColor.b),
                Lerp(self.Animations.press, 
                    Lerp(self.Animations.hover, baseColor.a, hoverColor.a),
                    math.min(baseColor.a + 20, 255)
                )
            )
            
            draw.RoundedBox(0, offsetX, offsetY, scaledW, scaledH, animColor)
            DrawBlurPanel(self)
            
            draw.SimpleText(teams_table[i].name, "ChatFont_new", w / 2, h / 2 + self.Animations.yOffset, 
                Color(198, 198, 198, 255 * currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        BREACH.Menu914Options.Users.OnCursorEntered = function(self)
            if IsValid(BREACH.Menu914Options.MainPanel) and not BREACH.Menu914Options.MainPanel.IsFadingOut then
                self.CursorOnPanel = true
            end
        end

        BREACH.Menu914Options.Users.OnCursorExited = function(self)
            self.CursorOnPanel = false
        end

        BREACH.Menu914Options.Users.DoClick = function(self)
            if IsValid(BREACH.Menu914Options.MainPanel) and BREACH.Menu914Options.MainPanel.IsFadingOut then
                return
            end

            teams_table[i].func()
            
            if IsValid(BREACH.Menu914Options.MainPanel) then
                BREACH.Menu914Options.MainPanel.IsFadingOut = true
            end
            gui.EnableScreenClicker(false)
        end
    end
end
