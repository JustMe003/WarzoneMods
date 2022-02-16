function Server_AdvanceTurn_Start (game,addNewOrder)
	data = Mod.PublicGameData;
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
		if result.IsAttack then
			
		else
			local numArmies = 0;
			if not order.ByPercent then
				numArmies = order.NumArmies.NumArmies;
			else
				numArmies = math.round(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.NumArmies / 100 * order.NumArmies.NumArmies);
			end
			result.ActualArmies = WL.Armies.Create(numArmies, order.SpecialUnits);
		else
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	Mod.PublicGameData = data;
end