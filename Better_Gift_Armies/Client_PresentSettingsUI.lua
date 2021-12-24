require("UI");

function Client_PresentSettingsUI(rootParent)
	init()
	colors = initColors();
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local line = getNewHorz(vert);
	createLabel(line, "Can gift armies to neutral: ", colors.TextColor);
	local color = colors.TrueColor;
	if not Mod.Settings.CanGiftToNeutral then color = colors.FalseColor; end
	createLabel(line, tostring(Mod.Settings.CanGiftToNeutral), color);
	line = getNewHorz(vert);
	createLabel(line, "Charges each player get per turn: ", colors.TextColor);
	createLabel(line, Mod.Settings.ChargesPerTurn, colors.NumberColor);
	line = getNewHorz(vert);
	createLabel(line, "Each army gift costs ", colors.TextColor);
	createLabel(line, Mod.Settings.ChargeAmountPerGift, colors.NumberColor);
	createLabel(line, "charges", colors.TextColor);
end