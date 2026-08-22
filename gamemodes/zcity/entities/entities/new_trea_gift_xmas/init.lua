AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")



function ENT:Initialize()
    local modeltablec = {
    "models/zerochain/props_christmas/zpn_present01.mdl",
    }
    self:SetModel(table.Random(modeltablec))
    self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
    self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end


function ENT:Use(a,c)
    if a:GTeam() != TEAM_SPEC then
        a:BrProgressBar("l:progress_wait", 2, "nextoren/gui/new_icons/hand.png", self, false, function()
            
            
            local steamid64 = a:SteamID64()
            local time = tonumber(util.GetPData(util.SteamIDFrom64(steamid64), "event_xmas_test_cd_gift", 0))
            if time > os.time() then
                a:RXSENDNotify("Вы сможете открыть подобный подарок через : " .. string.NiceTime_Full_Rus(time - os.time()))
                
                
            else
                time = os.time() + 24 * 1 * 60 * 60
                util.SetPData(util.SteamIDFrom64(steamid64), "event_xmas_test_cd_gift", time)
                if a:GetPData( "event_xmas_gift" ) != nil then
                    a:SetPData( "event_xmas_gift", a:GetPData( "event_xmas_gift" ) + 1 )
                else
                    a:SetPData( "event_xmas_gift", 1 )
                end
                a:SetNWInt("event_xmas_gift", a:GetPData( "event_xmas_gift" ))
                open_imperator_gift(a)
            end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        end)
    end
end

