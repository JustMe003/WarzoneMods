
function Client_SaveConfigureUI(alert)
	Mod.Settings.CanPlayEMB = CanPlayEMBCheckBox.GetIsChecked();
	Mod.Settings.CanPlayDiplomacy = CanPlayDiplomacyCheckBox.GetIsChecked();
	Mod.Settings.CanPlaySanctions = CanPlaySanctionsCheckBox.GetIsChecked();
	Mod.Settings.CanPlayBlockade = CanPlayBlockadeCheckBox.GetIsChecked();
	Mod.Settings.CanPlayBomb = CanPlayBombCheckBox.GetIsChecked();
end
