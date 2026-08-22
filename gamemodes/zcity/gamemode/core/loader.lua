-- Breach loader.
--
-- The project now uses folders for intent:
--   game/{shared,server,client} - main gamemode code
--   systems/                    - isolated feature systems
--   animation/                  - animation base
--   config/, data/, maps/       - non-code categories
--
-- Legacy Homigrad/system trees still use sh_/sv_/cl_ prefixes. This loader
-- keeps their original two-stage order: all shared files first, then the
-- current realm. That avoids gameplay changes caused by initialization order.

BREACH = BREACH or {}
BREACH.Loader = BREACH.Loader or {}

local Loader = BREACH.Loader
local ROOT = GM.FolderName .. "/gamemode"

local SHARED, SERVER_REALM, CLIENT_REALM = 1, 2, 3
local loaded, sent = {}, {}
local started = false
local stats = {executed = 0, sent = 0, skipped = 0, duplicates = 0}

local function join(path)
    return ROOT .. "/" .. path
end


local CLIENT_ONLY = {
    ["includes/modules/styled_theme.lua"] = true,
    ["includes/modules/styled_theme_file_browser.lua"] = true,
    ["includes/modules/styled_theme_tabbed_frame.lua"] = true,
}

local function realm_from_name(name, path)
    if path and CLIENT_ONLY[string.lower(path:gsub("^" .. ROOT:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. "/", ""))] then
        return CLIENT_REALM
    end
    name = string.lower(name)
    local lower = string.lower(name)
    if lower:StartWith("sv_") or lower:EndsWith("_sv.lua") then return SERVER_REALM end
    if lower:StartWith("cl_") or lower:EndsWith("_cl.lua") then return CLIENT_REALM end
    if lower == "init_sv.lua" then return SERVER_REALM end
    if lower == "init_cl.lua" then return CLIENT_REALM end
    return SHARED
end

local function sorted(path)
    local files, dirs = file.Find(path .. "/*", "LUA")
    files, dirs = files or {}, dirs or {}

    table.sort(files, function(a, b) return string.lower(a) < string.lower(b) end)
    table.sort(dirs, function(a, b) return string.lower(a) < string.lower(b) end)
    return files, dirs
end

local function walk(path, callback)
    local files, dirs = sorted(path)

    for _, name in ipairs(files) do
        if name:sub(1, 1) ~= "_" and name:EndsWith(".lua") then
            callback(path .. "/" .. name, name)
        end
    end

    for _, name in ipairs(dirs) do
        if name:sub(1, 1) ~= "_" then
            walk(path .. "/" .. name, callback)
        end
    end
end

local function send_file(path, realm)
    if not SERVER or realm == SERVER_REALM or sent[path] then return end
    sent[path] = true
    AddCSLuaFile(path)
    stats.sent = stats.sent + 1
end

local function run_file(path, realm)
    if loaded[path] then
        stats.duplicates = stats.duplicates + 1
        return false
    end

    loaded[path] = true
    send_file(path, realm)

    if (SERVER and realm == CLIENT_REALM) or (CLIENT and realm == SERVER_REALM) then
        stats.skipped = stats.skipped + 1
        return false
    end

    include(path)
    stats.executed = stats.executed + 1
    return true
end

local function load_phase(path, realm)
    walk(path, function(file_path, name)
        if realm_from_name(name, file_path) == realm then
            run_file(file_path, realm)
        end
    end)
end

local function send_tree(path)
    if not SERVER then return end
    walk(path, function(file_path, name)
        send_file(file_path, realm_from_name(name, file_path))
    end)
end

local function load_tree(relative_path)
    local path = join(relative_path)
    load_phase(path, SHARED)

    if SERVER then
        local items_path = join("game/server/sv_items.lua")

        if file.Exists(items_path, "LUA") then
            run_file(items_path, SERVER_REALM)
        end

        load_phase(path, SERVER_REALM)
        send_tree(path)
    else
        load_phase(path, CLIENT_REALM)
    end
end

local function load_entry(relative_path, realm)
    local entry = realm == SHARED and "sh_init.lua"
        or realm == SERVER_REALM and "sv_init.lua"
        or "cl_init.lua"
    local path = join(relative_path)
    local entry_path = path .. "/" .. entry

    if file.Exists(entry_path, "LUA") then
        run_file(entry_path, realm)
    else
        load_phase(path, realm)
    end
end

local function load_systems()
    local path = join("systems")
    local _, dirs = sorted(path)

    for _, name in ipairs(dirs) do
        if name:sub(1, 1) == "_" then continue end

        local system = "systems/" .. name
        local system_path = join(system)
        local has_shared_entry = file.Exists(system_path .. "/sh_init.lua", "LUA")

        if not has_shared_entry then
            load_tree(system)
            continue
        end

        -- Entry-based systems own their internal shared loading. Optional
        -- realm entries are explicit too, avoiding the legacy loader's
        -- accidental second execution of files already included by sh_init.
        load_entry(system, SHARED)

        if SERVER then
            if file.Exists(system_path .. "/sv_init.lua", "LUA") then
                load_entry(system, SERVER_REALM)
            end
            send_tree(system_path)
        elseif file.Exists(system_path .. "/cl_init.lua", "LUA") then
            load_entry(system, CLIENT_REALM)
        end
    end
