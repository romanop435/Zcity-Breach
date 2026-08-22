if not SERVER then return end

shz_native_opt = shz_native_opt or {}

local ok, lib = pcall(require, "shz_native_opt")
if ok and istable(lib) then
    shz_native_opt = lib
    print("[shz_native_opt] Native module loaded")
else
    print("[shz_native_opt] Native module unavailable, using Lua fallback")
end

local fallback = {}

function fallback.DistanceSqr(ax, ay, az, bx, by, bz)
    local dx = ax - bx
    local dy = ay - by
    local dz = az - bz
    return dx * dx + dy * dy + dz * dz
end

function fallback.NearestPointIndex(cx, cy, cz, radius, flatPoints)
    local bestIndex = 0
    local bestDist = math.huge
    local radiusSqr = radius * radius

    for i = 1, #flatPoints, 3 do
        local distSqr = fallback.DistanceSqr(cx, cy, cz, flatPoints[i], flatPoints[i + 1], flatPoints[i + 2])
        if distSqr <= radiusSqr and distSqr < bestDist then
            bestDist = distSqr
            bestIndex = ((i - 1) / 3) + 1
        end
    end

    return bestIndex, bestDist
end

function fallback.CountPointsInRadius(cx, cy, cz, radius, flatPoints)
    local count = 0
    local radiusSqr = radius * radius

    for i = 1, #flatPoints, 3 do
        local distSqr = fallback.DistanceSqr(cx, cy, cz, flatPoints[i], flatPoints[i + 1], flatPoints[i + 2])
        if distSqr <= radiusSqr then
            count = count + 1
        end
    end

    return count
end

function fallback.PointIndicesInRadius(cx, cy, cz, radius, flatPoints)
    local matches = {}
    local radiusSqr = radius * radius

    for i = 1, #flatPoints, 3 do
        local distSqr = fallback.DistanceSqr(cx, cy, cz, flatPoints[i], flatPoints[i + 1], flatPoints[i + 2])
        if distSqr <= radiusSqr then
            matches[#matches + 1] = ((i - 1) / 3) + 1
        end
    end

    return matches
end

function fallback.BulletPathProbe(sx, sy, sz, ex, ey, ez, px, py, pz, ox, oy, oz, ax, ay, az, maxDistance, nearShooterDistance, minAimDot)
    local segX = ex - sx
    local segY = ey - sy
    local segZ = ez - sz
    local segLenSqr = segX * segX + segY * segY + segZ * segZ

    local t = 0
    if segLenSqr > 0 then
        t = ((px - sx) * segX + (py - sy) * segY + (pz - sz) * segZ) / segLenSqr
        if t < 0 then t = 0 end
        if t > 1 then t = 1 end
    end

    local cx = sx + segX * t
    local cy = sy + segY * t
    local cz = sz + segZ * t

    local dist = math.sqrt(fallback.DistanceSqr(px, py, pz, cx, cy, cz))
    local shooterDist = math.sqrt(fallback.DistanceSqr(px, py, pz, ox, oy, oz))

    local aimPass = true
    if shooterDist < nearShooterDistance and shooterDist > 0 then
        aimPass = (((ax * (px - ox)) + (ay * (py - oy)) + (az * (pz - oz))) / shooterDist) >= minAimDot
    end

    return dist <= maxDistance, dist, cx, cy, cz, shooterDist, aimPass
end

shz_native_opt.DistanceSqr = shz_native_opt.DistanceSqr or fallback.DistanceSqr
shz_native_opt.NearestPointIndex = shz_native_opt.NearestPointIndex or fallback.NearestPointIndex
shz_native_opt.CountPointsInRadius = shz_native_opt.CountPointsInRadius or fallback.CountPointsInRadius
shz_native_opt.PointIndicesInRadius = shz_native_opt.PointIndicesInRadius or fallback.PointIndicesInRadius
shz_native_opt.BulletPathProbe = shz_native_opt.BulletPathProbe or fallback.BulletPathProbe

function shz_native_opt.FindNearestEntity(center, radius, entities, predicate, posGetter)
    if not center or not entities then return nil, nil end

    local flatPoints = {}
    local refs = {}

    posGetter = posGetter or function(ent)
        return IsValid(ent) and ent:GetPos() or nil
    end

    for _, ent in ipairs(entities) do
        if (not predicate) or predicate(ent) then
            local pos = posGetter(ent)
            if pos then
                refs[#refs + 1] = ent
                flatPoints[#flatPoints + 1] = pos.x
                flatPoints[#flatPoints + 1] = pos.y
                flatPoints[#flatPoints + 1] = pos.z
            end
        end
    end

    if #refs == 0 then return nil, nil end

    local index, distSqr = shz_native_opt.NearestPointIndex(center.x, center.y, center.z, radius, flatPoints)
    if not index or index <= 0 then return nil, nil end

    return refs[index], distSqr
end

function shz_native_opt.FindNearestEntityInSet(center, radius, entitySet, predicate, posGetter)
    if not center or not entitySet then return nil, nil end

    local flatPoints = {}
    local refs = {}

    posGetter = posGetter or function(ent)
        return IsValid(ent) and ent:GetPos() or nil
    end

    for ent, value in pairs(entitySet) do
        if (not predicate) or predicate(ent, value) then
            local pos = posGetter(ent, value)
            if pos then
                refs[#refs + 1] = ent
                flatPoints[#flatPoints + 1] = pos.x
                flatPoints[#flatPoints + 1] = pos.y
                flatPoints[#flatPoints + 1] = pos.z
            end
        end
    end

    if #refs == 0 then return nil, nil end

    local index, distSqr = shz_native_opt.NearestPointIndex(center.x, center.y, center.z, radius, flatPoints)
    if not index or index <= 0 then return nil, nil end

    return refs[index], distSqr
end

function shz_native_opt.CountEntitiesInRadius(center, radius, entities, predicate, posGetter)
    if not center or not entities then return 0 end

    local flatPoints = {}
    posGetter = posGetter or function(ent)
        return IsValid(ent) and ent:GetPos() or nil
    end

    for _, ent in ipairs(entities) do
        if (not predicate) or predicate(ent) then
            local pos = posGetter(ent)
            if pos then
                flatPoints[#flatPoints + 1] = pos.x
                flatPoints[#flatPoints + 1] = pos.y
                flatPoints[#flatPoints + 1] = pos.z
            end
        end
    end

    if #flatPoints == 0 then return 0 end

    return shz_native_opt.CountPointsInRadius(center.x, center.y, center.z, radius, flatPoints)
end

function shz_native_opt.FindEntitiesInRadius(center, radius, entities, predicate, posGetter)
    if not center or not entities then return {} end

    local flatPoints = {}
    local refs = {}

    posGetter = posGetter or function(ent)
        return IsValid(ent) and ent:GetPos() or nil
    end

    for _, ent in ipairs(entities) do
        if (not predicate) or predicate(ent) then
            local pos = posGetter(ent)
            if pos then
                refs[#refs + 1] = ent
                flatPoints[#flatPoints + 1] = pos.x
                flatPoints[#flatPoints + 1] = pos.y
                flatPoints[#flatPoints + 1] = pos.z
            end
        end
    end

    if #refs == 0 then return {} end

    local indices = shz_native_opt.PointIndicesInRadius(center.x, center.y, center.z, radius, flatPoints)
    local matches = {}

    for _, index in ipairs(indices) do
        matches[#matches + 1] = refs[index]
    end

    return matches
end
