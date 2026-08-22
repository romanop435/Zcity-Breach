BREACH = BREACH or {}

local EVENT_NET = "Breach:ClientEvent"

if SERVER then
    util.AddNetworkString(EVENT_NET)

    function BREACH.SendClientEvent(target, eventName, data)
        if not isstring(eventName) then return end

        net.Start(EVENT_NET)
        net.WriteString(eventName)
        net.WriteTable(data or {})

        if target == nil then
            net.Broadcast()
        else
            net.Send(target)
        end
    end

    return
end

local handlers = {}

local function register(name, callback)
    handlers[name] = callback
end

local allowedActions = {
    SHStart = true,
    TGStart = true,
    MOGStart = true,
    GRUCutscene = true,
    ARStart = true,
    NTFStart = true,
    GOCStart = true,
    OBRStart = true,
    ALPHA1Start = true,
    CRBStart = true,
    SHTURMONPStart = true,
    ONPStart = true,
    CutScene = true,
    CultStart = true,
}

register("action", function(data)
    local name = data.name
    if not allowedActions[name] then return end
    local callback = _G[name]
    if isfunction(callback) then callback() end
end)

register("play_sound", function(data)
    if isstring(data.sound) then surface.PlaySound(data.sound) end
end)

register("flash_window", function()
    system.FlashWindow()
end)

register("open_url", function(data)
    local allowed = {
        ["https://discord.gg/4KmXXWcZFp"] = true,
        ["https://discord.com/channels/985856355216789554/1405839318333001768"] = true
    }
    local url = tostring(data.url or "")
    if allowed[url] then gui.OpenURL(url) end
end)

register("gamestarted", function(data)
    gamestarted = data.value == true
end)

register("reset_round_flags", function()
    activeRound = nil
    preparing = false
    gamestarted = false
    postround = false
end)

register("blood_pool_iteration", function()
    CL_BLOOD_POOL_ITERATION = (CL_BLOOD_POOL_ITERATION or 1) + 1
end)

register("camera_disable", function()
    CamEnable = false
end)

register("set_vector", function(data)
    if not isvector(data.value) then return end

    if data.name == "CBG_COG_VECTOR" then CBG_COG_VECTOR = data.value
    elseif data.name == "O5_VECTOR" then O5_VECTOR = data.value
    elseif data.name == "RB_HEAD" then RB_HEAD = data.value
    elseif data.name == "RB_HAND" then RB_HAND = data.value
    elseif data.name == "RB_BODY" then RB_BODY = data.value
    elseif data.name == "RB_LEGS" then RB_LEGS = data.value
    end
end)

register("set_cltime", function(data)
    cltime = tonumber(data.value) or 0
end)

register("lz_timer", function(data)
    timer.Create("LZDecont", math.max(0, tonumber(data.delay) or 0), 1, function() end)
end)

register("close_inventory", function()
    if Breach and IsValid(Breach.InventoryMainFrame) then
        Breach.InventoryMainFrame:Remove()
    end
end)

register("clear_nvg", function()
    LocalPlayer().NVG = nil
end)

register("knocked_out", function(data)
    LocalPlayer().KnockedOut = data.value == true
end)

register("scp079_mode", function(data)
    local enabled = data.enabled == true
    local cvar = GetConVar("pp_fz_ps1_shader_enable")
    if cvar then cvar:SetFloat(enabled and 1 or 0) end

    local ply = LocalPlayer()
    ply.br_scp079_mode = enabled
    if enabled then ply:ScreenFade(SCREENFADE.IN, color_black, 1, 1) end
end)

register("select_default_class", function()
    if isfunction(SelectDefaultClass) then
        SelectDefaultClass(LocalPlayer():GTeam())
    end
end)

register("select_supp_menu", function()
    if isfunction(Select_Supp_Menu) then
        Select_Supp_Menu(LocalPlayer():GTeam())
    end
end)

register("select_weapon", function(data)
    if isstring(data.class) then LocalPlayer():SelectWeapon(data.class) end
end)

register("draw_role_desc", function()
    if isfunction(DrawNewRoleDesc) then DrawNewRoleDesc() end
end)

register("stop_music", function()
    if isfunction(StopMusic) then StopMusic() end
end)

register("open_914", function()
    if isfunction(Open914Menu) then Open914Menu() end
end)

register("arbuz", function(data)
    if isfunction(ArbuzFunc) and IsValid(data.entity) then ArbuzFunc(data.entity:EntIndex()) end
end)

