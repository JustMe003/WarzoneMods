function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
    data.WebsBought = {};
    for p, _ in pairs(game.Game.PlayingPlayers) do
        data.WebsBought[p] = 0;
    end
    Mod.PublicGameData = data;
end