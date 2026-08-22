function GM:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
    hook.Run("PlayerWeaponChanged", ply, newWeapon, true)
end
