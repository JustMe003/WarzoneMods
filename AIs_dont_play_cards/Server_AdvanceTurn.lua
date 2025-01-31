function Server_AdvanceTurn_Start(game, addNewOrder)
	t = {};
	for i, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		if p.IsAIOrHumanTurnedIntoAI then
			t[i] = {};
			if(game.ServerGame.LatestTurnStanding.Cards ~= nil and game.ServerGame.LatestTurnStanding.Cards[i] ~= nil and game.ServerGame.LatestTurnStanding.Cards[i].WholeCards ~= nil) then
				for instance, _ in pairs(game.ServerGame.LatestTurnStanding.Cards[i].WholeCards) do
					t[i][instance] = true;
				end
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (string.find(order.proxyType, "GameOrderPlayCard") ~= nil) then
		if (game.ServerGame.Game.Players[order.PlayerID].IsAIOrHumanTurnedIntoAI == true) then
			if (t[order.PlayerID][order.CardInstanceID] ~= nil) then
				if (order.proxyType == "GameOrderPlayCardAbandon" and Mod.Settings.CanPlayEMB == false) then
					skipOrRemove(game, order, skipThisOrder, addNewOrder);
				elseif (order.proxyType == "GameOrderPlayCardDiplomacy" and Mod.Settings.CanPlayDiplomacy == false) then
					skipOrRemove(game, order, skipThisOrder, addNewOrder);
				elseif (order.proxyType == "GameOrderPlayCardSanctions" and Mod.Settings.CanPlaySanctions == false) then
					skipOrRemove(game, order, skipThisOrder, addNewOrder);
				elseif (order.proxyType == "GameOrderPlayCardBlockade" and Mod.Settings.CanPlayBlockade == false) then
					skipOrRemove(game, order, skipThisOrder, addNewOrder);
				elseif (order.proxyType == "GameOrderPlayCardBomb" and Mod.Settings.CanPlayBomb == false) then
					skipOrRemove(game, order, skipThisOrder, addNewOrder);
				end
			end
		end
	end
end

function skipOrRemove(game, order, skipThisOrder, addNewOrder)
	
	if countCards(game.ServerGame.LatestTurnStanding.Cards[order.PlayerID].WholeCards) >= game.Settings.MaxCardsHold then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		local event = WL.GameOrderEvent.Create(order.PlayerID, "Removing card because of maximum card hold limit");
		event.RemoveWholeCardsOpt = {
			[order.PlayerID] = order.CardInstanceID
		};
		addNewOrder(event);
	else
		skipThisOrder(WL.ModOrderControl.Skip);
	end
end

function countCards(cards)
	local c = 0;
	for _, _ in pairs(cards) do
		c = c + 1;
	end
	return c;
end
