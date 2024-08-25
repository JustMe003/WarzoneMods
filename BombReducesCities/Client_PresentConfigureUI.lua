function Client_PresentConfigureUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert)
		.SetText("The number of cities that are removed from the target territory of the bomb card")
		.SetColor("#DDDDDD");
	
	NumCitiesInput = UI.CreateNumberInputField(vert)
		.SetSliderMinimumValue(1)
		.SetSliderMaximumValue(10)
		.SetValue(Mod.Settings.NumCities or 3);
end