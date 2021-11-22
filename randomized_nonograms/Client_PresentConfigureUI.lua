
function Client_PresentConfigureUI(rootParent)
	local customDistribution = Mod.Settings.CustomDistribution;
	local initialHeigth = Mod.Settings.NonogramHeigth;
	local initialWidth = Mod.Settings.NonogramWidth;
	local initialValueDensity = Mod.Settings.NonogramDensity;
	local localDeploymentsValue = Mod.Settings.LocalDeployments;
	if customDistribution == nil then customDistribution = false; end
	if initialHeigth == nil then initialHeigth = 10; end
	if initialWidth == nil then initialWidth = 10; end
	if initialValueDensity == nil then initialValueDensity = 60; end
	if localDeploymentsValue == nil then localDeploymentsValue = false; end

    local vert = UI.CreateVerticalLayoutGroup(rootParent);
	distributionLabel1 = UI.CreateLabel(vert)
		.SetText("This option will set the distribution to manual, everyone can see the solution of the nonogram back in the history")
		.SetColor("#88FF00");
	distributionLabel2 = UI.CreateLabel(vert)
		.SetText("Only make the territories that will give you gold / armies pickable")
		.SetColor("#88FF00");
	setCustomDistribution = UI.CreateCheckBox(vert)
		.SetText(" ")
		.SetIsChecked(customDistribution);
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
	local hor = UI.CreateHorizontalLayoutGroup(vert);
	densityLabel = UI.CreateLabel(hor)
		.SetText("Specify the density in percentages ")
		.SetColor("#88FF00");
	densityWarning = UI.CreateLabel(hor)
		.SetText("(60% or more is recommended!)")
		.SetColor("#FF0000");
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