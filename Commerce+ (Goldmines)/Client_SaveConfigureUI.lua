function Client_SaveConfigureUI(alert)
	Mod.Settings.NTurns = nTurnsInput.GetValue();
	Mod.Settings.Income = incomeInput.GetValue();
	if Mod.Settings.NTurns < 1 then alert("The number of turns it takes to build a mine cannot be smaller than 1"); end
	if Mod.Settings.Income < 1 then alert("Due to a technical issue you cannot set the income to less than 1"); end
end