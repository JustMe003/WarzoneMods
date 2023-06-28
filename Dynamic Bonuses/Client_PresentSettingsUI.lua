function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("Minimum multiplier: " .. rounding(Mod.Settings.MinMultiplier, 2)).SetColor("#8EBE57");
    UI.CreateLabel(vert).SetText("Maximum multiplier: " .. rounding(Mod.Settings.MaxMultiplier, 2)).SetColor("#8EBE57");
    UI.CreateLabel(vert).SetText("Multiplier increment each turn: " .. rounding(Mod.Settings.LevelMultiplierIncrement, 2)).SetColor("#8EBE57");
end

function rounding(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
