require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);

	colorsList = {"Blue", "Light Blue", "Purple", "Dark Green", "Orange", "Red", "Dark Gray", "Green", "Hot Pink", "Brown", "Sea Green", "Orange Red", "Cyan", "Aqua", "Dark Magenta", "Deep Pink", "yellow", "Saddle Brown", "Ivory", "Copper Rose", "Electric Purple", "Tan", "Pink", "Lime", "Tan", "Tyrian Purple", "Smoky Black"};
	pageNumber = 1;
	modifiedSlots = {};
	for i = 0, 49 do
		if getTableLength(Mod.Settings.CardPiecesFromStart[i]) > 0 or getTableLength(Mod.Settings.CardPiecesEachTurn[i]) > 0 then
			table.insert(modifiedSlots, i);
		end
	end

	showMenu();
end

function showMenu()
	local win = "showMenu";
	if windowExists(win) then
		resetWindow(win);
	end
	destroyWindow(getCurrentWindow());
	window(win);
	local vert = newVerticalGroup("vert", "root");
	for i = pageNumber * 10 + 1, (pageNumber + 1) * 10 do
		newButton(win .. i, vert, getSlotName(i), function() getConfig(i); end, colors[i]);
	end
	if #modifiedSlots > 10 then
		local line = newHorizontalGroup("line", vert);
		newButton(win .. "Previous", line, "Previous", function() pageNumber = pageNumber - 1; if pageNumber < 0 then pageNumber = #modifiedSlots; end showMenu(); end, "Royal Blue");
		print(Math);
		newLabel(win .. "PageNumber", line, pageNumber .. " / " .. Math.ceil(#modifiedSlots / 10), "Royal Blue");
		newButton(win .. "Next", line, "Next", function() pageNumber = pageNumber + 1; if pageNumber > #modifiedSlots then pageNumber = 1; end showMenu(); end, "Royal Blue");
	end
end

function showConfig(slot)
	local win = "showConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	
	local hasPiecesFromstart = false;
	for i, v in pairs(WL.CardID) do
		if Mod.Settings.CardPiecesFromStart[slot][v] ~= nil then
			if not hasPiecesFromstart then
				newLabel(win .. "hasPiecesFromstart", vert, "Slot " .. getSlotName(slot) .. " gets the following card modifications at the start of the game:\n", "Orange");
				hasPiecesFromstart = true;
			end
			newLabel(win .. v, vert, i .. ": " .. Mod.Settings.CardPiecesFromStart[slot][v], "Royal Blue");
		end
	end
	
	local hasPiecesEachTurn = false;
	for i, v in pairs(WL.CardID) do
		if Mod.Settings.CardPiecesEachTurn[slot][v] ~= nil then
			if not hasPiecesEachTurn then
				newLabel(win .. "hasPiecesEachTurn", vert, "\nSlot " .. getSlotName(slot) .. " gets the following card modifications at the end of every turn:\n", "Orange");
				hasPiecesEachTurn = true;
			end
			newLabel(win .. v, vert, i .. ": " .. Mod.Settings.CardPiecesEachTurn[slot][v], "Royal Blue");
		end
	end
	
	if not hasPiecesFromstart and not hasPiecesEachTurn then
		newLabel(win .. "Nothing", vert, "This slot does not have any card modification");
	end
	newButton(win .. "chooseSlot", vert, "Pick a slot", function() destroyWindow(getCurrentWindow()); pickSlot(); end, "Lime");
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

function getTableLength(t)
	local c = 0;
	for _, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end
