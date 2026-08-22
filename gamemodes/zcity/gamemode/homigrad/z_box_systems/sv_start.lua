ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}

function ZBox.StartAll()
    for _, plugin in pairs(ZBox.Plugins) do
        for hookName, callback in pairs(plugin.Hooks) do
            hook.Add(hookName, plugin.Name .. "_" .. hookName, callback)
        end
    end

    timer.Simple(1, function()
        hook.Run("ZBox_Start")
    end)
end

ZBox.Maps = {
    ["rp_truenorth_v1a"] = true
}

function ZBox.DisableAll()
    for _, plugin in pairs(ZBox.Plugins) do
        for hookName in pairs(plugin.Hooks) do
            hook.Remove(hookName, plugin.Name .. "_" .. hookName)
        end
    end

    timer.Simple(1, function()
        hook.Run("ZBox_Disable")
    end)
end
