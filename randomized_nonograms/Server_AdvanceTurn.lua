require("GiveIncome")

function Server_AdvanceTurn_End(game, addNewOrder)
	if Mod.Settings.LocalDeployments == true then
		terrModifications = {};		-- will contain all territories modifications
		touchedTerritories = {};	-- will contain all the ID's of the territories that will be modified
		index = 1;
		for _, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
			if playerHasBonus(game.ServerGame.LatestTurnStanding, listOfTerr) then
				terrModifications, touchedTerritories, index = localDeployments(game, addNewOrder, listOfTerr, terrModifications, touchedTerritories, index);
			end
		end
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"added armies",{},terrModifications));
	else
		playerIncome = initiatePlayerIncome(game);
		for _, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
			if playerHasBonus(game.ServerGame.LatestTurnStanding, listOfTerr) then
				playerID = getPlayer(game.ServerGame.LatestTurnStanding, listOfTerr);
				playerIncome[playerID] = playerIncome[playerID] + #listOfTerr;
			end
		end
		grantIncome(game, addNewOrder, playerIncome);
	end
end