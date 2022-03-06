function Server_AdvanceTurn_End(game, addNewOrder)
	if game.Settings.Cards ~= nil then
		if game.Settings.Cards[WL.CardID.Spy] ~= nil then
			local mostIncome = 0;
			for _, player in pairs(game.Game.PlayingPlayers) do
				if player.Income(0, game.ServerGame.LatestTurnStanding, true, false).Total > mostIncome then
					mostIncome = player.Income(0, game.ServerGame.LatestTurnStanding, true, false).Total;
				end
			end
			for _, player in pairs(game.Game.PlayingPlayers) do
				if player.Income(0, game.ServerGame.LatestTurnStanding, true, false).Total == mostIncome then
					for _, player2 in pairs(game.Game.PlayingPlayers) do
						if player.ID ~= player2.ID and not sameTeam(player, player2) then
							print(player.Team, player2.Team);
							local instance = WL.NoParameterCardInstance.Create(WL.CardID.Spy);
							addNewOrder(WL.GameOrderReceiveCard.Create(player2.ID, {instance}));
							addNewOrder(WL.GameOrderPlayCardSpy.Create(instance.ID, player2.ID, player.ID));
						end
					end
				end
			end
		end
	end
end

function sameTeam(player, player2)
	if player.Team == -1 then return false; end
	return player.Team == player2.Team;
end