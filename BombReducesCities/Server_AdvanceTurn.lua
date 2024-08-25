function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderPlayCardBomb" then
		print(1)
		local structures = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures;
		if structures and structures[WL.StructureType.City] and structures[WL.StructureType.City] > 0 then
			print(2)
			local mod = WL.TerritoryModification.Create(order.TargetTerritoryID);
			mod.AddStructuresOpt = {
				[WL.StructureType.City] = -Mod.Settings.NumCities
			};
			print("test: " .. mod.AddStructuresOpt[WL.StructureType.City]);
			local event = WL.GameOrderEvent.Create(order.PlayerID, "Bomb damages cities", {}, {mod});
			local mapTerr = game.Map.Territories[order.TargetTerritoryID];
			print(mapTerr.MiddlePointX, mapTerr.MiddlePointY)
			event.SetActionSpot = WL.RectangleVM.Create(mapTerr.MiddlePointX, mapTerr.MiddlePointY, mapTerr.MiddlePointX, mapTerr.MiddlePointY);
			print("Action spot set!")
			addNewOrder(event, true);
			print("Added order!")
		end
		print("end");
	end
end
