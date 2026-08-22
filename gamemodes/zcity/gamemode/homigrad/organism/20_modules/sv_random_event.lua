--local Organism = hg.organism
hg.organism.module.random_events = {}
local module = hg.organism.module.random_events
module[1] = function(org)
	org.timeToRandom = CurTime() + math.random(120,320)
end

local RandomEvents = {
    ["Sneeze"] = function( owner, org )
        owner:EmitSound(ThatPlyIsFemale(owner) and "zcitysnd/female/sneez_"..math.random(1,4)..".mp3" or "zcitysnd/male/sneez_"..math.random(1,4)..".mp3", nil, 100 + (owner.PlayerClassName == "furry" and 20 or 0))
        timer.Simple(.5,function()
            owner:ViewPunch(Angle(-2,0,0))
            timer.Simple(.3,function()
                owner:ViewPunch(Angle(5,0,0))
            end)
        end)
    end,
    //["Hungry"] = function( owner, org )
        //owner:EmitSound("zcitysnd/uni/hungry_"..math.random(1,6)..".mp3", nil, 100 + (owner.PlayerClassName == "furry" and 20 or 0))
    //end,
    ["Cough"] = function( owner, org )
        owner:EmitSound(ThatPlyIsFemale(owner) and "zcitysnd/female/cough_"..math.random(1,6)..".mp3" or "zcitysnd/male/cough_"..math.random(1,6)..".mp3",75,100 + (owner.PlayerClassName == "furry" and 20 or 0),1)
        timer.Simple(.3,function()
            owner:ViewPunch(Angle(3,0,0))
            timer.Simple(.3,function()
                owner:ViewPunch(Angle(2,0,0))
            end)
        end) -- жаль что сломалось, а ради этого неты делать ну, такое... | update уже неважно
    end,
} 

function module.TriggerRandomEvent(owner, eventName)
    if owner.GTeam and owner:GTeam() == TEAM_AR then return end
    if owner.GTeam and owner:GTeam() == TEAM_SCP then return end
    if RandomEvents[eventName] then
        if owner:IsRagdoll() then return end
        RandomEvents[eventName](owner, owner.organism)
    end
end

module[2] = function(owner, org, timeValue)
    local curTime = org.curTime or CurTime()
    if org.timeToRandom < curTime and owner:IsPlayer() and owner:Alive() and owner.PlayerClassName ~= "Combine" then -- Манютка переделывай говно. сделай в классе переменную об этом. либо дай овнеру просто переменную насчет этого.
        if owner.GTeam and (owner:GTeam() == TEAM_AR or owner:GTeam() == TEAM_SCP) then
            org.timeToRandom = curTime + math.random(120,320)
            return
        end

        -- Обычные люди чихают, если они в сознании
        if not org.otrub then
            if math.random(2) == 1 then
                RandomEvents.Sneeze(owner, org)
            else
                RandomEvents.Cough(owner, org)
            end
        end 
        org.timeToRandom = CurTime() + math.random(120,320)
    end
end

hook.Remove("Org Think", "VirusRandomEvents")


util.AddNetworkString("hg_second_wind_start")
util.AddNetworkString("hg_second_wind_end")

hook.Add("PostPlayerDeath", "HG_SecondWind_Trigger", function(ply)
    -- Проверка на то, что шанс еще не использован в этой жизни
    if ply.hasUsedSecondWind then return end

    local org = ply.organism
    if org and (org.skull == 1 or org.headexploded) then return end -- С оторванной головой не встают

    -- Бросаем кубик на 2%
    if math.random(0,100) < 2 then
        
        -- Находим LootBox (он уже был создан функцией CreateLootBox в GM:DoPlayerDeath)
        local rag = ply:GetNWEntity("RagdollEntityNO")
        if not IsValid(rag) then return end

        ply.hasUsedSecondWind = true
        --ply.SecondWindCorpse = rag
        
        -- САМОЕ ВАЖНОЕ: Удаляем таймер превращения в зрителя из вашей функции Death_Scene!
        timer.Remove("Death_Scene"..ply:SteamID())
        
        -- Отправляем сигнал клиенту начать катсцену
        net.Start("hg_second_wind_start")
        net.Send(ply)
    end
end)

