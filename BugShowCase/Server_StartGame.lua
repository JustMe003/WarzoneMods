---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local res = standing.Resources or {};
	for pID, _ in pairs(game.Game.PlayingPlayers) do
        res[pID] = res[pID] or {};
        res[pID][2] = 10;
        res[pID][5] = 100;
    end
    standing.Resources = res;

    for pID, _ in pairs(game.Game.PlayingPlayers) do
        print(2, standing.NumResources(pID, 2));
        print(5, standing.NumResources(pID, 5));
    end
end