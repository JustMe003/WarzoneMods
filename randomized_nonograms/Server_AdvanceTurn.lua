function Server_AdvanceTurn_End(Game, addNewOrder)
	local publicGameData = Mod.PublicGameData;
	bonuses = publicGameData.Bonuses;
	local player_income = initiate_player_income(Game);
	local modifiedTerritories = {};
	for bonusID, list in pairs(bonuses) do
		if player_has_bonus(Game, list) then
			if Mod.Settings.LocalDeployments == true then
				modifiedTerritories = local_deployments(Game, addNewOrder, list, modifiedTerritories);
			else
				playerID = get_player(Game, list);
				player_income[playerID] = player_income[playerID] + #list;
			end
		end
	end
	grant_income(Game, addNewOrder, player_income);
end

function get_player(game, list)
	for _, terrID in pairs(list) do
		return game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID;
	end
end

function initiate_player_income(game)
	returnList = {};
	for playerID, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		returnList[playerID] = 0;
	end
	return returnList;
end

function player_has_bonus(game, list_of_terr)
	local playerID = 0;
	for _, terrID in pairs(list_of_terr) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and playerID == 0 then
			playerID = terr.OwnerPlayerID;
		elseif terr.OwnerPlayerID ~= playerID or terr.OwnerPlayerID == WL.PlayerID.Neutral then
			return false;
		end
	end
	return true;
end

function local_deployments (game, addNewOrder, list_of_terr, modifiedTerritories)
	for _, terrID in pairs(list_of_terr) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		terrMod = WL.TerritoryModification.Create(terr.ID);
		terrMod.SetOwnerOpt = terr.OwnerPlayerID;
		if isModified(terrID, modifiedTerritories) then
			terrMod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + 2;
		else
			terrMod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + 1;
		end
		addNewOrder(WL.GameOrderEvent.Create(terr.OwnerPlayerID,"added armies",{},{terrMod}));
		table.insert(modifiedTerritories, terrID);
	end
	return modifiedTerritories;
end

function isModified(terrID, modifiedTerritories)
	for _, id in pairs(modifiedTerritories) do
		if terrID == id then return true; end
	end
	return false;
end

function grant_income(game, addNewOrder, player_income)
	if game.ServerGame.Settings.CommerceGame == true then
		for _,playerID in pairs(game.ServerGame.Game.PlayingPlayers)do
			local moneyforplayer = {};
			moneyforplayer[playerID.ID] = {};
			moneyforplayer[playerID.ID][WL.ResourceType.Gold] = player_income[playerID.ID] + game.ServerGame.LatestTurnStanding.NumResources(playerID.ID,WL.ResourceType.Gold);
			addNewOrder(WL.GameOrderEvent.Create(playerID.ID, "Recieved " .. player_income[playerID.ID] .. " gold from bonuses", {}, {},moneyforplayer));
		end
	end
end