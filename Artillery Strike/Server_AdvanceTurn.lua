require("Utilities");

function Server_AdvanceTurn_Start(game, addNewOrder)
	data = Mod.PublicGameData;
	lastDeployorder = {};
	customOrders = {};
	for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		for _, order in pairs(game.ServerGame.ActiveTurnOrders[player.ID]) do
			if order.proxyType == "GameOrderDeploy" then
				lastDeployorder[player.ID] = order.DeployOn;
			elseif order.proxyType == "GameOrderCustom" then
				if string.find(order.Payload, "Artillery Strike") ~= nil then
					table.insert(customOrders, order.Payload);
					data.TotalArtilleryShots[order.PlayerID] = data.TotalArtilleryShots[order.PlayerID] + 1;
				end
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderDeploy" then
		if order.DeployOn == lastDeployorder[order.PlayerID] then
			lastDeployorder[order.PlayerID] = nil;
			if getTableLength(lastDeployorder) == 0 then
				armyCountChanges = {};
				armyCountChanges[order.DeployOn] = game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].NumArmies.NumArmies + order.NumArmies;
				for _, custom in pairs(customOrders) do
					if string.find(custom, "Artillery Strike") ~= nil then
						local info = split(custom, "_");
						artilleryStrike(game, addNewOrder, info[2], tonumber(info[3]), tonumber(info[4]), tonumber(info[5]));
					end
				end
			end
		end
	elseif order.proxyType == "GameOrderCustom" then
		if string.find(order.Payload, "Artillery Strike") ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	for i, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		if math.floor((game.ServerGame.Game.TurnNumber - 1) / Mod.Settings.ArtilleryShot) - data.TotalArtilleryShots[i] < 0 then
			data.TotalArtilleryShots[i] = math.floor((game.ServerGame.Game.TurnNumber - 1) / Mod.Settings.ArtilleryShot);
		end
	end
	Mod.PublicGameData = data;
end


function artilleryStrike(game, addNewOrder, artillery, terrID, from, per)
	if artillery == "Cannon" then
		local mod = WL.TerritoryModification.Create(terrID);
		local armies = getNumArmies(game, terrID);
		mod.SetArmiesTo = armies - (armies * (per / 100));
		armyCountChanges[terrID] = mod.SetArmiesTo;
		local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID, game.Map.Territories[terrID].Name .. " was attacked by a cannon at " .. game.Map.Territories[from].Name .. " for " .. per .. "% damage", {}, {mod});
		event.AddResourceOpt = {[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID] = {[WL.ResourceType.Gold] = -Mod.Settings.GoldCost}};
		addNewOrder(event);
	elseif artillery == "Mortar" then
		local mods = {};
		local modTarget = WL.TerritoryModification.Create(terrID);
		modTarget.SetArmiesTo = getNumArmies(game, terrID) - round(getNumArmies(game, terrID) * ((100 - Mod.Settings.MortarDamage + per) / 100));
		armyCountChanges[terrID] = modTarget.SetArmiesTo;
		table.insert(mods, modTarget);
		local perForCon = per / getTableLength(game.Map.Territories[terrID].ConnectedTo);
		for i, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
			local mod = WL.TerritoryModification.Create(i);
			local armies = getNumArmies(game, i);
			mod.SetArmiesTo = armies * ((100 - perForCon) / 100);
			armyCountChanges[i] = mod.SetArmiesTo;
			table.insert(mods, mod);
		end
		-- WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID, game.Map.Territories[terrID].Name .. " was attacked by a mortar at " .. game.Map.Territories[from].Name, {}, mods);
		local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID, game.Map.Territories[terrID].Name .. " was attacked by a mortar at " .. game.Map.Territories[from].Name, {});
		event.AddResourceOpt = {[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID] = {[WL.ResourceType.Gold] = -Mod.Settings.GoldCost}};
		print(Mod.Settings.GoldCost, event.AddResourceOpt[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID][WL.ResourceType.Gold]);
		addNewOrder(event);
	end
end

function getNumArmies(game, terrID)
	if armyCountChanges[terrID] ~= nil then
		return armyCountChanges[terrID];
	else
		return game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies;
	end
end
