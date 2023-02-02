function Client_SaveConfigureUI(alert)
    if currentDragon ~= nil then
        saveDragon(dragons[currentDragon], dragonInputs);
    end
	Mod.Settings.Dragons = dragons;
    if dragonPlacementsInputs ~= nil then
        savePlacement();
    end
    Mod.Settings.DragonPlacements = placements;
end