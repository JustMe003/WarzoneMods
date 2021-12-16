function initiatePlayerIncome(game)
	returnList = {};
	for playerID, _ in pairs(game.ClientGame.Game.PlayingPlayers) do
		returnList[playerID] = 0;
	end
	return returnList;
end

function playerHasBonus(standing, listOfTerr)
	local playerID = 0;
	for _, terrID in pairs(listOfTerr) do
		local terr = standing.Territories[terrID];
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and playerID == 0 then
			playerID = terr.OwnerPlayerID;
		elseif terr.OwnerPlayerID ~= playerID or terr.OwnerPlayerID == WL.PlayerID.Neutral then
			return false;
		end
	end
	return true;
end

function getPlayer(standing, list)
	for _, terrID in pairs(list) do
		return standing.Territories[terrID].OwnerPlayerID;
	end
end

function firstTurnLD(standing, listOfTerr)
	for _, terrID in pairs(listOfTerr) do
		local terr = standing.Territories[terrID];
		terr.NumArmies = terr.NumArmies.Add(WL.Armies.Create(1));
		standing.Territories[terrID] = terr;
	end
end

function localDeployments (game, addNewOrder, listOfTerr, modifiedTerritories, touchedTerritories, index)
	for _, terrID in pairs(listOfTerr) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		terrMod = WL.TerritoryModification.Create(terr.ID);
		terrMod.SetOwnerOpt = terr.OwnerPlayerID;
		if touchedTerritories[terrID] ~= nil then
			terrMod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + 2;
			modifiedTerritories[touchedTerritories[terrID]] = terrMod; -- Overwrites the previous modification
		else
			terrMod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + 1;
			table.insert(modifiedTerritories, terrMod);
			touchedTerritories[terrID] = index;
			index = index + 1;
		end
	end
	return modifiedTerritories, touchedTerritories, index;
end

function grantIncome(game, addNewOrder, playerIncome)
	if game.ServerGame.Settings.CommerceGame == true then
		for _, player in pairs(game.ServerGame.Game.PlayingPlayers)do
			if playerIncome[player.ID] ~= 0 then
				local moneyforplayer = {};
				moneyforplayer[player.ID] = {};
				moneyforplayer[player.ID][WL.ResourceType.Gold] = playerIncome[player.ID] + game.ServerGame.LatestTurnStanding.NumResources(player.ID,WL.ResourceType.Gold);
				addNewOrder(WL.GameOrderEvent.Create(player.ID, "Recieved " .. playerIncome[player.ID] .. " gold from bonuses", {}, {},moneyforplayer));
			end
		end
		if game.ServerGame.Game.NumberOfTurns == 0 then
			for playerID, value in pairs(Mod.PublicGameData.FTI) do
				local moneyforplayer = {};
				moneyforplayer[playerID] = {};
				moneyforplayer[playerID][WL.ResourceType.Gold] = playerIncome[playerID] + value + game.ServerGame.LatestTurnStanding.NumResources(playerID,WL.ResourceType.Gold);
				addNewOrder(WL.GameOrderEvent.Create(playerID, "Recieved " .. value .. " additional gold from bonuses from turn 0", {}, {},moneyforplayer));
			end
		end
	end
end