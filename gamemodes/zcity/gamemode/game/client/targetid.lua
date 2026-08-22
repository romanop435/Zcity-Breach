local surface = surface
local Material = Material
local draw = draw
local table = table;
local hook = hook;
local draw = draw;
local util = util
local player = player



function GM:HUDDrawTargetID()
end

local cam = cam
local surface = surface
local draw = draw

local szmat = Material("icon16/star.png")
local offset = Vector( 0, 0, 85 )
local angletobeedited = Angle(0, 0, 90)
local nicknamecolor = Color( 255, 255, 255, 220 )
local LocalPlayer = LocalPlayer
local role = role



local function DrawTargetID()
	local client = LocalPlayer()

	if client:GTeam() == TEAM_SPEC then return end
	if GetConVar("breach_config_screenshot_mode"):GetInt() == 1 then return end

	local eyePos = client:EyePos()
	local aimVec = client:GetAimVector()

	for _, ply in player.Iterator() do
		if ply == client then continue end
		if not IsValid(ply) or not ply:Alive() then continue end
		if ply:GetNoDraw() then continue end

		local plyteam = ply:GTeam()
		if plyteam == TEAM_SCP or plyteam == TEAM_SPEC then continue end

		local plypos = ply:GetPos()
		
		if plypos:DistToSqr(client:GetPos()) > 40000 then continue end

		local dirToPly = (ply:WorldSpaceCenter() - eyePos):GetNormalized()
		local dot = aimVec:Dot(dirToPly)

		if dot < 0.85 then continue end

		local tr = util.TraceLine({
			start = eyePos,
			endpos = ply:WorldSpaceCenter(),
			filter = {client, ply},
			mask = MASK_OPAQUE
		})
		if tr.Hit then continue end
		local ang = client:EyeAngles()
		local pos = plypos + offset + ang:Up()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		angletobeedited["y"] = ang["y"]

		local nickp = ply:GetNamesurvivor()
		if client:IsAdmin() then nickp = nickp .. " ("..ply:Nick()..")" end

		cam.Start3D2D( pos, angletobeedited, 0.1 )
			
			draw.DrawText( nickp, "char_title", 0, 22, nicknamecolor, TEXT_ALIGN_CENTER )
			surface.SetFont("char_title")
			local dlina = surface.GetTextSize(nickp)
			
			if ply:GetRoleName() == role.TG_Com and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "★", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			elseif ply:GetRoleName() == role.TG_Left and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "Ⅴ", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			elseif ply:GetRoleName() == role.TG_SerPlus and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "Ⅳ", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			elseif ply:GetRoleName() == role.TG_Ser and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "Ⅲ", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			elseif ply:GetRoleName() == role.TG_Capral and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "Ⅱ", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			elseif ply:GetRoleName() == role.TG_Nerd and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "Ⅰ", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			elseif ply:GetModel() == "models/cultist/humans/mog/mog.mdl" and client:GTeam() == TEAM_GUARD then
				draw.DrawText( "Ⅲ", "char_title", dlina / 2 , 22, Color(65,103,230), TEXT_ALIGN_LEFT )
			end

		cam.End3D2D()
	end
end







hook.Add( "PostDrawTranslucentRenderables", "DrawTargetID", DrawTargetID )

local scp079 = ClientsideModel( "models/scp079microcom/scp079microcom.mdl" )
scp079:SetNoDraw( true )

local function drawPly(ply)
    local l = LocalPlayer()
    if !IsValid(ply) or !ply:Alive() or !IsValid(ply) then return end

	if ply:HasWeapon('item_scp_079') and ply:GetActiveWeapon() and ply:GetActiveWeapon():GetClass() != "item_scp_079" then
		local boneid = ply:LookupBone( "ValveBiped.Bip01_Spine2" )
		local ammobox_offsetvec = Vector( 6, -7.6, -5 )
		local ammobox_offsetang = Angle( -90, 90, 0 )
		if not boneid then
			return
		end
		
		local matrix = ply:GetBoneMatrix( boneid )
		
		if not matrix then 
			return 
		end
		
		local newpos, newang = LocalToWorld( ammobox_offsetvec, ammobox_offsetang, matrix:GetTranslation(), matrix:GetAngles() )
		
		scp079:SetPos( newpos )
		scp079:SetAngles( newang )
		scp079:SetupBones()
		scp079:DrawModel()
	end
    
end

local plyLoaded = {}
// Trick to prevent name glitching on invisible material
hook.Add("PostPlayerDraw", "ahud_DrawName", function(ply)
    table.insert(plyLoaded, ply)
end)

hook.Add("PostDrawTranslucentRenderables", "ahud_DrawName", function()
    for k, v in ipairs(plyLoaded) do
        drawPly(v)
    end
    plyLoaded = {}
end)