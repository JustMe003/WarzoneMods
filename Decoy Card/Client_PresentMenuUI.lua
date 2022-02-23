require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	if Game.Us == nil then return; end
	init(rootParent);
	game = Game;
	Close = close;
	
	showOptions();
end

function showOptions();
	local win = "main";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("AmountOfCards", "you've got " .. getAmountOfAvailableCards() .. " cards, and " .. game.Game.TurnNumber % Mod.Settings.CardPieces .. " pieces")
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showCreators(vert)
		newLabel("AmountOfCards", vert, "you've got " .. getAmountOfAvailableCards() .. " cards, and " .. game.Game.TurnNumber % Mod.Settings.CardPieces .. " pieces", "Hot Pink");
		updatePreferredHeight("AmountOfCards", 50);
		newButton("playDecoy", vert, "Decoy Card", chooseTerritory, "Orange", getAmountOfAvailableCards() > 0);
	end
end

function chooseTerritory()
	local win = "chooseTerritory";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "label", vert, "Choose a territory by clicking / tapping it", "Royal Blue")
	end
	UI.InterceptNextTerritoryClick(createCard);
end

function createCard(terrDetails)
	if terrDetails == nil then chooseTerritory(); end
	if game.Us.ID ~= game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID then UI.Alert("You must pick a territory you control"); chooseTerritory(); return; end
	local win = "createCard" .. terrDetails.ID;
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel("terrDetailsName", vert, "You have chosen" .. terrDetails.Name .. "\nSpecify how many armies will be visible on the territory", "Orchid")
		local numberOfArmies = newNumberField("numberOfArmies", vert, 1, 100, 20);
		newButton("playCard", vert, "Play Decoy Card", function() playCard(terrDetails, numberOfArmies); end, "Lime");
	end
end

function playCard(terrDetails, numArmiesInput)
	local orders = game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(game.Us.ID, "Play decoy card on " .. terrDetails.Name .. " and display " .. getValue(numArmiesInput) .. " armies", "playDecoy_" .. terrDetails.ID .. "_" .. getValue(numArmiesInput)))
	game.Orders = orders;
	if getAmountOfAvailableCards() > 0 then
		showOptions();
	else
		Close();
	end
end

function getAmountOfAvailableCards()
	amountOfCards = math.floor((game.Game.TurnNumber + Mod.Settings.StartAmount - 1)/ Mod.Settings.CardPieces) - Mod.PublicGameData.DecoysPlayed[game.Us.ID];
	for _, order in pairs(game.Orders) do
		if order.proxyType == "GameOrderCustom" then
			if string.find(order.Payload, "playDecoy_") ~= nil then
				amountOfCards = amountOfCards - 1;
			end
		end
	end
	return amountOfCards;
end

function showCreators(vert)
	local line = newHorizontalGroup("CreatorLine", vert);
	newLabel("mod author: ", line, "Mod author: ", "#DDDDDD");
	newLabel("creatorName", line, "Just_A_Dutchman_", "Lime");
	local line = newHorizontalGroup("IdeaLine", vert);
	newLabel("Suggestedby", line, "Suggested by: ", "#DDDDDD");
	newLabel("suggestorName", line, "DomN8R (The CHEEZINATOR) Demon", "Blue");
end
