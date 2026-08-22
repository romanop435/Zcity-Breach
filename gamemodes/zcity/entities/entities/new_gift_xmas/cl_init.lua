include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
        outline.Add(self,Color(221,76,76),2)
    
end
