function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if(string.find(order.proxyType, "GameOrderPlayCard") ~= nil)then
		if(game.ServerGame.Game.Players[order.PlayerID].IsAIOrHumanTurnedIntoAI == true)then
			if(order.proxyType == "GameOrderPlayCardAbandon" and Mod.Settings.CanPlayEMB == false)then
				skipThisOrder(WL.ModOrderControl.Skip);
--			elseif(order.proxyType == "GameOrderPlayCardReinforcement" and Mod.Settings.CanPlayReinforcement == false)then
--				skipThisOrder(WL.ModOrderControl.Skip);
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
