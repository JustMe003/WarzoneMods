function Server_AdvanceTurn_Start(game, addNewOrder)
	if game.Settings.FogLevel ~= 1 then
		playSpyCards(game, addNewOrder);
	end
	playDiploCards(game, addNewOrder);
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local playerData = Mod.PlayerGameData;
	for i, _ in pairs(game.Game.PlayingPlayers) do
		playerData[i].NumberOfNotifications = 0;
	end
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