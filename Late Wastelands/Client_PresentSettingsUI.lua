function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	if Mod.Settings.IsCustomScenario then
		UI.CreateLabel(vert).SetText("If this game uses a custom scenario then this are the wastelands settings:\nNumber of wastelands: " .. Mod.Settings.NumOfWastelands .. "\nSize of wastelands: " .. Mod.Settings.WastelandSize);
	else
		UI.CreateLabel(vert).SetText("This mod uses the normal, Warzone wastelands settings.");
	end
end