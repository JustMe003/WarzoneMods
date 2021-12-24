function Client_SaveConfigureUI(rootParent)
	Mod.Settings.CanGiftToNeutral = CanGiftToNeutralInput.GetIsChecked();
	Mod.Settings.ChargesPerTurn = math.max(math.min(ChargesPerTurnInput.GetValue(), 100), 1);
	Mod.Settings.ChargeAmountPerGift = math.max(math.min(ChargeAmountPerGiftInput.GetValue(), 100), 1);
end