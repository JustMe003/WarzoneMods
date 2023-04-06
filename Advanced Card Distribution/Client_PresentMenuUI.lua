require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	init(rootParent);
	game = Game;

	setMaxSize(400, 500);
	showMenu();
end

function showMenu()
	local win = "showMenu";
	if windowExists(win) then
		resetWindow(win);
	end
	destroyWindow(getCurrentWindow());
	window(win)
	local vert = newVerticalGroup("vert", "root");
	
	newLabel(win .. "label", vert, "These players have a modified card distribution");
	for _, p in pairs(game.Game.Players) do
		if p.State ~= WL.GamePlayerState.RemovedByHost and p.State ~= WL.GamePlayerState.Declined and p.Slot ~= nil then
			newButton(win .. p.ID .. "button", vert, p.DisplayName(nil, false) .. " (Slot " .. getSlotName(p.Slot) .. ")", function() showSlotSettings(p); end, p.Color.HtmlColor);
		end
	end
end

function showSlotSettings(p)
	local win = "showSlotSettings";
	if windowExists(win) then
		resetWindow(win);
	end
	destroyWindow(getCurrentWindow());
	window(win)
	local vert = newVerticalGroup("vert", "root");
	
	local line = newHorizontalGroup("line112345", vert);
	newLabel(win .. "explanation1a", line, "Green", "Green");
	newLabel(win .. "explanation1b", line, ": Warzone card settings");
	line = newHorizontalGroup("line112345543", vert);
	newLabel(win .. "explanation1c", line, "Red", "Orange Red");
	newLabel(win .. "explanation1d", line, ": Modifications from this mod");
	newLabel(win .. "explanation1", vert, "\n" .. p.DisplayName(nil, false) .. " will start with the following card pieces\n");
	
	for card, cardGame in pairs(game.Settings.Cards) do
		local line = newHorizontalGroup(win .. "lineS" .. card, vert);
		newLabel(win .. card .. "cardS", line, readableString(getCardName(card)) .. ": ", "Royal Blue");
		newLabel(win .. card .. "initialPieces", line, cardGame.InitialPieces, "Green");
		if Mod.Settings.CardPiecesFromStart[p.Slot][card] ~= nil then
			if Mod.Settings.CardPiecesFromStart[p.Slot][card] > 0 then
				newLabel(win .. card .. "equation", line, "+ ", "Royal Blue");
			end
			newLabel(win .. card .. "S", line, Mod.Settings.CardPiecesFromStart[p.Slot][card], "Orange Red");
		end
	end
	
	newLabel(win .. "explanation2", vert, "\n" .. p.DisplayName(nil, false) .. " will receive the following card pieces each turn: \n");
	
	for card, cardGame in pairs(game.Settings.Cards) do
		local line = newHorizontalGroup(win .. "lineT" .. card, vert);
		newLabel(win .. card .. "cardT", line, readableString(getCardName(card)) .. ": ", "Royal Blue");
		newLabel(win .. card .. "MinimumPiecesPerTurn", line, cardGame.MinimumPiecesPerTurn, "Green");
		if Mod.Settings.CardPiecesEachTurn[p.Slot][card] ~= nil then
			if Mod.Settings.CardPiecesEachTurn[p.Slot][card] > 0 then
				newLabel(win .. card .. "equation", line, "+ ", "Royal Blue");
			end
			newLabel(win .. card .. "T", line, Mod.Settings.CardPiecesEachTurn[p.Slot][card], "Orange Red");
		end
	end
	
	newButton(win .. "retruN", vert, "Return", showMenu, "Orange");
end

function getCardName(c)
	for i, v in pairs(WL.CardID) do
		if v == c then return i; end
	end
	return "ERROR: card not found";
end

function readableString(s)
	local ret = string.upper(string.sub(s, 1, 1));
	for i = 2, #s do
		if string.sub(s, i, i) == string.lower(string.sub(s, i, i)) then
			ret = ret .. string.sub(s, i, i);
		else
			ret = ret .. " " .. string.lower(string.sub(s, i, i));
		end
	end
	return ret;
end

function getSlotName(i)
	i = i + 1;
	local c = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	local s = "";
	if i > 26 then
		s = s .. c[math.floor(i / 26)];
		i = (i % 26);
	end
	return s .. c[i];
end
