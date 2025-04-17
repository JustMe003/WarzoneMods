require("UI");
require("Util");

function Client_PresentConfigureUI(rootParent)
	Init();

	colors = GetColors();
	GlobalRoot = CreateVert(rootParent).SetCenter(true).SetFlexibleWidth(1);
		
	CardPiecesEachTurn = Mod.Settings.CardPiecesEachTurn;
	CardPiecesFromStart = Mod.Settings.CardPiecesFromStart;
	CustomCards = Mod.Settings.CustomCards;
	ShowAllCardDistributions = Mod.Settings.ShowAllCardDistributions;
	if CardPiecesEachTurn == nil then CardPiecesEachTurn = {}; end
	if CardPiecesFromStart == nil then CardPiecesFromStart = {}; end
	if CustomCards == nil then CustomCards = {}; end
	if ShowAllCardDistributions == nil then ShowAllCardDistributions = false; end
	
	showMain();
end


function showMain()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	saveInputs();

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Alter cards for slot").SetColor(colors.Green).SetOnClick(chooseSlot);
	CreateButton(line).SetText("custom cards").SetColor(colors.Blue).SetOnClick(showCustomCards);

	CreateEmpty(root).SetPreferredHeight(5);
	
	if not tableIsEmpty(CardPiecesEachTurn) or not tableIsEmpty(CardPiecesFromStart) then
		local list = {};
		for slot, _ in pairs(CardPiecesEachTurn) do
			table.insert(list, slot);
		end
		for slot, _ in pairs(CardPiecesFromStart) do
			if not valueInTable(list, slot) then
				table.insert(list, slot);
			end
		end
		
		table.sort(list);

		for _, slot in ipairs(list) do
			line = CreateHorz(root);
			CreateButton(line).SetText(getSlotName(slot)).SetColor(getColorFromList(slot)).SetOnClick(function()
				slotConfig(slot);
			end);
			CreateEmpty(line).SetPreferredWidth(10);
			CreateLabel(line).SetText(getTableLength(CardPiecesFromStart[slot] or {}) + getTableLength(CardPiecesEachTurn[slot] or {}) .. " modifications").SetColor(colors.TextColor);
		end
	else
		CreateLabel(root).SetText("There are currently no configured card distributions. To alter a card distribution for a slot, please click the button above").SetColor(colors.TextColor);
	end
end

function chooseSlot(slot)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	saveInputs();
	local input;

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
		local name = input.GetText();
		if validateSlotName(name) then
			local n = getSlotIndex(name);
			if slot ~= nil then
				copySlot(slot, n);
			end
			slotConfig(n);
		else
			UI.Alert("You must enter only letters (a-z), you should omit the word 'slot'");
		end
	end);

	input = CreateTextInputField(root).SetPlaceholderText("Enter slot name here").SetCharacterLimit(10).SetPreferredWidth(300);
end

function slotConfig(slot)
	saveInputs();
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	inputs = {
		Slot = slot,
		CardPiecesEachTurn = {},
		CardPiecesFromStart = {}
	};
	CardPiecesFromStart[slot] = CardPiecesFromStart[slot] or {};
	CardPiecesEachTurn[slot] = CardPiecesEachTurn[slot] or {};

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateButton(line).SetText("Copy config").SetColor(colors.Blue).SetOnClick(function()
		chooseSlot(slot);
	end);

	CreateEmpty(root).SetPreferredHeight(10);
	
	line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	local checkBox = CreateCheckBox(line).SetText(" ").SetIsChecked(ShowAllCardDistributions);
	CreateLabel(line).SetText("Show all card distributions").SetColor(colors.TextColor);
	checkBox.SetOnValueChanged(function()
		ShowAllCardDistributions = checkBox.GetIsChecked();
		slotConfig(slot);
	end);

	CreateEmpty(root).SetPreferredHeight(10);
	
	CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText(getSlotName(slot) .. " config").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(5);

	local fromStart = CardPiecesFromStart[slot] or {};
	if not tableIsEmpty(fromStart) or ShowAllCardDistributions then
		CreateLabel(root).SetText("This slot has the following card piece modifications at the start of the game").SetColor(colors.TextColor);
		for _, cardID in pairs(getCardList()) do
			if ShowAllCardDistributions or fromStart[cardID] then
				CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText(getCardName(cardID)).SetColor(colors.TextColor);
				line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
				inputs.CardPiecesFromStart[cardID] = CreateNumberInputField(line).SetSliderMinValue(-10).SetSliderMaxValue(10).SetValue(fromStart[cardID] or 0);
				CreateEmpty(line).SetMinWidth(10);
				CreateButton(line).SetText("X").SetColor(colors.Red).SetOnClick(function()
					CardPiecesFromStart[slot][cardID] = nil;
					inputs.CardPiecesFromStart[cardID] = nil;
					slotConfig(slot);
				end);
			end
		end
	else
		CreateLabel(root).SetText("This slot does not have any card distribution modifications at the start of the game").SetColor(colors.TextColor);
	end

	CreateEmpty(root).SetPreferredHeight(5);

	if not ShowAllCardDistributions then
		CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add card distribution").SetColor(colors.Green).SetOnClick(function()
			addCardConfig(slot, CardPiecesFromStart[slot]);
		end);
	end

	CreateEmpty(root).SetPreferredHeight(10);

	local eachTurn = CardPiecesEachTurn[slot] or {};
	if not tableIsEmpty(eachTurn) or ShowAllCardDistributions then
		CreateLabel(root).SetText("This slot has the following card piece modifications at the start of the game").SetColor(colors.TextColor);
		for _, cardID in pairs(getCardList()) do
			if ShowAllCardDistributions or eachTurn[cardID] then
				CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText(getCardName(cardID)).SetColor(colors.TextColor);
				line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
				inputs.CardPiecesEachTurn[cardID] = CreateNumberInputField(line).SetSliderMinValue(-10).SetSliderMaxValue(10).SetValue(eachTurn[cardID] or 0);
				CreateEmpty(line).SetMinWidth(10);
				CreateButton(line).SetText("X").SetColor(colors.Red).SetOnClick(function()
					CardPiecesEachTurn[slot][cardID] = nil;
					inputs.CardPiecesEachTurn[cardID] = nil;
					slotConfig(slot);
				end);
			end
		end
	else
		CreateLabel(root).SetText("This slot does not have any card distribution modifications at the start of the game").SetColor(colors.TextColor);
	end
	
	if not ShowAllCardDistributions then
		CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add card distribution").SetColor(colors.Green).SetOnClick(function()
			addCardConfig(slot, CardPiecesEachTurn[slot]);
		end);
	end
