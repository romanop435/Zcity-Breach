AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/scp079microcom/scp079microcom.mdl")
    self:SetPos( Vector(3343.733154, 2837.850098, -83.968750) )
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    self.HaveCard = true
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end

function ENT:Use(a,c)
    if a:GTeam() ~= TEAM_AR then return end
    if a:GetWeapon("kasanov_ar_disk") ~= NULL then return end
    a:BrProgressBar("l:progress_wait", 5, "nextoren/gui/new_icons/hand.png", self, false, function()
        if !IsValid(self) then return end
        a:BreachGive("item_scp_079")
        self:Remove()
        local players = GetActivePlayers()
        for k, v in pairs( players ) do
            v:ScreenFade(SCREENFADE.IN, Color(0,0,0,164), 5, 13)
        end
        PlayAnnouncer("cpthazama/scp/079/new_079.wav")
        local doors682 = ents.FindInBox(Vector(2570.000000, 3006.000000, -334.000000), Vector(2570.000000, 3100.000000, -331.250000))
		for i = 1, #doors682 do
			local door = doors682[i]
			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("open")
			end
		end
		
		
		for i, v in pairs(ents.FindByModel("models/noundation/doors/860_door.mdl")) do v:Fire("use") end
		for i, v in pairs(ents.FindInBox(Vector(2679.069336, 1976.072876, 368.106079), Vector(2333.408691, 1436.376221, -17.681280))) do
			if IsValid(v) and v:GetClass() == "func_door" then
				v:Fire("Unlock")
				v:Fire("Open")
			end
		end
		for i, v in pairs(ents.FindByName('scp_door_new_*')) do v:Fire('Unlock') v:Fire('open') end
		for i, v in pairs(BUTTONS) do
			
				for _, door in ipairs(ents.FindInSphere(v.pos, 40)) do
					if IsValid(door) and door:GetClass() == "func_door" then
						door:Fire( "Unlock" )
						door:Fire( "Open" )
					end
				end
			
		end
        local new_scp_doors = {
			Vector(8413.53125, 1153.5559082031, 1.2612457275391),
			Vector(6999.3671875, 2526.9614257813, 0.03125),
			Vector(6571.0922851563, 2354.5971679688, 0.03125),
			Vector(5007.53125, 3558.1787109375, 0.03125),
			Vector(4310.0786132813, 2364.3271484375, 1.2612476348877),
			Vector(6062.5107421875, 1366.46875, 1.2612457275391),
			Vector(5670.7587890625, -670.53125, 1.2612457275391),
			Vector(2410.2827148438, 1853.2991943359, 1.6685428619385),
			Vector(2542.2839355469, 1727.4678955078, 1.2612495422363),
		}
		for k, v in pairs(new_scp_doors) do 
			for v, v in ipairs(ents.FindInSphere(v,100)) do 
				if v:GetClass() == "func_door" then
					v:Fire('Unlock') v:Fire('open') 
				end
			end
		end
		for _, door049 in ipairs(ents.FindInSphere(Vector(7565.8999023438, -272.04998779297, 55.389999389648), 10)) do
			if IsValid(door049) and door049:GetClass() == "prop_dynamic" then door049:Remove() end
		end

        local scpply = {}

        for k, v in pairs( players ) do
            if BREACH.SCP_PENALTY[v:SteamID64()] == 0 then
                table.insert( scpply, v )
            end
        end

        local tab = table.Copy(SCPS)
		local plys = player.GetAll()
		for i = 1, #plys do
			local ply1 = plys[i]
			if table.HasValue(tab, ply1:GetRoleName()) then
				table.RemoveByValue(tab, ply1:GetRoleName())
			end
		end
        for i = 1, math.random(3, 5) do
            ::selectscprepeat::
            if #scpply == 0 then
                scpply = players
            end
            local scp = GetSCP( table.remove( tab, math.random( #tab ) ) )
            local ply = #scpply > 0 and table.remove( scpply, math.random( #scpply ) ) or table.Random( players )
            if ply == nil then return end
            if ply:GTeam() ~= TEAM_SPEC then goto selectscprepeat end
            local spawnpos = table.remove(SPAWN_SCP_RANDOM_COPY_, math.random(1, #SPAWN_SCP_RANDOM_COPY_))
            ply:SetupNormal()
            scp:SetupPlayer( ply )
            ply:CompleteAchievement("spawn_scp")
        end

        
        
        
        
        
		
		
        
        

    end,
    function()
        timer.Create("create_079_laught_sounds", 30, 4, function()
            PlayAnnouncer("cpthazama/scp/079/broadcast"..math.random(1,7)..".mp3")
            local players = GetActivePlayers()

            for k, v in pairs( players ) do
                v:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3)
            end

        end)
    end, function()
        timer.Remove("create_079_laught_sounds")
    end)
end

