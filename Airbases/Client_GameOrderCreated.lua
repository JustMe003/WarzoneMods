function Client_GameOrderCreated(game, order, skipOrder)
    if order.proxyType == "GameOrderPlayCardAirlift" and Mod.Settings.RequiredCities > 0 then
        if testForNumberOfCities(game, order, game.LatestStanding.Territories[order.FromTerritoryID].structures, skipOrder) then
            testForNumberOfCities(game, order, game.LatestStanding.Territories[order.ToTerritoryID].structures, skipOrder)
        end
    end
end

function testForNumberOfCities(game, order, structures, skipOrder)
    if structures and structures[WL.StructureType.City] and structures[WL.StructureType.City] >= Mod.Settings.RequiredCities then
        UI.Alert("You cannot play this airlift because " .. game.Map.Territories[order.FromTerritoryID].Name .. " and/or " .. game.Map.Territories[order.ToTerritoryID].Name .. " don't have the number of required cities. When playing an airlift card, both territories need to have at least " .. Mod.Settings.RequiredCities .. " cities");
        skipOrder();
        return false;
    end
    return true;
end