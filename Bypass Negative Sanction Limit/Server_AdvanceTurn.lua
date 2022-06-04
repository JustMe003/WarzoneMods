function Server_AdvanceTurn_End(game, addNewOrder)
	if game.Settings.Cards == nil then return; end
	if game.Settings.Cards[WL.CardID.Sanctions] == nil then return; end
	if game.Settings.Cards[WL.CardID.Sanctions].Percentage >= 0 then return; end
	if game.ServerGame.LatestTurnStanding.ActiveCards == nil then return; end
	local t = {};
	for pid, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		t[pid] = 0
	end
	for _, ac in pairs(game.ServerGame.LatestTurnStanding.ActiveCards) do
		if ac.Card.CardID == WL.CardID.Sanction then
			t[ac.Card.SanctionedPlayerID] = t[ac.Card.SanctionedPlayerID] + 1;
		end
	end
	for pid, v in pairs(t) do
		local income = game.ServerGame.Game.PlayingPlayers[pid].Income.Total;
		local mod = WL.IncomeMod.Create(pid, math.min(1000000, income * math.pow(game.Settings.Cards[WL.CardID.Sanctions].Percentage, v)) - 10000, "Bypass negative sanctions limit");
	end
end
