require("utilities");
function Server_AdvanceTurn_Start(game, addNewOrder)
	local data = Mod.PublicGameData;
	if data.VersionNumber ~= nil and data.VersionNumber >= 5 then
		for i = 1, #data.Events do
			addNewOrder(WL.GameOrderEvent.Create(data.Events[i].PlayerID, data.Events[i].Message, filterDeadPlayers(game, data.Events[i].VisibleTo), {}, {}, {}));
		end
	end
	if data.VersionNumber ~= nil and data.VersionNumber <= 5 then
		for p, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
			if data.PlayerInFaction[p] ~= nil then
				if type(data.PlayerInFaction[p]) ~= type({}) then
					local f = data.PlayerInFaction[p];
					data.PlayerInFaction[p] = {};
					table.insert(data.PlayerInFaction[p], f);
				end
			else
				data.PlayerInFaction[p] = {};
			end
		end
		data.VersionNumber = 6;
	end
	data.Events = {};
	Mod.PublicGameData = data;
	if Mod.Settings.GlobalSettings.PlaySpyOnFactionMembers ~= nil and Mod.Settings.GlobalSettings.PlaySpyOnFactionMembers and game.Settings.FogLevel ~= 1 then
		playSpyCards(game, addNewOrder);
	end
	if game.Game.TurnNumber == 1 then
		playDiploCards(game, addNewOrder);
	end
	if data.FirstOrderDiplos ~= nil then
		for i, t in pairs(data.FirstOrderDiplos) do
			for _, v in pairs(t) do
				if data.Relations[i][v] ~= "AtWar" then
					local instance = WL.NoParameterCardInstance.Create(WL.CardID.Diplomacy);
					addNewOrder(WL.GameOrderReceiveCard.Create(i, {instance.ID}));
					addNewOrder(WL.GameOrderPlayCardSpy.Create(instance.ID, i, v));
				end
			end
		end
	end
	data.FirstOrderDiplos = {};
	Mod.PublicGameData = data;
end

