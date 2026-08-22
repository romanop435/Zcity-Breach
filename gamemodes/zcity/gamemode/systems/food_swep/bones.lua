function FoodSwep:InterpolateBones(ent, fraction, startData, endData)
	if !IsValid(ent) then return end
	
	for k, v in pairs(endData) do
		local boneID = ent:LookupBone(k)
		if boneID then
			if (boneID > -1) then
				if v.pos then
					if startData and startData[k] and startData[k].pos then
						ent:ManipulateBonePosition(boneID, LerpVector(fraction, startData[k].pos, v.pos))
					else
						ent:ManipulateBonePosition(boneID, LerpVector(fraction, Vector(0, 0, 0), v.pos))
					end
				end
				
				if v.angle then
					if startData and startData[k] and startData[k].angle then
						ent:ManipulateBoneAngles(boneID, LerpAngle(fraction, startData[k].angle, v.angle))
					else
						ent:ManipulateBoneAngles(boneID, LerpAngle(fraction, Angle(0, 0, 0), v.angle))
					end
				end
			end
		end
	end
end

function FoodSwep:SetBones(ent, bonesData)
	if !IsValid(ent) then return end
	
	if bonesData then
		for k, v in pairs(bonesData) do
			local boneID = ent:LookupBone(k)
			if boneID then
				if (boneID > -1) then
					if v.pos then
						ent:ManipulateBonePosition(boneID, v.pos)
					end

					if v.angle then
						ent:ManipulateBoneAngles(boneID, v.angle)
					end

					if v.scale then
						ent:ManipulateBoneScale(boneID, v.scale)
					end
				end
			end
		end
	end
end

function FoodSwep:ResetBones(ent)
	if !IsValid(ent) then return end

	if !ent:GetBoneCount() then return end
	
	for i = 0, ent:GetBoneCount() do
		ent:ManipulateBoneScale(i, Vector(1, 1, 1))
		ent:ManipulateBoneAngles(i, Angle(0, 0, 0))
		ent:ManipulateBonePosition(i, Vector(0, 0, 0))
	end
end