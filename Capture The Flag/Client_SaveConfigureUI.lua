
function Client_SaveConfigureUI(alert)
	Mod.Settings.FlagsPerTeam = getValue(amountOfFlags);
	Mod.Settings.NFlagsForLose = getValue(loseCondition);
	Mod.Settings.IncomeBoost = getValue(incomeIncrement);
end