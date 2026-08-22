
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.RenderGroup        = RENDERGROUP_TRANSLUCENT;

local G = 6.67428e-5
local function gravity(mass1,mass2,dist)
    return G * mass1 * mass2 / dist*dist;
end

function ENT:Initialize()
    self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
    self.mass = 500;

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)
    self:GetPhysicsObject():SetMass(5000)
end

function ENT:Think()
    self:Pull();


end

function ENT:Pull()
	if !SERVER then
		return
	end

    local phys, mass, dir, pos, entpos, grav;
    pos = self:GetPos();
    mass = self.mass or 500;
    for _,ent in player.Iterator() do
    	
        phys = ent:GetPhysicsObject();
        if (phys:IsValid() and ent ~= self and not ent:IsWorld()) then
            entpos = ent:GetPos();
            grav = gravity(mass, phys:GetMass(), entpos:Distance(pos));
            dir = (entpos - pos):GetNormalized() * -grav;
            if (ent:IsPlayer()) then
                ent:SetVelocity(dir);
            else
                phys:AddVelocity(dir);
            end
            if (not phys:IsMoveable() and dir:LengthSqr() > 100000000) then
                phys:EnableMotion(true);
            end
        
        
        end
    end
end

if SERVER then
concommand.Add("blackhole", function(ply, cmd, args, argstr)
	if !ply:IsSuperAdmin() then
		return
	end

	local ent = ents.Create("shit")
	ent:SetPos(ply:GetPos())
	ent:SetModel(args[2] or "models/combine_helicopter/helicopter_bomb01.mdl")
	if !args[2] then
		ent:SetMaterial("models/debug/debugwhite")
    	ent:SetColor( Color( 255,255,255,255) )
    end
	ent:Spawn()
	ent.mass = args[1] or 500

	undo.Create("prop")
 	undo.AddEntity(ent)
 	undo.SetPlayer(ply)
	undo.Finish()
end)
end