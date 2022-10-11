require("UI");
local colors;

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	setMaxSize(500, 400);
	game = Game;
	colors = init();
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText("Mod author: ").SetColor(colors.TextColor);
	UI.CreateLabel(horz).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	showMenu();
end

function showMenu()
	resetAll();
	createButton(vert, "Choose bonus", colors.Blue, pickBonus);
	createButton(vert, "Choose territory", colors.Blue, pickTerritory);
end

function pickTerritory()
	resetAll();
	createLabel(vert, "Pick a territory to show more information of this territory", colors.TextColor);
	UI.InterceptNextTerritoryClick(validateTerritory);
end

function validateTerritory(terrDetails)
	if terrDetails == nil then pickTerritory(); end
	resetAll();
	if territoryIsVisible(terrDetails.ID) then
		createLabel(vert, terrDetails.Name, getPlayerColor(game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID));
		createLabel(vert, "Multiplier: " .. Mod.PublicGameData.WellBeingMultiplier[terrDetails.ID], colors.TextColor);
		createLabel(vert, "Part of bonuses:", colors.TextColor);
		for _, bonusID in ipairs(terrDetails.PartOfBonuses) do
			createButton(vert, game.Map.Bonuses[bonusID].Name .. " (" .. #game.Map.Bonuses[bonusID].Territories .. " territories)", canSeeBonusOwner(game.Map.Bonuses[bonusID].ID), function() validateBonus(game.Map.Bonuses[bonusID]) end)
		end
	else
		createLabel(vert, "You are not able to see the details of this territory because you cannot see who owns it", colors.TextColor);
	end
	createLabel(vert, "\n", colors.TextColor);
	createButton(vert, "Return", colors.Blue, showMenu);
end

function pickBonus()
	resetAll();
	createLabel(vert, "Pick a bonus link to show more information of this territory", colors.TextColor);
	UI.InterceptNextBonusLinkClick(validateBonus);
end

function validateBonus(bonusDetails)
	if bonusDetails == nil then return; end
	resetAll();
	if bonusIsVisible(bonusDetails.ID) then
		createLabel(vert, bonusDetails.Name, getBonusColor(bonusDetails.ID));
		local array = {};
		for _, v in pairs(game.Map.Bonuses[bonusDetails.ID].Territories) do
			table.insert(array, Mod.PublicGameData.WellBeingMultiplier[v])
		end
		createLabel(vert, "This bonus generates " .. round(sum(array) * bonusDetails.Amount) .. " (" .. rounding(sum(array), 2) .. " * " .. bonusDetails.Amount .. ")", colors.TextColor);
		createLabel(vert, "\n", colors.TextColor);
		for _, terrID in pairs(game.Map.Bonuses[bonusDetails.ID].Territories) do
			createButton(vert, game.Map.Territories[terrID].Name .. ": " .. rounding(Mod.PublicGameData.WellBeingMultiplier[terrID], 2), getPlayerColor(game.LatestStanding.Territories[terrID].OwnerPlayerID), function() validateTerritory(game.Map.Territories[terrID]); end);
		end
	else
		createLabel(vert, "You are not able to see the details of this bonus because you cannot see who owns it", colors.TextColor);
	end
	createLabel(vert, "\n", colors.TextColor);
	createButton(vert, "Return", colors.Blue, showMenu);
end

function bonusIsVisible(bonusID)
	for _, terrID in pairs(game.Map.Bonuses[bonusID].Territories) do
		if not territoryIsVisible(terrID) then return false; end
	end
	return true;
end

function territoryIsVisible(terrID)
	if game.LatestStanding.Territories[terrID].FogLevel < 4 then return true; else return false; end
end

function getBonusColor(bonusID)
	colorString = "#";
	for i = 2, 4 do
		colorString = colorString .. numberToHex(tonumber(game.Map.Bonuses[bonusID].Color[i]))
	end
	return colorString;
end

function numberToHex(value)
	lookUpList = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"};
	returnString = "";
	for i = 1, 16 do
		if value - (16 * i) < 0 then
			returnString = returnString .. lookUpList[i];
			value = value - (16 * (i - 1));
			break;
		end
	end
	if value == 0 then
		returnString = returnString .. lookUpList[1];
	else
		for i = 1, 16 do
			if value - i == 0 then
				returnString = returnString .. lookUpList[i+1];
				break;
			end
		end
	end
	return returnString;
end

function getBonusValue(bonusID)
	if game.Settings.OverriddenBonuses[bonusID] ~= nil then
		return game.Settings.OverriddenBonuses[bonusID];
	else
		return game.Map.Bonuses[bonusID].Amount;
	end
end


function round(n)
	if n % 1 < 0.5 then
		return math.floor(n);
	else
		return math.ceil(n);
	end
end

function rounding(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


function sum(t)
	local total = 0;
	local count = 0;
	for _, v in pairs(t) do
		total = total + v;
		count = count + 1;
	end
	return total / count;
end

function canSeeBonusOwner(bonusID)
	if bonusIsVisible(bonusID) then
		return getPlayerColor(game.LatestStanding.Territories[game.Map.Bonuses[bonus].Territories[1]].OwnerPlayerID);
	else
		return colors.TextColor;
	end
end

function getPlayerColor(playerID)
	if playerID ~= WL.PlayerID.Neutral then
		return game.Game.PlayingPlayers[playerID].Color.HtmlColor;
	else
		return colors.TextColor;
	end
end