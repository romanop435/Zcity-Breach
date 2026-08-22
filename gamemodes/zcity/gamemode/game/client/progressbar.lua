local rust_panel    = Color(15, 14, 13, 220)
local rust_outline  = Color(255, 255, 255, 30)
local rust_yellow   = Color(218, 165, 32)
local rust_green    = Color(112, 126, 73)
local rust_red      = Color(188, 64, 43)



local function DrawTacticalFrame(x, y, w, h, clr, alpha)
    surface.SetDrawColor(ColorAlpha(clr, 255 * alpha))
    surface.DrawOutlinedRect(x, y, w, h, 1)
    local size = 8
    surface.DrawRect(x, y, size, 1) surface.DrawRect(x, y, 1, size)
    surface.DrawRect(x + w - size, y, size, 1) surface.DrawRect(x + w - 1, y, 1, size)
    surface.DrawRect(x, y + h - 1, size, 1) surface.DrawRect(x, y + h - size, 1, size)
    surface.DrawRect(x + w - size, y + h - 1, size, 1) surface.DrawRect(x + w - 1, y + h - size, 1, size)
end

function CreateProgressBar(client, name, time, icon)
    if IsValid(client.progressbar) then client.progressbar:Remove() end
    if IsValid(client.progressbaricon) then client.progressbaricon:Remove() end

    local sw, sh = ScrW(), ScrH()
    local barW, barH = 400, 50

    client.progressbar = vgui.Create("DPanel")
    local pnl = client.progressbar
    pnl:SetSize(barW, barH)
    pnl:SetPos(sw / 2 - barW / 2, sh * 0.8)
    pnl.name = name
    pnl.startTime = SysTime()
    pnl.duration = time
    pnl.alpha = 0
    pnl.state = "active" 

    pnl.Think = function(self)
        
        if self.state == "active" then
            self.alpha = math.Approach(self.alpha, 1, FrameTime() * 5)
        else
            self.alpha = math.Approach(self.alpha, 0, FrameTime() * 5)
            if self.alpha <= 0 then self:Remove() end
        end
    end

    pnl.Paint = function(self, w, h)
        local elapsed = SysTime() - self.startTime
        local progress = math.Clamp(elapsed / self.duration, 0, 1)
        
        
        if elapsed >= self.duration and self.state == "active" then
            self.state = "success"
            timer.Simple(1, function() if IsValid(self) then self.state = "hidden" end end)
        end

        local a = self.alpha
        local pCol = (self.state == "success") and rust_green or (self.state == "failed" and rust_red or rust_yellow)
        
        
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 220 * a)
        surface.DrawRect(0, 0, w, h)
        
        
        surface.SetDrawColor(0, 0, 0, 100 * a)
        surface.DrawRect(10, 30, w - 20, 10)
        
        surface.SetDrawColor(pCol.r, pCol.g, pCol.b, 255 * a)
        surface.DrawRect(10, 30, (w - 20) * progress, 10)

        
        draw.SimpleText(string.upper(self.name), "MM_Exp", 10, 5, ColorAlpha(color_white, 255 * a), TEXT_ALIGN_LEFT)
        draw.SimpleText(math.floor(progress * 100) .. "%", "MM_Exp", w - 10, 5, ColorAlpha(pCol, 255 * a), TEXT_ALIGN_RIGHT)

        DrawTacticalFrame(0, 0, w, h, pCol, a)
    end

    
    client.progressbaricon = vgui.Create("DPanel")
    local iconPnl = client.progressbaricon
    iconPnl:SetSize(50, 50)
    iconPnl:SetPos(sw / 2 - 200 - 60, sh * 0.8)
    iconPnl.mat = Material(icon or "nextoren/gui/new_icons/notifications/breachiconfortips.png", "smooth")
    
    iconPnl.Paint = function(self, w, h)
        if not IsValid(client.progressbar) then self:Remove() return end
        local a = client.progressbar.alpha
        surface.SetDrawColor(255, 255, 255, 255 * a)
        surface.SetMaterial(self.mat)
        surface.DrawTexturedRect(5, 5, w-10, h-10)
        DrawTacticalFrame(0, 0, w, h, rust_yellow, a)
    end
end


net.Receive("StartBreachProgressBar", function()
    local name = BREACH.TranslateString(net.ReadString())
    local time = net.ReadFloat()
    local icon = net.ReadString()
    CreateProgressBar(LocalPlayer(), name, time, icon)
end)

net.Receive("progressbarstate", function()
    local pnl = LocalPlayer().progressbar
    if not IsValid(pnl) then return end
    
    local state = net.ReadBool()
    if state then
        pnl.state = "success"
        pnl.name = "ЗАВЕРШЕНО"
    else
        pnl.state = "failed"
        pnl.name = "ОТМЕНЕНО"
    end
    
    timer.Simple(1, function() if IsValid(pnl) then pnl.state = "hidden" end end)
end)

net.Receive("StopBreachProgressBar", function()
    local client = LocalPlayer()
    if IsValid(client.progressbar) then
        
        client.progressbar.state = "failed"
        client.progressbar.name = "ОТМЕНЕНО"
        
        timer.Simple(1, function() 
            if IsValid(client.progressbar) then client.progressbar:Remove() end
            if IsValid(client.progressbaricon) then client.progressbaricon:Remove() end
        end)
    end
end)