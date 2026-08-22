AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")



function ENT:Initialize()
    local modeltablec = {
    "models/props_candy/bitohoney.mdl",
    "models/props_candy/bottlecaps.mdl", 
    "models/props_candy/bunchacrunch.mdl",
    "models/props_candy/charlestonchewmini.mdl",
    "models/props_candy/chucklesminis.mdl",
    "models/props_candy/crows.mdl",
    "models/props_candy/dots.mdl",
    "models/props_candy/goodandplenty.mdl",
    "models/props_candy/hottamales.mdl",
    "models/props_candy/jujubes.mdl",
    "models/props_candy/jujyfruits.mdl",
    "models/props_candy/juniormints.mdl",
    "models/props_candy/lemonhead.mdl",
    "models/props_candy/lifesaversgummies.mdl",
    "models/props_candy/mikeandike.mdl",
    "models/props_candy/mikeandikemegamix.mdl",
    "models/props_candy/mms.mdl",
    "models/props_candy/mmscaramel.mdl",
    "models/props_candy/mmspeanut.mdl",
    "models/props_candy/mmspeanutbutter.mdl",
    "models/props_candy/skittles.mdl",
    "models/props_candy/sourpatchkids.mdl",
    "models/props_candy/sweettarts.mdl",
    "models/props_candy/whoppers.mdl"
    }
    self:SetModel(table.Random(modeltablec))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
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
    if a:GTeam() != TEAM_GRU and a:GTeam() != TEAM_SPEC then
        a:BrProgressBar("l:progress_wait", 5, "nextoren/gui/new_icons/hand.png", self, false, function()
            a:SetNWInt("TASKS_Hell", a:GetNWInt("TASKS_Hell") + 1)
            if a:GetNWInt("TASKS_Hell") == 20 then
                a:AddToStatistics("Сбор конфеток", 1000)
                a:CompleteAchievement("halloween")
                if !a:IsPremium() then
            		timer.Simple( 1, function()
                    
            		
            		Shaky_SetupPremium(a:SteamID64(),259200)
            		a:RXSENDNotify("За выполение квестика")
            		end)
            	end
            end
            self:Remove()
        end)
    end
end

