function Client_PresentConfigureUI(rootParent)
	local TurnsToGetDevPos = Mod.Settings.TurnsToGetDevPos;
	local extraDevKillrate = Mod.Settings.ExtraDevKillrate;
	if TurnsToGetDevPos == nil then TurnsToGetDevPos = 4; end
	if extraDevKillrate == nil then 
		extraDevKillrate = 5; 
	else
		extraDevKillrate = extraDevKillrate * 100;
	end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Each player can build a devensive position every X turns");
    turnsInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(TurnsToGetDevPos);

	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText("Territories with a devensive position have a X% higher devensive killrate")
	killrateInputField = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(extraDevKillrate);
end