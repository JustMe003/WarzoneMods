
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.MaxAttacks;
	if initialValue == nil then
		initialValue = 5;
	end
    
   	local horz = UI.CreateHorizontalLayoutGroup(rootParent);
	UI.CreateLabel(horz).SetText('Maximum transfer range (1 is a normal transfer)');
   	InputMaxAttacks = UI.CreateNumberInputField(horz).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(initialValue);
end