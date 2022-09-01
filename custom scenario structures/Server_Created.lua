function Server_Created(game, settings)
	if not game.Settings.MultiPlayer and not Mod.Settings.Testing then
		settings.FogLevel = 1;
	end
	print(settings.FogLevel);
end