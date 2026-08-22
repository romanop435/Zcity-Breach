-- Server-only overrides that must be installed after entities exist.

function GAMEMODE:PlayerShouldTaunt()
    return true
end

-- Preserve the old server-side no-op override. The client animation branch in
-- the legacy shared file never ran because post-init is loaded only by server.
function GAMEMODE:HandlePlayerLanding() end

function GAMEMODE:GrabEarAnimation(ply)
    hg.earanim(ply)
end

function GAMEMODE:MouthMoveAnimation(ply)
    hg.mouthmove(ply)
end

-- Breach owns hitgroup scaling in its damage pipeline.
function GAMEMODE:ScalePlayerDamage() end
