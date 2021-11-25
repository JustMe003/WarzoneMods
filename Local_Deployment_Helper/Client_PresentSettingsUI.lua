function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText("Automated bonus overriding: " .. tostring(Mod.Settings.BonusOverrider));
	UI.CreateLabel(vert).SetText("Deploy/transfer helper: " .. tostring(Mod.Settings.DeployTransferHelper))
end