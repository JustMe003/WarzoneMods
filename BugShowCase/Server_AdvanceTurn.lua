local WL = WL;
---@cast WL WL

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
    for pID, _ in pairs(game.Game.PlayingPlayers) do
        local custom = WL.GameOrderCustom.Create(pID, "Adding +10 resources (custom order)", "", {
            [2] = -1,
            [5] = -1
        });
        addNewOrder(custom);

        local event = WL.GameOrderEvent.Create(pID, "Adding +1 resource (event order)", {});
        event.AddResourceOpt = {
            [pID] = {
                [2] = 10,
                [5] = 10
            }
        }
        addNewOrder(event);
    end
end
