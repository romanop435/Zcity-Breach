if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "SCP-215"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

if CLIENT then
    SWEP.InvIcon = Material("nextoren/gui/new_icons/scp/215.png")
    SWEP.IconOverride = "nextoren/gui/new_icons/scp/215.png"
    SWEP.red = "SCP"
    SWEP.BounceWeaponIcon = false
end

SWEP.HoldType = "normal" 
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/scp_items/215/w_215.mdl"
SWEP.WorldModelReal = "models/cultist/scp_items/215/v_215.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.setlh = true
SWEP.setrh = false
SWEP.UseHands = true
SWEP.HoldAng = Angle(0, 30, 10) 
SWEP.HoldPos = Vector(5, 0, 0)

SWEP.droppable = true
SWEP.UnDroppable = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

SWEP.AnimList = {
    ["deploy"] = {"draw", 0.5, false},
    ["idle"] = {"idle", 5, true},
    ["use"] = {"puton", 1.5, false},
    ["unuse"] = {"putoff", 1.5, false}
}

SWEP.Friendly_Teams = {
    [TEAM_CB or 0]      = { [TEAM_GUARD or 0] = true, [TEAM_SCI or 0] = true, [TEAM_SPECIAL or 0] = true, [TEAM_NTF or 0] = true, [TEAM_OBR or 0] = true, [TEAM_CB or 0] = true },
    [TEAM_GUARD or 0]   = { [TEAM_SCI or 0] = true, [TEAM_SPECIAL or 0] = true, [TEAM_CB or 0] = true, [TEAM_NTF or 0] = true, [TEAM_OBR or 0] = true, [TEAM_GUARD or 0] = true },
    [TEAM_CLASSD or 0]  = { [TEAM_CHAOS or 0] = true },
    [TEAM_SCI or 0]     = { [TEAM_GUARD or 0] = true, [TEAM_CB or 0] = true, [TEAM_SCI or 0] = true, [TEAM_NTF or 0] = true, [TEAM_OBR or 0] = true, [TEAM_SPECIAL or 0] = true },
    [TEAM_SPECIAL or 0] = { [TEAM_GUARD or 0] = true, [TEAM_CB or 0] = true, [TEAM_SCI or 0] = true, [TEAM_NTF or 0] = true, [TEAM_OBR or 0] = true, [TEAM_SPECIAL or 0] = true },
    [TEAM_CHAOS or 0]   = { [TEAM_CLASSD or 0] = true }
}

function SWEP:InitializeAdd()
    self:SetHold(self.HoldType)
    self:SetNWBool("IsActive", false)
    self:SetNWFloat("Sanity", 0)
end

function SWEP:Deploy()
    self.Initialzed = true
    self:SetHold(self.HoldType)
    self:PlayAnim("deploy")
    if SERVER then
        self:GetOwner():EmitSound("weapons/m249/handling/m249_armmovement_02.wav", 75, math.random(100, 120), 1, CHAN_WEAPON)
    end
    return true
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + 2)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local active = self:GetNWBool("IsActive", false)

    if not active then
        self:PlayAnim("use")
        timer.Simple(1, function()
        self:SetNWBool("IsActive", true)
        end)
        self.droppable = false
        self.UnDroppable = true

        if CLIENT then
            owner:ScreenFade(SCREENFADE.OUT, Color(0,0,0,150), 1, 1)
            timer.Simple(1, function()
              owner:ScreenFade(SCREENFADE.IN, Color(0,0,0,150), 1, 1)
            end)
            timer.Simple(1.5, function()
                if IsValid(self) and self:GetNWBool("IsActive", false) and IsValid(owner) and owner:Health() > 0 then
                end
            end)
        end
    else
        self:PlayAnim("unuse")
        timer.Simple(0.2, function()
        self:SetNWBool("IsActive", false)
        end)
        self.droppable = true
        self.UnDroppable = false

        if CLIENT then
            owner:ScreenFade(SCREENFADE.OUT, Color(0,0,0,150), 1, 1)
            timer.Simple(1, function()
              owner:ScreenFade(SCREENFADE.IN, Color(0,0,0,150), 1, 1)
            end)
        end
    end
end

function SWEP:SecondaryAttack() return false end

