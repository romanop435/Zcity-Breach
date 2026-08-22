AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model( "models/hunter/blocks/cube075x1x025.mdl" )

function ENT:Initialize()
	self:SetModel(self.Model)

    self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetPos(Vector(1591, 4105, 64))
    self:SetAngles(Angle(90,0,90))
end

ENT.NextUse = 0

function ENT:Use( activator, caller )
    if self.NextUse > CurTime() then return end
    self.NextUse = CurTime() + 1
    if not IsValid(caller) then return end
	if not caller:GetNWBool('ChipedByAndersonRobotik', false) then return end
    if not caller:HasWeapon("kasanov_ar_disk") then return end
    if not self.Hacker then
        self.Hacker = true
        caller:RXSENDNotify("l:ar_support_call")
        timer.Simple(60, function()
            BREACH.PowerfulARSupport(caller, self)
        end)
        caller:SetForcedAnimation("0_SCP_542_lifedrain", false, false, function()


            caller:TakeDamage(9999, ent, ent)


        end)
        
        
        
        
        
        
        
        
        caller:GetWeapon('kasanov_ar_disk'):Remove()
        self:EmitSound("^nextoren/others/monitor/start_hacking.wav")
    end
end