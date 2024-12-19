function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderPlayCardAirlift" then
        if not hasRequiredCities(game.ServerGame.LatestTurnStanding.Territories[order.ToTerritoryID]) or not hasRequiredCities(game.ServerGame.LatestTurnStanding.Territories[order.FromTerritoryID]) then
            skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
            addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Your airlift order was skipped because " .. game.Map.Territories[order.FromTerritoryID].Name .. " or " .. game.Map.Territories[order.ToTerritoryID].Name .. " has less than " .. tostring(Mod.Settings.RequiredCities) .. " cities"), "");
        end
    end
end

function hasRequiredCities(terr)
    return terr.Structures ~= nil and terr.Structures[WL.StructureType.City] ~= nil and terr.Structures[WL.StructureType.City] >= Mod.Settings.RequiredCities;
end
