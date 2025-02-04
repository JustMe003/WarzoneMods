function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	local line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("Number of distributed territories: ").SetColor("#DDDDDD");
	UI.CreateLabel(line).SetText(Mod.Settings.NumTerritories).SetColor("#FFE5B4");
	
	UI.CreateLabel(vert).SetText("The mod distributed territories that were " .. ifElse(Mod.Settings.takeDistributionTerr, "in the distribution", "neutral")).SetColor("#DDDDDD");
	
	UI.CreateLabel(line).SetText("Number of armies on auto distributed territories is the equal to those " .. ifElse(Mod.Settings.setArmiesToInDistribution, "manually distributed", "not in the distribution")).SetColor("#DDDDDD");
end

function ifElse(b, t, f)
	if b then return t; else return f; end	
end
