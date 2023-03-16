function Client_PresentConfigureUI(rootParent)
	BonusOverrider = Mod.Settings.BonusOverrider;
	DeployTransferHelper = Mod.Settings.DeployTransferHelper;
	OverridePercentage = Mod.Settings.OverridePercentage;
	if BonusOverrider == nil then BonusOverrider = true end
	if DeployTransferHelper == nil then DeployTransferHelper = true end
	if OverridePercentage == nil then OverridePercentage = true end
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	SetBonusOverrider = UI.CreateCheckBox(vert).SetText("Automate the bonus overwriting").SetIsChecked(BonusOverrider);
	SetDeployTransferHelper = UI.CreateCheckBox(vert).SetText("Deploy/transfer helper").SetIsChecked(DeployTransferHelper);
	label = UI.CreateLabel(vert).SetText("to make the deploy/transfer helper works the best it is recommended to use percentages attacks/transfers. The mod will override this setting to true unless you uncheck the checkbox below")
	SetOverridePercentage = UI.CreateCheckBox(vert).SetText("Override setting 'Can attack by percentage'").SetIsChecked(OverridePercentage);
end