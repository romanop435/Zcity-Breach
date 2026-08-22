include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():Distance(self:GetPos()) < 300 then
        outline.Add(self,Color(235,106,106),2)
    end
    
end
