require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	init(rootParent);
	game = Game;
	
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
	local hasButton = {};
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
	
	newLabel(win .. "explanation1", vert, "(Green numbers are standard Warzone settings, the red numbers are modifications from this mod", "Lime");
	newLabel(win .. "explanation1", vert, p.DisplayName(nil, false) .. " will start with the following card pieces\n", "Lime");
	
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
	
	newLabel(win .. "explanation2", vert, p.DisplayName(nil, false) .. " will receive the following card pieces each turn: \n", "Lime");
	
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
end

function getCardName(c)
	for i, v in pairs(WL.CardID) do
		if v == c then return i; end
	end
	return "ERROR: card not found";
end

function valueInTable(t, v)
	for _, i in pairs(t) do
		if v == i then return true; end
	end
	return false;
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
	local c = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	local s = "";
	if i > 26 then
		s = s .. c[math.floor(i / 26)];
		i = i - math.floor(i / 26);
	end
	return s .. c[i % 26 + 1];
end