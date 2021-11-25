function Client_PresentConfigureUI(rootParent)
	BonusOverrider = Mod.Settings.BonusOverrider;
	DeployTransferHelper = Mod.Settings.DeployTransferHelper;
	if BonusOverrider == nil then BonusOverrider = true end
	if DeployTransferHelper == nil then DeployTransferHelper = true end
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	SetBonusOverrider = UI.CreateCheckBox(vert).SetText("Automate the bonus overwriting").SetIsChecked(BonusOverrider);
	SetDeployTransferHelper = UI.CreateCheckBox(vert).SetText("Deploy/transfer helper").SetIsChecked(DeployTransferHelper);
end