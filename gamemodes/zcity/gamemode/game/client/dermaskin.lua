if not CLIENT then return end


local blurMat = Material("pp/blurscreen")
local function SafeDrawBlur(panel, amount, passes)
    if DrawBlurPanel then DrawBlurPanel(panel) return end
    local x, y = panel:LocalToScreen(0, 0)
    local sw, sh = ScrW(), ScrH()
    surface.SetMaterial(blurMat)
    surface.SetDrawColor(255, 255, 255, 255)
    for i = 1, (passes or 3) do
        blurMat:SetFloat("$blur", (i / (passes or 3)) * (amount or 6))
        blurMat:Recompute()
        if render then render.UpdateScreenEffectTexture() end
        surface.DrawTexturedRect(x * -1, y * -1, sw, sh)
    end
end




local rust_bg       = Color(25, 24, 22, 245)    
local rust_panel    = Color(18, 16, 15, 255)    
local rust_row      = Color(40, 38, 35, 255)    
local rust_outline  = Color(255, 255, 255, 10)  
local rust_green    = Color(112, 126, 73)       
local rust_red      = Color(188, 64, 43)        
local rust_yellow   = Color(218, 165, 32)       
local rust_text     = Color(230, 230, 230)      
local rust_text_dim = Color(140, 140, 140)      




local SKIN = {}
SKIN.PrintName = "Utopia Breach Rust"

SKIN.fontCategory = "MM_Exp"
SKIN.fontCategoryBlur = "MM_Exp"
SKIN.fontSegmentedProgress = "MM_Exp"

SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
SKIN.Colours.Outline = rust_outline
SKIN.Colours.Background = rust_bg


SKIN.Colours.Label.Default = rust_text
SKIN.Colours.Label.Dark = rust_text          
SKIN.Colours.Label.Highlight = rust_yellow


SKIN.Colours.Button.Normal = rust_text
SKIN.Colours.Button.Hover = color_white
SKIN.Colours.Button.Down = color_white
SKIN.Colours.Button.Disabled = rust_text_dim


SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines    = Color(100, 100, 100, 150)
SKIN.Colours.Tree.Normal   = rust_text                 
SKIN.Colours.Tree.Hover    = color_white               
SKIN.Colours.Tree.Selected = rust_yellow               


SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal       = rust_text
SKIN.Colours.Properties.Line_Selected     = rust_text
SKIN.Colours.Properties.Line_Hover        = color_white
SKIN.Colours.Properties.Title             = rust_text
SKIN.Colours.Properties.Column_Normal     = rust_bg
SKIN.Colours.Properties.Column_Selected   = rust_row
SKIN.Colours.Properties.Column_Hover      = Color(50, 48, 45, 255)
SKIN.Colours.Properties.Border            = rust_outline
SKIN.Colours.Properties.Label_Normal      = rust_text
SKIN.Colours.Properties.Label_Selected    = rust_text
SKIN.Colours.Properties.Label_Hover       = color_white




function SKIN:PaintFrame(panel, w, h)
    SafeDrawBlur(panel, 5, 3)
    
    
    surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, rust_bg.a)
    surface.DrawRect(0, 0, w, h)
    
    
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, 25) 
    
    
    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
    surface.DrawRect(0, 24, w, 1)

    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintPanel(panel, w, h)
    if panel.m_bBackground then 
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 150)
        surface.DrawRect(0, 0, w, h)
    end
end




function SKIN:PaintButton(panel, w, h)
    if not panel.m_bBackground then return end
    
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    local isDown = (panel.IsDown and panel:IsDown()) or panel.Depressed or false

    local bg_color = panel:GetDisabled() and rust_panel or rust_row
    surface.SetDrawColor(bg_color.r, bg_color.g, bg_color.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    
    if panel.lerpHover > 0.01 and not panel:GetDisabled() then
        surface.SetDrawColor(255, 255, 255, 10 * panel.lerpHover)
        surface.DrawRect(0, 0, w, h)
    end

    
    if isDown and not panel:GetDisabled() then
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 50)
        surface.DrawRect(0, 0, w, h)
    end

    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end


