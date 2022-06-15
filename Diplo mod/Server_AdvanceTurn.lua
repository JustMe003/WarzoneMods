function Server_AdvanceTurn_Start(game, addNewOrder)
	local data = Mod.PublicGameData;
	for i, t in pairs(data.Events) do
		addNewOrder(WL.GameOrderEvent.Create(t.PlayerID, i .. ": " .. t.Message, nil, {}, {}, {}));
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
	for i, p in pairs(game.Game.PlayingPlayers) do
		if not p.IsAI then
			playerData[i].NumberOfNotifications = 0;
		end
		if p.State ~= WL.GamePlayerState.EndedByVote then
			if (p.State == WL.GamePlayerState.Eliminated) or (p.State == WL.GamePlayerState.Booted and not game.Settings.BootedPlayersTurnIntoAIs) or (p.State == WL.GamePlayerState.SurrenderAccepted and not game.Settings.SurrenderedPlayersTurnIntoAIs) then
				if data.IsInFaction[i] then
					local index = 0;
					for k, v in pairs(data.Factions[data.PlayerInFaction[i]].FactionMembers) do
						if v == i then
							index = k;
							break;
						end
					end
					table.remove(data.Factions[data.PlayerInFaction[i]].FactionMembers, index);
					data.PlayerInFaction[i] = nil;
					data.IsInFaction[i] = false;
				end
			end
		end
	end
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