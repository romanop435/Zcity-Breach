include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("AlphaWarheadTimer_CLIENTSIDE")

function ENT:Initialize()
 
	self:SetModel( "models/props_debris/metal_panel01a.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	
	

	if SERVER then self:SetUseType( SIMPLE_USE ) end
end

function ENT:PlaySound(snd)
	local filt = RecipientFilter()
	filt:AddAllPlayers()

	self.NukeSound = CreateSound(game.GetWorld(), snd, filt)
	self.NukeSound:ChangeVolume(2)
	self.NukeSound:SetSoundLevel(0)

	self.NukeSound:Play()
end

function ENT:Use(activator, caller)
	if timer.Exists("O5Warhead_Start") then return end
	
	if GetGlobalBool("Evacuation", false) then return end
	if preparing then return end
	if postround then return end
	if !timer.Exists("EvacuationWarhead") then return end
	if !timer.Exists("Evacuation") then return end
	if caller:GTeam() == TEAM_SCP then return end

	Additionaltime = Additionaltime || 0

	if activator:GetModel():find("/goc/") then
		
		if self:GetActivated() then return end
		
		
		
		
		for i, v in player.Iterator() do
			if v:GTeam() == TEAM_GOC then
				v:AddToStatistics("l:activated_warhead", 100 )
			end
		end
		hook.Run("BreachLog_EnableGocNuke", activator)
		
		
		self:SetActivated(true)
		self.activator = activator
		local monitor = ents.Create("alphawarhead_monitor")
		monitor:Spawn()
		
		
		self:PlaySound("nextoren/sl/warheadcrank.ogg")
		

		if self:GetDeactivationTime() == 0 then BroadcastPlayMusic(BR_MUSIC_GOC_NUKE) end

		timer.Pause("RoundTime")
		timer.Pause("Evacuation")
		timer.Pause("EvacuationWarhead")
		timer.Pause("EndRound_Timer")

		Shaky = Shaky || {}
		Shaky.RoundStats = Shaky.RoundStats || {}
		Shaky.RoundStats.ActivatedTimes = ( Shaky.RoundStats.ActivatedTimes || 0 ) + 1

		SetGlobalBool( "NukeTime", true )

		timer.Create("AlphaWarhead_Start", 12, 1, function()
			local tim = self:GetDeactivationTime()
			local domus = true
			if tim == 0 then
				
				
				self:PlaySound("nextoren/round_sounds/main_decont/final_nuke.mp3")
				self:SetDeactivationTime(133)

			elseif tim > 70 and tim <= 80 then
				self:PlaySound("nextoren/sl/Resume80.ogg")
				self:SetDeactivationTime(80)
			elseif tim > 60 and tim <= 70 then
				self:PlaySound("nextoren/sl/Resume70.ogg")
				self:SetDeactivationTime(70)
			elseif tim > 50 and tim <= 60 then
				self:PlaySound("nextoren/sl/Resume60.ogg")
				self:SetDeactivationTime(60)
			elseif tim > 40 and tim <= 50 then
				self:PlaySound("nextoren/sl/Resume50.ogg")
				self:SetDeactivationTime(50)
			elseif tim > 30 and tim <= 40 then
				self:PlaySound("nextoren/sl/Resume40.ogg")
				self:SetDeactivationTime(40)
			elseif tim <= 30 then
				self:PlaySound("nextoren/sl/Resume30.ogg")
				self:SetDeactivationTime(30)
			else
				self:PlaySound("nextoren/sl/Resume90.ogg")
				self:SetDeactivationTime(90)
			end
			SetGlobalBool( "NukeTime", true )
			SetGlobalBool( "Evacuation_HUD", true )
			for _, ply in player.Iterator() do ply:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "l:goc_nuke_start", color_white) end
			timer.Create("GOC_EVACUATION_SEQUENCE", self:GetDeactivationTime() - 6, 1, function()
				if timer.Exists("AlphaWarhead_Begin") then
					
					for i, v in player.Iterator() do
						if v:GTeam() == TEAM_GOC then
							ParticleEffectAttach("mr_portal_1a_ff", PATTACH_POINT_FOLLOW, v, v:LookupAttachment("waist"))
							timer.Simple(2.6, function()
								if IsValid(v) and v:GTeam() == TEAM_GOC and v:Alive() then
									net.Start("ThirdPersonCutscene")
									net.WriteUInt(3, 4)
									net.WriteBool(true)
									net.Send(v)
									v:SetForcedAnimation("MPF_Deploy", 2, function() ParticleEffectAttach("mr_portal_1a", PATTACH_POINT_FOLLOW, v, v:LookupAttachment("waist")) v:EmitSound("nextoren/others/introfirstshockwave.wav", 115, 100, 1.4) v:GodEnable() end, function()
										v:GodDisable()
										v:AddToStatistics("l:escaped", 160 * tonumber("1."..tostring(v:GetNLevel() * 2)) )
										v:LevelBar()
										v:SetupNormal()
										v:SetSpectator()
										
									end, nil)
								end
							end)
						end
					end
				end
			end)
			timer.Create("AlphaWarhead_Begin", self:GetDeactivationTime(), 1, function()
				for i, v in player.Iterator() do
					if v:GTeam() != TEAM_SPEC && v:Alive() && v:Health() > 0 && v:GTeam() != TEAM_GOC then
						v:AddToStatistics("l:detonated_warhead_for_non_goc", -500)
						
						v:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
						timer.Simple(1, function()
							if IsValid(v) && v:GTeam() != TEAM_SPEC && v:Alive() && v:Health() > 0 && v:GTeam() != TEAM_GOC then
								v:LevelBar()
								v:SetupNormal()
								v:SetSpectator()
							end
						end)
					end
				end

				

				hook.Run("BreachLog_GocNukeDetonation")
				AlphaWarheadBoomEffect()
				net.Start("AlphaWarheadTimer_CLIENTSIDE")
				net.WriteString("")
				net.WriteBool(true)
				net.Broadcast()
				SetGlobalBool("NukeTime", false)
				if IsValid(self.activator) then self.activator:CompleteAchievement("bigboom") end
				Breach_EndRound("l:roundend_GOCNUKE")
			end)

			net.Start("AlphaWarheadTimer_CLIENTSIDE")
			net.WriteString(tostring(math.floor(timer.TimeLeft("AlphaWarhead_Begin"))))
			net.WriteBool(false)
			net.Broadcast()

		end)

	elseif !activator:GetModel():find("goc.mdl") and self:GetDeactivationTime() > 22 and GetGlobalBool("NukeTime", false) then
		hook.Run("BreachLog_DisableGocNuke", activator)
		
		
		for i, v in pairs(ents.FindByClass("alphawarhead_monitor")) do
			if IsValid(v) then v:Remove() end
		end
		SetGlobalBool( "NukeTime", false )
		SetGlobalBool( "Evacuation_HUD", false )
		timer.Remove("AlphaWarhead_Begin")
		timer.Remove("AlphaWarhead_Start") 
		timer.Remove("GOC_EVACUATION_SEQUENCE")

		timer.UnPause("RoundTime")
		timer.UnPause("Evacuation")
		timer.UnPause("EvacuationWarhead")
		timer.UnPause("EndRound_Timer")

		self:SetActivated(false)

		
		net.Start("AlphaWarheadTimer_CLIENTSIDE")
		net.WriteString("")
		net.WriteBool(true)
		net.Broadcast()

		BREACH.SendClientEvent(nil, "set_cltime", {value = timer.TimeLeft("RoundTime")})

		BroadcastStopMusic()
		self.NukeSound:Stop()
		
			net.Start("ForcePlaySound")
			net.WriteString("nextoren/round_sounds/intercom/goc_nuke_cancel.mp3")
			net.Broadcast()
		

	end

end

local checkcd = checkcd || 0
function ENT:Think()

	if checkcd > CurTime() then return end
	checkcd = CurTime() + 1

	if timer.Exists("AlphaWarhead_Begin") then
		self:SetDeactivationTime(math.floor(timer.TimeLeft("AlphaWarhead_Begin")))
	end

end