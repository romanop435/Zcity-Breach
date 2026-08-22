VoiceChatMeter = {
    IsTTT = false,
    DarkRPSelfSquare = false,
    SizeX = 250,
    SizeY = 40,
    FontSize = 17,
    Radius = 4,
    FadeAm = 0.1,
    SlideOut = true,
    SlideTime = 0.1,
    PosX = 0.97,
    PosY = 0.76,
    Align = 0,
    StackUp = true,
    UseTags = true,
    Tags = {}
}


local surface = surface
local Material = Material
local draw = draw

surface.CreateFont( "Jack_VoiceFont", {
 font = "Arial",
 size = VoiceChatMeter and VoiceChatMeter.FontSize or 17,
 weight = 550,
 antialias = true,
 shadow = true,
 outline = true
} )

local isgradientenabled = CreateClientConVar("br_gradient_voice_chat", 0, true, false, "", 0, 1)
local shouldshowchars = CreateClientConVar("br_voicechat_showalive", 1, true, false, "", 0, 1)

local rust_bg       = Color(18, 16, 15, 240)
local rust_panel    = Color(30, 28, 25, 255)
local rust_outline  = Color(255, 255, 255, 10)
local rust_yellow   = Color(218, 165, 32)
local rust_red      = Color(188, 64, 43)
local rust_green    = Color(112, 126, 73)
local rust_text     = Color(230, 230, 230)
local rust_dim      = Color(140, 140, 140)

local clr_white_gray = Color(210, 210, 210)

local emoticons = {
	["spectator"] = Material("icon16/rosette.png"),
	["headadmin"] = Material("icon16/fire.png"),
	["admin"]     = Material("icon16/shield.png"),
	["premium"]   = Material("icon16/medal_gold_1.png"),
}

Jack = Jack or {}
Jack.Talking = Jack.Talking or {}

local function PickColorForPlayer(ply)
	local color = gteams.GetColor(ply:GTeam())
	if not isgradientenabled:GetBool() then return false end
	
	if ply:GTeam() == TEAM_SPEC then 
		if ply:IsAdmin() and ply:IsSuperAdmin() then return rust_red else return Color(255,255,255,0) end 
	end
	if ply:GTeam() == TEAM_SCP then return gteams.GetColor(TEAM_SCP) end
	if LocalPlayer():GTeam() == TEAM_GOC and ply:GTeam() == TEAM_GOC then return gteams.GetColor(TEAM_GOC) end
	if (LocalPlayer():GTeam() == TEAM_SCP or LocalPlayer():GTeam() == TEAM_DZ) and ply:GTeam() == TEAM_DZ then return gteams.GetColor(TEAM_DZ) end
	if LocalPlayer():GTeam() == TEAM_CHAOS and ply:GTeam() == TEAM_CHAOS then return gteams.GetColor(TEAM_CHAOS) end
	
	if ply:GetModel():find("/goc/") then color = gteams.GetColor(TEAM_GOC) end
	if ply:GetModel():find("/sci/") and ply:GTeam() ~= TEAM_GUARD then color = gteams.GetColor(TEAM_SCI) end
	if ply:GetModel():find("class_d_cleaner") then return gteams.GetColor(TEAM_SCI) end
	if ply:GetModel():find("/class_d/") then color = gteams.GetColor(TEAM_CLASSD) end
	if ply:GetModel():find("/mog/") then color = gteams.GetColor(TEAM_GUARD) end
	if ply:GetModel():find("/security/") then color = gteams.GetColor(TEAM_CB) end
	if ply:GTeam() == TEAM_USA then color = color_white end

	return color
end