end

function saveInputs()
	if inputs ~= nil then
		local slot = inputs.Slot;

		local fromStart = CardPiecesFromStart[slot] or {}; 
		for cardID, input in pairs(inputs.CardPiecesFromStart) do
			if canReadObject(input) then 
				fromStart[cardID] = input.GetValue();
				if fromStart[cardID] == 0 then fromStart[cardID] = nil; end
			end
		end
		CardPiecesFromStart[slot] = fromStart;
		
		local eachTurn = CardPiecesEachTurn[slot] or {};
		for cardID, input in pairs(inputs.CardPiecesEachTurn) do
			if canReadObject(input) then
				eachTurn[cardID] = input.GetValue();
				if eachTurn[cardID] == 0 then eachTurn[cardID] = nil; end
			end
		end
		CardPiecesEachTurn[slot] = eachTurn;

		-- if tableIsEmpty(CardPiecesFromStart[slot]) and tableIsEmpty(CardPiecesEachTurn[slot]) then
		-- 	CardPiecesEachTurn[slot] = nil;
		-- 	CardPiecesFromStart[slot] = nil;
		-- end
	end
	inputs = nil;
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

function addCardConfig(slot, t)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	saveInputs();

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(function()
		slotConfig(slot);
	end);

	CreateEmpty(root).SetPreferredHeight(10);
	
	CreateLabel(root).SetText("Select a card").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(5);

	for name, cardID in pairs(getCardList()) do
		if t[cardID] == nil then
			CreateButton(root).SetText(readableString(name)).SetColor(getColorFromList(cardID)).SetOnClick(function()
				t[cardID] = 0;
				slotConfig(slot);
			end);
		end
	end
end

function showCustomCards()
	saveInputs();
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateButton(line).SetText("Enter custom card").SetColor(colors.Blue).SetOnClick(showEnterCustomCard);

	CreateEmpty(root).SetPreferredHeight(10);
	
	CreateLabel(root).SetText("This page shows all the custom card names you have entered through the mod. Note that this mod only allows you to alter the normal card distribution and does not add the custom cards themselves").SetColor(colors.TextColor);
	CreateLabel(root).SetText("To alter the card distrubtion of a custom card, enter the name of the card by clicking the button in the top. The mod will use this name to link the card distributions up to the custom card").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(5);

	local vert = CreateVert(root);
	for name, id in pairs(CustomCards) do
		local horz = CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
		CreateButton(horz).SetText(name).SetColor(getColorFromList(id)).SetOnClick(function()
			showEnterCustomCard(name);
		end);
		CreateEmpty(horz).SetMinWidth(20).SetFlexibleWidth(1);
		CreateButton(horz).SetText("X").SetColor(colors.Red).SetOnClick(function()
			UI.Destroy(horz);
			removeCustomCard(name);
		end);
	end
end

function showEnterCustomCard(cardName)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	local textInput = CreateTextInputField(root).SetCharacterLimit(100).SetText(cardName or "").SetPlaceholderText("Enter custom card name here").SetPreferredWidth(300);
	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(showCustomCards);
	CreateButton(line).SetText("Enter custom card").SetColor(colors.Blue).SetOnClick(function()
		local input = textInput.GetText();
		if #input > 0 then
			if not CustomCards[input] then
				if cardName then
					CustomCards[input] = CustomCards[cardName];
					CustomCards[cardName] = nil;
				else
					CustomCards[input] = getNewCustomCardID();
				end
				showCustomCards();
			else
				UI.Alert("\"" .. input .. "\" is already a name, please enter a new name or cancel the action");
			end
		else
			UI.Alert("You must enter a name of the custom card");
		end
	end);
end

function getNewCustomCardID()
	local min = 0;
	for _, id in pairs(CustomCards) do
		min = math.min(min, id);
	end
	return min - 1;
end

function removeCustomCard(name)
	local id = CustomCards[name];
	for i, _ in pairs(CardPiecesFromStart) do
		CardPiecesFromStart[i][id] = nil;
	end
	for i, _ in pairs(CardPiecesEachTurn) do
		CardPiecesEachTurn[i][id] = nil;
	end
	CustomCards[name] = nil;
end

function getCardList()
	local t = {};
	for i, v in pairs(WL.CardID) do
		t[i] = v;
	end
	for i, v in pairs(CustomCards) do
		t[i] = v;
	end
	return t;
end

function getCardName(id)
	for name, cardID in pairs(WL.CardID) do
		if cardID == id then
			return name;
		end
	end
	for name, cardID in pairs(CustomCards) do
		if cardID == id then
			return name;
		end
	end
	return "No name found";
end