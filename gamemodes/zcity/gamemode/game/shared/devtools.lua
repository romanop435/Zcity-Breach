local FindMetaTable = FindMetaTable
local CurTime = CurTime
local ipairs = ipairs
local table = table
local timer = timer
local hook = hook
local math = math
local tonumber = tonumber
local ents = ents
local player = player


local surface = surface or {}
local render = render or {}
local vgui = vgui or {}

if CLIENT then
	FSpectate = {}
	local isSpectating = false
	local specEnt
	local thirdperson = true
	local isRoaming = false

	local maxdistmeters_plys = 200
	local maxdistsqr_plys = (maxdistmeters_plys / 0.01905)^2

	hook.Add("Initialize", "FSpectate", function()
		surface.CreateFont("UiBold", { size = 16, weight = 800, antialias = true, shadow = false, font = "Verdana" })
	end)

	local LineMat = Material("cable/new_cable_lit")
	local linesToDraw = {}
	local view = {}

	local function specCalcView()
		view.origin = LocalPlayer():GetShootPos()
		view.angles = LocalPlayer():EyeAngles()
	end

	local function lookingLines()
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "kasanov_scp_079" then return end
		if not linesToDraw[0] then return end
		
		render.SetMaterial(LineMat)
		cam.Start3D(view.origin, view.angles)
		for i = 0, #linesToDraw, 3 do
			if linesToDraw[i] and linesToDraw[i+1] then
				render.DrawLine(linesToDraw[i], linesToDraw[i+1], linesToDraw[i+2] or color_white) 
			end
		end
		cam.End3D()
	end

	local function specThink()
		local lp = LocalPlayer()
		local lastPly, skip = 0, 0
		
		for i, p in player.Iterator() do
			if not IsValid(p) or not p:Alive() then skip = skip + 3 continue end
			if p == lp then skip = skip + 3 continue end
			if not isRoaming and p == specEnt and not thirdperson then skip = skip + 3 continue end

			local tr = p:GetEyeTrace()
			local sp = p:EyePos()
			local pos = (i - 1) * 3 - skip

			linesToDraw[pos] = tr.HitPos
			linesToDraw[pos + 1] = sp
			linesToDraw[pos + 2] = gteams.GetColor(p:GTeam())
			lastPly = i
		end

		for i = #linesToDraw, lastPly * 3, -1 do linesToDraw[i] = nil end
	end

	local uiForeground, uiBackground = Color(240, 240, 255, 255), Color(20, 20, 20, 120)
	local green = Color(0, 255, 0, 255)

	local function drawHelp()
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "kasanov_scp_079" then return end
		local myPos = LocalPlayer():GetPos()

		for _, ply in player.Iterator() do
			if not IsValid(ply) or not ply:Alive() or ply == LocalPlayer() then continue end
			if myPos:DistToSqr(ply:GetPos()) > maxdistsqr_plys then continue end

			local pos = ply:GetShootPos():ToScreen()
			if not pos.visible then continue end

			local x, y = pos.x, pos.y
			draw.RoundedBox(2, x, y - 6, 12, 12, gteams.GetColor(ply:GTeam()))
			draw.WordBox(2, x, y - 86, ply:Nick() .. "(" .. (ply:GetNamesurvivor() or "") .. ")", "BudgetLabel", uiBackground, uiForeground) 
			draw.WordBox(2, x, y - 66, ply:GetRoleName() or "", "BudgetLabel", uiBackground, gteams.GetColor(ply:GTeam())) 
			draw.WordBox(2, x, y - 46, "HP: " .. ply:Health() .. "/" .. ply:GetMaxHealth(), "BudgetLabel", uiBackground, green)
			draw.WordBox(2, x, y - 26, ply:SteamID(), "BudgetLabel", uiBackground, uiForeground)
		end
	end

	local funnywh = false
	concommand.Add("funny_wallhackers", function()
		if LocalPlayer():IsSuperAdmin() then funnywh = not funnywh end
	end)
	
	hook.Add("Think", "FSpectate_AdminObserver", function()
		if not LocalPlayer():IsAdmin() or LocalPlayer():InVehicle() then return end
		local isGhost = (LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP or funnywh) and LocalPlayer():GTeam() ~= TEAM_SPEC
		
		if isGhost and not isSpectating then
			isSpectating = true
			hook.Add("Think", "FSpectate", specThink)
			hook.Add("HUDPaint", "FSpectate", drawHelp)
			hook.Add("CalcView", "FSpectate", specCalcView)
			hook.Add("RenderScreenspaceEffects", "FSpectate", lookingLines)
		elseif not isGhost and isSpectating then
			isSpectating = false
			hook.Remove("Think", "FSpectate")
			hook.Remove("HUDPaint", "FSpectate")
			hook.Remove("CalcView", "FSpectate")
			hook.Remove("RenderScreenspaceEffects", "FSpectate")
			table.Empty(linesToDraw)
		end
	end)

	BREACH.Descriptions = BREACH.Descriptions or { russian = {}, english = {} }

	function BREACH.GetDescription(rolename)
		local mylang = langtouse or "english"
		local langtable = BREACH.Descriptions[mylang] or (mylang == "ukraine" and BREACH.Descriptions.russian or BREACH.Descriptions.english)

		if not langtable[rolename] then
			if rolename:find("SCP") then
				return (mylang == "russian" or mylang == "ukraine") and "Вы - Аномальный SCP-Объект\n\nСкооперируйтесь с другими SCP, убейте всех людей кроме Длани Змей и сбегите!" or 
					   (mylang == "chinese" and "你是一个异常的SCP对象\n\n与其他Scp合作，杀死除蛇之手以外的所有人类并逃跑！" or "You are an Anomalous SCP Object\n\nCooperate with other SCPs, kill all humans except the Hand of the Serpents and escape!")
			else
				local role_str = GetLangRole(rolename)
				return (mylang == "russian" or mylang == "ukraine") and "Вы - " .. role_str .. "\n\nВыполняйте свою нынешнюю задачу." or 
					   (mylang == "chinese" and "你 -" .. role_str .. "\n\n完成当前任务" or "You - " .. role_str .. "\n\nComplete your current task.")
			end
		end
		return langtable[rolename]
	end

	function StartIntroMusic()
		local t = LocalPlayer():GTeam()
		if t == TEAM_SCP then SCPStart()
		elseif t ~= TEAM_GUARD and t ~= TEAM_FURRY and t ~= TEAM_ANTIFURRY and t ~= TEAM_COMBINE and t ~= TEAM_RESISTANCE and t ~= TEAM_NAZI and t ~= TEAM_AMERICA then
			surface.PlaySound("no_music/start_round_ambient/start_ambience" .. math.random(1, 10) .. ".ogg")
		end
	end

    local shakeEndTime = 0
    local shakeIntensity = 0
    local shakeDuration = 0

    function hg.ShakeScreenLocal(intensity, duration)
        shakeIntensity = intensity
        shakeDuration = duration
        shakeEndTime = CurTime() + duration
    end

	hook.Add("Think", "HG_ActualScreenShake_Intro", function()
        if CurTime() < shakeEndTime then
            local timeLeft = shakeEndTime - CurTime()
            local progress = 1 - (timeLeft / shakeDuration)
            local fade = (1 - progress) ^ 2 
            
            local amp = (shakeIntensity / 10) * fade
            
            --if ViewPunch4 then
                local shakeAng = Angle(
                    math.sin(CurTime() * 50) * amp, 
                    math.cos(CurTime() * 45) * amp, 
                    0
                )
                ViewPunchIntro(shakeAng)
            --end
        end
    end)

    hook.Add("Post Processing", "HG_Intro_FearEffect", function()
        if CurTime() >= shakeEndTime then return end
        
        local timeLeft = shakeEndTime - CurTime()
        local fade = math.Clamp(timeLeft / 1.0, 0, 1)

        local tab = {
            ["$pp_colour_brightness"] = -fade * 0.15,
            ["$pp_colour_contrast"] = 1 + (fade * 0.3),
            ["$pp_colour_colour"] = 1 - (fade * 0.8),
            --["$pp_colour_addr"] = fade * 0.1,
        }
        DrawColorModify(tab)
    end)

	local shake_times = {3.16, 6, 6.2, 8.5, 10.5, 14, 16, 18, 21.28, 23.28, 25, 26, 29.15, 34, 36, 39, 40.5}

	function IntroSound()
	    local client = LocalPlayer()
	    if not IsValid(client) then return end
	    local t = client:GTeam()

	    if t ~= TEAM_GUARD and FadeMusic then FadeMusic(1) end
		
	    if t == TEAM_GUARD then
	        surface.PlaySound("nextoren/start_round/start_round_mtf.mp3")        
	    elseif t == TEAM_CLASSD or t == TEAM_SCI then
	        surface.PlaySound(t == TEAM_CLASSD and "nextoren/start_round/start_round_classd.mp3" or "nextoren/start_round/start_round_sci.mp3")
		
	        timer.Simple(7, function()
	            hg.ShakeScreenLocal(5, 1)
	            surface.PlaySound("nextoren/others/horror/horror_14.ogg")
			
	            local blackscreen = vgui.Create("DPanel")
	            blackscreen:SetSize(ScrW(), ScrH()) 
	            blackscreen:SetAlpha(0)
	            blackscreen:AlphaTo(255, 0.6, 0, function()
	                if BREACH and BREACH.Round then BREACH.Round.GeneratorsActivated = false end
	                blackscreen:AlphaTo(0, 1, 3, function() blackscreen:Remove() end)
	            end)
	            blackscreen.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,255)) end

	            for _, tm in ipairs(shake_times) do
	                timer.Simple(tm, function()
	                    local amp = (tm == 36 or tm == 40.5) and 25 or 3
	                    local dur = (tm == 36 or tm == 40.5) and 1.5 or 0.4
	                    hg.ShakeScreenLocal(amp, dur)
	                end)
	            end
	        end)
	    elseif t == TEAM_SCP then
	        surface.PlaySound("nextoren/start_round/start_round_scp.mp3")
	    end
	end

	function StartOutisdeSounds() surface.PlaySound("Satiate Strings.ogg") end
	function StartEndSound() surface.PlaySound("Mandeville.ogg") end

	function CreateFirstPersonFlashlight(texture, enableshadows, farz, fov, brightness)
		local pt = ProjectedTexture()
		pt:SetTexture(texture or "effects/flashlight001")
		pt:SetEnableShadows(enableshadows == nil and true or enableshadows)
		pt:SetFarZ(farz or 512)
		pt:SetFOV(fov or 60)
		pt:SetBrightness(brightness or 3)
		LocalPlayer().FlashlightProjectedTexture = pt
		return pt
	end

	function EnableFirstPersonFlashlight()
		if not IsValid(LocalPlayer().FlashlightProjectedTexture) then CreateFirstPersonFlashlight() return end
		LocalPlayer().FlashlightProjectedTexture:SetNearZ(0)
	end

	function DisableFirstPersonFlashlight()
		if not IsValid(LocalPlayer().FlashlightProjectedTexture) then CreateFirstPersonFlashlight() end
		LocalPlayer().FlashlightProjectedTexture:SetNearZ(1)
	end

	hook.Add('NotifyShouldTransmit', 'FlashLight_NotifyShouldTransmit', function(ent, shouldTransmit)
		if ent:GetClass() == 'ent_flashlight' then
			local owner = ent:GetParent()
			if IsValid(owner) then ent:SetParent(owner) end
		end
	end)
