function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderAttackTransfer" then
        print(game.Map.Territories[order.From].ConnectedTo[order.To]);
        if game.Map.Territories[order.From].ConnectedTo[order.To] ~= WL.TerritoryConnectionWrap.Normal then
            skipThisOrder(WL.ModOrderControl.Skip);
        end
    end
end