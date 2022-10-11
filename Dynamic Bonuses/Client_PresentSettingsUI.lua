function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("Minimum multiplier: " .. Mod.Settings.MinMultiplier).SetColor("#8EBE57");
    UI.CreateLabel(vert).SetText("Maximum multiplier: " .. Mod.Settings.MaxMultiplier).SetColor("#8EBE57");
    UI.CreateLabel(vert).SetText("Multiplier increment each turn: " .. Mod.Settings.LevelMultiplierIncrement).SetColor("#8EBE57");
end

