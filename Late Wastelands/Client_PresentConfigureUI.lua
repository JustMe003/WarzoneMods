function Client_PresentConfigureUI(rootParent)
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	isCustomScenario = Mod.Settings.IsCustomScenario; if isCustomScenario == nil then isCustomScenario = false; end
	numOfWastelands = Mod.Settings.NumOfWastelands; if numOfWastelands == nil then numOfWastelands = 5; end
	wastelandSize = Mod.Settings.WastelandSize; if wastelandSize == nil then wastelandSize = 100; end
	showConfig()
end

function showConfig()
	isCustomScenarioInput = UI.CreateCheckBox(vert).SetText("My game uses a custom scenario").SetIsChecked(isCustomScenario).SetOnValueChanged(refresh);
	if isCustomScenarioInput.GetIsChecked() then
		label1 = UI.CreateLabel(vert).SetText("The number of wastelands");
		numOfWastelandsInput = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(numOfWastelands);
		label2 = UI.CreateLabel(vert).SetText("The size of the wastelands");
		wastelandSizeInput = UI.CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(wastelandSize);
	end
end

function refresh()
	if isCustomScenario then
		numOfWastelands = numOfWastelandsInput.GetValue();
		wastelandSize = wastelandSizeInput.GetValue();
		UI.Destroy(label1);
		UI.Destroy(numOfWastelandsInput);
		UI.Destroy(label2);
		UI.Destroy(wastelandSizeInput);
		numOfWastelandsInput = nil;
		wastelandSizeInput = nil;
	end
	isCustomScenario = isCustomScenarioInput.GetIsChecked();
	UI.Destroy(isCustomScenarioInput);
	showConfig();
end