include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if LocalPlayer():GTeam() == TEAM_ANTIFURRY then
        outline.Add(self,Color(255,255,255),2)
    end
end
