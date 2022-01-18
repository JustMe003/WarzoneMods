function Server_Created(game, settings)
	settings.AutomaticTerritoryDistribution = false;
	settings.LimitDistributionTerritories = math.max(settings.LimitDistributionTerritories, 1)
	if settings.FogLevel >= 4 then settings.FogLevel = 2; end
end