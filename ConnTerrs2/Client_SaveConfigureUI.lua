function Client_SaveConfigureUI(alert)
	Mod.Settings.AutoDistributeUnits = autoDistributeUnitsInput.GetIsChecked();
	Mod.Settings.NUnitsIsNTerrs = nUnitsIsNTerrsInput.GetIsChecked();
	if not Mod.Settings.NUnitsIsNTerrs then
		Mod.Settings.NumberOfUnits = numberOfUnitsInput.GetValue();
	end
	Mod.Settings.IncludeCommanders = includeCommandersInput.GetIsChecked();
	Mod.Settings.CanBeAirliftedToSelf = canBeAirliftedToSelfInput.GetIsChecked();
	Mod.Settings.TeamsCountAsOnePlayer = teamsCountAsOnePlayerInput.GetIsChecked();
end