if SERVER then return end

CreateClientConVar("mw2023_hitmarker_enable", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_stick", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_sound", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_killsound", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_hit", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_score", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_achievement", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_scale", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_scaletext", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_textX", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_textY", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE})

CreateClientConVar("mw2023_hitmarker_head", "HEADSHOT", {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_one", "ONE SHOT ONE KILL", {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_meele", "BRUTAL", {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_long", "LONG RANGE KILL", {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_dist", 30, {FCVAR_USERINFO, FCVAR_ARCHIVE})

CreateClientConVar("mw2023_hitmarker_r", 227, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_g", 233, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_b", 85, {FCVAR_USERINFO, FCVAR_ARCHIVE})
CreateClientConVar("mw2023_hitmarker_a", 100, {FCVAR_USERINFO, FCVAR_ARCHIVE})

local HitMaterial = {
	L1 = Material("mw2023/hit/L1"),
	L2 = Material("mw2023/hit/L2"),
	R1 = Material("mw2023/hit/R1"),
	R2 = Material("mw2023/hit/R2"),
}

local KillInHead = false
local ShootInHead = false
local HitMarker = {}	
local hitPos = Vector()
local HitTimer = { kill = 0, hit = 0, fade = 0 }
local hitmarker = { alpha = 0, hitalpha = 0, killS = 0, hitS = 0 }
local S = { hit = 0, killdist = 0 }
local hitR = 0
local kill = false

local notice = { life = 0, textScale = 5, nummove = 0, move = 0, specialmove = 0, showsup = 0 }
local alpha = { num = 0, text = 0, special = 0 }

local killscore2 = 0
local killdist = 0
local achievement = {}
local exist = {}
local int = 0

local function AddToAchievement(name, score)
	if GetConVar("mw2023_hitmarker_achievement"):GetInt() ~= 1 then return end
	if table.HasValue(exist, name) then return end

	int = int + 1
	achievement[int] = achievement[int] or {}
    achievement[int].name = name
    exist[int] = name
    achievement[int].life = CurTime() + 2 + (int - 1) * 0.1
    achievement[int].score = score
    achievement[int].move = 0
    achievement[int].showsup = 0
    achievement[int].alpha = 0
    achievement[int].pos = 0
end

net.Receive("MW2023_long_range", function()
	timer.Simple(0.1, function()	
		if killdist >= GetConVar("mw2023_hitmarker_dist"):GetFloat() then
			AddToAchievement(GetConVar("mw2023_hitmarker_long"):GetString(), 25)
			killscore2 = killscore2 + 25
		end
	end)
end)

net.Receive("MW2023_headshot", function()
	timer.Simple(0.1, function()	
		AddToAchievement(GetConVar("mw2023_hitmarker_head"):GetString(), 25)
		killscore2 = killscore2 + 25
	end)
end)

net.Receive("MW2023_meele", function()
	timer.Simple(0.1, function()	
		AddToAchievement(GetConVar("mw2023_hitmarker_meele"):GetString(), 25)
		killscore2 = killscore2 + 25
	end)
end)

net.Receive("MW2023_dist", function()
	killdist = net.ReadFloat()
end)

local kill_shake = false

net.Receive("MW2023_kill", function()
	if GetConVar("mw2023_hitmarker_enable"):GetInt() ~= 1 then return end

	kill_shake = true
	timer.Create("kill_shake", 0.2, 1, function() kill_shake = false end)

	local killsound = "mw2023/kill.wav"
	KillInHead = net.ReadBool()
	local killcount = net.ReadInt(32)

	table.Empty(achievement)
	table.Empty(exist)
	int = 0

	notice.life = CurTime() + 2	
	alpha.num = 0
	notice.nummove = 0
	notice.move = 0
	notice.textScale = 5
	notice.showsup = 0
	S.killdist = 0
	hitmarker.killS = 1
	killscore2 = killscore2 + 100

	AddToAchievement("ELIMINATED", 100)

	if KillInHead then killsound = "mw2023/headshot3.wav" end

	HitTimer.kill = CurTime() + 0.5
	timer.Simple(0.1, function()
		if GetConVar("mw2023_hitmarker_killsound"):GetInt() == 1 then 
			surface.PlaySound(killsound)
		end
	end)
	kill = true
end)

local hitScale = { x = 0, y = 0 }
local hit_shake = false

net.Receive("MW2023_hit", function()
	if GetConVar("mw2023_hitmarker_enable"):GetInt() ~= 1 then return end

	hit_shake = true
	timer.Create("hit_shake", 0.1, 1, function() hit_shake = false end)

	local ent = net.ReadEntity()
	ShootInHead = net.ReadBool()
	local armored = net.ReadBool()
	local hitarmor = net.ReadBool()
	local armorbreak = net.ReadBool()
	hitPos = net.ReadVector()

	hitR = math.Rand(-10, 10)
	HitTimer.hit = CurTime() + 0.2
	HitTimer.fade = CurTime() + 0.3

	if hitarmor then
		HitMarker.markColor = Color(0, 130, 200) -- Синий маркер брони
	else
		HitMarker.markColor = Color(255, 255, 255)
	end

	timer.Simple(0.1, function() 
		if GetConVar("mw2023_hitmarker_sound"):GetInt() ~= 1 then return end 

		if hitarmor then
			if ShootInHead then
				surface.PlaySound("mw2023/armor_hit_head.wav")
			else
				surface.PlaySound("mw2023/hit_armor.wav")
			end
		else
			surface.PlaySound("mw2023/hit.wav")
		end
	end)
end)

HitMarker.markColor = Color(255, 255, 255)
local shake_scale = ScrW() * 0.008
local shake_x, shake_y = 0, 0
HitMarker.armor_icon = 0

hook.Add("DrawOverlay", "MW2023Hitmarker_ZCity", function()
	if GetConVar("mw2023_hitmarker_enable"):GetInt() ~= 1 then return end

	local FT = FrameTime()
	local MarkPos = hitPos:ToScreen()
	local x, y = MarkPos.x, MarkPos.y

	if hit_shake or kill_shake then
        shake_x = shake_scale * (math.random() - 0.5)
        shake_y = shake_scale * (math.random() - 0.5)
    else
        shake_x, shake_y = 0, 0
    end	

	if GetConVar("mw2023_hitmarker_stick"):GetInt() == 1 then
		x, y = ScrW()/2, ScrH()/2
	end

	if HitTimer.kill > CurTime() then
		hitmarker.alpha = 1
	else
		hitmarker.alpha = Lerp(FT*20, hitmarker.alpha, 0)
		kill = false
	end

	if HitTimer.hit > CurTime() then
		hitScale.x = Lerp(FT*10, hitScale.x, 10)
		hitScale.y = Lerp(FT*10, hitScale.y, 10)
	else
		if HitTimer.hit < CurTime() - 0.3 then
			hitScale.x = Lerp(FT*10, hitScale.x, 10)
			hitScale.y = Lerp(FT*10, hitScale.y, 10)
		else
			hitScale.x = Lerp(FT*10, hitScale.x, -1)
			hitScale.y = Lerp(FT*10, hitScale.y, -1)
		end
	end

    local scaleMul = GetConVar("mw2023_hitmarker_scale"):GetFloat()

	if KillInHead then
		surface.SetDrawColor(255, 0, 0, 255 * hitmarker.alpha)
		surface.SetMaterial(HitMaterial.L1)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x + 3)), y + ScreenScale(0.325*(shake_y - hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
		surface.SetMaterial(HitMaterial.L2)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x - 3)), y + ScreenScale(0.325*(shake_y + hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
		surface.SetMaterial(HitMaterial.R1)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x - 3)), y + ScreenScale(0.325*(shake_y - hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
		surface.SetMaterial(HitMaterial.R2)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x + 3)), y + ScreenScale(0.325*(shake_y + hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	end

	surface.SetDrawColor(255, 0, 0, 255 * hitmarker.alpha)
	surface.SetMaterial(HitMaterial.L1)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x)), y + ScreenScale(0.325*(shake_y - hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	surface.SetMaterial(HitMaterial.L2)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x)), y + ScreenScale(0.325*(shake_y + hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	surface.SetMaterial(HitMaterial.R1)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x)), y + ScreenScale(0.325*(shake_y - hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	surface.SetMaterial(HitMaterial.R2)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x)), y + ScreenScale(0.325*(shake_y + hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)

	if kill then
		hitmarker.hitalpha = 0
	else
		if HitTimer.fade > CurTime() then
			S.hit = Lerp(FT*20, S.hit, hitR)
			hitmarker.hitalpha = 1
		else
			hitmarker.hitalpha = Lerp(FT*10, hitmarker.hitalpha, 0)
			if hitmarker.hitalpha < 0.3 then S.hit = Lerp(FT*10, S.hit, 0) end
		end
	end

	if ShootInHead then
		surface.SetDrawColor(ColorAlpha(HitMarker.markColor, 255 * hitmarker.hitalpha))
		surface.SetMaterial(HitMaterial.L1)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x + 3)), y + ScreenScale(0.325*(shake_y - hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
		surface.SetMaterial(HitMaterial.L2)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x - 3)), y + ScreenScale(0.325*(shake_y + hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
		surface.SetMaterial(HitMaterial.R1)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x - 3)), y + ScreenScale(0.325*(shake_y - hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
		surface.SetMaterial(HitMaterial.R2)
		surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x + 3)), y + ScreenScale(0.325*(shake_y + hitScale.y - 4)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	end

	surface.SetDrawColor(ColorAlpha(HitMarker.markColor, 255 * hitmarker.hitalpha))
	surface.SetMaterial(HitMaterial.L1)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x)), y + ScreenScale(0.325*(shake_y - hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	surface.SetMaterial(HitMaterial.L2)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x - hitScale.x)), y + ScreenScale(0.325*(shake_y + hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	surface.SetMaterial(HitMaterial.R1)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x)), y + ScreenScale(0.325*(shake_y - hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
	surface.SetMaterial(HitMaterial.R2)
	surface.DrawTexturedRectRotated(x + ScreenScale(0.325*(shake_x + hitScale.x)), y + ScreenScale(0.325*(shake_y + hitScale.y)), ScreenScale(55*0.325)*scaleMul, ScreenScale(55*0.325)*scaleMul, S.hit)
end)