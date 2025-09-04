require("Hills")

---Server_StartDistribution hook
---@param game GameServerHook
---@param standing GameStanding
function Server_StartDistribution(game, standing)
    setUpHills(standing);

    local data = Mod.PublicGameData;
    for _, player in pairs(game.Game.PlayingPlayers) do
        data.IsTeamGame = player.Team ~= -1;
        break;
    end
    Mod.PublicGameData = data;
end