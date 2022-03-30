function Client_SaveConfigureUI(alert)
    local turns = turnsInputField.GetValue();
	local killrate = killrateInputField.GetValue();

    if turns < 1 then alert("Turns to get a devensive position must be positive"); end
	if killrate < 1 then alert("Territories with a devensive position must have an extra killrate higher than 1%"); end
	
	Mod.Settings.ExtraDevKillrate = killrate / 100;
    Mod.Settings.TurnsToGetDevPos = turns;
end