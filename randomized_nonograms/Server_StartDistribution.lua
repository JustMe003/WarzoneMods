require("setDistribution");

function Server_StartDistribution(game, standing)
	print("Mod.Settings.CustomDistribution = " .. tostring(Mod.Settings.CustomDistribution))
	if Mod.Settings.CustomDistribution == true then
		for terrID, terr in pairs(standing.Territories) do
			-- only change the OwnerPlayerID when the territory isn't neutral
			if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
				terr.OwnerPlayerID = WL.PlayerID.Neutral;
				terr.NumArmies = terr.NumArmies.Add(WL.Armies.Create(game.Settings.InitialNonDistributionArmies));
				standing.Territories[terrID] = terr; -- reset all territories 
			end
		end
		-- Mod.PublicGameData.Bonuses has as index the bonus ID's, and as value another table containing an array of territory ID's
		-- Note that the bonuses are custom made
		for bonusID, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
			-- All the territories are either assigned to 0 or 2 bonuses
			-- If assigned to 2 bonuses, the first bonus ID is below or equal to 200, the other ID above 200
			-- when we reach bonusID 200+, we can break the loop since we've had all the territories once
			if bonusID < 201 then
--				print(bonusID)
				setPickable(standing, listOfTerr);
			else break; end
		end
	end
end

function setPickable(standing, listOfTerr)
	for _, terrID in pairs(listOfTerr) do
		terr = standing.Territories[terrID];
		terr.OwnerPlayerID = -2;
--		standing.Territories[terrID] = terr; -- With this or without, it won't work...
--		print(terrID, standing.Territories[terrID].OwnerPlayerID, terr.OwnerPlayerID)
	end
end
