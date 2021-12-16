require("UI");
local colors = initColors();

function Client_PresentSettingsUI(rootParent)
	init();
	-- vert is the parent of the whole layout
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local color;
	line = getNewHorz(vert);
	createLabel(line, "only territories that will give you gold / armies are pickable: ", colors.TextColor);
	if Mod.Settings.CustomDistribution == true then color = colors.TrueColor; else color = colors.FalseColor; end
	createLabel(line, Mod.Settings.CustomDistribution, color);
	line = getNewHorz(vert);
	createLabel(line, "Heigth of nonogram: ", colors.TextColor);
	createLabel(line, Mod.Settings.NonogramHeigth, colors.NumberColor);
	line = getNewHorz(vert);
	createLabel(line, "Width of nonogram: ", colors.TextColor);
	createLabel(line, Mod.Settings.NonogramWidth, colors.NumberColor);
	line = getNewHorz(vert);
	createLabel(line, "Density of nonogram: ", colors.TextColor);
	createLabel(line, Mod.Settings.NonogramDensity, colors.TextColor);
	line = getNewHorz(vert);
	createLabel(line, "Custom local deployments: ", colors.TextColor);
	if Mod.Settings.LocalDeployments == true then color = colors.TrueColor; else color = colors.FalseColor; end
	createLabel(line, Mod.Settings.LocalDeployments, color);
end


