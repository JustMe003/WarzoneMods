---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local counters = {};
    for i, group in ipairs(Mod.Settings.Config) do
        counters[i] = group.Interval;
    end
    Mod.PublicGameData = {Counters = counters};
end
