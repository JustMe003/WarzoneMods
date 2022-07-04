require("utilities");
function Server_AdvanceTurn_Start(game, addNewOrder)
	local data = Mod.PublicGameData;
	for i = 1, #data.Events do
		local group;
		if not Mod.Settings.GlobalSettings.VisibleHistory then
			if data.PlayerInFaction[data.Events[i].PlayerID] ~= nil then
				group = data.Factions[data.PlayerInFaction[data.Events[i].PlayerID]].FactionMembers;
			else
				group = {data.Events[i].PlayerID};
			end
		else
			group = nil;
		end
		addNewOrder(WL.GameOrderEvent.Create(data.Events[i].PlayerID, data.Events[i].Message, group, {}, {}, {}));
	end
	data.Events = {};
	Mod.PublicGameData = data;
	if game.Settings.FogLevel ~= 1 then
		playSpyCards(game, addNewOrder);
	end
	playDiploCards(game, addNewOrder);
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local data = Mod.PublicGameData;
	local playerData = Mod.PlayerGameData;
	local count = 0;
	for i, p in pairs(game.Game.Players) do
		if p.State ~= WL.GamePlayerState.EndedByVote and p.State ~= WL.GamePlayerState.RemovedByHost and p.State ~= WL.GamePlayerState.Declined then
			if (p.State == WL.GamePlayerState.Eliminated) or (p.State == WL.GamePlayerState.Booted and not game.Settings.GlobalSettings.BootedPlayersTurnIntoAIs) or (p.State == WL.GamePlayerState.SurrenderAccepted and not game.Settings.GlobalSettings.SurrenderedPlayersTurnIntoAIs) then
				if data.Relations[i] ~= nil then
					for k, _ in pairs(data.Relations[i]) do
						data.Relations[k][i] = nil;
					end
					data.Relations[i] = nil;
				end
				if data.IsInFaction[i] then
					local index = 0;
					for k, v in pairs(data.Factions[data.PlayerInFaction[i]].FactionMembers) do
						if v == i then
							index = k;
							break;
						end
					end
					table.remove(data.Factions[data.PlayerInFaction[i]].FactionMembers, index);
					if data.Factions[data.PlayerInFaction[i]].FactionLeader == i then
						if #data.Factions[data.PlayerInFaction[i]].FactionMembers <= 0 then
							data.Factions[data.PlayerInFaction[i]] = nil;
							for faction, _ in pairs(data.Factions) do
								if faction ~= data.PlayerInFaction[i] then
									data.Factions[faction].AtWar[data.PlayerInFaction[i]] = nil;
									for k, v in pairs(data.Factions[faction].PendingOffers) do
										if faction == v then
											table.remove(data.Factions[faction].PendingOffers, k);
											data.Factions[faction].Offers[data.PlayerInFaction[i]] = nil;
										end
									end
								end
							end
							table.insert(data.Events, createEvent("'" .. data.PlayerInFaction[i] .. "' was deleted since it had no more members", WL.PlayerID.Neutral));
						else
							data.Factions[data.PlayerInFaction[i]].FactionLeader = data.Factions[data.PlayerInFaction[i]].FactionMembers[1];
							local group;
							if not Mod.Settings.GlobalSettings.VisibleHistory then
								if data.PlayerInFaction[t.PlayerID] ~= nil then
									group = data.Factions[data.PlayerInFaction[t.PlayerID]].FactionMembers;
								end
							end
							table.insert(data.Events, createEvent("The new faction leader of '" .. data.PlayerInFaction[i] .. "' is now " .. game.ServerGame.Game.Players[i].DisplayName(nil, false), i));
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
								if data.Relations[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID][i] ~= "InFaction" and ((Mod.Settings.GlobalSettings.AICanDeclareOnPlayer and not game.ServerGame.Game.PlayingPlayers[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID].IsAIOrHumanTurnedIntoAI) or (Mod.Settings.GlobalSettings.AICanDeclareOnAI and game.ServerGame.Game.PlayingPlayers[game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID].IsAIOrHumanTurnedIntoAI)) then
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
					table.insert(data.Events, createEvent(game.ServerGame.Game.Players[i].DisplayName(nil, false) .. " declared war on " .. game.ServerGame.Game.Players[target].DisplayName(nil, false), i));
				end
			end
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