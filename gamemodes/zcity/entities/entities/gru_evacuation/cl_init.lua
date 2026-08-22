include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    self:SetSubMaterial(0,"models/imperator/female/no_draw")
    if LocalPlayer():GTeam() == TEAM_GRU and !GetGlobalBool("Evacuation") then return end
    if LocalPlayer():GetPos():Distance(self:GetPos()) < 400 and LocalPlayer():GTeam() != TEAM_SPEC then
    outline.Add(self,Color(255,255,255),2)
    end
    
end
