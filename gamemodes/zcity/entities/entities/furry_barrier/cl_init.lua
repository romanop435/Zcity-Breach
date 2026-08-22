include("shared.lua")
ENT.Pos = Vector(0, 8, -1.2)
ENT.Ang = Angle(90, 50, -90)
function ENT:Initialize()

end


function ENT:Draw()

	self:DrawModel()

end