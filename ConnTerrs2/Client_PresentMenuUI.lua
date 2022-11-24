require("UI");
require("util");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	if Game.Us == nil then UI.Alert("Only players playing this game can use the mod menu"); close(); end
	if Game.Game.TurnNumber ~= 1 then UI.Alert("You can only use this in the first turn (not the distribution turn)"); close(); end
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

	local count = 0;
	for _, order in pairs(game.Orders) do
		if order.proxyType == "GameOrderCustom" then
			local t = split(order.Payload, "_");
			if t[1] == "ConnTerrs2" then
				count = count + 1;
				CreateButton(GetRoot()).SetText(game.Map.Territories[t[2]].Name).SetColor(colors.Lime).SetOnClick(function() removeOrder(t[2]) DestroyWindow(); SetWindow("ShowInfo"); CreateLabel(GetRoot()).SetText("Click one of your territories to create the order. You can move this dialog out of the way if you need to"); UI.InterceptNextTerritoryClick(validateClick); end);
			end
		end
	end
	addUnit.SetInteractable(Mod.PublicGameData.NumUnits - count > 0);
	text.SetText("You can place " .. Mod.PublicGameData.NumUnits - count .. " more link units");
end

function validateClick(terrDetails)
	if terrDetails == nil then return; end
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