
function Client_SaveConfigureUI(alert)
    
    Mod.Settings.NonogramWidth = setWidth.GetValue();
	Mod.Settings.NonogramHeigth = setHeigth.GetValue();
	Mod.Settings.NonogramDensity = setDensity.GetValue();
	Mod.Settings.LocalDeployments = LocalDeployments.GetValue();
end