function Server_AdvanceTurn_End(Game, addNeworder)
	local publicGameData = Mod.PublicGameData;
	bonuses = publicGameData.Bonuses
	for bonusID, list in pairs(bonuses) do
		if player_has_bonus(Game, list) then
			if Mod.Settings.LocalDeployments == true then
				local_deployments(Game, list);
			else
				print(tostring(Mod.Settings.LocalDeployments));
			end
		end
	end
end

function player_has_bonus(Game, list_of_terr)
	local playerID = 0;
	for _, terrID in pairs(list_of_terr) do
		print(type(terrID));
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID]
		if terr.OwnerPlayerID ~= PlayerID.Neutral and playerID == 0 then
			playerID = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID;
		elseif game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID ~= playerID or game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID == PlayerID.Neutral then
			return false;
		end
	end
	return true;
end

function local_deployments (Game, list_of_terr)
	for _, terrID in pairs(list_of_terr) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		terrMod = WL.TerritoryModification.Create(terr.ID);
		terrMod.SetArmiesTo = terr.NumArmies.NumArmies + 1;
	end
end