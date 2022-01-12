function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	data.numberOfGroups = math.min(#game.ServerGame.CyclicMoveOrder, Mod.Settings.numberOfGroups);
	data.DurationDistributionStage = data.numberOfGroups * Mod.Settings.additionalTerritories;
	data.AbortDistribution = false;
	
	if data.numberOfGroups > 1 then
		local playersPerGroup = math.ceil(#game.ServerGame.CyclicMoveOrder /  data.numberOfGroups)
		local playerCount = 0
		local groupCount = 1
		local group = {};
		local groups = {};
		for _, ID in pairs(game.ServerGame.CyclicMoveOrder) do
			table.insert(group, ID)
			playerCount = playerCount + 1;
			if playerCount == playersPerGroup then
				table.insert(groups, group)
				group = {};
				playerCount = 0;
				groupCount = groupCount + 1;
			end
		end
		if #group ~= 0 then table.insert(groups, group); end
		data.Groups = groups;
		data.numberOfGroups = #data.Groups;
	end
	
	if Mod.Settings.distributionTerritories == true then
		local distributionTerritories = {};
		for terrID, disTerr in pairs(game.ServerGame.DistributionStanding.Territories) do
			if disTerr.OwnerPlayerID == WL.PlayerID.AvailableForDistribution and standing.Territories[terrID].OwnerPlayerID == WL.PlayerID.Neutral then
				table.insert(distributionTerritories, terrID);
				structures = standing.Territories[terrID].Structures;
				if structures == nil then structures = {}; end
				if structures[WL.StructureType.Hospital] == nil then 
					structures[WL.StructureType.Hospital] = 1; 
				else
					structures[WL.StructureType.Hospital] = structures[WL.StructureType.Hospital] + 1;
				end
				standing.Territories[terrID].Structures = structures;
			end
		end
		data.distributionTerritories = distributionTerritories;
	end
	Mod.PublicGameData = data;
end