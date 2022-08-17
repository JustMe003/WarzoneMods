function Server_AdvanceTurn_Start (game,addNewOrder)
	map = {};
	for i, _ in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		map[i] = Mod.Settings.MaxAttacks;
	end
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
		if not result.IsAttack then
			if map[order.From] > 0 and game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID == order.PlayerID then
				local numArmies = 0;
				if not order.ByPercent then
					numArmies = order.NumArmies.NumArmies;
				else
					numArmies = round(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.NumArmies / 100 * order.NumArmies.NumArmies);
				end
				result.ActualArmies = WL.Armies.Create(numArmies, result.ActualArmies.SpecialUnits);
				map[order.To] = math.min(map[order.From] - 1, map[order.To]);
			else
				result.ActualArmies = WL.Armies.Create(0, result.ActualArmies.SpecialUnits);
			end
		elseif result.IsSuccessful then
			map[order.To] = Mod.Settings.MaxAttacks;
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	
end

function round(n)
	if n % 1 > 0.5 then
		return math.ceil(n);
	else
		return math.floor(n);
	end
end