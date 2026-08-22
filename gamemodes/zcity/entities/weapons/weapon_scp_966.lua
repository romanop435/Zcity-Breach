SWEP.Category = "BREACH SCP"
SWEP.PrintName = "SCP-966"
SWEP.Base = "breach_scp_base"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawCrosshair = false
SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.HoldType = "scp966"
SWEP.maxs = Vector( 8, 10, 5 )

SWEP.AbilityIcons = {
    {
        ["Name"] = "Sleep Deprivation",
        ["Description"] = "Лишить сна (Навести на человека).",
        ["Cooldown"] = 1,
        ["CooldownTime"] = 0,
        ["KEY"] = _G["KEY_R"],
        ["Using"] = false,
        ["Icon"] = "nextoren/gui/special_abilities/966_1.png", 
    },
}

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextGrab")
end

function SWEP:Deploy()
    self:SetHoldType( self.HoldType )

    if SERVER then
        self.Owner:DrawWorldModel( false )
        self.Owner:SetNWBool("IsSCP966", true)

        hook.Add("PlayerButtonDown", "SCP_966_Abilities_" .. self:EntIndex(), function(ply, butt)
            if not IsValid(ply) or ply:GetRoleName() ~= "SCP966" then return end
            local wep = ply:GetActiveWeapon()
            if not IsValid(wep) or wep:GetClass() ~= "weapon_scp_966" then return end

            if butt == KEY_R and wep.AbilityIcons[1].CooldownTime < CurTime() then
                local tr = util.TraceLine({
                    start = ply:GetShootPos(),
                    endpos = ply:GetShootPos() + ply:GetAimVector() * 150,
                    filter = ply,
                    mask = MASK_SHOT
                })

                local target = tr.Entity
                if IsValid(target) and target:IsPlayer() and target:GTeam() ~= TEAM_SCP and target:Alive() then
                    if target:GetNWBool("SCP966_Insomniac", false) then
                        ply:ChatPrint("Эта жертва уже лишена сна.")
                        return
                    end

                    target:SetNWBool("SCP966_Insomniac", true)
                    wep.AbilityIcons[1].CooldownTime = CurTime() + wep.AbilityIcons[1].Cooldown
                    BREACH.SendClientEvent(ply, "ability_cooldown", {index = 1, seconds = wep.AbilityIcons[1].Cooldown})
                    
                    ply:EmitSound("nextoren/scp/966/Echo"..math.random(0,2)..".ogg", 75, math.random(90, 110))
                    ply:ChatPrint("Вы лишили сна: " .. target:Name())
                end
            end
        end)
    end

    if CLIENT then
        local clr_red = Color(180, 0, 0, 200)
        hook.Add("PreDrawOutlines", "SCP966_BloodESP_" .. self:EntIndex(), function()
            local client = LocalPlayer()
            if not IsValid(client) or client:Health() <= 0 or client:GetRoleName() ~= "SCP966" then return end

            local to_draw = {}
            for _, v in player.Iterator() do
                if v:GetNWFloat("SCP966_BleedTimer", 0) > CurTime() and v:Alive() and v:GTeam() ~= TEAM_SCP then
                    if client:CanSee(v) then
                        table.insert(to_draw, v)
                    end
                end
            end

            if #to_draw > 0 and outline then
                outline.Add(to_draw, clr_red, OUTLINE_MODE_VISIBLE)
            end
        end)
    end
end

function SWEP:Holster()
    if self.RemoveCustomFunc and isfunction(self.RemoveCustomFunc) then
        self.RemoveCustomFunc()
    end

    if SERVER and IsValid(self.Owner) then
        self.Owner:SetNWBool("IsSCP966", false)
    end
    return true
end

function SWEP:OnRemove()
    if self.RemoveCustomFunc and isfunction(self.RemoveCustomFunc) then
        self.RemoveCustomFunc()
    end

    if SERVER and IsValid(self.Owner) then
        self.Owner:SetNWBool("IsSCP966", false)
    end
    
    hook.Remove("PlayerButtonDown", "SCP_966_Abilities_" .. self:EntIndex())
    
    if CLIENT then
        hook.Remove("PreDrawOutlines", "SCP966_BloodESP_" .. self:EntIndex())
    end
end

