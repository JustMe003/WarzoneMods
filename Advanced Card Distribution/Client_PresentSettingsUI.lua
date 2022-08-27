require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	
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
	
	newButton(win .. "chooseSlot", vert, "Pick a slot", pickSlot, "Lime");
end

function pickSlot()
	local list = {};
	local hasModifiedSlots = false;
	for i = 0, 49 do
		if Mod.Settings.CardPiecesFromStart[i] ~= nil or Mod.Settings.CardPiecesEachTurn[i] ~= nil then
			hasModifiedSlots = true;
			local t = {};
			t.text = "Slot " .. getSlotName(i);
			t.selected = function() showConfig(i); end
			table.insert(list, t);
		end
	end
	if hasModifiedSlots then
		UI.PromptFromList("Pick a slot", list);
	else
		UI.Alert("It seems like the mod has not been configured.");
	end
end

function showConfig(slot)
	local win = "showConfig";
	if windowExists(win) then
		resetWindow(win);
	end
	destroyWindow(getCurrentWindow());
	window(win);
	local vert = newVerticalGroup("vert", "root");
	
	local hasPiecesFromstart = false;
	for i, v in pairs(WL.CardID) do
		if Mod.Settings.CardPiecesFromStart[slot][v] ~= nil then
			if not hasPiecesFromstart then
				newLabel(win .. "hasPiecesFromstart", vert, "Slot " .. getSlotName(slot) .. " gets the following card modifications at the start of the game:");
				hasPiecesFromstart = true;
			end
			newLabel(win .. v, vert, i .. ": " .. Mod.Settings.CardPiecesFromStart[slot][v]);
		end
	end
	
	local hasPiecesEachTurn = false;
	for i, v in pairs(WL.CardID) do
		if Mod.Settings.CardPiecesEachTurn[slot][v] ~= nil then
			if not hasPiecesEachTurn then
				newLabel(win .. "hasPiecesEachTurn", vert, "Slot " .. getSlotName(slot) .. " gets the following card modifications at the end of every turn:");
				hasPiecesEachTurn = true;
			end
			newLabel(win .. v, vert, i .. ": " .. Mod.Settings.CardPiecesEachTurn[slot][v]);
		end
	end
	
	if not hasPiecesFromstart and not hasPiecesEachTurn then
		newLabel(win .. "Nothing", vert, "This slot does not have any card modification");
	end
	newButton(win .. "chooseSlot", vert, "Pick a slot", pickSlot, "Lime");
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
