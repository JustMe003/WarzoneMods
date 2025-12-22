---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Start(game, addNewOrder)
    local terrs = {};
    for id, _ in pairs(game.Map.Territories) do
        table.insert(terrs, id);
    end

    local t = {};
    for _, v in pairs(Mod.PublicGameData.Players or {}) do
        table.insert(t, v);
    end

    local fogMod = WL.FogMod.Create("testing", WL.StandingFogLevel.Visible, 10000, terrs, t);
    local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Vision!", nil, {});
    event.FogModsOpt = {fogMod};
    addNewOrder(event);
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    
end

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