end

local function load_languages()
    local path = join("languages")
    local files = select(1, sorted(path))
    for _, name in ipairs(files) do
        if name:EndsWith(".lua") then
            run_file(path .. "/" .. name, SHARED)
        end
    end
end

local function load_game()
    -- Shared configuration required by both realms during startup.
    run_file(join("config/music.lua"), SHARED)
    run_file(join("config/utopia_core.lua"), SHARED)

    -- Bootstrap order is intentionally explicit. These four legacy files are
    -- large dependency roots and moving their execution changes the gamemode.
    run_file(join("game/bootstrap/shared.lua"), SHARED)

    -- roles_scp.lua depends on the role/team constants created by the shared bootstrap.
    -- Languages depend on the role table, while server bootstrap depends on BOTH.
    run_file(join("game/shared/roles_scp.lua"), SHARED)
    load_languages()

    run_file(join("game/bootstrap/client_events.lua"), SHARED)

    if SERVER then
        -- Persistence schema must exist before the optional Utopia data modules.
        run_file(join("game/bootstrap/persistence.lua"), SERVER_REALM)
        run_file(join("game/bootstrap/server.lua"), SERVER_REALM)

        -- Utopia server modules are dependency roots. They must execute before
        -- game/server tree traversal so rounds and player systems can consume them.
        run_file(join("game/server/utopia/sv_mysql.lua"), SERVER_REALM)
        run_file(join("game/server/utopia/sv_player_data.lua"), SERVER_REALM)
        run_file(join("game/server/utopia/sv_achievements.lua"), SERVER_REALM)
        run_file(join("game/server/utopia/sv_round_setup.lua"), SERVER_REALM)

        send_file(join("game/bootstrap/client.lua"), CLIENT_REALM)

        run_file(join("data/sv_names.lua"), SERVER_REALM)
        send_file(join("config/changelogs.lua"), CLIENT_REALM)
        send_file(join("config/donatelist.lua"), CLIENT_REALM)
    else
        run_file(join("game/bootstrap/client.lua"), CLIENT_REALM)
    end

    -- This table used to be the only no-prefix file in modules/, therefore it
    -- executed before cl_/sh_/sv_ files. Keep that exact order.
    run_file(join("game/shared/achievement_definitions.lua"), SHARED)

    if CLIENT then
        run_file(join("game/client/compat_bonemerge.lua"), CLIENT_REALM)
        walk(join("game/client"), function(path) run_file(path, CLIENT_REALM) end)
        walk(join("game/shared"), function(path) run_file(path, SHARED) end)
    else
        walk(join("game/shared"), function(path) run_file(path, SHARED) end)
        walk(join("game/server"), function(path) run_file(path, SERVER_REALM) end)
        send_tree(join("game/client"))
        send_tree(join("game/shared"))
    end
end

local function load_map()
    local path = join("maps/" .. game.GetMap() .. ".lua")
    MAP_LOADED = false

    if file.Exists(path, "LUA") then
        -- Map configs are server-side data. They can be very large and are not
        -- needed by the client. Loading them as SHARED makes AddCSLuaFile try
        -- to send the whole file and hits the 64 KB client-file limit.
        if SERVER then
            run_file(path, SERVER_REALM)

            -- Optional map prop database. It is intentionally SERVER ONLY.
            local prop_path = join("maps/prop_loot.lua")
            if file.Exists(prop_path, "LUA") then
                run_file(prop_path, SERVER_REALM)
            end
        end
        MAP_LOADED = true
    elseif SERVER then
        print("[Breach] Unsupported map: " .. game.GetMap())
    end
end

local function load_native()
    if BREACH.Native ~= nil then return end

    -- The open build ships only the optional module source, not a platform
    -- binary in lua/bin. Calling require() in that state makes GMod emit a
    -- hard include error before falling back. Keep the supported Lua path
    -- silent and deterministic. Drop a compiled module in lua/bin and set
    -- BREACH.Native from a tiny autorun if native acceleration is desired.
    BREACH.Native = false
end

function Loader.GetStats()
    return table.Copy(stats)
end

function Loader.Start()
    if started then return end
    started = true

    load_native()
    load_tree("includes")

    -- Homigrad shared files populate hg at file scope, so the namespace must
    -- exist before the first Homigrad include. The old order only worked when
    -- another addon happened to create hg first.
    hg = hg or {}
    hg.Version = "Release 1.02"

    load_tree("homigrad")
    hg.loaded = true

    load_game()
    load_tree("animation")
    load_systems()
    load_map()

    if SERVER then
        hook.Add("InitPostEntity", "Breach.Loader.PostInit", function()
            run_file(join("postinit/server.lua"), SERVER_REALM)
            hook.Remove("InitPostEntity", "Breach.Loader.PostInit")
        end)
    end
end