function SKIN:PaintWindowCloseButton(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    if panel.lerpHover > 0.01 then
        surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, 255 * panel.lerpHover)
        surface.DrawRect(0, 0, w, 25) 
    end
    
    local col = Color(255, Lerp(panel.lerpHover, 255, 200), Lerp(panel.lerpHover, 255, 200))
    draw.SimpleText("✕", "MM_Exp", w / 2, 25 / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end




function SKIN:PaintTextEntry(panel, w, h)
    if panel.m_bBackground then
        surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
        surface.DrawRect(0, 0, w, h)
        
        panel.lerpFocus = panel.lerpFocus or 0
        panel.lerpFocus = Lerp(FrameTime() * 15, panel.lerpFocus, panel:HasFocus() and 1 or 0)
        
        if panel.lerpFocus > 0.01 then
            surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * panel.lerpFocus)
        else
            surface.SetDrawColor(rust_outline)
        end
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    panel:DrawTextEntryText(color_white, rust_yellow, color_white)
end




function SKIN:PaintComboBox(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    if panel.lerpHover > 0 then 
        surface.SetDrawColor(255, 255, 255, 10 * panel.lerpHover)
        surface.DrawRect(0, 0, w, h)
    end
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintComboDownArrow(panel, w, h)
    surface.SetDrawColor(rust_text_dim)
    local cx, cy = w/2, h/2
    surface.DrawLine(cx - 4, cy - 2, cx, cy + 2)
    surface.DrawLine(cx, cy + 2, cx + 4, cy - 2)
    surface.DrawLine(cx - 4, cy - 1, cx, cy + 3)
    surface.DrawLine(cx, cy + 3, cx + 4, cy - 1)
end

function SKIN:PaintCheckBox(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    panel.lerpCheck = panel.lerpCheck or 0
    panel.lerpCheck = Lerp(FrameTime() * 20, panel.lerpCheck, panel:GetChecked() and 1 or 0)

    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(255, 255, 255, 10 + (20 * panel.lerpHover))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    
    if panel.lerpCheck > 0.01 then 
        local offset = (w/2) * (1 - panel.lerpCheck)
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * panel.lerpCheck)
        surface.DrawRect(offset + 3, offset + 3, w - (offset*2) - 6, h - (offset*2) - 6) 
    end
end




function SKIN:PaintVScrollBar(panel, w, h) 
    surface.SetDrawColor(10, 10, 10, 200)
    surface.DrawRect(w / 2 - 2, 0, 4, h)
end

function SKIN:PaintScrollBarGrip(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    local isHoveredOrDrag = panel:IsHovered() or panel.Depressed or false
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, isHoveredOrDrag and 1 or 0)
    
    local c = Lerp(panel.lerpHover, 80, 120)
    surface.SetDrawColor(c, c, c, 255)
    surface.DrawRect(w / 2 - 2, 0, 4, h)
end

function SKIN:PaintButtonUp(panel, w, h) end 
function SKIN:PaintButtonDown(panel, w, h) end 

function SKIN:PaintSliderKnob(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    surface.SetDrawColor(200, 200, 200, 255)
    surface.DrawRect(2, 2, w-4, h-4)
    if panel.lerpHover > 0 then 
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 150 * panel.lerpHover)
        surface.DrawRect(2, 2, w-4, h-4)
    end
end

function SKIN:PaintNumSlider(panel, w, h) 
    surface.SetDrawColor(10, 10, 10, 255)
    surface.DrawRect(0, h/2 - 2, w, 4) 
end




function SKIN:PaintListView(panel, w, h) 
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintListViewLine(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, (panel:IsHovered() or panel:IsSelected()) and 1 or 0)
    
    if panel:IsSelected() then 
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 80 + 40 * panel.lerpHover)
        surface.DrawRect(0, 0, w, h)
    elseif panel:IsHovered() then 
        surface.SetDrawColor(255, 255, 255, 10 * panel.lerpHover)
        surface.DrawRect(0, 0, w, h)
    elseif panel.m_bAlt then 
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintListViewColumn(panel, w, h)
    surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
    surface.DrawRect(0, h - 2, w, 2)
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end




function SKIN:PaintPropertySheet(panel, w, h) end

function SKIN:PaintTab(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    if panel:IsActive() then 
        surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 255)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(0, h - 2, w, 2)
    else
        if panel.lerpHover > 0.01 then 
            surface.SetDrawColor(255, 255, 255, 10 * panel.lerpHover)
            surface.DrawRect(0, 0, w, h)
        end
    end
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintActiveTab(panel, w, h) end

function SKIN:PaintCollapsibleCategory(panel, w, h) 
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintCategoryList(panel, w, h) end

