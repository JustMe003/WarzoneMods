function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText("The amount of turns it takes to build a goldmine: " .. Mod.Settings.NTurns).SetColor("#DDDDDD");
	UI.CreateLabel(vert).SetText("The amount of income 1 goldmine gives: " .. Mod.Settings.Income).SetColor("#DDDDDD");
end