function SWEP:ThinkAdd()
    local active = self:GetNWBool("IsActive", false)
    local owner = self:GetOwner()


    if SERVER and active and IsValid(owner) then
        self.NextSanityUp = self.NextSanityUp or 0
        if CurTime() > self.NextSanityUp then
            self.NextSanityUp = CurTime() + 0.25
            
            local currentSanity = self:GetNWFloat("Sanity", 0)
            currentSanity = currentSanity + 1.25 
            self:SetNWFloat("Sanity", currentSanity)

            if currentSanity >= 100 then
                if owner:Alive() then owner:Kill() end
                self:SetNWFloat("Sanity", 0)
                self:SetNWBool("IsActive", false)
            end
        end
    end
end

function SWEP:DrawPostWorldModel()
    local wm = self:GetWM()
    if IsValid(wm) then
        if self:GetNWBool("IsActive", false) then
            if not wm.IsHiddenCustom then
                wm.IsHiddenCustom = true
                wm:SetNoDraw(true)
            end
        else
            if wm.IsHiddenCustom then
                wm.IsHiddenCustom = nil
                wm:SetNoDraw(false)
            end
        end
    end
end

function SWEP:DeactivateEffect()
    self:SetNWBool("IsActive", false)
    self:SetNWFloat("Sanity", 0)
    self.droppable = true
    self.UnDroppable = false
    local owner = self:GetOwner()
    if CLIENT and IsValid(owner) then
        owner:ScreenFade(SCREENFADE.IN, color_black, 0.5, 1)
    end
end

function SWEP:Holster()
    if self:GetNWBool("IsActive", false) then self:DeactivateEffect() end
    return true
end

function SWEP:OnDrop()
    if self:GetNWBool("IsActive", false) then self:DeactivateEffect() end
end

function SWEP:OnRemove()
    if self:GetNWBool("IsActive", false) then self:DeactivateEffect() end
end

