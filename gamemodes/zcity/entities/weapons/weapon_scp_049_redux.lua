if ( CLIENT ) then
	net.Receive( "SCP049_PlayerScreenManipulations", function()
	end )
end

if ( SERVER ) then
	util.AddNetworkString( "SCP049_PlayerScreenManipulations" )
end

if CLIENT then
    net.Receive("SCP049_FreezeGesture", function()
        local ply = net.ReadEntity()
        local seq = net.ReadInt(16)
        
        if not IsValid(ply) or not ply.GetNumAnimLayers then return end
        
        if seq == -1 then
            ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
            return
        end

        local numLayers = ply:GetNumAnimLayers()
        for i = 0, numLayers - 1 do
            if ply:GetLayerSequence(i) == seq then
                ply:SetLayerPlaybackRate(i, 0)
                ply:SetLayerCycle(i, 0.99)
            end
        end
    end)
end

if CLIENT then
CreateMaterial( "ZombieTexture", "VertexLitGeneric", {
	  ["$basetexture"] = "models/cultist/heads/zombie_face",
	  ["$model"] = 1,
	  ["&nocull"] = 1,
	  ["$phong"] = 1,
	  ["$phongboost"] = 0.5,
	  ["$lightwarptexture"] = "models/all_scp_models/shared/Clothes_wrp",
	  ["$phongexponenttexture"] = "models/all_scp_models/shared/exp",
	} )
end

BREACH = BREACH || {}

BREACH.ZombieTextureMaterials = {
	"models/all_scp_models/shared/arms_new",
	"models/all_scp_models/class_d/arms",
	"models/all_scp_models/class_d/arms_b",
	"models/all_scp_models/mog/skin_full_arm_wht_col",
	"models/all_scp_models/class_d/fatheads/fat_head",
	"models/all_scp_models/class_d/fatheads/fat_torso",
	"models/all_scp_models/class_d/body_b",
	"models/all_scp_models/class_d/prisoner_lt_head_d",
	"models/all_scp_models/shared/f_hands/f_hands_white",
	"models/all_scp_models/shared/heads/female/head_1",
	"models/all_scp_models/cultists/vrancis_head",
	"models/all_scp_models/cultists/footmale",
	"models/all_scp_models/sci/shirt_boss",
	"models/all_scp_models/sci/dispatch/dispatch_head",
	"models/all_scp_models/sci/dispatch/dispatch_face",
	"models/all_scp_models/sci/dispatch/skirt",
	"models/all_scp_models/special_sci/special_4/head_sci_4",
	"models/all_scp_models/special_sci/special_4/face_sci_4",
	"models/all_scp_models/special_sci/sci_3_materials/sci_3_head",
	"models/all_scp_models/special_sci/sci_3_materials/sci_3_face",
	"models/all_scp_models/special_sci/arms",
	"models/all_scp_models/special_sci/tex_0160_0",
	"models/all_scp_models/special_sci/sci_2_materials/sci_2_face",
	"models/all_scp_models/special_sci/sci_2_materials/sci_2_head",
	"models/all_scp_models/special_sci/special_1/face_sci_1",
	"models/all_scp_models/special_sci/special_1/head_sci_1",
	"models/all_scp_models/special_sci/sci_7_materials/sci_7_face",
	"models/all_scp_models/special_sci/sci_7_materials/sci_7_head",
	"models/all_scp_models/special_sci/sci_9_materials/sci_9_face",
	"models/all_scp_models/special_sci/sci_9_materials/sci_9_head",
	"models/all_scp_models/special_sci/mutantskin_diff",
	"models/all_scp_models/special_sci/zed_hans_d",
	"models/all_scp_models/special_sci/spes_head"
}

local blacklistrag = {
	"models/cultist/scp/scp_106.mdl",
	"models/cultist/scp/scp_542.mdl"
}

