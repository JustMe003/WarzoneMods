function Server_AdvanceTurn_Start(game, addNewOrder)
	playerPerTerr = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		playerPerTerr[terr.ID] = terr.OwnerPlayerID;
	end
end


function Server_AdvanceTurn_End(game, addNewOrder)
	local listOfAttackedTerr = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID ~= playerPerTerr[terr.ID] then
			listOfAttackedTerr[terr.ID] = true;
		end
	end
	local data = Mod.PublicGameData;
	for terrID, _ in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if listOfAttackedTerr[terrID] ~= nil then
			data.WellBeingMultiplier[terrID] = Mod.Settings.MinMultiplier;
		else
			data.WellBeingMultiplier[terrID] = math.min(Mod.Settings.MaxMultiplier, data.WellBeingMultiplier[terrID] + Mod.Settings.LevelMultiplierIncrement);
		end
	end
	Mod.PublicGameData = data;
	local t = {};
	for p, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		t[p] = {};
	end
	for _, bonus in pairs(game.Map.Bonuses) do
		local pID = holdsBonus(game, bonus.Territories)
		if pID ~= WL.PlayerID.Neutral and getBonusValue(game, bonus.ID) ~= 0 then
			if not game.Settings.LocalDeployments then
				table.insert(t[pID], WL.IncomeMod.Create(pID, -getBonusValue(game, bonus.ID), "Cancel out " .. bonus.Name))
			else
				table.insert(t[pID], WL.IncomeMod.Create(pID, -getBonusValue(game, bonus.ID), "Cancel out " .. bonus.Name, bonus.ID));
			end
		end
	end
	for _, bonus in pairs(game.Map.Bonuses) do
		pID = holdsBonus(game, bonus.Territories);
		if pID ~= WL.PlayerID.Neutral and getBonusValue(game, bonus.ID) ~= 0 then
			local array = {};
			for _, terrID in pairs(bonus.Territories) do
				table.insert(array, Mod.PublicGameData.WellBeingMultiplier[terrID])
			end
			if not game.Settings.LocalDeployments then
				table.insert(t[pID], WL.IncomeMod.Create(pID, round(getBonusValue(game, bonus.ID) * sum(array)), "Actual income of " .. bonus.Name));
			else
				table.insert(t[pID], WL.IncomeMod.Create(pID, round(getBonusValue(game, bonus.ID) * sum(array)), "Actual income of " .. bonus.Name, bonus.ID));
			end
		end
	end
	for p, arr in pairs(t) do
		addNewOrder(WL.GameOrderEvent.Create(p, "Dynamic Bonuses", {}, {}, {}, arr));
	end
end

function holdsBonus(game, terrList)
	local pID = 0;
	for _, terrID in pairs(terrList) do
		if game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID ~= WL.PlayerID.Neutral then
			if pID == 0 then
				pID = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID;
			else
				if pID ~= game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID then
					return WL.PlayerID.Neutral;
				end
			end
		else
			return WL.PlayerID.Neutral;
		end
	end
	return pID;
end


function getBonusValue(game, bonusID)
	if game.Settings.OverriddenBonuses[bonusID] ~= nil then
		return game.Settings.OverriddenBonuses[bonusID];
	else
		return game.Map.Bonuses[bonusID].Amount;
	end
end

function round(n)
	if n % 1 < 0.5 then
		return math.floor(n);
	else
		return math.ceil(n);
	end
end

function sum(t)
	local total = 0;
	local count = 0;
	for _, v in pairs(t) do
		total = total + v;
		count = count + 1;
	end
	return total / count;
end