-- Когда катсцена кончилась и игрок готов вставать
net.Receive("hg_second_wind_end", function(len, ply)
    --if not IsValid(ply) or not ply.SecondWindCorpse then return end
    
    local body = ply.lastrag
    --if not IsValid(body) then
    --    -- Если труп кто-то сжег или уничтожил пока мы смотрели сцену, игрок окончательно умирает
    --    ply:SetSpectator()
    --    return
    --end

    local body = ply.lastrag
	local ply = body:GetOwner()
	timer.Remove( "PlayerDeathFromBleeding" .. ply:SteamID64() )

	ply:SetupNormal()
	ply:SetModel(body:GetModel())
	ply:SetSkin(body:GetSkin())
	ply:SetGTeam(body.__Team)
	ply:SetRoleName(body.Role)
	ply:SetMaxHealth(body.__Health) 
	ply:SetHealth(ply:GetMaxHealth())
	ply:SetUsingCloth(body.Cloth)
	ply:SetNamesurvivor(body.__Name)
	ply.OldSkin = body.OldSkin
	ply.OldModel = body.OldModel
	ply.OldBodygroups = body.OldBodygroups
	ply:SetWalkSpeed(body.WalkSpeed)
	ply:SetRunSpeed(body.RunSpeed)
	ply:SetupHands()
	--ply:SetNWAngle("ViewAngles", ply:GetAngles())
	timer.Remove("Death_Scene"..ply:SteamID())
	ply:SetPos( Vector(body:GetPos().x, body:GetPos().y, GroundPos(body:GetPos()).z) )
	if istable(body.AmmoData) then
		for ammo, amount in pairs(body.AmmoData) do
			ply:SetAmmo(amount, ammo)
		end
	end

	if body.AbilityTable != nil then
		ply:SetNWString("AbilityName", body.AbilityTable[1])
		net.Start("SpecialSCIHUD")
	        net.WriteString(body.AbilityTable[1])
		    net.WriteUInt(body.AbilityTable[2], 9)
		    net.WriteString(body.AbilityTable[3])
		    net.WriteString(body.AbilityTable[4])
		    net.WriteBool(body.AbilityTable[5])
	    net.Send(ply)

	    ply:SetSpecialCD(body.AbilityCD)
	    ply:SetSpecialMax(body.AbilityMax)

	end
	--ply:BreachGive("br_holster")


	--if body.vtable and body.vtable.Weapons then
	for _, v in pairs(body.vtable.Weapons) do
		if weapons.GetStored(v) then
			ply:BreachGive(v)
		end
	end
	--else
		ply:BreachGive("br_holster")
	--end

	for _, bnmrg in pairs(body:LookupBonemerges()) do
		local bnmrg_ent = Bonemerge(bnmrg:GetModel(), ply)
		bnmrg_ent:SetSubMaterial(0, bnmrg:GetSubMaterial(0))
		bnmrg_ent:SetSubMaterial(2, bnmrg:GetSubMaterial(2))
	end

	for i = 0, 9 do
		ply:SetBodygroup(i, body:GetBodygroup(i))
	end

    -- Восстанавливаем инвентарь ZCity (копируем обратно из трупа)
    if body.vtable and body.vtable.Items then
        ply.Inventory = ply.Inventory or {["Items"] = {}}
        ply.Inventory["Items"] = table.Copy(body.vtable.Items)
        
        -- Синхронизируем инвентарь с клиентом
        net.Start("SendInventoryDataOper")
        net.WriteTable(ply.Inventory)
        net.Send(ply)
        ply:MarkInventoryChanged()
    end

    -- Выдаем базовую кобуру, чтобы не было Т-позы
    ply:Give("br_holster")
    ply:SelectWeapon("br_holster")
    ply:SetNWInt("ActiveSlot", 0)

    -- Удаляем труп
    body:Remove()

    -- ==================================
    -- ИСЦЕЛЕНИЕ ОРГАНИЗМА ZCITY
    -- ==================================
    local org = ply.organism
    if org then
        org.blood = 3000 -- Восстанавливаем 4 литра крови
        org.wounds = {}
        org.arterialwounds = {}
        ply:SetNetVar("wounds", {})
        ply:SetNetVar("arterialwounds", {})
        org.bleed = 0
        org.internalBleed = 0
        org.pain = 20
        org.painadd = 0
        org.shock = 10
        org.adrenaline = 3
        org.pulse = 130
        org.heartbeat = 130
        org.o2[1] = 5 
        org.otrub = false
        org.consciousness = 1
        org.alive = true
        
        ply.fullsend = true
        if hg and hg.send_organism then
            hg.send_organism(org, ply)
        end
    end

    -- Делаем игрока снова видимым
    ply:SetNoDraw(false)
    ply:DrawShadow(true)
    
    -- Очищаем ссылку на труп
    ply.SecondWindCorpse = nil

    -- Резкий вдох
    ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/inhale/female/inhale_0"..math.random(5)..".wav" or "breathing/inhale/male/inhale_0"..math.random(4)..".wav", 85)
end)

