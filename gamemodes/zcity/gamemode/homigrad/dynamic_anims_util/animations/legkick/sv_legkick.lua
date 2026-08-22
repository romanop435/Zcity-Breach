hook.Add("HG_MovementCalc_2","HG-LegKickAnim",function(mul, ply, cmd, mv)
    if ply:GetNWFloat("InLegKick",0) > CurTime() then
        cmd:RemoveKey(IN_MOVELEFT)
        cmd:RemoveKey(IN_MOVERIGHT)
        cmd:RemoveKey(IN_JUMP)

        mv:RemoveKey(IN_MOVELEFT)
        mv:RemoveKey(IN_MOVERIGHT)
        mv:RemoveKey(IN_JUMP)

        mul[1] = math.min(math.max(0.001,1 - (ply:GetNWFloat("InLegKick",0) - CurTime()) * 2 ),1)

        if cmd:KeyDown(IN_DUCK) or ply:Crouching() then
            cmd:AddKey(IN_DUCK)
            mv:AddKey(IN_DUCK)
        else
            cmd:RemoveKey(IN_DUCK)
            mv:RemoveKey(IN_DUCK)
        end
    end
end)