if SERVER then
	local ment = FindMetaTable("Entity")

	function ment:MakeZombieTexture()
		for i, material in pairs(self:GetMaterials()) do
			i = i - 1
			if not table.HasValue(BREACH.ZombieTextureMaterials, material) then
				if string.StartWith(material, "models/all_scp_models/") then
					local str = string.sub(material, #"models/all_scp_models//")
					str = "models/all_scp_models/zombies/"..str
					self:SetSubMaterial(i, str)
				end
			else
				self:SetSubMaterial(i, "!ZombieTexture")
			end
		end
	end

	function ment:MakeZombie()
		self:MakeZombieTexture()
		for _, bnmrg in pairs(self:LookupBonemerges()) do
			if bnmrg:GetModel():find("male_head") or bnmrg:GetModel():find("balaclava") then
				self.FaceTexture = "models/all_scp_models/zombies/shared/heads/head_1_1"
				if CORRUPTED_HEADS and CORRUPTED_HEADS[bnmrg:GetModel()] then
					bnmrg:SetSubMaterial(1, self.FaceTexture)
				else
					bnmrg:SetSubMaterial(0, self.FaceTexture)
				end
			else
				bnmrg:MakeZombieTexture()
			end
		end
	end
end

SWEP.AbilityIcons = {
	{
		["Name"] = "Zombie Buff",
		["Description"] = "Using this ability gives all zombies extra power.",
		["Cooldown"] = "100",
		["CooldownTime"] = 0,
		["KEY"] = "RMB",
		["Using"] = false,
		["Icon"] = "nextoren/gui/special_abilities/scp_049_zombiebuff.png",
		["Abillity"] = nil
	},
}

SWEP.Category = "BREACH SCP"
SWEP.PrintName = "SCP-049"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawCrosshair = false
SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.HoldType = "scp049"
SWEP.Base = "breach_scp_base"
SWEP.AlertWindow = false
SWEP.AbillityID = 0
SWEP.mins = Vector( -8, -10, -5 )
SWEP.maxs = Vector( 8, 10, 5 )

SWEP.droppable = false
SWEP.Primary.Delay = 3
SWEP.Secondary.Delay = 6
SWEP.Outline_Color = Color( 180, 0, 0, 190 )
SWEP.Speed = 110

if SERVER then
	local mply = FindMetaTable("Player")

	function mply:SetupZombie()
		local victim = self
		victim:SetNoDraw(false)
		victim:SetDSP(1)
		victim:SetNWEntity("NTF1Entity", victim)
		victim:SetGTeam(TEAM_SCP)
		victim.IsZombie = true
		victim:Freeze(true)
		victim.ScaleDamage = {
			["HITGROUP_HEAD"] = .35,
			["HITGROUP_CHEST"] = .35,
			["HITGROUP_LEFTARM"] = .35,
			["HITGROUP_RIGHTARM"] = .35,
			["HITGROUP_STOMACH"] = .35,
			["HITGROUP_GEAR"] = .35,
			["HITGROUP_LEFTLEG"] = .35,
			["HITGROUP_RIGHTLEG"] = .35
		}
		victim.Stamina = 100
		victim:SetWalkSpeed(620)
		victim:SetRunSpeed(220)
		victim:SetMaxHealth(victim:GetMaxHealth() * 2)
		victim:SetHealth(victim:GetMaxHealth())
		victim:MakeZombie()
		victim:StripWeapons()
		victim.JustSpawned = true
		victim:Give( "weapon_scp_049_2" )
		timer.Simple( .1, function()
			if IsValid(victim) then victim.JustSpawned = false end
		end)
		victim.MaxStaminaMul = 3.0
		timer.Create("Safe_WEAPON_SELECT_"..victim:SteamID64(), FrameTime(), 99999, function()
			if not IsValid(victim) then return end
			if !IsValid(victim:GetActiveWeapon()) or victim:GetActiveWeapon():GetClass() ~= "weapon_scp_049_2" then
				victim:SelectWeapon("weapon_scp_049_2")
			else
				timer.Remove("Safe_WEAPON_SELECT_"..victim:SteamID64())
			end
			victim:SetWalkSpeed( victim:GetWalkSpeed() * 2 )
		end)
		victim:SetForcedAnimation("breach_zombie_getup", victim:SequenceDuration(victim:LookupSequence("breach_zombie_getup")), nil, function()
			if not IsValid(victim) then return end
			victim:SetMoveType(MOVETYPE_WALK)
			victim:Freeze(false)
			victim:SetNotSolid(false)
			victim:SetNWEntity("NTF1Entity", NULL)
		end)
	end

	util.AddNetworkString("SCP049_FreezeGesture")

	local function PlayAndFreezeGesture(ply, seqName, slot)
		local seq = ply:LookupSequence(seqName)
		if not seq or seq == -1 then return end
		
		local dur = ply:SequenceDuration(seq)
		
		ply:PlayGestureSequence(seqName, slot, false)
		
		local timerName = "SCP049_Freeze_" .. ply:EntIndex()
		timer.Create(timerName, dur - 0.05, 1, function()
			if not IsValid(ply) then return end
			
			local numLayers = ply:GetNumAnimLayers() or 15
			for i = 0, numLayers - 1 do
				if ply:GetLayerSequence(i) == seq then
					ply:SetLayerPlaybackRate(i, 0)
					ply:SetLayerCycle(i, 0.99)
				end
			end
			
			net.Start("SCP049_FreezeGesture")
				net.WriteEntity(ply)
				net.WriteInt(seq, 16)
			net.Broadcast()
		end)
	end

	local function StopFrozenGesture(ply, slot)
		timer.Remove("SCP049_Freeze_" .. ply:EntIndex())
		ply:AnimResetGestureSlot(slot)
		
		net.Start("SCP049_FreezeGesture")
			net.WriteEntity(ply)
			net.WriteInt(-1, 16)
		net.Broadcast()
	end

	hook.Add("PlayerButtonDown", "SCP_049_CONTROLS", function(ply, butt)
		if ply:GetRoleName() ~= "SCP049" then return end
		if butt ~= KEY_E and butt ~= KEY_R then return end

		local rag = ply:GetEyeTrace().Entity
		
		if not IsValid(rag) or rag:GetClass() ~= "prop_ragdoll" then
			local closestDist = 20000
			for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 100)) do
				if ent:GetClass() == "prop_ragdoll" then
					local dist = ent:GetPos():DistToSqr(ply:GetPos())
					if dist < closestDist then
						closestDist = dist
						rag = ent
					end
				end
			end
		end

		if not IsValid(rag) or rag:GetClass() ~= "prop_ragdoll" then return end
		if rag:GetPos():DistToSqr(ply:GetPos()) > 20000 then return end
		if table.HasValue(blacklistrag,rag:GetModel()) then return end
		local age = 0
		if rag.Info and rag.Info.Time then
			age = CurTime() - rag.Info.Time
		else
			local dietime = rag:GetNWInt("DiedWhen", 0)
			if dietime > 0 then
				age = os.time() - dietime
			end
		end

		if age > 240 then
			if ply.RXSENDNotify then ply:RXSENDNotify("Данный труп слишком разложился для воскрешения!") end
			return
		end

		local victim = nil
		for _, v in player.Iterator() do
			if v.lastrag == rag and (not v:Alive() or v:GTeam() == TEAM_SPEC) then
				victim = v
				break
			end
		end

		if not IsValid(victim) then
			local specs = {}
			for _, v in player.Iterator() do
				if (not v:Alive() or v:GTeam() == TEAM_SPEC) and not v.IsZombie and v:GTeam() ~= TEAM_SCP then
					table.insert(specs, v)
				end
			end
			if #specs > 0 then victim = specs[math.random(#specs)] end
		end

		if not IsValid(victim) then
			if ply.RXSENDNotify then ply:RXSENDNotify("Нет свободных душ (наблюдателей) для воскрешения тела.") end
			return
		end

		
		local timerName = "SCP049_ActionCheck_" .. ply:SteamID64()
		
		timer.Create(timerName, 0.1, 0, function()
			if not IsValid(ply) or not ply:Alive() or ply:GetVelocity():Length2D() > 10 then
				--FinishOrFailCallback()
			end
		end)



		if butt == KEY_E then
			ply:BrProgressBar("l:creating_zombie", 5, "nextoren/gui/new_icons/notifications/breachiconfortips.png", rag, false, function()

				
				if not IsValid(victim) or (victim:Alive() and victim:GTeam() ~= TEAM_SPEC) then return end
				
				if ply.AddToAchievementPoint then ply:AddToAchievementPoint("scp049", 1) end
				
				local body = rag
				local victimPly = body:GetOwner()

				if IsValid(victimPly) then
					timer.Remove("PlayerDeathFromBleeding" .. victimPly:SteamID64())
				end

				victim:SetupNormal()
				victim:SetModel(body:GetModel())
				victim:SetSkin(body:GetSkin())
				victim:SetGTeam(body.__Team or TEAM_SCP)
				victim:SetRoleName(body.Role or "SCP0492")
				victim:SetMaxHealth(body.__Health or 300) 
				victim:SetHealth(victim:GetMaxHealth())
				if victim.SetUsingCloth then victim:SetUsingCloth(body.Cloth) end
				if victim.SetNamesurvivor then victim:SetNamesurvivor(body.__Name) end
				
				victim.OldSkin = body.OldSkin
				victim.OldModel = body.OldModel
				victim.OldBodygroups = body.OldBodygroups
				victim:SetWalkSpeed(620) 
				victim:SetRunSpeed(220) 
				victim:SetupHands()
				timer.Remove("Death_Scene"..victim:SteamID())
				victim:SetPos(Vector(body:GetPos().x, body:GetPos().y, GroundPos(body:GetPos()).z))
				
				if istable(body.AmmoData) then
					for ammo, amount in pairs(body.AmmoData) do
						victim:SetAmmo(amount, ammo)
					end
				end

				if body.vtable and body.vtable.Weapons then
					for _, v in pairs(body.vtable.Weapons) do
						if weapons.GetStored(v) then
							victim:BreachGive(v)
						end
					end
				else
					if victim.BreachGive then victim:BreachGive("br_holster") end
				end
			
				for _, bnmrg in pairs(body:LookupBonemerges()) do
					local bnmrg_ent = Bonemerge(bnmrg:GetModel(), victim)
					bnmrg_ent:SetSubMaterial(0, bnmrg:GetSubMaterial(0))
					bnmrg_ent:SetSubMaterial(2, bnmrg:GetSubMaterial(2))
				end
			
				for i = 0, 9 do
					victim:SetBodygroup(i, body:GetBodygroup(i))
				end
			
    			if body.vtable and body.vtable.Items then
    			    victim.Inventory = victim.Inventory or {["Items"] = {}}
    			    victim.Inventory["Items"] = table.Copy(body.vtable.Items)
				
    			    net.Start("SendInventoryDataOper")
    			    net.WriteTable(victim.Inventory)
    			    net.Send(victim)
    			    if victim.MarkInventoryChanged then victim:MarkInventoryChanged() end
    			end
			
				if victim.Give then victim:Give("br_holster") end
				if victim.SelectWeapon then victim:SelectWeapon("br_holster") end
    			victim:SetNWInt("ActiveSlot", 0)
			
    			body:Remove()
			
    			local org = victim.organism
    			if org then
    			    org.blood = 3000
    			    org.wounds = {}
    			    org.arterialwounds = {}
    			    victim:SetNetVar("wounds", {})
    			    victim:SetNetVar("arterialwounds", {})
    			    org.bleed = 0
    			    org.internalBleed = 0
    			    org.pain = 0
    			    org.painadd = 0
    			    org.shock = 0
    			    org.adrenaline = 3
    			    org.pulse = 130
    			    org.heartbeat = 130
    			    org.o2[1] = 30 
    			    org.otrub = false
    			    org.consciousness = 1
    			    org.alive = true
					org.berserkActive2 = true 
				
    			    victim.fullsend = true
    			    if hg and hg.send_organism then
    			        hg.send_organism(org, victim)
    			    end
    			end
			
    			victim:SetNoDraw(false)
    			victim:DrawShadow(true)
				
				if victim.UnSpectate then victim:UnSpectate() end

				victim:SetDSP(1)
				victim:SetNWEntity("NTF1Entity", victim)
				victim:SetGTeam(TEAM_SCP)
				victim.IsZombie = true
				
				victim.ScaleDamage = {
					 ["HITGROUP_HEAD"] = .35,
					 ["HITGROUP_CHEST"] = .35,
					 ["HITGROUP_LEFTARM"] = .35,
					 ["HITGROUP_RIGHTARM"] = .35,
					 ["HITGROUP_STOMACH"] = .35,
					 ["HITGROUP_GEAR"] = .35,
					 ["HITGROUP_LEFTLEG"] = .35,
					 ["HITGROUP_RIGHTLEG"] = .35
				}
				victim.Stamina = 100
				
				victim:SetMaxHealth(victim:GetMaxHealth() * 2)
				victim:SetHealth(victim:GetMaxHealth())
				if victim.MakeZombie then victim:MakeZombie() end
				
				victim.JustSpawned = true
				if victim.Give then victim:Give("weapon_scp_049_2") end
				timer.Simple(0.1, function()
					if IsValid(victim) then victim.JustSpawned = false end
				end)
				
				if victim.CompleteAchievement then victim:CompleteAchievement("scp0492") end
				timer.Simple(2,function()
					victim:SetWalkSpeed( victim:GetWalkSpeed() * 2 )
				end)
				timer.Create("Safe_WEAPON_SELECT_"..victim:SteamID64(), FrameTime(), 99999, function()
					if not IsValid(victim) then return end
					if not IsValid(victim:GetActiveWeapon()) or victim:GetActiveWeapon():GetClass() ~= "weapon_scp_049_2" then
						victim:SelectWeapon("weapon_scp_049_2")
					else
						timer.Remove("Safe_WEAPON_SELECT_"..victim:SteamID64())
					end
				end)
				
				if victim.SetForcedAnimation then
					victim:SetForcedAnimation("breach_zombie_getup", victim:SequenceDuration(victim:LookupSequence("breach_zombie_getup")), nil, function()
						if not IsValid(victim) then return end
						victim:SetMoveType(MOVETYPE_WALK)
						victim:Freeze(false)
						victim:SetNotSolid(false)
						victim:SetNWEntity("NTF1Entity", NULL)
					end)
				end
			end,
    		function()
    			ply:SetForcedAnimation( 616, math.huge, function() ply:SetNWEntity("NTF1Entity", ply) end, function() ply:SetNWEntity("NTF1Entity", NULL) if IsValid(rag) then  end end, function() ply:SetNWEntity("NTF1Entity", NULL) if IsValid(rag) then  end end, true )
    		    	--ply:RXSENDNotify("l:looting_started")
    			end, function()
    		end, true)

		elseif butt == KEY_R then

		end
	end)

