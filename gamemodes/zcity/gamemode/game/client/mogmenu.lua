MainMogFrame = MainMogFrame or {}
MainMogFrame.comand_chars = MainMogFrame.comand_chars or {}
MainMogFrame.bg_chars = MainMogFrame.bg_chars or {}

local rust_bg       = Color(18, 16, 15, 245)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_red      = Color(188, 64, 43)
local rust_yellow   = Color(218, 165, 32)
local rust_green    = Color(112, 126, 73)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)

file.CreateDir("mog_presets_v2")

for _, size in ipairs({16, 12, 10, 8, 7, 6, 5, 4, 3}) do
    surface.CreateFont("MogM_" .. size, {
        font = "Hitmarker Normal",
        size = ScreenScale(size),
        extended = true,
        weight = 300
    })
end

local animatia_table = {
    "idle_passive", "idle_relaxed_ar2_1", "idle_relaxed_ar2_2", 
    "idle_relaxed_ar2_3", "idle_relaxed_ar2_4", "idle_relaxed_ar2_5", 
    "idle_relaxed_ar2_6", "idle_relaxed_ar2_7", "idle_relaxed_ar2_8", 
    "idle_relaxed_ar2_9"
}

local function SetupMogDummy(pos, ang, model, wepClass, animTable, cycleSpeed)
    local character = ents.CreateClientside("base_gmodentity")
    character:SetPos(pos or Vector(0,0,0))
    character:SetAngles(ang)
    character:SetModel(model)
    character:Spawn()

    local anim = istable(animTable) and table.Random(animTable) or animTable
    character:SetSequence(character:LookupSequence(anim) or 0)
    character:SetCycle(0)
    character:SetPlaybackRate(1)

    character.currentWep = wepClass

    local weapon = ents.CreateClientside("base_gmodentity")
    weapon:SetModel("models/weapons/w_cw_kk_ins2_rpk_tac.mdl")
    weapon:SetMoveType(MOVETYPE_NONE)
    weapon:SetNoDraw(true)
    weapon:Spawn()
    character.weaponEnt = weapon

    local nextblink = SysTime() + math.Rand(0.1, 1)
    local blink_tar = NULL
    local blink_id = character:GetFlexIDByName("Eyes")
    local gesturelist = {"hg_chest_twistL", "HG_TURNR", "HG_TURNL"}
    local nextgesture = SysTime() + math.Rand(0.1, 1)
    local blinkback, doblink, lookingaround, waitbegin = false, false, false, false
    local blinklerp = 0
    local blink_speed = 7
    local lookaround_val, lookaroundendtime = 0, 0
    local nextlookaround = SysTime() + math.Rand(3, 10)
    local reverse_look = false
    local headid = character:LookupBone("ValveBiped.Bip01_Head1")
    local headid2 = character:LookupBone("ValveBiped.Bip01_Neck1")
    local headang = Angle(0, 0, 0)

    character.Draw = function(self)
        self:DrawModel()
        local t = SysTime()
        local ft = FrameTime()

        local w_name = self.currentWep or "weapon_hk416"
        local wd = weapons.Get(w_name)
        if wd and wd.WorldModel and IsValid(self.weaponEnt) then
            if self.weaponEnt:GetModel() ~= wd.WorldModel then
                self.weaponEnt:SetModel(wd.WorldModel)
            end
            
            local att = self:LookupAttachment('anim_attachment_RH')
            if att > 0 then
                local attData = self:GetAttachment(att)
                if attData then
                    if w_name:find("medkit") then
                        self.weaponEnt:SetPos(attData.Pos)
                        self.weaponEnt:SetAngles(Angle(attData.Ang.x + 90, attData.Ang.y, attData.Ang.z))
                        if wd.Skin then self.weaponEnt:SetSkin(wd.Skin) end
                    else
                        self.weaponEnt:SetPos(attData.Pos)
                        self.weaponEnt:SetAngles(attData.Ang)
                    end
                    self.weaponEnt:DrawModel()
                end
            end
        end

        self:SetCycle(math.Approach(self:GetCycle(), 1, ft * (cycleSpeed or 0.2)))
        if self:GetCycle() >= 1 then self:SetCycle(0) end

        if nextgesture <= t then
            self:SetLayerSequence(0, self:LookupSequence(gesturelist[math.random(1, #gesturelist)]))
            self:SetLayerCycle(0.4)
            nextgesture = t + math.Rand(0.1, 5.5)
        end

        if not IsValid(blink_tar) and self.BoneMergedEnts then
            for _, bnm in pairs(self.BoneMergedEnts) do
                if IsValid(bnm) then
                    local mdl = bnm:GetModel()
                    if mdl and (mdl:find("male_head") or mdl:find("fat")) then
                        blink_tar = bnm
                        blink_id = blink_tar:GetFlexIDByName("Eyes")
                    end
                end
            end
        end

        if t >= nextblink and not doblink and IsValid(blink_tar) then
            nextblink = t + math.Rand(0.5, 2.6)
            blinkback, blinklerp, doblink = false, 0, true
            blink_speed = math.Rand(7, 10)
        end

        if nextlookaround <= t and not lookingaround then lookingaround = true end

        if lookingaround and headid and headid2 then
            if lookaroundendtime <= t and not waitbegin then
                lookaround_val = math.Approach(lookaround_val, 1, ft / 2)
                if lookaround_val == 1 then
                    lookaroundendtime = t + 3
                    waitbegin = true
                end
            elseif lookaround_val >= 0 and lookaroundendtime <= t and waitbegin then
                lookaround_val = math.Approach(lookaround_val, 0, ft / 2)
                if lookaround_val == 0 then
                    reverse_look, waitbegin, lookingaround = not reverse_look, false, false
                    nextlookaround = t + math.Rand(5, 10)
                end
            end
            
            local easeval = waitbegin and math.ease.InQuart(lookaround_val) or math.ease.OutQuint(lookaround_val)
            local mul = reverse_look and -20 or 10
            headang.r = easeval * mul
            self:ManipulateBoneAngles(headid, headang)
            self:ManipulateBoneAngles(headid2, Angle(0, 0, (easeval * .4) * mul))
        end

        if doblink and blink_id and IsValid(blink_tar) then
            blinklerp = math.Approach(blinklerp, blinkback and 0 or 1, ft * blink_speed)
            if blinklerp == 1 then blinkback = true end
            blink_tar:SetFlexWeight(blink_id, blinklerp)
            if blinkback and blinklerp == 0 then doblink = false end
        end
    end

    character.OnRemove = function(self)
        if IsValid(self.weaponEnt) then self.weaponEnt:Remove() end
    end

    return character
end

net.Receive("Breach:SENDMOGVIStoCLIENT", function(len, sender_ply)
    local C_1_1 = net.ReadString()
    local C_1_2 = net.ReadString()
    local C_1_3 = net.ReadTable()
    local C_1_4 = net.ReadInt(8)
    local C_2_1 = net.ReadString()
    local headmat = net.ReadString()
    local ply = net.ReadPlayer()

    if not IsValid(ply) or ply:SteamID64() == LocalPlayer():SteamID64() then return end

    local pos = nil
    for i = #MainMogFrame.comand_chars, 1, -1 do
        local v = MainMogFrame.comand_chars[i]
        if IsValid(v) and v.steamid == ply:SteamID64() then
            pos = v:GetPos()
            v:Remove()
            table.remove(MainMogFrame.comand_chars, i)
        end
    end

    if LocalPlayer():GetModel() ~= "models/cultist/humans/mog/mog.mdl" then return end

    local character = SetupMogDummy(pos, Angle(2.835, -100.4, 0), LocalPlayer():GetModel(), C_2_1, animatia_table, 0.2)
    character.steamid = ply:SteamID64()
    
    if C_1_1 ~= "а нету" then ClientBoneMerge(character, C_1_1) end
    local head = ClientBoneMerge(character, C_1_2)
    if C_1_2 ~= "models/cultist/humans/balaclavas_new/mog_hazmat.mdl" and IsValid(head) then
        head:SetSubMaterial(0, headmat)
    end

    character:SetSkin(C_1_4)
    for bg, val in pairs(C_1_3) do character:SetBodygroup(bg, val) end

    table.insert(MainMogFrame.comand_chars, character)
end)

local CustomCameraActive, swayStartTime, originalViewData = false, 0, nil

local function RestoreHeadScale()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local head = ply:LookupBone("ValveBiped.Bip01_Head1")
    if head then ply:ManipulateBoneScale(head, Vector(1, 1, 1)) end
    
    local rag = ply:GetNWEntity("FakeRagdoll")
    if IsValid(rag) then
        local rhead = rag:LookupBone("ValveBiped.Bip01_Head1")
        if rhead then rag:ManipulateBoneScale(rhead, Vector(1, 1, 1)) end
    end
end

local function GetCustomCameraView(fov)
    local ct = CurTime() - swayStartTime
    local view = {
        origin = Vector(7552.584, -4492.091, 60),
        angles = Angle(6.174 + math.sin(ct * 0.7) * 0.3, 126.334 + math.cos(ct * 0.5) * 0.2, math.sin(ct * 0.3) * 0.1),
        fov = fov or 90,
        drawviewer = true
    }
    RestoreHeadScale()
    return view
end

concommand.Add("camera_move_to", function()
    if not CustomCameraActive then originalViewData = { pos = LocalPlayer():EyePos(), angles = LocalPlayer():EyeAngles() } end
    CustomCameraActive = true
    swayStartTime = CurTime()
    gui.EnableScreenClicker(false) 
    input.SetCursorPos(ScrW() / 2, ScrH() / 2)
end)

concommand.Add("camera_reset", function()
    CustomCameraActive = false
    if originalViewData then
        LocalPlayer():SetEyeAngles(originalViewData.angles)
        originalViewData = nil 
    end
    gui.EnableScreenClicker(true)
end)

zb = zb or {}
local old_zb_OverrideCalcView = zb.OverrideCalcView
zb.OverrideCalcView = function(ply, origin, angles, fov, znear, zfar)
    if CustomCameraActive then return GetCustomCameraView(fov) end
    if old_zb_OverrideCalcView then return old_zb_OverrideCalcView(ply, origin, angles, fov, znear, zfar) end
end

timer.Simple(1, function()
    if DrawPlayerRagdoll and not OLD_DrawPlayerRagdoll then
        OLD_DrawPlayerRagdoll = DrawPlayerRagdoll
        DrawPlayerRagdoll = function(ent, ply)
            OLD_DrawPlayerRagdoll(ent, ply)
            if CustomCameraActive and IsValid(ent) then
                local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
                if headBone then
                    local mat = ent:GetBoneMatrix(headBone)
                    if mat then
                        mat:SetScale(Vector(1, 1, 1))
                        if hg and hg.bone_apply_matrix then hg.bone_apply_matrix(ent, headBone, mat)
                        else ent:SetBoneMatrix(headBone, mat) end
                    end
                end
            end
        end
    end
end)

local function CreateAnimatedButton(parent, text, iconMat, x, y, w, h, onClick, onRightClick)
    local btn = vgui.Create("DButton", parent)
    
    if x and y then
        btn:SetPos(x, y)
        btn:SetSize(w, h)
    else
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 2)
        btn:SetTall(h or 30)
    end
    
    btn:SetText("")
    btn.HoverLerp = 0

    btn.Think = function(s)
        s.HoverLerp = math.Approach(s.HoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 12)
    end

    btn.Paint = function(s, pw, ph)
        surface.SetDrawColor(rust_panel)
        surface.DrawRect(0, 0, pw, ph)

        if s.HoverLerp > 0 then
            surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 20 * s.HoverLerp)
            surface.DrawRect(0, 0, pw, ph)
            
            surface.SetDrawColor(rust_yellow.r, rust_yellow.g, rust_yellow.b, 255 * s.HoverLerp)
            surface.DrawRect(0, ph - 2, pw, 2)
        end

        if s:IsDown() then
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, pw, ph)
        end

        surface.SetDrawColor(rust_outline)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)

        if iconMat then
            local iconSize = ph * 0.7
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(type(iconMat) == "string" and Material(iconMat, "smooth") or iconMat)
            surface.DrawTexturedRect(10, ph / 2 - iconSize / 2, iconSize, iconSize)
            
            local txtCol = s:IsHovered() and color_white or rust_text
            draw.SimpleText(text, "MM_Exp", pw - 15, ph / 2 - 1, txtCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        else
            local txtCol = s:IsHovered() and color_white or rust_text
            draw.SimpleText(text, "MM_Exp", pw / 2, ph / 2 - 1, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    btn.DoClick = function(s)
        if onClick then onClick(s) end
    end

    if onRightClick then
        btn.DoRightClick = function(s)
            if onRightClick then onRightClick(s) end
        end
    end

    return btn
end

function mog_menu()
    local function FindInConfig(configList, key, value)
        if not value then return configList[1] end
        for _, item in ipairs(configList) do if item[key] == value then return item end end
        return configList[1]
    end

    local ply = LocalPlayer()
    local team_tg = table.Random({"ALPHA","BETA","GAMMA","DELTA","ZETA","ETA","IOTA"})
    local number_tg = math.random(1,99)

    local C_1_1, C_1_2, C_1_3, C_1_4 = MogConfigurations.helmets[1], MogConfigurations.faces[1], MogConfigurations.armor[1], MogConfigurations.skins[1]
    local C_2_1, C_2_2, C_2_3, C_2_4 = MogConfigurations.primary_weapons[1], MogConfigurations.secondary_weapons[1], MogConfigurations.nvgs[1], MogConfigurations.gasmasks[1]
    local C_2_5, C_2_6 = MogConfigurations.medkits[1], MogConfigurations.consumables[1]
    local C_3_1, C_3_2, C_3_3 = MogConfigurations.health_abilities[1], MogConfigurations.speed_abilities[1], MogConfigurations.special_equipment[1]

    MainMogFrame = vgui.Create("DFrame")
    MainMogFrame:SetPos(0, 0)
    MainMogFrame:SetSize(ScrW(), ScrH())
    MainMogFrame:SetDraggable(false)
    MainMogFrame:ShowCloseButton(false)
    MainMogFrame:SetTitle("")
    MainMogFrame:SetAlpha(0)
    MainMogFrame:AlphaTo(255, 10)
    gui.EnableScreenClicker(true)
    MainMogFrame:SetMouseInputEnabled(true)
    
    MainMogFrame.Wallet = ply:IsDonator() and 500 or (GetRoleTableSH(ply:GetRoleName()).wallet or 200)

    local gU = Material("vgui/gradient_up")
    MainMogFrame.Paint = function(s, w, h)
        surface.SetMaterial(gU)
        surface.SetDrawColor(0,0,0)
        surface.DrawTexturedRect(0, h/2, w, h/2)
    end

    MainMogFrame.character = SetupMogDummy(Vector(7516.066, -4475.471, 1.331), Angle(2.83, 0.4, 0), ply:GetModel(), C_2_1.name or "cw_kk_ins2_cq300", "p_ar2_relaxedloop", 0.2)
    local character = MainMogFrame.character
    local currentBodygroups, currentskin, currentgaz, currentnvg, currentWep = {}, 0, false, nil, C_2_1.name or "cw_kk_ins2_cq300"
    for i = 0, 7 do currentBodygroups[i] = 0 end

    for _, bonemerge in pairs(ply:LookupBonemerges()) do
        if not IsValid(bonemerge) then continue end
        if bonemerge:GetModel():find('/balaclavas_new/') then
            ClientBoneMerge(character, "models/cultist/heads/male/male_head_15.mdl", bonemerge:GetSubMaterial(0))
            character.HeadMat = bonemerge:GetSubMaterial(0)
        end
    end

    if MainMogFrame.bg_chars then
        for _, v in ipairs(MainMogFrame.bg_chars) do if IsValid(v) then v:Remove() end end
    end
    MainMogFrame.bg_chars = {}

    local pos_golov = {
        Vector(7571.38, -4363.24, 1.33), Vector(7534.19, -4364.61, 1.33), Vector(7491.31, -4381.55, 1.33),
        Vector(7551.34, -4319.89, 1.33), Vector(7496.89, -4328.46, 1.33), Vector(7575.82, -4283.13, 1.33),
        Vector(7533.20, -4266.94, 1.33), Vector(7492.68, -4289.85, 1.33), Vector(7566.11, -4232.75, 1.33),
        Vector(7497.66, -4241.64, 1.33), Vector(7526.35, -4204.41, 1.33), Vector(7576.78, -4189.38, 1.33),
        Vector(7491.91, -4195.97, 1.33), Vector(7557.21, -4420.74, 1.33), Vector(7507.17, -4439.31, 1.33),
        Vector(7526.76, -4406.96, 1.33), Vector(7527.37, -4309.51, 1.33)
    }

    local weapons_table = {}
    for id, role in player.Iterator() do
        if role:GTeam() == TEAM_GUARD and role:GetModel() == "models/cultist/humans/mog/mog.mdl" then
            table.insert(weapons_table, {name = role:GetNamesurvivor(), class = role, id = id, max = 3, level = 12})
            if role:SteamID64() == ply:SteamID64() then continue end
            
            local pos = table.Random(pos_golov)
            table.RemoveByValue(pos_golov, pos)
            local bg_char = SetupMogDummy(pos, Angle(2.83, -100.4, 0), ply:GetModel(), "weapon_hk416", animatia_table, 0.05)
            bg_char.steamid = role:SteamID64()
            table.insert(MainMogFrame.bg_chars, bg_char)

            for _, bonemerge in pairs(role:LookupBonemerges()) do
                if IsValid(bonemerge) and bonemerge:GetModel():find('/balaclavas_new/') then
                    local h = ClientBoneMerge(bg_char, "models/cultist/heads/male/male_head_15.mdl")
                    if IsValid(h) then h:SetSubMaterial(0, bonemerge:GetSubMaterial(0)) end
                    bg_char.HeadMat = bonemerge:GetSubMaterial(0)
                end
            end
        end
    end

    function MainMogFrame:OnRemove()
        if IsValid(self.character) then self.character:Remove() end
        for _, v in ipairs(self.bg_chars or {}) do
            if IsValid(v) then v:Remove() end
        end
        self.bg_chars = {}
    end
    
    MainMogFrame.PlayerInfo = vgui.Create("DPanel", MainMogFrame)
    MainMogFrame.PlayerInfo:SetSize(340, 140)
    MainMogFrame.PlayerInfo:SetPos(30, 30)
    MainMogFrame.PlayerInfo.Paint = function(s, w, h)
        surface.SetDrawColor(30, 28, 25, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(218, 165, 32, 255)
        surface.DrawRect(0, 0, 4, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleText("ОПЕРАТИВНАЯ СВОДКА", "MogM_8", 15, 10, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(15, 38, w - 15, 38)

        local roleStr = string.upper(GetLangRole(ply:GetRoleName()) or "НЕИЗВЕСТНО")
        local nameStr = string.upper(ply:GetNamesurvivor() or "НЕИЗВЕСТНО")

        draw.SimpleText("ОТРЯД: " .. team_tg .. "-" .. number_tg, "MogM_6", 15, 50, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("БОЙЦОВ: " .. #weapons_table, "MogM_6", 15, 70, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("ПОЗЫВНОЙ: " .. nameStr, "MogM_6", 15, 90, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("ЗВАНИЕ: " .. roleStr, "MogM_6", 15, 110, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        draw.SimpleText("БАЛАНС: " .. MainMogFrame.Wallet .. " PT", "MogM_6", w - 15, 110, Color(218, 165, 32), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    MainMogFrame.Info = vgui.Create("DPanel", MainMogFrame)
    MainMogFrame.Info:SetSize(280, 80)
    MainMogFrame.Info:SetPos(390, 30)
    MainMogFrame.Info.Paint = function(s, w, h)
        surface.SetDrawColor(30, 28, 25, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("СТАТУС РАЗВЕРТЫВАНИЯ", "MogM_6", 15, 8, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local isTimer = timer.Exists("NewTG_SpanwTimer")
        local txt = isTimer and string.ToMinutesSeconds(timer.TimeLeft("NewTG_SpanwTimer")) or "ВЫЕЗЖАЕМ"
        local statusColor = isTimer and Color(218, 165, 32) or Color(112, 126, 73) 

        surface.SetDrawColor(statusColor)
        surface.DrawRect(0, 0, 4, h)
        draw.SimpleText(txt, "MogM_16", w / 2 + 2, h / 2 + 6, statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local TeamList = vgui.Create("DPanel", MainMogFrame)
    TeamList:SetSize(ScrW() * 0.15, ScrH() * 0.6)
    TeamList:SetPos(ScrW() - (ScrW() * 0.15) - 30, 30)
    TeamList:SetAlpha(0)
    TeamList:AlphaTo(255, 0.5)

    TeamList.Paint = function(self, w, h) end

    local ScrollPanel = vgui.Create("DScrollPanel", TeamList)
    ScrollPanel:Dock(FILL)
    ScrollPanel:DockMargin(5, 35, 5, 5)

    local bar = ScrollPanel:GetVBar()
    function bar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 150) surface.DrawRect(0, 0, w, h) end
    function bar.btnUp:Paint() end
    function bar.btnDown:Paint() end
    function bar.btnGrip:Paint(w, h) surface.SetDrawColor(80, 80, 80, 255) surface.DrawRect(0, 0, w, h) end

    for _, wep_info in ipairs(weapons_table) do
        local userBtn = ScrollPanel:Add("DButton")
        userBtn:SetText("")
        userBtn:Dock(TOP)
        userBtn:SetTall(65)
        userBtn:DockMargin(0, 0, 0, 4)
        userBtn.HoverLerp = 0

        local charPnl = vgui.Create("DModelPanel", userBtn)
        local iconSize = 55
        charPnl:SetSize(iconSize, iconSize)
        charPnl:SetPos(5, 5)
        charPnl:SetModel(wep_info.class:GetModel())
        
        charPnl:SetDirectionalLight(BOX_TOP, Color(100, 100, 100))
        charPnl:SetDirectionalLight(BOX_FRONT, Color(200, 200, 200))
        charPnl:SetDirectionalLight(BOX_RIGHT, Color(100, 100, 100))
        charPnl:SetAmbientLight(Color(50, 50, 50))

        charPnl.LayoutEntity = function(s, ent) ent:SetAngles(Angle(0, 45, 0)) end

        for _, bonemerge in pairs(wep_info.class:LookupBonemerges()) do
            if IsValid(bonemerge) and bonemerge:GetModel():find('/balaclavas_new/') then
                charPnl:BoneMerged("models/cultist/heads/male/male_head_15.mdl", bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin())
            end
        end
        
        if table.IsEmpty(charPnl.Entity:LookupBonemerges()) then charPnl:SetModel("models/cultist/humans/corpse.mdl") end
        if wep_info.class:GetRoleName() == role.TG_Com then charPnl:BoneMerged("models/cultist/humans/mog/head_gear/helmet_beret.mdl") end
        
        charPnl.Entity:SetSequence(charPnl.Entity:LookupSequence("ragdoll") or 0)
        
        timer.Simple(0, function()
            if not IsValid(charPnl) or not IsValid(charPnl.Entity) then return end
            local head = charPnl.Entity:LookupBone("ValveBiped.Bip01_Head1")
            local eyepos = head and charPnl.Entity:GetBonePosition(head) or charPnl.Entity:GetPos() + Vector(0, 0, 60)
            eyepos:Add(Vector(0, 0, 2))
            charPnl:SetLookAt(eyepos)
            charPnl:SetFOV(30)
            charPnl:SetCamPos(eyepos + Vector(40, -15, 0))
        end)

        charPnl:SetMouseInputEnabled(false)

        local isMe = (wep_info.class == ply)

        userBtn.Paint = function(s, w, h)
            s.HoverLerp = math.Approach(s.HoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 10)
            
            surface.SetDrawColor(18, 16, 15, 255)
            surface.DrawRect(0, 0, w, h)

            if s.HoverLerp > 0 then
                surface.SetDrawColor(218, 165, 32, 20 * s.HoverLerp)
                surface.DrawRect(0, 0, w, h)
            end

            if isMe then
                surface.SetDrawColor(112, 126, 73, 255)
                surface.DrawRect(0, 0, 3, h)
            elseif s.HoverLerp > 0 then
                surface.SetDrawColor(218, 165, 32, 255 * s.HoverLerp)
                surface.DrawRect(0, 0, 3, h)
            end

            surface.SetDrawColor(10, 9, 8, 200)
            surface.DrawRect(5, 5, iconSize, iconSize)
            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawOutlinedRect(5, 5, iconSize, iconSize, 1)

            local textX = iconSize + 15
            local roleStr = string.upper(GetLangRole(wep_info.class:GetRoleName()) or "ОПЕРАТИВНИК")
            local nameStr = string.upper(wep_info.name)

            draw.SimpleText(nameStr, "MogM_6", textX, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(roleStr, "MogM_5", textX, 30, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if isMe then
                draw.SimpleText("[ ВЫ ]", "MogM_6", w - 10, h / 2, Color(112, 126, 73), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end

    local activePanel = nil
    local function GetConfigIcon(cfg)
        if cfg.name and weapons.Get(cfg.name) then return weapons.Get(cfg.name).InvIcon end
        return cfg.icon and Material(cfg.icon) or Material("nextoren/gui/icons/weapons/empty.png")
    end

    local function GetConfigName(cfg) return (cfg.name and weapons.Get(cfg.name)) and weapons.Get(cfg.name).PrintName or (cfg.name or "none") end

    local function OpenConfigPanel(parentFrame, configList, pSettings, onSelect, onPreview)
        if IsValid(activePanel) then 
            local oldPanel = activePanel
            activePanel = nil
            oldPanel:AlphaTo(0, 0.15, 0, function() if IsValid(oldPanel) then oldPanel:Remove() end end)
            if oldPanel.panelID == pSettings.id then return end
        end

        local pnl = vgui.Create("DFrame", parentFrame)
        pnl:SetSize(ScrW() * 0.18, pSettings.h or (ScrH() * 0.45))
        pnl:SetPos(pSettings.x or (ScrW() * 0.05), pSettings.y or (ScrH() * 0.25))
        pnl:SetTitle("")
        pnl:ShowCloseButton(false)
        pnl:MakePopup()
        pnl:SetAlpha(0)
        pnl:AlphaTo(255, 0.15)
        pnl.panelID = pSettings.id
        activePanel = pnl

        pnl.Paint = function(s, w, h)
            surface.SetDrawColor(15, 14, 13, 245) surface.DrawRect(0, 30, w, h - 30)
            surface.SetDrawColor(30, 28, 25, 255) surface.DrawRect(0, 0, w, 30)
            surface.SetDrawColor(218, 165, 32, 255) surface.DrawRect(0, 30, w, 2)
            surface.SetDrawColor(255, 255, 255, 10) surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(string.upper(pSettings.title), "MogM_6", 15, 15, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        pnl.OnClose = function() activePanel = nil end

        local sPanel = vgui.Create("DScrollPanel", pnl)
        sPanel:Dock(FILL) sPanel:DockMargin(5, 35, 5, 5)
        local sb = sPanel:GetVBar()
        function sb:Paint(w, h) surface.SetDrawColor(10, 10, 10, 150) surface.DrawRect(0,0,w,h) end
        function sb.btnUp:Paint() end function sb.btnDown:Paint() end
        function sb.btnGrip:Paint(w, h) surface.SetDrawColor(80, 80, 80, 255) surface.DrawRect(0,0,w,h) end

        for _, cfg in ipairs(configList) do
            local btn = vgui.Create("DButton", sPanel)
            btn:SetText("") btn:SetTall(60) btn:Dock(TOP) btn:DockMargin(5, 5, 5, 0)
            btn.HoverLerp = 0
            
            btn.Paint = function(s, w, h)
                s.HoverLerp = math.Approach(s.HoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 12)
                surface.SetDrawColor(30, 28, 25, 255) surface.DrawRect(0, 0, w, h)
                if s.HoverLerp > 0 then
                    surface.SetDrawColor(218, 165, 32, 20 * s.HoverLerp) surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(218, 165, 32, 255 * s.HoverLerp) surface.DrawRect(0, h - 2, w, 2)
                end
                surface.SetDrawColor(255, 255, 255, 10) surface.DrawOutlinedRect(0, 0, w, h, 1)

                draw.SimpleText(string.upper(L(GetConfigName(cfg))), "MogM_5", 65, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                if cfg.buf and cfg.buf ~= "" then draw.SimpleText(L(cfg.buf), "MogM_4", 65, 30, Color(112, 126, 73), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
                if cfg.debuf and cfg.debuf ~= "" then draw.SimpleText(L(cfg.debuf), "MogM_4", 65, 45, Color(188, 64, 43), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end                

                if cfg.price and cfg.price > 0 then
                    draw.SimpleText(cfg.price .. " PT", "MogM_6", w - 10, h/2, pSettings.canAffordCheck(cfg.price) and Color(218, 165, 32) or Color(188, 64, 43), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
                
                local mat = GetConfigIcon(cfg)
                if type(mat) == "IMaterial" or type(mat) == "string" then
                    surface.SetDrawColor(255, 255, 255, 255) 
                    surface.SetMaterial(type(mat) == "string" and Material(mat, "smooth") or mat) 
                    surface.DrawTexturedRect(10, 10, 40, 40)
                end
            end
            
            btn.OnCursorEntered = function() if onPreview then onPreview(cfg, true) end end
            btn.OnCursorExited = function() if onPreview then onPreview(cfg, false) end end
            
            btn.DoClick = function()
                if onSelect(cfg) then
                    --net.Start("Breach:SENDMOGVIS")
                    --net.WriteString(C_1_1 and C_1_1.model or "а нету")
                    --net.WriteString(C_1_2 and C_1_2.model or "а нету")
                    --net.WriteTable(C_1_3 and C_1_3.bodygroups or {})
                    --net.WriteInt(C_1_4 and C_1_4.skin or 0, 8)
                    --net.WriteString(C_2_1 and C_2_1.name or "none")
                    --net.WriteString(character.HeadMat or "")
                    --net.SendToServer()
                    
                    if IsValid(activePanel) then
                        local p = activePanel
                        activePanel = nil
                        p:AlphaTo(0, 0.15, 0, function() if IsValid(p) then p:Remove() end end)
                    end
                end
            end
        end
    end

    local function CreateMogButton(parent, pd, initialIcon, onClickFunc)
        local btn = vgui.Create("DButton", parent)
        btn:SetSize(pd.w or (ScrW() / 25), pd.h or (ScrW() / 25))
        btn:SetPos(pd.x, pd.y)
        btn:SetText("")
        btn.currentIcon, btn.locked, btn.HoverLerp = initialIcon, false, 0

        btn.Paint = function(s, w, h)
            s.HoverLerp = math.Approach(s.HoverLerp, s:IsHovered() and 1 or 0, FrameTime() * 12)
            surface.SetDrawColor(30, 28, 25, 255) surface.DrawRect(0, 0, w, h)
            
            if s.HoverLerp > 0 and not s.locked then
                surface.SetDrawColor(218, 165, 32, 20 * s.HoverLerp) surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(218, 165, 32, 255 * s.HoverLerp) surface.DrawRect(0, h - 2, w, 2)
            end
            surface.SetDrawColor(255, 255, 255, 10) surface.DrawOutlinedRect(0, 0, w, h, 1)

            if s.currentIcon then
                surface.SetDrawColor(255, 255, 255, s.locked and 80 or 255)
                surface.SetMaterial(type(s.currentIcon) == "string" and Material(s.currentIcon, "smooth") or s.currentIcon)
                surface.DrawTexturedRect(5, 5, w - 10, h - 10)
            end
            
            if s.locked then
                surface.SetDrawColor(188, 64, 43, 50) surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(255, 100, 100, 200) surface.SetMaterial(Material("nextoren/mog/abb/locked_m.png", "smooth")) surface.DrawTexturedRect(0, 0, w, h)
                surface.SetDrawColor(188, 64, 43, 255) surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
        end
        btn.DoClick = function(s) if not s.locked then onClickFunc(s) end end
        return btn
    end

    MainMogFrame.Buttons = {}

    local function SafeRemoveErrors(charEnt)
        if not IsValid(charEnt) or not charEnt.BoneMergedEnts then return end
        for _, b in pairs(charEnt.BoneMergedEnts) do
            if IsValid(b) then
                local mdl = b:GetModel()
                if not mdl or mdl == "models/error.mdl" or mdl == "error.mdl" then
                    b:Remove()
                end
            end
        end
    end

    MainMogFrame.Buttons.helmet = CreateMogButton(MainMogFrame, {x = ScrW()/4, y = ScrH()/1.15}, C_1_1.icon, function(btn)
        if ply:GetRoleName() == role.TG_Com then return end
        OpenConfigPanel(MainMogFrame, MogConfigurations.helmets, {title = "Головные уборы", id = "helmets", x = ScrW()/4, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_1_1.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_1_1.price) >= sel.price then
                    for _, b in pairs(character.BoneMergedEnts or {}) do 
                        if IsValid(b) then
                            local bMdl = b:GetModel()
                            if bMdl == C_1_1.model or bMdl == sel.model then b:Remove() end 
                        end
                    end
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_1_1.price - sel.price
                    C_1_1 = sel
                    if sel.model and sel.model ~= "none" then ClientBoneMerge(character, sel.model) end
                    SafeRemoveErrors(character)
                    btn.currentIcon = sel.icon
                    return true
                end return false
            end,
            function(cfg, hvr)
                for _, b in pairs(character.BoneMergedEnts or {}) do 
                    if IsValid(b) then
                        local bMdl = b:GetModel()
                        if bMdl == C_1_1.model or bMdl == cfg.model then b:Remove() end 
                    end
                end
                
                local target = hvr and cfg.model or C_1_1.model
                if target and target ~= "none" then 
                    ClientBoneMerge(character, target) 
                end
                SafeRemoveErrors(character)
            end)
    end)
    if ply:GetRoleName() == role.TG_Com then MainMogFrame.Buttons.helmet.currentIcon = "nextoren/mog/hel/head.png" MainMogFrame.Buttons.helmet.locked = true end

    MainMogFrame.Buttons.face = CreateMogButton(MainMogFrame, {x = ScrW()/3.42, y = ScrH()/1.15}, C_1_2.icon, function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.faces, {title = "Маски", id = "masks", x = ScrW()/4, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_1_2.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_1_2.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_1_2.price - sel.price
                    C_1_2 = sel
                    btn.currentIcon = sel.icon
                    for _, b in pairs(character.BoneMergedEnts or {}) do 
                        if IsValid(b) then
                            local bMdl = b:GetModel()
                            if bMdl and (bMdl:find("/balaclavas_new/") or bMdl == "models/cultist/heads/male/male_head_15.mdl") then b:Remove() end 
                        end
                    end
                    local tModel = (sel.model and sel.model ~= "none") and sel.model or "models/cultist/heads/male/male_head_15.mdl"
                    local h = ClientBoneMerge(character, tModel)
                    
                    if IsValid(h) then 
                        h:SetSubMaterial(0, tModel ~= "models/cultist/humans/balaclavas_new/mog_hazmat.mdl" and (character.HeadMat or "") or "") 
                    end
                    SafeRemoveErrors(character)
                    return true
                end return false
            end,
            function(cfg, hvr)
                for _, b in pairs(character.BoneMergedEnts or {}) do 
                    if IsValid(b) then
                        local bMdl = b:GetModel()
                        if bMdl and (bMdl:find("/balaclavas_new/") or bMdl == "models/cultist/heads/male/male_head_15.mdl") then b:Remove() end 
                    end
                end
                
                local target = hvr and cfg or C_1_2
                local tModel = "models/cultist/heads/male/male_head_15.mdl"
                if target and target.model and target.model ~= "none" then
                    tModel = target.model
                end
                
                local h = ClientBoneMerge(character, tModel)
                if IsValid(h) then 
                    h:SetSubMaterial(0, tModel ~= "models/cultist/humans/balaclavas_new/mog_hazmat.mdl" and (character.HeadMat or "") or "") 
                end
                SafeRemoveErrors(character)
            end)
    end)

    MainMogFrame.Buttons.armor = CreateMogButton(MainMogFrame, {x = ScrW()/2.99, y = ScrH()/1.15}, C_1_3.icon, function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.armor, {title = "Бронежилеты", id = "armor", x = ScrW()/4, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + (C_1_3 and C_1_3.price or 0)) >= price end},
            function(sel)
                if MainMogFrame.Wallet + (C_1_3 and C_1_3.price or 0) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + (C_1_3 and C_1_3.price or 0) - sel.price
                    C_1_3 = sel
                    for bg, val in pairs(sel.bodygroups) do character:SetBodygroup(bg, val) currentBodygroups[bg] = val end
                    btn.currentIcon = sel.icon
                    return true
                end return false
            end,
            function(cfg, hvr)
                if hvr then 
                    for bg, val in pairs(cfg.bodygroups) do character:SetBodygroup(bg, val) end 
                else
                    for bg, _ in pairs(cfg.bodygroups) do character:SetBodygroup(bg, currentBodygroups[bg] or 0) end 
                end
            end)
    end)

    MainMogFrame.Buttons.skin = CreateMogButton(MainMogFrame, {x = ScrW()/2.65, y = ScrH()/1.15}, C_1_4.icon, function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.skins, {title = "Комбинезоны", id = "skins", x = ScrW()/4, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_1_4.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_1_4.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_1_4.price - sel.price
                    C_1_4, currentskin = sel, sel.skin
                    character:SetSkin(sel.skin)
                    btn.currentIcon = sel.icon
                    return true
                end return false
            end,
            function(cfg, hvr) character:SetSkin(hvr and cfg.skin or currentskin) end)
    end)

    MainMogFrame.Buttons.primary = CreateMogButton(MainMogFrame, {x = ScrW()/1.9, y = ScrH()/1.15}, GetConfigIcon(C_2_1), function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.primary_weapons, {title = "Основное оружие", id = "primary_wep", x = ScrW()/1.9, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_2_1.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_2_1.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_2_1.price - sel.price
                    C_2_1, currentWep = sel, sel.name
                    character.currentWep = currentWep
                    character:ResetSequence(character:LookupSequence("p_ar2_relaxedloop"))
                    btn.currentIcon = GetConfigIcon(sel)
                    return true
                end return false
            end,
            function(cfg, hvr) character.currentWep = hvr and cfg.name or currentWep end)
    end)

    MainMogFrame.Buttons.secondary = CreateMogButton(MainMogFrame, {x = ScrW()/1.76, y = ScrH()/1.15}, GetConfigIcon(C_2_2), function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.secondary_weapons, {title = "Вторичное оружие", id = "sec_wep", x = ScrW()/1.9, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_2_2.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_2_2.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_2_2.price - sel.price
                    C_2_2, character.currentWep = sel, currentWep
                    character:ResetSequence(character:LookupSequence("p_ar2_relaxedloop"))
                    btn.currentIcon = GetConfigIcon(sel)
                    return true
                end return false
            end,
            function(cfg, hvr) character.currentWep = (hvr and cfg.name) and cfg.name or currentWep end)
    end)

    MainMogFrame.Buttons.nvg = CreateMogButton(MainMogFrame, {x = ScrW()/1.64, y = ScrH()/1.15}, GetConfigIcon(C_2_3), function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.nvgs, {title = "Спец. оборудование", id = "nvg", x = ScrW()/1.9, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_2_3.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_2_3.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_2_3.price - sel.price
                    C_2_3, currentnvg = sel, sel.model
                    for _, b in pairs(character.BoneMergedEnts or {}) do 
                        if IsValid(b) then
                            local bMdl = b:GetModel()
                            if bMdl and bMdl:find("/nightvision/") then b:Remove() end 
                        end
                    end
                    if sel.model and sel.model ~= "none" then ClientBoneMerge(character, sel.model) end
                    SafeRemoveErrors(character)
                    btn.currentIcon = GetConfigIcon(sel)
                    return true
                end return false
            end,
            function(cfg, hvr)
                for _, b in pairs(character.BoneMergedEnts or {}) do 
                    if IsValid(b) then
                        local bMdl = b:GetModel()
                        if bMdl and bMdl:find("/nightvision/") then b:Remove() end 
                    end
                end
                
                local target = hvr and cfg.model or currentnvg
                if target and target ~= "none" then 
                    ClientBoneMerge(character, target) 
                end
                SafeRemoveErrors(character)
            end)
    end)

    MainMogFrame.Buttons.gasmask = CreateMogButton(MainMogFrame, {x = ScrW()/1.535, y = ScrH()/1.15}, GetConfigIcon(C_2_4), function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.gasmasks, {title = "Противогазы", id = "gaz", x = ScrW()/1.9, y = ScrH()/2.4, h = ScrH()/4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_2_4.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_2_4.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_2_4.price - sel.price
                    C_2_4, currentgaz = sel, sel.name ~= "none" and sel.name ~= nil
                    character:SetBodygroup(6, currentgaz and 1 or 0)
                    btn.currentIcon = (sel.name and sel.name ~= "none") and Material("nextoren/gui/new_icons/gasmask.png") or Material("nextoren/gui/icons/gaz_empty.png")
                    return true
                end return false
            end,
            function(cfg, hvr) character:SetBodygroup(6, (hvr and cfg.name and cfg.name ~= "none") and 1 or (currentgaz and 1 or 0)) end)
    end)

    MainMogFrame.Buttons.medkit = CreateMogButton(MainMogFrame, {x = ScrW()/1.442, y = ScrH()/1.15}, GetConfigIcon(C_2_5), function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.medkits, {title = "Мед. оборудование", id = "med", x = ScrW()/1.9, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_2_5.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_2_5.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_2_5.price - sel.price
                    C_2_5, character.currentWep = sel, currentWep
                    character:ResetSequence(character:LookupSequence("p_ar2_relaxedloop"))
                    btn.currentIcon = GetConfigIcon(sel)
                    return true
                end return false
            end,
            function(cfg, hvr) character.currentWep = (hvr and cfg.name and cfg.name ~= "none") and cfg.name or currentWep end)
    end)

    MainMogFrame.Buttons.consumable = CreateMogButton(MainMogFrame, {x = ScrW()/1.359, y = ScrH()/1.15}, GetConfigIcon(C_2_6), function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.consumables, {title = "Расходники", id = "boosters", x = ScrW()/1.9, y = ScrH()/2.4, h = ScrH()/2.3, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_2_6.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_2_6.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_2_6.price - sel.price
                    C_2_6 = sel
                    btn.currentIcon = GetConfigIcon(sel)
                    return true
                end return false
            end)
    end)

    MainMogFrame.Buttons.hpAbility = CreateMogButton(MainMogFrame, {x = ScrW()/64, y = ScrH()/1.15}, C_3_1.icon or "nextoren/mog/abb/h_empty.png", function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.health_abilities, {title = "Способности (HP)", id = "hp_abil", x = ScrW()/64, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_3_1.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_3_1.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_3_1.price - sel.price
                    C_3_1 = sel
                    btn.currentIcon = sel.icon
                    return true
                end return false
            end)
    end)

    MainMogFrame.Buttons.speedAbility = CreateMogButton(MainMogFrame, {x = ScrW()/17, y = ScrH()/1.15}, C_3_2.icon or "nextoren/mog/abb/s_empty.png", function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.speed_abilities, {title = "Способности (Бег)", id = "speed_abil", x = ScrW()/64, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_3_2.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_3_2.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_3_2.price - sel.price
                    C_3_2 = sel
                    btn.currentIcon = sel.icon
                    return true
                end return false
            end)
    end)

    MainMogFrame.Buttons.special = CreateMogButton(MainMogFrame, {x = ScrW()/10, y = ScrH()/1.15}, C_3_3.icon or "nextoren/mog/abb/nothing.png", function(btn)
        OpenConfigPanel(MainMogFrame, MogConfigurations.special_equipment, {title = "Особенное", id = "special", x = ScrW()/64, y = ScrH()/2.4, canAffordCheck = function(price) return (MainMogFrame.Wallet + C_3_3.price) >= price end},
            function(sel)
                if (MainMogFrame.Wallet + C_3_3.price) >= sel.price then
                    MainMogFrame.Wallet = MainMogFrame.Wallet + C_3_3.price - sel.price
                    C_3_3 = sel
                    btn.currentIcon = sel.icon
                    return true
                end return false
            end)
    end)

    MainMogFrame.finalbutton = vgui.Create("DButton", MainMogFrame)
    MainMogFrame.finalbutton:SetText("")
    MainMogFrame.finalbutton:SetSize(ScrW() / 4, ScrH() / 12)
    MainMogFrame.finalbutton:SetPos(ScrW() / 1.01, ScrH() / 1.12)
    MainMogFrame.finalbutton.Paint = function() end
    MainMogFrame.finalbutton.DoClick = function(self)
        if timer.Exists("NewTG_SpanwTimer") or self.used then return end
        self.used = true 
        timer.Simple(0.1, function()
            net.Start("Breach:SENDMOGPRESET")
            net.WriteString(C_1_1.model or "none") 
            net.WriteString(C_1_2.model or "none") 
            net.WriteTable(C_1_3.bodygroups or {}) 
            net.WriteInt(C_1_4.skin or 0, 8)
            net.WriteString(C_2_1.name or "none") 
            net.WriteString(C_2_2.name or "none") 
            net.WriteString(C_2_3.name or "none")
            net.WriteString(C_2_4.name or "none") 
            net.WriteString(C_2_5.name or "none") 
            net.WriteString(C_2_6.name or "none")
            net.WriteString(C_3_1.name or "none") 
            net.WriteString(C_3_2.name or "none") 
            net.WriteString(C_3_3.name or "none")
            net.WriteString(character.HeadMat or "")
            net.SendToServer()
            
            RunConsoleCommand("mog_loading")
            timer.Simple(3, function() gui.EnableScreenClicker(false) end)
            if IsValid(MainMogFrame) then
                MainMogFrame:AlphaTo(0, 0.5, 0, function() if IsValid(MainMogFrame) then MainMogFrame:Remove() end end)
            end
        end)
    end

    local function ApplyPreset(data)
        if not data then return false end
        local nHelmet = FindInConfig(MogConfigurations.helmets, "model", data.helmet)
        local nFace = FindInConfig(MogConfigurations.faces, "model", data.face)
        local nArmor = FindInConfig(MogConfigurations.armor, "name", data.armor)
        local nSkin = FindInConfig(MogConfigurations.skins, "skin", data.skin)
        local nPrim = FindInConfig(MogConfigurations.primary_weapons, "name", data.primary)
        local nSec = FindInConfig(MogConfigurations.secondary_weapons, "name", data.secondary)
        local nNVG = FindInConfig(MogConfigurations.nvgs, "name", data.nvg)
        local nGas = FindInConfig(MogConfigurations.gasmasks, "name", data.gasmask)
        local nMed = FindInConfig(MogConfigurations.medkits, "name", data.medkit)
        local nCons = FindInConfig(MogConfigurations.consumables, "name", data.consumable)
        local nHP = FindInConfig(MogConfigurations.health_abilities, "name", data.hpAbility)
        local nSpeed = FindInConfig(MogConfigurations.speed_abilities, "name", data.speedAbility)
        local nSpec = FindInConfig(MogConfigurations.special_equipment, "name", data.special)

        local sumCur = (C_1_1.price or 0) + (C_1_2.price or 0) + (C_1_3.price or 0) + (C_1_4.price or 0) + (C_2_1.price or 0) + (C_2_2.price or 0) + (C_2_3.price or 0) + (C_2_4.price or 0) + (C_2_5.price or 0) + (C_2_6.price or 0) + (C_3_1.price or 0) + (C_3_2.price or 0) + (C_3_3.price or 0)
        local sumPres = (nHelmet.price or 0) + (nFace.price or 0) + (nArmor.price or 0) + (nSkin.price or 0) + (nPrim.price or 0) + (nSec.price or 0) + (nNVG.price or 0) + (nGas.price or 0) + (nMed.price or 0) + (nCons.price or 0) + (nHP.price or 0) + (nSpeed.price or 0) + (nSpec.price or 0)

        if MainMogFrame.Wallet + sumCur < sumPres then return false end
        MainMogFrame.Wallet = MainMogFrame.Wallet + sumCur - sumPres

        for _, b in pairs(character.BoneMergedEnts or {}) do 
            if IsValid(b) then
                local bMdl = b:GetModel()
                if bMdl == C_1_1.model or bMdl:find("/balaclavas_new/") or bMdl == "models/cultist/heads/male/male_head_15.mdl" or bMdl:find("/nightvision/") or bMdl == "models/error.mdl" then b:Remove() end 
            end
        end

        C_1_1, C_1_2, C_1_3, C_1_4, C_2_1, C_2_2, C_2_3, C_2_4, C_2_5, C_2_6, C_3_1, C_3_2, C_3_3 = nHelmet, nFace, nArmor, nSkin, nPrim, nSec, nNVG, nGas, nMed, nCons, nHP, nSpeed, nSpec
        
        if nHelmet.model and nHelmet.model ~= "none" then ClientBoneMerge(character, nHelmet.model) end
        if nFace.model and nFace.model ~= "none" then local h = ClientBoneMerge(character, nFace.model) if IsValid(h) then h:SetSubMaterial(0, nFace.model ~= "models/cultist/humans/balaclavas_new/mog_hazmat.mdl" and (data.headMat or character.HeadMat) or 0) end end
        if nArmor.bodygroups then for bg, val in pairs(nArmor.bodygroups) do character:SetBodygroup(bg, val) currentBodygroups[bg] = val end end
        character:SetSkin(nSkin.skin) currentskin = nSkin.skin
        currentWep = nPrim.name or "cw_kk_ins2_cq300" character.currentWep = currentWep
        if nNVG.model and nNVG.model ~= "none" then ClientBoneMerge(character, nNVG.model) currentnvg = nNVG.model else currentnvg = nil end
        currentgaz = nGas.name ~= nil and nGas.name ~= "none" character:SetBodygroup(6, currentgaz and 1 or 0)

        MainMogFrame.Buttons.helmet.currentIcon = nHelmet.icon or "nextoren/mog/hel/nill.png"
        MainMogFrame.Buttons.face.currentIcon = nFace.icon or "nextoren/mog/head/nill.png"
        MainMogFrame.Buttons.armor.currentIcon = nArmor.icon or "nextoren/mog/armor/nill.png"
        MainMogFrame.Buttons.skin.currentIcon = nSkin.icon or "nextoren/mog/form/standart.png"
        MainMogFrame.Buttons.primary.currentIcon = GetConfigIcon(nPrim)
        MainMogFrame.Buttons.secondary.currentIcon = GetConfigIcon(nSec)
        MainMogFrame.Buttons.nvg.currentIcon = GetConfigIcon(nNVG)
        MainMogFrame.Buttons.gasmask.currentIcon = (nGas.name and nGas.name ~= "none") and Material("nextoren/gui/new_icons/gasmask.png") or Material("nextoren/gui/icons/gaz_empty.png")
        MainMogFrame.Buttons.medkit.currentIcon = GetConfigIcon(nMed)
        MainMogFrame.Buttons.consumable.currentIcon = GetConfigIcon(nCons)
        MainMogFrame.Buttons.hpAbility.currentIcon = nHP.icon or "nextoren/mog/abb/h_empty.png"
        MainMogFrame.Buttons.speedAbility.currentIcon = nSpeed.icon or "nextoren/mog/abb/s_empty.png"
        MainMogFrame.Buttons.special.currentIcon = nSpec.icon or "nextoren/mog/abb/nothing.png"
        
        if data.headMat then character.HeadMat = data.headMat end
        character:ResetSequence(character:LookupSequence("p_ar2_relaxedloop"))

        return true
    end

    MainMogFrame.btnSavePreset = CreateAnimatedButton(MainMogFrame, "СОХРАНИТЬ ПРЕСЕТ", "nextoren/gui/save.png", ScrW()/1.185, ScrH()/1.10, ScrW()/8, ScrH()/32, function(self)
        if IsValid(MainMogFrame.Saveframe) then MainMogFrame.Saveframe:Remove() end
        
        local f = vgui.Create("DFrame", MainMogFrame)
        f:SetSize(300, 150) 
        f:Center() 
        f:SetTitle("") 
        f:MakePopup() 
        f:ShowCloseButton(false)
        
        f:SetAlpha(0)
        f:AlphaTo(255, 0.15)

        f.Paint = function(s, w, h) 
            surface.SetDrawColor(rust_bg)
            surface.DrawRect(0, 30, w, h - 30)
            
            surface.SetDrawColor(rust_panel)
            surface.DrawRect(0, 0, w, 30)
            
            surface.SetDrawColor(rust_yellow)
            surface.DrawRect(0, 30, w, 2)
            
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            draw.SimpleText("СОХРАНЕНИЕ ПРЕСЕТА", "MogM_6", 15, 15, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("ИМЯ ПРЕСЕТА (АНГЛ, БЕЗ ПРОБЕЛОВ)", "MogM_4", w/2, h - 15, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        local entry = vgui.Create("DTextEntry", f) 
        entry:SetPos(15, 50) 
        entry:SetSize(270, 30) 
        entry:SetFont("MogM_6")
        entry:SetTextColor(rust_text)
        entry:SetCursorColor(rust_yellow)
        entry:SetPaintBackground(false)
        
        entry.Paint = function(s, w, h)
            surface.SetDrawColor(10, 9, 8, 200)
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(s:HasFocus() and rust_yellow or rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            s:DrawTextEntryText(s:GetTextColor(), Color(218, 165, 32, 100), s:GetCursorColor())
            
            if s:GetText() == "" and not s:HasFocus() then
                draw.SimpleText("ВВЕДИТЕ ИМЯ...", "MogM_6", 5, h/2 - 1, rust_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end

        CreateAnimatedButton(f, "СОХРАНИТЬ", nil, 15, 90, 130, 30, function()
            if entry:GetValue() ~= "" then
                file.Write("mog_presets_v2/" .. entry:GetValue() .. ".txt", util.TableToJSON({helmet = C_1_1.model, face = C_1_2.model, armor = C_1_3.name, skin = C_1_4.skin, primary = C_2_1.name, secondary = C_2_2.name, nvg = C_2_3.name, gasmask = C_2_4.name, medkit = C_2_5.name, consumable = C_2_6.name, hpAbility = C_3_1.name, speedAbility = C_3_2.name, special = C_3_3.name, headMat = character.HeadMat}))
            end
            f:AlphaTo(0, 0.15, 0, function() if IsValid(f) then f:Close() end end)
        end)
        
        CreateAnimatedButton(f, "ОТМЕНА", nil, 155, 90, 130, 30, function() 
            f:AlphaTo(0, 0.15, 0, function() if IsValid(f) then f:Close() end end) 
        end)
    end)

    MainMogFrame.btnLoadPreset = CreateAnimatedButton(MainMogFrame, "ЗАГРУЗИТЬ ПРЕСЕТ", "nextoren/gui/load.png", ScrW()/1.185, ScrH()/1.15, ScrW()/8, ScrH()/32, function(self)
        local files = file.Find("mog_presets_v2/*.txt", "DATA")
        if #files == 0 then return end
        
        local f = vgui.Create("DFrame", MainMogFrame)
        f:SetSize(500, 300) 
        f:Center() 
        f:SetTitle("") 
        f:MakePopup()
        f:ShowCloseButton(false)

        f:SetAlpha(0)
        f:AlphaTo(255, 0.15)

        f.Paint = function(s, w, h) 
            surface.SetDrawColor(rust_bg)
            surface.DrawRect(0, 30, w, h - 30)
            
            surface.SetDrawColor(rust_panel)
            surface.DrawRect(0, 0, w, 30)
            
            surface.SetDrawColor(rust_yellow)
            surface.DrawRect(0, 30, w, 2)
            
            surface.SetDrawColor(rust_outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            draw.SimpleText("МЕНЕДЖЕР ПРЕСЕТОВ", "MogM_6", 15, 15, rust_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("ЛКМ - ЗАГРУЗИТЬ | ПКМ - УДАЛИТЬ", "MogM_4", w - 35, 15, rust_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        
        local btnClose = vgui.Create("DButton", f)
        btnClose:SetSize(30, 30)
        btnClose:SetPos(f:GetWide() - 30, 0)
        btnClose:SetText("X")
        btnClose:SetFont("MogM_6")
        btnClose:SetTextColor(rust_dim)
        btnClose.Paint = function(s, w, h)
            if s:IsHovered() then
                surface.SetDrawColor(rust_red)
                surface.DrawRect(0, 0, w, h)
                s:SetTextColor(Color(255,255,255))
            else
                s:SetTextColor(rust_dim)
            end
        end
        btnClose.DoClick = function()
            local p = f
            f = nil
            p:AlphaTo(0, 0.15, 0, function() if IsValid(p) then p:Close() end end)
        end

        local sPanel = vgui.Create("DScrollPanel", f) 
        sPanel:Dock(FILL) 
        sPanel:DockMargin(5, 35, 5, 5)

        local bar = sPanel:GetVBar()
        function bar:Paint(w, h) surface.SetDrawColor(10, 10, 10, 150) surface.DrawRect(0,0,w,h) end
        function bar.btnUp:Paint() end
        function bar.btnDown:Paint() end
        function bar.btnGrip:Paint(w, h) surface.SetDrawColor(80, 80, 80, 255) surface.DrawRect(0,0,w,h) end

        for _, fname in ipairs(files) do
            CreateAnimatedButton(sPanel, string.upper(string.StripExtension(fname)), nil, nil, nil, 400, 36, function(btn)
                ApplyPreset(util.JSONToTable(file.Read("mog_presets_v2/" .. fname, "DATA"))) 
                
                local p = f
                f = nil
                p:AlphaTo(0, 0.15, 0, function() if IsValid(p) then p:Close() end end)
            end, function(btn)
                file.Delete("mog_presets_v2/" .. fname, "DATA") 
                btn:Remove()
            end)
        end
    end)
end