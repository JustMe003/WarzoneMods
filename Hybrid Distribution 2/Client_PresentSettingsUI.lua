function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	local line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("Number of distributed territories: ").SetColor("#DDDDDD");
	UI.CreateLabel(line).SetText(Mod.Settings.NumTerritories).SetColor("#FFE5B4");
	
	line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("Distribute territories in distribution: ").SetColor("#DDDDDD");
	createBoolLabel(line, Mod.Settings.takeDistributionTerr);
	
	line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("Number of armies on the auto distributed territories is the same as those in the manual distribution: ")
	createBoolLabel(line, Mod.Settings.setArmiesToInDistribution);
end

function createBoolLabel(line, b)
	UI.CreateLabel(line).SetText(getBoolText(b)).SetColor(getBoolColor(b));
end

function getBoolText(b)
	if b then 
		return "Yes";
	end
	return "No";
end

function getBoolColor(b)
	if b then
		return "#00FF00";
	end
	return "#FF0000";
end