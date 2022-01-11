function Client_SaveConfigureUI(alert)
    local numTerritories = numTerritoriesInputField.GetValue();

    if (numTerritories < 1) then alert("Number of territories to auto distribute must be positive"); end

    Mod.Settings.NumTerritories = numTerritories;
	Mod.Settings.takeDistributionTerr = takeDistributionTerrInputField.GetIsChecked();
	Mod.Settings.setArmiesToInDistribution = setArmiesToInDistributionInputField.GetIsChecked();
end