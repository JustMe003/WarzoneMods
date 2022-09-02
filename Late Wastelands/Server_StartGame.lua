function Server_StartGame(game, standing)
	local numOfWastelands = game.Settings.NumberOfWastelands;
	local wastelandSize = game.Settings.WastelandSize;
	if game.Settings.CustomScenario ~= nil and Mod.Settings.IsCustomScenario then numOfWastelands = Mod.Settings.NumOfWastelands; wastelandSize = Mod.Settings.WastelandSize;
	elseif game.Settings.AutomaticTerritoryDistribution then return; end
	
	local terrList = {};
	for _, terr in pairs(standing.Territories) do
		if terr.IsNeutral then
			table.insert(terrList, terr.ID);
		end
	end	
	
	for i = 1, math.min(numOfWastelands, #terrList) do
		local rand = math.random(#terrList);
		local terr = standing.Territories[terrList[rand]];
		terr.NumArmies = WL.Armies.Create(wastelandSize, {});
		standing.Territories[terrList[rand]] = terr;
		table.remove(terrList, rand);
	end
end