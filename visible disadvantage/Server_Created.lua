function Server_Created(game, settings)
	local cards = settings.Cards;
	if settings.Cards[WL.CardID.Spy] == nil then
		cards[WL.CardID.Spy] = WL.CardGameSpy.Create(1, 0, 0, 0, 1, false);
	end
	for i, v in pairs(game.Settings.Cards) do
		print(i, v);
	end
	settings.Cards = cards;
end