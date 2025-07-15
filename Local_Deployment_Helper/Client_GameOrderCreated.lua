local payload = "[LDH_V3]";

function Client_GameOrderCreated(game, order, skipOrder)
    local orders = game.Orders;
    local index = #orders;
    while index > 0 do
        local o = orders[index];
        if o.OccursInPhase and o.OccursInPhase < WL.TurnPhase.ReceiveCards then break; end 
        if o.proxyType == "GameOrderCustom" and o.Payload == payload then
            table.remove(orders, index);
            break;
        end
        index = index - 1;
    end
    if #game.Orders ~= #orders then game.Orders = orders; end
end