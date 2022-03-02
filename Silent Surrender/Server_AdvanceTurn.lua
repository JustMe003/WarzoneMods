function Server_AdvanceTurn_Start(game, addNewOrder)
	for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		print(player.BootedDuration);
		if player.HumanTurnedIntoAI and player.Surrendered then
			local modifications = {};
			for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
				if terr.OwnerPlayerID == player.ID then
					local mod = WL.TerritoryModification.Create(terr.ID);
					mod.SetOwnerOpt = WL.PlayerID.Neutral;
					table.insert(modifications, mod);
				end
			end
			addNewOrder(WL.GameOrderEvent.Create(player.ID, game.ServerGame.Game.PlayingPlayers[player.ID].DisplayName(nil, false) .. " silently surrendered", nil, modifications));
		end
	end
end
