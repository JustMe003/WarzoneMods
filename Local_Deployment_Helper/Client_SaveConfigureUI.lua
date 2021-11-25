function Client_SaveConfigureUI(alert)
	Mod.Settings.BonusOverrider = SetBonusOverrider.GetIsChecked();
	Mod.Settings.DeployTransferHelper = SetDeployTransferHelper.GetIsChecked();
	if Mod.Settings.BonusOverrider == false and Mod.Settings.BonusOverrider == false then alert("why use this mod when no option is on?") end
end