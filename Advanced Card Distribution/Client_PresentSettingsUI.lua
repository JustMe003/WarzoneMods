require("UI");
require("Util");

function Client_PresentSettingsUI(rootParent)
	Init();
	colors = GetColors();
	GlobalRoot = CreateVert(rootParent).SetCenter(true).SetFlexibleWidth(1);


	modifiedSlots = {};
	for i, t in pairs(Mod.Settings.CardPiecesFromStart) do
		if not tableIsEmpty(t) then
			modifiedSlots[i] = {
				CardPiecesFromStart = t
			};
		end
	end
	for i, t in pairs(Mod.Settings.CardPiecesEachTurn) do
		if not tableIsEmpty(t) then
			modifiedSlots[i] = modifiedSlots[i] or {};
			modifiedSlots[i].CardPiecesEachTurn = t;
		end
	end
	
	local line = CreateHorz(GlobalRoot).SetCenter(true);
	CreateButton(line).SetText("Show one").SetColor(colors.Orange).SetOnClick(showMenu);
	CreateButton(line).SetText("Show all").SetColor(colors.RoyalBlue).SetOnClick(showFullSettings);
	CreateButton(line).SetText("Custom cards").SetColor(colors.Yellow).SetOnClick(showCustomCards);
	showMenu();
end

function showFullSettings()
	DestroyWindow()
	root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true).SetFlexibleWidth(1);
	for i, t in pairs(modifiedSlots) do
		showConfig(i, t, true);
	end
end

function showMenu()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true).SetFlexibleWidth(1);

	CreateLabel(root).SetText("Select a slot below").SetColor(colors.TextColor);
	for slot, dist in pairs(modifiedSlots) do
		local line = CreateHorz(root);
		CreateButton(line).SetText(getSlotName(slot)).SetColor(getColorFromList(slot)).SetOnClick(function()
			showConfig(slot, dist);
		end);
		CreateEmpty(line).SetPreferredWidth(10);
		CreateLabel(line).SetText(getTableLength(dist.CardPiecesFromStart or {}) + getTableLength(dist.CardPiecesEachTurn or {}) .. " modifications").SetColor(colors.TextColor);
	end
end

function showConfig(slot, dist, showAll)
	if not showAll then
		DestroyWindow();
		root = CreateWindow(CreateVert(GlobalRoot));
	end

	CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText(getSlotName(slot) .. " card distribution").SetColor(colors.Tan);

	CreateEmpty(root).SetPreferredHeight(5);
	if dist.CardPiecesFromStart then
		CreateLabel(root).SetText("This slot has the following altered card distribution at the start of the game").SetColor(colors.TextColor);
		local fromStart = dist.CardPiecesFromStart;
		local list = {};
		for cardID, _ in pairs(dist.CardPiecesFromStart) do
			table.insert(list, cardID);
		end
		table.sort(list);

		local vert = CreateVert(root).SetCenter(true);
		for _, cardID in ipairs(list) do
			local line = CreateHorz(vert).SetFlexibleWidth(1).SetCenter(true);
			CreateLabel(line).SetText(getCardName(cardID) .. ": ").SetColor(colors.TextColor).SetAlignment(WL.TextAlignmentOptions.Right).SetFlexibleWidth(1);
			CreateLabel(line).SetText(fromStart[cardID]).SetColor(getPosNegColor(fromStart[cardID]));
		end
		CreateEmpty(root).SetPreferredHeight(5);
	else
		CreateLabel(root).SetText("This slot does not have any altered card distributions at the start of the game").SetColor(colors.TextColor);
	end
	
	if dist.CardPiecesEachTurn then
		CreateLabel(root).SetText("This slot has the following altered card distribution for each turn in the game").SetColor(colors.TextColor);
		local fromStart = dist.CardPiecesEachTurn;
		local list = {};
		for cardID, _ in pairs(dist.CardPiecesEachTurn) do
			table.insert(list, cardID);
		end
		table.sort(list);

		local vert = CreateVert(root).SetCenter(true);
		for _, cardID in ipairs(list) do
			local line = CreateHorz(vert).SetFlexibleWidth(1).SetCenter(true);
			CreateLabel(line).SetText(getCardName(cardID) .. ": ").SetColor(colors.TextColor).SetAlignment(WL.TextAlignmentOptions.Right).SetFlexibleWidth(1);
			CreateLabel(line).SetText(fromStart[cardID]).SetColor(getPosNegColor(fromStart[cardID]));
		end
		CreateEmpty(root).SetPreferredHeight(5);
	else
		CreateLabel(root).SetText("This slot does not have any altered card distributions for each turn in the game").SetColor(colors.TextColor);
	end
end

function showCustomCards()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true);

	local cards = Mod.Settings.CustomCards or {};
	if not tableIsEmpty(cards) then
		CreateLabel(root).SetText("The following custom cards were entered into this mod. Please note that this does not necessarily mean that the cards are in the game, nor that this mod adds these cards to the game. When a card is listed below, the only meaning it has is that a slot can have an altered card distribution for this type of card").SetColor(colors.TextColor);
		for name, id in pairs(cards) do
			CreateButton(root).SetText(name).SetColor(getColorFromList(id));
		end
	else
		CreateLabel(root).SetText("There are no custom cards entered into this mod. Please note that this does not mean that there are no custom cards, only that none of the distributions of the custom cards will be altered through this mod").SetColor(colors.TextColor);
	end
end

function getCardName(id)
	for name, cardID in pairs(WL.CardID) do
		if cardID == id then
			return name;
		end
	end
	for name, cardID in pairs(Mod.Settings.CustomCards or {}) do
		if cardID == id then
			return name;
		end
	end
	return "No name found";
end