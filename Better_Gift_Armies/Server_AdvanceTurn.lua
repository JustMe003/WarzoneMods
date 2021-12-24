require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'BetterGiftArmies_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the destination territory ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 18), ','); 
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);
		local destinationTerritoryID = tonumber(payloadSplit[3]);
		
		if Mod.PublicGameData.Charges[order.PlayerID] < Mod.Settings.ChargeAmountPerGift then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, game.Game.Players[order.PlayerID].DisplayName(nil, false) .. " tried to gift armies to " .. game.Map.Territories[destinationTerritoryID].Name .. " but didn't have enough charges.", {}, {}));
			return;
		end
		
		--Skip if we don't control the territory (this can happen if someone captures the territory before our gift order executes)
		if (order.PlayerID ~= game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID) then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, game.Game.Players[order.PlayerID].DisplayName(nil, false) .. " tried to gift armies from " .. game.Map.Territories[targetTerritoryID].Name .. " but didn't control it", {}, {}));
			return;
		end

		local armiesOnTerritory = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies;

		if (numArmies < 0) then numArmies = 0 end;
		if (numArmies > armiesOnTerritory) then numArmies = armiesOnTerritory end;

		if (game.ServerGame.LatestTurnStanding.Territories[destinationTerritoryID].OwnerPlayerID == order.PlayerID) then  --can't gift yourself
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, game.Game.Players[order.PlayerID].DisplayName(nil, false) .. " tried to gift armies to " .. game.Map.Territories[destinationTerritoryID].Name .. ", but since he owns it he should play a airlift card instead of using this mod", {}, {}));
			return;
		end 
		-- If the territory you want to gift to is neutral and Mod.Settings.CanGiftToNeutral is false you then can't gift to neutral thus skip and do nothing
		if game.ServerGame.LatestTurnStanding.Territories[destinationTerritoryID].OwnerPlayerID == WL.PlayerID.Neutral and Mod.Settings.CanGiftToNeutral == false then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, game.Game.Players[order.PlayerID].DisplayName(nil, false) .. " tried to gift armies to " .. game.Map.Territories[destinationTerritoryID].Name .. " but you're not allowed to gift armies to neutral", {}, {}));
			return;
		end
		modifications = {};
		mod = WL.TerritoryModification.Create(destinationTerritoryID);
		mod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[destinationTerritoryID].NumArmies.NumArmies + numArmies;
		table.insert(modifications, mod);
		mod = WL.TerritoryModification.Create(targetTerritoryID);
		mod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies - numArmies;
		table.insert(modifications, mod);
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Gifted " .. numArmies .. " to " .. game.Map.Territories[destinationTerritoryID].Name, {}, modifications));
		data = Mod.PublicGameData;
		data.Charges[order.PlayerID] = data.Charges[order.PlayerID] - Mod.Settings.ChargeAmountPerGift;
		Mod.PublicGameData = data;

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.

	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	data = Mod.PublicGameData;
	for ID, _ in pairs(game.Game.PlayingPlayers) do
		data.Charges[ID] = data.Charges[ID] + Mod.Settings.ChargesPerTurn;
	end
	Mod.PublicGameData = data;
end