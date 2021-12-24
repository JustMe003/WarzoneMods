require("UI");

function Client_PresentConfigureUI(rootParent)
	init()
	colors = initColors();
	
	
	CanGiftToNeutral = Mod.Settings.CanGiftToNeutral;
	ChargesPerTurn = Mod.Settings.ChargesPerTurn;
	ChargeAmountPerGift = Mod.Settings.ChargeAmountPerGift;
	if CanGiftToNeutral == nil then CanGiftToNeutral = false; end
	if ChargesPerTurn == nil then ChargesPerTurn = 3; end
	if ChargeAmountPerGift == nil then ChargeAmountPerGift = 5; end
	
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local line = getNewHorz(vert);
	createLabel(line, "Allow players to gift to neutral territories: ", colors.TextColor);
	CanGiftToNeutralInput = createCheckBox(line, CanGiftToNeutral, " ");
	local line = getNewHorz(vert);
	createLabel(line, "Amount of charges each player get per turn:  ", colors.TextColor);
	ChargesPerTurnInput = createNumberInputField(line, ChargesPerTurn, 1, 5);
	local line = getNewHorz(vert);
	createLabel(line, "The amount of charges you need for 1 army gift: ", colors.TextColor);
	ChargeAmountPerGiftInput = createNumberInputField(line, ChargeAmountPerGift, 1, 10);
end