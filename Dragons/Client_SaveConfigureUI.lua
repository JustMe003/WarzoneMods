function Client_SaveConfigureUI(alert)
    if currentDragon ~= nil then
        saveInputs(currentDragon, dragonInputs);
    end
	Mod.Settings.Dragons = dragons;
end