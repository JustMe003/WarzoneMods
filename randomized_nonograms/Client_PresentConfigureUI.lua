require("UI")

function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
	local textColor = GetColors().TextColor;
	local customDistribution = Mod.Settings.CustomDistribution;
	local initialValueDensity = Mod.Settings.NonogramDensity;
	if customDistribution == nil then customDistribution = false; end
	if initialValueDensity == nil then initialValueDensity = 60; end
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	CreateLabel(vert).SetText("This option will set the distribution to manual, everyone can see the solution of the nonogram back in the history").SetColor(textColor);
	CreateLabel(vert).SetText("Only make the territories that will give you gold / armies pickable").SetColor(textColor);
	setCustomDistribution = createCheckBox(vert).SetIsChecked(customDistribution).SetText(" ");
	CreateLabel(line).SetText("Specify the density in percentages (60% or more is recommended!)").SetColor(textColor);
	setDensity = CreateNumberInputField(vert).SetSliderMinValue(25).SetSliderMaxValue(100).SetValue(initialValueDensity);
	CreateLabel(vert).SetText("Check checkbox below to play with custom local deployments").SetColor(textColor);
end