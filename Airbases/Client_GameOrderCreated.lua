function Client_GameOrderCreated(game, order, skipOrder)
    if order.proxyType == "GameOrderPlayCardAirlift" and Mod.Settings.RequiredCities > 0 then
        if testForNumberOfCities(game, order, order.FromTerritoryID, skipOrder) then
            testForNumberOfCities(game, order, order.ToTerritoryID, skipOrder)
        end
    end
end

function testForNumberOfCities(game, order, terrID, skipOrder)
    local structures = game.LatestStanding.Territories[terrID].Structures;
    if not (structures and structures[WL.StructureType.City] and structures[WL.StructureType.City] + getPurchasedCities(game.Orders, terrID) >= Mod.Settings.RequiredCities) then
        print(structures[WL.StructureType.City] + getPurchasedCities(game.Orders, terrID))
        UI.Alert("You cannot play this airlift because '" .. game.Map.Territories[order.FromTerritoryID].Name .. "' and/or '" .. game.Map.Territories[order.ToTerritoryID].Name .. "' don't have the number of required cities. When playing an airlift card, both territories need to have at least " .. Mod.Settings.RequiredCities .. " cities");
        skipOrder();
        return false;
    end
    return true;
end

function getPurchasedCities(orders, terrID)
    for _, order in pairs(orders) do
        if order.proxyType == "GameOrderPurchase" then
            return order.BuildCities[terrID] or 0;
        elseif order.OccursInPhase > WL.TurnPhase.Purchase then
            return 0;
        end
    end
    return 0;
end