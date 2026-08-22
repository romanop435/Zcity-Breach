include( "shared.lua" )



net.Receive("AlphaWarheadTimer_CLIENTSIDE", function()
	local time = tonumber(net.ReadString())
	local remove = net.ReadBool()
	if !remove then
		timer.Create("NukeTimer", time - 1, 1, function() end)
	else
		timer.Remove("NukeTimer")
	end
end)

function ENT:Draw()
    
end