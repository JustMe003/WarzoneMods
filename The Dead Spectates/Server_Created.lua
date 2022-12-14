function Server_Created(game, settings)
    local cards = {};
    for i, v in pairs(settings.Cards) do
        cards[i] = v;
    end
    cards[WL.CardID.Spy] = WL.CardGameSpy.Create(1000, 0, 0, 0, 999999, true);
    settings.Cards = cards;
end