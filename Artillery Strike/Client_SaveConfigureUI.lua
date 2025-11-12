function Client_SaveConfigureUI(alert)
	saveAll();
end

function saveAll()
	saveCannons();
	saveMortars();
	saveMiscelaneous();
end

function saveCannons()
	if not canReadObject(addCannons) then return; end
	Mod.Settings.Cannons = addCannons.GetIsChecked();
	Mod.Settings.AmountOfCannons = maxCannons.GetValue();
	Mod.Settings.MaxCannonDamage = maximumCannonDamage.GetValue();
	Mod.Settings.MinCannonDamage = minimumCannonDamage.GetValue();
	Mod.Settings.RangeOfCannons = rangeOfCannons.GetValue();
end

function saveMortars()
	if not canReadObject(addMortars) then return; end
	Mod.Settings.Mortars = addMortars.GetIsChecked();
	Mod.Settings.AmountOfMortars = maxMortars.GetValue();
	Mod.Settings.MortarDamage = mortarDamage.GetValue();
	Mod.Settings.MaxMissPercentage = maxMissPercentage.GetValue();
	Mod.Settings.MinMissPercentage = minMissPercentage.GetValue();
	Mod.Settings.RangeOfMortars = rangeOfMortars.GetValue();
end

function saveMiscelaneous()
	if not canReadObject(useGoldInput) then return; end
	Mod.Settings.UseGold = useGoldInput.GetIsChecked();
	Mod.Settings.GoldCost = goldCostInput.GetValue();
	Mod.Settings.ArtilleryShot = cannonShotTurnNumber.GetValue();
	Mod.Settings.CustomScenario = customScenarioInput.GetIsChecked();
end