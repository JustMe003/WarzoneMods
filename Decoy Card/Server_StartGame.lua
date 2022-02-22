function Server_StartGame(game, standing)
	data = Mod.PublicGameData;
	data.ActiveDecoys = {};
	data.DecoysPlayed = {};
	for i, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		data.DecoysPlayed[i] = 0;
	end
	Mod.PublicGameData = data;
end