function Server_AdvanceTurn_Start(game, addNewOrder)
	globalBoolean = false;
    listOfGifts = {};
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if not globalBoolean and order.proxyType == "GameOrderPlayCardGift" then
        table.insert(listOfGifts, order);
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	globalBoolean = true;
    for _, gift in pairs(listOfGifts) do
        if gift.PlayerID == game.ServerGame.LatestTurnStanding.Territories[gift.TerritoryID].OwnerPlayerID then
            addNewOrder(gift);
        end
    end
end