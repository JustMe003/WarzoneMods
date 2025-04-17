require("UI");
require("Util");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init();
	colors = GetColors();
	GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1).SetCenter(true);
	Game = game;

	setMaxSize(400, 500);
	showMenu();
end

function showMenu()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	CreateLabel(root).SetText("The following players have/had a modified card distribution").SetColor(colors.TextColor);
	for _, p in pairs(Game.Game.Players) do
		if p.State ~= WL.GamePlayerState.RemovedByHost and p.State ~= WL.GamePlayerState.Declined and p.Slot ~= nil then
			local line = CreateHorz(root);
			CreateButton(line).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showSlotSettings(p);
			end);
			CreateEmpty(line).SetMinWidth(10);
			CreateLabel(line).SetText(getNumModifications(p.Slot) .. " Modifications").SetColor(colors.TextColor);
		end
	end
end

function showSlotSettings(p)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
	
	CreateEmpty(root).SetPreferredHeight(10);
	
	local line = CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
	CreateLabel(line).SetText("Green").SetColor(colors.Green);
	CreateLabel(line).SetText(": Warzone card distribution").SetColor(colors.TextColor);
	
	line = CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
	CreateLabel(line).SetText("Red").SetColor(colors.OrangeRed);
	CreateLabel(line).SetText(": Additional card distribution").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(10);
	
	CreateLabel(root).SetText("Number of card pieces " .. p.DisplayName(nil, false) .. " started with").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(5);

	for card, cardGame in pairs(Game.Settings.Cards) do
		card = (Mod.PublicGameData.GameToMod or {})[card] or card;
		line = CreateHorz(root);
		CreateLabel(line).SetText(getCardName(cardGame) .. ": ").SetColor(colors.TextColor);
		CreateEmpty(line).SetMinWidth(4);
		CreateLabel(line).SetText(cardGame.InitialPieces).SetColor(colors.Green);
		if Mod.Settings.CardPiecesFromStart[p.Slot][card] ~= nil then
			if Mod.Settings.CardPiecesFromStart[p.Slot][card] < 0 then
				CreateLabel(line).SetText("-").SetColor(colors.TextColor);
			else
				CreateLabel(line).SetText("+").SetColor(colors.TextColor);
			end
			CreateLabel(line).SetText(math.abs(Mod.Settings.CardPiecesFromStart[p.Slot][card])).SetColor(colors.OrangeRed);
		end
	end
	
	CreateEmpty(root).SetPreferredHeight(5);
	
	CreateLabel(root).SetText("The number of card pieces " .. p.DisplayName(nil, false) .. " will receive guaranteed each turn").SetColor(colors.TextColor);	
	for card, cardGame in pairs(Game.Settings.Cards) do
		card = (Mod.PublicGameData.GameToMod or {})[card] or card;
		line = CreateHorz(root);
		CreateLabel(line).SetText(getCardName(cardGame) .. ": ").SetColor(colors.TextColor);
		CreateEmpty(line).SetMinWidth(4);
		CreateLabel(line).SetText(cardGame.MinimumPiecesPerTurn).SetColor(colors.Green);
		if Mod.Settings.CardPiecesEachTurn[p.Slot][card] ~= nil then
			if Mod.Settings.CardPiecesEachTurn[p.Slot][card] < 0 then
				CreateLabel(line).SetText("-").SetColor(colors.TextColor);
			else
				CreateLabel(line).SetText("+").SetColor(colors.TextColor);
			end
			CreateLabel(line).SetText(math.abs(Mod.Settings.CardPiecesEachTurn[p.Slot][card])).SetColor(colors.OrangeRed);
		end
	end
end

function getCardName(cardGame)
	if cardGame.proxyType == "CardGameCustom" then
		return cardGame.Name;
	else
		for name, cardID in pairs(WL.CardID) do
			if cardID == cardGame.ID then
				return name;
			end
		end
	end
end

function getNumModifications(slot)
	local fromStart = Mod.Settings.CardPiecesFromStart[slot] or {};
	local eachTurn = Mod.Settings.CardPiecesEachTurn[slot] or {};
	if tableIsEmpty(fromStart) and tableIsEmpty(eachTurn) then
		return 0;
	end
	local c = 0;
	for cardID, cardGame in pairs(Game.Settings.Cards) do
		if cardGame.proxyType == "CardGameCustom" then
			cardID = Mod.PublicGameData.GameToMod[cardID] or cardID;
		end
		if fromStart[cardID] ~= nil then c = c + 1; end
		if eachTurn[cardID] ~= nil then c = c + 1; end
	end
	return c;
end