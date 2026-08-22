-- Compatibility bridge for addons that still use Garry's Mod's legacy umsg API.
-- Only the usermessage transport is emulated; arbitrary client Lua execution is not.

local NET_NAME = "UMSG"

if SERVER then
    util.AddNetworkString(NET_NAME)

    local pending = {}

    function umsg.Start(name, recipients)
        if pending.active then
            ErrorNoHalt("[UMSG] previous message was not ended: " .. tostring(pending.name) .. "\n")
            pending = {}
            return
        end

        pending = {
            active = true,
            name = name,
            recipients = recipients,
        }

        net.Start(NET_NAME, true)
        net.WriteString(name)
    end

    function umsg.Angle(value) net.WriteAngle(value or angle_zero) end
    function umsg.Bool(value) net.WriteBool(value or false) end
    function umsg.Char(value)
        if isstring(value) then value = string.byte(value) end
        net.WriteInt(value or 0, 8)
    end
    function umsg.Entity(value) net.WriteInt(IsValid(value) and value:EntIndex() or -1, 16) end
    function umsg.Float(value) net.WriteFloat(value or 0) end
    function umsg.Long(value) net.WriteInt(value or 0, 32) end
    function umsg.Short(value) net.WriteInt(value or 0, 16) end
    function umsg.String(value) net.WriteString(value or "") end
    function umsg.Vector(value) net.WriteVector(value or vector_origin) end
    umsg.VectorNormal = umsg.Vector

    function umsg.End()
        if not pending.active then return end

        local recipients = pending.recipients
        if recipients and recipients.GetRecipients then
            recipients = recipients:GetRecipients()
        end

        if recipients == nil then
            net.Broadcast()
        else
            net.Send(recipients)
        end

        pending = {}
    end

    return
end

function usermessage:ReadAngle() return net.ReadAngle() end
function usermessage:ReadBool() return net.ReadBool() end
function usermessage:ReadChar() return net.ReadInt(8) end
function usermessage:ReadEntity()
    local index = net.ReadInt(16)
    return index == -1 and NULL or Entity(index)
end
function usermessage:ReadFloat() return net.ReadFloat() end
function usermessage:ReadLong() return net.ReadInt(32) end
function usermessage:ReadShort() return net.ReadInt(16) end
function usermessage:ReadString() return net.ReadString() end
function usermessage:ReadVector() return net.ReadVector() end
usermessage.ReadVectorNormal = usermessage.ReadVector
function usermessage:Reset() end

usermessage.__hooks = usermessage.__hooks or {}

function usermessage.Hook(name, callback)
    usermessage.__hooks[name] = callback
end

net.Receive(NET_NAME, function()
    local name = net.ReadString()
    local callback = usermessage.__hooks[name]
    local legacy = usermessage.GetTable()[name]

    if callback then
        callback(usermessage)
    elseif legacy then
        legacy(usermessage)
    end
end)

for name, data in pairs(usermessage.GetTable()) do
    if data.Function then
        usermessage.Hook(name, data.Function)
    end
end
