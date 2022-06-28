function Server_AdvanceTurn_Start(game,addNewOrder)
	data = Mod.PublicGameData;
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
		if result.IsAttack and result.IsSuccessful and game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID ~= WL.PlayerID.Neutral then
			team = game.Game.PlayingPlayers[game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID].Team;
			if team == -1 then
				team = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID;
			end
			if data.Flags[team][order.To] ~= nil then
				owner = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID;
				local mod = WL.TerritoryModification.Create(order.To);
				local structures = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures;
				if structures ~= nil then
					structures[team % 17 + 2] = 0;
				end
				mod.SetStructuresOpt = structures;
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Captured flag at " .. game.Map.Territories[order.To].Name, {}, {mod}), true);
			end
		end
	elseif order.proxyType == "GameOrderEvent" then
		if string.find(order.Message, "Captured flag at") ~= nil then
			data.Flags[team][order.TerritoryModifications[1].TerritoryID] = nil;
			table.insert(data.Income[game.ServerGame.LatestTurnStanding.Territories[order.TerritoryModifications[1].TerritoryID].OwnerPlayerID], "Captured flag at " .. game.Map.Territories[order.TerritoryModifications[1].TerritoryID].Name)
			checkFlagStatus(game, addNewOrder, owner);
		elseif string.find(order.Message, "Lost flag at") ~= nil then
			print(order.Message, data.Flags[teamID][order.TerritoryModifications[1].TerritoryID]);
			data.Flags[teamID][order.TerritoryModifications[1].TerritoryID] = nil;
			checkFlagStatus(game, addNewOrder, order.PlayerID);
		else
			for _, mod in pairs(order.TerritoryModifications) do
				for n, team in pairs(data.Flags) do
					if team[mod.TerritoryID] ~= nil then
						if mod.SetOwnerOpt ~= nil then
							if game.ServerGame.LatestTurnStanding.Territories[mod.TerritoryID].OwnerPlayerID ~= mod.SetOwnerOpt then
								teamID = n;
								local modification = WL.TerritoryModification.Create(mod.TerritoryID);
								modification.SetStructuresOpt = getStructureTable(game, mod.TerritoryID);
								addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[mod.TerritoryID].OwnerPlayerID, "Lost flag at " .. game.Map.Territories[mod.TerritoryID].Name, {}, {modification}))
							end
						end
					end
				end
			end
		end
	elseif order.proxyType == "GameOrderPlayCardGift" then
		team = game.Game.PlayingPlayers[order.PlayerID].Team;
		if team == -1 then
			team = order.PlayerID;
		end
		if data.Flags[team][order.TerritoryID] ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You cannot gift a territory with your flag", ""));
		end
	elseif order.proxyType == "GameOrderPlayCardAbandon" or order.proxyType == "GameOrderPlayCardBlockade" then
		team = game.Game.PlayingPlayers[order.PlayerID].Team;
		if team == -1 then
			team = order.PlayerID;
		end
		if data.Flags[team][order.TargetTerritoryID] ~= nil then
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You cannot blockade your flag", ""));
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local mods = {};
	for player, t in pairs(data.Income) do
		for _, message in pairs(t) do
			table.insert(mods, WL.IncomeMod.Create(player, Mod.Settings.IncomeBoost, message))
		end
	end
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Added income", nil, {}, {}, mods));
	Mod.PublicGameData = data;
end

function checkFlagStatus(game, addNewOrder, player)
	local team = player;
	if game.Game.PlayingPlayers[player] == nil then return; end
	if game.Game.PlayingPlayers[player].Team ~= -1 then
		team = game.Game.PlayingPlayers[player].Team;
	end
	data.FlagsLost[team] = data.FlagsLost[team] + 1;
	local remainingFlags = getTableLength(data.Flags[team]);
	if data.FlagsLost[team] >= Mod.Settings.NFlagsForLose or remainingFlags < 1 then
		if game.Game.PlayingPlayers[team] == nil then
			addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Team " .. getTeamName(team) .. " lost to many flags", nil, eliminateTeam(game, team)));
		else
			if game.Game.PlayingPlayers[team].Team == -1 then
				local mods = {};
				for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
					if terr.OwnerPlayerID == team then
						local mod = WL.TerritoryModification.Create(terr.ID);
						mod.SetOwnerOpt = WL.PlayerID.Neutral;
						mod.SetStructuresOpt = getStructureTable(game, terr.ID);
						table.insert(mods, mod);
					end
				end
				addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, game.Game.Players[player].DisplayName(nil, false) .. " lost to many flags", nil, mods));
			else
				addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Team " .. getTeamName(team) .. " lost to many flags", nil, eliminateTeam(game, team)));
			end
		end
	end
end

function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end

function getStructureTable(game, terr)
	if game.ServerGame.LatestTurnStanding.Territories[terr].Structures == nil then 
		return {}; 
	else
		local structures = {};
		for i = 2, 18 do
			structures[i] = 0;
		end
		structures[WL.StructureType.City] = game.ServerGame.LatestTurnStanding.Territories[terr].Structures[WL.StructureType.City] or 0;
		return structures;
	end
end

function eliminateTeam(game, teamID)
	local mods = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
			if game.Game.PlayingPlayers[terr.OwnerPlayerID].Team == teamID then
				local mod = WL.TerritoryModification.Create(terr.ID);
				mod.SetOwnerOpt = WL.PlayerID.Neutral;
				mod.SetStructuresOpt = getStructureTable(game, terr.ID);
				table.insert(mods, mod);
			end
		end
	end
	return mods;
end

function getTeamName(n)
	local list = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	local ret = "";
	if n > #list then
		ret = ret .. list[math.floor(n/#list)];
	end
	ret = ret .. list[n % #list + 1];
	return ret;
end