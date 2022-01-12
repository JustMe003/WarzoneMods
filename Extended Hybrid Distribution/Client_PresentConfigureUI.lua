function Client_PresentConfigureUI(rootParent)
	
	distributionTerritories = Mod.Settings.distributionTerritories;
	if distributionTerritories == nil then distributionTerritories = false; end
	additionalTerritories = Mod.Settings.additionalTerritories;
	if additionalTerritories == nil then additionalTerritories = 3; end
	takeTurnsPicking = Mod.Settings.takeTurnsPicking;
	if takeTurnsPicking == nil then takeTurnsPicking = false; end
	numberOfGroups = Mod.Settings.numberOfGroups;
	if numberOfGroups == nil then numberOfGroups = 2; end
	
	
	
	textColor = "#CCCCCC";
	notInteractableColor = "#CC0000";
	
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText("Note that this mod only really works with no fog, light fog and dense fog! When another fog is being used the mod will overwrite this to be light fog").SetColor("#CC0000");
	updateLabel = UI.CreateLabel(vert).SetText("Click the refresh button to see how long the distribution phase will last").SetColor("#9999FF");
	warningLabel = UI.CreateLabel(vert).SetText(" ").SetColor(notInteractableColor)
	
	UI.CreateEmpty(vert).SetPreferredHeight(20);
	
	row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Territories can only be chosen from territories in the distribution (indicated by a hospital)").SetColor(textColor);
	distributionTerritoriesOnly = UI.CreateCheckBox(row1).SetText(" ").SetIsChecked(distributionTerritories);
	
	UI.CreateLabel(vert).SetText("Fill in how many additional territories each player gets").SetColor(textColor);
	territoryCount = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(additionalTerritories);

	row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText("Not all players pick in the same turn").SetColor(textColor);
	splitDistribution = UI.CreateCheckBox(row2).SetText(" ").SetIsChecked(takeTurnsPicking);
	
	groupPlayerLabel = UI.CreateLabel(vert).SetText("Fill in how many groups of players the mod will make for the extended distribution stage").SetColor(isInteractable());
	groupPlayers = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(numberOfGroups).SetInteractable(splitDistribution.GetIsChecked());
	
	UI.CreateButton(vert).SetText("refresh").SetColor("#00FF00").SetOnClick(refresh);
	
	splitDistribution.SetOnValueChanged(changeOfSplit);
	
end

function refresh()
	local numberOfTurns = 1;
	if splitDistribution.GetIsChecked() then
		numberOfTurns = groupPlayers.GetValue();
	end
	numberOfTurns = numberOfTurns * territoryCount.GetValue();
	updateLabel.SetText("The distribution phase will take " .. numberOfTurns .. " turns");
	if numberOfTurns > 10 then
		warningLabel.SetText("I recommend to not have the distribution phase take more than 10 turns");
	else
		warningLabel.SetText(" ");
	end
	
end

function changeOfSplit()
	if splitDistribution.GetIsChecked() then
		groupPlayerLabel.SetColor(textColor);
		groupPlayers.SetInteractable(true)
	else
		groupPlayerLabel.SetColor(notInteractableColor);
		groupPlayers.SetInteractable(false)
	end
end

function isInteractable()
	if splitDistribution.GetIsChecked() then
		return textColor;
	else
		return notInteractableColor;
	end
end