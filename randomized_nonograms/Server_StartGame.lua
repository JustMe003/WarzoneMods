require("GiveIncome");
require("setDistribution");

function Server_StartGame(game, standing)
	if game.Settings.AutomaticTerritoryDistribution == true then
		setDistribution(game, standing, Mod.PublicGameData.Bonuses);
	end
	if Mod.Settings.LocalDeployments == true then
		for _, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
			if playerHasBonus(standing, listOfTerr) then
				firstTurnLD(standing, listOfTerr);
			end
		end
	elseif game.ServerGame.Settings.CommerceGame == true then
		playerIncome = initiatePlayerIncome(game);
		for _, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
			if playerHasBonus(standing, listOfTerr) then
				playerID = getPlayer(standing, listOfTerr);
				playerIncome[playerID] = playerIncome[playerID] + #listOfTerr;
			end
		end
		local publicGameData = Mod.PublicGameData;
		publicGameData.FTI = playerIncome;
		Mod.PublicGameData = publicGameData;
	end
end