end

function SWEP:Deploy()

	self.Owner:DrawViewModel( false )

	if ( SERVER ) then
		self.Owner:DrawWorldModel( false )
		timer.Simple( .25, function()
			if ( ( self and self:IsValid() ) and ( self.Owner and self.Owner:IsValid() ) ) then
				self.Speed = self.Owner:GetWalkSpeed()
			end
		end )
	end

	if ( CLIENT ) then
		local outline_col = self.Outline_Color
		--hook.Add( "PreDrawOutlines", "SCP049_BodyOutline", function()
		--	local client = LocalPlayer()
	end

  self:SetHoldType( self.HoldType )

end

local vec_zero = vector_origin

function SWEP:VictimOverlay( target )
	target:SetNWEntity( "NTF1Entity", NULL )
	self.Owner:SetNWEntity( "NTF1Entity", NULL )

	for _, v in pairs( ents.FindInSphere( target:GetPos(), 40 ) ) do
		if ( v:GetClass() == "prop_ragdoll" and v:GetVictimHealth() ) then
			target:SetNWEntity( "NTF1Entity", v )

			if ( SERVER ) then
				net.Start( "SCP049_PlayerScreenManipulations" )
					net.WriteUInt( 0, 2 )
					net.WriteBool( true )
				net.Send( target )

				if ( target:IsFemale() ) then
					net.Start( "ForcePlaySound" )
						net.WriteString( "nextoren/charactersounds/breathing/breathing_female.wav" )
					net.Send( target )
				else
					net.Start( "ForcePlaySound" )
						net.WriteString( "nextoren/others/player_breathing_knockout01.wav" )
					net.Send( target )
				end
			end
		end
	end
end

function SWEP:GrabVictim( victim )
	self.GesturePlaying = nil
	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )

	if ( CLIENT ) then return end

	local activeweapon = victim:GetActiveWeapon()

	if ( activeweapon != NULL ) then
  		activeweapon:SetNoDraw( true )
	end

	victim:SetMoveType( MOVETYPE_OBSERVER )
	self.Owner:SetMoveType( MOVETYPE_OBSERVER )

	local uniqueID = "GetBothStatus" .. self.Owner:EntIndex()

	timer.Create( uniqueID, 0, 0, function()

		if ( not ( victim and victim:IsValid() ) or victim:Health() <= 0 ) then
			if IsValid(self.Owner) then
				self.Owner:StopForcedAnimation()
				self.Owner:Freeze( false )
				self.Owner:SetMoveType( MOVETYPE_WALK )
				self.Owner:SetNWAngle( "ViewAngles", angle_zero )
				self.Owner:SetNWEntity( "NTF1Entity", NULL )
			end

			if IsValid(victim) then
				victim:StopForcedAnimation()
				victim:Freeze( false )
				victim:SetDSP( 1 )

				net.Start( "SCP049_PlayerScreenManipulations" )
					net.WriteUInt( 2, 2 )
					net.WriteBool( false )
				net.Send( victim )

				victim:SetNWAngle( "ViewAngles", angle_zero )
				victim:SetNWEntity( "NTF1Entity", NULL )
			end

			timer.Remove( uniqueID )
			return
		end

		if ( not ( self and self:IsValid() ) or not ( self.Owner and self.Owner:IsValid() ) or self.Owner:Health() <= 0 ) then
			if ( victim and victim:IsValid() ) then
				victim:StopForcedAnimation()
				victim:Freeze( false )
				victim:SetNWEntity( "NTF1Entity", NULL )
				victim:SetDSP( 1 )
				victim:SetNWAngle( "ViewAngles", angle_zero )

				net.Start( "SCP049_PlayerScreenManipulations" )
					net.WriteUInt( 2, 2 )
					net.WriteBool( false )
				net.Send( victim )
			end

			if IsValid(self.Owner) then
				self.Owner:StopForcedAnimation()
				self.Owner:Freeze( false )
				self.Owner:SetMoveType( MOVETYPE_WALK )
				self.Owner:SetNWAngle( "ViewAngles", angle_zero )
				self.Owner:SetNWEntity( "NTF1Entity", NULL )
			end

			timer.Remove( uniqueID )
			return
		end

	end )

	victim:Freeze( true )
	self.Owner:Freeze( true )

	victim:SetNWEntity( "NTF1Entity", victim )
	self.Owner:SetNWEntity( "NTF1Entity", self.Owner )

	self.Owner:SetForcedAnimation( "0_049_struggle_start", 1.3, nil, function()
		if not IsValid(self.Owner) then return end
		self.Owner:GodEnable()

		self.Owner:SetForcedAnimation( "0_049_struggle_loop", 4, nil, function()
			if not IsValid(self.Owner) then return end
			self.Owner:SetForcedAnimation( "0_049_struggle_end", 1.5, nil, function()
				if not IsValid(self.Owner) then return end
				self.Owner:GodDisable()

				self.Owner:SetNWAngle( "ViewAngles", angle_zero )
				if IsValid(victim) then victim:SetNWAngle( "ViewAngles", angle_zero ) end

				self.Owner:SetMoveType( MOVETYPE_WALK )
				self.Owner:Freeze( false )

				timer.Remove( uniqueID )
			end )
		end )
	end )

	victim:SetForcedAnimation( "0_049_victum_struggle_start", 1.3, nil, function()
		if not IsValid(victim) then return end
		victim:GodEnable()

		victim:SetDSP( 16 )
		net.Start( "SCP049_PlayerScreenManipulations" )
			net.WriteUInt( 1, 2 )
			net.WriteBool( true )
		net.Send( victim )

		victim:SetForcedAnimation( "0_049_victum_struggle_loop", 4, nil, function()

			timer.Simple( victim:SequenceDuration( 5443 ) - .1, function()
				if IsValid(victim) and victim:Alive() then
					victim:StopForcedAnimation()
					victim:GodDisable()
					
					net.Start( "SCP049_PlayerScreenManipulations" )
						net.WriteUInt( 2, 2 )
						net.WriteBool( false )
					net.Send( victim )

					local attacker = (IsValid(self) and IsValid(self.Owner)) and self.Owner or game.GetWorld()
					local inflictor = IsValid(self) and self or game.GetWorld()
					
					local d = DamageInfo()
					d:SetDamage(victim:GetMaxHealth() * 2)
					d:SetAttacker(attacker)
					d:SetInflictor(inflictor)
					d:SetDamageType(DMG_SLASH)
					victim:TakeDamageInfo(d)
				end
			end )

			victim:SetForcedAnimation( "0_049_victum_struggle_end", 1.5, nil, function() end )

		end )
	end  )

	timer.Simple( .1, function()
		if not IsValid(victim) or not IsValid(self.Owner) then return end

		victim:SetNWAngle( "ViewAngles", ( victim:GetShootPos() - self.Owner:EyePos() ):Angle() )
		self.Owner:SetNWAngle( "ViewAngles", ( victim:GetShootPos() - self.Owner:EyePos() ):Angle() )

		local shoot_pos = self.Owner:GetShootPos()
		local vec_pos = shoot_pos + ( victim:GetShootPos() - self.Owner:EyePos() ):Angle():Forward() * 1.5

		vec_pos.z = GroundPos( vec_pos ).z

		victim:SetPos( vec_pos )

		timer.Simple( .25, function()
			if ( victim and victim:IsValid() and victim:Health() > 0 ) then
				victim:SetPos( vec_pos )
			end
		end )
	end )