function SKIN:PaintCategoryButton(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 10, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    if panel.lerpHover > 0 then 
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 40 * panel.lerpHover)
        surface.DrawRect(0, 0, w, h)
    end
    
    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
    surface.DrawRect(0, h - 1, w, 1)
end

function SKIN:PaintExpandButton(panel, w, h)
    draw.SimpleText(panel:GetExpanded() and "-" or "+", "MM_Exp", w/2, h/2 - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end




function SKIN:PaintMenu(panel, w, h) 
    SafeDrawBlur(panel, 5, 3)
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintMenuOption(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, (panel.Hovered or panel.Highlight) and 1 or 0)

    if panel.lerpHover > 0.01 then
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 100 * panel.lerpHover)
        surface.DrawRect(1, 1, w - 2, h - 2)
    end
    panel:SetTextColor(rust_text)
end

function SKIN:PaintDivider(panel, w, h) 
    surface.SetDrawColor(rust_outline)
    surface.DrawRect(0, h/2, w, 1)
end




SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines    = Color(100, 100, 100, 150) 
SKIN.Colours.Tree.Normal   = rust_text                 
SKIN.Colours.Tree.Hover    = color_white               
SKIN.Colours.Tree.Selected = rust_yellow               




function SKIN:PaintTree(panel, w, h)
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end




function SKIN:PaintTreeNodeButton(panel, w, h)
    if not panel.m_bBackground then return end

    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)

    if panel:IsSelected() then
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 50)
        surface.DrawRect(0, 0, w, h)
        
        
        surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
        surface.DrawRect(0, 0, 2, h)
    elseif panel.lerpHover > 0.01 then
        surface.SetDrawColor(255, 255, 255, 10 * panel.lerpHover)
        surface.DrawRect(0, 0, w, h)
    end
end




function SKIN:PaintDivider(panel, w, h)
    surface.SetDrawColor(rust_row.r, rust_row.g, rust_row.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    
    surface.SetDrawColor(rust_text_dim)
    if w > h then 
        surface.DrawRect(w/2 - 10, h/2 - 1, 20, 2)
    else 
        surface.DrawRect(w/2 - 1, h/2 - 10, 2, 20)
    end
end




function SKIN:PaintFileBrowser(panel, w, h)
    surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 255)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end




function SKIN:PaintTooltip(panel, w, h)
    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 250)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(rust_outline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end


derma.DefineSkin("LegacyBreach", "Legacy Breach Theme", SKIN)
derma.RefreshSkins()


hook.Add("ForceDermaSkin", "ForceLegacyBreachSkin", function()
    return "LegacyBreach"
end)





local function UpgradeElements(panel)
    for _, child in ipairs(panel:GetChildren()) do
        local cls = child:GetClassName()
        
        
        if cls == "Label" or cls == "DLabel" or cls == "DCheckBoxLabel" then
            child:SetTextColor(rust_text)
        end
        if cls == "DComboBox" then
            child:SetTextColor(rust_text)
        end
        if cls == "DListView" then
            child:SetDrawBackground(false)
        end
        if cls == "DTextEntry" then
            child:SetTextColor(color_white)
            child:SetCursorColor(rust_yellow)
        end

        UpgradeElements(child)
    end
end

hook.Add("InitPostEntity", "InjectLegacyBreachXGUI", function()
    timer.Create("WaitForXGUI", 1, 0, function()
        if xgui and xgui.anchor then
            timer.Remove("WaitForXGUI")

            xgui.settings.skin = "LegacyBreach"
            if xgui.base and xgui.base.SetSkin then
                xgui.base:SetSkin("LegacyBreach")
            end

            local oldPaint = xgui.anchor.Paint
            xgui.anchor.Paint = function(self, w, h)
                if oldPaint then oldPaint(self, w, h) end 
                
                SafeDrawBlur(self, 8, 4)
                surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, 240)
                surface.DrawRect(0, 0, w, h)
                
                
                surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255)
                surface.DrawRect(0, 0, w, 2)
                
                surface.SetDrawColor(rust_outline)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end

            if xgui.infobar then
                xgui.infobar.Paint = function(self, w, h)
                    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 255)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(rust_outline)
                    surface.DrawRect(0, 0, w, 1)
                end
            end

            hook.Add("XLIBDoAnimation", "LegacyBreachXGUIFixer", function()
                if xgui.anchor and xgui.anchor:IsVisible() then
                    UpgradeElements(xgui.anchor)
                end
            end)
            
            UpgradeElements(xgui.anchor)
        end
    end)
end)