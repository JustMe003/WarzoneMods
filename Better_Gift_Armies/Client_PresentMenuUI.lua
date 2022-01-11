require("Utilities");
require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	init()
	colors = initColors();
	Game = game;
	SubmitBtn = nil;
	NumArmiesInput = nil;

	setMaxSize(450, 280);

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Us == nil) then
		createLabel(vert, "You cannot gift armies since you're not in the game", colors.ErrorColor);
		return;
	end
	local row1 = getNewHorz(vert);
	createLabel(row1, "You have ", colors.TextColor);
	createLabel(row1, Mod.PublicGameData.Charges[game.Us.ID], colors.NumberColor);
	createLabel(row1, " charges, enough for ", colors.TextColor);
	createLabel(row1, math.floor(Mod.PublicGameData.Charges[game.Us.ID] / Mod.Settings.ChargeAmountPerGift), colors.NumberColor);
	createLabel(row1, " gifts", colors.TextColor);

	local row2 = getNewHorz(vert);
	createLabel(row2, "Gift armies from this territory: ", colors.TextColor);
	TargetTerritoryBtn = UI.CreateButton(row2).SetText("Select source territory...").SetColor(colors.TextColor).SetOnClick(TargetTerritoryClicked);
	
	
	local row3 = UI.CreateHorizontalLayoutGroup(vert);
	createLabel(row3, "Gift armies to this territory: ", colors.TextColor)
	DestinationTerritoryBtn = UI.CreateButton(row3).SetText("Select destination territory...").SetColor(colors.TextColor).SetOnClick(promptDestinationList);

end

function promptDestinationList()
	local array = getTerritoryNames(filter(Game.LatestStanding.Territories, function(t) return t.OwnerPlayerID ~= Game.Us.ID end))
	local sortedList = sortList(array);
	options = {}
	for _, v in pairs(sortedList) do
		table.insert(options, TerritoryButtonTwo(Game.Map.Territories[array[v]]));
	end
	UI.PromptFromList("Select the territory you'd like to send armies to", options)
end

function TargetTerritoryClicked()
	local array = getTerritoryNames(filter(Game.LatestStanding.Territories, function(t) return t.OwnerPlayerID == Game.Us.ID end))
	local sortedList = sortList(array);
	options = {}
	for _, v in pairs(sortedList) do
		table.insert(options, TerritoryButton(Game.Map.Territories[array[v]]));
	end
	UI.PromptFromList("Select the territory you'd like to take armies from", options);
end

function TerritoryButton(terr)
	local name = Game.Map.Territories[terr.ID].Name;
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function()
		TargetTerritoryBtn.SetText(name).SetColor(getColor(Game.Map.Territories[terr.ID].PartOfBonuses));
		TargetTerritoryID = terr.ID;

		CheckCreateFinalStep();
	end
	return ret;
end

function TerritoryButtonTwo(terr)
	local name = Game.Map.Territories[terr.ID].Name;
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function()
		DestinationTerritoryBtn.SetText(name).SetColor(getColor(Game.Map.Territories[terr.ID].PartOfBonuses));
		DestinationTerritoryID = terr.ID;
	end
	return ret;
end

function CheckCreateFinalStep()
	print(SubmitBtn);
	if (SubmitBtn == nil) then

		local row3 = UI.CreateHorizontalLayoutGroup(vert);
		createLabel(row3, "How many armies would you like to gift: ", colors.TextColor);
		if NumArmiesInput == nil then
			NumArmiesInput = createNumberInputField(row3, 1, 1, 1);
		end

		SubmitBtn = createButton(vert, "Gift", colors.Blue, SubmitClicked);
	end

	local maxArmies = Game.LatestStanding.Territories[TargetTerritoryID].NumArmies.NumArmies;
	NumArmiesInput.SetSliderMaxValue(maxArmies).SetValue(maxArmies);
end

function SubmitClicked()
	local msg = 'Gifting ' .. NumArmiesInput.GetValue() .. ' armies from ' .. Game.Map.Territories[TargetTerritoryID].Name .. ' to ' .. Game.Map.Territories[DestinationTerritoryID].Name;

	local payload = 'BetterGiftArmies_' .. NumArmiesInput.GetValue() .. ',' .. TargetTerritoryID .. ',' .. DestinationTerritoryID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
end

function getColor(array)
	local bonusID = 0;
	local bonusSize = 1000;
	for _, ID in pairs(array) do
		if #Game.Map.Bonuses[ID].Territories < bonusSize then
			bonusID = ID;
			bonusSize = #Game.Map.Bonuses[ID].Territories;
		end
	end
	return getBonusColor(bonusID)
end

function getBonusColor(bonusID)
	colorString = "#";
	for i = 2, 4 do
		colorString = colorString .. numberToHex(tonumber(Game.Map.Bonuses[bonusID].Color[i]))
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


function getTerritoryNames(array)
	newArray = {};
	for i,terr in pairs(array) do
		newArray[Game.Map.Territories[terr.ID].Name] = i;
	end
	return newArray;
end 