require("Annotations");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
    data.ActiveCards = {};
    data.IsTeamGame = getIsTeamGame(game);
    Mod.PublicGameData = data;

    local whole = 0;
    local pieces = Mod.Settings.StartingPieces;
    while pieces >= Mod.Settings.NumPieces do
        whole = whole + 1;
        pieces = pieces - Mod.Settings.NumPieces;
    end    
    
    local t1 = {};
    local t2 = {};
    for _, player in pairs(game.Game.PlayingPlayers) do
        t2[player.ID] = 0;
        local teamID = getPlayerOrTeamID(player);
        if not t1[teamID] then
            t1[teamID] = {
                Pieces = pieces;
                WholeCards = whole;
            }
        end 
    end
    data.CardData = t1;
    data.CardsPlayedThisTurn = t2;

    Mod.PublicGameData = data;
end

---Returns the playerID of teamID of the player
---@param player GamePlayer # The player in question
---@return PlayerID | TeamID | integer # The ID to use to index the data
function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end

---Returns true if the game is a team game, returns false otherwise
---@param game GameServerHook # The game object
---@return boolean # True if the game is a team game, false otherwise
function getIsTeamGame(game)
    for _, player in pairs(game.Game.PlayingPlayers) do
        return player.Team ~= -1;
    end
end

---Returns the used bonus value
---@param bonus BonusDetails
---@param bonusOverrides table<BonusID, integer>
---@return integer
function getBonusValue(bonus, bonusOverrides)
    if bonusOverrides[bonus.ID] then return bonusOverrides[bonus.ID]; end
    return bonus.Amount;
end
