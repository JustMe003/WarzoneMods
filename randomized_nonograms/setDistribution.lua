function setDistribution(game, standing, bonuses)
	if game.Settings.AutomaticTerritoryDistribution == false then
		for terrID, terr in pairs(standing.Territories) do
			if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
				terr.OwnerPlayerID = WL.PlayerID.Neutral;
				terr.NumArmies = terr.NumArmies.Add(WL.Armies.Create(game.Settings.InitialNonDistributionArmies));
				standing.Territories[terrID] = terr; -- reset all territories, no need to check which distribution was selected
			end
			for bonusID, listOfTerr in pairs(bonuses) do
				if bonusID < 201 then
					setPickable(standing, listOfTerr);
				end
			end
		end
	end
end

function setPickable(standing, listOfTerr)
	for _, terrID in pairs(listOfTerr) do
		terr = standing.Territories[terrID];
		terr.OwnerPlayerID = WL.PlayerID.AvailableForDistribution;
		standing.Territories[terrID] = terr;
	end
end
