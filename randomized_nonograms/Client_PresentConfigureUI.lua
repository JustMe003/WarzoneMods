
function Client_PresentConfigureUI(rootParent)
	local initialHeigth = Mod.Settings.NonogramHeigth;
	local initialWidth = Mod.Settings.NonogramWidth;
	local initialValueDensity = Mod.Settings.NonogramDensity;
	local localDeploymentsValue = Mod.Settings.LocalDeployments;
	if initialHeigth == nil then initialHeigth = 10; end
	if initialWidth == nil then initialWidth = 10; end
	if initialValueDensity == nil then initialValueDensity = 50; end
	if localDeploymentsValue == nil then localDeploymentsValue = false; end

    local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Random +/- limit');
    widthLabel = UI.CreateLabel(vert)
		.SetText("Specify the width of the nonogram:")
		.SetColor("#00FF00");
	setWidth = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(5)
		.SetSliderMaxValue(20)
		.SetValue(initialWidth);
	setHeigth = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(5)
		.SetSliderMaxValue(20)
		.SetValue(initialHeigth);
	setDensity = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(30)
		.SetSliderMaxValue(70)
		.SetValue(initialValueDensity);
	LocalDeployments = UI.CreateCheckBox(vert)
		.SetText("Check this to play with custom local deployments")
		.SetIsChecked(localDeploymentsValue);

end