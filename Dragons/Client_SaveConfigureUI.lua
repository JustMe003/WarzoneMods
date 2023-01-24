function Client_SaveConfigureUI(alert)
    if currentDragon ~= nil then
        saveDragon(currentDragon, dragonInputs);
    end
	Mod.Settings.Dragons = dragons;
end