register("combine_line", function(data)
    if DarkRP and isfunction(DarkRP.AddCombineDisplayLine) and isstring(data.text) then
        DarkRP.AddCombineDisplayLine(data.text, data.color or color_white)
    end
end)

register("custom_gloves", function(data)
    if not isstring(data.material) then return end
    local hands = LocalPlayer():GetHands()
    if not IsValid(hands) then return end

    for index, material in ipairs(hands:GetMaterials()) do
        if material == "models/shakytest/vm_mp_beta_glove_iw9_1_1" then
            hands:SetSubMaterial(index - 1, data.material)
        end
    end
end)

register("request_bullet_log", function()
    if not LeyHitreg or not LeyHitreg.bulletlog then return end
    net.Start("Breach:RequestBulletLog")
    net.WriteTable(LeyHitreg.bulletlog)
    net.SendToServer()
end)

register("particle_world", function(data)
    if not isstring(data.effect) or not isvector(data.pos) then return end
    ParticleEffect(data.effect, data.pos, angle_zero, game.GetWorld())
end)

register("particle_entity", function(data)
    if not isstring(data.effect) or not isvector(data.pos) or not IsValid(data.entity) then return end
    ParticleEffect(data.effect, data.pos, angle_zero, data.entity)
end)

register("particle_attach", function(data)
    if not isstring(data.effect) or not IsValid(data.entity) then return end
    local attachment = data.entity:LookupAttachment(data.attachment or "")
    ParticleEffectAttach(data.effect, PATTACH_POINT_FOLLOW, data.entity, attachment)
end)

register("effect_entity", function(data)
    if not isstring(data.effect) or not IsValid(data.entity) then return end
    local effect = EffectData()
    effect:SetEntity(data.entity)
    util.Effect(data.effect, effect)
end)

register("ability_cooldown", function(data)
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or not wep.AbilityIcons then return end

    local index = tonumber(data.index) or 1
    local icon = wep.AbilityIcons[index]
    if not icon then return end

    icon.CooldownTime = CurTime() + math.max(0, tonumber(data.seconds) or 0)
end)

register("scp939_footstep", function(data)
    SCPFOOTSTEP = SCPFOOTSTEP or {}
    SCPFOOTSTEP.SCP939 = data.value == true
end)

register("gesture", function(data)
    local ent = data.entity
    if not IsValid(ent) or not isstring(data.sequence) then return end
    ent:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ent:LookupSequence(data.sequence), 0, true)
end)

register("scp500_restore", function(data)
    local amount = tonumber(data.amount) or 70
    if isfunction(addZmeczenie) then addZmeczenie(amount) end
    if isfunction(addSwiadomosc) then addSwiadomosc(amount) end
end)

register("scp1499", function(data)
    local client = LocalPlayer()
    local enabled = data.enabled == true

    if enabled then
        client.Fog_Overlay = true
        client:SetDSP(15)
        colour = .25

        local inhale = CreateSound(client, "nextoren/weapons/items/gasmask/focus_inhale_0" .. math.random(1, 4) .. ".wav")
        inhale:SetDSP(17)
        inhale:Play()

        client.scp1499_ambient = CreateSound(client, "nextoren/scp/1499/enter.ogg")
        client.scp1499_ambient:SetDSP(1)
        client.scp1499_ambient:Play()

        if not client.Gasmask_Breathing then
            client.Gasmask_Breathing = CreateSound(client, "nextoren/weapons/items/gasmask/gasmask_breathing_loop.wav")
            client.Gasmask_Breathing:Play()
        end
        return
    end

    colour = .7
    client.Fog_Overlay = nil
    client:SetDSP(1)

    local exhale = CreateSound(client, "nextoren/weapons/items/gasmask/focus_exhale_0" .. math.random(1, 4) .. ".wav")
    exhale:SetDSP(17)
    exhale:Play()

    if client.scp1499_ambient and client.scp1499_ambient:IsPlaying() then
        client.scp1499_ambient:Stop()
        client.scp1499_ambient = nil
    end

    CreateSound(client, "nextoren/scp/1499/exit.ogg"):Play()

    if client.Gasmask_Breathing then
        client.Gasmask_Breathing:Stop()
        client.Gasmask_Breathing = nil
    end
end)

net.Receive(EVENT_NET, function()
    local eventName = net.ReadString()
    local data = net.ReadTable()
    local callback = handlers[eventName]
    if callback then callback(data) end
end)
