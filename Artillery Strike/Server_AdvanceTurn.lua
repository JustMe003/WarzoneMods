require("Utilities");

function Server_AdvanceTurn_Start(game, addNewOrder)
	data = Mod.PublicGameData;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderCustom" then
		if string.find(order.Payload, "Artillery Strike_") ~= nil then
			local info = split(order.Payload, "_");
			artilleryStrike(game, addNewOrder, info[2], tonumber(info[3]), tonumber(info[4]), tonumber(info[5]));
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
		mod.AddArmies = -(armies * (per / 100));
		local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID, game.Map.Territories[terrID].Name .. " was attacked by a cannon at " .. game.Map.Territories[from].Name .. " for " .. per .. "% damage", {}, {mod});
		if game.Settings.CommerceGame then
			event.AddResourceOpt = {[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID] = {[WL.ResourceType.Gold] = -(Mod.Settings.GoldCost or 0)}};
		end
		event.JumpToActionSpotOpt = createRectangleVM(game, terrID);
		event.TerritoryAnnotationsOpt = {
			[terrID] = WL.TerritoryAnnotation.Create("Artillery Strike (" .. mod.AddArmies .. ")", 5, game.Game.Players[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID].Color.IntColor);
		};
		addNewOrder(event);
	elseif artillery == "Mortar" then
		local mods = {};
		local annotations = {};
		local annotationColor = game.Game.Players[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID].Color.IntColor;
		local modTarget = WL.TerritoryModification.Create(terrID);
		modTarget.AddArmies = -round(getNumArmies(game, terrID) * ((Mod.Settings.MortarDamage - per) / 100));
		table.insert(mods, modTarget);
		annotations[terrID] = WL.TerritoryAnnotation.Create("Artillery Strike (" .. modTarget.AddArmies .. ")", 5, annotationColor)
		local perForCon = per / getTableLength(game.Map.Territories[terrID].ConnectedTo);
		for i, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
			local mod = WL.TerritoryModification.Create(i);
			local armies = getNumArmies(game, i);
			mod.AddArmies = -(armies * ((perForCon) / 100));
			table.insert(mods, mod);
			annotations[i] = WL.TerritoryAnnotation.Create(mod.AddArmies, 5, annotationColor);
		end
		local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID, game.Map.Territories[terrID].Name .. " was attacked by a mortar at " .. game.Map.Territories[from].Name, {}, mods);
		if game.Settings.CommerceGame then
			event.AddResourceOpt = {[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID] = {[WL.ResourceType.Gold] = -(Mod.Settings.GoldCost or 0)}};
		end
		event.TerritoryAnnotationsOpt = annotations;
		event.JumpToActionSpotOpt = createRectangleVM(game, terrID);
		addNewOrder(event);
	end
	data.TotalArtilleryShots[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID] = data.TotalArtilleryShots[game.ServerGame.LatestTurnStanding.Territories[from].OwnerPlayerID] + 1;
end

function getNumArmies(game, terrID)
	return game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies;
end

function createRectangleVM(game, terrID)
	return WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY)
end
