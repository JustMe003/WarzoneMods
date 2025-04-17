require("Util");

function Server_AdvanceTurn_End(game, addNewOrder)
	if game.Settings.CustomScenario == nil and game.Settings.AutomaticTerritoryDistribution then return; end
	if game.Settings.Cards == nil then return; end
	for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		local pieces = {};
		local cardsToBeRemoved = {};
		for card, amount in pairs(Mod.Settings.CardPiecesEachTurn[p.Slot] or {}) do
			card = (Mod.PublicGameData.ModToGame or {})[card] or card;
			if game.Settings.Cards[card] ~= nil then
				if amount > 0 then
					pieces[card] = amount;
				else
					if game.ServerGame.LatestTurnStanding.Cards ~= nil then
						local playerCards = game.ServerGame.LatestTurnStanding.Cards[p.ID];
						local totalPieces = 0;
						if playerCards.Pieces ~= nil then
							totalPieces = playerCards.Pieces[card];
						end
						if totalPieces >= math.abs(amount) then
							pieces[card] = amount;
						else
							local totalCards = {};
							if playerCards.WholeCards ~= nil then
								for _, instance in pairs(playerCards.WholeCards) do
									if instance.CardID == card then
										table.insert(totalCards, instance);
									end
								end
							end
							for i = 1, math.min(#totalCards, math.ceil(math.abs(totalPieces + amount) / game.Settings.Cards[card].NumPieces)) do
								table.insert(cardsToBeRemoved, totalCards[i]);
							end
							if #totalCards * game.Settings.Cards[card].NumPieces + totalPieces >= -amount then
								pieces[card] = (totalPieces + amount ) % game.Settings.Cards[card].NumPieces - totalPieces;
							else
								pieces[card] = -totalPieces;
							end
						end
					end
				end
			end
		end
		if getTableLength(pieces) > 0 then
			local order = WL.GameOrderEvent.Create(p.ID, "adjusted pieces", {}, {}, {}, {});
			local t = {};
			t[p.ID] = pieces;
			order.AddCardPiecesOpt = t;
			addNewOrder(order);
		end
		for _, instance in pairs(cardsToBeRemoved) do
			local order = WL.GameOrderEvent.Create(p.ID, "Removed " .. getCardName(instance.CardID) .. " card", {}, {}, {}, {});
			local t = {};
			t[p.ID] = instance.ID;
			order.RemoveWholeCardsOpt = t;
			addNewOrder(order);
		end
	end
end

function getCardName(id)
	for name, cardID in pairs(WL.CardID) do
		if cardID == id then
			return name;
		end
	end
	for name, cardID in pairs(Mod.Settings.CustomCards or {}) do
		if Mod.PublicGameData.GameToMod[id] == cardID then
			return name;
		end
	end
	return "No name found";
end