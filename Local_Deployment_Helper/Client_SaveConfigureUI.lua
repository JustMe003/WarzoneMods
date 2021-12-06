function Client_SaveConfigureUI(alert)
	Mod.Settings.BonusOverrider = SetBonusOverrider.GetIsChecked();
	Mod.Settings.DeployTransferHelper = SetDeployTransferHelper.GetIsChecked();
	Mod.Settings.OverridePercentage = SetOverridePercentage.GetIsChecked();
	if Mod.Settings.BonusOverrider == false and Mod.Settings.DeployTransferHelper == false then alert("why use this mod when no option is on?") end
end