if CLIENT then
    local hud_lerp = 0
    local Hallucinations = {}

    local friendly_phrases = {
        "свой...", "друг", "безопасен", "защити его", "чист"
    }
    
    local friendly_paranoia = {
        "он лжёт", "предатель?", "смотрит на тебя", "убей и его", "одинаковые"
    }

    local hostile_phrases = {
        "ЖЕРТВА", "МЯСО", "ВРАГ", "УБЕЙ", "ЧУЖОЙ", "КРОВЬ", "ОПАСНОСТЬ", "ВИЖУ ЕГО"
    }

    local function GlitchText(str, sanity)
        if sanity < 40 then return str end
        local out = ""
        for i = 1, utf8.len(str) do
            local char = utf8.sub(str, i, i)
            if math.random(1, 100) < sanity / 3 then
                char = string.upper(char)
            elseif math.random(1, 100) < sanity / 6 then
                char = table.Random({"?", ".", "†", "X", "#", "!", "/"})
            end
            out = out .. char
        end
        return out
    end

    hook.Add("RenderScreenspaceEffects", "SCP215_Paranoia_Screen", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_scp_215" then return end
        if not wep:GetNWBool("IsActive", false) then return end

        local sanity = wep:GetNWFloat("Sanity", 0)
        local fac = sanity / 100

        local tab = {
            ["$pp_colour_addr"] = fac * 0.15,       
            ["$pp_colour_addg"] = fac * 0.02,       
            ["$pp_colour_addb"] = -fac * 0.1,       
            ["$pp_colour_brightness"] = -fac * 0.1, 
            ["$pp_colour_contrast"] = 1 + fac * 0.4, 
            ["$pp_colour_colour"] = 1 - fac * 0.6,  
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)

        if fac > 0.1 then
            DrawMotionBlur(0.1, 0.8 + fac * 0.15, 0.01)
        end
        
        if fac > 0.5 then
            DrawToyTown(2, fac * ScrH() / 2.5)
        end
    end)

    function SWEP:DrawHUD()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        local isActive = self:GetNWBool("IsActive", false)
        local sanity = self:GetNWFloat("Sanity", 0)
        local sanity_fac = sanity / 100

        local w, h = ScrW(), ScrH()
        local curTime = CurTime()
        local frameTime = FrameTime()

        if isActive then
            local ents_in_range = ents.FindInSphere(ply:GetPos(), 2000)
            local cTeam = (ply.GTeam and ply:GTeam()) or ply:Team()
            local eyePos = ply:EyePos()
            local eyeFwd = ply:EyeAngles():Forward()

            for _, ent in ipairs(ents_in_range) do
                if not IsValid(ent) or not ent:IsPlayer() or ent == ply or not ent:Alive() then continue end
                
                local eTeam = (ent.GTeam and ent:GTeam()) or ent:Team()
                if eTeam == TEAM_SPEC or eTeam == 1002 then continue end

                local targetEnt = (hg and hg.GetCurrentCharacter) and hg.GetCurrentCharacter(ent) or ent
                if not IsValid(targetEnt) then continue end

                local center = targetEnt:WorldSpaceCenter()
                local dist = eyePos:Distance(center)
                if dist > 2000 then continue end

                ent.SCP215_NextWord = ent.SCP215_NextWord or 0
                if curTime > ent.SCP215_NextWord then
                    local spawnDelay = math.Rand(0.4, 1.2) / (1 + sanity_fac * 3)
                    ent.SCP215_NextWord = curTime + spawnDelay

                    local is_friendly = (self.Friendly_Teams[cTeam] and self.Friendly_Teams[cTeam][eTeam])
                    
                    local phraseList = hostile_phrases
                    if is_friendly then
                        phraseList = (sanity > 60 and math.random(1, 3) == 1) and friendly_paranoia or friendly_phrases
                    end

                    table.insert(Hallucinations, {
                        target = targetEnt,
                        text = GlitchText(phraseList[math.random(#phraseList)], sanity),
                        lifeTime = math.Rand(2.0, 4.0),
                        spawnTime = curTime,
                        offset = Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-10, 40)),
                        velocity = Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(5, 15)),
                        is_friendly = is_friendly,
                        baseScale = math.Rand(0.1, 0.3)
                    })
                end
            end

            for i = #Hallucinations, 1, -1 do
                local word = Hallucinations[i]
                local age = curTime - word.spawnTime
                local progress = age / word.lifeTime

                if progress >= 1 or not IsValid(word.target) then
                    table.remove(Hallucinations, i)
                    continue
                end

                word.velocity = word.velocity + VectorRand() * frameTime * (15 + sanity_fac * 30)
                word.offset = word.offset + word.velocity * frameTime

                local worldPos = word.target:WorldSpaceCenter() + word.offset
                
                local dirToWord = (worldPos - eyePos):GetNormalized()
                if eyeFwd:Dot(dirToWord) < 0 then continue end

                local screen = worldPos:ToScreen()
                if not screen.visible then continue end

                local dist = eyePos:Distance(worldPos)
                
                local alphaCurve = math.sin(progress * math.pi)
                local baseAlpha = math.Clamp(255 - (dist / 2000) * 255, 0, 255)
                local finalAlpha = baseAlpha * alphaCurve * 0.8 

                local r, g, b = 180, 20, 20 
                if word.is_friendly then
                    if sanity <= 60 then
                        r, g, b = 180, 200, 180 
                    else
                        r, g, b = 200, 180, 50  
                    end
                end

                local scale = math.Clamp(800 / dist, 0.4, 2.5) * word.baseScale
                local font = sanity > 60 and (math.random(1,3)==1 and "DermaLarge" or "Trebuchet24") or "DermaLarge"
                
                surface.SetFont(font)
                local tW, tH = surface.GetTextSize(word.text)
                
                local m = Matrix()
                m:Translate(Vector(screen.x, screen.y, 0))
                m:Scale(Vector(scale, scale, 1))
                m:Translate(Vector(-tW / 2, -tH / 2, 0))
                
                render.PushFilterMag(TEXFILTER.ANISOTROPIC)
                render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                
                cam.PushModelMatrix(m)
                
                DisableClipping(true)
                
                local layers = sanity > 40 and 3 or 1
                for layer = 1, layers do
                    local jX = math.random(-1, 1) * (layer - 1) * (sanity_fac * 2)
                    local jY = math.random(-1, 1) * (layer - 1) * (sanity_fac * 2)
                    local c = Color(r, g, b, finalAlpha / layer)
                    
                    draw.DrawText(word.text, font, jX, jY, c, TEXT_ALIGN_LEFT)
                end

                DisableClipping(false)
                cam.PopModelMatrix()
                
                render.PopFilterMin()
                render.PopFilterMag()
            end
        else
            if #Hallucinations > 0 then
                table.Empty(Hallucinations)
            end
        end
    end
end