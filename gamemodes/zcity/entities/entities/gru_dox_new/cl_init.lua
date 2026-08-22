include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if LocalPlayer():GetNWBool("can_sea_gaus") then
        outline.Add(self,Color(255,255,255),1)
    end
end
