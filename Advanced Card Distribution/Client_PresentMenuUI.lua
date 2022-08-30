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
	for i, v in pairs(Mod.Settings.CardPiecesFromStart) do
		if getTableLength(v) > 0 then
			newButton(win .. i .. "button", vert, getPlayerSlot(i), function() showSlotConfig(i); end, getPlayerColor(i));
			table.insert(hasButton, i);
		end
	end
	for i, v in pairs(Mod.Settings.CardPiecesEachTurn) do
		if not valueInTable(hasButton, i)and getTableLength(v) > 0 then
			newButton(win .. i .. "button", vert, getPlayerSlot(i), function() showSlotConfig(i); end, getPlayerColor(i));
		end
	end
end

function showSlotConfig(slot)
	local win = "showSlotConfig";
	if windowExists(win) then
		resetWindow(win);
	end
	destroyWindow(getCurrentWindow());
	window(win)
	local vert = newVerticalGroup("vert", "root");
	
	for card, cardGame in pairs(game.Settings.Cards) do
		local line = newHorizontalGroup(win .. "lineS" .. card);
		newLabel(win .. card .. "cardS", line, readableString(getCardName(card)) .. ": ", "Royal Blue");
		newLabel(win .. card .. "initialPieces", line, cardGame.InitialPieces, "Green");
		if Mod.Settings.CardPiecesFromStart[slot][card] ~= nil then
			newLabel(win .. card .. "S", line, Mod.Settings.CardPiecesFromStart[slot][card], "Orange Red");
		end
	end
end

function getPlayerSlot(slot)
	for _, p in pairs(game.Game.Players) do
		if p.Slot == slot then 
			return p.DisplayName(nil, false);
		end
	end
end

function getPlayerColor(slot)
	for _, p in pairs(game.Game.Players) do
		if p.Slot == slot then
			return p.Color.HtmlColor;
		end
	end
	return "None found";
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

function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end