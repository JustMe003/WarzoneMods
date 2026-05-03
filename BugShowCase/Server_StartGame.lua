---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local cards = standing.Cards;

    for pID, playerCards in pairs(cards) do
        print(string.format("Player: %d\tNum cards: %d", pID, tableSize(playerCards.WholeCards)));
    end

    standing.Cards = cards;
end

function tableSize(t)
    local c = 0;
    for _, _ in pairs(t) do
        c = c + 1;
    end
    return c;
end