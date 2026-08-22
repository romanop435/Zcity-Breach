AddCSLuaFile()

BREACH = BREACH or {}
local vec_up = Vector(0, 0, 32768)
function BREACH.GroundPos(pos)
    local trace = {}
    trace.start = pos
    trace.endpos = trace.start - vec_up
    trace.mask = MASK_BLOCKLOS
    local tr = util.TraceLine(trace)
    if tr.Hit then return tr.HitPos end
    return pos
end

SWEP.HotKeyTable = {}

SWEP.Base 		= "breach_scp_base"
SWEP.PrintName	= "SCP-1015-RU"
SWEP.HoldType	= "scp1015ru"

SWEP.ViewModel = "models/cultist/scp/1015ru_hands.mdl"

SWEP.AttackDelay			= 5
SWEP.NextAttackW			= 0

if CLIENT then
	  SWEP.WepSelectIcon 	= Material("breach/wep_049.png")
end

SWEP.AbilityIcons = {
    {
        Name = "Attack",
        Description = "none",
        Cooldown = 1,
        CooldownTime = 0,
        KEY = 107,
        Using = false,
        Icon = "nextoren/gui/special_abilities/scp_1015_attack.png",
        Func = function(self, idx, ply)
            if ply:IsFrozen() then return end
            if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            wep:Cooldown(idx, self.Cooldown)

            local maxs = Vector( 8, 10, 5 )
            local trace = {}
            trace.start = ply:GetShootPos()
            trace.endpos = trace.start + ply:GetAimVector() * 80
            trace.filter = ply
            trace.mins = -maxs
            trace.maxs = maxs

            ply:LagCompensation( true )
            trace = util.TraceHull( trace )
            ply:LagCompensation( false )
            local target = trace.Entity
            ply:SetAnimation( PLAYER_ATTACK1 )

            if ( CLIENT ) then
                if ( target && target:IsValid() && target:IsPlayer() && target:GTeam() != TEAM_SCP ) then
                   local effectData = EffectData()
                    effectData:SetOrigin( trace.HitPos )
                    effectData:SetEntity( target )

                    util.Effect( "BloodImpact", effectData )
                end

                return
            end

            if ( target && target:IsValid() && target:IsPlayer() && target:Health() > 0 && target:GTeam() != TEAM_SCP ) then
                local dmginfo = DamageInfo()
                dmginfo:SetDamageType( DMG_SLASH )
                dmginfo:SetDamage( target:GetMaxHealth() * .2 )
                dmginfo:SetDamageForce( target:GetAimVector() * 40 )
                dmginfo:SetInflictor( wep )
                dmginfo:SetAttacker( ply )

                ply:EmitSound( "npc/antlion/shell_impact4.wav" )
                ply:MeleeViewPunch( dmginfo:GetDamage() )
                ply:SetHealth( math.Clamp( ply:Health() + dmginfo:GetDamage(), 0, ply:GetMaxHealth() ) )

                target:MeleeViewPunch( dmginfo:GetDamage() )
                if target:WouldDieFrom(dmginfo:GetDamage()) then
                    ply:EmitSound( ("nextoren/kasanov/scps/006fr/kill%s.mp3"):format(math.random(1, 5)) )
                end
                target:TakeDamageInfo( dmginfo )
            else
                ply:SetAnimation( PLAYER_ATTACK1 )
                ply:EmitSound( "npc/zombie/claw_miss"..math.random( 1, 2 )..".wav" )
                ply:ViewPunch( AngleRand( 10, 2, 10 ) )
            end
        end
    },
    {
        Name = "Meat Hook",
        Description = "Throw meat hook",
        Cooldown = 18,
        CooldownTime = 0,
        KEY = _G["KEY_Q"],
        Using = false,
        Icon = "nextoren/gui/special_abilities/scp_1015_grab.png",
        Func = function(self, idx, ply)
            if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            wep:Cooldown(idx, self.Cooldown)
            wep.Voice_Line = CreateSound(ply, "nextoren/kasanov/scps/006fr/hook_chain.mp3")
            wep.Voice_Line:SetDSP(17)
            wep.Voice_Line:Play()

            ply.TempValues.SCP1015_MeatHook = ents.Create("prop_dynamic")
            local Hook = ply.TempValues.SCP1015_MeatHook
            Hook:SetPos(ply:EyePos() + Vector(0, 0, -10))
            Hook:SetModel("models/props_junk/meathook001a.mdl")
            Hook:SetAngles(Angle(-90, ply:GetAngles().y, 0))
            Hook:Spawn()
            Hook:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            Hook.__FlyTime = 2

            ply.TempValues.SCP1015_MeatRope = constraint.Rope(ply, Hook, 0, 0, Vector(20, 0, 10), Vector(0, 0, 0), 2000, 2, 0, 1, 1, "cable/rope", false)

            local normal_vector = ply:GetEyeTrace().Normal
            local hasTarget = false
            local target = NULL
            local limitDist = 1000
            local returnByDist = false
            ply:Freeze(true)
            timer.Create("SCP1015_MeatHookThink", .02, 0, function()
                if not IsValid(ply.TempValues.SCP1015_MeatHook) then
                    timer.Remove("SCP1015_MeatHookThink")
                    return
                end

                local entities = ents.FindInSphere(Hook:GetPos(), 80)
                local firstPlayer = entities[1]
                if target == NULL and firstPlayer and firstPlayer:IsPlayer() and firstPlayer:Alive() and firstPlayer:Health() > 0 then
                    if firstPlayer ~= ply and firstPlayer:GTeam() ~= TEAM_SCP and firstPlayer:GTeam() ~= TEAM_DZ and firstPlayer:GTeam() ~= TEAM_SPEC then
                        hasTarget = true
                        target = firstPlayer
                        ply:EmitSound("nextoren/kasanov/scps/006fr/hook_impact.mp3")
                        ply:EmitSound( ("nextoren/kasanov/scps/006fr/hook_pro%s.mp3"):format(math.random(1, 3)) )
                        local dmginfo = DamageInfo()
                        dmginfo:SetDamageType( DMG_SLASH )
                        dmginfo:SetDamage( target:GetMaxHealth() * .2 )
                        dmginfo:SetDamageForce( target:GetAimVector() * 40 )
                        dmginfo:SetInflictor( wep )
                        dmginfo:SetAttacker( ply )

                        ply:EmitSound( "npc/antlion/shell_impact4.wav" )
                        ply:SetHealth( math.Clamp( ply:Health() + dmginfo:GetDamage(), 0, ply:GetMaxHealth() ) )

                        target:MeleeViewPunch( dmginfo:GetDamage() )
                        if target:WouldDieFrom(dmginfo:GetDamage()) then
                            ply:EmitSound( ("nextoren/kasanov/scps/006fr/kill%s.mp3"):format(math.random(1, 5)) )
                        end
                        target:TakeDamageInfo( dmginfo )
                    end
                end

                if hasTarget and target and target:Health() > 0 then
                    Hook:SetPos( Hook:GetPos() - Vector(normal_vector.x * 50, normal_vector.y * 50, normal_vector.z * 0) )
                    if Hook:GetPos():Distance(ply:GetPos()) <= 80 then
                        ply.TempValues.SCP1015_MeatHook:Remove()
                        ply.TempValues.SCP1015_MeatRope:Remove()
                        ply:Freeze(false)
                        timer.Remove("SCP1015_MeatHookThink")
                        timer.Remove("SCP1015_MeatHookDelete")
                        return
                    end
                    target:SetPos( Hook:GetPos() + Vector(0, 0, -40) )
                else
                    if returnByDist then
                        Hook:SetPos( Hook:GetPos() - Vector(normal_vector.x * 50, normal_vector.y * 50, normal_vector.z * 0) )
                        if Hook:GetPos():Distance(ply:GetPos()) <= 100 then
                            ply.TempValues.SCP1015_MeatHook:Remove()
                            ply.TempValues.SCP1015_MeatRope:Remove()
                            ply:EmitSound("nextoren/kasanov/scps/006fr/hook_end.mp3")
                            if IsValid(wep.Voice_Line) then wep.Voice_Line:Stop() end
                            ply:Freeze(false)
                            timer.Remove("SCP1015_MeatHookThink")
                            timer.Remove("SCP1015_MeatHookDelete")
                            return
                        end
                    else
                        Hook:SetPos( Hook:GetPos() + Vector(normal_vector.x * 50, normal_vector.y * 50, normal_vector.z * 0) )
                    end
                end

                if Hook:GetPos():Distance(ply:GetPos()) > limitDist then
                    returnByDist = true
                end
                if not Hook:IsInWorld() then
                    returnByDist = true
                end
            end)
            timer.Create("SCP1015_MeatHookDelete", 5, 1, function()
                if IsValid(ply.TempValues.SCP1015_MeatHook) then
                    ply.TempValues.SCP1015_MeatHook:Remove()
                    ply.TempValues.SCP1015_MeatRope:Remove()
                    ply:Freeze(false)
                end
            end)
        end,
    },
    {
        Name = "Dismember",
        Description = "none",
        Cooldown = 40,
        CooldownTime = 0,
        KEY = _G["KEY_R"],
        Using = false,
        Icon = "nextoren/gui/special_abilities/scp_1015_cartoonism.png",
        Func = function(self, idx, ply)
            if self.CooldownTime > CurTime() then return end
            local wep = ply:GetActiveWeapon()
            local target = ply:GetEyeTrace().Entity
            if IsValid(target) and target:IsPlayer() and target:GTeam() ~= TEAM_SCP and target:GTeam() ~= TEAM_DZ and target:GetPos():Distance( ply:GetPos() ) < 100 then
                self.CooldownTime = CurTime() + self.Cooldown
                wep:Cooldown(idx, self.Cooldown)

                local shoot_pos = ply:GetShootPos()
                local vec_pos = shoot_pos + ply:GetAngles():Forward() * 35

	            vec_pos.z = BREACH.GroundPos( vec_pos ).z
                ply:EmitSound( ("nextoren/kasanov/scps/006fr/ult_pro%s.mp3"):format(math.random(1, 6)) )
                ply:SetNWAngle( "ViewAngles", Angle(0,0,0) )
                ply:SetNWEntity( "NTF1Entity", ply )
                ply:Freeze(true)
                ply:SetForcedAnimation("0_SCP_542_grab", 4, nil, function()
                    ply:SetNWAngle( "ViewAngles", Angle(0,0,0) )
                    ply:SetNWEntity( "NTF1Entity", NULL )
                    ply:Freeze(false)
                end)

                target:SetNWAngle( "ViewAngles", Angle(0,0,0) )
                target:SetNWEntity( "NTF1Entity", target )
                target:Freeze(true)
                target:SetPos( vec_pos )

                local dmginfo = DamageInfo()
                dmginfo:SetDamageType( DMG_SLASH )
                dmginfo:SetDamage( target:GetMaxHealth() * .08 )
                dmginfo:SetDamageForce( target:GetAimVector() * 40 )
                dmginfo:SetInflictor( wep )
                dmginfo:SetAttacker( ply )
                timer.Create("SCP1015RU_TakeDamage", .5, 8, function()
                    if not IsValid(target) then return end
                    ply:EmitSound( ("nextoren/kasanov/scps/006fr/ult_blood%s.mp3"):format(math.random(1, 3)) )
                    ply:EmitSound( ("nextoren/kasanov/scps/006fr/ult_chain%s.mp3"):format(math.random(1, 3)) )
                    ply:SetHealth( math.Clamp( ply:Health() + (dmginfo:GetDamage() * 2), 0, ply:GetMaxHealth() ) )
                    if target:WouldDieFrom(dmginfo:GetDamage()) then
                        ply:EmitSound( ("nextoren/kasanov/scps/006fr/kill%s.mp3"):format(math.random(1, 5)) )
                        ply:SetForcedAnimation("0_SCP_542_lifedrain", .01)
                        ply:SetNWAngle( "ViewAngles", Angle(0,0,0) )
                        ply:SetNWEntity( "NTF1Entity", NULL )
                        ply:Freeze(false)
                        timer.Remove("SCP1015RU_TakeDamage")
                    end
                    target:TakeDamageInfo( dmginfo )
                    local hand_pos = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_R_Hand" ) )
		            local angles = ply:GetAngles()
		            ParticleEffect( "core_dirl1", hand_pos, angles, target )
                end)
                target:SetForcedAnimation("0_SCP_542_lifedrain", 3.25, nil, function()
                    target:Freeze(false)
                end)
            else
                wep:Cooldown(idx, 1)
                return
            end
        end
    }
} 

