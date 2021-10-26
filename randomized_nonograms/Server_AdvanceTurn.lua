function Server_AdvanceTurn_End(Game, addNeworder)
	local publicGameData = Mod.publicGameData;
	for bonusID, list in pairs(publicGameData.Bonuses) do
		if player_has_bonus(list) then
			if Mod.Settings.LocalDeployments == true then
				local_deployments(list);
			else
				print(tostring(Mod.Settings.LocalDeployments));
			end
		end
	end
end

function player_has_bonus(list_of_terr)
	local playerID = 0;
	for _, terrID in pairs(list_of_terr) do
		if Game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID ~= PlayerID.Neutral and playerID == 0 then
			playerID = Game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID;
		elseif Game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID ~= playerID or Game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID == PlayerID.Neutral then
			return false;
		end
	end
	return true;
end

function local_deployments (list_of_terr)
	for _, terrID in pairs(list_of_terr) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
		terrMod = WL.TerritoryModification.Create(terr.ID);
		terrMod.SetArmiesTo = terr.NumArmies.NumArmies + 1;
	end
end