function Server_GameCreated(game, settings)
	print(game.Settings.MultiPlayer, Mod.Settings.Testing);
	if not game.Settings.MultiPlayer and not Mod.Settings.Testing then
		settings.FogLevel = 3;
	end
end