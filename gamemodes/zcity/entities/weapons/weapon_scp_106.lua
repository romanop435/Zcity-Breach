SWEP.AbilityIcons = {
    {
        Name = "Ghost mode",
        Description = "None provided",
        Cooldown = 10,
        KEY = _G["KEY_R"],
        Icon = "nextoren/gui/special_abilities/scp_106_new_1.png"
    },
    {
        Name = "Shadow attack",
        Description = "None provided",
        Cooldown = 10,
        KEY = _G["KEY_J"],
        Icon = "nextoren/gui/special_abilities/scp_106_new_2.png"
    },
    {
        Name = "Zone Teleport",
        Description = "Teleport to a selected zone.",
        Cooldown = 30,
        KEY = _G["KEY_B"],
        Icon = "nextoren/gui/special_abilities/scp_106_new_3.png"
    },
    {
        Name = "Stalk Prey",
        Description = "Teleport to a random human below surface.",
        Cooldown = 90,
        KEY = _G["KEY_N"],
        Icon = "nextoren/gui/special_abilities/scp_106_new_4.png"
    }
}

SWEP.ZoneTeleportSpawns = {
    ["LCZ"] = {
        {pos = Vector(8806.29, -4772.6, 1.33), ang = Angle(0, 90, 0)},
        {pos = Vector(9388.2, -4721.78, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(8775.79, -3403.47, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(8167.69, -3496.93, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(8139.61, -2694.94, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(8079.48, -2245, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(7103.94, -2229.03, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(5987.21, -2215.2, 1.32), ang = Angle(0, 180, 0)},
        {pos = Vector(5477.1, -2218.42, 2.03), ang = Angle(0, 180, 0)},
        {pos = Vector(5143.43, -3073.47, 2.03), ang = Angle(0, 180, 0)},
        {pos = Vector(8794.38, -2829, 1.33), ang = Angle(0, 180, 0)},
        {pos = Vector(9612.04, -1237.9, 1.33), ang = Angle(0, 180, 0)},
    },
    ["HCZ"] = {
        {pos = Vector(8167.43, -3.09, 1.02), ang = Angle(0, 0, 0)},
        {pos = Vector(8167.07, 1035.52, -0.97), ang = Angle(0, -90, 0)},
        {pos = Vector(8647.25, 1479.87, 3.03), ang = Angle(0, -90, 0)},
        {pos = Vector(6575.64, 634.73, 0.03), ang = Angle(0, -90, 0)},
        {pos = Vector(4338.94, 1425.68, -0.12), ang = Angle(0, -90, 0)},
        {pos = Vector(2974.96, 952.96, -0.97), ang = Angle(0, -90, 0)},
        {pos = Vector(4212.08, -1441.1, 0.03), ang = Angle(0, -90, 0)},
        {pos = Vector(4678.73, 2795.77, 142.03), ang = Angle(0, -90, 0)},
        {pos = Vector(7455.9, 2919.55, -0.97), ang = Angle(0, -90, 0)},
        {pos = Vector(6511.96, 1203.19, -447.97), ang = Angle(0, -90, 0)},
        {pos = Vector(4411.75, -31.32, 0.03), ang = Angle(0, -90, 0)},
        {pos = Vector(3333.78, 3106.27, 142.03), ang = Angle(0, -90, 0)},
        {pos = Vector(7161.84, 3662.6, -0.97), ang = Angle(0, -90, 0)},
    },
    ["EZ"] = {
        {pos = Vector(855.06, 3640.95, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(195.67, 3657.77, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-434.27, 2371.12, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-1024.86, 1826.47, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-2361.11, 1815.31, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-2736.36, 2189.24, 256.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-2808.55, 4946.24, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-1957.15, 5812.39, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-1661.44, 4592.06, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(-444.17, 3683.08, 0.03), ang = Angle(0, 45, 0)},
        {pos = Vector(111.71, 3314.52, -127.97), ang = Angle(0, 45, 0)},
        {pos = Vector(868.75, 1833.37, 0.03), ang = Angle(0, 45, 0)},
    }
}

SWEP.PrintName = "SCP-106"
SWEP.HoldType = "scp106"
SWEP.Base = "breach_scp_base"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/items/blue_screwdriver/w_screwdriver.mdl"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    timer.Simple(3,function()
        self.AbilityIcons[1].CooldownTime = CurTime() + 120
        self.AbilityIcons[2].CooldownTime = CurTime() + 120
        self.AbilityIcons[3].CooldownTime = CurTime() + 120
        self.AbilityIcons[4].CooldownTime = CurTime() + 120
    end)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "GhostMode")
    self:NetworkVar("Bool", 1, "InDimension")
    self:SetGhostMode(false)
    self:SetInDimension(false)
end

if SERVER then
    util.AddNetworkString("SCP106_ZoneTeleport")

    net.Receive("SCP106_ZoneTeleport", function(len, ply)
        local zone = net.ReadString()
        local wep = ply:GetActiveWeapon()
        
        if not IsValid(wep) or wep:GetClass() ~= "weapon_scp_106" then return end
        if not wep.AbilityIcons or not wep.AbilityIcons[3] then return end

        if wep:GetGhostMode() or ply:GetInDimension() then return end
        
        if (wep.AbilityIcons[3].CooldownTime or 0) > CurTime() or wep.AbilityIcons[3].Forbidden then return end

        local spawns = wep.ZoneTeleportSpawns[zone]
        if not spawns or #spawns == 0 then 
            ply:ChatPrint("Координаты для этой зоны не настроены!")
            return 
        end

        local selected = table.Random(spawns)

        wep.AbilityIcons[3].CooldownTime = CurTime() + wep.AbilityIcons[3].Cooldown

        wep:ZoneTeleportSequence(selected.pos, selected.ang)
    end)

    function Stuck(ply, pos)
        local t = {}
        t.start 	= pos or ply:GetPos()
        t.endpos 	= t.start
        t.filter 	= ply
        t.mask 		= MASK_PLAYERSOLID
        t.mins 		= ply:OBBMins()
        t.maxs 		= ply:OBBMaxs()
        t = util.TraceHull(t)
        
        local ent = t.Entity
        return t.StartSolid or (ent and (ent:IsWorld() or IsValid(ent)))
    end

    function FindPassableSpace(ply, direction, step)
        local OldPos = ply:GetPos()
        local Origin = ply:GetPos()
        
        for i = 1, 11 do
            Origin = Origin + (step * direction)
            if not Stuck(ply,Origin) then return true, Origin end
        end
        
        return false, OldPos
    end

    function UnStuck(ply, ang, scale)
        local NewPos = ply:GetPos()
        local OldPos = NewPos
        
        if not Stuck(ply) then return end
        local Ang = ang or ply:GetAngles()
        
        local Forward 	= Ang:Forward()
        local Right 	= Ang:Right()
        local Up 		= Ang:Up()
        
        local SearchScale = scale or 3
        local Found
        
        Found, NewPos = FindPassableSpace(ply, Forward, -SearchScale)
        if not Found then
            Found, NewPos = FindPassableSpace(ply, Right, SearchScale)
            if not Found then
                Found, NewPos = FindPassableSpace(ply, Right, -SearchScale)
                if not Found then
                    Found, NewPos = FindPassableSpace(ply, Up, -SearchScale)
                    if not Found then
                        Found, NewPos = FindPassableSpace(ply, Up, SearchScale)
                        if not Found then
                            Found, NewPos = FindPassableSpace(ply, Forward, SearchScale)
                            if not Found then
                                return false
                            end
                        end
                    end
                end
            end
        end
        
        if OldPos == NewPos then
            return false
        else        
            ply:SetPos(NewPos)
            return true
        end
    end

    local test_106_pos = {
        Vector(-2092.832031, 9035.246094, -245),
    }
    local horror_tbl = {
        "nextoren/others/horror/horror_0.ogg",
        "nextoren/others/horror/horror_1.ogg",
        "nextoren/others/horror/horror_2.ogg",
        "nextoren/others/horror/horror_3.ogg",
        "nextoren/others/horror/horror_4.ogg",
        "nextoren/others/horror/horror_5.ogg",
        "nextoren/others/horror/horror_9.ogg",
        "nextoren/others/horror/horror_10.ogg",
        "nextoren/others/horror/horror_16.ogg"
    }

    util.AddNetworkString("DimensionSequence")
    function CheckLabirintRandom(player, origin, blink_random, initial_pos)
        local all_good = false
        local protect_counter = 0
        while not all_good do
            protect_counter = protect_counter + 1
            if protect_counter > 4000 then break end
            
            local random_vector = table.Random(test_106_pos)
            BREACH.SendClientEvent(player, "play_sound", {sound = table.Random(horror_tbl)})
           
            if not origin then
                player:SetPos(random_vector)
                if player:GTeam() ~= TEAM_SCP then CreateSearchSequence(player, random_vector, initial_pos) end
                if not Stuck(player) then
					all_good = true
				else
                    UnStuck(player)
					all_good = true
				end
            else
                if origin:DistToSqr(random_vector) <= 1048576 then 
                    continue
                end
                return random_vector
            end
        end
    end

    function CreateSearchSequence(player, player_pos, initial_pos)
        local body_origin = CheckLabirintRandom(false, player_pos)
        player:PlayMusic(BR_MUSIC_DIMENSION_SCP106)
        net.Start("DimensionSequence")
        net.WriteVector(body_origin)
        net.WriteBool(true)
        net.Send(player)
    end

    function SWEP:TeleportSequence(victim)
        if not (victim and victim:IsValid()) then return end
        victim:SetForcedAnimation("0_106_victum", 1.25, function()
            victim:SetMoveType(MOVETYPE_OBSERVER)
            victim:SetNWEntity("NTF1Entity", victim)
           
            timer.Simple(.25, function() if victim and victim:IsValid() and victim:Health() > 0 and victim:GTeam() ~= TEAM_SPEC then victim:ScreenFade(SCREENFADE.OUT, color_black, .1, 2.25) end end)
        end, function()
            victim:SetMoveType(MOVETYPE_WALK)
            victim:SetNWEntity("NTF1Entity", NULL)
            CheckLabirintRandom(victim, nil, nil, victim:GetPos())
            if victim.Teleported then victim.Teleported = nil end
        end)
    end

    function SWEP:OwnerTeleport(b_origin, b_leave)
        if not b_origin then
            self.Owner:SetForcedAnimation("0_106_new_despawn_1", 2, function()
                self.Owner:Freeze(true)
                self.Owner:SetNotSolid(true)
                self.Owner:SetNWBool("CloakSAM", true)
                
                if not self:GetInDimension() then
                    self.DimensionEnterPosition = self.Owner:GetPos()
                end

                self:DrawTeleportDecal(self.Owner)
                timer.Simple(1.8, function() if self and self:IsValid() then self.Owner:ScreenFade(SCREENFADE.OUT, color_black, .1, 1.1) end end)
            end, function()
                if not b_leave then
                    CheckLabirintRandom(self.Owner)
                else
                    self.Owner:SetPos(self.DimensionEnterPosition)
                    self.DimensionEnterPosition = nil
                end

                self:DrawTeleportDecal(self.Owner)
                self.Owner:SetForcedAnimation("0_106_new_spawn_1", 4.25, function()
                    self:EmitSound("nextoren/scp/106/decay0.ogg", 75, 100, 1, CHAN_STATIC)
                    self.Owner:EmitSound("nextoren/scp/106/laugh.ogg", 75, 100, 1, CHAN_VOICE)
                    self.Owner:SetNWBool("CloakSAM", false)
                end, function()
                    if b_leave then
                        self.Owner:SetNotSolid(false)
                        for i = 1, #self.AbilityIcons do
                            if self.ForbidAbility then self:ForbidAbility(i, false) end
                        end
                    else
                        self.Owner:SetNotSolid(true)
                    end

                    self.Owner:Freeze(false)
                end)
            end)
        else
            self:DrawTeleportDecal(self.Owner)
            self.Owner:ScreenFade(SCREENFADE.OUT, color_black, .1, 1)
            self.Owner:SetForcedAnimation("0_106_new_spawn_1", 4.25, function()
                self:SetGhostMode(false)
                self.Owner:SetNWBool("CloakSAM", false)

                timer.Simple(7, function()
                    if (self and self:IsValid()) and (self.Owner and self.Owner:IsValid()) then
                        self.Owner:SetRunSpeed(125)
                        self.Owner:SetWalkSpeed(125)
                    end
                end)

                sound.Play("nextoren/scp/106/decay0.ogg", self:GetPos() + vector_up * 24, 80, math.random(90, 100), 1)
                self.Owner:EmitSound("nextoren/scp/106/laugh.ogg", 75, 100, 1, CHAN_VOICE)
                self.Owner:SetNoDraw(false)
            end, function()
                self.Owner:Freeze(false)
                self.Owner:SetNotSolid(false)
                
                self.Owner.Block_Use = nil
                for i = 1, #self.AbilityIcons do
                    if self.ForbidAbility then self:ForbidAbility(i, false) end
                end
            end)
        end
    end

    function SWEP:ZoneTeleportSequence(pos, ang)
        if not IsValid(self.Owner) then return end

        for i = 1, #self.AbilityIcons do
            if self.ForbidAbility then self:ForbidAbility(i, true) end
        end

        self.Owner:SetForcedAnimation("0_106_new_despawn_2", 2, function()
            self.Owner:Freeze(true)
            self.Owner:SetNotSolid(true)
            
            self:DrawTeleportDecal(self.Owner)
            
            timer.Simple(1.8, function() 
                if IsValid(self) and IsValid(self.Owner) then 
                    self.Owner:ScreenFade(SCREENFADE.OUT, color_black, 0.1, 1.1) 
                end 
            end)
        end, function()
            if not IsValid(self.Owner) then return end

            self.Owner:SetPos(pos)
            if ang then self.Owner:SetEyeAngles(ang) end

            self:DrawTeleportDecal(self.Owner)

            self.Owner:SetForcedAnimation("0_scp_106_spawn", 4.25, function()
                self:EmitSound("nextoren/scp/106/decay0.ogg", 75, 100, 1, CHAN_STATIC)
                self.Owner:EmitSound("nextoren/scp/106/laugh.ogg", 75, 100, 1, CHAN_VOICE)
                self.Owner:SetNWBool("CloakSAM", false)
            end, function()
                if not IsValid(self.Owner) then return end

                self.Owner:SetNotSolid(false)
                self.Owner:Freeze(false)

                for i = 1, #self.AbilityIcons do
                    if self.ForbidAbility then self:ForbidAbility(i, false) end
                end
            end)
        end)
    end

    function SWEP:DrawTeleportDecal(origin_ent, offset, with_trap, distant_attack)
        if not origin_ent:IsPlayer() then return end
        local trace = {} 
        trace.start = origin_ent:GetShootPos() + (offset or vector_origin)
        trace.endpos = trace.start - (vector_up * 36200)
        trace.filter = origin_ent
        trace.mask = MASK_SHOT
        if distant_attack then
            local decal_origin = trace.start
            local check_trace = {}
            check_trace.start = decal_origin - origin_ent:GetForward() * 64
            check_trace.endpos = check_trace.start + origin_ent:GetForward() * 70
            check_trace.filter = origin_ent
            check_trace.mask = MASK_SHOT
            check_trace = util.TraceLine(check_trace)
            if check_trace.HitWorld or (check_trace.Entity and check_trace.Entity:IsValid()) and check_trace.Entity:GetClass():find("door") then
                timer.Remove("SCP106_RangeAttack")
                return
            end

            trace = util.TraceLine(trace)
            local shadoweffect = EffectData()
            shadoweffect:SetOrigin(trace.HitPos + trace.HitNormal)
            local recipients = RecipientFilter()
            recipients:AddAllPlayers()
            util.Effect("scp106_shadowattack", shadoweffect, true, recipients)
            if with_trap then
                local ents_withinadecal = ents.FindInSphere(decal_origin, 30)
                for i = 1, #ents_withinadecal do
                    local ent = ents_withinadecal[i]
                    if ent:IsPlayer() and not (ent:GTeam() == TEAM_SPEC or ent:GTeam() == TEAM_SCP) and not ent.Teleported then
                        ent.Teleported = true
                        self:TeleportSequence(ent)
                        util.Decal("Decal106", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, ent)
                    end
                end
            end
        else
            trace = util.TraceLine(trace)
            util.Decal("Decal106", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, origin_ent)
        end

        sound.Play("nextoren/scp/106/decay" .. math.random(1, 3) .. ".ogg", trace.HitPos + vector_up * 18, 75, math.random(90, 100), 1)
    end

    function SWEP:DistantAttack()
        self.Owner:SetForcedAnimation("0_106_new_range_attack", 3.5, function()
            self.Owner:Freeze(true)
            local unique_id = "SCP106_RangeAttack"
            local i = 1
            timer.Create(unique_id, 1.3, 1, function()
                if not (self and self:IsValid()) or self.Owner:Health() <= 0 or self.Owner:GTeam() ~= TEAM_SCP or self.Owner:GetRoleName() ~= "SCP106" then
                    timer.Remove(unique_id)
                    return
                end

                timer.Create(unique_id, .1, 24, function()
                    if not (self and self:IsValid()) or self.Owner:Health() <= 0 or self.Owner:GTeam() ~= TEAM_SCP or self.Owner:GetRoleName() ~= "SCP106" then
                        timer.Remove(unique_id)
                        return
                    end

                    local player_angles = self.Owner:GetAngles()
                    self:DrawTeleportDecal(self.Owner, self.Owner:GetForward() * (48 * i) + player_angles:Right() * 20 - player_angles:Forward() * 12, true, true)
                    i = i + 1
                end)
            end)
        end, function()
            self.Owner:Freeze(false)
            for i = 1, #self.AbilityIcons do
                if self.ForbidAbility then self:ForbidAbility(i, false) end
            end
        end)
    end

    function SWEP:Think()
        if self:GetGhostMode() and not self.Owner:GetNoDraw() then 
            self.Owner:SetNoDraw(true)
            self.Owner:SetRenderMode(RENDERMODE_NODRAW)
            self.Owner:SetColor(Color(0,0,0,0))
        end
    end

    function SWEP:StartContainmentSequence(victims)
        local ply = self.Owner
        if not IsValid(ply) then 
            SetGlobalBool("SCP106_Containment_Active", false)
            return 
        end

        ply:Freeze(true)
        ply:SetNotSolid(true)
        ply:GodEnable()

        ply:SetForcedAnimation("0_106_new_despawn_1", 4.25, function()
            self:EmitSound("nextoren/scp/106/decay0.ogg", 75, 100, 1, CHAN_STATIC)
            self:DrawTeleportDecal(ply)
            timer.Simple(1.8, function() 
                if IsValid(ply) then ply:ScreenFade(SCREENFADE.OUT, color_black, .1, 1.1) end 
            end)
        end, function()
            if not IsValid(ply) then 
                SetGlobalBool("SCP106_Containment_Active", false)
                return 
            end

            local targetPos = Vector(6834.26, 1425.54, -306.97)
            ply:SetPos(targetPos)
            self:DrawTeleportDecal(ply)

            ply:SetForcedAnimation("0_106_new_spawn_1", 4.25, function()
                self:EmitSound("nextoren/scp/106/decay0.ogg", 75, 100, 1, CHAN_STATIC)
                ply:EmitSound("nextoren/scp/106/laugh.ogg", 75, 100, 1, CHAN_VOICE)
            end, function()
                if not IsValid(ply) then 
                    SetGlobalBool("SCP106_Containment_Active", false)
                    return 
                end

                ply:Freeze(false)
                ply:SetNotSolid(false)
                ply:GodDisable()

                if victims and istable(victims) then
                    for _, victim in pairs(victims) do
                        if IsValid(victim) and victim:Alive() and victim:GTeam() ~= TEAM_SPEC then
                            self:TeleportSequence(victim)
                        end
                    end
                end

                timer.Simple(1, function()
                    if IsValid(ply) then
                        ply:Kill()
                    end
                    SetGlobalBool("SCP106_Containment_Active", false)
                end)
            end)
        end)
    end

    hook.Add("EntityTakeDamage", "SCP106_BulletImmunity", function(target, dmginfo)
        if not dmginfo:IsDamageType(DMG_BULLET) and not dmginfo:IsDamageType(DMG_BUCKSHOT) then return end
        
        local ply = target
        if target:IsRagdoll() then
            ply = target:GetNWEntity("ply")
            if not IsValid(ply) and hg and hg.RagdollOwner then
                ply = hg.RagdollOwner(target)
            end
        end
        
        if IsValid(ply) and ply:IsPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_scp_106" then
                if math.random(1, 3) == 1 then
                    target:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav", 75, math.random(60, 80))
                    local effectdata = EffectData()
                    effectdata:SetOrigin(dmginfo:GetDamagePosition())
                    effectdata:SetNormal((dmginfo:GetDamageForce() * -1):GetNormalized())
                    effectdata:SetMagnitude(1)
                    effectdata:SetScale(1)
                    effectdata:SetRadius(2)
                    util.Effect("Sparks", effectdata, true, true)
                end
                
                dmginfo:ScaleDamage(0)
                dmginfo:SetDamage(0)
                return true
            end
        end
    end)

    hook.Add("PreHomigradDamage", "SCP106_PreHomigradImmunity", function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs, inputHole)
        if IsValid(ply) and ply:IsPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_scp_106" then
                if dmgInfo:IsDamageType(DMG_BULLET) or dmgInfo:IsDamageType(DMG_BUCKSHOT) then
                    dmgInfo:SetDamage(0)
                    dmgInfo:ScaleDamage(0)
                end
            end
        end
    end)

    hook.Add("PreTraceOrganBulletDamage", "SCP106_OrganImmunity", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
        local ply = org.owner
        if IsValid(ply) and ply:IsPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_scp_106" then
                hook_info.dmg = 0
                hook_info.restricted = true
                dmgInfo:SetDamage(0)
            end
        end
    end)

else 
    local function CreateClientExit(client, pos)
        client.exit_ent = ents.CreateClientside("base_gmodentity")
        client.exit_ent:SetPos(pos + vector_up * 4)
        client.exit_ent:SetModel(client:GetModel())
        client.exit_ent:SetOwner(client)
        client.exit_ent:SetSkin(client:GetSkin())
        client.exit_ent:AddEffects(EF_BRIGHTLIGHT)
        client.exit_ent:AddEffects(EF_NOSHADOW)
        client.exit_ent:SetMaterial("lights/white001")
        client.exit_ent:SetAutomaticFrameAdvance(true)
        client.exit_ent:Spawn()
        for id in ipairs(client:GetBodyGroups()) do
            client.exit_ent:SetBodygroup(id, client:GetBodygroup(id))
        end

        for _, bonemerge in ipairs(client:GetChildren()) do
            if bonemerge:GetClass() == "ent_bonemerged" then ClientBoneMerge(client.exit_ent, bonemerge:GetModel()) end
        end

        client.exit_ent:SetSequence(client.exit_ent:LookupSequence("2ump_holding_jump"))
        client.exit_ent:SetPlaybackRate(1.0)
        if client.exit_ent.BoneMergedEnts then
            for _, v in ipairs(client.exit_ent.BoneMergedEnts) do
                if v and v:IsValid() then v:SetMaterial("lights/white001") end
            end
        end

        ParticleEffectAttach("death_evil3", PATTACH_POINT_FOLLOW, client.exit_ent, 1)
        ParticleEffectAttach("death_blood_slave2", PATTACH_POINT_FOLLOW, client.exit_ent, 3)
        
        client.exit_ent.Reverse = false
        client.exit_ent.Think = function(self)
            self:NextThink(CurTime())
            if self:GetCycle() >= .99 then self:SetCycle(0) end
            self:SetCycle(self:GetCycle() + .001)
            if self.DeathTime then
                if not self.EndParticleCreated then
                    self.EndParticleCreated = true
                    self:StopParticles()
                    timer.Simple(.05, function()
                        if self and self:IsValid() then
                            ParticleEffectAttach("death_telc", PATTACH_POINT_FOLLOW, self, 1)
                            ParticleEffectAttach("burning_character_glow_b_white", PATTACH_POINT_FOLLOW, self, 3)
                        end
                    end)
                end

                if self.DeathTime < CurTime() then
                    if not self.ForceDeath then
                        gasblind = 8
                        local owner = self:GetOwner()
                        owner.FOVStartDecrease = nil
                        owner.FOVTest = 20
                        timer.Simple(8, function()
                            LocalPlayer().FOVStartDecrease = true
                            surface.PlaySound("nextoren/charactersounds/stun_out.wav")
                        end)
                    end

                    self:Remove()
                end
            end
            return true
        end
    end

    net.Receive("DimensionSequence", function()
        local ent_origin = net.ReadVector()
        local start = net.ReadBool()
        local client = LocalPlayer()

        if start then
            client:ConCommand("stopsound")

            CreateClientExit(client, ent_origin)
                       
            client.CustomRenderHook = true
            
            local old_name = client:GetNamesurvivor()
            local material_clr = Material("pp/colour")
            local check_time = 0
            local brightness = -.01

            client.snd_HeartBeat = CreateSound(client, "nextoren/charactersounds/heartbeat.wav")

            timer.Simple(1, function() 
                if client.snd_HeartBeat then
                    client.snd_HeartBeat:Play()
                end
            end)

            hook.Add("RenderScreenspaceEffects", "Dimension_ScreenRender", function()
                local client = LocalPlayer()
               
                if client:Health() <= 0 or (not client:GetInDimension() or client:GetNamesurvivor() ~= old_name or not IsValid(client.exit_ent))then
                    if IsValid(client.exit_ent) and not client.exit_ent.DeathTime then
                        client.exit_ent.DeathTime = CurTime() + 0.25
                        client.exit_ent.ForceDeath = true
                    end

                    client.CustomRenderHook = nil
                    if client.snd_HeartBeat then
                        client.snd_HeartBeat:Stop()
                        client.snd_HeartBeat = nil
                    end

                    hook.Remove("RenderScreenspaceEffects", "Dimension_ScreenRender")
                    return
                end

                if check_time < CurTime() then
                    check_time = CurTime() + 1
                    local snd_volume = 1 - math.Clamp(client:GetPos():Distance(client.exit_ent:GetPos()) / 1200, 0, .95) 
                    client.snd_HeartBeat:ChangeVolume(snd_volume, 0)
                end

                render.UpdateScreenEffectTexture()
                if f_started then
                    brightness = -1
                elseif brightness == -1 then
                    brightness = -.01
                end

                material_clr:SetFloat("$pp_colour_brightness", brightness)
                material_clr:SetFloat("$pp_colour_contrast", 5)
                material_clr:SetFloat("$pp_colour_colour", .45)
                render.SetMaterial(material_clr)
                render.DrawScreenQuad()
            end)
        else
            local client = LocalPlayer()
            if client.exit_ent and client.exit_ent:IsValid() then
                client.exit_ent:StopParticles()
                ParticleEffectAttach("death_telc", PATTACH_POINT_FOLLOW, client.exit_ent, 1)
                client.exit_ent.DeathTime = CurTime() + 2
            end
        end
    end)

    function SWEP:CalcViewModelView()
        if not self:GetInDimension() then return end
        local dynamic_light = DynamicLight(self:EntIndex())
        if dynamic_light then
            dynamic_light.Pos = self:GetPos() + self:GetUp() * 64
            dynamic_light.r = 140
            dynamic_light.g = 0
            dynamic_light.b = 0
            dynamic_light.Brightness = 4
            dynamic_light.Size = 280
            dynamic_light.Decay = 2500
            dynamic_light.DieTime = CurTime() + .1
        end
    end

    function SWEP:DrawWorldModel()
        if self:GetGhostMode() then return end
        if not self:GetInDimension() then return end
        local dynamic_light = DynamicLight(self:EntIndex())
        if dynamic_light then
            dynamic_light.Pos = self:GetPos() + self:GetUp() * 64
            dynamic_light.r = 140
            dynamic_light.g = 0
            dynamic_light.b = 0
            dynamic_light.Brightness = 4
            dynamic_light.Size = 280
            dynamic_light.Decay = 2500
            dynamic_light.DieTime = CurTime() + .1
        end
    end

    function SWEP:PreDrawViewModel(vm, wep, ply)
        if self:GetGhostMode() then return true end
    end

    function SWEP:Think()
        if self:GetGhostMode() and not self.Tip_Received then
            self.Tip_Received = true
            BREACH.Player:ChatPrint(true, true, "Активирован режим \"Призрака\".")
            BREACH.Player:ChatPrint(true, true, "Ваша скорость передвижения увеличена в два раза.")
            BREACH.Player:ChatPrint(true, true, "В этом режиме Вы не можете никого атаковать. Люди, в свою очередь, никаким образом не смогут Вас увидеть.")
            BREACH.Player:ChatPrint(true, true, "Вы можете покинуть этот режим, нажав кнопку \"R\". Ваш персонаж появится на текущей позиции.")
        end

        if self.Owner:GetInDimension() and not self.Tip_Received_2 then
            self.Tip_Received_2 = true
            BREACH.Player:ChatPrint(true, true, "Теперь Вы находитесь в своём измерении.")
            BREACH.Player:ChatPrint(true, true, "С помощью клавиши \"H\" Вы можете вернуться на свою старую позицию, откуда был произведён вход в собственное измерение.")
            BREACH.Player:ChatPrint(true, true, "Вы можете продолжать телепортироваться по случайным точкам измерения с помощью способности на клавишу \"T\".")
        end
    end

    local exit_icon = Material("nextoren/gui/special_abilities/scp_106_trap.png")
    local clrgray = Color(198, 198, 198)
    local darkgray = Color(105, 105, 105)
    function SWEP:DrawHUDBackground()
        if not self.Deployed then
            self.Deployed = true
            self:Deploy()
        end

        if self.Owner:GetInDimension() then 
            local icon_x, icon_y = ScrW() / 2 - 32, ScrH() / 1.4
            surface.SetDrawColor(color_white)
            surface.SetMaterial(exit_icon)
            surface.DrawTexturedRect(icon_x, icon_y, 64, 64)
            if self.Owner:IsFrozen() or (self.AbilityIcons[2].CooldownTime or 0) > CurTime() then draw.RoundedBox(0, icon_x, icon_y, 64, 64, ColorAlpha(darkgray, 190)) end
            if input.IsKeyDown(KEY_H) then draw.RoundedBox(0, icon_x, icon_y, 64, 64, ColorAlpha(clrgray, 70)) end
            OGRX.outlineText("H", "HUDFont", icon_x + 64 - (32 / 4), icon_y + 22, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, color_black)
        end
    end

    function SWEP:Camera(eyePos, angles, view, velLen)
        if self:GetGhostMode() then
            local ply = self:GetOwner()
            if not IsValid(ply) then return end
            
            local tr = util.TraceLine({
                start = ply:GetPos() + Vector(0, 0, 10),
                endpos = ply:GetPos() - Vector(0, 0, 100),
                filter = ply,
                mask = MASK_SOLID_BRUSHONLY
            })
            
            view.origin = tr.HitPos + Vector(0, 0, 65)
            view.angles = angles
            view.drawviewer = false
            
            return view
        end
    end

    function SWEP:OpenZoneMenu()
        if IsValid(self.ZoneMenu) then self.ZoneMenu:Remove() end

        local rust_bg       = Color(15, 14, 13, 245)
        local rust_panel    = Color(30, 28, 25, 255)
        local rust_outline  = Color(255, 255, 255, 10)
        local rust_yellow   = Color(218, 165, 32, 255)
        local rust_red      = Color(188, 64, 43, 255)
        local rust_green    = Color(112, 126, 73, 255)
        local rust_text     = Color(230, 230, 230, 255)
        local rust_dim      = Color(140, 140, 140, 255)

        local frame = vgui.Create("DFrame")
        frame:SetSize(380, 200)
        frame:Center()
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:MakePopup()

        frame:SetAlpha(0)
        frame:AlphaTo(255, 0.15)
        
        self.ZoneMenu = frame

        frame.Paint = function(s, w, h)
            if DrawBlurPanel then DrawBlurPanel(s, 3) end

            surface.SetDrawColor(rust_bg)
            surface.DrawRect(0, 30, w, h - 30)

            surface.SetDrawColor(rust_panel)
            surface.DrawRect(0, 0, w, 30)
            

            surface.SetDrawColor(rust_yellow)
            surface.DrawRect(0, 30, w, 2)

            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            draw.SimpleText("", "MM_Exp", 15, 15, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("", "MM_SmallName", w - 40, 15, rust_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        local btnClose = vgui.Create("DButton", frame)
        btnClose:SetSize(30, 30)
        btnClose:SetPos(frame:GetWide() - 30, 0)
        btnClose:SetText("X")
        btnClose:SetFont("MM_Exp")
        btnClose:SetTextColor(rust_dim)
        btnClose.Paint = function(s, w, h)
            if s:IsHovered() then
                surface.SetDrawColor(rust_red)
                surface.DrawRect(0, 0, w, h)
                s:SetTextColor(color_white)
            else
                s:SetTextColor(rust_dim)
            end
        end
        btnClose.DoClick = function()
            frame:AlphaTo(0, 0.15, 0, function() frame:Close() end)
        end

        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 10, 10, 10)

        local zones = {
            {name = "ЛЕГКАЯ ЗОНА (LCZ)", key = "LCZ"},
            {name = "ТЯЖЕЛАЯ ЗОНА (HCZ)", key = "HCZ"},
            {name = "ОФИСНАЯ ЗОНА (EZ)",  key = "EZ"}
        }

        for i, zone in ipairs(zones) do
            local btn = vgui.Create("DButton", scroll)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 5)
            btn:SetTall(40)
            btn:SetText("")
            btn.HoverLerp = 0
            
            btn.Paint = function(s, w, h)
                s.HoverLerp = math.Approach(s.HoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 12)
                
                surface.SetDrawColor(rust_panel)
                surface.DrawRect(0, 0, w, h)
                
                if s.HoverLerp > 0 then
                    surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 20 * s.HoverLerp)
                    surface.DrawRect(0, 0, w, h)
                    
                    surface.SetDrawColor(rust_yellow)
                    surface.DrawRect(0, 0, 3, h) 
                end
                
                surface.SetDrawColor(rust_outline)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                local txtCol = s:IsHovered() and color_white or rust_text
                draw.SimpleText(zone.name, "MM_Exp", 20, h/2 - 1, txtCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                draw.SimpleText("[ ДОСТУПНО ]", "MM_SmallName", w - 15, h/2 - 1, ColorAlpha(rust_green, 150 + 105 * s.HoverLerp), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function()

                
                net.Start("SCP106_ZoneTeleport")
                net.WriteString(zone.key)
                net.SendToServer()
                
                frame:AlphaTo(0, 0.15, 0, function() frame:Close() end)
            end
        end
    end
end

local prim_maxs = Vector(12, 4, 32)
function SWEP:PrimaryAttack()
    if self:GetGhostMode() then return end
    self:SetNextPrimaryFire(CurTime() + 1)
    if CLIENT then return end
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = trace.start + self.Owner:GetAimVector() * 90
    trace.filter = self.Owner
    trace.mins = -prim_maxs
    trace.maxs = prim_maxs
    trace = util.TraceHull(trace)
    local hit_ent = trace.Entity
    if hit_ent:IsPlayer() and hit_ent:GTeam() ~= TEAM_SCP and hit_ent:GetMoveType() ~= MOVETYPE_OBSERVER then
        if self.Owner:GetInDimension() then
            self.Owner:SetHealth(math.min(self.Owner:Health() + hit_ent:Health(), self.Owner:GetMaxHealth()))
            self.Owner:EmitSound("nextoren/scp/106/laugh.ogg", 75, 100, 1, CHAN_VOICE)
            hit_ent:Kill()
            self.Owner:AddToStatistics("SCP-106 Dimension kill", 150)
        else
            hit_ent.BodyOrigin = hit_ent:GetPos()
            
            self:DrawTeleportDecal(hit_ent)
            self:TeleportSequence(hit_ent)
        end
    end
end

function SWEP:CanSecondaryAttack()
    return false
end

function SWEP:Deploy()
    hook.Add("PlayerButtonDown", "SCP106_DimensionTeleport", function(caller, button)
        if caller:GetRoleName() ~= "SCP106" then return end
        local wep = caller:GetActiveWeapon()
        if wep == NULL or not wep.AbilityIcons then return end
        
        if button == KEY_T and not ((wep.AbilityIcons[2].CooldownTime or 0) > CurTime() or wep.AbilityIcons[2].Forbidden) then
            wep.AbilityIcons[2].CooldownTime = CurTime() + wep.AbilityIcons[2].Cooldown
            if SERVER then
                for i = 1, #wep.AbilityIcons do
                    if self.ForbidAbility then self:ForbidAbility(i, true) end
                end
                wep:OwnerTeleport()
            else
                timer.Simple(.25, function()
                    hook.Add("SetupOutlines", "SCP106_DimensionVision", function()
                        local client = LocalPlayer()
                        if client:Health() <= 0 or client:GetRoleName() ~= "SCP106" or not client:GetInDimension() then
                            hook.Remove("SetupOutlines", "SCP106_DimensionVision")
                            return
                        end

                        local to_draw = {}
                        local players = player.GetAll()
                        for i = 1, #players do
                            local player = players[i]
                            if player and player:IsValid() and player ~= client and player:Health() > 0 and player:GTeam() ~= TEAM_SPEC and player:GetInDimension() then
                                to_draw[#to_draw + 1] = player
                                local bnmrges = player:LookupBonemerges()
                                for i = 1, #bnmrges do
                                    to_draw[#to_draw + 1] = bnmrges[i]
                                end
                            end
                        end

                        if #to_draw > 0 then outline.Add(to_draw, color_white, OUTLINE_MODE_BOTH) end
                    end)
                end)
            end
        elseif button == KEY_J and not ((wep.AbilityIcons[2].CooldownTime or 0) > CurTime() or wep.AbilityIcons[2].Forbidden) then
            wep.AbilityIcons[2].CooldownTime = CurTime() + wep.AbilityIcons[2].Cooldown
            if CLIENT then return end
            for i = 1, #wep.AbilityIcons do
                if self.ForbidAbility then self:ForbidAbility(i, true) end
            end
            wep:DistantAttack()
            
        elseif button == KEY_B and not ((wep.AbilityIcons[3].CooldownTime or 0) > CurTime() or wep.AbilityIcons[3].Forbidden) then
            if wep:GetGhostMode() or caller:GetInDimension() then return end
            wep.AbilityIcons[3].CooldownTime = CurTime() + 1
            if CLIENT then
                wep:OpenZoneMenu()
            end

        elseif button == KEY_N and not ((wep.AbilityIcons[4].CooldownTime or 0) > CurTime() or wep.AbilityIcons[4].Forbidden) then
            if wep:GetGhostMode() or caller:GetInDimension() then return end
            
            if SERVER then
                local valid_targets = {}
                for _, p in player.Iterator() do
                    if p:Alive() and p:GTeam() ~= TEAM_SCP and p:GTeam() ~= TEAM_SPEC and not p:GetInDimension() and p:GetPos().z < 1100 then
                        table.insert(valid_targets, p)
                    end
                end
                
                if #valid_targets > 0 then
                    local target = table.Random(valid_targets)
                    wep.AbilityIcons[4].CooldownTime = CurTime() + wep.AbilityIcons[4].Cooldown

                    for i = 1, #wep.AbilityIcons do
                        if wep.ForbidAbility then wep:ForbidAbility(i, true) end
                    end
                    
                    local tpos = target:GetPos()

                    local dir = -target:GetAngles():Forward()
                    dir.z = 0
                    dir:Normalize()
                    
                    local spawnPos = tpos + dir * 50

                    local tr = util.TraceHull({
                        start = tpos,
                        endpos = spawnPos,
                        mins = Vector(-16, -16, 0),
                        maxs = Vector(16, 16, 72),
                        filter = {target, caller}
                    })
                    
                    if tr.Hit then spawnPos = tpos end
                    
                    local ang = (tpos - spawnPos):Angle()
                    ang.p = 0
                    ang.r = 0
                    if spawnPos == tpos then ang = caller:GetAngles() end

                    wep:ZoneTeleportSequence(spawnPos, ang)
                else
                    caller:ChatPrint("Нет подходящих жертв под землей.")
                end
            else
                wep.AbilityIcons[4].CooldownTime = CurTime() + wep.AbilityIcons[4].Cooldown
            end
        end
    end)

    if self.AbilityIcons then
        for i = 1, #self.AbilityIcons do
            self.AbilityIcons[i].CooldownTime = CurTime() + 10
        end
    end

    if SERVER then
        self:DrawTeleportDecal(self.Owner)
        self.Owner:Freeze(true)
        self.Owner:EmitSound("nextoren/scp/106/decay0.ogg", 75, 100, 1, CHAN_STATIC)
        self.Owner:ScreenFade(SCREENFADE.OUT, color_black, .1, 2.5)
        timer.Simple(1.25, function()
            if not (self and self:IsValid()) then return end
            self.Owner:SetForcedAnimation("0_106_new_spawn_1", 4.25, function()
            end, function()
                self.Owner:SetMoveType(MOVETYPE_WALK)
                self.Owner:SetCustomCollisionCheck(true)
                self.Owner:Freeze(false)
            end)
        end)
    else
        local material_clr = Material("pp/colour")
        hook.Add("RenderScreenspaceEffects", "SCP106_GhostModeProccessing", function()
            local client = LocalPlayer()
            if client:Health() <= 0 or client:GTeam() ~= TEAM_SCP or client:GetRoleName() ~= "SCP106" then
                if client.CustomRenderHook then client.CustomRenderHook = nil end
                hook.Remove("RenderScreenspaceEffects", "SCP106_GhostModeProccessing")
                return
            end

            local wep = client:GetActiveWeapon()
            if wep == NULL then return end
            if not wep:GetGhostMode() then
                if client.CustomRenderHook then client.CustomRenderHook = nil end
                return
            end

            if not client.CustomRenderHook then client.CustomRenderHook = true end
            render.UpdateScreenEffectTexture()
            material_clr:SetFloat("$pp_colour_brightness", .1)
            material_clr:SetFloat("$pp_colour_contrast", 1)
            material_clr:SetFloat("$pp_colour_colour", .1)
            material_clr:SetFloat("$pp_colour_addr", .1)
            render.SetMaterial(material_clr)
            render.DrawScreenQuad()
        end)
    end
end

function SWEP:Reload()
    if self.AbilityIcons and ((self.AbilityIcons[1].CooldownTime or 0) > CurTime() or self.AbilityIcons[1].Forbidden) then return end
    self.AbilityIcons[1].CooldownTime = CurTime() + self.AbilityIcons[1].Cooldown
    local is_ghostmode = self:GetGhostMode()
    
    if is_ghostmode then
        local check_trace = {}
        check_trace.start = self.Owner:GetShootPos()
        check_trace.endpos = check_trace.start + self.Owner:GetAimVector() * 16
        check_trace.mask = MASK_SHOT
        check_trace.filter = self.Owner
        check_trace = util.TraceLine(check_trace)
        if check_trace.Entity and check_trace.Entity:IsValid() then
            if CLIENT then BREACH.Player:ChatPrint(true, true, "Вы не можете выйти из режима \"Призрака\" в этом месте.") end
            self.AbilityIcons[1].CooldownTime = CurTime() + 3
            return
        end
    end

    if CLIENT then return end
    self:DrawTeleportDecal(self.Owner)
    self.Owner:EmitSound("nextoren/scp/106/laugh.ogg", 75, 100, 1, CHAN_VOICE)
    if not is_ghostmode then
        for i = 2, #self.AbilityIcons do
            if self.ForbidAbility then self:ForbidAbility(i, true) end
        end

        local unique_id = "DecalDraw" .. self.Owner:SteamID()
        local i = 1
        timer.Create(unique_id, .75, 2, function()
            if not (self and self:IsValid()) then
                timer.Remove(unique_id)
                return
            end

            self:DrawTeleportDecal(self.Owner, self.Owner:GetAimVector() * (24 * i))
            i = i + 1
        end)

        self.Owner:SetForcedAnimation("0_106_new_despawn_2", 3, function()
            self.Owner:Freeze(true)
            self.Owner:ScreenFade(SCREENFADE.OUT, color_black, 2.25, 1.25)
        end, function()
            self.Owner:SetNoDraw(true)
            self.Owner:SetNotSolid(true)
            self.Owner:Freeze(false)
            self.Owner.Block_Use = true 
            self.Owner:SetRunSpeed(220)
            self.Owner:SetWalkSpeed(220)
            self.Owner:SetNWBool("CloakSAM", true)
            self:SetGhostMode(true)
        end)
    else
        self.Owner:Freeze(true)
        self.Owner:SetRunSpeed(165)
        self.Owner:SetWalkSpeed(165)
        self:OwnerTeleport(true)
    end
end

function SWEP:OnRemove()
    local players = player.GetAll()
    local scp106_exists
    for i = 1, #players do
        local player = players[i]
        if player:GetRoleName() == "SCP106" then
            scp106_exists = true
            break
        end
    end

    if not scp106_exists then hook.Remove("PlayerButtonDown", "SCP106_DimensionTeleport") end
end

hook.Add("HG_PlayerFootstep", "SCP106_CustomFootsteps", function(ply, pos, foot, snd, volume, rf)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "weapon_scp_106" then
        if wep:GetGhostMode() then 
            return true
        end
        
        if SERVER then
            local step_snd = "nextoren/scp/106/StepPD"..math.random(0,2)..".ogg"
            ply:EmitSound(step_snd, 75, 100, volume, CHAN_AUTO)
        end
        
        return true
    end
end)