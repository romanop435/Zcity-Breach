local CurTime = CurTime;
local pairs = pairs;
local concommand = concommand;
local hook = hook;
local util = util
local net = net


util.AddNetworkString("GASMASK_RequestToggle")
util.AddNetworkString("GASMASK_Remove")
util.AddNetworkString("GASMASK_SendEquippedStatus")

local meta = FindMetaTable("Player")
function meta:GASMASK_RequestToggle()
	net.Start("GASMASK_RequestToggle")
		net.WriteBool(self.GASMASK_Equiped)
	net.Send(self)
	local model
	if self:GTeam() == TEAM_GUARD or self:GetUsingCloth() == "armor_mtf" then
		model = "models/cultist/humans/mog/mask/mask_gasmask.mdl"
	else
		model = "models/gmod4phun/w_contagion_gasmask_equipped.mdl"
	end
	if self.GASMASK_Equiped then
		if self:GTeam() != TEAM_SPEC or self:GTeam() != TEAM_SCP && self:Alive() && self:Health() > 0 then
			if self:GTeam() == TEAM_GUARD or self:GTeam() == TEAM_SECURITY or self:GTeam() == TEAM_CLASSD or self:GTeam() == TEAM_SCI or self:GetRoleName() == role.ClassD_GOCSpy or self:GetRoleName() == role.SCI_SpyDZ or self:GetRoleName() == role.SECURITY_Spy then
			    GhostBoneMerge(self, model)
			elseif self:GetModel() == "models/cultist/humans/obr/obr.mdl" then
				self:SetBodygroup(0, 1)
			end
		end
	elseif !self:IIHasWeapon("gasmask") then
		if ( self.GhostBoneMergedEnts ) then

			for _, v in ipairs( self.GhostBoneMergedEnts ) do
	
				if ( v && v:IsValid() ) then

					if ( v:GetModel() == model ) then
	
						v:Remove()
					end
				end
			end

		end
		if self:GetModel() == "models/cultist/humans/obr/obr.mdl" then
			self:SetBodygroup(0, 0)
		end

	else
		if ( self.GhostBoneMergedEnts ) then

			for _, v in ipairs( self.GhostBoneMergedEnts ) do
	
				if ( v && v:IsValid() ) then

					if ( v:GetModel() == model ) then
	
						v:Remove()
					end
				end
			end

		end
		if self:GetModel() == "models/cultist/humans/obr/obr.mdl" then
			self:SetBodygroup(0, 0)
		end
	end
end

function meta:GASMASK_SetEquipped(b)
	self.GASMASK_Equiped = b
	net.Start("GASMASK_SendEquippedStatus")
		net.WriteBool(b)
	net.Send(self)
end

hook.Add("PlayerSpawn", "GASMASK_PlayerSpawn", function(ply)
	ply.GASMASK_Ready = true
	ply:GASMASK_SetEquipped(false)
end)

hook.Add("PostPlayerDeath", "GASMASK_PostDeath", function(ply)
	ply:GASMASK_SetEquipped(false)
end)

local gasmask_class = "gasmask"
concommand.Add("g4p_gasmask_toggle", function(ply)
	if !ply.GASMASK_Ready then return end

	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	
	if wep:GetClass() != gasmask_class then
		if !ply.GASMASK_SpamDelay or ply.GASMASK_SpamDelay < CurTime() then
			ply.GASMASK_SpamDelay = CurTime() + 0.75
			ply.GASMASK_LastWeapon = wep
			ply:StripWeapon(gasmask_class)
			ply:SetSuppressPickupNotices(true)
			ply:Give(gasmask_class).GASMASK_SignalForDeploy = true
			ply:SetSuppressPickupNotices(false)
			ply:SelectWeapon(gasmask_class)
		end
	end
end)
