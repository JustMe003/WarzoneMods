function Client_SaveConfigureUI(alert)
	Mod.Settings.CardPiecesEachTurn = CardPiecesEachTurn;
	Mod.Settings.CardPiecesFromStart = CardPiecesFromStart;
	for i = 0, 49 do
		if Mod.Settings.CardPiecesFromStart[i] == nil then
			Mod.Settings.CardPiecesFromStart[i] = {};
		end
		for _, j in pairs(WL.CardID) do
			if objectsID["getConfig" .. i .. "StartCardInput" .. j] ~= nil then
				Mod.Settings.CardPiecesFromStart[i][j] = getValue("getConfig" .. i .. "StartCardInput" .. j)
			end
		end
	end
	for i = 0, 49 do
		if Mod.Settings.CardPiecesEachTurn[i] == nil then
			Mod.Settings.CardPiecesEachTurn[i] = {};
		end
		for _, j in pairs(WL.CardID) do
			if objectsID["getConfig" .. i .. "TurnCardInput" .. j] ~= nil then
				if getValue("getConfig" .. i .. "TurnCardInput" .. j) ~= 0 then
					Mod.Settings.CardPiecesEachTurn[i][j] = getValue("getConfig" .. i .. "TurnCardInput" .. j);
				end
			end
		end
	end
end