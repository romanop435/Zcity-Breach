
print("Auto-Workshop Force Download")
for i,addon in pairs(engine.GetAddons()) do
	print("Adding Workshop Addons:")
	if addon.mounted then
		resource.AddWorkshop( addon.wsid )
		print("\t[+]"..addon.wsid..": "..addon.title)
	end
end

resource.AddWorkshop( "1344177917" )
--resource.AddWorkshop( "3461733876" )

resource.AddWorkshop("3626277245") -- аватарки

--resource.AddWorkshop("3542644649") -- Либа шэйдеров
--resource.AddWorkshop("3556046077") -- Сигма блум
--resource.AddWorkshop("3590958052") -- Рябь на мониторах