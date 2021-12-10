require("setDistribution");

function Server_StartDistribution(game, standing)
	print("Mod.Settings.CustomDistribution = " .. tostring(Mod.Settings.CustomDistribution))
	if Mod.Settings.CustomDistribution == true then
		for terrID, terr in pairs(standing.Territories) do
			if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
				terr.OwnerPlayerID = WL.PlayerID.Neutral;
				terr.NumArmies = terr.NumArmies.Add(WL.Armies.Create(game.Settings.InitialNonDistributionArmies));
				standing.Territories[terrID] = terr; -- reset all territories 
			end
		end
		for bonusID, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
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
		terr.OwnerPlayerID = WL.PlayerID.AvailableForDistribution;
		standing.Territories[terrID] = terr;
		print(terrID, standing.Territories[terrID].OwnerPlayerID, terr.OwnerPlayerID)
	end
end
