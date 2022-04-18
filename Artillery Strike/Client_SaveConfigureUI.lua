function Client_SaveConfigureUI(alert)
	if addCannons ~= nil then
		Mod.Settings.Cannons = getIsChecked(addCannons);
		Mod.Settings.AmountOfCannons = getValue(maxCannons);
		Mod.Settings.MaxCannonDamage = getValue(maximumCannonDamage);
		Mod.Settings.MinCannonDamage = getValue(minimumCannonDamage);
		Mod.Settings.RangeOfCannons = getValue(rangeOfCannons);
	end
	if addMortars ~= nil then
		Mod.Settings.Mortars = getIsChecked(addMortars);
		Mod.Settings.AmountOfMortars = getValue(maxMortars);
		Mod.Settings.MortarDamage = getValue(mortarDamage);
		Mod.Settings.MaxMissPercentage = getValue(maxMissPercentage);
		Mod.Settings.MinMissPercentage = getValue(minMissPercentage);
		Mod.Settings.RangeOfMortars = getValue(rangeOfMortars);
		if Mod.Settings.MaxMissPercentage > Mod.Settings.MortarDamage then alert("The maximum miss percentage cannot be bigger than the damage of the mortar itself"); end
	end
	if useGold ~= nil then
		Mod.Settings.UseGold = getIsChecked(useGoldInput);
		Mod.Settings.GoldCost = getValue(goldCostInput);
	end
	Mod.Settings.ArtilleryShot = getValue(cannonShotTurnNumber);
	Mod.Settings.CustomScenario = getIsChecked(customScenarioInput);
end