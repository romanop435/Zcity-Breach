if SERVER then
    return
end

-- каким то образом в шейдер не передается fogColor через register(c29) ¯\_(ツ)_/¯
matproxy.Add({
    name = "PixelatedFog",
    init = function(self, mat, values)
    end,
    bind = function(self, mat, ent)
        local r, g, b = render.GetFogColor()
        mat:SetFloat("$c2_x", r/255)
        mat:SetFloat("$c2_y", g/255)
        mat:SetFloat("$c2_z", b/255)
        mat:SetFloat("$c2_w", render.GetFogMode() - 1)
    end
})

Pixelated = Pixelated or {}

Pixelated.LAYOUT_SQUARE = 1
Pixelated.LAYOUT_OFFSET_SQUARE = 2
Pixelated.LAYOUT_ARROW = 3
Pixelated.LAYOUT_TRIANGULAR = 4

function Pixelated.CreateMaterial()
    local uid = math.floor(CurTime())

    local mat = CreateMaterial("pixelated_lcd_" .. uid, "screenspace_general", {
        ["$pixshader"] = "pixelated_effect_ps30",
        ["$vertexshader"] = "pixelated_effect_vs30",
        ["$cull"] = 1,
        ["$depthtest"] = 1,
        ["$writedepth"] = 0,

        ["$basetexture"] = "pixelated/test", // base texture
        ["$texture1"] = "pixelated/pixelstripes1", // pixel mask

        ["$linearread_basetexture"] = 0, // test
        ["$linearread_texture1"] = 0, // test

        ["$c0_x"] = 512, // basetexture width
        ["$c0_y"] = 512, // basetexture height

        ["$c0_z"] = 64, // pixel mask width
        ["$c0_w"] = 64, // pixel mask height

        ["$c1_x"] = 3, // pixel luma
        ["$c1_y"] = 1, // layout : 1 - square, 2 - offset square (offset: c1_z), 3 - arrow (offset: c1_z), 4 - triangular (offset: c1_z)
        ["$c1_z"] = 0, // layout offset

        ["$c2_x"] = 0, // fog r
        ["$c2_y"] = 0, // fog g
        ["$c2_z"] = 0, // fog b
        ["$c2_w"] = 0, // fog mode

        ["Proxies"] = {
            ["PixelatedFog"] = { // auto sets fog settings
            }
        },

        ["$vertexcolor"] = 1,
        ["$verteralpha"] = 1,

        ["$pointsample_basetexture"] = 1,
    })

    print("Pixelated - Creating material \"" .. "pixelated_lcd_" .. uid .. "\"")

    Pixelated.Material = mat

    Pixelated.PrevCull = true
    Pixelated.PrevDepthTest = true
    Pixelated.PrevWriteDepth = false

    Pixelated.PrevLinearBase = false
    Pixelated.PrevLinearMask = false

    Pixelated.PrevLuma = 3

    Pixelated.PrevLayout = 1
    Pixelated.PrevLayoutOffset = 0

    Pixelated.TextureWidth = 512
    Pixelated.TextureHeight = 512
end

function Pixelated.SetSettings(cull, depthTest, writeDepth, linearBaseTexture, linearPixelMask)
    if type(cull) ~= "boolean"              then error("Argument #1 is " .. type(cull) .. " expected boolean") end
    if type(depthTest) ~= "boolean"         then error("Argument #2 is " .. type(depthTest) .. " expected boolean") end
    if type(writeDepth) ~= "boolean"        then error("Argument #3 is " .. type(writeDepth) .. " expected boolean") end
    if type(linearBaseTexture) ~= "boolean" then error("Argument #4 is " .. type(linearBaseTexture) .. " expected boolean") end
    if type(linearPixelMask) ~= "boolean"   then error("Argument #5 is " .. type(linearPixelMask) .. " expected boolean") end

    if Pixelated.PrevCull ~= cull then
        Pixelated.PrevCull = cull

        Pixelated.Material:SetInt("$cull", cull and 1 or 0)
    end

    if Pixelated.PrevDepthTest ~= depthTest then
        Pixelated.PrevDepthTest = depthTest

        Pixelated.Material:SetInt("$depthtest", depthTest and 1 or 0)
    end

    if Pixelated.PrevWriteDepth ~= writeDepth then
        Pixelated.PrevWriteDepth = writeDepth

        Pixelated.Material:SetInt("$writedepth", writeDepth and 1 or 0)
    end

    if Pixelated.PrevLinearBase ~= linearBaseTexture then
        Pixelated.PrevLinearBase = linearBaseTexture

        Pixelated.Material:SetInt("$linearread_basetexture", linearBaseTexture and 1 or 0)
    end

    if Pixelated.PrevLinearMask ~= linearPixelMask then
        Pixelated.PrevLinearMask = linearPixelMask

        Pixelated.Material:SetInt("$linearread_texture1", linearPixelMask and 1 or 0)
    end
