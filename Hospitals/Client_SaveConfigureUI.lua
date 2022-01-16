function Client_SaveConfigureUI(alert)
	
	Mod.Settings.numberOfHospitals = numberOfHospitalsInput.GetValue();
	Mod.Settings.recoverPercentageMinimum = recoverPercentageMinimumInput.GetValue();
	Mod.Settings.recoverPercentageMaximum = recoverPercentageMaximuminput.GetValue();
	Mod.Settings.maximumHospitalRange = math.min(math.max(maximumHospitalRangeInput.GetValue(), 1), 5);
	Mod.Settings.upgradeSystem = upgradeSystemInput.GetIsChecked();
	Mod.Settings.amountOfLevels = amountOfLevelsInput.GetValue();
end