require("Annotations");
require("Hills");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
	if game.Settings.AutomaticTerritoryDistribution then
        setUpHills(standing);
    end

    local data = Mod.PublicGameData;
    for _, player in pairs(game.Game.PlayingPlayers) do
        data.IsTeamGame = player.Team ~= -1;
        break;
    end
    Mod.PublicGameData = data;
end