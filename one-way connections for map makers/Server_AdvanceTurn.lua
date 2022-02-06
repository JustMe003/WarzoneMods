
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
		if Mod.PublicGameData.OneWayConnections[order.From] ~= nil then
			for _, conn in pairs(Mod.PublicGameData.OneWayConnections[order.From]) do
				if conn == order.To then
					skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
					addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, game.ServerGame.Game.PlayingPlayers[order.PlayerID].DisplayName(nil, false) .. " tried to send armies the wrong way from " .. game.Map.Territories[order.From].Name .. " to " .. game.Map.Territories[order.To].Name, {}, {WL.TerritoryModification.Create(order.From), WL.TerritoryModification.Create(order.To)}));
					return;
				end
			end
		end
	end
end
