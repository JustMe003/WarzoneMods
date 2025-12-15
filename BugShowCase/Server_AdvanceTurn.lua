require("Logger");

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Start(game, addNewOrder)
    data = Mod.PublicGameData;
    data.Logs[game.Game.TurnNumber] = {};
    CreateNewLog(data.Logs[game.Game.TurnNumber]);
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    Log(order.proxyType);
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
    Mod.PublicGameData = data;
    -- for p, _ in pairs(game.Game.PlayingPlayers) do
    --     local rand = math.random(100);
    --     addNewOrder(WL.GameOrderEvent.Create(p, "Adding " .. rand .. " random income", nil, {}, {}, {
    --         WL.IncomeMod.Create(p, rand, "Random income boost");
    --     }));
    -- end
end