end

if ( SERVER ) then
	function SWEP:PlayHandGesture( play )
		if ( !self.OldGestureBool ) then
			self.OldGestureBool = play
		end

		if ( self.OldGestureBool ~= play ) then
			local gesture_id = play and 5250 or 5251

			net.Start( "GestureClientNetworking" )
				net.WriteEntity( self.Owner )
				net.WriteUInt( gesture_id, 13 )
				net.WriteUInt( GESTURE_SLOT_CUSTOM, 3 )
				net.WriteBool( true )
			net.Broadcast()

			if ( play ) then
				timer.Simple( self.Owner:SequenceDuration( 5250 ) - .2, function()
					net.Start( "GestureClientNetworking" )
						net.WriteEntity( self.Owner )
						net.WriteUInt( 5252, 13 )
						net.WriteUInt( GESTURE_SLOT_CUSTOM, 3 )
						net.WriteBool( false )
					net.Broadcast()
				end )
			end

			self.OldGestureBool = play
		end
	end
end

SWEP.NextVoiceLine = 0
SWEP.NextGestureCheck = 0

function SWEP:VoiceLine( s_sound )
  if ( self.Voice_Line and self.Voice_Line:IsPlaying() ) then
    self.Voice_Line:Stop()
  end

  self.Voice_Line = CreateSound( self.Owner, s_sound )
  self.Voice_Line:SetDSP( 17 )
  self.Voice_Line:Play()
