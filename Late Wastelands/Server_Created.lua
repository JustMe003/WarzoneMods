function Server_Created(game, settings)
	if settings.CustomScenario ~= nil and Mod.Settings.IsCustomScenario then
		settings.WastelandSize = Mod.Settings.WastelandSize;
		settings.NumberOfWastelands = Mod.Settings.NumOfWastelands;
	end
end