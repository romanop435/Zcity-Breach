UtopiaCore = UtopiaCore or {}

UtopiaCore.LicenseKey = "А_Тут_Должен_Быть_Ваш_Ключ"

UtopiaCore.DB = {
    Enabled = true,
    Host = "ip",
    Username = "username",
    Password = "password",
    Database_name = "dbname",
    Database_port = 3306,
    MultiStatements = true 
}

newMysql = newMysql or {}
newMysql.QueryQueue = {}
function newMysql.query(sqlText, cb, errCb)
    table.insert(newMysql.QueryQueue, {sqlText, cb, errCb})
end

BREACH = BREACH or {}
BREACH.DataBaseSystem = BREACH.DataBaseSystem or {}
BREACH.DataBaseSystem.ActionQueue = {}

function BREACH.DataBaseSystem:Connect() end
function BREACH.DataBaseSystem:UpdateData(sid64, dataname, value, add)
    table.insert(BREACH.DataBaseSystem.ActionQueue, {"UpdateData", sid64, dataname, value, add})
end
function BREACH.DataBaseSystem:GetData(sid64, dataname, default, callback, onerror)
    table.insert(BREACH.DataBaseSystem.ActionQueue, {"GetData", sid64, dataname, default, callback, onerror})
end
function BREACH.DataBaseSystem:LoadPlayer(ply, onload)
    table.insert(BREACH.DataBaseSystem.ActionQueue, {"LoadPlayer", ply, onload})
end

local AUTH_URL = "http://5.42.211.4:27017/auth"

print("[Utopia Core] Проверка лицензии...")

local serverIP = game.GetIPAddress()
if not serverIP or serverIP == "loopback" then 
    serverIP = "127.0.0.1" 
end

local requestUrl = AUTH_URL .. "?key=" .. UtopiaCore.LicenseKey

http.Fetch(requestUrl,
    function(body, len, headers, code)
        if code ~= 200 then
            local errData = util.JSONToTable(body)
            local errMsg = (errData and errData.error) or ("Ошибка HTTP: " .. tostring(code))
            ErrorNoHalt("\n=========================================\n")
            ErrorNoHalt("[Utopia Core] ОШИБКА ЛИЦЕНЗИИ: \n" .. errMsg .. "\n")
            ErrorNoHalt("=========================================\n\n")
            return
        end

        local data = util.JSONToTable(body)
        if data and data.success and data.files then
            print("[Utopia Core] Лицензия подтверждена! Загрузка модулей...")
            
            for filename, lua_code in pairs(data.files) do
                local func = CompileString(lua_code, filename, false)
                if isfunction(func) then
                    local success, err = pcall(func)
                    if not success then
                        ErrorNoHalt("  -> Ошибка выполнения " .. filename .. ":\n" .. tostring(err) .. "\n")
                    end
                else
                    ErrorNoHalt("  -> Ошибка синтаксиса " .. filename .. ":\n" .. tostring(func) .. "\n")
                end
            end
            
            print("[Utopia Core] Ядро успешно запущено! Обработка очереди запросов...")
            
            if newMysql.QueryQueue then
                for _, q in ipairs(newMysql.QueryQueue) do
                    newMysql.query(q[1], q[2], q[3])
                end
                newMysql.QueryQueue = nil
            end
            
            if BREACH.DataBaseSystem.ActionQueue then
                for _, act in ipairs(BREACH.DataBaseSystem.ActionQueue) do
                    if act[1] == "UpdateData" then
                        BREACH.DataBaseSystem:UpdateData(act[2], act[3], act[4], act[5])
                    elseif act[1] == "GetData" then
                        BREACH.DataBaseSystem:GetData(act[2], act[3], act[4], act[5], act[6])
                    elseif act[1] == "LoadPlayer" then
                        BREACH.DataBaseSystem:LoadPlayer(act[2], act[3])
                    end
                end
                BREACH.DataBaseSystem.ActionQueue = nil
            end
        end
    end,
    function(err)
        ErrorNoHalt("[Utopia Core] Нет связи с сервером авторизации: " .. tostring(err) .. "\n")
    end
)