function Server_AdvanceTurn_Start(game, addNewOrder)
	t = {};
	for i, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		if p.IsAIOrHumanTurnedIntoAI then
			t[i] = {};
			for instance, _ in pairs(game.ServerGame.Game.LatestTurnStanding.Cards[i].WholeCards) do
				print(instance);
				t[i][instance] = true;
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if(string.find(order.proxyType, "GameOrderPlayCard") ~= nil)then
		if(game.ServerGame.Game.Players[order.PlayerID].IsAIOrHumanTurnedIntoAI == true)then
			if(t[order.PlayerID][order.CardInstanceID] ~= nil) then
				if(order.proxyType == "GameOrderPlayCardAbandon" and Mod.Settings.CanPlayEMB == false)then
					skipThisOrder(WL.ModOrderControl.Skip);
				elseif(order.proxyType == "GameOrderPlayCardDiplomacy" and Mod.Settings.CanPlayDiplomacy == false)then
					skipThisOrder(WL.ModOrderControl.Skip);
				elseif(order.proxyType == "GameOrderPlayCardSanctions" and Mod.Settings.CanPlaySanctions == false)then
					skipThisOrder(WL.ModOrderControl.Skip);
				elseif(order.proxyType == "GameOrderPlayCardBlockade" and Mod.Settings.CanPlayBlockade == false)then
					skipThisOrder(WL.ModOrderControl.Skip);
				elseif(order.proxyType == "GameOrderPlayCardBomb" and Mod.Settings.CanPlayBomb == false)then
					skipThisOrder(WL.ModOrderControl.Skip);
				end
			end
		end
	end
end
