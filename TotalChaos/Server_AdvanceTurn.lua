function Server_AdvanceTurn_Start(game, addNewOrder)
    Orders = {};
    HasReachedEnd = true;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if HasReachedEnd then
        table.insert(Orders, order);
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
    HasReachedEnd = false;
    Orders = shuffle(Orders);
    for _, order in pairs(Orders) do
        addNewOrder(order);
    end
end

function shuffle(list)
    for i = #list, 2, -1 do
        local rand = math.random(i);
        list[i], list[rand] = list[rand], list[i];
    end
    return list;
end