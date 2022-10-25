function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderAttackTransfer" then
        if game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
            skipThisOrder(WL.ModOrderControl.Skip);
        end
    elseif order.proxyType == "GameOrderPlayCardBomb" then
        local b = false;
        for connID, wrap in pairs(game.Map.Territories[order.TargetTerritoryID].ConnectedTo) do
            if wrap == WL.TerritoryConnectionWrap.Normal and game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID == order.PlayerID then
                b = true;
                break;
            end
        end
        if not b then
            skipThisOrder(WL.ModOrderControl.Skip);
        end
    end
end