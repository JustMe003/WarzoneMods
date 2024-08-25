function Server_AdvanceTurn_Order(order, orderResult, game, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderPlayCardBomb" then
		local structures = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures;
		if structures and structures[WL.StructureType.City] and structures[WL.StructureType.City] > 0 then
			local mod = WL.TerritoryModifidation.Create(order.TargetTerritoryID);
			mod.AddStructuresOpt = {
				[WL.StructureType.City] = -Mod.Settings.NumCities
			};
			local order = WL.GameOrderEvent.Create(order.PlayerID, "Bomb damages cities", {}, {}, {mod});
			local mapTerr = game.Map.Territories[order.TargetTerritoryID];
			order.SetActionSpot = WL.RectangleVM.Create(mapTerr.MiddlePointX, mapTerr.MiddlePointY, mapTerr.MiddlePointX, mapTerr.MiddlePointY);
			addNewOrder(order, true);
		end
	end
	print(10)
end