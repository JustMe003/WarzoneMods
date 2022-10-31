
function Client_SaveConfigureUI(alert)
	Mod.Settings.FlagsPerTeam = getValue(amountOfFlags);
	if Mod.Settings.FlagsPerTeam < 1 then alert("The number of flags (" .. Mod.Settings.FlagsPerTeam .. ") cannot be lower than 1"); end
	Mod.Settings.NFlagsForLose = getValue(loseCondition);
	if Mod.Settings.NFlagsForLose < 1 or Mod.Settings.NFlagsForLose > Mod.Settings.FlagsPerTeam then alert("The number of flags a team has to lose to be eliminated (" .. Mod.Settings.NFlagsForLose .. ") cannot be lower than 1 and can be at most equal to the number of flags per team, " .. Mod.Settings.FlagsPerTeam); end
	Mod.Settings.IncomeBoost = getValue(incomeIncrement);
	Mod.Settings.Cooldown = getValue(moveCooldown);
	if Mod.Settings.Cooldown < 0 then alert("The cooldown (" .. Mod.Settings.Cooldown .. ") cannot be lower than 0"); end
end