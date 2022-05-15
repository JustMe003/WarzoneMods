function Server_AdvanceTurn_Start(game, addNewOrder)
	data = Mod.PublicGameData;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" and orderResult.IsAttack then
		if orderResult.DefendingArmiesKilled.NumArmies / 100 * data.Values[1] >= 1 then
			reviveArmies(game, orderResult.DefendingArmiesKilled.NumArmies, order.To, order, orderResult, addNewOrder);
		end
		if orderResult.AttackingArmiesKilled.NumArmies / 100 * data.Values[1] >= 1 then
			reviveArmies(game, orderResult.AttackingArmiesKilled.NumArmies, order.From, order, orderResult, addNewOrder);
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	Mod.PublicGameData = data;
end

function reviveArmies(game, armies, eventTerr, order, orderResult, addNewOrder)
	local range = 1;
	for i = 1, Mod.Settings.maximumHospitalRange do
		if armies / 100 * data.Values[i] >= 1 then 
			range = i; 
		else 
			break;
		end
	end
	for terrID, dis in pairs(getTerritories(game, order.To, range)) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		if terr.OwnerPlayerID == game.ServerGame.LatestTurnStanding.Territories[eventTerr].OwnerPlayerID and terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
			if terr.Structures ~= nil and terr.Structures[WL.StructureType.Hospital] ~= nil then
				local mod = WL.TerritoryModification.Create(terrID);
				if order.From == terrID then
					if orderResult.IsSuccessful then
						mod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + math.floor(armies / 100 * data.Values[dis]) - orderResult.ActualArmies.NumArmies;
					else
						mod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + math.floor(armies / 100 * data.Values[dis]) - orderResult.AttackingArmiesKilled.NumArmies;
					end
				else
					mod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + math.floor(armies / 100 * data.Values[dis]);
				end
				addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[eventTerr].OwnerPlayerID, "revived " .. data.Values[dis] .. "% armies at " .. game.Map.Territories[terrID].Name, {}, {mod}), true);
			end
		end
	end
end

function getTerritories(game, terrID, range)
	local t = {};
	t[terrID] = -10;
	for i = 1, range do
--		print(i, getValue(i), Mod.PublicGameData.Values[i])
		if i == 1 then
			for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
				t[connID] = i;
--				print(game.Map.Territories[connID].Name, t[connID]);
			end
		else
			for j, v in pairs(t) do
				for connID, _ in pairs(game.Map.Territories[j].ConnectedTo) do
					if t[connID] == nil then
						if v == i - 1 then
							t[connID] = i;
--							print(game.Map.Territories[connID].Name, t[connID]);
						end
					end
				end
			end
		end
	end
	t[terrID] = nil;
	return t;
end
