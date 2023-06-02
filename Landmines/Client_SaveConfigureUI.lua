function Client_SaveConfigureUI(alert)
	Mod.Settings.UnitCost = unitCostInput.GetValue();
    Mod.Settings.Damage = damageInput.GetValue();
    Mod.Settings.MaxUnits = maxUnitsInput.GetValue();
    Mod.Settings.GuessCooldown = guessCooldownInput.GetValue();
end