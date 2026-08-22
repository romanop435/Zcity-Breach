local pos1 = Vector(6032.666016, -6367.041504, 0)
local pos2 = Vector(6029.106445, -6783.162598, 129)

local bMin = Vector(math.min(pos1.x, pos2.x), math.min(pos1.y, pos2.y), math.min(pos1.z, pos2.z))
local bMax = Vector(math.max(pos1.x, pos2.x), math.max(pos1.y, pos2.y), math.max(pos1.z, pos2.z))

local center = (bMin + bMax) / 2
local widthWorld = bMax.y - bMin.y
local heightWorld = bMax.z - bMin.z

local wallX = center.x
local thickness = 25
local bMinY = bMin.y - 50
local bMaxY = bMax.y + 50
local bMinZ = bMin.z - 100
local bMaxZ = bMax.z + 200

hook.Add("FinishMove", "MentalBarrier_SoftwareWall", function(ply, mv)
    if not GetGlobalBool("MentalBarrierActive", false) then return end
    if not ply:Alive() or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_OBSERVER then return end

    local pos = mv:GetOrigin()

    if pos.y >= bMinY and pos.y <= bMaxY and pos.z >= bMinZ and pos.z <= bMaxZ then
        
        if pos.x > (wallX - thickness) and pos.x < (wallX + thickness) then
            local vel = mv:GetVelocity()
            
            if pos.x >= wallX then
                pos.x = wallX + thickness
                if vel.x < 0 then vel.x = 0 end
            else
                pos.x = wallX - thickness
                if vel.x > 0 then vel.x = 0 end
            end

            mv:SetOrigin(pos)
            mv:SetVelocity(vel)
        end
    end
end)

if SERVER then
    local barrierEnt = nil

    hook.Add("Think", "MentalBarrier_PhysicalLogic", function()
        local isActive = GetGlobalBool("MentalBarrierActive", false)

        if isActive and not IsValid(barrierEnt) then


        elseif not isActive and IsValid(barrierEnt) then
            --barrierEnt:Remove()
            --barrierEnt = nil
        end
    end)

    concommand.Add("br_toggle_mental_barrier", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        local state = not GetGlobalBool("MentalBarrierActive", false)
        SetGlobalBool("MentalBarrierActive", state)
        ply:ChatPrint("Ментальный барьер изменен на: " .. tostring(state))
    end)
end
print("мяу")

