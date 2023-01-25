function Client_SaveConfigureUI(alert)
    Mod.Settings.Cost = costInput.GetValue();
    if Mod.Settings.Cost < 0 then alert("The Landmine cost cannot be lower than 0"); end
    Mod.Settings.CostIncrease = costIncreaseInput.GetValue();
    if Mod.Settings.CostIncrease < 0 then alert("The cost increase cannot be lower than 0"); end
	Mod.Settings.DamageAbsorbed = damageAbsorbedInput.GetValue();
    if Mod.Settings.DamageAbsorbed < 0 then alert("The damage absorbed by a Landmine must be greater than 0"); end
end