function Jack.StartVoice(ply)
	if not IsValid(ply) or not ply.GTeam then return false end
	if ply:GTeam() ~= TEAM_SCP and ply:GTeam() ~= TEAM_SPEC and (not LocalPlayer():IsAdmin() or LocalPlayer():GTeam() ~= TEAM_SPEC) and ply ~= LocalPlayer() then return false end
	if ply:GTeam() == TEAM_SCP and LocalPlayer():GTeam() ~= TEAM_SCP and LocalPlayer():GTeam() ~= TEAM_SPEC then return false end
	if GetConVar("breach_config_screenshot_mode"):GetInt() == 1 then return false end
	if ply:GTeam() ~= TEAM_SPEC and ply:GTeam() ~= TEAM_SCP and not shouldshowchars:GetBool() and ply ~= LocalPlayer() then return false end
	
	for k,v in pairs(Jack.Talking) do if v.Owner == ply then v:Remove() Jack.Talking[k] = nil break end end
	
	if ply ~= LocalPlayer() and LocalPlayer():GTeam() ~= TEAM_SPEC and ply:GTeam() ~= TEAM_SCP and LocalPlayer():GTeam() ~= TEAM_SCP and not LocalPlayer():CanSeeEnt(ply) then return false end
	if ply:GetPos():DistToSqr(LocalPlayer():GetPos()) > 200000 and ply:GTeam() ~= TEAM_SPEC and LocalPlayer():GTeam() ~= TEAM_SCP then return false end

	local plyteam = ply:GTeam()
	local IsSeen = ((LocalPlayer():CanSeeEnt(ply) and not ply:GetNoDraw()) or ply == LocalPlayer() or (ply:GTeam() == TEAM_SCP and LocalPlayer():GTeam() == TEAM_SCP))
	if LocalPlayer():GTeam() == TEAM_SPEC then IsSeen = true end
	
	local CurID = 1
	local client = LocalPlayer()
	local plycol = PickColorForPlayer(ply) or rust_text
	local H = VoiceChatMeter and VoiceChatMeter.SizeY or 45
	local W = 60
	
	local CurName = string.upper(ply:Name())
	local test_width = CurName

	if ply:GetNWBool("prefix_active") and plyteam == TEAM_SPEC then
		test_width = "["..string.upper(ply:GetNWBool("prefix_title", "")).."] "..test_width
	end
	
	surface.SetFont("MogM_6")
	local eqeq, _ = surface.GetTextSize(test_width)
	W = W + eqeq + 25
	W = math.max(W, 260)

	local ToAdd = 0
	if #Jack.Talking ~= 0 then
		for i = 1, #Jack.Talking + 3 do
			if not Jack.Talking[i] or not IsValid(Jack.Talking[i]) then
				ToAdd = -(i - 1) * (H + 4)
				CurID = i
				break
			end
		end
	end

	if VoiceChatMeter and not VoiceChatMeter.StackUp then ToAdd = -ToAdd end

	local NameBar = vgui.Create("DPanel")
	NameBar:SetSize(W, H)
	
	local StartPos = (VoiceChatMeter and VoiceChatMeter.SlideOut and ((VoiceChatMeter.PosX < .5 and -W) or ScrW())) or (ScrW() * (VoiceChatMeter and VoiceChatMeter.PosX or 0.8) - W)
	local TargetPos = ScrW() * (VoiceChatMeter and VoiceChatMeter.PosX or 0.8) - W
	local TargetY = ScrH() * (VoiceChatMeter and VoiceChatMeter.PosY or 0.7) + ToAdd
	
	NameBar:SetPos(StartPos, TargetY)
	NameBar.Owner = ply
	NameBar.Fade = 0

	local avatarSize = H - 8
	local iconSize = 16

	local processedData = { text = CurName, isRainbow = false, flashColor = nil }
	local steamID = ply:SteamID64()
	local tagData = LOUNGE_CHAT and LOUNGE_CHAT.CustomTagsPlayers and LOUNGE_CHAT.CustomTagsPlayers[steamID]

	if tagData and plyteam == TEAM_SPEC then
		local function ProcessTag(tagString)
			local text = tagString
			local isRainbow = false
			local flashColor = nil
			if string.find(tagString, "<rainbow=1>") then
				isRainbow = true
				text = string.match(tagString, "<rainbow=1>(.-)</rainbow>") or text
			end
			local flashMatch = string.match(tagString, "<flash=(%d+),(%d+),(%d+)")
			if flashMatch then
				local r, g, b = string.match(tagString, "<flash=(%d+),(%d+),(%d+)")
				flashColor = Color(tonumber(r), tonumber(g), tonumber(b))
				text = string.match(tagString, "<flash=[%d,]+>(.-)</flash>") or text
			end
			text = string.gsub(text, "<[^>]+>", "")
			text = string.gsub(text, ":[%w_]+:", "")
			return { text = string.upper(text), isRainbow = isRainbow, flashColor = flashColor }
		end
		processedData = ProcessTag(tagData)
	end

	NameBar.Think = function(self)
		if not IsValid(ply) then self:Remove() Jack.Talking[CurID] = nil return end
		if self.Next and CurTime() - self.Next < 0.02 then return end
		self.Next = CurTime()

		if self.fade then
			self.Fade = math.Approach(self.Fade, 0, FrameTime() * 3)
			if self.Fade <= 0 then self:Remove() Jack.Talking[CurID] = nil end
		else
			self.Fade = math.Approach(self.Fade, 1, FrameTime() * 3)
		end

		if VoiceChatMeter and VoiceChatMeter.SlideOut then
			local cx = Lerp(FrameTime() * 8, self.x, self.fade and StartPos or TargetPos)
			self:SetPos(cx, TargetY)
		end
	end

	NameBar.Paint = function(self, w, h)
		local a = self.Fade * 255
		
		surface.SetDrawColor(rust_bg.r, rust_bg.g, rust_bg.b, a)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(rust_panel.r, rust_panel.g, rust_panel.b, a)
		surface.DrawRect(4, 4, avatarSize, avatarSize)

		surface.SetDrawColor(plycol.r, plycol.g, plycol.b, a)
		surface.DrawRect(0, 0, 3, h)

		surface.SetDrawColor(rust_outline.r, rust_outline.g, rust_outline.b, a * 0.5)
		surface.DrawOutlinedRect(0, 0, w, h, 1)

		local vol = math.Clamp(ply:VoiceVolume() * 1.5, 0, 1)
		local barW = w - avatarSize - 20
		local barH = 4
		local barX = 14 + avatarSize
		local barY = h - barH - 6

		surface.SetDrawColor(10, 9, 8, a)
		surface.DrawRect(barX, barY, barW, barH)

		local volColor = rust_green
		if vol > 0.6 then volColor = rust_yellow end
		if vol > 0.9 then volColor = rust_red end

		surface.SetDrawColor(volColor.r, volColor.g, volColor.b, a)
		surface.DrawRect(barX, barY, barW * vol, barH)

		local textX = 14 + avatarSize
		local textY = h / 2 - 12

		local hasIcon = (emoticons[ply:GetUserGroup()] or (RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[ply:SteamID64()])) and plyteam == TEAM_SPEC
		if hasIcon and (ply:GetUserGroup() ~= "premium" or ply:GetNWBool("display_premium_icon", true)) then
			local mat = (RXSEND_YOUTUBERS and RXSEND_YOUTUBERS[ply:SteamID64()]) and Material("icon16/user_red.png") or emoticons[ply:GetUserGroup()]
			if mat then
				surface.SetDrawColor(255, 255, 255, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(textX, textY, iconSize, iconSize)
				textX = textX + iconSize + 6
			end
		end

		local displayCol = rust_text
		local displayName = processedData.text

		if processedData.isRainbow then
			self.Hue = ((self.Hue or 0) + FrameTime() * 100) % 360
			displayCol = HSVToColor(self.Hue, 1, 1)
		elseif processedData.flashColor then
			displayCol = processedData.flashColor
		end

		if plyteam ~= TEAM_SPEC and plyteam ~= TEAM_SCP then
			if IsSeen then
				displayName = string.upper(ply:GetNamesurvivor())
				if LocalPlayer():IsAdmin() and ply ~= LocalPlayer() then displayName = string.upper(ply:Nick()) end
			else
				displayName = "НЕИЗВЕСТНЫЙ"
				if client:GetPos():DistToSqr(ply:GetPos()) > 562500 then displayName = "НЕИЗВЕСТНЫЙ #" .. math.floor(util.SharedRandom(ply:GetNamesurvivor(), 100, 999)) end
				if ply:GetNWBool("IntercomTalking", false) then displayName = "(INTERCOM) НЕИЗВЕСТНЫЙ" end
			end
			displayCol = color_white
		end

		draw.SimpleText(displayName, "MogM_6", textX, textY, ColorAlpha(displayCol, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local Av
	if plyteam == TEAM_SPEC then
		Av = vgui.Create("AvatarImage", NameBar)
		Av:SetPos(4, 4)
		Av:SetSize(avatarSize, avatarSize)
		Av:SetPlayer(ply)
	else
		Av = vgui.Create("DModelPanel", NameBar)
		Av:SetPos(4, 4)
		Av:SetSize(avatarSize, avatarSize)
		
		if IsSeen then
			Av:SetModel(ply:GetModel())
			Av.Entity:SetSkin(ply:GetSkin() or 0)
			for i = 0, 9 do Av.Entity:SetBodygroup(i, ply:GetBodygroup(i) or 0) end
		else
			Av:SetModel("models/cultist/humans/class_d/class_d.mdl")
			Av.Entity:SetMaterial("lights/white001")
			Av.Entity:SetColor(clr_white_gray)
		end

		local iSeq = Av.Entity:LookupSequence("idle_all_01")
		if iSeq > 0 then Av.Entity:ResetSequence(iSeq) end
		Av:SetFOV(15)

		Av.Paint = function(self, w, h)
			if not IsValid(self.Entity) then return end
			render.SetBlend(NameBar.Fade)
			DModelPanel.Paint(self, w, h)
			render.SetBlend(1)
		end

		Av.LayoutEntity = function(self, ent)
			ent:SetAngles(Angle(0, 45, 0))
			if IsValid(ply) then
				local vol = ply:VoiceVolume()
				local jaw = ent:LookupBone("ValveBiped.Bip01_Jaw")
				if jaw then ent:ManipulateBoneAngles(jaw, Angle(0, 0, -vol * 30)) end
			end
		end

		local eyepos = Av.Entity:GetBonePosition(Av.Entity:LookupBone("ValveBiped.Bip01_Head1") or 0)
		if not isnumber(Av.Entity:LookupBone("ValveBiped.Bip01_Head1")) then 
			local att = Av.Entity:LookupAttachment("eyes")
			eyepos = att and Av.Entity:GetAttachment(att) and Av.Entity:GetAttachment(att).Pos or Vector(0,0,0) 
		end

		eyepos:Add(Vector(0, 0, 2))	
		Av:SetLookAt(eyepos)
		Av:SetCamPos(eyepos - Vector(-55, 0, 0))
		Av.Entity:SetEyeTarget(eyepos - Vector(-55, 0, 0))

		local bnmrgtable = ents.FindByClassAndParent("ent_bonemerged", ply)
		if not IsSeen then
			local fakeHead = Av:BoneMerged("models/cultist/heads/male/head_main_1.mdl")
			if IsValid(fakeHead) then
				fakeHead:SetMaterial("lights/white001")
				fakeHead:SetColor(clr_white_gray)
			end
		elseif istable(bnmrgtable) then
			for _, bnmrg in pairs(bnmrgtable) do
				if not IsValid(bnmrg) then continue end
				local headface = bnmrg:GetSubMaterial(0)
				if CORRUPTED_HEADS and CORRUPTED_HEADS[bnmrg:GetModel()] then headface = bnmrg:GetSubMaterial(1) end
				Av:BoneMerged(bnmrg:GetModel(), headface, bnmrg:GetInvisible(), bnmrg:GetSkin())
			end
		end

		if ply:GTeam() == TEAM_SCP and not ply:GetModel():find("/scp/") and Av.MakeZombie then 
			Av:MakeZombie() 
		end
	end

	Jack.Talking[CurID] = NameBar
	return false
end
hook.Add("PlayerStartVoice", "Jack's Voice Meter Addon Start", Jack.StartVoice)

function Jack.EndVoice(ply)
	for k,v in pairs(Jack.Talking) do if v.Owner == ply then Jack.Talking[k].fade = true break end end

	if DarkRP and ply == LocalPlayer() then
		hook.Remove("Think", "DarkRP_chatRecipients")
		hook.Remove("HUDPaint", "DarkRP_DrawChatReceivers")
		ply.DRPIsTalking = false
	end

	if (VOICE and VOICE.SetStatus) then
		if IsValid(ply) and not no_reset then ply.traitor_gvoice = false end
		if ply == LocalPlayer() then VOICE.SetSpeaking(false) end
	end
end
hook.Add("PlayerEndVoice", "Jack's Voice Meter Addon End", Jack.EndVoice)

hook.Add("HUDShouldDraw", "Remove old voice cards", function(elem) 
	if elem == "CHudVoiceStatus" or elem == "CHudVoiceSelfStatus" then return false end 
end)