if CLIENT then
    local addonName = "Hardcoded_SCP_Unrecord_Effects_Final"

    local mat_Caber = Material("effects/shaders/unrecord_vmt_chromaticaberration")
    local mat_Filmgrain = Material("effects/shaders/unrecord_vmt_filmgrain")
    local mat_Fisheye = Material("effects/shaders/unrecord_vmt_fisheye")
    local mat_Sharpen = Material("pp/sharpen")

    surface.CreateFont("Barrier_Huge", { font = "Segoe UI", size = 180, weight = 800, extended = true })
    surface.CreateFont("Barrier_Big", { font = "Segoe UI", size = 70, weight = 600, extended = true })

    local function GetDistanceToBarrier(pos)
        local cx = math.Clamp(pos.x, bMin.x, bMax.x)
        local cy = math.Clamp(pos.y, bMin.y, bMax.y)
        local cz = math.Clamp(pos.z, bMin.z, bMax.z)
        return pos:Distance(Vector(cx, cy, cz))
    end

    local rust_red    = Color(188, 64, 43)
    local rust_panel  = Color(10, 9, 8) 
    local ghost_red   = Color(255, 0, 0)
    local ghost_cyan  = Color(0, 200, 255)

    local scale = 0.05
    local w = widthWorld / scale
    local h = heightWorld / scale

    local angles = { Angle(0, 90, 90), Angle(0, -90, 90) }

    local function DrawMentalText(text, font, x, y, color, alignX, alignY, stressLevel, alphaMult)
        local offset = 20 * stressLevel

        if stressLevel > 0.1 then
            ghost_red.a = 150 * alphaMult * stressLevel
            draw.SimpleText(text, font, x - offset, y, ghost_red, alignX, alignY)
            
            ghost_cyan.a = 150 * alphaMult * stressLevel
            draw.SimpleText(text, font, x + offset, y, ghost_cyan, alignX, alignY)
        end
        
        draw.SimpleText(text, font, x, y, color, alignX, alignY)
    end

    hook.Add("RenderScreenspaceEffects", addonName, function()
        if not render.SupportsPixelShaders_2_0() then return end
        if true then return end
        
        render.UpdateScreenEffectTexture()
        mat_Fisheye:SetFloat("$c0_x", 0.03)
        render.SetMaterial(mat_Fisheye)
        render.DrawScreenQuad()
--
        render.CopyRenderTargetToTexture(render.GetScreenEffectTexture())
        mat_Sharpen:SetTexture("$fbtexture", render.GetScreenEffectTexture())
        mat_Sharpen:SetFloat("$contrast", 1.00)
        mat_Sharpen:SetFloat("$distance", 1.00 / ScrW()) 
        render.SetMaterial(mat_Sharpen)
        render.DrawScreenQuad()
--
        render.UpdateScreenEffectTexture()
        mat_Caber:SetFloat("$c0_x", -0.03)
        mat_Caber:SetInt("$c0_y", 1)
        render.SetMaterial(mat_Caber)
        render.DrawScreenQuad()
--
        render.UpdateScreenEffectTexture()
        mat_Filmgrain:SetInt("$c0_y", 2)
        mat_Filmgrain:SetFloat("$c0_z", 2.00)
        mat_Filmgrain:SetFloat("$c0_w", 0.10)
        mat_Filmgrain:SetFloat("$c1_x", 0.50)
        mat_Filmgrain:SetFloat("$c1_y", 0.50)
        render.SetMaterial(mat_Filmgrain)
        render.DrawScreenQuad()

        if not GetGlobalBool("MentalBarrierActive", false) then return end

        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        if ply:GTeam() != TEAM_CLASSD then return end
        local dist = GetDistanceToBarrier(ply:EyePos())
        
        if dist > 450 then return end 

        local alphaMult = 1 - math.Clamp((dist - 1) / 150, 0, 1)
        if alphaMult <= 0 then return end

        local stressLevel = 0
        if dist < 250 then
            stressLevel = 0
        end
        
        local jitterX = math.random(-30, 30) * stressLevel
        local jitterY = math.random(-15, 15) * stressLevel
        local heartbeat = (math.sin(CurTime() * 12) + 1) / 2

        render.SetColorMaterial()
        draw.NoTexture()

        cam.Start3D()
            cam.IgnoreZ(true)
            
            for _, ang in ipairs(angles) do
                if (ply:EyePos() - center):Dot(ang:Up()) < 0 then continue end

                cam.Start3D2D(center, ang, scale)
                    
                    local startX = -w / 2
                    local startY = -h / 2

                    surface.SetDrawColor(0, 0, 0, 180 * alphaMult)
                    surface.DrawRect(startX, startY, w, h)

                    local boxW, boxH = 3400, 480
                    local boxX = startX + w / 2 - boxW / 2 + jitterX
                    local boxY = startY + h / 2 - boxH / 2 + jitterY

                    local ghostOffset = 15 * stressLevel
                    
                    surface.SetDrawColor(0, 100, 200, 100 * alphaMult * stressLevel)
                    surface.DrawRect(boxX + ghostOffset, boxY, boxW, boxH)
                    surface.SetDrawColor(200, 0, 0, 100 * alphaMult * stressLevel)
                    surface.DrawRect(boxX - ghostOffset, boxY, boxW, boxH)

                    surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, 240 * alphaMult)
                    surface.DrawRect(boxX, boxY, boxW, boxH)

                    local redAlpha = (150 + 105 * heartbeat) * alphaMult
                    surface.SetDrawColor(rust_red.r, rust_red.g, rust_red.b, redAlpha)
                    surface.DrawRect(boxX, boxY, 30, boxH)
                    surface.DrawRect(boxX + boxW - 30, boxY, 30, boxH)

                    local cx = boxX + boxW / 2
                    local cy = boxY + boxH / 2
                    
                    DrawMentalText("Я не могу просто уйти", "Barrier_Huge", cx, cy - 100, 
                        Color(rust_red.r, rust_red.g, rust_red.b, 255 * alphaMult), 
                        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, stressLevel * 1.5, alphaMult)
                    
                    DrawMentalText("Я боюсь за свою жизнь", "Barrier_Big", cx, cy + 100, 
                        Color(230, 230, 230, 200 * alphaMult), 
                        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, stressLevel, alphaMult)

                cam.End3D2D()
            end
            
            cam.IgnoreZ(false)
        cam.End3D()
    end)
end