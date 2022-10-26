function Client_PresentConfigureUI(rootParent)
	local nTurns = Mod.Settings.NTurns;
	if nTurns == nil then nTurns = 3; end
	local income = Mod.Settings.Income;
	if income == nil then income = 1; end
	local vert = UI.CreateVerticalLayoutGroup(rootParent)
	UI.CreateLabel(vert).SetText("The amount of turns it takes to convert a city into a mine").SetColor("#DDDDDD");
	nTurnsInput = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(nTurns);
	UI.CreateLabel(vert).SetText("The amount of income a mine gives").SetColor("#DDDDDD");
	incomeInput = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(income);
	print(nTurns, income);
end