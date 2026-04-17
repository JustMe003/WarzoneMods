function Server_StartGame(game, standing)
    local data = Mod.PrivateGameData;
    data.ActiveCards = {};
    Mod.PrivateGameData = data;
end