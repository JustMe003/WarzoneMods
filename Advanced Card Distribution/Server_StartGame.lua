function Server_StartGame(game, standing)
	if game.Settings.CustomScenario == nil and game.Settings.AutomaticTerritoryDistribution then return; end
	local s = standing;
	local cards = s.Cards;
	for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		local playerCards = WL.PlayerCards.Create(p.ID);
		local newPieces = playerCards.Pieces;
		local newCards = playerCards.WholeCards;
		for card, cardGame in pairs(game.Settings.Cards) do
			if card ~= WL.CardID.Reinforcement then
				local totalPieces = cardGame.InitialPieces;
				if Mod.Settings.CardPiecesFromStart[p.Slot] ~= nil and Mod.Settings.CardPiecesFromStart[p.Slot][card] ~= nil then
					totalPieces = totalPieces + Mod.Settings.CardPiecesFromStart[p.Slot][card];
				end
				for k = 1, math.floor(totalPieces / cardGame.NumPieces) do
					local instance = WL.NoParameterCardInstance.Create(card);
					newCards[instance.ID] = instance;
				end
				newPieces[card] = totalPieces % cardGame.NumPieces;
			else
				local armies = 0;
				for i, v in pairs(game.ServerGame.TurnZeroStanding.Cards[p.ID].WholeCards) do
					if v.CardID == WL.CardID.Reinforcement then
						armies = v.Armies;
						break;
					end
				end
				if armies > 0 then
					for k = 1, math.floor(cardGame.InitialPieces / cardGame.NumPieces) do
						local instance = WL.ReinforcementCardInstance.Create(armies);
						newCards[instance.ID] = instance;
					end
				end
				newPieces[card] = cardGame.InitialPieces % cardGame.NumPieces;
			end
		end
		playerCards.WholeCards = newCards;
		playerCards.Pieces = newPieces;
		cards[p.ID] = playerCards;
	end
	s.Cards = cards;
	standing = s;
end
