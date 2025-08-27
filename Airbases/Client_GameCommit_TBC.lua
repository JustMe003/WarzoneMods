function Client_GameCommit(game, skipCommit)
    local invalidOrders = {};
    for _, order in pairs(game.Orders) do
        
    end
end

function testForNumberOfCities(game, terrID)
    local structures = game.LatestStanding.Territories[terrID].Structures;
    if not (structures and structures[WL.StructureType.City] and structures[WL.StructureType.City] + getPurchasedCities(game.Orders, terrID) >= Mod.Settings.RequiredCities) then
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