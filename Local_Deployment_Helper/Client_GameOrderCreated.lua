local payload = "[LDH_V3]";

function Client_GameOrderCreated(game, order, skipOrder)
    local orders = game.Orders;
    local index = 1;
    while index <= #orders do
        print(index, #orders);
        local o = orders[index];
        if o.OccursInPhase and o.OccursInPhase > WL.TurnPhase.Purchase then break; end 
        if o.proxyType == "GameOrderCustom" and o.Payload == payload then
            table.remove(orders, index);
        else
            index = index + 1;
        end
    end
    game.Orders = orders;
end