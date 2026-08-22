BREACH.ResourcesPrecached = BREACH.ResourcesPrecached or false

local function precacheDirectory(dir, fully)
    local files, directories = file.Find(dir .. "*", "GAME")
    files, directories = files or {}, directories or {}

    for _, subdir in pairs(directories) do
        if subdir != ".svn" then
            precacheDirectory(dir .. subdir .. "/", fully)
        end
    end

    for _, name in ipairs(files) do
        local path = string.lower(dir .. name)
        local isMaterial = string.find(path, ".vtf") or string.find(path, ".vmt")
        local isParticle = string.find(path, ".pcf")
        local isSound = string.find(path, ".wav") or string.find(path, ".mp3") or string.find(path, ".ogg")
        local isModel = string.find(path, ".mdl")

        if isMaterial then
            Material(path, "mips")
        elseif isParticle then
            PrecacheParticleSystem(path)
        elseif isSound then
            util.PrecacheSound(path)
        elseif isModel then
            util.PrecacheModel(path)

            if fully and CLIENT then
                local model = ClientsideModel(path)
                if model then
                    model:SetPos(LocalPlayer():GetPos())
                    model:Spawn()
                    model:Remove()
                end
            end
        end
    end
end

function PrecacheDir(dir)
    precacheDirectory(dir, false)
end

function FullyPrecacheDir(dir)
    precacheDirectory(dir, true)
end

local COMMON_PRECACHE_DIRS = {
    "models/cultist/",
    "models/imperator/humans/a1_new/",
    "models/weapons/",
    "sound/nextoren/",
    "models/gmod4phun/",
    "sound/no_music/",
    "sound/player/",
    "sound/cw/",
    "sound/common/",
    "sound/physics/",
    "models/props_gffice/",
    "models/cultist_props/",
    "models/cult_props/",
    "models/noundation/",
    "models/props_beneric/",
    "models/props_canteen/",
    "models/props_glackmesa/",
    "models/props_gm/",
    "models/props_guestionableethics/",
    "models/next_breach/",
    "models/models/",
    "sound/weapons/",
    "sound/bullet/",
    "models/scp_helicopter/",
    "models/scp_chaos_jeep/"
}

local CLIENT_PRECACHE_DIRS = {
    "sound/ttt_foundation/",
    "materials/models/cultist/",
    "materials/models/all_scp_models/",
    "materials/nextoren/",
    "materials/nextoren_hud/"
}

function PrecachePlayerSounds()
    if BREACH.ResourcesPrecached then return end
    BREACH.ResourcesPrecached = true

    local startTime = SysTime()

    for _, dir in ipairs(COMMON_PRECACHE_DIRS) do
        PrecacheDir(dir)
    end

    if CLIENT then
        for _, dir in ipairs(CLIENT_PRECACHE_DIRS) do
            PrecacheDir(dir)
        end
    end

    print("End time: ", SysTime() - startTime)
end

if SERVER then
    hook.Add("InitPostEntity", "Breach:PrecacheResources", PrecachePlayerSounds)
end
