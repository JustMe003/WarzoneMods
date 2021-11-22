
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local horz1 = UI.CreateHorizontalLayoutGroup(vert);
	local horz2 = UI.CreateHorizontalLayoutGroup(vert);
	local horz3 = UI.CreateHorizontalLayoutGroup(vert);
	local horz4 = UI.CreateHorizontalLayoutGroup(vert);
	local horz5 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz1).SetText("only territories that will give you gold / armies are pickable: ").SetColor("#7aba30");
	if Mod.Settings.CustomDistribution == true then UI.CreateLabel(horz1).SetText(Mod.Settings.CustomDistribution).SetColor("#88FF00"); else UI.CreateLabel(horz1).SetText(Mod.Settings.CustomDistribution).SetColor("#801111"); end
	UI.CreateLabel(horz2).SetText("Heigth of nonogram: ").SetColor("#7aba30");
	UI.CreateLabel(horz2).SetText(Mod.Settings.NonogramHeigth).SetColor("#00AA" .. (tonumber(Mod.Settings.NonogramHeigth / 2 - 1)) .. (tonumber(Mod.Settings.NonogramHeigth / 2 - 1)));
	UI.CreateLabel(horz3).SetText("Width of nonogram: ").SetColor("#7aba30");
	UI.CreateLabel(horz3).SetText(Mod.Settings.NonogramWidth).SetColor("#00AA" .. (tonumber(Mod.Settings.NonogramWidth / 2 - 1)) .. (tonumber(Mod.Settings.NonogramWidth / 2 - 1)));
	UI.CreateLabel(horz4).SetText("Density of nonogram: ").SetColor("#7aba30");
	UI.CreateLabel(horz4).SetText(Mod.Settings.NonogramDensity).SetColor("#FF00" .. (100 - Mod.Settings.NonogramDensity));
	UI.CreateLabel(horz5).SetText("Custom local deployments: ").SetColor("#7aba30");
	if Mod.Settings.LocalDeployments == true then UI.CreateLabel(horz5).SetText(Mod.Settings.LocalDeployments).SetColor("#88FF00"); else UI.CreateLabel(horz5).SetText(Mod.Settings.LocalDeployments).SetColor("#801111"); end

end

