BREACH = BREACH or {}

ALLLANGUAGES = ALLLANGUAGES or {}
WEPLANG = WEPLANG or {}
russian = russian or {}
nontranslated = nontranslated or {}

function GM:PlayerNoClip()
    return false
end

include("core/language.lua")

BREACH.Loader.Start()
