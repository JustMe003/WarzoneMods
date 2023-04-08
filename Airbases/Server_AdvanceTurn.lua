function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderPlayCardAirlift" then
        if not hasRequiredCities(game.ServerGame.LatestTurnStanding.Territories[order.ToTerritoryID]) or not hasRequiredCities(game.ServerGame.LatestTurnStanding.Territories[order.FromTerritoryID]) then
            skipThisOrder(WL.ModOrderControl.Skip);
        end
    end
end

function hasRequiredCities(terr)
    return terr.Structures ~= nil and terr.Structures[WL.StructureType.City] ~= nil and terr.Structures[WL.StructureType.City] >= Mod.Settings.RequiredCities;
end
