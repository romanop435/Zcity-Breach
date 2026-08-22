include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
        outline.Add(self,Color(255,166,0),2)
    
end