end

if ( SERVER ) then

	local mply = FindMetaTable("Player")
	if not mply.PlayGestureSequence then
		function mply:PlayGestureSequence(sequence, slot, autokill, cycle)
			if isstring(sequence) then sequence = self:LookupSequence(sequence) end
			if autokill == nil then autokill = true end
			if slot == nil then slot = GESTURE_SLOT_CUSTOM end
			if cycle == nil then cycle = 0 end

			if not sequence or sequence == -1 then return end

			self:AddVCDSequenceToGestureSlot(slot, sequence, cycle, autokill)

			local str = self:GetSequenceName(sequence)

			net.Start( "GestureClientNetworking" )
				net.WriteEntity( self )
				net.WriteString( str )
				net.WriteUInt( slot, 3 )
				net.WriteBool( autokill )
				net.WriteFloat(cycle)
			net.Broadcast()
		end
	end

	local friendly_teams = {
		[ TEAM_SPEC ] = true,
		[ TEAM_DZ ] = true,
		[ TEAM_SCP ] = true
	}

	function SWEP:Think()
		if ( ( self.t_NextThink or 0 ) > CurTime() ) then return end
		self.t_NextThink = CurTime() + 0.3

		if self.Owner:GetMoveType() == MOVETYPE_WALK then
			self.Owner:SetNWEntity("NTF1Entity", NULL)
		end

		if ( self.Owner:GetMoveType() == MOVETYPE_OBSERVER ) then return end

		local entities = ents.FindInSphere( self.Owner:GetPos(), 600 )
		local has_infected_target = false

		for _, v in ipairs( entities ) do
			if ( v:IsPlayer() and not friendly_teams[ v:GTeam() ] and self.Owner:IsLineOfSightClear( v ) and not v:GetNoDraw() ) then
				
				if v:GetNWBool("HasPestilence", false) and not IsValid(v:GetNWEntity("FakeRagdoll")) then
					has_infected_target = true
				end

				if ( self.NextVoiceLine < CurTime() ) then
					self.NextVoiceLine = CurTime() + 60
					self:VoiceLine( "nextoren/scp/049/spotted" .. math.random( 1, 7 ) .. ".ogg" )
				end
			end
		end

		if has_infected_target then
			self.Owner:SetWalkSpeed( self.Speed * 1.5 )
			self.Owner:SetRunSpeed( self.Speed * 1.5 )
			
			if not self.IsChasing then
				self.IsChasing = true
				
				self.Owner:PlayGestureSequence("0_049_hand_up_gesture", GESTURE_SLOT_CUSTOM, true)

				local anim_id = self.Owner:LookupSequence("0_049_hand_up_gesture")
				local dur = (anim_id and anim_id ~= -1) and self.Owner:SequenceDuration(anim_id) or 0.5
				
				timer.Create("SCP049_GestureLoop_" .. self.Owner:EntIndex(), dur, 1, function()
					if IsValid(self) and IsValid(self.Owner) and self.IsChasing then
						self.Owner:PlayGestureSequence("0_049_hand_gesture", GESTURE_SLOT_CUSTOM, false)
					end
				end)
			end
		else
			self.Owner:SetWalkSpeed( self.Speed )
			self.Owner:SetRunSpeed( self.Speed )
			
			if self.IsChasing then
				self.IsChasing = false

				timer.Remove("SCP049_GestureLoop_" .. self.Owner:EntIndex())

				self.Owner:PlayGestureSequence("0_049_hand_down_gesture", GESTURE_SLOT_CUSTOM, true)
			end
		end
	end

	function SWEP:Holster()
		if IsValid(self.Owner) then
			timer.Remove("SCP049_GestureLoop_" .. self.Owner:EntIndex())
			if self.IsChasing then
				self.Owner:PlayGestureSequence("0_049_hand_down_gesture", GESTURE_SLOT_CUSTOM, true)
				self.IsChasing = false
			end
		end
		return true
	end

	function SWEP:OnRemove()
		if IsValid(self.Owner) then
			timer.Remove("SCP049_GestureLoop_" .. self.Owner:EntIndex())
		end
	end
