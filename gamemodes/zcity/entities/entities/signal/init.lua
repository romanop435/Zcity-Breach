AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_beneric/bm_batteryradio01.mdl")
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    BREACH.HELIGO = false
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end


function ENT:Use(a,c)
    if a:GTeam() == TEAM_ANTIFURRY and !BREACH.HELIGO then
        BREACH.HELIGO = true
        self:EmitSound( "nextoren/heli_antifurry.ogg", 75, math.random( 95, 105 ), .75, CHAN_STATIC )
		for _, announce in player.Iterator() do
			announce:BrTip(0, "[ZCity Breach]", Color(255,0,0,200), "Вертолет пребудет через 90 секунд, обороняйте ВП", color_white)
		end
		timer.Simple(90, function()
        	local heli = ents.Create("heli")
	    	heli:Spawn()
        	timer.Simple(30, function()
	    		if IsValid(heli) then
	    			heli:EmitSound("nextoren/vo/chopper/chopper_ten_left.wav", 130, 100, 1.5, CHAN_VOICE, 0, 0)
	    		end
	    	end)

	    	
	    	
	    	
	    	
	    	

	    	timer.Create("PerformEscapeAnim_HELI", 40, 1, function()
	    		if IsValid(heli) then
	    			heli:EmitSound("nextoren/vo/chopper/chopper_evacuate_end.wav", 110, 100, 1.2, CHAN_VOICE, 0, 0)
	    			heli:Escape()
	    			
	    			for _, ply in pairs(ents.FindInBox( Vector(-5541.473633, -12180.079102, 7358), Vector(-6201.487305, -12924.251953, 6693) )) do
	    				if IsValid(ply) and ply:IsPlayer() and ply:GTeam() == TEAM_ANTIFURRY then
	    				    if !ply:Alive() or ply:Health() <= 0 then continue end
	    				    timer.Simple(0.6, function()
	    				    	ply:AddToStatistics("l:escaped", 200)
	    				    	if ply:HasWeapon("item_cheemer") then
	    				    		ply:AddToStatistics("l:cheemer_rescue", 100)
	    				    	end
	    				    	net.Start("Ending_HUD")
	    				    		net.WriteString("l:ending_evac_choppa")
	    				    	net.Send(ply)
	    				    	ply:CompleteAchievement("escape")
	    				    	ply:LevelBar()
	    				    	ply:SetupNormal()
	    				    	ply:SetSpectator()
								ply:SetNWInt("gloves_antifurry", 1)
								ply:SetPData( "gloves_antifurry", 1 )
								ply:CompleteAchievement("antifurry")
	    				    	givekarmaforescape(ply)
	    				    end)
	    				end
	    			end
	    		end
	    	end)
		end)
    end
end

