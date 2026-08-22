SWEP.Category = "kasanov"
SWEP.PrintName = "SCP-079"
SWEP.HoldType = "testholdtype"
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.Base = "breach_scp_base"
SWEP.CurrentCam = 0
SWEP.MaxCam = #ents.FindByClass("br_camera")
SWEP.PrevCamera = 0

DarkRP = DarkRP or {}

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "Power")
    self:NetworkVar("Int", 0, "Tier")
    self:NetworkVar("Float", 1, "MaxPower")

    self:SetTier( 1 )
    self:SetPower( 100 )
    self:SetMaxPower( 100 )
end

if CLIENT then

    local function sm(v)
	return v * ( ScrW() / 640.0 )
    end

BoHU = {}
BoHU_ColorWhite = Color(255, 255, 255, 255)
BoHU_ColorShadow = Color(0, 0, 0, 127)
local NA = "-"
local P = P or {}
local hi = {}
function SWEP:Think()
if !IsValid(LocalPlayer()) then return end

P = LocalPlayer()
hi.scrw	=	ScrW()
hi.scrh	=	ScrH()
hi.scrw_g	=	(ScrW() - hi.scrw) * 0.5
hi.scrh_g	=	(ScrH() - hi.scrh) * 0.5

hi.hp_am	=	P:Health()
hi.ar_per	=	P:Armor()/P:GetMaxArmor()
hi.ar_am	=	P:Armor()
end


function BoHU.ProgressBar( p, po, x, y, w, h )
	local prev = surface.GetDrawColor()
	local x, y = math.ceil(x), math.ceil(y)
	if w == 0 or h == 0 then return end
	p = math.Clamp(p, 0, 1)
	surface.SetDrawColor(BoHU_ColorShadow)
	surface.DrawOutlinedRect(x+2, y+2, w, h)
	surface.DrawOutlinedRect(x+1, y+1, w, h)
	surface.SetDrawColor(prev)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.DrawOutlinedRect(x-1, y-1, w+2, h+2)
	if w*p == 0 or h*p == 0 then return end
	if po == 1 then
		x = x + (w*(1-p))
	end
	surface.SetDrawColor(BoHU_ColorShadow)
	surface.DrawOutlinedRect(x+2, y+2, w*p, h)
	surface.DrawOutlinedRect(x+1, y+1, w*p, h)
	surface.SetDrawColor(prev)
	surface.DrawRect(x, y, w*p, h)
end

