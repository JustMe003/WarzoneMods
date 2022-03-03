function Server_AdvanceTurn_Start(game, addNewOrder)
	local data = Mod.PublicGameData;
	local prints = {};
	for _, v in pairs(game.ServerGame.PendingStateTransitions) do
		table.insert(prints, v.NewState);
		table.insert(prints, v.PlayerID);
		table.insert(prints, v.TakingOverForAI);
		table.insert(prints, v.TurningIntoAI);
	end
	for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		table.insert(prints, player.BootedDuration);
		table.insert(prints, player.Surrendered);
		table.insert(prints, player.HumanTurnedIntoAI);
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
	data.Prints = prints;
	Mod.PublicGameData = data;
end
