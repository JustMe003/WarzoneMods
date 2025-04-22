require("utilities2");
function Server_StartGameMain(game, standing)
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
			if Mod.Settings.GlobalSettings.ApproveFactionJoins then
				data.Factions[i].JoinRequests = {};
			end
			hasFactionLeader[i] = false;
		end
		for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
			count = count + p.Income(0, game.ServerGame.TurnZeroStanding, true, true).Total;
			if not p.IsAI then
				playerData[p.ID] = {};		-- Initialization notifications system
				playerData[p.ID].LastMessage = game.ServerGame.Game.ServerTime;
				playerData[p.ID].Notifications = setPlayerNotifications();
				playerData[p.ID].NumberOfNotifications = 0;
				playerData[p.ID].PendingOffers = {};
				playerData[p.ID].Offers = {};
				playerData[p.ID].PersonalSettings = {
					WindowWidth = 500,
					WindowHeight = 600,
					DisableWarningAlerts = false
				};
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
					if Mod.Settings.GlobalSettings.PlayersStartAtWar == nil or not Mod.Settings.GlobalSettings.PlayersStartAtWar then
						relations[p.ID][i] = "InPeace";
						relations[i][p.ID] = "InPeace";
					else
						relations[p.ID][i] = "AtWar";
						relations[i][p.ID] = "AtWar";
					end
				end
			end
			isInFaction[p.ID] = Mod.Settings.Configuration.SlotInFaction[p.Slot] ~= nil;
			playerInFaction[p.ID] = {};
			if isInFaction[p.ID] then
				playerInFaction[p.ID] = Mod.Settings.Configuration.SlotInFaction[p.Slot];
				for _, faction in pairs(playerInFaction[p.ID]) do
					table.insert(data.Factions[faction].FactionMembers, p.ID);
					if data.Factions[faction].FactionLeader == p.Slot and not hasFactionLeader[faction] then
						data.Factions[faction].FactionLeader = p.ID;
						hasFactionLeader[faction] = true;
					end
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
			playerInFaction[p.ID] = {};
			for k, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
				if Mod.Settings.GlobalSettings.PlayersStartAtWar == nil or not Mod.Settings.GlobalSettings.PlayersStartAtWar then
					relations[i][k] = "InPeace";
				else
					relations[i][k] = "AtWar";
				end
			end
			if not p.IsAI then
				playerData[i] = {};
				playerData[i].LastMessage = game.ServerGame.Game.ServerTime;
				playerData[i].Notifications = setPlayerNotifications();
				playerData[i].NumberOfNotifications = 0;
				playerData[i].PendingOffers = {};
				playerData[i].Offers = {};
				playerData[i].PersonalSettings = {
					WindowWidth = 500,
					WindowHeight = 600,
					DisableWarningAlerts = false
				};
			end
		end
	end
	data.TotalIncomeOfAllPlayers = count;
	data.Relations = relations;
	data.IsInFaction = isInFaction;
	data.PlayerInFaction = playerInFaction;
	data.Events = {};
	data.VersionNumber = 6;
	data.EventsHistory = {};
	Mod.PlayerGameData = playerData;
	Mod.PublicGameData = data;
end
