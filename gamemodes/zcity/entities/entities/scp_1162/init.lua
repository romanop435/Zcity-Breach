AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/player/main.mdl")
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    
    
    
    
    self:SetPos(Vector(6971.624512, -2629.821289, 48))
    self:SetAngles(Angle(90,0,0))
end







local drka_list = {
    "item_tazer",
	"item_pills",
	"item_medkit_1",
	"item_medkit_2",
	"item_medkit_3",
	
	"item_syringe",
	"item_adrenaline",
    "item_cheemer",
	"armor_big_bag",
	"armor_small_bag",
	"weapon_pass_medic",
	"weapon_pass_guard",
	"weapon_pass_sci",
	"item_tazer",
	"item_radio",
	"copper_coin",
	"silver_coin",
	"gold_coin",
	"breach_keycard_sci_1",
	"breach_keycard_sci_2",
	"breach_keycard_sci_3",
	"breach_keycard_sci_4",
	"breach_keycard_1",
	"breach_keycard_security_1",
	"breach_keycard_security_2",
	"breach_keycard_security_3",
	"breach_keycard_security_4",
	"breach_keycard_3",
	"breach_keycard_4",
	"breach_keycard_guard_4",
	"breach_keycard_guard_3",
	"breach_keycard_guard_2",
	"battery_1"
}

function ENT:Use(a,c)
    if timer.Exists("scp_1162_working") then return end
    if a:GTeam() == TEAM_SPECTATOR or a:GTeam() == TEAM_SCP then return end
    local wep = a:GetActiveWeapon()
    if !IsValid(wep) then return end
    if wep:GetClass() == "br_holster" then
        
        if a:Health() <= a:GetMaxHealth() * 0.35 then
            a:EmitSound("nextoren/charactersounds/hurtsounds/male/gore_" .. math.random( 1, 4 ) .. ".mp3")
            a:Kill()
            ParticleEffect( "tank_gore_c", a:GetPos(), a:GetAngles() )
			a:GetNWEntity( "RagdollEntityNO" ):Remove()
            timer.Create("scp_1162_working", math.random(1,10), 1, function()
                if math.random(1,4) == 4 then
                    self:EmitSound("nextoren/scp/542/scp_542_finish.ogg")
                    local prop = ents.Create(table.Random(drka_list))
	                if(!IsValid(prop)) then return end
	                local pos = self:GetPos()
	                prop:SetPos(self:LocalToWorld(Vector(-2, -2, 12)))
	                prop:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 90)))
	                prop:Spawn()
	                prop:PhysWake()
	                prop:GetPhysicsObject():SetVelocity(Vector(self:GetAngles():Up() * 75))
                else
                    self:EmitSound("nextoren/scp/106/disappear.ogg")  
                end
            end)
        else
            a:TakeDamage(a:GetMaxHealth() * 0.35,self)
            a:ScreenFade(SCREENFADE.IN, Color(255,0,0,64), 3, 1)
            a:ViewPunch( Angle( -10, 0, 0 ) )
            timer.Create("scp_1162_working", math.random(1,10), 1, function()
                if math.random(1,4) == 4 then
                    self:EmitSound("nextoren/scp/542/scp_542_finish.ogg")
                    local prop = ents.Create(table.Random(drka_list))
	                if(!IsValid(prop)) then return end
	                local pos = self:GetPos()
	                prop:SetPos(self:LocalToWorld(Vector(-2, -2, 12)))
	                prop:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 90)))
	                prop:Spawn()
	                prop:PhysWake()
	                prop:GetPhysicsObject():SetVelocity(Vector(self:GetAngles():Up() * 75))
                else
                    self:EmitSound("nextoren/scp/106/disappear.ogg")  
                end
            end)
        end
    end
    if wep.droppable == false then return end
    wep:Remove()
    self:EmitSound("nextoren/equipment/gasmask/unprone.wav")
    timer.Create("scp_1162_working", math.random(1,10), 1, function()
        if math.random(1,4) == 4 then
            self:EmitSound("nextoren/scp/542/scp_542_finish.ogg")
            local prop = ents.Create(table.Random(drka_list))
	        if(!IsValid(prop)) then return end
	        local pos = self:GetPos()
	        prop:SetPos(self:LocalToWorld(Vector(-2, -2, 12)))
	        prop:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 90)))
	        prop:Spawn()
	        prop:PhysWake()
	        prop:GetPhysicsObject():SetVelocity(Vector(self:GetAngles():Up() * 75))
        else
            self:EmitSound("nextoren/scp/106/disappear.ogg")  
        end
    end)
    
end
