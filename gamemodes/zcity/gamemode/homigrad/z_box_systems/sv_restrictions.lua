ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}

local PLUGIN = ZBox.Plugins.Restrictions or {}
ZBox.Plugins.Restrictions = PLUGIN
PLUGIN.Name = "Restrictions"
PLUGIN.Hooks = {}

local Hook = PLUGIN.Hooks

for _, hookName in ipairs({
    "PlayerSpawnVehicle",
    "PlayerSpawnRagdoll",
    "PlayerSpawnNPC",
    "PlayerSpawnEffect"
}) do
    Hook[hookName] = function()
        return false
    end
end

-- Prop spawning was intentionally left unrestricted in the legacy code.
Hook.PlayerSpawnProp = function() end

local function adminOnly(ply)
    if not ply:IsAdmin() then return false end
end

Hook.PlayerSpawnSWEP = adminOnly
Hook.PlayerGiveSWEP = adminOnly
Hook.PlayerSpawnSENT = adminOnly

function Hook.PlayerNoClip(ply)
    return ply:IsAdmin()
end