-- Защита: Сброс флага "Второго дыхания" при нормальном спавне
hook.Add("PlayerSpawn", "HG_ResetSecondWind", function(ply)
    ply.hasUsedSecondWind = false
    ply.SecondWindCorpse = nil
end)

-- Координаты Токсичной зоны
local zoneMin = Vector(-3655.074951, 7707.482422, -1511.903564)
local zoneMax = Vector(3680.588135, 12476.416992, 1556.305664)
OrderVectors(zoneMin, zoneMax) 

hook.Add("Org Think", "Toxic_Zone_Effect", function(owner, org, timeValue)
    -- Базовые проверки: жив ли игрок
    --if true then return end
    if not IsValid(owner) or not owner:Alive() then return end
    
    -- Проверка: находится ли игрок в заданном квадрате
    if not owner:GetPos():WithinAABox(zoneMin, zoneMax) then return end

    -- ==========================================
    -- 1. КИСЛОРОД И ДЫХАНИЕ (Не убивает сразу)
    -- ==========================================
    -- Опускаем кислород, но не ниже 8, чтобы игрок не умер от удушья за 20 секунд.
    -- Он будет постоянно видеть надписи "Я задыхаюсь", но будет жить.
    --if org.o2 and org.o2[1] > 8 then
    --    org.o2[1] = math.max(org.o2[1] - timeValue * 2, 8)
    --end
    -- Высасываем выносливость, чтобы он тяжело дышал и медленнее бегал
    --if org.stamina and org.stamina[1] then
    --    org.stamina[1] = math.Approach(org.stamina[1], 10, timeValue * 15)
    --end
    org.pulse = math.max(org.pulse, 130)
    org.heartbeat = math.max(org.heartbeat, 130)


    -- ==========================================
    -- 2. БОЛЬ (Убьет ровно за 5 минут)
    -- ==========================================
    -- Ставим базовую боль на 30. До смерти (90) остается 60 единиц.
    -- Чтобы набрать 60 боли за 300 секунд, нам нужно прибавлять 0.2 в секунду.
    if org.pain < 30 then
        org.pain = 30
        org.avgpain = math.max(org.avgpain, 30)
    end
    org.painadd = org.painadd + (timeValue * 0.2)


    -- ==========================================
    -- 3. ОТРАВЛЕНИЕ МОЗГА (Второй таймер смерти)
    -- ==========================================
    -- Смерть мозга наступает при 0.7. За 300 секунд мы накопим 0.66.
    -- Это гарантия того, что даже если игрок вколет обезболивающее, токсин убьет его.
    --org.brain = math.min(org.brain + (timeValue * 0.0022), 1)


    -- ==========================================
    -- 4. ДЕЗОРИЕНТАЦИЯ И ШАТАНИЕ
    -- ==========================================
    -- Значение 3.5 заставит экран плыть, размываться и качаться.
    org.disorientation = math.max(org.disorientation, 3.5)


    -- ==========================================
    -- 5. РВОТА (Потеря крови)
    -- ==========================================
    -- Системная рвота отнимает 200 крови. Игрок будет блевать 1 раз в 25 секунд.
    -- За 5 минут он вырвет 12 раз, потеряв 2400 крови (упадет в кому перед смертью).
    org.wantToVomit = (org.wantToVomit or 0) + (timeValue * 0.04)
    if org.wantToVomit > 1 then
        org.wantToVomit = 0
        if hg.organism.Vomit then
            hg.organism.Vomit(owner)
        end
    end


    -- ==========================================
    -- 6. АТМОСФЕРНЫЙ КАШЕЛЬ
    -- ==========================================
    owner.nextToxicCough = owner.nextToxicCough or 0
    if CurTime() > owner.nextToxicCough then
        -- Кашляем раз в 6-12 секунд (чтобы не спамить звук)
        owner.nextToxicCough = CurTime() + math.Rand(6, 12)
        
        local isFemale = (ThatPlyIsFemale and ThatPlyIsFemale(owner)) or false
        local snd = "zcitysnd/real_sonar/" .. (isFemale and "female" or "male") .. "_cough" .. math.random(1, 4) .. ".mp3"
        
        owner:EmitSound(snd, 75, math.random(95, 105))
        owner:ViewPunch(Angle(math.random(3, 5), math.random(-2, 2), 0))
        
        -- Шанс 12% кашлянуть кровью (дополнительный урон)
        if math.random(1, 8) == 1 and hg.organism.CoughBlood then
            hg.organism.CoughBlood(org)
        end
    end
end)

-- ==========================================================
-- ИЗМЕРЕНИЕ SCP-106 (КАРМАННОЕ ИЗМЕРЕНИЕ)
-- ==========================================================

