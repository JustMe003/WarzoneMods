require("Annotations");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
    data.ActiveCards = {};
    data.IsTeamGame = getIsTeamGame(game);
    Mod.PublicGameData = data;

    local t = {};
    for _, player in pairs(game.Game.PlayingPlayers) do
        local teamID = getPlayerOrTeamID(player);
        if not t[teamID] then
            t[teamID] = {
                Pieces = Mod.Settings.StartingPieces;
                WholeCards = 0;
                CardsUsedThisTurn = 0;
            }
        end 
    end
    data.CardData = t;

    Mod.PublicGameData = data;
end

function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end

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
