---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local res = standing.Resources or {};
	for pID, _ in pairs(game.Game.PlayingPlayers) do
        res[pID] = res[pID] or {};
        res[pID][2] = 100;
        res[pID][5] = 100;
    end
    standing.Resources = res;
end