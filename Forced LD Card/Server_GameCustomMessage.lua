require("Annotations");

---Server_GameCustomMessage
---@param game GameServerHook
---@param playerID PlayerID
---@param payload table
---@param setReturn fun(payload: table) # Sets the table that will be returned to the client when the custom message has been processed
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    local data = Mod.PublicGameData;
    local teamID = getPlayerOrTeamID(game.Game.PlayingPlayers[playerID]);
    local cardData = data.CardData[teamID];
    if payload.Action == "PlayCard" then
        if cardData.WholeCards - getAllPlayedCardsCount(game, teamID) <= 0 then
            return;
        end
        data.CardsPlayedThisTurn[playerID] = data.CardsPlayedThisTurn[playerID] + 1;
    elseif payload.Action == "UpdateCardCount" then
        data.CardsPlayedThisTurn[playerID] = data.CardsPlayedThisTurn[playerID] - payload.Count;
    end
    Mod.PublicGameData = data;

end

function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end

function getAllPlayedCardsCount(game, teamID)
    local c = 0;
    for _, p in pairs(game.Game.PlayingPlayers) do
        if getPlayerOrTeamID(p) == teamID then
            c = c + Mod.PublicGameData.CardsPlayedThisTurn[p.ID];
        end
    end
    return c;
end