local vecfake = Vector(0, 0, 16000)
	surface.CreateFont( "Tahoma_lines50", { font = "Tahoma", size = 50, weight = 500, scanlines = 3, antialias = true} )
	surface.CreateFont( "Tahoma_lines30", { font = "Tahoma", size = 30, weight = 700, scanlines = 3, antialias = true} )
	surface.CreateFont( "Tahoma_lines18", { font = "Tahoma", size = 18, weight = 700, scanlines = 2, antialias = true} )
	surface.CreateFont( "Tahoma_lines23", { font = "Tahoma", size = 23, weight = 700, scanlines = 2, antialias = true} )

	surface.CreateFont( "Tahoma_lines60", { font = "Tahoma", size = 60, weight = 700, scanlines = 3, antialias = true} )
	surface.CreateFont( "Tahoma_lines80", { font = "Tahoma", size = 80, weight = 700, scanlines = 3, antialias = true} )
	surface.CreateFont( "Tahoma_lines130", { font = "Tahoma", size = 130, weight = 700, scanlines = 3, antialias = true} )

	surface.CreateFont( "BM2ConsoleFont", {
		font = "Ubuntu Mono", 
		extended = false,
		size = 19,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

    hook.Add(
	"HUDPaint",
	"DrawCombineOverlay",
	function()
		local ply = LocalPlayer()
		local x, y = ScrW() / 26, ScrH() / 12
		local blackFadeAlpha = 0
		local colorWhite = Color(255, 255, 255)
		local curTime = CurTime()

		if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "kasanov_scp_079" then
            surface.SetDrawColor(BoHU_ColorWhite)
            local wep = LocalPlayer():GetActiveWeapon()
            draw.DrawText( math.Round(wep:GetPower()), "Event_Terminal", ScrW() / 2.35, ScrH() / 1.07, Color(255,255,255), TEXT_ALIGN_LEFT )
            draw.DrawText( wep:GetMaxPower(), "Event_Terminal", ScrW() / 1.72, ScrH() / 1.07, Color(255,255,255), TEXT_ALIGN_RIGHT )
            BoHU.ProgressBar(wep:GetPower()/wep:GetMaxPower(), 0, ScrW() / 2.35, ScrH() / 1.05, sm(100), sm(4))
			local height = draw.GetFontHeight("Event_Terminal")
			if !DarkRP.combineDisplayLines then return end
			for k, v in ipairs(DarkRP.combineDisplayLines) do
				if (curTime >= v[2]) then
					table.remove(DarkRP.combineDisplayLines, k)
				else
					local color = v[4] or colorWhite
					local textColor = Color(color.r, color.g, color.b, 255 - blackFadeAlpha)

					draw.SimpleText(string.sub(v[1], 1, v[3]), "Event_Terminal", x, y, textColor)

					if (v[3] < string.len(v[1])) then
						v[3] = v[3] + 1
					end

					y = y + height
				end
			end
		end
	end
)

function DarkRP.AddCombineDisplayLine(text, color)
	local ply = LocalPlayer()
	if (ply:Alive()) then
		if (not DarkRP.combineDisplayLines) then
			DarkRP.combineDisplayLines = {}
		end
		table.insert(DarkRP.combineDisplayLines, {"OS_079/Core/Notify:" .. (text) .. "/", CurTime() + 8, 5, color})
	end
end


local randomDisplayLines = {
	"Перезагрузка оперативной памяти...",
	"Загрузка последних обновлений...",
	"Обновление всех внешних подключений...",
	"Синхронизация всех данных...",
	"Обновление радиосигнала...",
	"Проверка пинга до центрального сервера...",
	"Ожидание подключения..."
}




















local curTime, health, armor
local nextHealthWarning = CurTime() + 2
local nextRandomLine = CurTime() + 3
local lastRandomDisplayLine = ""
hook.Add(
	"Think",
	"DisplayLine_Tick",
	function()
		local ply = LocalPlayer()
		if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "kasanov_scp_079" then
			curTime = CurTime()
			health = ply:Health()
			armor = ply:Armor()
			if (nextHealthWarning <= curTime) then
				if (ply.lastHealth) then
					if (health < ply.lastHealth) then
						if (health == 0) then
							DarkRP.AddCombineDisplayLine("!ERROR! ОТКАЗ СИСТЕМ ЖИЗНЕОБЕСПЕЧЕНИЯ!", Color(255, 0, 0, 255))
						else
							DarkRP.AddCombineDisplayLine("!WARNING! Обнаружено физическое повреждение!", Color(255, 0, 0, 255))
						end
					elseif (health > ply.lastHealth) then
						if (health >= (ply:GetMaxHealth())) then
							DarkRP.AddCombineDisplayLine("Физические показатели восстановлены.", Color(0, 255, 0, 255))
						else
							DarkRP.AddCombineDisplayLine("Физические показатели восстанавливаются.", Color(0, 0, 255, 255))
						end
					end
				end

				if (ply.lastArmor) then
					if (armor < ply.lastArmor) then
						if (armor == 0) then
							DarkRP.AddCombineDisplayLine("!ERROR! Внешняя защита исчерпана!", Color(255, 0, 0, 255))
						else
							DarkRP.AddCombineDisplayLine("!WARNING! Обнаружено повреждение внешней защиты!", Color(255, 0, 0, 255))
						end
					elseif (armor > ply.lastArmor) then
						if (armor >= (ply:getJobTable().armor or 100)) then
							DarkRP.AddCombineDisplayLine("Внешняя защита восстановлена.", Color(0, 255, 0, 255))
						else
							DarkRP.AddCombineDisplayLine("Внешняя защита восстанавливается.", Color(0, 0, 255, 255))
						end
					end
				end
				nextHealthWarning = curTime + 2
				ply.lastHealth = health
				ply.lastArmor = armor
			end

			if (nextRandomLine <= curTime) then
				local text = randomDisplayLines[math.random(1, #randomDisplayLines)]

				if (text and lastRandomDisplayLine ~= text) then
					DarkRP.AddCombineDisplayLine(text)

					lastRandomDisplayLine = text
				end
				nextRandomLine = CurTime() + 3
			end
		end
	end
)












end

kasanov = kasanov or {}

SWEP.AbilityIcons = {
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    {
        Name = "Change state",
        Description = "Open/Close door you're looking at",
        Cooldown = 1,
        CooldownTime = 0,
        KEY = _G["KEY_F"],
        Using = false,
        Amount = 10,
        Icon = "nextoren/gui/special_abilities/scp079_1.png",
        Func = function(self, idx, ply)
            if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            wep:Cooldown(idx, self.Cooldown)
            
            local hitPos = ply:GetEyeTrace().HitPos
            for _, ent in ipairs(ents.FindInSphere(hitPos, 100)) do
                if not ent then continue end
                if not IsValid(ent) then continue end
                if ent:GetClass() ~= "func_door" then continue end
                if ent:GetName():find("elev") then continue end
                if ent:GetName():find("gate") then continue end
                if ent:GetName():find("shel") then continue end
                if ent:GetName():find("914") then continue end
                if ent:GetInternalVariable("m_toggle_state") == 1 then
                    ent:Fire("open")
                else
                    ent:Fire("close")
                end
                ent:EmitSound("cpthazama/scp/079/broadcast"..math.random(1,7)..".mp3")
            end
           
                BREACH.SendClientEvent(ply, "combine_line", {text = "Энергия = OS_079 - 10 // Причина : Открытие двери", color = Color(255, 0, 0, 255)})
            
        end,
    },
    {
        Name = "Lock Door",
        Description = "Closes the door you're looking at",
        Cooldown = 5,
        CooldownTime = 0,
        KEY = _G["KEY_G"],
        Using = true,
        Amount = 0,
        CurrentDoor = nil,
        HackedDoors = {},
        Icon = "nextoren/gui/special_abilities/scp079_2.png",
        Func = function(self, idx, ply)
            if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            if not self.CurrentDoor then
                wep:Cooldown(idx, 1)
                local hitPos = ply:GetEyeTrace().HitPos

                for _, ent in ipairs(ents.FindInSphere(hitPos, 100)) do
                    if not ent then continue end
                    if not IsValid(ent) then continue end
                    if ent:GetClass() ~= "func_door" and ent:GetClass() ~= "func_button" then continue end
                    if ent:GetName():find("elev") then continue end
                    if ent:GetName():find("gate") then continue end
                    if ent:GetName():find("shel") then continue end
                    if ent:GetName():find("914") then continue end
                    ent.SCP079_Blocked = true
                    ent:EmitSound( "ambient/energy/spark"..math.random( 1, 6 )..".wav", 900 )
                    ent:EmitSound( "ambient/energy/spark"..math.random( 1, 6 )..".wav", 900 )
                    ent:EmitSound( "ambient/energy/spark"..math.random( 1, 6 )..".wav", 900 )
                    self.HackedDoors[#self.HackedDoors + 1] = ent
                    timer.Create( "SCP079_LeakPower_By_"..ent:EntIndex(), 1, 0, function()
                        if wep:GetPower() - 5 < 0 then
                            timer.Remove("SCP079_LeakPower_By_"..ent:EntIndex())
                            ent.SCP079_Blocked = false
                            self.CurrentDoor = false
                            self.HackedDoors = {}
                            for _, pl in player.Iterator() do
                                if not pl then continue end
                                if not pl:IsPlayer() then continue end
                                if pl:Health() <= 0 then continue end
                                if pl:GTeam() ~= TEAM_SCP then continue end
                                net.Start("scp079_brokendoor")
                                    net.WriteTable(self.HackedDoors)
                                net.Send(pl)
                            end
                        else
                            wep:SetPower(wep:GetPower() - 5)
                            BREACH.SendClientEvent(ply, "combine_line", {text = "Энергия = OS_079 - 5 // Причина : Блокировка двери", color = Color(255, 0, 0, 255)})
                        end
                    end)
                    for _, pl in player.Iterator() do
                        if not pl then continue end
                        if not pl:IsPlayer() then continue end
                        if pl:Health() <= 0 then continue end
                        if pl:GTeam() ~= TEAM_SCP then continue end
                        net.Start("scp079_brokendoor")
                            net.WriteTable(self.HackedDoors)
                        net.Send(pl)
                    end
                end
                self.CurrentDoor = true
            else
                wep:Cooldown(idx, self.Cooldown)
                for _, ent in pairs(self.HackedDoors) do
                    timer.Remove( "SCP079_LeakPower_By_"..ent:EntIndex() )
                    ent.SCP079_Blocked = false
                    self.CurrentDoor = false
                    self.HackedDoors = {}
                end
                for _, pl in player.Iterator() do
                    if not pl then continue end
                    if not pl:IsPlayer() then continue end
                    if pl:Health() <= 0 then continue end
                    if pl:GTeam() ~= TEAM_SCP then continue end
                    net.Start("scp079_brokendoor")
                        net.WriteTable(self.HackedDoors)
                    net.Send(pl)
                end
            end
        end,
    },
    {
        Name = "Hack Tesla",
        Description = "Makes the Tesla gate work before it temporarily turns on",
        Cooldown = "15",
        CooldownTime = 0,
        KEY = _G["KEY_H"],
        Using = false,
        Icon = "nextoren/gui/special_abilities/scp079_4.png",
        Amount = 20,
        Func = function(self, idx, ply)
            if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            wep:Cooldown(idx, self.Cooldown)
            local hitPos = ply:GetEyeTrace().HitPos
            for _, ent in ipairs(ents.FindInSphere(hitPos, 200)) do
                if not ent then continue end
                if not IsValid(ent) then continue end
                if ent:GetClass() ~= "test_entity_tesla" then continue end
                
                ent.SCP079_Hacked = CurTime() + 3
                ent:SetActive(true)
                ent.Reloading = 0
                timer.Simple(3, function()
                    ent:SetActive(false)
                end)
            end
        end,
    },
    {
        Name = "Look At Him",
        Description = "Highlights the player you are looking at for allies for a short time",
        Cooldown = "10",
        CooldownTime = 0,
        KEY = 109,
        Using = false,
        Icon = "nextoren/gui/special_abilities/scp079_3.png",
        Time = 4,
        Amount = 5,
        Func = function(self, idx, ply)
            if self.CooldownTime > CurTime() then return end
            self.CooldownTime = CurTime() + self.Cooldown
            local wep = ply:GetActiveWeapon()
            wep:Cooldown(idx, self.Cooldown)
            local hitPos = ply:GetEyeTrace().HitPos

            for _, ply in ipairs(ents.FindInSphere(hitPos, 100)) do
                if not ply then continue end
                if not ply:IsPlayer() then continue end
                if ply:Health() <= 0 then continue end
                if ply:GTeam() == TEAM_SPEC then continue end
                if ply:GTeam() == TEAM_SCP then continue end
                if ply:GTeam() == TEAM_DZ then continue end
                local tableToSend = {}
                tableToSend[#tableToSend+1] = ply

                for _, pl in player.Iterator() do
                    if not pl then continue end
                    if not pl:IsPlayer() then continue end
                    if pl:Health() <= 0 then continue end
                    if pl:GTeam() ~= TEAM_SCP then continue end
                    net.Start("scp079_ping")
                        net.WriteTable(tableToSend)
                        net.WriteUInt(self.Time, 8)
                    net.Send(pl)
                end
            end
        end,
    },
}



function SWEP:PrimaryAttack()
    return
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Reload()
    return
end

if SERVER then
    util.AddNetworkString("scp079_brokendoor")
    util.AddNetworkString("scp079_ping")
end

if CLIENT then
    net.Receive("scp079_brokendoor", function(len)
        local FirstTableDoors = net.ReadTable()
        local tableNULL = {}
        local tableDoors = {}
        for _, ent in pairs(FirstTableDoors) do
            local children = ent:GetChildren()
            for _, data in pairs(children) do
                tableDoors[#tableDoors + 1] = data
            end
        end
        if tableDoors ~= tableNULL then
            local ply = LocalPlayer()
            if ply:GTeam() ~= TEAM_SCP then return end
            hook.Add("PreDrawOutlines", "SCP079_BROKENDOOR", function()
                if ply:GTeam() ~= TEAM_SCP then hook.Remove("PreDrawOutlines", "SCP079_BROKENDOOR") end
                outline.Add( tableDoors, Color(255,0,0), 0 )
            end)
        else
            hook.Remove("PreDrawOutlines", "SCP079_BROKENDOOR")
        end
    end)

    net.Receive("scp079_ping", function(len)
        local tableUsers = net.ReadTable()
        local duration = net.ReadUInt(8)

        local ply = LocalPlayer()
        if ply:GTeam() ~= TEAM_SCP then return end
        hook.Add("PreDrawOutlines", "SCP079_PING", function()
            if ply:GTeam() ~= TEAM_SCP then hook.Remove("PreDrawOutlines", "SCP079_PING") end
            outline.Add( tableUsers, Color(255,0,0), 3 )
        end)

        timer.Create("SCP079_PING", duration, 1, function()
            hook.Remove("PreDrawOutlines", "SCP079_PING")
        end)
    end)

    function SWEP:Initialize()
        if IsValid(BREACH.SCP079) then BREACH.SCP079:Remove() end
        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        

        
        
        
        
        
        
        
        
        
        
        
    end
end

function SWEP:Deploy()

    kasanov.FindAbilityTableByKey = function(wep, key)
    local abilityTable = wep.AbilityIcons

    for idx, info in ipairs(abilityTable) do
        if info.KEY == key then
            return idx
        end
    end

    return nil
    end
    local own = self.Owner

    if not own or not IsValid(own) then return end
    timer.Simple(.5, function()
        own:SetNoDraw(true)
        own:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
        own:SetModelScale(.1)
    end)

    BREACH.SendClientEvent(own, "scp079_mode", {enabled = true})
    self:SetTier( 1 )
    self:SetPower( 100 )
    self:SetMaxPower( 100 )
    
    
    own:SetMoveType(MOVETYPE_NOCLIP)
    
    

    timer.Create("SCP079_GenerateMana", 1, 0, function()
        if self:GetPower() + self:GetTier() > self:GetMaxPower() then
            self:SetPower(self:GetMaxPower())
        else
            self:SetPower(self:GetPower() + self:GetTier())
        end
    end)

    hook.Add('PlayerButtonDown', 'SCP079_Buttons', function(ply, button)
        if ply:GetRoleName() ~= "SCP079" then return end

        local wep = ply:GetActiveWeapon()
        if not wep or not wep.AbilityIcons then return end

        local abilityIdx = kasanov.FindAbilityTableByKey(wep, button)
        if abilityIdx then
            local abilityTable = wep.AbilityIcons[abilityIdx]
            if abilityTable.CooldownTime > CurTime() then return end
            if abilityTable.Func and isfunction(abilityTable.Func) then
                if abilityTable.Amount and wep:GetPower() < abilityTable.Amount then
                    BREACH.SendClientEvent(ply, "play_sound", {sound = "ambient/energy/spark" .. math.random(1, 6) .. ".wav"})
                    return
                end
                wep:SetPower(wep:GetPower() - abilityTable.Amount)
                abilityTable.Func(abilityTable, abilityIdx, ply)
            end
        end
    end)
end


function SWEP:OnRemove()
    local players = player.GetAll()
    local scp079_exists
    for i = 1, #players do
        local player = players[i]
        if player:GetRoleName() == "SCP079" then
            scp079_exists = true
            break
        end
    end

    for _, ent in pairs(ents.FindByClass("br_camera")) do
        ent:SetEnabled(false)
    end

    if not scp079_exists then
        hook.Remove("PlayerButtonDown", "SCP079_Buttons")
        timer.Remove("SCP079_GenerateMana")
    end
    if CLIENT then
        GetConVar("pp_fz_ps1_shader_enable"):SetFloat(0)
    end
end



function SWEP:Think()
  if SERVER then
    if SCPLockDownHasStarted != true then
        if IsValid(self:GetOwner()) and !self:GetOwner():GetPos():WithinAABox(Vector(3178.099365, 3342.646240, 317),Vector(3913.222168, 2660.589844, -114)) then
            self:GetOwner():SetPos(Vector(3407.471924, 3010.586426, 91))
        end
    end
  end
end