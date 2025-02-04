function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	local line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("Number of distributed territories: ").SetColor("#DDDDDD");
	UI.CreateLabel(line).SetText(Mod.Settings.NumTerritories).SetColor("#FFE5B4");
	
	UI.CreateLabel(vert).SetText("The mod distributed territories that were " .. ifElse(Mod.Settings.takeDistributionTerr, "in distribution", "neutral"));
	
	line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("Number of armies on the auto distributed territories is the same as those in the manual distribution: ").SetColor("#DDDDDD");
	-- createBoolLabel(line, Mod.Settings.setArmiesToInDistribution);
end

function ifElse(b, t, f)
	if b then return t; else return f; end	
end
