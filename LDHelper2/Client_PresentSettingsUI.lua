function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText("Automated bonus overriding: " .. tostring(Mod.Settings.BonusOverrider));
	UI.CreateLabel(vert).SetText("Deploy/transfer helper: " .. tostring(Mod.Settings.DeployTransferHelper));
	if Mod.Settings.DeployTransferHelper == true then UI.CreateLabel(vert).SetText("Override 'can attack by percentage' setting:" .. tostring(Mod.Settings.OverridePercentage)); end
end