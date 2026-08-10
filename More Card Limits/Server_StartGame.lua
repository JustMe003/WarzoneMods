require("Util");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local data = Mod.PrivateGameData;
    local cards = standing.Cards;
    for p, playerCards in pairs(cards) do
        if data[p] == nil then
            data[p] = {};
            for card, settings in pairs(Mod.Settings) do
                if settings.MaxGameCardLimit > 0 then
                    data[p][card] = settings.MaxGameCardLimit;
                end 
            end
        end
    end

    local cardsPerPlayer = {};
    for p, playerCards in pairs(cards) do
        cardsPerPlayer[p] = {};
        for _, card in pairs(playerCards.WholeCards) do
            cardsPerPlayer[p][card.CardID] = cardsPerPlayer[p][card.CardID] or {};
            table.insert(cardsPerPlayer[p][card.CardID], card);
        end
    end

    for cardId, settings in pairs(Mod.Settings) do
        if settings.MaxCardHold > 0 or settings.MaxGameCardLimit > 0 then
            for p, playerCards in pairs(cardsPerPlayer) do
                if playerCards[cardId] ~= nil then
                    local handLimit = settings.MaxCardHold;
                    if settings.MaxGameCardLimit > 0 and settings.MaxGameCardLimit < settings.MaxCardHold then
                        handLimit = settings.MaxGameCardLimit;
                    end
                    local tmp = cards[p].WholeCards;
                    for i = #playerCards[cardId], handLimit + 1, -1 do
                        local card = playerCards[cardId][i];
                        tmp[card.ID] = nil;
                        playerCards[cardId][i] = nil;
                    end
                    cards[p].WholeCards = tmp;
                    if settings.MaxGameCardLimit > 0 then
                        
                        data[p][cardId] = data[p][cardId] - #playerCards[cardId];
                    end
                end
            end
        end
    end

    PrintTable(data);

    standing.Cards = cards;
    Mod.PrivateGameData = data;
end