end

local prim_maxs =  Vector( 12, 4, 32 )

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + 1 )

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 90
	trace.filter = self.Owner
	trace.mins = -prim_maxs
	trace.maxs = prim_maxs

	trace = util.TraceHull( trace )

	local target = trace.Entity

	if ( not ( target and target:IsValid() ) ) then return end

	if ( target.IsZombie ) then
		self.Owner:SetHealth( math.min( self.Owner:Health() + target:Health(), self.Owner:GetMaxHealth() ) )
		target:Kill()
		return
	end


	if ( target:IsPlayer() and target:Health() > 0 and target:GTeam() ~= TEAM_SCP and target:GetMoveType() ~= MOVETYPE_OBSERVER and not self.ForceAnimSequence ) then

		if target:GetNWBool("HasPestilence", false) then
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

			if ( SERVER ) then
				self:VoiceLine( "nextoren/scp/049/kidnap" .. math.random( 1, 2 ) .. ".ogg" )
			end

			self.NextGestureCheck = CurTime() + 8
			self:GrabVictim( target )

		else
			self:SetNextPrimaryFire( CurTime() + 1 )

			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

			if SERVER then
				target:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1, 3) .. ".wav", 75)
				
				local org = target.organism
				if org then
					org.shock = org.shock + 30
					org.painadd = org.painadd + 30
					

					local pushDir = (target:GetPos() - self.Owner:GetPos()):GetNormalized()
					target:SetVelocity(pushDir * 200)

					target:Notify("Его прикосновение обжигает разум...", 5, "049_touch", 0, nil, Color(255, 0, 0))
				end
			end
		end

	end

