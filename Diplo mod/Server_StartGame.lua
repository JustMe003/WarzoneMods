require("utilities");
function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	local playerData = Mod.PlayerGameData;
	local relations = {};
	local isInFaction = {};
	local playerInFaction = {};
	local count = 0;
	if game.Settings.CustomScenario ~= nil and Mod.Settings.Configuration ~= nil and game.Settings.AutomaticTerritoryDistribution then
		data.Factions = Mod.Settings.Configuration.Factions
		local hasFactionLeader = {};
		for i, _ in pairs(data.Factions) do
			data.Factions[i].FactionMembers = {};
			data.Factions[i].Offers = {};
			data.Factions[i].PendingOffers = {};
			data.Factions[i].FactionChat = {};
			print(Mod.Settings.GlobalSettings.ApproveFactionJoins);
			if Mod.Settings.GlobalSettings.ApproveFactionJoins then
				data.Factions[i].JoinRequests = {};
			end
			hasFactionLeader[i] = false;
		end
		for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
			count = count + p.Income(0, game.ServerGame.TurnZeroStanding, true, true).Total;
			if not p.IsAI then
				playerData[p.ID] = {};
				playerData[p.ID].LastMessage = game.ServerGame.Game.ServerTime;
				playerData[p.ID].Notifications = setPlayerNotifications();
				playerData[p.ID].NumberOfNotifications = 0;
				playerData[p.ID].PendingOffers = {};
				playerData[p.ID].Offers = {};
			end
			relations[p.ID] = {};
			for i, _ in pairs(relations) do
				if Mod.Settings.Configuration.Relations[p.Slot] ~= nil then
					if i ~= p.ID then
						if Mod.Settings.Configuration.Relations[game.ServerGame.Game.PlayingPlayers[i].Slot] ~= nil then
							relations[p.ID][i] = Mod.Settings.Configuration.Relations[p.Slot][game.ServerGame.Game.PlayingPlayers[i].Slot];
							relations[i][p.ID] = Mod.Settings.Configuration.Relations[p.Slot][game.ServerGame.Game.PlayingPlayers[i].Slot];
						end
					end
				end
				if relations[p.ID][i] == nil then
					relations[p.ID][i] = "InPeace";
					relations[i][p.ID] = "InPeace";
				end
			end
			isInFaction[p.ID] = Mod.Settings.Configuration.SlotInFaction[p.Slot] ~= nil
			playerInFaction[p.ID] = Mod.Settings.Configuration.SlotInFaction[p.Slot];
			if isInFaction[p.ID] then
				table.insert(data.Factions[playerInFaction[p.ID]].FactionMembers, p.ID);
				if data.Factions[playerInFaction[p.ID]].FactionLeader == p.Slot and not hasFactionLeader[playerInFaction[p.ID]] then
					data.Factions[playerInFaction[p.ID]].FactionLeader = p.ID;
					hasFactionLeader[playerInFaction[p.ID]] = true;
				end
			end
		end
		for faction, _ in pairs(data.Factions) do
			if not hasFactionLeader[faction] then
				if #data.Factions[faction].FactionMembers > 0 then
					data.Factions[faction].FactionLeader = data.Factions[faction].FactionMembers[1];
				else
					data.Factions[faction] = nil;
				end
			end
		end
	else
		for i, p in pairs(game.ServerGame.Game.PlayingPlayers) do
			count = count + p.Income(0, game.ServerGame.TurnZeroStanding, true, true).Total;
			relations[i] = {};
			isInFaction[i] = false;
			for k, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
				relations[i][k] = "InPeace";
			end
			if not p.IsAI then
				playerData[i] = {};
				playerData[i].LastMessage = game.ServerGame.Game.ServerTime;
				playerData[i].Notifications = setPlayerNotifications();
				playerData[i].NumberOfNotifications = 0;
				playerData[i].PendingOffers = {};
				playerData[i].Offers = {};
			end
		end
	end
	-- for i, v in pairs(relations) do
		-- for k, j in pairs(v) do
			-- print(i, k, j);
		-- end
	-- end
	data.TotalIncomeOfAllPlayers = count;
	data.Relations = relations;
	data.IsInFaction = isInFaction;
	data.PlayerInFaction = playerInFaction;
	data.Events = {};
	Mod.PlayerGameData = playerData;
	Mod.PublicGameData = data;
end
