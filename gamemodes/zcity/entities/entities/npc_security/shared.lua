AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Охранник Зоны"
ENT.Category = "My Custom Bots"
ENT.Spawnable = true

if SERVER then
    util.AddNetworkString("Nextbot_YellChat")

    function ENT:Initialize()
        self:SetModel("models/rainval_breach/1000shells/charachers/guards/guard-escort.mdl")
        self:SetHealth(150)
        self:SetNWString("BotName", "Victor Orr")

        self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionGroup(COLLISION_GROUP_PLAYER)

        self.SightDistance = 800
        self.WarningDistance = 120
        self.MaxChaseDistanceSq = 400 * 400
        self.MaxWarnings = 2       
        
        self.PlayerWarnings = {}   
        self.HostilePlayers = {}   
        
        self.NextWarningTime = 0
        self.WarningCooldown = 5.0
        self.NextAttackTime = 0
        self.CurrentBotState = ""

        self.SpawnPos = self:GetPos()
        self.SpawnAng = self:GetAngles()

        if not self.WeaponEquipped then
            self:EquipWeapon("models/cultist/items/taser/w_taser_small.mdl", false)
        end
    end

    function ENT:EquipWeapon(model, isSMG)
        self.IsSMGGuard = isSMG
        self.WeaponEquipped = true

        if IsValid(self.WeaponEntity) then self.WeaponEntity:Remove() end

        self.WeaponEntity = ents.Create("prop_dynamic")
        self.WeaponEntity:SetModel(model)
        self.WeaponEntity:Spawn()
        
        timer.Simple(0.1, function()
            if not IsValid(self) or not IsValid(self.WeaponEntity) then return end
            
            local att = self:LookupAttachment("anim_attachment_RH")
            if att > 0 then
                self.WeaponEntity:SetParent(self)
                self.WeaponEntity:Fire("setparentattachment", "anim_attachment_RH")
            else
                local bone = self:LookupBone("ValveBiped.Bip01_R_Hand")
                if bone then
                    self.WeaponEntity:SetParent(self, bone)
                    if !isSMG then
                        self.WeaponEntity:SetLocalAngles(Angle(90, 90, 180))
                        self.WeaponEntity:SetLocalPos(Vector(4, 1.5, 0)) 
                    else
                        self.WeaponEntity:SetLocalPos(Vector(4, 1.5, 0)) 
                        self.WeaponEntity:SetLocalAngles(Angle(0, 90, 180))
                    end
                else
                    self.WeaponEntity:SetParent(self)
                    self.WeaponEntity:AddEffects(EF_BONEMERGE)
                end
            end
        end)
    end

    function ENT:CheckProximity()
        for _, ply in player.Iterator() do
            if not ply:Alive() or IsValid(ply.FakeRagdoll) or ply:GetObserverMode() ~= OBS_MODE_NONE then continue end

            local distSq = self:GetPos():DistToSqr(ply:GetPos())
            if distSq < (self.WarningDistance * self.WarningDistance) and not self.HostilePlayers[ply] then
                if CurTime() > self.NextWarningTime then
                    self.PlayerWarnings[ply] = (self.PlayerWarnings[ply] or 0) + 1
                    
                    local randomSounds = {
                        "utopia/npc/angry_security/security_go_out_1.ogg",
                        "utopia/npc/angry_security/security_go_out_2.ogg",
                        "utopia/npc/angry_security/security_go_out_3.ogg",
                        "utopia/npc/angry_security/security_go_out_4.ogg",
                    }
                    self:EmitSound(randomSounds[math.random(1, #randomSounds)], 80, 100, 1, CHAN_VOICE)

                    net.Start("Nextbot_YellChat")
                    net.WriteEntity(self)
                    net.Broadcast()
                    
                    self.NextWarningTime = CurTime() + self.WarningCooldown

                    if self.PlayerWarnings[ply] >= self.MaxWarnings then
                        self.HostilePlayers[ply] = true
                    end
                end
            end
        end
    end

    function ENT:FindTarget()
        local bestTarget = nil
        local bestDistSq = 99999999

        for ply, isHostile in pairs(self.HostilePlayers) do
            if not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then
                self.HostilePlayers[ply] = nil
                self.PlayerWarnings[ply] = nil
                continue
            end

            if ply:GetPos():DistToSqr(self.SpawnPos) > self.MaxChaseDistanceSq then
                self.HostilePlayers[ply] = nil
                self.PlayerWarnings[ply] = nil
                continue
            end

            if isHostile then
                local distSq = self:GetPos():DistToSqr(ply:GetPos())
                if distSq < bestDistSq and self:IsLineOfSightClear(ply) then
                    bestTarget = ply
                    bestDistSq = distSq
                end
            end
        end
        return bestTarget
    end

    function ENT:ShootTarget(target)
        local shootPos = IsValid(self.WeaponEntity) and self.WeaponEntity:GetPos() or (self:GetPos() + Vector(0, 0, 55))
        local dir = (target:GetPos() + Vector(0, 0, 45) - shootPos):GetNormalized()

        local bullet = {
            Num = 1,
            Src = shootPos,
            Dir = dir,
            Spread = Vector(0.05, 0.05, 0),
            Tracer = 1,
            TracerName = "Tracer",
            Force = 5,
            Damage = 12,
            Attacker = self
        }

        self:FireBullets(bullet)
        self:EmitSound("zcitysnd/sound/weapons/mp5k/mp5k_suppressed_fp.wav", 90, 100, 1, CHAN_WEAPON) 

        self:AddGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1)
    end

    function ENT:MeleeTaserAttack(target)
        self:SetBotAnim("attack", "idle_slam", false)

        self:EmitSound("weapons/tazer_sound.wav", 80, 100, 1, CHAN_WEAPON)
        timer.Simple(0.4, function() 
            if IsValid(self) then self:StopSound("weapons/tazer_sound.wav") end 
        end)
        
        timer.Simple(0.3, function()
            if IsValid(self) then self.CurrentBotState = "" end
            if not IsValid(self) or not IsValid(target) then return end
            if self:GetPos():DistToSqr(target:GetPos()) > 10000 then return end

            local org = target.organism
            if org then
                org.painadd = org.painadd + 10
                org.shock = org.shock + 15
                hg.StunPlayer(target, 5)
            end

            local zap = ents.Create("point_tesla")
            if IsValid(zap) then
                zap:SetKeyValue("targetname", "teslab")
                zap:SetKeyValue("m_SoundName", "")
                zap:SetKeyValue("texture", "sprites/physbeam.spr")
                zap:SetKeyValue("m_Color", "210 200 255")
                zap:SetKeyValue("m_flRadius", "15")
                zap:SetPos(target:GetPos() + Vector(0,0,40))
                zap:Spawn()
                zap:Fire("DoSpark", "", 0)
                zap:Fire("kill", "", 0.1)
            end
        end)
    end

    function ENT:SetBotAnim(state, actOrSeq, isActivity)
        if self.CurrentBotState == state then return end
        self.CurrentBotState = state
        
        if isActivity then
            self:StartActivity(actOrSeq)
        else
            local seq = self:LookupSequence(actOrSeq)
            if seq and seq > 0 then
                self:ResetSequence(seq)
            else
                self:StartActivity(ACT_HL2MP_RUN_PISTOL)
            end
        end
    end

    function ENT:RunBehaviour()
        while true do
            self:CheckProximity()
            local target = self:FindTarget()

            if IsValid(target) then
                local attackDistSq = self.IsSMGGuard and 250000 or 7000
                local distToTargetSq = self:GetPos():DistToSqr(target:GetPos())

                if distToTargetSq < attackDistSq and self:IsLineOfSightClear(target) then 
                    self.loco:SetVelocity(Vector(0,0,0))
                    self.loco:FaceTowards(target:GetPos())
                    
                    if CurTime() > self.NextAttackTime then
                        if self.IsSMGGuard then
                            self:SetBotAnim("attack", ACT_HL2MP_IDLE_SMG1, true)
                            self:ShootTarget(target)
                            self.NextAttackTime = CurTime() + 0.1
                        else
                            self:MeleeTaserAttack(target)
                            self.NextAttackTime = CurTime() + 2.5
                        end
                    else
                        if self.CurrentBotState ~= "attack" then
                            self:SetBotAnim("idle", self.IsSMGGuard and ACT_HL2MP_IDLE_SMG1 or "idle_slam", self.IsSMGGuard)
                        end
                    end
                else
                    self:SetBotAnim("run", self.IsSMGGuard and ACT_HL2MP_RUN_SMG1 or "run_slam", self.IsSMGGuard)
                    
                    local dir = (target:GetPos() - self:GetPos())
                    dir.z = 0
                    dir:Normalize()
                    self.loco:SetVelocity(dir * 250)
                    self.loco:FaceTowards(target:GetPos())
                end
            else
                local distToHome = self:GetPos():DistToSqr(self.SpawnPos)
                
                if distToHome > 500 then
                    self:SetBotAnim("walk", self.IsSMGGuard and ACT_HL2MP_WALK_SMG1 or "walk_slam", self.IsSMGGuard)
                    
                    local dir = (self.SpawnPos - self:GetPos())
                    dir.z = 0
                    dir:Normalize()
                    self.loco:SetVelocity(dir * 100)
                    self.loco:FaceTowards(self.SpawnPos)
                else
                    self.loco:SetVelocity(Vector(0,0,0))
                    self:SetBotAnim("idle", self.IsSMGGuard and ACT_HL2MP_IDLE_SMG1 or "idle_slam", self.IsSMGGuard)
                    self.loco:FaceTowards(self:GetPos() + self.SpawnAng:Forward() * 100)
                end
            end
            
            coroutine.yield()
        end
    end

    function ENT:BodyUpdate()
        self:FrameAdvance()
    end

    function ENT:OnKilled(dmginfo)
        if IsValid(self.WeaponEntity) then
            self.WeaponEntity:Remove()
        end

        local corpse = ents.Create("prop_ragdoll")
        if IsValid(corpse) then
            corpse:SetModel(self:GetModel())
            corpse:SetPos(self:GetPos())
            corpse:SetAngles(self:GetAngles())
            corpse:SetSkin(self:GetSkin())
            
            for _, v in pairs(self:GetBodyGroups()) do
                corpse:SetBodygroup(v.id, self:GetBodygroup(v.id))
            end
            
            corpse:Spawn()
            corpse:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
            
            local velocity = self:GetVelocity()
            self:SetupBones()
            
            for i = 0, corpse:GetPhysicsObjectCount() - 1 do
                local phys = corpse:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    local boneIndex = corpse:TranslatePhysBoneToBone(i)
                    local pos, ang = self:GetBonePosition(boneIndex)
                    if pos and ang then
                        phys:SetPos(pos)
                        phys:SetAngles(ang)
                    end
                    phys:SetVelocity(velocity)
                end
            end

            corpse.breachsearchable = true
            corpse.IsLootingBy = {}
            corpse.vtable = {}
            corpse.vtable.Entity = corpse
            corpse.vtable.Name = self:GetNWString("BotName", "Victor Orr")
            
            local randomCard = math.random(1, 2) == 1 and "breach_keycard_security_1" or "breach_keycard_security_2"

            corpse.vtable.Items = {
                [1] = { class = "item_radio" },
                [2] = { class = "item_tazer", Clip = 2 },
                [3] = { class = randomCard },
            }

            corpse.Ammo = {
                [game.GetAmmoID("SMG1")] = 60
            }
            corpse.vtable.Ammo = corpse.Ammo
            corpse.__Team = 7
            corpse.IsZombie = false
            corpse.IsFemale = false
            corpse.LastHit = HITGROUP_CHEST
            corpse:SetNWInt("TaizerCount", 15)
            corpse:SetNWString("DeathReason1", "l:body_bullets")
            corpse:SetNWInt("DiedWhen", os.time())
        end

        self:Remove()
    end
end

if CLIENT then
    function ENT:Draw() self:DrawModel() end

    local offset = Vector(0, 0, 85)
    local nicknamecolor = Color(255, 255, 255, 220)

    hook.Add("PostDrawTranslucentRenderables", "TargetID_Nextbot_Security", function()
        local client = LocalPlayer()
        if not IsValid(client) or client:GTeam() == TEAM_SPEC then return end
        
        local tr = client:GetEyeTraceNoCursor()
        local ent = tr.Entity

        if not IsValid(ent) or ent:GetClass() ~= "npc_security" then return end
        if ent:Health() < 0 or ent:GetNoDraw() then return end

        local distSqr = ent:GetPos():DistToSqr(client:GetPos())
        if distSqr > 40000 then return end

        local ang = client:EyeAngles()
        local pos = ent:GetPos() + offset + ang:Up()

        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        local nickp = ent:GetNWString("BotName", "Victor Orr")

        cam.Start3D2D(pos, ang, 0.1)
            draw.DrawText(nickp, "char_title", 0, 22, nicknamecolor, TEXT_ALIGN_CENTER)
            draw.DrawText("/// НЕ ИГРОК ///", "char_title", 0, 62, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end)

net.Receive("Nextbot_YellChat", function()
    local bot = net.ReadEntity()
    if not IsValid(bot) then return end

    local botName = bot:GetNWString("BotName", "Victor Orr")
    local messageText = "Отойди от меня!"

    local av = vgui.Create("DModelPanel")
    av:SetSize(74, 74)
    av:SetModel(bot:GetModel() or "models/player/kleiner.mdl")
    av:SetSkin(bot:GetSkin() or 0)
    for i = 0, 18 do
        av.Entity:SetBodygroup(i, bot:GetBodygroup(i) or 0)
    end
    
    local head = av.Entity:LookupBone("ValveBiped.Bip01_Head1")
    if head then
        local headpos = av.Entity:GetBonePosition(head)
        av:SetLookAt(headpos + Vector(0,1,0))
        av:SetCamPos(headpos + Vector(15, -11, 4))
    else
        av:SetLookAt(Vector(10,0,60))
        av:SetCamPos(Vector(45,0,60))
    end

    av.Paint = function(self, w, h)
        if not IsValid(self.Entity) then return end
        local p = self:GetParent()
        local a = 255
        while IsValid(p) do
            a = math.min(a, p:GetAlpha())
            p = p:GetParent()
        end
        if a <= 0 then return end 
        
        local x, y = self:LocalToScreen(0, 0)
        render.SetBlend(a / 255)
        cam.Start3D(self.vCamPos, (self.vLookatPos - self.vCamPos):Angle(), self.fFOV, x, y, w, h, 5, self.FarZ)
            cam.IgnoreZ(true)
            render.SuppressEngineLighting(true)
            render.SetLightingOrigin(self.Entity:GetPos())
            render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
            render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
            self:DrawModel()
            render.SuppressEngineLighting(false)
            cam.IgnoreZ(false)
        cam.End3D()
        render.SetBlend(1)
    end

    local rawText = "[НЕ ИГРОК] " .. botName .. " крикнул:\n" .. messageText

    if LOUNGE_CHAT and LOUNGE_CHAT.AddToChatbox then
        local tab = {
            {pre = av, space = 4},
            Color(188, 64, 43), "[НЕ ИГРОК] ",
            Color(112, 126, 73), botName,
            Color(198, 198, 198, 180), " крикнул:",
            {linebreak = true},
            Color(255, 100, 100), "''" .. messageText .. "''",
            {origtext = rawText}
        }
        
        LOUNGE_CHAT:AddToChatbox(LOUNGE_CHAT:ParseLineWrap(tab, true, nil, nil, false))
        
        if chat.OldAddText then
            chat.OldAddText(
                Color(188, 64, 43), "[НЕ ИГРОК] ",
                Color(112, 126, 73), botName,
                Color(198, 198, 198, 180), " крикнул:\n",
                Color(255, 100, 100), "''" .. messageText .. "''"
            )
        end
    else
        av:Remove()
        chat.AddText(
            Color(188, 64, 43), "[НЕ ИГРОК] ",
            Color(112, 126, 73), botName,
            Color(198, 198, 198, 180), " крикнул:\n",
            Color(255, 100, 100), "''" .. messageText .. "''"
        )
    end
    end)
end

if SERVER then
    function SpawnSec()
        local function createGuard(name, pos, ang, wepModel, isSMG)
            local bot = ents.Create("npc_security")
            if IsValid(bot) then
                bot:SetPos(pos)
                bot:SetAngles(ang)
                bot:Spawn()
                bot:SetNWString("BotName", name)
                
                bot:EquipWeapon(wepModel, isSMG)
            end
        end

        createGuard("Victor Orr", Vector(6922.387695,-5479.717285,195.536041), Angle(2.067374, -90.974251, 0),"models/cultist/items/taser/w_taser_small.mdl", false)
        createGuard("Anton Orr", Vector(6832.283203,-5514.558594,195.266891), Angle(0,-2.081352,0), "models/cultist/items/taser/w_taser_small.mdl", false)
        createGuard("Stony Orr", Vector(6889.242676,-5525.990723,194.679382), Angle(0,-57.176006,0), "models/weapons/zcity/w_mp5_sef.mdl", true)
    end
end