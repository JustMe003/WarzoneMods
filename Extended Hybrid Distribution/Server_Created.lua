function Server_Created(game, settings)
	settings.AutomaticTerritoryDistribution = false;
	settings.LimitDistributionTerritories = math.max(settings.LimitDistributionTerritories, 1)
	print(settings.FogLevel);
end