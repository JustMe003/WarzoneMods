function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
    data.NoSplitCursesPurchased = {};
    for p, _ in pairs(game.Game.PlayingPlayers) do
        data.NoSplitCursesPurchased[p] = 0;
    end
    Mod.PublicGameData = data;
end