local prim_maxs = Vector(12, 12, 12)
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + 1.2 )

    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = trace.start + self.Owner:GetAimVector() * 70
    trace.filter = self.Owner
    trace.mins = -prim_maxs
    trace.maxs = prim_maxs

    self.Owner:LagCompensation( true )
    trace = util.TraceHull( trace )
    self.Owner:LagCompensation( false )

    local target = trace.Entity

    if SERVER and self.Owner.PlayGestureSequence then
        local anim = math.random(1, 2) == 1 and "attack1" or "attack2"
        self.Owner:PlayGestureSequence(anim, GESTURE_SLOT_ATTACK_AND_RELOAD, true)
    end

    if IsValid(target) and target:IsPlayer() and target:Health() > 0 and target:GTeam() ~= TEAM_SCP then
        
        if SERVER then
            self.Owner:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav", 75, 100)
            
            local org = target.organism
            if org and hg and hg.organism and hg.organism.AddWoundManual then
                hg.organism.AddWoundManual(target, 20, vector_origin, angle_zero, trace.PhysicsBone or 0, CurTime())
                org.painadd = org.painadd + 20
                org.fearadd = org.fearadd + 1
            end

            target:SetNWFloat("SCP966_BleedTimer", CurTime() + 30)

            local d = DamageInfo()
            d:SetDamage(10)
            d:SetDamageType(DMG_SLASH)
            d:SetAttacker(self.Owner)
            d:SetInflictor(self)
            d:SetDamageForce(self.Owner:GetAimVector() * 100)
            target:TakeDamageInfo(d)
            
            target:ViewPunch(Angle(math.random(-5, 5), math.random(-5, 5), 0))
        end

    else
        self.Owner:EmitSound( "npc/zombie/claw_miss"..math.random( 1, 2 )..".wav" )
    end
end

function SWEP:SecondaryAttack()
end

SWEP.NextAuraSound = 0

function SWEP:Think()
    if CLIENT then return end

    if CurTime() > self.NextAuraSound then
        self.NextAuraSound = CurTime() + math.random(5, 10)
        
        for _, v in ipairs(ents.FindInSphere(self.Owner:GetPos(), 400)) do
            if IsValid(v) and v:IsPlayer() and v:GTeam() ~= TEAM_SCP and v:GTeam() ~= TEAM_SPEC and v:Alive() then
                net.Start("ForcePlaySound")
                net.WriteString("nextoren/scp/966/Echo"..math.random(0,2)..".ogg")
                net.Send(v)
            end
        end
    end
end

