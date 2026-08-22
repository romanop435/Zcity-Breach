include( "shared.lua" )

local rust_bg       = Color(25, 24, 22, 245)
local rust_panel    = Color(18, 16, 15, 245)
local rust_row      = Color(40, 38, 35, 255)
local rust_outline  = Color(255, 255, 255, 15)
local rust_green    = Color(112, 126, 73)
local rust_red      = Color(188, 64, 43)
local rust_yellow   = Color(218, 165, 32)
local rust_text     = Color(230, 230, 230)
local rust_text_dim = Color(140, 140, 140)

local function ForbidTalant()
    local is_forbidden = net.ReadBool()
    local talant_id = net.ReadUInt( 4 )

    if ( !IsValid( BREACH.Abilities ) || #BREACH.Abilities.Buttons == 0 ) then return end

    LocalPlayer():GetActiveWeapon().AbilityIcons[ talant_id ].Forbidden = is_forbidden
end
net.Receive( "ForbidTalant", ForbidTalant )

local function Ability_ClientsideCooldown()
    local abilityid = net.ReadUInt( 4 )
    local cooldown = net.ReadFloat()
    local wep = net.ReadEntity()

    wep.AbilityIcons[ abilityid ].CooldownTime = CurTime() + cooldown
end
net.Receive( "Ability_ClientsideCooldown", Ability_ClientsideCooldown )

function ShowAbilityDesc(name, text, cooldown, x, y)
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

local scpAbilityAnims = {}

function SWEP:ChooseAbility(table)
    if (IsValid(BREACH.Abilities)) then
        BREACH.Abilities:Remove()
    end

    BREACH.Abilities = vgui.Create("DPanel")
    BREACH.Abilities.AbilityIcons = table
    local numAbilities = #BREACH.Abilities.AbilityIcons
    
    scpAbilityAnims = {}
    for i = 1, numAbilities do
        scpAbilityAnims[i] = {
            press = 0,
            hover = 0,
            scale = 1,
            appear = 0,
            readyPulse = 0,
            laserProgress = 1,
            laserAlpha = 0
        }
    end

    local size = 68
    local spacing = 8
    local totalW = (size * numAbilities) + (spacing * (numAbilities - 1))
    
    BREACH.Abilities:SetPos(ScrW() / 2 - (totalW / 2), ScrH() / 1.122)
    BREACH.Abilities:SetSize(totalW, size)
    BREACH.Abilities:SetText("")
    BREACH.Abilities.SCP_Name = LocalPlayer():GetRoleName()
    BREACH.Abilities.CreationTime = CurTime()

    BREACH.Abilities.Think = function(self)
        if self.CreationTime < (CurTime() - 4) then
            for i = 1, numAbilities do
                scpAbilityAnims[i].appear = math.Approach(scpAbilityAnims[i].appear, 1, FrameTime() * 5)
            end
        end
    end

    BREACH.Abilities.Paint = function(self, w, h)
        local client = LocalPlayer()
        if (client:Health() <= 0 || client:GetRoleName() != self.SCP_Name) then
            self:Remove()
            return
        end
    end

    BREACH.Abilities.OnRemove = function()
        gui.EnableScreenClicker(false)
        if (IsValid(BREACH.Abilities) && IsValid(BREACH.Abilities.TipWindow)) then
            BREACH.Abilities.TipWindow:CloseWithAnim()
        end
    end

    for i = 1, numAbilities do
        BREACH.Abilities.Buttons = BREACH.Abilities.Buttons || {}
        BREACH.Abilities.Buttons[i] = vgui.Create("DButton", BREACH.Abilities)
        BREACH.Abilities.Buttons[i]:SetPos((size + spacing) * (i - 1), 0)
        BREACH.Abilities.Buttons[i]:SetSize(size, size)
        BREACH.Abilities.Buttons[i]:SetText("")
        BREACH.Abilities.Buttons[i].ID = i
        
        local iconmat = Material(BREACH.Abilities.AbilityIcons[i].Icon, "smooth")

        BREACH.Abilities.Buttons[i].Think = function(self)
            local client = LocalPlayer()
            local abilityData = BREACH.Abilities.AbilityIcons[i]
            local anim = scpAbilityAnims[i]
            local currentTime = CurTime()

            local press = false
            local c_key = abilityData.KEY
            
            if (isnumber(c_key) && input.IsKeyDown(c_key) && !client:IsTyping()) then
                press = true
            end
            if (c_key == "RMB" or c_key == 108) and input.IsMouseDown(MOUSE_RIGHT) then
                press = true
            end
            if (c_key == "LMB" or c_key == 107) and input.IsMouseDown(MOUSE_LEFT) then
                press = true
            end
            if press then
                anim.press = Lerp(FrameTime() * 20, anim.press, 1)
                anim.scale = Lerp(FrameTime() * 20, anim.scale, 0.9)
            else
                anim.press = Lerp(FrameTime() * 10, anim.press, 0)
                anim.scale = Lerp(FrameTime() * 15, anim.scale, 1)
            end

            if self:IsHovered() then
                anim.hover = Lerp(FrameTime() * 10, anim.hover, 1)
            else
                anim.hover = Lerp(FrameTime() * 10, anim.hover, 0)
            end
            
            local cdTime = (abilityData.CooldownTime || 0) - currentTime
            local maxCd = tonumber(abilityData.Cooldown) or 1
            if maxCd <= 0 then maxCd = 1 end

            if abilityData.Forbidden then
                anim.laserProgress = 1
                anim.laserAlpha = Lerp(FrameTime() * 10, anim.laserAlpha, 0)
                anim.readyPulse = 0
            elseif cdTime > 0 then
                local rawProgress = math.Clamp(1 - (cdTime / maxCd), 0, 1)
                
                if anim.laserProgress > 0.95 and rawProgress < 0.1 then
                    anim.laserProgress = 0
                end

                anim.laserProgress = Lerp(FrameTime() * 10, anim.laserProgress, rawProgress)
                anim.laserAlpha = Lerp(FrameTime() * 15, anim.laserAlpha, 1)
                anim.readyPulse = 0
            else
                anim.laserProgress = Lerp(FrameTime() * 15, anim.laserProgress, 1)
                anim.laserAlpha = Lerp(FrameTime() * 10, anim.laserAlpha, 0)
                
                if abilityData.Using then
                    anim.readyPulse = math.sin(currentTime * 4) * 0.5 + 0.5
                end
            end
        end

        BREACH.Abilities.Buttons[i].OnCursorEntered = function(self)
            if scpAbilityAnims[i].appear < 0.9 then return end
            surface.PlaySound("nextoren/gui/main_menu/button_hover.wav")
            ShowAbilityDesc(BREACH.Abilities.AbilityIcons[i].Name, 
                          BREACH.Abilities.AbilityIcons[i].Description, 
                          tostring(BREACH.Abilities.AbilityIcons[i].Cooldown), 
                          gui.MouseX(), (gui.MouseY() || 5))
        end

        BREACH.Abilities.Buttons[i].OnCursorExited = function()
            if (BREACH.Abilities.TipWindow) then
                BREACH.Abilities.TipWindow:CloseWithAnim()
            end
        end

        BREACH.Abilities.Buttons[i].DoClick = function()
            surface.PlaySound("nextoren/gui/main_menu/button_click.wav")
        end
        local key = BREACH.Abilities.AbilityIcons[i].KEY
        local keyTxt = "NONE"
        if (isnumber(key)) then
            keyTxt = string.upper(input.GetKeyName(key) or "NONE")
        elseif isstring(key) then
            keyTxt = string.upper(key)
        end

        BREACH.Abilities.Buttons[i].Paint = function(self, w, h)
            local client = LocalPlayer()
            local abilityData = BREACH.Abilities.AbilityIcons[i]
            local anim = scpAbilityAnims[i]

            if (!BREACH.Abilities || !abilityData) then
                self:Remove()
                return
            end

            local currentAlpha = anim.appear
            if currentAlpha <= 0.01 then return end

            local currentScale = anim.scale
            local appearScale = 0.5 + currentAlpha * 0.5
            local finalScale = currentScale * appearScale
            
            local finalW = w * finalScale
            local finalH = h * finalScale
            local finalX = (w - finalW) / 2
            local finalY = (h - finalH) / 2

            local cdTime = (abilityData.CooldownTime || 0) - CurTime()
            local isReady = (cdTime <= 0 and not abilityData.Forbidden)

            surface.SetDrawColor(15, 15, 15, 240 * currentAlpha)
            surface.DrawRect(finalX, finalY, finalW, finalH)

            if iconmat and not iconmat:IsError() then
                surface.SetDrawColor(255, 255, 255, 255 * currentAlpha)
                surface.SetMaterial(iconmat)
                surface.DrawTexturedRectUV(finalX, finalY, finalW, finalH, 0.06, 0.06, 0.94, 0.94)
            end

            if anim.press > 0 then
                surface.SetDrawColor(0, 0, 0, 180 * anim.press * currentAlpha)
                surface.DrawRect(finalX, finalY, finalW, finalH)
            end

            if anim.laserAlpha > 0.01 then
                local coverH = finalH * (1 - anim.laserProgress)

                surface.SetDrawColor(5, 5, 5, 210 * currentAlpha * anim.laserAlpha)
                surface.DrawRect(finalX, finalY, finalW, coverH)

                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 50 * currentAlpha * anim.laserAlpha)
                surface.DrawRect(finalX, finalY + coverH - 4, finalW, 4)

                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * currentAlpha * anim.laserAlpha)
                surface.DrawRect(finalX, finalY + coverH - 1, finalW, 1)

                if cdTime > 0 then
                    local cdText = math.Round(cdTime, 1)
                    draw.SimpleTextOutlined(cdText, "MM_Exp", w / 2, h / 2, Color(255, 255, 255, 255 * currentAlpha * anim.laserAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200 * currentAlpha * anim.laserAlpha))
                end
            end

            if abilityData.Forbidden and anim.laserAlpha < 0.99 then
                local emptyAlpha = (1 - anim.laserAlpha) * currentAlpha
                surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 120 * emptyAlpha)
                surface.DrawRect(finalX, finalY, finalW, finalH)
                
                local display_text = "BLOCKED"
                if (client:GetRoleName() == "SCP973") then
                    local primary_wep = client:GetWeapon("weapon_scp_973")
                    if (primary_wep && primary_wep:IsValid()) then
                        local number_cooldown = tonumber(abilityData.Cooldown)
                        if ((primary_wep:GetRage() || 0) < number_cooldown) then
                            display_text = tostring(math.Round(number_cooldown - primary_wep:GetRage()))
                        end
                    end
                end

                draw.SimpleTextOutlined(display_text, "MM_SmallName", w / 2, h / 2, Color(255, 100, 100, 255 * emptyAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200 * emptyAlpha))
            end

            surface.SetDrawColor(255, 255, 255, 15 * currentAlpha)
            surface.DrawOutlinedRect(finalX, finalY, finalW, finalH, 1)

            if isReady and abilityData.Using then
                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * currentAlpha)
                surface.DrawRect(finalX, finalY + finalH - 3, finalW, 3)
                
                if anim.readyPulse > 0 then
                    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 30 * anim.readyPulse * currentAlpha)
                    surface.DrawOutlinedRect(finalX - 1, finalY - 1, finalW + 2, finalH + 2, 2)
                end
            end

            if anim.hover > 0 then
                surface.SetDrawColor(255, 255, 255, 10 * anim.hover * currentAlpha)
                surface.DrawRect(finalX, finalY, finalW, finalH)
                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 150 * anim.hover * currentAlpha)
                surface.DrawOutlinedRect(finalX, finalY, finalW, finalH, 1)
            end

            draw.NoTexture()

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

            if (self.PaintOverride && isfunction(self.PaintOverride)) then
                self:PaintOverride(w, h)
            end
        end
    end
end

function SWEP:OnRemove()
    if ( self.RemoveCustomFunc && isfunction( self.RemoveCustomFunc ) ) then
        self.RemoveCustomFunc()
    end
end

function SWEP:Holster()
    if ( self.RemoveCustomFunc && isfunction( self.RemoveCustomFunc ) ) then
        self.RemoveCustomFunc()
    end
end

function SWEP:DrawHUD()
    if ( !IsValid( BREACH.Abilities ) ) then
        self:ChooseAbility( self.AbilityIcons )
    end

    if ( input.IsKeyDown( KEY_F3 ) && ( self.NextPush || 0 ) <= CurTime() ) then
        self.NextPush = CurTime() + .5
        gui.EnableScreenClicker( !vgui.CursorVisible() )
    end
end