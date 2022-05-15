function Client_SaveConfigureUI(alert)
	
	Mod.Settings.numberOfHospitals = numberOfHospitalsInput.GetValue();
	Mod.Settings.recoverPercentageMinimum = recoverPercentageMinimumInput.GetValue();
	Mod.Settings.recoverPercentageMaximum = recoverPercentageMaximuminput.GetValue();
	if Mod.Settings.recoverPercentageMaximum < Mod.Settings.recoverPercentageMinimum then alert("The minimum percentage cannot be greater than the maximum percentage"); end
	Mod.Settings.maximumHospitalRange = math.min(math.max(maximumHospitalRangeInput.GetValue(), 1), 5);
end