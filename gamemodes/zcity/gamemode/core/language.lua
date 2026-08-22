-- Language maintenance helpers. Kept out of shared.lua so the gamemode
-- bootstrap stays small and language tooling can evolve independently.

BREACH = BREACH or {}

function BREACH.CompareLanguage(language)
    local missing = {}

    for key, value in pairs(russian or {}) do
        if language[key] == nil then
            missing[key] = value
        end
    end

    return missing
end

local function complete_language(_, _, args)
    local prefix = string.lower(args[1] or "")
    local result = {}

    for language in pairs(ALLLANGUAGES or {}) do
        if prefix == "" or string.StartWith(string.lower(language), prefix) then
            result[#result + 1] = "breach_compare_language " .. language
        end
    end

    table.sort(result)
    return result
end

concommand.Add("breach_compare_language", function(_, _, args)
    local language = args[1]
    local data = language and ALLLANGUAGES and ALLLANGUAGES[language]

    if not data then
        print("[Breach] Language not found: " .. tostring(language))
        return
    end

    local missing = BREACH.CompareLanguage(data)
    local count = table.Count(missing)

    if count > 0 then
        PrintTable(missing)
        print("[Breach] " .. count .. " missing phrases in " .. language)
        return
    end

    print("[Breach] Language " .. language .. " is up to date.")
end, complete_language)