if SERVER then
    local sleep_phrases = {
        "Я так хочу спать...",
        "Глаза сами закрываются...",
        "Если я сейчас закрою глаза, я умру?",
        "Слишком... устал...",
        "Тело не слушается... хочу уснуть.",
    }

    hook.Add("Org Think", "SCP966_InsomniaLogic", function(owner, org, timeValue)
        if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
        
        if owner:GetNWBool("SCP966_Insomniac", false) then
            
            if org.stamina and org.stamina[1] then
                org.stamina[1] = math.max(org.stamina[1] - (timeValue * 3), 5)
            end

            org.disorientation = math.min(org.disorientation + (timeValue * 0.1), 16)

            owner.nextSleepMsg = owner.nextSleepMsg or 0
            if CurTime() > owner.nextSleepMsg then
                owner.nextSleepMsg = CurTime() + math.random(15, 30)
                owner:Notify(sleep_phrases[math.random(#sleep_phrases)], 6, "966_sleep", 0, nil, Color(200, 200, 255))
                
                if ThatPlyIsFemale then
                    local snd = ThatPlyIsFemale(owner) and "breathing/exhale/female/exhale_0"..math.random(5)..".wav" or "breathing/exhale/male/exhale_0"..math.random(5)..".wav"
                    owner:EmitSound(snd, 60)
                end
            end
        end
    end)

    hook.Add("PlayerDeath", "SCP966_ResetInsomnia", function(ply)
        ply:SetNWBool("SCP966_Insomniac", false)
        ply:SetNWFloat("SCP966_BleedTimer", 0)
    end)
end

hook.Add("CalcMainActivity", "SCP966_CustomAnimations", function(ply, velocity)
    if not IsValid(ply) or ply:Health() <= 0 then return end
    if not ply:GetNWBool("IsSCP966") then return end
    if ply:GetModel() ~= "models/1000shells/scp966/scp_966.mdl" then return end

    local seq = -1
    local len = velocity:Length2D()

    if ply:Crouching() then
        seq = ply:LookupSequence("idle_crouch")
    elseif not ply:IsOnGround() then
        seq = ply:LookupSequence("jump_melee")
    elseif len > 150 then
        seq = ply:LookupSequence("run_all")
    elseif len > 5 then
        seq = ply:LookupSequence("run_all")
    else
        seq = ply:LookupSequence("idle1")
    end

    if seq ~= -1 then
        ply.CalcIdeal = ACT_HL2MP_IDLE
        ply.CalcSeqOverride = seq
        return ply.CalcIdeal, ply.CalcSeqOverride
    end
end)

hook.Add("UpdateAnimation", "SCP966_AnimRate", function(ply, velocity, maxSeqGroundSpeed)
    if ply:GetNWBool("IsSCP966") and ply:GetModel() == "models/1000shells/scp966/scp_966.mdl" then
        local len = velocity:Length2D()
        if len > 5 and ply:IsOnGround() then
            local rate = len / (maxSeqGroundSpeed > 0 and maxSeqGroundSpeed or 150)
            ply:SetPlaybackRate(math.Clamp(rate, 0.5, 2))
            return true
        end
    end
end)

if CLIENT then
    local Hallucinations966 = {}
    
    local insomniac_phrases = {
        "сонный...", "хочет спать", "он уже не жилец", "устал", "глаза закрываются", "МЯСО", "засыпает...", "слабеет"
    }

    local function GlitchText(str)
        local out = ""
        for i = 1, utf8.len(str) do
            local char = utf8.sub(str, i, i)
            if math.random(1, 100) < 15 then
                char = string.upper(char)
            elseif math.random(1, 100) < 10 then
                char = table.Random({"?", ".", "†", "X", "#", "!", "/"})
            end
            out = out .. char
        end
        return out
    end

    function SWEP:DrawHUD()
        if not IsValid(BREACH.Abilities) and self.AbilityIcons then
            self:ChooseAbility(self.AbilityIcons)
        end

        if input.IsKeyDown(KEY_F3) and (self.NextPush or 0) <= CurTime() then
            self.NextPush = CurTime() + 0.5
            gui.EnableScreenClicker(not vgui.CursorVisible())
        end

        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        local curTime = CurTime()
        local frameTime = FrameTime()
        local ents_in_range = ents.FindInSphere(ply:GetPos(), 2000)
        local eyePos = ply:EyePos()
        local eyeFwd = ply:EyeAngles():Forward()

        for _, ent in ipairs(ents_in_range) do
            if not IsValid(ent) or not ent:IsPlayer() or ent == ply or not ent:Alive() then continue end
            if not ent:GetNWBool("SCP966_Insomniac", false) then continue end
            
            local targetEnt = (hg and hg.GetCurrentCharacter) and hg.GetCurrentCharacter(ent) or ent
            if not IsValid(targetEnt) then continue end

            local center = targetEnt:WorldSpaceCenter()
            local dist = eyePos:Distance(center)
            if dist > 2000 then continue end

            ent.SCP966_NextWord = ent.SCP966_NextWord or 0
            if curTime > ent.SCP966_NextWord then
                local spawnDelay = math.Rand(0.4, 1.2)
                ent.SCP966_NextWord = curTime + spawnDelay

                table.insert(Hallucinations966, {
                    target = targetEnt,
                    text = GlitchText(insomniac_phrases[math.random(#insomniac_phrases)]),
                    lifeTime = math.Rand(2.0, 4.0),
                    spawnTime = curTime,
                    offset = Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-10, 40)),
                    velocity = Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(5, 15)),
                    baseScale = math.Rand(0.1, 0.3)
                })
            end
        end

        for i = #Hallucinations966, 1, -1 do
            local word = Hallucinations966[i]
            local age = curTime - word.spawnTime
            local progress = age / word.lifeTime

            if progress >= 1 or not IsValid(word.target) then
                table.remove(Hallucinations966, i)
                continue
            end

            word.velocity = word.velocity + VectorRand() * frameTime * 15
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

            local scale = math.Clamp(800 / dist, 0.4, 2.5) * word.baseScale
            local font = "DermaLarge"
            
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
            
            local layers = 3
            for layer = 1, layers do
                local jX = math.random(-1, 1) * (layer - 1) * 2
                local jY = math.random(-1, 1) * (layer - 1) * 2
                local c = Color(r, g, b, finalAlpha / layer)
                
                draw.DrawText(word.text, font, jX, jY, c, TEXT_ALIGN_LEFT)
            end

            DisableClipping(false)
            cam.PopModelMatrix()
            
            render.PopFilterMin()
            render.PopFilterMag()
        end
    end
end