BREACH = BREACH or {}
BREACH.DataBaseSystem = BREACH.DataBaseSystem or {}

local DB = BREACH.DataBaseSystem

local function schemaQuery(text)
    if not newMysql or not newMysql.query then
        ErrorNoHalt("[BreachDB] newMysql backend is not available.\n")
        return
    end
    newMysql.query(text, nil, function(err)
        ErrorNoHalt("[BreachDB] Schema query failed: "..tostring(err).."\n")
    end)
end

local function createTables()
    schemaQuery([[CREATE TABLE IF NOT EXISTS player_data (
        id TEXT NOT NULL,
        dataname TEXT NOT NULL,
        value TEXT
    )]])

    schemaQuery([[CREATE TABLE IF NOT EXISTS breachachievements (
        owner TEXT NOT NULL,
        achivid TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0
    )]])

    schemaQuery([[CREATE TABLE IF NOT EXISTS breach_roles (
        steamid64 TEXT NOT NULL,
        rolename TEXT NOT NULL,
        exp INTEGER NOT NULL DEFAULT 0,
        unlocked INTEGER NOT NULL DEFAULT 0,
        blacklisted INTEGER NOT NULL DEFAULT 0
    )]])

    schemaQuery([[CREATE TABLE IF NOT EXISTS breach_upgrades (
        steamid64 TEXT NOT NULL,
        rolename TEXT NOT NULL,
        upgid TEXT NOT NULL,
        exp INTEGER NOT NULL DEFAULT 0,
        unlocked INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (steamid64, rolename, upgid)
    )]])

    -- Legacy table kept for compatibility with existing code/admin tools.
    schemaQuery([[CREATE TABLE IF NOT EXISTS breach_data (
        steamid64 TEXT NOT NULL,
        dataname TEXT NOT NULL,
        value TEXT,
        PRIMARY KEY (steamid64, dataname)
    )]])

    schemaQuery("CREATE INDEX IF NOT EXISTS idx_player_data_key ON player_data(id, dataname)")
    schemaQuery("CREATE INDEX IF NOT EXISTS idx_breach_roles_key ON breach_roles(steamid64, rolename)")
    schemaQuery("CREATE INDEX IF NOT EXISTS idx_breach_achievements_key ON breachachievements(owner, achivid)")
end

function DB:Connect()
    createTables()
end

hook.Add("Initialize", "BreachDB.SchemaInit", function()
    timer.Simple(0, function()
        if DB and DB.Connect then DB:Connect() end
    end)
end)
