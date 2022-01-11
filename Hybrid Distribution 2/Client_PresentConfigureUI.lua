
function Client_PresentConfigureUI(rootParent)
	local numTerritories = Mod.Settings.NumTerritories;
	if (numTerritories == nil) then numTerritories = 1; end
	local takeDistributionTerr = Mod.Settings.takeDistributionTerr;
	if (takeDistributionTerr == nil) then takeDistributionTerr = false; end
	local setArmiesToInDistribution = Mod.Settings.setArmiesToInDistribution;
	if (setArmiesToInDistribution == nil) then setArmiesToInDistribution = true; end

    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Number of territories to auto distribute to each player");
    numTerritoriesInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(numTerritories);
	
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	takeDistributionTerrInputField = UI.CreateCheckBox(row2)
		.SetText("Check this checkbox if the auto distributed territories are chosen from territories in the distribution")
		.SetIsChecked(takeDistributionTerr);

	local row3 = UI.CreateHorizontalLayoutGroup(vert);
	setArmiesToInDistributionInputField = UI.CreateCheckBox(row3)
		.SetText("Set the armies of the auto distributed territories to it corresponding setting: 'Number of armies each neutral territory starts with (applies to territories that are in the distribution, but a player did not end up with)'")
		.SetIsChecked(setArmiesToInDistribution);
	UI.CreateLabel(vert).SetText("Note that with the box above unchecked the number of armies will default to that of those territories not in the distribution");
	
	UI.CreateLabel(vert).SetText("Note: You must set the game's distribution mode to Manual for this mod to work properly");
			
end