end

function Pixelated.SetPixelLuma(luma)
    luma = luma or Pixelated.PrevLuma

    if type(luma) ~= "number" then error("Argument #1 is " .. type(luma) .. " expected boolean") end

    if Pixelated.PrevLuma ~= luma then
        Pixelated.PrevLuma = luma

        Pixelated.Material:SetFloat("$c1_x", luma)
    end
end

function Pixelated.SetPixelLayout(typ, offset)
    typ = typ or Pixelated.PrevLayout
    offset = offset or Pixelated.PrevLayoutOffset

    if type(typ) ~= "number" then error("Argument #1 is " .. type(typ) .. " expected boolean") end
    if type(offset) ~= "number" then error("Argument #1 is " .. type(offset) .. " expected boolean") end
    
    if Pixelated.PrevLayout ~= typ then
        Pixelated.PrevLayout = typ

        Pixelated.Material:SetFloat("$c1_y", typ)
    end
    
    if Pixelated.PrevLayoutOffset ~= offset then
        Pixelated.PrevLayoutOffset = offset

        Pixelated.Material:SetFloat("$c1_z", offset)
    end
end

function Pixelated.SetPixelMask(texture, width, height)
    Pixelated.Material:SetTexture("$texture1", texture)

    -- Pixelated.Material:SetFloat("$c0_z", (width or (texture.Width and texture:Width() or 64)) * 4)
    -- Pixelated.Material:SetFloat("$c0_w", (height or (texture.Height and texture:Height() or 64)) * 4)
    Pixelated.Material:SetFloat("$c0_z", (width or (texture.Width and texture:Width() or 64)))
    Pixelated.Material:SetFloat("$c0_w", (height or (texture.Height and texture:Height() or 64)))
end

function Pixelated.SetDefaultPixelMask()
    Pixelated.Material:SetTexture("$texture1", "pixelated/pixelstripes1")

    Pixelated.Material:SetFloat("$c0_z", 64)
    Pixelated.Material:SetFloat("$c0_w", 64)
end

function Pixelated.SetBaseTexture(texture, width, height)
    Pixelated.Material:SetTexture("$basetexture", texture)

    width = width or (texture.Width and texture:Width() or 512)
    height = height or (texture.Height and texture:Height() or 512)

    Pixelated.Material:SetFloat("$c0_x", width)
    Pixelated.Material:SetFloat("$c0_y", height)

    Pixelated.TextureWidth = width
    Pixelated.TextureHeight = height
end

local render_SetMaterial = render.SetMaterial
local render_OverrideDepthEnable = render.OverrideDepthEnable
local render_SetRenderTargetEx = render.SetRenderTargetEx
local render_PushRenderTarget = render.PushRenderTarget
local render_PopRenderTarget = render.PopRenderTarget
local render_GetResolvedFullFrameDepth = render.GetResolvedFullFrameDepth
local render_PushFilterMag = render.PushFilterMag
local render_PushFilterMin = render.PushFilterMin
local render_PopFilterMag = render.PopFilterMag
local render_PopFilterMin = render.PopFilterMin
local render_DrawQuad = render.DrawQuad

local isfunction = isfunction
local isbool = isbool

local POINT = TEXFILTER.POINT
local ANISOTROPIC = TEXFILTER.ANISOTROPIC

// mat_antialias

function Pixelated.StartDraw(depthEnable)
    render_SetMaterial(Pixelated.Material)
    render_OverrideDepthEnable(true, (not isbool(depthEnable)) and true)
    render_PushFilterMag(POINT)
    render_PushFilterMin(ANISOTROPIC)
