function Server_AdvanceTurn_Start(game, addNewOrder)
	local mods = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.Structures ~= nil and terr.Structures[WL.StructureType.City] ~= nil then
			local mod = WL.TerritoryModification.Create(terr.ID);
			local t = {};
			if terr.Structures[WL.StructureType.City] == 1 then
				t[WL.StructureType.Mine] = 1;
			else
			end
			t[WL.StructureType.City] = -1;
			mod.AddStructuresOpt = t;
			table.insert(mods, mod);
		end
	end
	if #mods > 0 then
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Gold mine building has continued", {}, mods));
	end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderPurchase" then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		local mods = {};
		local cost = 0;
		local terrNames = {};
		for i, _ in pairs(order.BuildCities) do
			if game.ServerGame.LatestTurnStanding.Territories[i].Structures == nil or game.ServerGame.LatestTurnStanding.Territories[i].Structures[WL.StructureType.City] == nil or game.ServerGame.LatestTurnStanding.Territories[i].Structures[WL.StructureType.City] == 0 then
				table.insert(terrNames, game.Map.Territories[i].Name);
				cost = cost - game.Settings.CommerceCityBaseCost;
				local mod = WL.TerritoryModification.Create(i);
				local t = {};
				t[WL.StructureType.City] = Mod.Settings.NTurns;
				mod.AddStructuresOpt = t;
				table.insert(mods, mod);
			end
		end
		if #terrNames > 0 then
			local event = WL.GameOrderEvent.Create(order.PlayerID, createMessage(terrNames), {}, mods);
			local t = {};
			t[order.PlayerID] = {};
			t[order.PlayerID][WL.ResourceType.Gold] = cost;
			event.AddResourceOpt = t;
			addNewOrder(event);
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local income = {};
	for p, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		income[p] = {};
		income[p][WL.StructureType.City] = 0;
		income[p][WL.StructureType.Mine] = 0;
	end
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if not terr.IsNeutral and terr.Structures ~= nil then
			if terr.Structures[WL.StructureType.City] ~= nil then
				income[terr.OwnerPlayerID][WL.StructureType.City] = income[terr.OwnerPlayerID][WL.StructureType.City] + terr.Structures[WL.StructureType.City];
			end
			if terr.Structures[WL.StructureType.Mine] ~= nil then
				income[terr.OwnerPlayerID][WL.StructureType.Mine] = income[terr.OwnerPlayerID][WL.StructureType.Mine] + terr.Structures[WL.StructureType.Mine];
			end
		end
	end
	for p, t in pairs(income) do
		local mods = {};
		if t[WL.StructureType.City] > 0 then
			table.insert(mods, WL.IncomeMod.Create(p, -t[WL.StructureType.City], "Removing income from cities"));
		end
		if t[WL.StructureType.Mine] > 0 then
			table.insert(mods, WL.IncomeMod.Create(p, Mod.Settings.Income * t[WL.StructureType.Mine], "Income from goldmines"));
		end
		addNewOrder(WL.GameOrderEvent.Create(p, "Adjusted income", {}, {}, {}, mods));
	end
end

function createMessage(array)
	return "Started building goldmines at " .. #array .. " territories";
end

