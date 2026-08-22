
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= ""

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/tool_kit.png" )

end

SWEP.PrintName		= "Ремонтный комплект"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.WorldModel = "models/cultist/items/toolbox/tool_box.mdl"
SWEP.ViewModel = ""
SWEP.HoldType		= "heal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false
SWEP.Amount = 5

SWEP.droppable				= false
SWEP.UnDroppable 			= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false
SWEP.UseHands				= true


SWEP.Pos = Vector( 3,-1,0 )
SWEP.Ang = Angle( 0,0,90 )

SWEP.Pos2 = Vector( 3,-1,0 )
SWEP.Ang2 = Angle( 0,0,90 )

function SWEP:Deploy()

	self.NextThinkt = CurTime() + 2

end

local function RevivePlayer( self, ply, body, force, wep )

	if !IsValid(ply) or CLIENT then return end

	if !force then
		if body.__Team == TEAM_SCP then return end
		if body.__Team ~= TEAM_AR then return end

		if body:GetModel():find("corpse.mdl") then self:RXSENDNotify("l:deffib_body_decayed_pt1 ", Color(255,0,0), "l:deffib_body_decayed_pt2") return end

		if body.DieWhen + 45 <= CurTime() then self:RXSENDNotify("l:deffib_body_too_late_pt1 ", Color(255,0,0), "l:deffib_body_too_late_pt2") return end

		local isheadgibbed = false

		for i, v in pairs(body:LookupBonemerges()) do

			if IsValid(v) and v:GetModel():find("gib_head") then
				isheadgibbed = true
				break
			end

		end

		if ( body.KilledByWeapon and body.LastHit == HITGROUP_HEAD ) or isheadgibbed then self:RXSENDNotify("l:deffib_headshot ", Color(255,0,0), "l:deffib_headshot_pt2") return end

		self:BrProgressBar("l:ressurecting_someone", 2,"nextoren/gui/new_icons/tool_kit.png", body, false, nil, nil, function() self:StopForcedAnimation() end)
	end

	local finishcallback = function()

		if IsValid(wep) then
            wep.Amount = wep.Amount - 1
            if wep.Amount <= 0 then
                wep:Remove()
            end
        end

		self:CompleteAchievement("deffib")

		self:SetNWEntity("NTF1Entity", NULL)

		if ply:GTeam() != TEAM_SPEC and ply:Health() > 0 then return end

		if CLIENT then return end
		timer.Remove( "PlayerDeathFromBleeding" .. ply:SteamID64() )

		ply:SetupNormal()
		ply:SetModel(body:GetModel())
		ply:SetSkin(body:GetSkin())
		ply:SetGTeam(body.__Team)
		ply:SetRoleName(body.Role)
		ply:SetMaxHealth(body.__Health) 
		ply:SetHealth(ply:GetMaxHealth() * .65)
		ply:SetUsingCloth(body.Cloth)
		ply:SetNamesurvivor(body.__Name)
		ply.OldSkin = body.OldSkin
		ply.OldModel = body.OldModel
		ply.OldBodygroups = body.OldBodygroups
		ply:SetWalkSpeed(body.WalkSpeed)
		ply:SetRunSpeed(body.RunSpeed)
		ply:SetupHands()
		ply:SetNWAngle("ViewAngles", ply:GetAngles())
		timer.Remove("Death_Scene"..ply:SteamID())
		
		
		ply:SetMoveType(MOVETYPE_OBSERVER)
		ply:Freeze(true)

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
		


		
			for _, v in pairs(body.vtable.Weapons) do
				if weapons.GetStored(v) then
					ply:BreachGive(v)
				end
			end
		
			ply:BreachGive("br_holster")
		

		for _, bnmrg in pairs(body:LookupBonemerges()) do
			local bnmrg_ent = Bonemerge(bnmrg:GetModel(), ply)
			bnmrg_ent:SetSubMaterial(0, bnmrg:GetSubMaterial(0))
			bnmrg_ent:SetSubMaterial(2, bnmrg:GetSubMaterial(2))
			bnmrg_ent:SetSkin(bnmrg:GetSkin())
			bnmrg_ent:SetInvisible(bnmrg:GetInvisible())
		end

		for i = 0, 9 do
			ply:SetBodygroup(i, body:GetBodygroup(i))
		end

		ply:SetPos( Vector(body:GetPos().x, body:GetPos().y, GroundPos(body:GetPos()).z) )
		ply:SetAngles( body:GetAngles() )

		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		ply:SetForcedAnimation( ply:LookupSequence("l4d_Defib_Jolt"), 8, function() ply:GodEnable() ply:ScreenFade(SCREENFADE.IN, color_white, 4, 0) ply:SetNWEntity("NTF1Entity", ply) end, function()

			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			ply:SetForcedAnimation( ply:LookupSequence("l4d_Defib_Revive"), ply:SequenceDuration(ply:LookupSequence("l4d_Defib_Revive")), nil, function()

				ply:GodDisable()

				ply:ScreenFade(SCREENFADE.IN, color_black, 1, 0.5)

				ply:SetNWAngle("ViewAngles", Angle(0,0,0))

				ply:SetDSP( 1 )
				ply:Freeze( false )
				ply:SetMoveType(MOVETYPE_WALK)
				ply:SetNWEntity("NTF1Entity", NULL)

			end )

		end )

		body:SetNoDraw(true)

		timer.Simple( .2, function()

			body:Remove()

			if ( ply && ply:IsValid() ) then

				ply:SetNoDraw( false )

			end

		end )

		ply:SetNotSolid( false )

	end

	if !force then

		self:SetForcedAnimation("l4d_defibrillate_incap_standing", 2, function() self:SetNWEntity("NTF1Entity", self) end, finishcallback, function() self:SetNWEntity("NTF1Entity", NULL) end)

	else
		finishcallback()
	end

end

function SWEP:PrimaryAttack()

	local tr = self.Owner:GetEyeTrace()

	local ent = tr.Entity

	self.NextThinkt = CurTime() + 2

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity

	if ( ent && ent:IsValid() && ent:GetClass() == "prop_ragdoll" && !ent.NOREVIVE ) then

		RevivePlayer( self.Owner, ent:GetOwner(), ent, nil, self )

	end

end

function SWEP:OnDrop()

		if IsValid(self.Owner) then
			self.Owner:BrStopProgressBar("l:ressurecting_someone")
		end

end

function SWEP:Reload()
end

function SWEP:SecondaryAttack()

  return false

end