end

local mply = FindMetaTable("Player")
DEFINE_BASECLASS("player_default")

local PLAYER = {}

function PLAYER:SetupDataTables()
	if self._datatableapplied then return end
	self._datatableapplied = true
	
	self.Player:NetworkVar("String", 0, "RoleName")
	self.Player:NetworkVar("String", 1, "Namesurvivor")
	self.Player:NetworkVar("Int", 0, "NEXP")
	self.Player:NetworkVar("Int", 1, "NLevel")
	self.Player:NetworkVar("Int", 2, "NGTeam")
	self.Player:NetworkVar("Int", 3, "MaxSlots")
	self.Player:NetworkVar("Int", 4, "SpecialMax")
	self.Player:NetworkVar("Int", 5, "PenaltyAmount")
	self.Player:NetworkVar("Float", 0, "SpecialCD")
	self.Player:NetworkVar("Float", 1, "StaminaScale")
	self.Player:NetworkVar("Bool", 0, "Energized")
	self.Player:NetworkVar("Bool", 1, "Boosted")
	self.Player:NetworkVar("Bool", 2, "Adrenaline")
	self.Player:NetworkVar("Bool", 3, "Female")
	self.Player:NetworkVar("Bool", 4, "InDimension")
	self.Player:NetworkVar("Bool", 5, "Crouching")

	if SERVER then
		self.Player:SetRoleName("Spectator")
		self.Player:SetNamesurvivor("")

		if BREACH and BREACH.DataBaseSystem then
			BREACH.DataBaseSystem:LoadPlayer(self.Player, function()
				print("[RXSEND MYSQLOO] Data for " .. self.Player:Nick() .. " has been set successfully!")
			end)
		end

		self.Player:SetNGTeam(1)
		self.Player:SetSpecialCD(0)
		self.Player:SetInDimension(false)
		self.Player:SetAdrenaline(false)
		self.Player:SetEnergized(false)
		self.Player:SetBoosted(false)
		self.Player:SetMaxSlots(8)
		self.Player:SetFemale(false)
		self.Player:SetCrouching(false)
		self.Player:SetSpecialMax(0)
		self.Player:SetStaminaScale(1.0)
	end
end

function CheckPlayerData(player, name)
	local pd = player:GetPData(name, 0)
	if pd == "nil" or pd == nil then
		print("Damaged playerdata found...")
		player:RemovePData(name)
		player:SetPData(name, 1)
	end
end

player_manager.RegisterClass("class_breach", PLAYER, "player_default")