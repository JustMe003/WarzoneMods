function Server_StartGame(game, standing)
	if game.Settings.CustomScenario == nil and game.Settings.AutomaticTerritoryDistribution then return; end
	local s = standing;
	local cards = s.Cards;
	local armies = 0;
	if game.Settings.Cards[WL.CardID.Reinforcement] ~= nil then
		if game.Settings.Cards[WL.CardID.Reinforcement].Mode == WL.ReinforcementCardMode.Fixed then
			armies = cardGame.FixedArmies;		-- fixed amount
		elseif game.Settings.Cards[WL.CardID.Reinforcement].Mode == WL.ReinforcementCardMode.ProgressiveByNumberOfTerritories then
			armies = round(getTableLength(game.ServerGame.Game.PlayingPlayers) * game.Settings.Cards[WL.CardID.Reinforcement].ProgressivePercentage)
		else
			armies = 1;			-- Turn 0, so 0 * x		To give some armies it is always 1
		end
	end
	for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		local playerCards = WL.PlayerCards.Create(p.ID);
		local newPieces = playerCards.Pieces;
		local newCards = playerCards.WholeCards;
		for card, cardGame in pairs(game.Settings.Cards) do
			local totalPieces = cardGame.InitialPieces;
			if Mod.Settings.CardPiecesFromStart[p.Slot] ~= nil and Mod.Settings.CardPiecesFromStart[p.Slot][card] ~= nil then
				totalPieces = totalPieces + Mod.Settings.CardPiecesFromStart[p.Slot][card];
			end
			if card ~= WL.CardID.Reinforcement then
				for k = 1, math.floor(totalPieces / cardGame.NumPieces) do
					local instance = WL.NoParameterCardInstance.Create(card);
					newCards[instance.ID] = instance;
				end
				newPieces[card] = totalPieces % cardGame.NumPieces;
			else
				for k = 1, math.floor(totalPieces / cardGame.NumPieces) do
					local instance = WL.ReinforcementCardInstance.Create(armies);
					newCards[instance.ID] = instance;
				end
				newPieces[card] = totalPieces % cardGame.NumPieces;
			end
		end
		playerCards.WholeCards = newCards;
		playerCards.Pieces = newPieces;
		cards[p.ID] = playerCards;
	end
	s.Cards = cards;
	standing = s;
end

function round(n)
	return math.floor(n + 0.5);
end

function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end
