-- Chatbox shared bootstrap. The configuration module expects this namespace
-- to exist on both realms, so create it before loading config.lua.
LOUNGE_CHAT = LOUNGE_CHAT or {}

include("config.lua")

local meta = FindMetaTable("Player")
if meta then
    meta.IsTyping = meta.OldIsTyping or meta.IsTyping

    function meta:IsTyping()
        return self:GetNWBool("LOUNGE_CHAT.Typing")
    end
end
