function Client_SaveConfigureUI(alert)
	Mod.Settings.BonusOverrider = SetBonusOverrider.GetIsChecked();
	Mod.Settings.OverridePercentage = SetOverridePercentage.GetIsChecked();
	-- Mod.Settings.ModVersion = "3.0";
end