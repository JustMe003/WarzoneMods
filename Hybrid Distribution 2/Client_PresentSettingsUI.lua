function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText("Number of territories to auto distribute to each player: " .. Mod.Settings.NumTerritories);
	UI.CreateLabel(vert).SetText("Auto distributed territories are chosen from territories in distribution: " .. tostring(Mod.Settings.takeDistributionTerr))
	UI.CreateLabel(vert).SetText("Number of armies on the auto distributed territories is the same as those in the manual distribution: " .. tostring(Mod.Settings.setArmiesToInDistribution))
end