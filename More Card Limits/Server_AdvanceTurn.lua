require("Util");

---Server_AdvanceTurn_Start
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder, b: boolean)
function Server_AdvanceTurn_Start(game, addNewOrder)
    cardsAtStart = {};
    for p, playerCards in pairs(game.ServerGame.LatestTurnStanding.Cards) do
        local t = {};
        for type, cards in pairs(SortCards(playerCards.WholeCards)) do
            if Mod.Settings[type] ~= nil and Mod.Settings[type].MaxGameCardLimit > 0 then
                t[type] = cards;
            end
        end
        cardsAtStart[p] = t;
    end
end

---Server_AdvanceTurn_End
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder, b: boolean)
function Server_AdvanceTurn_End(game, addNewOrder)
    local data = Mod.PrivateGameData;
    for p, playerCards in pairs(game.ServerGame.LatestTurnStanding.Cards) do
        local abundantPieces = {};
        local playerCardsAtStart = cardsAtStart[p] or {};
        for type, cards in pairs(SortCards(playerCards.WholeCards)) do
            if Mod.Settings[type] ~= nil then
                local playerCardsAtStartOfType = playerCardsAtStart[type];
                local removedCards = {};
                if Mod.Settings[type].MaxCardHold > 0 then
                    local numCards = #cards;
                    if numCards > Mod.Settings[type].MaxCardHold then
                        for _, card in ipairs(cards) do
                            if not ValueInTable(playerCardsAtStartOfType, card) then
                                RemoveCard(p, card, playerCards.WholeCards[card], addNewOrder);
                                table.insert(removedCards, card);
                                numCards = numCards - 1;
                                if numCards <= Mod.Settings[type].MaxCardHold then
                                    break;
                                end
                            end
                        end
                    end
                    if numCards == Mod.Settings[type].MaxCardHold and playerCards.Pieces[type] > 0 then          -- Code above will match numCards with the limit, no need to check for over the limit
                        abundantPieces[type] = playerCards.Pieces[type];
                    end
                end
                if Mod.Settings[type].MaxGameCardLimit > 0 then
                    local c = data[GetIdFromPlayer(game, p)][type];
                    if playerCardsAtStartOfType == nil then             -- Player had no cards of this type at the start of the turn
                        c = c - #cards;
                    else
                        for _, card in ipairs(cards) do
                            if not ValueInTable(playerCardsAtStartOfType, card) and not ValueInTable(removedCards, card) then        -- Only count new cards and cards not removed already
                                if c == 0 then
                                    RemoveCard(p, card, playerCards.WholeCards[card], addNewOrder);
                                else
                                    c = c - 1;
                                end
                            end
                        end
                    end
                    if c == 0 and playerCards.Pieces[type] > 0 then      -- Max game limit reached, always remove card pieces
                        abundantPieces[type] = playerCards.Pieces[type];
                    end
                    data[GetIdFromPlayer(game, p)][type] = c;
                end
            end
        end
        if GetTableSize(abundantPieces) > 0 then
            RemoveCardPieces(p, abundantPieces, addNewOrder);
        end
    end
    Mod.PrivateGameData = data;
end

---Sorts the cards and returns an indexable table
---@param cards table<string, CardInstance>
---@return table<CardID, CardInstanceID[]>
function SortCards(cards)
    local t = {};
    for _, card in pairs(cards) do
        local cardType = card.CardID;
        t[cardType] = t[cardType] or {};
        table.insert(t[cardType], card.ID);
    end
    return t;
end

---Returns the team or player ID of the passed player
---@param game GameServerHook
---@param p PlayerID
---@return TeamID | PlayerID
function GetIdFromPlayer(game, p)
    return GetTeamOrPlayerID(game.Game.Players[p]);
end

---Removes all the passed cards
---@param p PlayerID
---@param cards table<CardInstanceID, CardInstance>
---@param addNewOrder fun(order: GameOrder)
function RemoveAllCards(p, cards, addNewOrder)
    for instanceID, card in pairs(cards) do
        RemoveCard(p, instanceID, card, addNewOrder);
    end
end

---Removes the passed card
---@param p PlayerID
---@param cardInstance CardInstanceID
---@param card CardInstance
---@param addNewOrder fun(order: GameOrder)
function RemoveCard(p, cardInstance, card, addNewOrder)
    local order = WL.GameOrderEvent.Create(p, string.format("Removed %s card", GetCardName(card.CardID)), {}, {});
    order.RemoveWholeCardsOpt = {
        [p] = cardInstance;
    };
    addNewOrder(order);
end

---Removes card pieces
---@param p PlayerID
---@param pieces table<CardID, integer>
---@param addNewOrder fun(order: GameOrder)
function RemoveCardPieces(p, pieces, addNewOrder)
    local strings = {};
    for cardID, n in pairs(pieces) do
        table.insert(strings, string.format("%d %s", n, GetCardName(cardID)));
        pieces[cardID] = -n;
    end

    local order = WL.GameOrderEvent.Create(p, string.format("Removed %s card pieces", ConcatTable(strings)), {}, {});
    order.AddCardPiecesOpt = {
        [p] = pieces;
    };
    addNewOrder(order);
end