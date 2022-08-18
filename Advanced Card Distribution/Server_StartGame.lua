function Server_StartGame(game, standing)
	if game.Settings.CustomScenario == nil and game.Settings.AutomaticTerritoryDistribution then return; end
	local s = standing;
	local cards = s.Cards;
	local activeCards = s.ActiveCards;
	for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		local playerCards = WL.PlayerCards.Create(p.ID);
		local newPieces = playerCards.Pieces;
		local newCards = playerCards.WholeCards;
		for i, v in pairs(Mod.Settings.CardPiecesFromStart[p.Slot]) do
			if game.Settings.Cards[i] ~= nil then
				print(i, v, game.Settings.Cards[i].InitialPieces);
				local totalPieces = math.max(0, game.Settings.Cards[i].InitialPieces + v);
				for k = 1, math.floor(totalPieces / game.Settings.Cards[i].NumPieces) do
					local instance = WL.NoParameterCardInstance.Create(i);
					newCards[instance.ID] = instance;
				end
				newPieces[i] = totalPieces % game.Settings.Cards[i].NumPieces;
				-- local totalCards = 0;
				-- if cards[p.ID] ~= nil and cards[p.ID].WholeCards ~= nil then
					-- totalCards = getTableLength(cards[p.ID].WholeCards);
				-- end
				-- local totalPieces = 0;
				-- if cards[p.ID] ~= nil and cards[p.ID].Pieces ~= nil and cards[p.ID].Pieces[i] ~= nil then
					-- totalPieces = cards[p.ID].Pieces[i];
				-- end
				-- newPieces[i] = totalPieces + getCardPieces(game, i, v);
				-- if newPieces[i] >= game.Settings.Cards[i].NumPieces then
					-- totalCards = totalCards + 1;
					-- newPieces[i] = newPieces[i] - game.Settings.Cards[i].NumPieces;
				-- elseif newPieces[i] < 0 then
					-- totalCards = totalCards - 1;
					-- newPieces[i] = game.Settings.Cards[i].NumPieces + newPieces[i];
				-- end
				-- for index = 1, math.max(0, totalCards + getWholeCards(game, i, v)) do 
					-- local instance = WL.NoParameterCardInstance.Create(i);
					-- newCards[instance.ID] = instance;
				-- end
			end
		end
		playerCards.WholeCards = newCards;
		playerCards.Pieces = newPieces;
		cards[p.ID] = playerCards;
	end
	s.Cards = cards;
	standing = s;
end

function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end

function getWholeCards(game, card, value)
	if value < 0 then
		return math.ceil(value / game.Settings.Cards[card].NumPieces);
	else
		return math.floor(value / game.Settings.Cards[card].NumPieces);
	end
end

function getCardPieces(game, card, value)
	if value < 0 then
		return -math.abs(game.Settings.Cards[card].NumPieces - (value % game.Settings.Cards[card].NumPieces));
	else
		return value % game.Settings.Cards[card].NumPieces;
	end
end
