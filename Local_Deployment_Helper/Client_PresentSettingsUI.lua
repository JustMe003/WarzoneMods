require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
	local vert = GetRoot();
	local textcolor = GetColors().TextColor;
	CreateLabel(vert).SetText("Automated bonus overriding: " .. tostring(Mod.Settings.BonusOverrider)).SetColor(textcolor);
	CreateLabel(vert).SetText("Overridden 'can attack by percentage' setting: " .. tostring(Mod.Settings.OverridePercentage)).SetColor(textcolor); 
end