
function Client_PresentConfigureUI(rootParent)
	local numTerritories = Mod.Settings.NumTerritories;
	if (numTerritories == nil) then numTerritories = 1; end
	local takeDistributionTerr = Mod.Settings.takeDistributionTerr;
	if (takeDistributionTerr == nil) then takeDistributionTerr = false; end
	local setArmiesToInDistribution = Mod.Settings.setArmiesToInDistribution;
	if (setArmiesToInDistribution == nil) then setArmiesToInDistribution = true; end

    
	local vert = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Number of territories to auto distribute to each player").SetColor("#DDDDDD");
    numTerritoriesInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(numTerritories);
	
	local row2 = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	takeDistributionTerrInputField = UI.CreateCheckBox(row2)
		.SetText(" ")
		.SetIsChecked(takeDistributionTerr);
	UI.CreateLabel(row2)
		.SetText("Use territories in distribution")
		.SetColor("#DDDDDD");
	UI.CreateEmpty(row2)
		.SetFlexibleWidth(1);
	UI.CreateButton(row2)
		.SetText("?")
		.SetColor("#4169E1")
		.SetOnClick(function()
			UI.Alert("When checked, the mod will distribute territories that would be otherwise in the distribution. If not checked, it will only auto distribute neutral territories");
		end);

	local row3 = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	setArmiesToInDistributionInputField = UI.CreateCheckBox(row3)
		.SetText(" ")
		.SetIsChecked(setArmiesToInDistribution);
	UI.CreateLabel(row3)
		.SetText("Set armies to corresponding setting")
		.SetColor("#DDDDDD");
	UI.CreateEmpty(row3)
		.SetFlexibleWidth(1);
	UI.CreateButton(row3)
		.SetText("?")
		.SetColor("#4169E1")
		.SetOnClick(function()
			UI.Alert("If checked, the mod will set the armies it distributes equal to the number of armies you'll get manually distributed. When not checked, the mod will set the armies of the territories it distributes equal to the territories that are not in the distribution");
		end);
		
end