require("utilities")

function Server_AdvanceTurn_Start(Game, addNewOrder)
	game = Game;
	data = Mod.PublicGameData;
	if data.DurationDistributionStage >= game.ServerGame.Game.TurnNumber then distributionPhase = true; end
	
	if distributionPhase then
		picked = {};
		if data.numberOfGroups> 1 then
			group = getGroup(game.ServerGame.Game.TurnNumber, data.numberOfGroups);
			for _, v in pairs(data.Groups[group]) do
				picked[v] = 0;
			end
		else
			for i,_ in pairs(game.ServerGame.Game.PlayingPlayers) do
				picked[i] = 0;
			end
		end
		
		if Mod.Settings.distributionTerritories then
			listOfTerr = getTerritories(game.ServerGame.LatestTurnStanding.Territories, function(terr) return terr.OwnerPlayerID == WL.PlayerID.Neutral and valueInTable(data.distributionTerritories, terr.ID); end);
		else
			listOfTerr = getTerritories(game.ServerGame.LatestTurnStanding.Territories, function(terr) return terr.OwnerPlayerID == WL.PlayerID.Neutral; end);
		end
		
		if data.numberOfGroups > 1 then
			if #listOfTerr < #data.Groups[getGroup(game.ServerGame.Game.TurnNumber, data.numberOfGroups)] then
				data.AbortDistribution = true;
				data.DurationDistributionStage = game.ServerGame.Game.TurnNumber;
			end
		else
			if #listOfTerr < #game.ServerGame.CyclicMoveOrder then
				data.AbortDistribution = true;
				data.DurationDistributionStage = game.ServerGame.Game.TurnNumber;
			end
		end
		if game.ServerGame.Game.TurnNumber < data.DurationDistributionStage or (game.Settings.CommerceGame == true and game.ServerGame.Game.TurnNumber == data.DurationDistributionStage) then
			for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
				income = player.Income(0, game.ServerGame.LatestTurnStanding, false, false)
				addNewOrder(WL.GameOrderEvent.Create(player.ID, "taking away your income", {}, nil, nil, {WL.IncomeMod.Create(player.ID, -income.Total, "Extended Hybrid Distributions\n\nWe have taken away your income since you should not deploy during the distribution phase")}))
			end
		end
	end
	Mod.PublicGameData = data;
	
	territoryPicks = {};
	for ID, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		territoryPicks[ID] = {};
	end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if not distributionPhase then return; end
	if order.proxyType == "GameOrderDeploy" or order.proxyType == "GameOrderAttackTransfer" then skipThisOrder(WL.ModOrderControl.Skip); end
	if order.proxyType ~= "GameOrderCustom" then return; end
	if data.AbortDistribution == true then skipThisOrder(WL.ModOrderControl.Skip); end
	if data.numberOfGroups> 1 then
		if not valueInTable(Mod.PublicGameData.Groups[group], order.PlayerID) then 
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You are not able to pick territories this turn", "_ExtendedDistributionPhase_Skip_Message_"));
			return; 
		end
	end
	if string.sub(order.Payload, 1, 24) ~= "ExtendDistributionPhase_" then return; end
	local array = split(string.sub(order.Payload, 25), "_")
	if array[1] ~= "pick" then return; end
	local ID = tonumber(array[2]);
	if game.ServerGame.LatestTurnStanding.Territories[ID].OwnerPlayerID == WL.PlayerID.Neutral then
		table.insert(territoryPicks[order.PlayerID], ID)
	else
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Your pick on " .. game.Map.Territories[ID].Name .. " was incorrect since someone else already controls the territory", "_ExtendedDistributionPhase_Skip_Message_"));
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	if not distributionPhase then return; end
	
	AddNewOrder = addNewOrder;
	picked = {};
	local group;
	if data.numberOfGroups > 1 then group = getGroup(game.ServerGame.Game.TurnNumber, data.numberOfGroups); end
	
	for playerID,_ in pairs(game.ServerGame.Game.PlayingPlayers) do
		if group ~= nil then
			if valueInTable(data.Groups[group], playerID) then picked[playerID] = false; else picked[playerID] = true; end
		else
			picked[playerID] = false;
		end
	end

	if not data.AbortDistribution then
		local reverseOrder = game.ServerGame.Game.TurnNumber % 2 == 1;
		if reverseOrder then
			for i = #game.ServerGame.CyclicMoveOrder, 1, -1 do
				if territoryPicks[game.ServerGame.CyclicMoveOrder[i]] ~= nil and territoryPicks[game.ServerGame.CyclicMoveOrder[i]] ~= {} then
					pickTerritory(territoryPicks[game.ServerGame.CyclicMoveOrder[i]], game.ServerGame.CyclicMoveOrder[i])
				end
			end
		else
			for i = 0, #game.ServerGame.CyclicMoveOrder do
				if territoryPicks[game.ServerGame.CyclicMoveOrder[i]] ~= nil and territoryPicks[game.ServerGame.CyclicMoveOrder[i]] ~= {} then
					pickTerritory(territoryPicks[game.ServerGame.CyclicMoveOrder[i]], game.ServerGame.CyclicMoveOrder[i])
				end
			end
		end
	end

	if not data.AbortDistribution then
		for id, v in pairs(picked) do
			if not v then
				local rand = math.random(#listOfTerr)
				local mod = WL.TerritoryModification.Create(listOfTerr[rand]);
				mod.SetOwnerOpt = id;
				mod.SetArmiesTo = game.Settings.InitialPlayerArmiesPerTerritory;
				addNewOrder(WL.GameOrderEvent.Create(id, "auto picked " .. game.Map.Territories[listOfTerr[rand]].Name .. " since " .. game.ServerGame.Game.PlayingPlayers[id].DisplayName(nil, false) .. " didn't pick enough territories", {}, {mod}))
				table.remove(listOfTerr, rand);
			end
		end
	end
	
	if (data.AbortDistribution or data.DurationDistributionStage == game.ServerGame.Game.TurnNumber) and data.distributionTerritories ~= nil then
		local modifications = {}
		for _, terrID in pairs(data.distributionTerritories) do
			local mod = WL.TerritoryModification.Create(terrID)
			local structures = game.ServerGame.LatestTurnStanding.Territories[terrID].Structures;
			structures[WL.StructureType.Hospital] = structures[WL.StructureType.Hospital] - 1
			mod.SetStructuresOpt = structures;
			table.insert(modifications, mod);
		end
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Removed hospitals from the map \nGood luck everyone!", {}, modifications));
		data.distributionTerritories = nil;
	end
	Mod.PublicGameData = data
end

function getTerritories(terr, func)
	local list = {};
	for i, v in pairs(terr) do
		if func(v) then
			table.insert(list, i);
		end
	end
	return list;
end

function pickTerritory(arrayOfTerrID, playerID)
	for _, ID in pairs(arrayOfTerrID) do
		if game.ServerGame.LatestTurnStanding.Territories[ID].OwnerPlayerID == WL.PlayerID.Neutral then
			local index;
			for i, terrID in pairs(listOfTerr) do if terrID == ID then index = i; break; end end
			if index ~= nil then
				local mod = WL.TerritoryModification.Create(ID);
				mod.SetOwnerOpt = playerID;
				mod.SetArmiesTo = game.Settings.InitialPlayerArmiesPerTerritory;
				AddNewOrder(WL.GameOrderEvent.Create(playerID, "picked " .. game.Map.Territories[ID].Name, {}, {mod}))
				picked[playerID] = true;
				table.remove(listOfTerr, index)
				return;
			end
		end
	end
end