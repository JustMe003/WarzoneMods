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
        ---@diagnostic disable-next-line: param-type-mismatch
        if cardData.WholeCards - getAllPlayedCardsCount(game, teamID) <= 0 then
            return;
        end
        data.CardsPlayedThisTurn[playerID] = data.CardsPlayedThisTurn[playerID] + 1;
    elseif payload.Action == "UpdateCardCount" then
        data.CardsPlayedThisTurn[playerID] = data.CardsPlayedThisTurn[playerID] - payload.Count;
    end
    Mod.PublicGameData = data;

end

---Returns the playerID of teamID of the player
---@param player GamePlayer # The player in question
---@return PlayerID | TeamID | integer # The ID to use to index the data
function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end

---Counts all the Forced LD cards played by the team
---@param game GameServerHook # The game object
---@param teamID TeamID # The teamID of the team we want to count the cards from
---@return integer # The number of cards played
function getAllPlayedCardsCount(game, teamID)
    local c = 0;
    for _, p in pairs(game.Game.PlayingPlayers) do
        if getPlayerOrTeamID(p) == teamID then
            c = c + Mod.PublicGameData.CardsPlayedThisTurn[p.ID];
        end
    end
    return c;
end