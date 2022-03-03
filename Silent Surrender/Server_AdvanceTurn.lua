function Server_AdvanceTurn_Start(game, addNewOrder)
	local data = Mod.PublicGameData;
	local prints = {};
	for _, v in pairs(game.ServerGame.PendingStateTransitions) do
		table.insert(prints, "new state " .. tostring(v.NewState));
		table.insert(prints, "playerID " .. tostring(v.PlayerID));
		table.insert(prints, "taking over AI " .. tostring(v.TakingOverForAI));
		table.insert(prints, "turning into AI " .. tostring(v.TurningIntoAI));
	end
	for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		table.insert(prints, "player " .. tostring(player.DisplayName(nil, false)));
		table.insert(prints, "booted duration " .. tostring(player.BootedDuration));
		table.insert(prints, "surrendered " .. tostring(player.Surrendered));
		table.insert(prints, "human turned into AI " .. tostring(player.HumanTurnedIntoAI));
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
