AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")



function ENT:Initialize()
    local modeltablec = {
    "models/zerochain/props_christmas/zpn_candy_cookie01.mdl",
    "models/zerochain/props_christmas/zpn_candy_cookie02.mdl", 
    "models/zerochain/props_christmas/zpn_candy_cookie03.mdl",
    "models/zerochain/props_christmas/zpn_candy_cookie04.mdl",
    "models/zerochain/props_christmas/zpn_candy_cookie05.mdl",
    "models/zerochain/props_christmas/zpn_candy_cookie06.mdl",
    }
    self:SetModel(table.Random(modeltablec))
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Think()
	if ( SERVER ) then
		self:NextThink( CurTime() )
        return true
	end
end


function ENT:Use(a,c)
    if a:GTeam() != TEAM_SPEC then
        local function startcallback()
			for i = 1, 4 do
				timer.Create("EAT_CANDY_"..a:SteamID64().."_"..tostring(i),i,1, function()
					a:EmitSound("zpn/sfx/zpn_candy_collect0"..math.random(1,3)..".wav")
				end)
			end
		end
        local function stopcallback()
			for i = 1, 4 do
				timer.Remove("EAT_CANDY_"..a:SteamID64().."_"..tostring(i))
			end
		end
        a:BrProgressBar("l:progress_wait", 5, "nextoren/gui/new_icons/eat_new_candy_"..math.random(1,3)..".png", self, false, function()
            
            if a:GetPData( "event_xmas_candy" ) != nil then
                a:SetPData( "event_xmas_candy", a:GetPData( "event_xmas_candy" ) + 1 )
            else
                a:SetPData( "event_xmas_candy", 1 )
            end
            a:SetNWInt("event_xmas_candy", a:GetPData( "event_xmas_candy" ))
            
            a:RXSENDNotify("Ты собрал еще одну конфетку! Собрано конфет : "..a:GetPData( "event_xmas_candy" ))
            a:EmitSound("nextoren/kys_"..math.random(1,3)..".mp3")
            
            
            
            
            
            
            
            
            
            
            
            
            self:Remove()
        end, startcallback, stopcallback)
    end
end

