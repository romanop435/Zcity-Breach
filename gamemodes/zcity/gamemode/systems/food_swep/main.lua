hook.Add("UpdateAnimation", "FoodSwep_UpdateAnimation", function(ply, vel, maxSeqGroundSpeed)
	if !IsValid(ply) then return end
	
	local wep = ply:GetActiveWeapon()
	
	if !IsValid(wep) then return end
	
	if IsValid(ply.ActiveFoodWepoon) then
		if wep:GetClass() != ply.ActiveFoodWepoon:GetClass() then
			if IsValid(ply.ActiveFoodWepoon) then
				if CLIENT then
					ply.ActiveFoodWepoon:ResetAnimaton()
					ply.ActiveFoodWepoon:ResetPose()
				end
			end
			ply.ActiveFoodWepoon = nil
		else
			if wep.AnimationPlaying then
				wep:UpdateAnimation()
			end
		end
	else
		if wep.IsFoodBase then
			if CLIENT then
				wep:SetupPose()
			end
			ply.ActiveFoodWepoon = wep
		end
	end
end)