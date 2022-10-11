function Client_PresentConfigureUI(rootParent)
	local minMultiplier = Mod.Settings.MinMultiplier;
	local LevelMultiplierIncrement = Mod.Settings.LevelMultiplierIncrement;
	local MaxMultiplier = Mod.Settings.MaxMultiplier;
	if minMultiplier == nil then minMultiplier = 1; end
	if LevelMultiplierIncrement == nil then LevelMultiplierIncrement = 0.2; end
	if MaxMultiplier == nil then MaxMultiplier = 2.0; end
	
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert)
		.SetText("Configure the minimum multiplier (when the player just captured a territory)")
		.SetColor("#AAAAAA");
	setMinMultiplier = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(1)
		.SetWholeNumbers(false)
		.SetValue(minMultiplier);
	UI.CreateLabel(vert)
		.SetText("Configure the maximum multiplier (bonus value * multiplier)")
		.SetColor("#AAAAAA");
	setMaxMultiplier = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(3)
		.SetWholeNumbers(false)
		.SetValue(MaxMultiplier);
	UI.CreateLabel(vert)
		.SetText("Configure the increment of the multiplier each turn")
		.SetColor("#AAAAAA");
	setLevelMultiplierIncrement = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(0.1)
		.SetSliderMaxValue(1)
		.SetWholeNumbers(false)
		.SetValue(LevelMultiplierIncrement);
end