end

function Pixelated.EndDraw()
    render_OverrideDepthEnable(false, false)
    render_PopFilterMag()
    render_PopFilterMin()
end


local uid = math.floor(CurTime())
local depth_write_mat = CreateMaterial("DepthWriteMat"..uid, "DepthWrite", {
    ["$color_depth"] = 1,
    ["$nocull"] = 0,
    -- ["$cull"] = 1,
})

function Pixelated.DrawWithFunc(func, useDepthPass, depthEnable)
    local is_func_depth = isfunction(useDepthPass)
    local is_bool_depth = isbool(useDepthPass)

    Pixelated.StartDraw(depthEnable)
        func(false)
    Pixelated.EndDraw()

    if not useDepthPass then return end

    render_SetMaterial(depth_write_mat)
    render_PushRenderTarget(render_GetResolvedFullFrameDepth())
    
    if is_bool_depth then
        func(true)
    elseif is_func_depth then
        useDepthPass(true) -- separate depth func
    end

    render_PopRenderTarget()
end

local pixelated_3d2d_pos = vector_origin
local pixelated_3d2d_x_axis = vector_origin
local pixelated_3d2d_y_axis = vector_origin
local pixelated_3d2d_color = Color(255, 255, 255, 255)

-- local pixelated_3d2d_pos_x = 0
-- local pixelated_3d2d_pos_y = 0
-- local pixelated_3d2d_pos_z = 0

-- local pixelated_3d2d_x_axis_x = 0
-- local pixelated_3d2d_x_axis_y = 0
-- local pixelated_3d2d_x_axis_z = 0

-- local pixelated_3d2d_y_axis_x = 0
-- local pixelated_3d2d_y_axis_y = 0
-- local pixelated_3d2d_y_axis_z = 0

local pixelated_in_3d2d = false

local function pixelated_to_world(px, py)
    return pixelated_3d2d_pos + pixelated_3d2d_x_axis * px + pixelated_3d2d_y_axis * py
end

function Pixelated.Start3D2D(pos, ang, scale)
    if pixelated_in_3d2d then ErrorNoHaltWithStack("You forgot call Pixelated.End3D2D!") return end

    pos = pos or Vector(0, 0, 0)
    ang = ang or Angle(0, 0, 0)
    scale = scale or 1

    pixelated_3d2d_pos = pos
    pixelated_3d2d_x_axis = ang:Forward() * scale
    pixelated_3d2d_y_axis = ang:Right() * scale

    -- pixelated_3d2d_pos_x = pos.x
    -- pixelated_3d2d_pos_y = pos.y
    -- pixelated_3d2d_pos_z = pos.z

    -- pixelated_3d2d_x_axis_x = pixelated_3d2d_x_axis.x
    -- pixelated_3d2d_x_axis_y = pixelated_3d2d_x_axis.y
    -- pixelated_3d2d_x_axis_z = pixelated_3d2d_x_axis.z

    -- pixelated_3d2d_y_axis_x = pixelated_3d2d_y_axis.x
    -- pixelated_3d2d_y_axis_y = pixelated_3d2d_y_axis.y
    -- pixelated_3d2d_y_axis_z = pixelated_3d2d_y_axis.z

    pixelated_in_3d2d = true
end

function Pixelated.End3D2D()
    if not pixelated_in_3d2d then ErrorNoHaltWithStack("You forgot call Pixelated.Start3D2D!") return end

    pixelated_in_3d2d = false
end

function Pixelated.SetDrawColor(r, g, b, a)
    local is_color = IsColor(r)

    if is_color then
        pixelated_3d2d_color = r 
    else
        --Color() => This function is relatively expensive when used in rendering hooks or in operations requiring very frequent calls (like loops for example) due to object creation and garbage collection. It is better to store the color in a variable or to use the default colors available.
        
        pixelated_3d2d_color.r = r or 255
        pixelated_3d2d_color.g = g or 255
        pixelated_3d2d_color.b = b or 255
        pixelated_3d2d_color.a = a or 255
    end
end

