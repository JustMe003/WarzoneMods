require("UI");
function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
	local vert = GetRoot();
	BonusOverrider = Mod.Settings.BonusOverrider;
	OverridePercentage = Mod.Settings.OverridePercentage;
	if BonusOverrider == nil then BonusOverrider = true end
	if OverridePercentage == nil then OverridePercentage = true end
	
	SetBonusOverrider = CreateCheckBox(vert).SetText("Automate the bonus overwriting").SetIsChecked(BonusOverrider)
	label = CreateLabel(vert).SetText("to make the deploy/transfer helper works the best it is recommended to use percentages attacks/transfers. The mod will override this setting to true unless you uncheck the checkbox below").SetColor(GetColors().TextColor);
	SetOverridePercentage = CreateCheckBox(vert).SetText("Override setting 'Can attack by percentage'").SetIsChecked(OverridePercentage);
end