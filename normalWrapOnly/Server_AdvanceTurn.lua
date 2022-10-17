function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderAttackTransfer" then
        for i, v in pairs(WL.TerritoryConnectionWrap) do
            print(i, v);
        end
        if game.Map.Territories[order.From].ConnectedTo[order.To] ~= WL.Wrap.Normal then
            skipThisOrder(WL.ModOrderControl.SkipOrder);
        end
    end
end