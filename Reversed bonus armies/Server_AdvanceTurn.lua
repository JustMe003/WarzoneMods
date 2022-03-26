
function Server_AdvanceTurn_End(game, addNewOrder)
	if game.Settings.BonusArmyPer == 0 then return; end
	local terrCount = {};
	for i,_ in pairs(game.Game.PlayingPlayers) do
		terrCount[i] = 0;
	end

	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
			terrCount[terr.OwnerPlayerID] = terrCount[terr.OwnerPlayerID] + 1;
		end
	end

	local mods = {};
	for i, v in pairs(terrCount) do
                local num = (math.min(game.Settings.MinimumArmyBonus, math.floor(v / game.Settings.BonusArmyPer)) * -1) - math.floor(math.max(v - (game.Settings.BonusArmyPer * game.Settings.MinimumArmyBonus), 0) / game.Settings.BonusArmyPer * 2);
                table.insert(mods, WL.IncomeMod.Create(i, num, "Reversed the bonus armies"))
	end
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Reversed bonus armies", nil, {}, {}, mods))
end
