if CLIENT then return end

util.AddNetworkString("MW2023_hit")
util.AddNetworkString("MW2023_kill")
util.AddNetworkString("MW2023_dist")
util.AddNetworkString("MW2023_headshot")
util.AddNetworkString("MW2023_long_range")
util.AddNetworkString("MW2023_blast")
util.AddNetworkString("MW2023_burn")
util.AddNetworkString("MW2023_meele")
util.AddNetworkString("MW2023_oneshot")

hook.Add("HomigradDamage", "MW2023_HomigradHitmarker", function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs, inputHole)
    local attacker = dmgInfo:GetAttacker()
    
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker == ply then return end

    if not (dmgInfo:IsDamageType(DMG_BULLET) or dmgInfo:IsDamageType(DMG_BUCKSHOT) or dmgInfo:IsDamageType(DMG_SLASH) or dmgInfo:IsDamageType(DMG_CLUB)) then 
        return 
    end

    local isHeadshot = (hitgroup == HITGROUP_HEAD)
    local isMelee = (dmgInfo:IsDamageType(DMG_SLASH) or dmgInfo:IsDamageType(DMG_CLUB))
    local pos = dmgInfo:GetDamagePosition()

    local isArmored = false
    local hitArmor = false
    
    if ply.armors then
        if (hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH) and ply.armors["torso"] then
            isArmored = true
            hitArmor = true
        elseif hitgroup == HITGROUP_HEAD and (ply.armors["head"] or ply.armors["face"]) then
            isArmored = true
            hitArmor = true
        end
    end

    net.Start("MW2023_hit")
        net.WriteEntity(ply)
        net.WriteBool(isHeadshot)
        net.WriteBool(isArmored)
        net.WriteBool(hitArmor)
        net.WriteBool(false)
        net.WriteVector(pos)
    net.Send(attacker)

    if isMelee then attacker.MW2023_LastMelee = CurTime() end
    if isHeadshot then attacker.MW2023_LastHeadshot = CurTime() end
end)


hook.Add("PlayerDeath", "MW2023_HomigradKillmarker", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

    local dist = attacker:GetPos():Distance(victim:GetPos()) / 25

    attacker.MW2023_KillCount = (attacker.MW2023_KillCount or 0) + 1
    timer.Create("MW2023_KillStreak_" .. attacker:EntIndex(), 3, 1, function()
        if IsValid(attacker) then attacker.MW2023_KillCount = 0 end
    end)

    local isHeadshotKill = (attacker.MW2023_LastHeadshot and (CurTime() - attacker.MW2023_LastHeadshot) < 0.5)
    local isMeleeKill = (attacker.MW2023_LastMelee and (CurTime() - attacker.MW2023_LastMelee) < 0.5)

    if isHeadshotKill then
        net.Start("MW2023_headshot") net.Send(attacker)
    end

    net.Start("MW2023_long_range") net.Send(attacker)

    if isMeleeKill then
        net.Start("MW2023_meele") net.Send(attacker)
    end

    net.Start("MW2023_kill")
        net.WriteBool(isHeadshotKill)
        net.WriteInt(attacker.MW2023_KillCount, 32)
    net.Send(attacker)

    net.Start("MW2023_dist")
        net.WriteFloat(dist)
    net.Send(attacker)
end)