-- Список жутких звуков при телепортации
local horror_tbl = {
    "nextoren/others/horror/horror_0.ogg",
    "nextoren/others/horror/horror_1.ogg",
    "nextoren/others/horror/horror_2.ogg",
    "nextoren/others/horror/horror_3.ogg",
    "nextoren/others/horror/horror_4.ogg",
    "nextoren/others/horror/horror_5.ogg",
    "nextoren/others/horror/horror_9.ogg",
    "nextoren/others/horror/horror_10.ogg",
    "nextoren/others/horror/horror_16.ogg"
}

-- Координаты точек, в которые игрок заходит (ловушки/коридоры)
local trap_portals = {
    Vector(-2489.414062, 8687.505859, -417.854828),
    Vector(-2521.773193, 9048.884766, -416.144257),
    Vector(-2412.266113, 9337.497070, -417.849182),
    Vector(-2126.564697, 9441.593750, -418.669800),
    Vector(-1802.628174, 9374.368164, -425.038025),
    Vector(-1677.616455, 9068.583984, -410.227325),
    Vector(-1751.979370, 8700.089844, -420.275208),
    Vector(-2113.113037, 8550.301758, -416.426575)
}

local trap_destinations_frequent = {
    --{ pos = Vector(-1106.438110, 11082.672852, -214.404449), ang = Angle(0, 145.207336, 0) },
    { pos = Vector(1704.915527, 9169.990234, -321.689270),  ang = Angle(0, 38.099323, 0) }
}

-- Куда будет кидать РЕЖЕ (остальные точки)
local trap_destinations_rare = {
    { pos = Vector(6298.472168, 1586.689209, -24.349554),   ang = Angle(0, 172.087234, 0) },
    { pos = Vector(8652.201172, 1223.071533, 164.204681),   ang = Angle(0, 52.327286, 0) },
    { pos = Vector(8053.208496, 2913.435791, 179.258438),   ang = Angle(0, 175.627243, 0) },
    { pos = Vector(9211.885742, -4177.353027, 64.442612),   ang = Angle(0, 91.207130, 0) },
    { pos = Vector(6835.989746, -4174.145020, 288.558411),  ang = Angle(0, 167.947220, 0) },
    { pos = Vector(-1088.024292, 1563.222656, -43),         ang = Angle(0, math.random(0, 360), 0) },
    { pos = Vector(-3861.837402, 3496.722656, 169.325043),  ang = Angle(0, 45.907295, 0) }
}

-- Специальная точка спасения
local escape_portal = Vector(974.065918, 9928.050781, -513.566040)

-- Куда кинет, если игрок угадал выход (Хорошие места)
local escape_destinations = {
    { pos = Vector(1662.988281, 2067.645020, 154.957947), ang = Angle(0, -3.261136, 0) },
    { pos = Vector(3870.448730, 1172.542480, 182.724182), ang = Angle(0, 74.138817, 0) },
    { pos = Vector(8655.028320, 1228.142212, 136.305725), ang = Angle(0, 71.378830, 0) }
}


-- Функция самой телепортации с эффектами
local function PerformDimensionTeleport(ply, destTable)
    -- Блокируем игрока, чтобы он не провалился под карту и не вызвал ТП дважды
    ply.IsTeleporting106 = true
    ply:Freeze(true)

    -- 1. Звук и затемнение экрана (уходит в черный за 1.5 секунды)
    ply:EmitSound(table.Random(horror_tbl), 100, math.random(90, 110))
    ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 0.1, 0)

    -- 2. Через полторы секунды переносим физически и осветляем экран
    timer.Simple(1.5, function()
        if not IsValid(ply) or not ply:Alive() then return end
        
        -- Телепорт
        ply:SetPos(destTable.pos)
        ply:SetEyeAngles(destTable.ang)

        -- Выход из темноты (рассветление за 2 секунды)
        ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 2.0, 3)

        -- Размораживаем
        ply:Freeze(false)

        -- Снимаем флаг кулдауна
        timer.Simple(1, function()
            if IsValid(ply) then ply.IsTeleporting106 = false end
        end)
    end)
end

-- ========================================================
-- Хук проверки нахождения в координатах
-- ========================================================
local nextCheck = 0
local radiusSqr = 80 * 80 -- Радиус "цилиндра" по горизонтали (80 юнитов)
local zTolerance = 150    -- Допуск по высоте (150 юнитов)

