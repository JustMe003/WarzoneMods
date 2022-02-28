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
		newButton("showActiveDecoys", vert, "Show your decoys", showDecoys, "Yellow");
		newButton("description", vert, "More information", showDescription, "Gold");
	end
end

function showDecoys()
	local win = "Decoys";
	if windowExists(win) then
		destroyWindow(getCurrentWindow());
		restoreWindow(win);
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "decoys", vert, "Your active decoys", "Lime");
		for i, decoy in pairs(Mod.PublicGameData.ActiveDecoys) do
			if game.LatestStanding.Territories[i].OwnerPlayerID == game.Us.ID then
				newLabel(win .. i .. "name", vert, "territory name: " .. game.Map.Territories[i].Name, "Sea Green");
				newLabel(win .. i .. "armies", vert, "Actual (not visible) armies: " .. decoy.ActualArmies, "Sea Green");
				newLabel(win .. i .. "duration", vert, "Runs out in turn: " .. decoy.MaxDuration, "Sea Green");
			end
		end
	end
end

function showDescription()
	local win = "description";
	if windowExists(win) then
		destroyWindow(getCurrentWindow());
		restoreWindow(win);
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "label1", vert, " - When you play a decoy card, you must own the territory at the end of turn. Otherwise the card cannot get played, just like the blockade card\n \
		- You can specify the amount of armies that will be shown yourself\n \
		- A territory in decoy CAN NOT transfer, attack or airlift\n \
		- You can deploy on a decoyed territory, although the armies will get added on the army count stored by the mod and not on the territory itself\n \
		- The following will reveal that the territory is in decoy:\n \
		  - An attack / transfer TO the decoyed territory\n \
		  - An airlift TO the decoyed territory \n \
		  - A blockade or emergency blockade on a decoyed territory\n \
		  - A gift on a decoyed territory\n \
		- Decoys always get played at the end of a turn, but can be revealed anywhere in the turn whenever a condition above is met", "Royal Blue");
		newButton(win .. "return", vert, "Return", showOptions, "Green");
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
		newLabel("terrDetailsName", vert, "You have chosen " .. terrDetails.Name .. "\nSpecify how many armies will be visible on the territory", "Light Blue")
		local numberOfArmies = newNumberField("numberOfArmies", vert, 0, 100, 20);
		newButton("playCard", vert, "Play Decoy Card", function() playCard(terrDetails, math.max(numberOfArmies, 0)); end, "Lime");
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
	newLabel("suggestorName", line, "DomN8R (The CHEEZINATOR) Demon", "Purple");
end
