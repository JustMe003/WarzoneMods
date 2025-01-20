function Server_AdvanceTurn_Order(game, order, orderDetails, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderPlayCardCustom" then
        local terrID = tonumber(order.ModData);

        local list = {};
        for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
            table.insert(list, connID);
        end

        for i = #list, 1, -1 do
            local rand = math.random(#list);
            local randID = list[rand];
            table.remove(list, rand);

            local terr = game.ServerGame.LatestTurnStanding.Territories[randID];
            if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
                addNewOrder(WL.GameOrderAttackTransfer.Create(terr.OwnerPlayerID, randID, terrID, WL.AttackTransferEnum.AttackTransfer, false, terr.NumArmies, false));
            end

        end
    end
end