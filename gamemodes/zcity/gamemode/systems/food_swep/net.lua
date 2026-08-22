if SERVER then
	util.AddNetworkString("FoodSwep_PlayAnimation")
	util.AddNetworkString("FoodSwep_AnimationEvent")

	net.Receive("FoodSwep_AnimationEvent", function(len, ply) 
		if !IsValid(ply) then return end

		local id = net.ReadInt( 32 )
		local wep = ply:GetActiveWeapon()

		if !IsValid(wep) or !wep.IsFoodBase then return end

		wep:OnAnimationEvent(id)
	end)
end

if CLIENT then
	net.Receive("FoodSwep_PlayAnimation", function() 
		local ply = net.ReadEntity()

		if !IsValid(ply) then return end

		local wep = ply:GetActiveWeapon()

		if !IsValid(wep) or !wep.IsFoodBase or wep.AnimationPlaying then return end
		wep:PlayAnimation()
	end)
end