require("Annotations");
require("Hills");

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
	local player = checkOwnerHills(game.ServerGame.LatestTurnStanding.Territories, game.Game.Players);

    local data = Mod.PublicGameData;
    if player ~= -1 then    -- A team has all the hills
        if player == data.LastControllingPlayer then    -- Same team as previous turn
            data.NumTurnsControlling = data.NumTurnsControlling + 1;
            if data.NumTurnsControlling == Mod.Settings.NumTurns then
                endGame(player, game, addNewOrder);
            end
        else    -- New team in posession of all the hills
            data.LastControllingPlayer = player;
            data.NumTurnsControlling = 1;
            if data.NumTurnsControlling == Mod.Settings.NumTurns then
                endGame(player, game, addNewOrder);
            end
        end
    else    -- No team is in posession of all the hills atm
        data.LastControllingPlayer = player;
        data.NumTurnsControlling = 0;
    end
    Mod.PublicGameData = data;
end
