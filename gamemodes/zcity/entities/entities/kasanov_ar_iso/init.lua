AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_tech/usbstick/usbstick.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    self.NextThinkk = 0
end

function ENT:Think()
    for _, ply in ipairs(ents.FindInSphere(self:GetPos(), 50)) do
        if not ply then continue end
        if not ply:IsPlayer() then continue end
        if not ply:Alive() then continue end
        if ply:Health() <= 0 then continue end
        if ply:GTeam() == TEAM_SPEC then continue end
        if ply:GTeam() == TEAM_SCP then continue end
        if ply:HasHazmat() then continue end

        
        ply:SetGTeam(TEAM_AR)
        ply:RXSENDNotify("Вы были чипированы оборудованием \"Андерсон Роботикс\". Ваша новая задача: доставить полученый прибор к указаному месту!")
        ply:SetNWBool('ChipedByAndersonRobotik', true)
        ply:BreachGive('kasanov_ar_disk')
        self:Remove()
        break
    end

    self:NextThink(CurTime() + 1)
end