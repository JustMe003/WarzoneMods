require("utilities")

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, Close)
	
--[[	if (WL.IsVersionOrHigher == nil or not WL.IsVersionOrHigher("5.17")) then
		UI.Alert("You must update your app to the latest version to use this mod");
		return;
	end]]--

	UI.Alert("If this window crashes the mod, than this has to do with running a Warzone version lower than '5.17'. Please update your app if you can to use the mod accordingly");
	
	game = Game;
	orders = game.Orders;
	close = Close;
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	setMaxSize(400, 500);
	
	print(_VERSION);
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Mod author: ").SetColor("#CCCCCC");
	UI.CreateLabel(row1).SetText("Just_A_Dutchman_").SetColor("#00FF00");
	UI.CreateEmpty(vert).SetPreferredHeight(20);
	
	if game.Game.TurnNumber < 1 then return; end
	if game.Us == nil then return; end
	button = UI.CreateButton(vert).SetText("Click here to add your picks to your orderlist").SetColor("#0000FF").SetOnClick(addOrdersToList);
	UI.CreateLabel(vert).SetText("Every territory you click / tap will end up here below").SetColor("#FF8C00");
	if playerShouldPick(game.Us.ID) then
		print(Mod.PublicGameData.numberOfGroups)
		if Mod.PublicGameData.numberOfGroups > 1 then
			minimumPicks = #Mod.PublicGameData.Groups[getGroup(game.Game.TurnNumber, Mod.PublicGameData.numberOfGroups)];
		else
			minimumPicks = #game.Game.PlayingPlayers;
			print(minimumPicks);
		end
		updateLabel = UI.CreateLabel(vert).SetText("In this turn you are able to pick more territories! You should pick at least " .. minimumPicks .. " more to make sure you don't end up with random territories!").SetColor("#AA0000");
	end
	labels = {UI.CreateLabel(vert).SetText("You have picked").SetColor("#C0C0C0")};
	
	showPicks();
end

function showPicks()
	UI.InterceptNextTerritoryClick(territoryClicked);
end

function territoryClicked(terrDetails)
	if button == nil then return; end
	if terrDetails == nil then return; end
	if alreadyHasOrder("ExtendDistributionPhase_pick_" .. terrDetails.ID) then showPicks(); return; end
	local pick = WL.GameOrderCustom.Create(game.Us.ID, "attempt to pick " .. terrDetails.Name, "ExtendDistributionPhase_pick_" .. terrDetails.ID, {})
	table.insert(orders, pick)
	table.insert(labels, UI.CreateLabel(vert).SetText(terrDetails.Name).SetColor(getColor(game.Map.Territories[terrDetails.ID].PartOfBonuses)));
	if updateLabel ~= nil then
		minimumPicks = math.max(minimumPicks - 1, 0)
		updateLabel.SetText("In this turn you are able to pick more territories! You should pick at least " .. minimumPicks .. " more to make sure you don't end up with random territories!");
	end
	showPicks();
end

function addOrdersToList()
	game.Orders = orders
	for _,v in pairs(labels) do UI.Destroy(v); end
	UI.Destroy(button);
	button = nil;
	close();
end

function alreadyHasOrder(payload)
	for _, order in pairs(orders) do
		if order.proxyType == "GameOrderCustom" then
			if order.Payload == payload then return true; end
		end
	end
	return false;
end


function playerShouldPick(PlayerID)
	if Mod.PublicGameData.numberOfGroups == 1 then return true; end
	return valueInTable(Mod.PublicGameData.Groups[getGroup(game.Game.TurnNumber, Mod.PublicGameData.numberOfGroups)], PlayerID);
end