function Server_GameCreated(game, settings)
	if not game.Settings.MultiPlayer and not Mod.Settings.Testing then
		settings.FogLevel = 3;
	end
end