function Server_StartGame(game, standing)
	data = {};
	data.Charges = {};
	for ID, _ in pairs(game.Game.PlayingPlayers) do
		data.Charges[ID] = 0
	end
	Mod.PublicGameData = data;
end