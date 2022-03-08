require("Utilities");
function Server_AdvanceTurn_Start(game, addNewOrder)
	data = Mod.PublicGameData;
	decoys = {};
	for playerID, orders in pairs(game.ServerGame.ActiveTurnOrders) do
		for _, order in pairs(orders) do
			if order.proxyType == "GameOrderCustom" then
				if string.find(order.Payload, "playDecoy_") ~= nil then
					table.insert(decoys, order);
				end
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderCustom" then
		if string.find(order.Payload, "playDecoy_") ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		end
	elseif order.proxyType == "GameOrderDeploy" then
		if data.ActiveDecoys[order.DeployOn] ~= nil then
			data.ActiveDecoys[order.DeployOn].ActualArmies = data.ActiveDecoys[order.DeployOn].ActualArmies + order.NumArmies;
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Skipped the deployment on " .. game.Map.Territories[order.DeployOn].Name .. " since the army count is a decoy. The actual army count is now " .. data.ActiveDecoys[order.DeployOn].ActualArmies, ""));
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		end
	elseif order.proxyType == "GameOrderAttackTransfer" then
		if data.ActiveDecoys[order.From] ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Skipped attack / transfer order since " .. game.Map.Territories[order.From].Name .. " is a decoy", ""));
		elseif data.ActiveDecoys[order.To] ~= nil then
			if orderResult.ActualArmies.NumArmies > 0 then
				if orderResult.IsAttack and game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID ~= WL.PlayerID.Neutral then
					local to = WL.TerritoryModification.Create(order.To)
					local from = WL.TerritoryModification.Create(order.From);
					to.SetArmiesTo = data.ActiveDecoys[order.To].ActualArmies;
					to.SetOwnerOpt = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID;
					from.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.NumArmies;
					addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID, "Sike!\n" .. game.Map.Territories[order.To].Name .. " was a decoy! Lets see what the attack actually does...", {}, {to, from}), true)
					addNewOrder(order, true);
				elseif order.PlayerID == game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID then
					local mod = WL.TerritoryModification.Create(order.To);
					mod.SetArmiesTo = data.ActiveDecoys[order.To].ActualArmies + orderResult.ActualArmies.NumArmies;
					addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID, "decoy on " .. game.Map.Territories[order.To].Name .. " ran out due to a transfer", {}, {mod}), true)
				end
				data.ActiveDecoys[order.To] = nil;
			end
		end
	elseif order.proxyType == "GameOrderPlayCardAirlift" then
		if data.ActiveDecoys[order.FromTerritoryID] ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Skipped airlift since " .. game.Map.Territories[order.FromTerritoryID].Name .. " is a decoy", ""));
		elseif data.ActiveDecoys[order.ToTerritoryID] ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			revealDecoy(game, order, addNewOrder, order.ToTerritoryID, "airlift");
		end
	elseif order.proxyType == "GameOrderPlayCardGift" then
		if data.ActiveDecoys[order.TerritoryID] ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			revealDecoy(game, order, addNewOrder, order.TerritoryID, "gift");
		end
	elseif order.proxyType == "GameOrderPlayCardBlockade" or order.proxyType == "GameOrderPlayCardAbandon" then
		if data.ActiveDecoys[order.TargetTerritoryID] then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			revealDecoy(game, order, addNewOrder, order.TargetTerritoryID, "blockade");
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	for i, decoy in pairs(data.ActiveDecoys) do
		if decoy.MaxDuration <= game.ServerGame.Game.TurnNumber then
			local mod = WL.TerritoryModification.Create(i);
			mod.SetArmiesTo = decoy.ActualArmies;
			addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[i].OwnerPlayerID, "Decoy card on " .. game.Map.Territories[i].Name .. " ran out", {}, {mod}));
			data.ActiveDecoys[i] = nil;
		end
	end
	for _, order in pairs(decoys) do
		local info = split(order.Payload, "_");
		local terr = tonumber(info[2]);
		if game.ServerGame.LatestTurnStanding.Territories[terr].OwnerPlayerID == order.PlayerID then
			local visibleArmies = tonumber(info[3]);
			local actualArmies = game.ServerGame.LatestTurnStanding.Territories[terr].NumArmies.NumArmies;
			if data.ActiveDecoys[terr] ~= nil then actualArmies = data.ActiveDecoys[terr].ActualArmies; end
			data.ActiveDecoys[terr] = {};
			data.ActiveDecoys[terr].MaxDuration = game.ServerGame.Game.TurnNumber + Mod.Settings.NumberOfTurns;
			data.ActiveDecoys[terr].ActualArmies = actualArmies;
			local mod = WL.TerritoryModification.Create(terr);
			mod.SetArmiesTo = visibleArmies;
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {mod}))
			data.DecoysPlayed[order.PlayerID] = data.DecoysPlayed[order.PlayerID] + 1;
		else
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Your decoy card couldn't be played because you don't own the territory anymore", ""));
		end
	end
	Mod.PublicGameData = data;
end

function revealDecoy(game, order, addNewOrder, terrID, reason)
	local mod = WL.TerritoryModification.Create(terrID);
	mod.SetArmiesTo = data.ActiveDecoys[terrID].ActualArmies;
	addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID, "decoy on " .. game.Map.Territories[terrID].Name .. " ran out due to an " .. reason, {}, {mod}), true)
	addNewOrder(order, true);
	data.ActiveDecoys[terrID] = nil;
end