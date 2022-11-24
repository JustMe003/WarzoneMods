require("util");
function Server_AdvanceTurn_Start(game, addNewOrder)
	if game.ServerGame.Game.TurnNumber ~= 1 then return; end
	local hasDeployedUnit = 0;
	local deployedUnitAt = {};
	for p, _ in pairs(game.Game.PlayingPlayers) do
		for _, order in pairs(game.ServerGame.ActiveTurnOrders[p]) do
			if order.proxyType == "GameOrderCustom" then
				local info = split(order.Payload, "_");
				if info[1] == "ConnTerrs2" then
					local terrID = tonumber(info[2]);
					local mod = WL.TerritoryModification.Create(terrID);
					mod.AddSpecialUnits = {buildUnit(p)};
					local order = WL.GameOrderEvent.Create(p, "Deployed link unit", {}, {mod}, {});
					order.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
					addNewOrder(order);
					hasDeployedUnit = hasDeployedUnit + 1;
					deployedUnitAt[terrID] = true;
				end
			end
		end
		if hasDeployedUnit ~= Mod.PublicGameData.NumUnits then		-- auto deploy
			local terrs = {};
			for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
				if terr.OwnerPlayerID == p and deployedUnitAt[terr.ID] == nil then
					table.insert(terrs, terr.ID);
				end
			end
			for i = 1, math.min(Mod.PublicGameData.NumUnits - hasDeployedUnit, #terrs) do
				local rand = math.random(#terrs);
				local mod = WL.TerritoryModification.Create(terrs[rand]);
				mod.AddSpecialUnits = {buildUnit(p)};
				local order = WL.GameOrderEvent.Create(p, "Auto deployed link unit", {}, {mod}, {});
				order.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrs[rand]].MiddlePointX, game.Map.Territories[terrs[rand]].MiddlePointY, game.Map.Territories[terrs[rand]].MiddlePointX, game.Map.Territories[terrs[rand]].MiddlePointY);
				addNewOrder(order);
				table.remove(terrs, rand);
			end
		end
		hasDeployedUnit = 0;
	end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderCustom" and split(order.Payload, "_")[1] == "ConnTerrs2" then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	Game = game;
	connectedCommanders(game);
	for i, group in pairs(groups) do
		if groupHasUnit[i] == nil then
			local mods = {};
			for _, terrID in pairs(group) do
				local mod = WL.TerritoryModification.Create(terrID);
				mod.SetOwnerOpt = WL.PlayerID.Neutral;
				table.insert(mods, mod);
			end
			local event = WL.GameOrderEvent.Create(groupOwner[i], "Lost " .. #group .. " territories because they were not connected to a special unit", {}, mods)
			event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[group[1]].MiddlePointX, game.Map.Territories[group[1]].MiddlePointY, game.Map.Territories[group[1]].MiddlePointX, game.Map.Territories[group[1]].MiddlePointY);
			addNewOrder(event);
		end
	end
end

function connectedCommanders(Game)
	groups = {};				-- store all the groups
	table.insert(groups, {});	-- initiate the first group
	group = #groups;			-- group counter
	groupHasUnit = {};			-- keep track if the group has a special unit
	groupOwner = {};			-- keep track of the group owner (the player to whom the territories belong)
	skipTerrs = {};				-- keep track of the already processed territories
	for _, terr in pairs(Game.ServerGame.LatestTurnStanding.Territories) do
		if terrMeetsReq(terr) then
			groupOwner[group] = terr.OwnerPlayerID;
			getGroup(terr.ID);
			table.insert(groups, {});
			group = #groups;
		end
	end
	table.remove(groups, group);
end

function getGroup(terrID)
	skipTerrs[terrID] = true; 	-- We will process this territory now, so we label it as processed since it is a recursive function
	table.insert(groups[group], terrID);
	if groupHasUnit[group] == nil then
		if hasRequiredUnit(Game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.SpecialUnits) then
			groupHasUnit[group] = true;
		end
	end
	for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
		if terrMeetsReq(Game.ServerGame.LatestTurnStanding.Territories[connID]) and (groupOwner[group] == Game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID or (Mod.Settings.TeamsCountAsOnePlayer and playersAreTeammates(groupOwner[group], Game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID))) then
			getGroup(connID);
		end
	end
end

function hasRequiredUnit(arr)
	for _, sp in pairs(arr) do
		if (sp.proxyType == "Commander" and Mod.Settings.IncludeCommanders) or (sp.proxyType == "CustomSpecialUnit" and sp.Name == "Link") then
			return true;
		end
	end
	return false;
end

function playersAreTeammates(p1, p2)
	return Game.Game.PlayingPlayers[p1].Team ~= -1 and Game.Game.PlayingPlayers[p1].Team == Game.Game.PlayingPlayers[p2].Team;
end

function terrMeetsReq(terr)
	return skipTerrs[terr.ID] == nil and terr.OwnerPlayerID ~= WL.PlayerID.Neutral
end

function valueInTable(t, v)
	for _, v2 in pairs(t) do
		if v == v2 then return true; end
	end
	return false;
end
