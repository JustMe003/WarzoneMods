require("UI")
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	
	colorsList = {"Blue", "Light Blue", "Purple", "Dark Green", "Orange", "Red", "Dark Gray", "Green", "Hot Pink", "Brown", "Sea Green", "Orange Red", "Cyan", "Aqua", "Dark Magenta", "Deep Pink", "yellow", "Saddle Brown", "Ivory", "Copper Rose", "Electric Purple", "Tan", "Pink", "Lime", "Tan", "Tyrian Purple", "Smoky Black"};
	
	CardPiecesEachTurn = Mod.Settings.CardPiecesEachTurn;
	CardPiecesFromStart = Mod.Settings.CardPiecesFromStart;
	if CardPiecesEachTurn == nil then CardPiecesEachTurn = {}; end
	if CardPiecesFromStart == nil then CardPiecesFromStart = {}; end
	
	showMain();
end


function showMain()
	local win = "Main";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel("NonIncludedCards", vert, "This mod does not give / take pieces if the card is not enabled!", "Orange Red");
	newButton("AlterSlot", vert, "Alter a slot", chooseSlot, "Tyrian Purple");
	newLabel("slotCardsAtStart", vert, "\n\nSlots that will receive extra / less cards during the game:");
	local needsButton = {};
	for i, v in pairs(CardPiecesFromStart) do
		if v ~= nil and getTableLength(v) > 0 then
			needsButton[i] = true;
		end
	end
	for i, v in pairs(CardPiecesEachTurn) do
		if v ~= nil and getTableLength(v) > 0 and needsButton[i] == nil then
			needsButton[i] = true;
		end
	end
	for i, _ in pairs(needsButton) do
		print(i);
		newButton(win .. "Slot" .. i, vert, "Slot " .. getSlotName(i), function() getConfig(i) end, colorsList[(i % #colorsList) + 1]);
	end
end

function chooseSlot()
	local win = "ChooseSlot";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local input = newTextField("SlotInput", vert, "Input Slot Name", "", 3);
	updateFlexibleWidth(vert, 1);
	updateFlexibleWidth(input, 1);
	updatePreferredWidth(input, 300);
	local submit = newButton("SubmitButton", vert, "Select", function() local slot = getSlotNumberFromName(string.upper(string.gsub(getText(input), "%s", ""))); if slot >= 0 then getConfig(slot); else UI.Alert(getText(input) .. " is not a valid slot name") end; end, "Blue");

end

function getConfig(slot)
	local win = "getConfig" .. slot;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then 
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "Slot", vert, "Slot " .. getSlotName(slot), "Lime")
	newLabel("CardsStart" .. win, vert, "This slot has the following card piece modifications at the start of the game:", "Green");
	local startVert = newVerticalGroup("StartVert", vert);
	newButton(win .. "AddConfigStart", startVert, "Add card config", function() addCardConfig(startVert, "Start") end, "Green");
	if CardPiecesFromStart[slot] == nil then CardPiecesFromStart[slot] = {}; end
	for i, v in pairs(WL.CardID) do
		if objectsID[win .. "StartCardLabel" .. v] ~= nil or getZeroOrValue("Start", slot, v) ~= 0 then
			newLabel(win .. "StartCardLabel" .. v, startVert, readableString(i) .. " card:", "Orange");
			newNumberField(win .. "StartCardInput" .. v, startVert, -10, 10, getZeroOrValue("Start", slot, v));
			newLabel(win .. "StartCardNewline" .. v, startVert, "\n");
		end
	end
	newLabel("CardsEachTurn" .. win, vert, "This slot has the following card piece modifications in every turn:", "Green");
	local turnVert = newVerticalGroup("TurnVert", vert);
	newButton(win .. "AddConfigTurn", turnVert, "Add card config", function() addCardConfig(turnVert, "Turn") end, "Green");
	if CardPiecesEachTurn[slot] == nil then CardPiecesEachTurn[slot] = {}; end
	for i, v in pairs(WL.CardID) do
		if objectsID[win .. "TurnCardLabel" .. v] ~= nil or getZeroOrValue("Turn", slot, v) ~= 0 then
			newLabel(win .. "TurnCardLabel" .. v, turnVert, readableString(i) .. " card:", "Orange");
			newNumberField(win .. "TurnCardInput" .. v, turnVert, 0, 10, getZeroOrValue("Turn", slot, v));
			newLabel(win .. "TurnCardNewline" .. v, turnVert, "\n");
		end
	end
	local line = newHorizontalGroup(win .. "line", vert);
	newButton("return" .. win, line, "Return", function() saveInputs(win, slot); showMain(); end, "Lime");
	newButton(win .. "CopyConfig", line, "Copy configuration", function() saveInputs(win, slot); pickSlotToCopy(slot); end, "Royal Blue");
end

function saveInputs(win, slot)
	for i, v in pairs(WL.CardID) do
		if objectsID[win .. "StartCardInput" .. v] ~= nil and getZeroOrValue("Start", slot, v) then
			CardPiecesFromStart[slot][v] = getValue(win .. "StartCardInput" .. v);
		end
		if objectsID[win .. "TurnCardLabel" .. v] ~= nil or getZeroOrValue("Turn", slot, v) ~= 0 then
			CardPiecesEachTurn[slot][v] = getValue(win .. "TurnCardInput" .. v);
		end
	end
end

function pickSlotToCopy(copy)
	local win = "coptyTo" .. copy;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then 
		resetWindow(win);
	end
	window(win);

	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "CopyToText", vert, "Pick the slot you want to copy the configuration to", "#DDDDDD");
	local line = newHorizontalGroup(win .. "Horz", vert);
	newLabel(win .. "SlotText", line, "Slot", "#DDDDDD");
	slotNameinput = newTextField("SlotInput", vert, "Input Slot Name", "", 3);
	updateFlexibleWidth(vert, 1);
	updateFlexibleWidth(slotNameinput, 1);
	updatePreferredWidth(slotNameinput, 300);
	newButton(win .. "SubmitButton", vert, "Copy", function() local slot = getSlotNumberFromName(string.upper(string.gsub(getText(slotNameinput), "%s", ""))); if slot >= 0 then copySlot(copy, slot); getConfig(slot); else UI.Alert(getText(input) .. " is not a valid slot name") end; end, "Royal Blue");
end

function copySlot(copy, slot)
	CardPiecesFromStart[slot] = {};
	for i, v in pairs(CardPiecesFromStart[copy]) do
		CardPiecesFromStart[slot][i] = v;
	end
	CardPiecesEachTurn[slot] = {};
	for i, v in pairs(CardPiecesEachTurn[copy]) do
		CardPiecesEachTurn[slot][i] = v;
	end
end

function addCardConfig(vert, s)
	local list = {};
	for i, v in pairs(WL.CardID) do
--		if v ~= WL.CardID.Reinforcement then
			local l = {};
			l.text = readableString(i) .. " Card";
			l.selected = function() if objectsID[getCurrentWindow() .. s .. "CardInput" .. v] == nil then 
						newLabel(getCurrentWindow() .. s .. "CardLabel" .. v, vert, readableString(i) .. " card:", "Orange");
						newNumberField(getCurrentWindow() .. s .. "CardInput" .. v, vert, -10, 10, getZeroOrValue("Turn", slot, v));
						newLabel(getCurrentWindow() .. s .. "CardNewline" .. v, vert, "\n");
					else
						UI.Alert("There already is a input for this");
					end
				end;
			table.insert(list, l);
--		end
	end
	UI.PromptFromList("Choose which card you want to alter", list);
end

function getSlotName(i)
	i = i + 1;
	local alpha = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	local s = "";
	while (i ~= 0) do
		local index = i % 26;
		if index == 0 then 
			index = 26;
			s = alpha[index] .. s;
			i = (i - 26) / 26;
		else
			s = alpha[index] .. s;
			i = (i - (i % 26)) / 26;
		end
	end
	return s;
end

function getSlotNumberFromName(s)
	s = string.gsub(s, "%s+", "");
	if #string.gsub(s, "%a+", "") ~= 0 then
		return -1;
	end
	local slot = 0;
	local mult = 1;
	local index = 1;
	local alpha = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	for j = #s, 1, -1 do
		local c = string.sub(s, j, j);
		for i = 1, 26 do
			if c == alpha[i] then
				slot = slot + i * mult;
				break;
			end
		end
		mult = mult * 26;
	end
	return slot - 1;
end

function getZeroOrValue(s, slot, card)
	if objectsID[getCurrentWindow() .. s .. "CardInput" .. card] ~= nil then
		return getValue(getCurrentWindow() .. s .. "CardInput" .. card);
	end
	if s == "Turn" then
		if CardPiecesEachTurn[slot] ~= nil then
			if CardPiecesEachTurn[slot][card] ~= nil then
				return CardPiecesEachTurn[slot][card];
			end
		end
	elseif s == "Start" then
		if CardPiecesFromStart[slot] ~= nil then
			if CardPiecesFromStart[slot][card] ~= nil then
				return CardPiecesFromStart[slot][card];
			end
		end
	end
	return 0;
end

function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
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