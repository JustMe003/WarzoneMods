
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.RandomizeAmount;
	if initialValue == nil then
		initialValue = 10;
	end
    
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Random +/- limit');
    setWidth = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(5)
		.SetSliderMaxValue(20)
		.SetValue(initialValue);
	setHeigth = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(5)
		.SetSliderMaxValue(20)
		.SetValue(initialValue);
	setDensity = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(30)
		.SetSliderMaxValue(70)
		.SetValue(initialValue*5);

end