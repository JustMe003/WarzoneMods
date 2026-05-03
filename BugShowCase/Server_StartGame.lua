---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local cards = standing.Cards;

    standing.Cards = cards;
end