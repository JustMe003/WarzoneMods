require("UI");
require("util");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	if Game.Us == nil then UI.Alert("Only players playing this game can use the mod menu"); close(); end
	if Game.Game.TurnNumber ~= 1 then UI.Alert("You can only use this in the first turn (not the distribution turn)"); close(); end
	if Mod.Settings.AutoDistributeUnits then UI.Alert("The link units got auto distributed at the start of the game, you are not allowed to place any yourself"); close(); end
	Init(rootParent);
	colors = GetColors();
	game = Game;
	showMenu();
end

function showMenu()
	DestroyWindow();
	SetWindow("ShowMenu");

	local text = CreateLabel(GetRoot()).SetColor(colors.Tan);
	local addUnit = CreateButton(GetRoot()).SetText("Place unit").SetColor(colors.Blue).SetOnClick(function() DestroyWindow(); SetWindow("ShowInfo"); CreateLabel(GetRoot()).SetText("Click one of your territories to create the order. You can move this dialog out of the way if you need to"); UI.InterceptNextTerritoryClick(validateClick); end);
	CreateEmpty(GetRoot()).SetPreferredHeight(10)
	local text2 = CreateLabel(GetRoot()).SetColor(colors.Tan);
	local count = 0;
	for _, order in pairs(game.Orders) do
		if order.proxyType == "GameOrderCustom" then
			local t = split(order.Payload, "_");
			if t[1] == "ConnTerrs2" then
				count = count + 1;
				CreateButton(GetRoot()).SetText(game.Map.Territories[t[2]].Name).SetColor(colors.Lime).SetOnClick(function() Order = order; removeOrder(t[2]) DestroyWindow(); SetWindow("ShowInfo"); CreateLabel(GetRoot()).SetText("Click one of your territories to create the order. You can move this dialog out of the way if you need to"); UI.InterceptNextTerritoryClick(validateClick); end);
			end
		end
	end
	if count > 0 then text2.SetText("You're gonna deploy link units on:"); end
	CreateLabel(GetRoot()).SetText("You can move or close this window if you want to, but don't forget to deploy all link units!").SetColor(colors.Tan);
	addUnit.SetInteractable(Mod.PublicGameData.NumUnits - count > 0);
	text.SetText("You can place " .. Mod.PublicGameData.NumUnits - count .. " more link units");
end

function validateClick(terrDetails)
	if terrDetails == nil then showMenu(); return; end
	if game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID ~= game.Us.ID then
		UI.Alert("you must pick a territory you control");
		if Order ~= nil then
			local orders = game.Orders;
			table.insert(orders, Order);
			game.Orders = orders;
		end
		showMenu();
		return;
	end
	local orders = game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(game.Us.ID, "Place link unit on " .. terrDetails.Name, "ConnTerrs2_" .. terrDetails.ID));
	game.Orders = orders;
	showMenu();
end

function removeOrder(terrID)
	local orders = game.Orders;
	for i, order in pairs(orders) do
		if order.proxyType == "GameOrderCustom" then 
			local t = split(order.Payload, "_")
			if t[1] == "ConnTerrs2" and t[2] == terrID then
				table.remove(orders, i);
				game.Orders = orders;
				return;
			end
		end
	end
end
