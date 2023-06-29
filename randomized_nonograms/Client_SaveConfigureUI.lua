
function Client_SaveConfigureUI(alert)
	Mod.Settings.CustomDistribution = setCustomDistribution.GetIsChecked();
	Mod.Settings.NonogramDensity = setDensity.GetValue();

	if Mod.Settings.NonogramDensity < 10 then Mod.Settings.NonogramDensity = 10; end
	if Mod.Settings.NonogramDensity > 90 then Mod.Settings.NonogramDensity = 90; end
end