function Client_SaveConfigureUI(alert)
	Mod.Settings.IsCustomScenario = isCustomScenarioInput.GetIsChecked();
	if numOfWastelandsInput ~= nil then
		Mod.Settings.NumOfWastelands = numOfWastelandsInput.GetValue();
		if Mod.Settings.NumOfWastelands < 1 then alert("The number of wastelands must be higher than 0"); end
	else
		Mod.Settings.NumOfWastelands = numOfWastelands;
	end
	if wastelandSizeInput ~= nil then
		Mod.Settings.WastelandSize = wastelandSizeInput.GetValue();
		if Mod.Settings.WastelandSize < 1 then alert("The size of wastelands must be higher or equal than 0"); end
	else
		Mod.Settigns.WastelandSize = wastelandSize;
	end
end