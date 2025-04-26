local WL = WL;
---@cast WL WL

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
    -- for p, _ in pairs(game.Game.PlayingPlayers) do
    --     local rand = math.random(100);
    --     addNewOrder(WL.GameOrderEvent.Create(p, "Adding " .. rand .. " random income", nil, {}, {}, {
    --         WL.IncomeMod.Create(p, rand, "Random income boost");
    --     }));
    -- end
end
