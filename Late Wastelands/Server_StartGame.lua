function Server_StartGame(game, standing)
	if game.Settings.AutomaticTerritoryDistribution then return; end
	
	local terrList = {};
	for _, terr in pairs(standing.Territories) do
		if terr.IsNeutral then
			table.insert(terrList, terr.ID);
		end
	end


	
	for i = 1, math.min(game.Settings.NumberOfWastelands, #terrList) do
		local rand = math.random(#terrList);
		local terr = standing.Territories[terrList[rand]];
		terr.NumArmies = WL.Armies.Create(game.Settings.WastelandSize, {});
		standing.Territories[terrList[rand]] = terr;
		table.remove(terrList, rand);
	end
end