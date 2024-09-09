require("Annotations");

---Server_GameCustomMessage
---@param game GameServerHook
---@param playerID PlayerID
---@param payload table
---@param setReturn fun(payload: table) # Sets the table that will be returned to the client when the custom message has been processed
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    local data = Mod.PublicGameData;
    local cardData = data.CardData[getPlayerOrTeamID(game.Game.PlayingPlayers[playerID])];
    if payload.Action == "PlayCard" then
        if cardData.WholeCards - cardData.CardsUsedThisTurn <= 0 then
            return;
        end
        cardData.CardsUsedThisTurn = cardData.CardsUsedThisTurn + 1;
    elseif payload.Action == "UpdateCardCount" then
        cardData.CardsUsedThisTurn = cardData.CardsUsedThisTurn - payload.Count;
    end
    Mod.PublicGameData = data;

end

function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end