hook.Add("Think", "SCP106_Dimension_Checker", function()
    if CurTime() < nextCheck then return end
    nextCheck = CurTime() + 0.2

    for _, ply in player.Iterator() do
        if not ply:Alive() or ply:InVehicle() or ply.IsTeleporting106 then continue end
        if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then continue  end
        if IsValid(ply.FakeRagdoll) then continue end

        local pPos = ply:GetPos()

        -- 1. Проверяем точку ВЫХОДА (цилиндрическая проверка)
        local dist2D_escape = math.pow(pPos.x - escape_portal.x, 2) + math.pow(pPos.y - escape_portal.y, 2)
        local distZ_escape = math.abs(pPos.z - escape_portal.z)

        if dist2D_escape < radiusSqr and distZ_escape < zTolerance then
            PerformDimensionTeleport(ply, table.Random(escape_destinations))
            continue 
        end

        -- 2. Проверяем ЛОВУШКИ (цилиндрическая проверка)
        for _, trapPos in ipairs(trap_portals) do
            local dist2D_trap = math.pow(pPos.x - trapPos.x, 2) + math.pow(pPos.y - trapPos.y, 2)
            local distZ_trap = math.abs(pPos.z - trapPos.z)

            if dist2D_trap < radiusSqr and distZ_trap < zTolerance then
                
                -- Выбор точки с нужным шансом
                local targetDest
                
                -- 70% шанс, что закинет в частые точки. 30% шанс на остальные.
                -- Можете менять число 70 на любое другое!
                if math.random(1, 100) <= 70 then 
                    targetDest = table.Random(trap_destinations_frequent)
                else
                    targetDest = table.Random(trap_destinations_rare)
                end

                PerformDimensionTeleport(ply, targetDest)
                break 
            end
        end
    end
end)


if CLIENT then return end

-- Указываем координаты зоны
local zoneMin = Vector(-984.122070, -3499.068115, -1405)
local zoneMax = Vector(2166.351318, -6167.319824, -782)
-- Обязательно сортируем вектора от меньшего к большему, иначе WithinAABox не сработает
OrderVectors(zoneMin, zoneMax)

hook.Add("Org Think", "Custom_Toxic_Zone_Logic", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end

    -- Проверка: Находится ли игрок в зоне
    if not owner:GetPos():WithinAABox(zoneMin, zoneMax) then return end

    -- Твои проверки (заменил continue на return, так как функция обрабатывает 1 игрока за раз)
    if owner:GTeam() == TEAM_SPEC then return end
    if owner:Health() <= 0 then return end
    if not owner:Alive() then return end
    
    local roleName = owner:GetRoleName()
    if roleName == "CI Soldier" then return end
    if roleName == "CI Juggernaut" then return end
    if roleName == "NTF Grunt" then return end
    if owner:GTeam() == TEAM_DZ and roleName ~= "SH Spy" then return end
    
    if owner.IsLZ and not owner:IsLZ() then return end -- проверка на метод (чтобы не выдало ошибку, если его нет)
    
    -- Защита от ошибки, если таблица role локальная или не прогрузилась
    local bannedRole = (role and role.ClassD_Banned) or "ClassD_Banned"

    if owner.HasHazmat and owner:HasHazmat() and roleName ~= bannedRole then return end 
    if owner.GASMASK_Equiped and roleName ~= bannedRole then return end

    -- ========================================================
    -- Если игрок прошел все проверки (он внутри и без защиты):
    -- ========================================================

    -- 1. Роняем кислород до 5 и не даем подняться выше
    if org.o2 and org.o2[1] then
        org.o2[1] = math.min(org.o2[1], 20)
    end

     if org.stamina and org.stamina[1] then
        org.stamina[1] = math.min(org.stamina[1], 20)
    end

    -- 2. Заставляем кашлять (с задержкой, чтобы не спамить звук каждый тик)
    owner.nextToxicZoneCough = owner.nextToxicZoneCough or 0
    if CurTime() > owner.nextToxicZoneCough then
        owner.nextToxicZoneCough = CurTime() + math.Rand(3, 6)
        
        -- Вызываем встроенный ивент обычного кашля Z-City
        if hg.organism.module.random_events and hg.organism.module.random_events.TriggerRandomEvent then
            hg.organism.module.random_events.TriggerRandomEvent(owner, "Cough")
        else
            -- Если ивента по какой-то причине нет, просто проигрываем звук
            local isFemale = (ThatPlyIsFemale and ThatPlyIsFemale(owner)) or false
            local snd = isFemale and "zcitysnd/female/cough_"..math.random(1,6)..".mp3" or "zcitysnd/male/cough_"..math.random(1,6)..".mp3"
            owner:EmitSound(snd, 75, math.random(95, 105))
            owner:ViewPunch(Angle(math.random(2, 4), 0, 0))
        end
    end
end)
