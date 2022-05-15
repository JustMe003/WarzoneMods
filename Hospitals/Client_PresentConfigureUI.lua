function Client_PresentConfigureUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	local numberOfHospitals = Mod.Settings.numberOfHospitals;
	if numberOfHospitals == nil then numberOfHospitals = 5; end
	local recoverPercentageMinimum = Mod.Settings.recoverPercentageMinimum;
	if recoverPercentageMinimum == nil then recoverPercentageMinimum = 20; end
	local recoverPercentageMaximum = Mod.Settings.recoverPercentageMaximum;
	if recoverPercentageMaximum == nil then recoverPercentageMaximum = 30; end
	local maximumHospitalRange = Mod.Settings.maximumHospitalRange;
	if maximumHospitalRange == nil then maximumHospitalRange = 2; end
	
	textColor = "#DDDDDD";
	grayedOutColor = "#CCCCCC";
		
	UI.CreateLabel(vert).SetText("I recommend to pick your map first before setting up this mod").SetColor(textColor)
	UI.CreateEmpty(vert).SetPreferredHeight(20);
	
	UI.CreateLabel(vert).SetText("Number of hospitals at the start of the game").SetColor(textColor);
	numberOfHospitalsInput = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(numberOfHospitals);
	
	UI.CreateLabel(vert).SetText("Percentage of recovered armies (minimum)").SetColor(textColor);
	recoverPercentageMinimumInput = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(30).SetValue(recoverPercentageMinimum);
	
	UI.CreateLabel(vert).SetText("Percentage of recovered armies (maximum)").SetColor(textColor);
	recoverPercentageMaximuminput = UI.CreateNumberInputField(vert).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(recoverPercentageMaximum);
	
	UI.CreateLabel(vert).SetText("Maximum range of hospitals (hard coded maximum is 5!)").SetColor(textColor);
	maximumHospitalRangeInput = UI.CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(maximumHospitalRange);
	
	percentagesLabel = UI.CreateLabel(vert).SetText(getPercentageString()).SetColor(textColor);
	refreshButton = UI.CreateButton(vert).SetText("Refresh").SetColor("#00DD00").SetOnClick(refeshPercentages);

end

function setColor(input)
	if input.GetIsChecked() then
		return textColor;
	else
		return grayedOutColor;
	end
end

function getPercentageString()
	local str = "the percentages will be (from close range to far range):";
	local minPer = recoverPercentageMinimumInput.GetValue();
	local maxPer = recoverPercentageMaximuminput.GetValue();
	local maxRange = maximumHospitalRangeInput.GetValue() - 1;
	local increment = (maxPer - minPer) / maxRange;
	for i = 0, maxRange do
		str = str .. " " .. (maxPer - increment * i) .. ",";
	end
	return string.sub(str, 1, string.len(str)-1);
end

function refeshPercentages()
	maximumHospitalRangeInput.SetValue(math.min(math.max(maximumHospitalRangeInput.GetValue(), 1), 5));
	percentagesLabel.SetText(getPercentageString());
end