end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire( CurTime() + self.AbilityIcons[ 1 ].Cooldown )

	self.AbilityIcons[ 1 ].CooldownTime = CurTime() + tonumber( self.AbilityIcons[ 1 ].Cooldown )

	if ( CLIENT ) then return end

	local players = player.GetAll()

	for i = 1, #players do
		local player = players[ i ]

		if ( player.IsZombie and player:Health() > 0 ) then
			player:AnimatedHeal(player:GetMaxHealth() - player:Health())
			player:SetArmor(50)

			timer.Simple( 20, function()
				if ( player and player:IsValid() ) then
					player:SetArmor(0)
				end
			end )
		end
	end
end


if CLIENT then
	local pestilence_mat = Material("sprites/light_glow02_add_noz")

	local function DrawSCP049PestilenceVision(bDepth, bSkybox)
		if bSkybox then return end
		local client = LocalPlayer()

		if not IsValid(client) or client:GTeam() ~= TEAM_SCP or client:Health() <= 0 or client:GetRoleName() ~= "SCP049" then
			return
		end

		local pulse = math.abs(math.sin(CurTime() * 5))
		local baseSize = 20
		local infectedSize = baseSize + (15 * pulse)

		cam.Start3D()
		cam.IgnoreZ(true)

		for _, ent in ipairs(ents.GetAll()) do
			local pos = nil
			local color = nil
			local isCorpse = false
			if ent:GetClass() == "prop_ragdoll" then
				local ownerPly = ent:GetNWEntity("ply")
				
				if IsValid(ownerPly) and ownerPly:IsPlayer() then
					if ownerPly:GetNWBool("HasPestilence", false) then
						color = Color(200, 0, 0, 255)
					end
				elseif not IsValid(ownerPly) then
					color = Color(100, 100, 100, 150)
					isCorpse = true
				end

				if color then
					local bone = ent:LookupBone("ValveBiped.Bip01_Spine2")
					if bone then
						local mat = ent:GetBoneMatrix(bone)
						if mat then pos = mat:GetTranslation() end
					end
					if not pos then pos = ent:WorldSpaceCenter() end
				end

			elseif ent:IsPlayer() and ent:Alive() and ent:GetNWBool("HasPestilence", false) then
				if not IsValid(ent:GetNWEntity("FakeRagdoll")) then
					color = Color(200, 0, 0, 255)

					local bone = ent:LookupBone("ValveBiped.Bip01_Spine2")
					if bone then
						local mat = ent:GetBoneMatrix(bone)
						if mat then pos = mat:GetTranslation() end
					end
					if not pos then pos = ent:WorldSpaceCenter() + Vector(0, 0, 15) end
				end
			end

			if pos and color then
				render.SetMaterial(pestilence_mat)
				
				if isCorpse then
					render.DrawSprite(pos, 15, 15, color)
				else
					render.DrawSprite(pos, infectedSize, infectedSize, color)
					render.DrawSprite(pos, infectedSize * 0.4, infectedSize * 0.4, Color(255, 150, 150, 255))
				end
			end
		end

		cam.IgnoreZ(false)
		cam.End3D()
	end

	hook.Remove("PreDrawOutlines", "SCP049_BodyOutline")
	hook.Remove("SetupOutlines", "SCP049_BodyOutline_Setup")
	
	hook.Add("PostDrawTranslucentRenderables", "SCP049_PestilenceVision", DrawSCP049PestilenceVision)
end