-- local function pixelated_to_world(px, py, out)
--     out.x = pixelated_3d2d_pos_x + pixelated_3d2d_x_axis_x * px + pixelated_3d2d_y_axis_x * py
--     out.y = pixelated_3d2d_pos_y + pixelated_3d2d_x_axis_y * px + pixelated_3d2d_y_axis_y * py
--     out.z = pixelated_3d2d_pos_z + pixelated_3d2d_x_axis_z * px + pixelated_3d2d_y_axis_z * py
-- end

local tl = Vector(0, 0, 0)
local tr = Vector(0, 0, 0)
local br = Vector(0, 0, 0)
local bl = Vector(0, 0, 0)

local vgui_white = Material("vgui/white")


function Pixelated.DrawRect(x, y, w, h) -- for debug
    x = x or 0
    y = y or 0
    w = w or 0
    h = h or 0

    local tl = pixelated_to_world(x,     y)
    local tr = pixelated_to_world(x + w, y)
    local br = pixelated_to_world(x + w, y + h)
    local bl = pixelated_to_world(x,     y + h)

    render_SetMaterial(vgui_white)
    render_OverrideDepthEnable(true, false)
    render_DrawQuad(tl, tr, br, bl, pixelated_3d2d_color)
    render_OverrideDepthEnable(false, false)
    render_SetMaterial(Pixelated.Material)
end

function Pixelated.DrawTexturedRect(x, y, w, h)
    x = x or 0
    y = y or 0
    w = w or 0
    h = h or 0

    local tl = pixelated_to_world(x,     y)
    local tr = pixelated_to_world(x + w, y)
    local br = pixelated_to_world(x + w, y + h)
    local bl = pixelated_to_world(x,     y + h)
    -- pixelated_to_world(x     , y    , tl)
    -- pixelated_to_world(x + w , y    , tr)
    -- pixelated_to_world(x + w , y + h, br)
    -- pixelated_to_world(x     , y + h, bl)

    render_DrawQuad(tl, tr, br, bl, pixelated_3d2d_color)
end

local mesh_Begin = mesh.Begin
local mesh_End = mesh.End

local mesh_Position = mesh.Position
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex

local QUADS = MATERIAL_QUADS

local math_abs = math.abs
local math_floor = math.Round

-- local function getTextureSizeFromUV(origW, origH, startU, startV, endU, endV)
--     return math_floor(origW * math_abs(endU - startU)), math_floor(origH * math_abs(endV - startV))
-- end

local function getTextureSizeFromUV(origW, origH, startU, startV, endU, endV)
    return origW * math_abs(endU - startU), origH * math_abs(endV - startV)
end

function Pixelated.DrawTexturedRectUV(x, y, w, h, startU, startV, endU, endV, preserveSize)
    x = x or 0
    y = y or 0
    w = w or 0
    h = h or 0

    startU = startU or 0
    startV = startV or 0
    endU = endU or 1
    endV = endV or 1

    local tl = pixelated_to_world(x,     y)
    local tr = pixelated_to_world(x + w, y)
    local br = pixelated_to_world(x + w, y + h)
    local bl = pixelated_to_world(x,     y + h)

    if not preserveSize then
        local newW, newH = getTextureSizeFromUV(Pixelated.TextureWidth, Pixelated.TextureHeight, startU, startV, endU, endV)
    
        Pixelated.Material:SetFloat("$c0_x", newW)
        Pixelated.Material:SetFloat("$c0_y", newH)
    end

    local r = pixelated_3d2d_color.r
    local g = pixelated_3d2d_color.g
    local b = pixelated_3d2d_color.b
    local a = pixelated_3d2d_color.a

    mesh_Begin(QUADS, 1)
        mesh_Position(tl)
        mesh_TexCoord(0, startU, startV)
        mesh_Color(r, g, b, a)
        mesh_AdvanceVertex()
        
        mesh_Position(tr)
        mesh_TexCoord(0, endU  , startV)
        mesh_Color(r, g, b, a)
        mesh_AdvanceVertex()
        
        mesh_Position(br)
        mesh_TexCoord(0, endU  , endV)
        mesh_Color(r, g, b, a)
        mesh_AdvanceVertex()
        
        mesh_Position(bl)
        mesh_TexCoord(0, startU, endV)
        mesh_Color(r, g, b, a)
        mesh_AdvanceVertex()
    mesh_End()
end

Pixelated.CreateMaterial()

