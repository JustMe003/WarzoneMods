require("UI")
local colors = initColors();

function Client_PresentConfigureUI(rootParent)
	init();
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
	
	-- vert is the parent of the whole layout
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
	createLabel(vert, "This option will set the distribution to manual, everyone can see the solution of the nonogram back in the history", colors.Ivory);
	createLabel(vert, "Only make the territories that will give you gold / armies pickable", colors.TextColor);
	setCustomDistribution = createCheckBox(vert, customDistribution, " ");
	createLabel(vert, "Specify the heigth of the nonogram:", colors.TextColor);
	setHeigth = createNumberInputField(vert, initialHeigth, 5, 20);
	createLabel(vert, "Specify the width of the nonogram:", colors.TextColor);
	setWidth = createNumberInputField(vert, initialWidth, 5, 20);
	line = getNewHorz(vert)
	createLabel(line, "Specify the density in percentages ", colors.TextColor);
	createLabel(line, "(60% or more is recommended!)", colors.WarningNumberColor);
	setDensity = createNumberInputField(vert, initialValueDensity, 30, 80);
	createLabel(vert, " ", colors.TextColor);
	createLabel(vert, "Check checkbox below to play with custom local deployments", colors.TextColor);
	LocalDeployments = createCheckBox(vert, localDeploymentsValue, " ");
end