function SWEP:Deploy()
    kasanov.FindAbilityTableByKey = function(wep, key)
        local abilityTable = wep.AbilityIcons

        for idx, info in ipairs(abilityTable) do
            if info.KEY == key then
                return idx
            end
        end

        return nil
    end

    hook.Add('PlayerButtonDown', 'SCP01015_Buttons', function(ply, button)
        if ply:GetRoleName() ~= "SCP006FR" then return end

        local wep = ply:GetActiveWeapon()
        if not wep or not wep.AbilityIcons then return end

        local abilityIdx = kasanov.FindAbilityTableByKey(wep, button)
        if abilityIdx then
            local abilityTable = wep.AbilityIcons[abilityIdx]
            if abilityTable.CooldownTime > CurTime() then return end
            if abilityTable.Func and isfunction(abilityTable.Func) then
                abilityTable.Func(abilityTable, abilityIdx, ply)
            end
        end
    end)
end

function SWEP:OnRemove()
    local players = player.GetAll()
    local scp1015_exists
    for i = 1, #players do
        local player = players[i]
        if player:GetRoleName() == "SCP006FR" then
            scp1015_exists = true
            break
        end
    end

    if not scp1015_exists then
        hook.Remove("PlayerButtonDown", "SCP01015_Buttons")
    end
end

function SWEP:DrawWorldModel()
    return
end

function SWEP:Think()
    return
end

function SWEP:Reload()
    return
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:PrimaryAttack()
    return
end