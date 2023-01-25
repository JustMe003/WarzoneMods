function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
    data.LandminesBought = {};
    for p, _ in pairs(game.Game.PlayingPlayers) do
        data.LandminesBought[p] = 0;
    end
    Mod.PublicGameData = data;
end