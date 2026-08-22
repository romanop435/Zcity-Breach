local surface = surface
local Material = Material
local draw = draw
local CurTime = CurTime;
local table = table;
local ScrW = ScrW;
local ScrH = ScrH;
local timer = timer;
local hook = hook;
local math = math;
local draw = draw;
local vgui = vgui;
local net = net




local TipPanels = {}

local clr_message = Color( 198, 198, 198 )

net.Receive("Eventmessage", function( len )

  local client = LocalPlayer()

  if ( IsValid( client.msgEvent ) ) then return end

  local msg = net.ReadString()

  surface.SetFont( "BrSoul20" )

  local msg1sizew, msg1sizeh = surface.GetTextSize( msg )

  client.msgEvent = vgui.Create( "DFrame" )
  client.msgEvent:SetPos( ( ScrW() / 2 - ( msg1sizew / 2 ) ), ( ScrH() / 1.3 ) )
  client.msgEvent:SetSize( msg1sizew + 8, msg1sizeh )
  client.msgEvent:SetTitle( "" )
  client.msgEvent.Active = RealTime() + 6
  client.msgEvent.Alpha = 0
  client.msgEvent:ShowCloseButton( false )
  client.msgEvent.Paint = function( self )

    if ( self.Active > RealTime() ) then

      self.Alpha = math.Approach( self.Alpha, 255, RealFrameTime() * 256 )

    else

      self.Alpha = math.Approach( self.Alpha, 0, RealFrameTime() * 512 )

      if ( self.Alpha == 0 ) then

        self:Remove()
        client.msgEvent = nil

      end

    end

    draw.SimpleText( msg, "BrSoul20", 2, 2, ColorAlpha( clr_message, self.Alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

  end

end)

local UpdateDelay = 0

net.Receive( "TipSend", function()

  local str1 = net.ReadString()
  local col1 = net.ReadColor()
  local str2 = net.ReadString()
  local col2 = net.ReadColor()

  timer.Simple( UpdateDelay, function()

    MakeTip( str1, col1, str2, col2 )

    if ( UpdateDelay != 1 ) then

      UpdateDelay = math.Clamp( UpdateDelay - 1, 0, 100 )

    end

  end )

  UpdateDelay = UpdateDelay + 1

end)

local TipPanels = TipPanels or {}


local blurMaterial = Material("pp/blurscreen")


local function DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local w, h = panel:GetSize()
    
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(blurMaterial)
    
    for i = 1, 3 do
        blurMaterial:SetFloat("$blur", (i / 3) * (amount or 5))
        blurMaterial:Recompute()
        
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end
end

function MakeTip(str1, col1, str2, col2)
    local lang1 = str1 or ""
    local lang2 = str2 or ""
    
    if (string.find(lang1, "[ERROR", 1, true)) then
        lang1 = str1
    end
    
    if (string.find(lang2, "[ERROR", 1, true)) then
        lang2 = str2
    end
    
    surface.SetFont("Cyb_HudTEXT")
    local s1 = surface.GetTextSize(lang1)
    local s2 = surface.GetTextSize(lang2)
    
    if (lang2 == "") then
        s2 = 0
    end
    
    
    local panelWidth = math.max(s1 + s2 + 100, 260)
    local panelHeight = 50
    
    
    local tippanel = vgui.Create("DPanel")
    TipPanels[#TipPanels + 1] = tippanel
    
    tippanel:SetSize(panelWidth, panelHeight)
    
    
    local screenwidth = ScrW()
    local screenheight = ScrH()
    
    
    local multiplier = #TipPanels
    local targetX = screenwidth - panelWidth - 4
    local targetY = screenheight / 1.2 - panelHeight * multiplier - 5 * (multiplier - 1)
    
    tippanel:SetPos(screenwidth, targetY)
    tippanel:SetZPos(32767)
    
    
    tippanel.dietime = CurTime() + 5
    tippanel.animStage = 0
    tippanel.shakeOffset = 0
    tippanel.shakeDirection = 1
    tippanel.targetX = targetX
    tippanel.targetY = targetY
    tippanel.enterStart = CurTime()
    tippanel.exitStart = nil
    tippanel.shakeTime = CurTime()
    
    
    col1 = col1 or color_white
    col2 = col2 or color_white
    local gradientcol = Color(70, 70, 70, 200)
    
    
    local maticon = Material("nextoren/gui/new_icons/notifications/breachiconfortips.png")
    
    tippanel.Paint = function(self, w, h)
        if self.dietime <= CurTime() and self.animStage == 2 then
            self:Remove()
            return
        end
        
        
        DrawBlur(self, 5)
        
        
        draw.RoundedBox(0, 0, 0, w, h, gradientcol)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        
        draw.RoundedBox(0, 0, 0, 50, 50, color_black)
        surface.SetMaterial(maticon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(2, 2, 46, 46)
        
        
        local textY = 5
        draw.DrawText(lang1, "Cyb_HudTEXT", 55, textY, col1)
        
        if lang2 ~= "" then
            draw.DrawText(lang2, "Cyb_HudTEXT", 55 + s1, textY + h/2 - 8, col2)
        end
        
        return true
    end
    
    
    tippanel.Think = function(self)
        if self.animStage == 0 then
            
            local progress = (CurTime() - self.enterStart) / 1.5
            
            if progress >= 1 then
                
                self:SetPos(self.targetX, self.targetY)
                self.animStage = 1
                self.shakeTime = CurTime() + 0.1
                self.shakeCount = 0
                self.shakeOffset = 2
                return
            end
            
            
            local easeOut = progress * progress * progress
            
            
            local shakeIntensity = progress * 2
            local shakeX = math.sin(CurTime() * 20) * shakeIntensity
            local shakeY = math.cos(CurTime() * 15) * shakeIntensity
            
            
            local startX = screenwidth
            local newX = startX + (self.targetX - startX) * easeOut
            local newY = self.targetY + shakeY
            
            self:SetPos(newX + shakeX, newY)
            
        elseif self.animStage == 1 then
            
            if CurTime() < self.shakeTime then return end
            
            local currentX = self.targetX
            local currentY = self.targetY
            
            if self.shakeCount < 3 then
                
                local offsetX = math.random(-self.shakeOffset, self.shakeOffset)
                local offsetY = math.random(-self.shakeOffset, self.shakeOffset)
                
                self:SetPos(currentX + offsetX, currentY + offsetY)
                self.shakeCount = self.shakeCount + 1
                self.shakeTime = CurTime() + 0.05
                self.shakeOffset = self.shakeOffset * 0.7
            else
                
                self:SetPos(currentX, currentY)
                self.animStage = 2
                self.pauseEnd = CurTime() + 3
            end
            
        elseif self.animStage == 2 then
            
            if CurTime() >= self.pauseEnd then
                self.animStage = 3
                self.shakeTime = CurTime() + 0.1
                self.shakeCount = 0
                self.shakeOffset = 1
            end
            
        elseif self.animStage == 3 then
            
            if CurTime() < self.shakeTime then return end
            
            local currentX = self.targetX
            local currentY = self.targetY
            
            if self.shakeCount < 2 then
                
                local offsetX = math.random(-self.shakeOffset, self.shakeOffset)
                local offsetY = math.random(-self.shakeOffset, self.shakeOffset)
                
                self:SetPos(currentX + offsetX, currentY + offsetY)
                self.shakeCount = self.shakeCount + 1
                self.shakeTime = CurTime() + 0.08
            else
                
                self:SetPos(currentX, currentY)
                self.animStage = 4
                self.exitStart = CurTime()
            end
            
        elseif self.animStage == 4 then
            
            local progress = (CurTime() - self.exitStart) / 1.5
            
            if progress >= 1 then
                self:Remove()
                return
            end
            
            
            local easeIn = progress * progress * progress
            
            
            local shakeIntensity = (1 - progress) * 2
            local shakeX = math.sin(CurTime() * 20) * shakeIntensity
            local shakeY = math.cos(CurTime() * 15) * shakeIntensity
            
            
            local endX = screenwidth
            local newX = self.targetX + (endX - self.targetX) * easeIn
            local newY = self.targetY + shakeY
            
            self:SetPos(newX + shakeX, newY)
        end
    end
    
    
    timer.Simple(7, function()
        if IsValid(tippanel) then
            tippanel:Remove()
        end
    end)
end


local nextcheck = 0
hook.Add("Think", "TipPanels_Cleanup", function()
    if nextcheck < CurTime() then
        for i = #TipPanels, 1, -1 do
            if not TipPanels[i] or not IsValid(TipPanels[i]) then
                table.remove(TipPanels, i)
            end
        end
        nextcheck = CurTime() + 1
    end
end)