function Server_AdvanceTurn_End(game, addNewOrder)
	if game.Game.TurnNumber > 1 then
		playDiploCards(game, addNewOrder);
	end
	local data = Mod.PublicGameData;
	local playerData = Mod.PlayerGameData;
	local count = 0;
	for i, p in pairs(game.Game.Players) do
		if p.State ~= WL.GamePlayerState.EndedByVote and p.State ~= WL.GamePlayerState.RemovedByHost and p.State ~= WL.GamePlayerState.Declined then
			if (p.State == WL.GamePlayerState.Eliminated) or (p.State == WL.GamePlayerState.Booted and not game.Settings.BootedPlayersTurnIntoAIs) or (p.State == WL.GamePlayerState.SurrenderAccepted and not game.Settings.SurrenderedPlayersTurnIntoAIs) then
				if data.Relations[i] ~= nil then
					for k, _ in pairs(data.Relations[i]) do
						data.Relations[k][i] = nil;
					end
					data.Relations[i] = nil;
				end
				if data.IsInFaction[i] then
					local index = 0;
					for _, faction in pairs(data.PlayerInFaction[i]) do
						for k, v in pairs(data.Factions[faction].FactionMembers) do
							if v == i then
								index = k;
								break;
							end
						end
						table.remove(data.Factions[faction].FactionMembers, index);
						if data.Factions[faction].FactionLeader == i then
							if #data.Factions[faction].FactionMembers <= 0 then
								data.Factions[faction] = nil;
								for faction2, _ in pairs(data.Factions) do
									if faction ~= faction2 then
										data.Factions[faction2].AtWar[faction] = nil;
										for k, v in pairs(data.Factions[faction2].PendingOffers) do
											if faction2 == v then
												table.remove(data.Factions[faction2].PendingOffers, k);
												data.Factions[faction2].Offers[faction] = nil;
											end
										end
									end
								end
								table.insert(data.Events, createEvent("'" .. faction .. "' was deleted since it had no more members", WL.PlayerID.Neutral));
							else
								data.Factions[faction].FactionLeader = data.Factions[faction].FactionMembers[1];
								table.insert(data.Events, createEvent("The new faction leader of '" .. faction .. "' is now " .. game.ServerGame.Game.Players[data.Factions[faction].FactionLeader].DisplayName(nil, false), data.Factions[faction].FactionLeader));
							end
						end
					end
					data.PlayerInFaction[i] = nil;
					data.IsInFaction[i] = false;
				end
			end
		end
	end
	for i, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		if not p.IsAI then
			playerData[i].NumberOfNotifications = 0;
		end
		count = count + p.Income(0, game.ServerGame.LatestTurnStanding, true, true).Total;
		if p.State == WL.GamePlayerState.Playing and p.IsAIOrHumanTurnedIntoAI and (Mod.Settings.GlobalSettings.AICanDeclareOnPlayer or Mod.Settings.GlobalSettings.AICanDeclareOnAI) then
			local isAtWar = false;
			for _, state in pairs(data.Relations[i]) do
				if state == "AtWar" then
					isAtWar = true;
					break;
				end
			end
			if not isAtWar then
				local potentialTargets = {};
				for terrID, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
					if terr.OwnerPlayerID == i then
						for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
							if game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID ~= WL.PlayerID.Neutral and game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID ~= i then
								if data.Relations[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID][i] ~= "InFaction" and ((Mod.Settings.GlobalSettings.AICanDeclareOnPlayer and not game.ServerGame.Game.PlayingPlayers[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID].IsAIOrHumanTurnedIntoAI) or (Mod.Settings.GlobalSettings.AICanDeclareOnAI and game.ServerGame.Game.PlayingPlayers[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID].IsAIOrHumanTurnedIntoAI)) and (playerData[i] == nil or playerData[i].Cooldowns == nil or playerData[i].Cooldowns.WarDeclarations == nil or playerData[i].Cooldowns[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID] == nil) then
									table.insert(potentialTargets, game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID);
								end
							end
						end
					end
				end
				if #potentialTargets > 0 then
					local target = potentialTargets[math.random(#potentialTargets)];
					data.Relations[target][i] = "AtWar";
					data.Relations[i][target] = "AtWar";
					if not game.ServerGame.Game.PlayingPlayers[target].IsAI then
						table.insert(playerData[target].Notifications.WarDeclarations, i);
					end
					table.insert(data.Events, createEvent(game.ServerGame.Game.Players[i].DisplayName(nil, false) .. " declared war on " .. game.ServerGame.Game.Players[target].DisplayName(nil, false), i, getPlayerHashMap(data, i, target)));
				end
			end
		end
		if playerData[i] ~= nil then
			playerData[i].Cooldowns = nil;
		end
	end
	data.TotalIncomeOfAllPlayers = count;
	Mod.PublicGameData = data;
	Mod.PlayerGameData = playerData;
end

function playDiploCards(game, addNewOrder)
	local a = {};
	for i, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		table.insert(a, i);
	end
	local count = 2;
	for _, v in pairs(a) do
		local instances = {};
		for i = count, #a do
			if Mod.PublicGameData.Relations[v][a[i]] ~= "AtWar" and not sameTeam(game.ServerGame.Game.PlayingPlayers[a[i]], game.ServerGame.Game.PlayingPlayers[v]) then
				table.insert(instances, WL.NoParameterCardInstance.Create(WL.CardID.Diplomacy));
			end
		end
		if #instances > 0 then
			addNewOrder(WL.GameOrderReceiveCard.Create(v, instances));
			local count2 = 1;
			for i = count, #a do
				if Mod.PublicGameData.Relations[v][a[i]] ~= "AtWar" and not sameTeam(game.ServerGame.Game.PlayingPlayers[a[i]], game.ServerGame.Game.PlayingPlayers[v]) then
					addNewOrder(WL.GameOrderPlayCardDiplomacy.Create(instances[count2].ID, v, v, a[i]));
					count2 = count2 + 1;
				end
			end
		end
		count = count + 1;
	end
end

function playSpyCards(game, addNewOrder)
	for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		if not p.IsAI then
			local a = {};
			local instances = {};
			for i, v in pairs(Mod.PublicGameData.Relations[p.ID]) do
				if v == "InFaction" and p.ID ~= i and not sameTeam(p, game.ServerGame.Game.PlayingPlayers[i]) then
					table.insert(a, i);
					table.insert(instances, WL.NoParameterCardInstance.Create(WL.CardID.Spy));
				end
			end
			if #a > 0 then
				addNewOrder(WL.GameOrderReceiveCard.Create(p.ID, instances));
				for i = 1, #a do
					addNewOrder(WL.GameOrderPlayCardSpy.Create(instances[i].ID, p.ID, a[i]));
				end
			end
		end
	end
end

function sameTeam(player, player2)
	if player.Team == -1 then return false; end
	return player.Team == player2.Team;
end