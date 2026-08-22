include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():Distance(self:GetPos()) < 300 then
        outline.Add(self,Color(206,175,175),2)
    end
    
end
