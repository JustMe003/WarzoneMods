function Server_AdvanceTurn_End(Game, addNewOrder)
	local publicGameData = Mod.PublicGameData;
	bonuses = publicGameData.Bonuses;
	local player_income = initiate_player_income(Game);
	for bonusID, list in pairs(bonuses) do
		if player_has_bonus(Game, list) then
			if Mod.Settings.LocalDeployments == true then
				local_deployments(Game, addNewOrder, list);
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
		print(terrID);
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and playerID == 0 then
			playerID = terr.OwnerPlayerID;
		elseif terr.OwnerPlayerID ~= playerID or terr.OwnerPlayerID == WL.PlayerID.Neutral then
			return false;
		end
	end
	return true;
end

function local_deployments (game, addNewOrder, list_of_terr)
	for _, terrID in pairs(list_of_terr) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		terrMod = WL.TerritoryModification.Create(terr.ID);
		terrMod.SetOwnerOpt = terr.OwnerPlayerID;
		terrMod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + 1;
		addNewOrder(WL.GameOrderEvent.Create(terr.OwnerPlayerID,"added armies",{},{terrMod}));
	end
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