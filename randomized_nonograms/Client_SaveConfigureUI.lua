
function Client_SaveConfigureUI(alert)
    Mod.Settings.NonogramWidth = setWidth.GetValue();
	Mod.Settings.NonogramHeigth = setHeigth.GetValue();
	Mod.Settings.NonogramDensity = setDensity.GetValue();
	Mod.Settings.LocalDeployments = LocalDeployments.GetIsChecked();
--	If the host made a mistake or tried to bread the mod it checks if the given inputs are playable
	if Mod.Settings.NonogramWidth < 5 then Mod.Settings.NonogramWidth = 5; end
	if Mod.Settings.NonogramWidth > 20 then Mod.Settings.NonogramWidth = 20; end
	if Mod.Settings.NonogramHeigth < 5 then Mod.Settings.NonogramHeigth = 5; end
	if Mod.Settings.NonogramHeigth > 20 then Mod.Settings.NonogramHeigth = 20; end
	if Mod.Settings.NonogramDensity < 1 then Mod.Settings.NonogramDensity = 1; end
	if Mod.Settings.NonogramDensity > 99 then Mod.Settings.NonogramDensity = 99; end
end