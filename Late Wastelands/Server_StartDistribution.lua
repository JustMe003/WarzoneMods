function Server_StartDistribution(game, standing)
	for _, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID == WL.PlayerID.Neutral then
			terr.NumArmies = WL.Armies.Create(game.Settings.InitialNonDistributionArmies, {});
			if game.Settings.DistributionModeID == 0 then
				terr.OwnerPlayerID = WL.PlayerID.AvailableForDistribution;
			end
		end
	end
end

