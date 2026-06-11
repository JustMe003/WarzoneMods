---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local cards = standing.Cards;

    print(tostring(cards), tostring(standing.Cards));
    for pID, playerCards in pairs(cards) do
        local whole = playerCards.WholeCards;
        print(string.format("Player: %d\tNum cards: %d", pID, tableSize(whole.WholeCards)));
        
        -- Removing a card
        local cardID = getFirstCard(whole.WholeCards);
        print(string.format("Removing card with ID %s, indexing gives %s", cardID, tostring(whole.WholeCards[cardID])));
        whole.WholeCards[cardID] = nil;
        cards[pID] = whole;
        print(string.format("Player: %d\tNum cards: %d", pID, tableSize(whole.WholeCards)));
        
        -- Adding a card
        local new = WL.ReinforcementCardInstance.Create(1);
        print(string.format("Adding card with ID %s, indexing gives %s", new.ID, tostring(whole.WholeCards[new.ID])));
        whole.WholeCards[new.ID] = new;
        cards[pID] = whole;
        print(string.format("Player: %d\tNum cards: %d", pID, tableSize(whole.WholeCards)));
        playerCards = whole;
    end

    standing.Cards = cards;
end

function getFirstCard(cards)
    for cardID, _ in pairs(cards) do
        return cardID;
    end
end

function tableSize(t)
    local c = 0;
    for _, _ in pairs(t) do
        c = c + 1;
    end
    return c;
end