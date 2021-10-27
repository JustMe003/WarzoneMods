
function Client_PresentConfigureUI(rootParent)
	local initialHeigth = Mod.Settings.NonogramHeigth;
	local initialWidth = Mod.Settings.NonogramWidth;
	local initialValueDensity = Mod.Settings.NonogramDensity;
	local localDeploymentsValue = Mod.Settings.LocalDeployments;
	if initialHeigth == nil then initialHeigth = 10; end
	if initialWidth == nil then initialWidth = 10; end
	if initialValueDensity == nil then initialValueDensity = 60; end
	if localDeploymentsValue == nil then localDeploymentsValue = false; end

    local vert = UI.CreateVerticalLayoutGroup(rootParent);
	heigthLabel = UI.CreateLabel(vert)
		.SetText("Specify the heigth of the nonogram:")
		.SetColor("#88FF00");
	setHeigth = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(5)
		.SetSliderMaxValue(20)
		.SetValue(initialHeigth);
    widthLabel = UI.CreateLabel(vert)
		.SetText("Specify the width of the nonogram:")
		.SetColor("#88FF00");
	setWidth = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(5)
		.SetSliderMaxValue(20)
		.SetValue(initialWidth);
	densityLabel = UI.CreateLabel(vert)
		.SetText("Specify the density in percentages (60% or more is recommended!):")
		.SetColor("#88FF00");
	setDensity = UI.CreateNumberInputField(vert)
		.SetSliderMinValue(30)
		.SetSliderMaxValue(70)
		.SetValue(initialValueDensity);
	emptyLabel = UI.CreateLabel(vert).SetText(" ");
	localDeploymentsLabel = UI.CreateLabel(vert)
		.SetText("Check checkbox below to play with custom local deployments")
		.SetColor("#88FF00");
	LocalDeployments = UI.CreateCheckBox(vert)
		.SetText(" ")
		.SetIsChecked(localDeploymentsValue);

end