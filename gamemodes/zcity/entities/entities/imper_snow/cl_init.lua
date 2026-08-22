include("shared.lua")

function ENT:Draw()
    if GetConVar("breach_config_snow"):GetInt() == 0 or LocalPlayer():GetPos():Distance(self:GetPos()) > 1000 then return end
    self:DrawModel()
    
        
    
end
