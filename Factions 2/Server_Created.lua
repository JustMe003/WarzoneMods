function Server_Created(game, settings)
	local c = settings.Cards;
	if c ~= nil then
		c[WL.CardID.Spy] = WL.CardGameSpy.Create(1, 0, 0, 0, 1, false);
		for i, v in pairs(game.Settings.Cards) do
			c[i] = v;
		end
	else
		c = {};
		c[WL.CardID.Spy] = WL.CardGameSpy.Create(1, 0, 0, 0, 1);
	end
	c[WL.CardID.Diplomacy] = WL.CardGameDiplomacy.Create(1, 0, 0, 0, 1);
	settings.Cards = c;
	
	local data = Mod.PublicGameData;
	data.Factions = {};
	Mod.PublicGameData = data;
end