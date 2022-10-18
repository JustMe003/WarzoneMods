require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init();
    colors = GetColors();
    Game = game;
    setMaxSize(500, 600);
    SetWindow("ROOT");
    vert = CreateVerticalLayoutGroup(rootParent);
    SetWindow("LKDJOIGH");
    showOrderList();
end

function showOrderList()
    DestroyWindow();
    SetWindow("showOrderList");
    for i, order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderAttackTransfer" then
            if Game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
                CreateButton(vert).SetText("Move " .. order.NumArmies.NumArmies .. " from " .. order.From .. " to " .. order.To).SetColor(colors.OrangeRed).SetOnClick(function() showMoveDetails(order, i); end);
            else
                CreateButton(vert).SetText("Move " .. order.NumArmies.NumArmies .. " from " .. Game.Map.Territories[order.From].Name .. " to " .. Game.Map.Territories[order.To].Name).SetColor(colors.Green);
            end
        elseif order.proxyType == "GameOrderDeploy" then
            CreateButton(vert).SetText("Deploy " .. order.NumArmies .. " on " .. Game.Map.Territories[order.DeployOn].Name).SetColor(colors.Green);
        elseif string.find(order.proxyType, "GameOrderPlayCard") ~= nil then
            CreateButton(vert).SetText("Play a card").SetColor(colors.Green);
        elseif order.proxyType == "GameOrderDiscard" then
            CreateButton(vert).SetText("Discard a card").SetColor(colors.Green);
        elseif order.proxyType == "GameOrderCustom" then
            CreateButton(vert).SetText("Custom order: " .. order.Message).SetColor(colors.Green);
        else
            CreateButton(vert).SetText(order.proxyType).SetColor(colors.Green);
        end
    end
end

function showMoveDetails(order, i)
    DestroyWindow();
    SetWindow("ShowOrderDetails");
    if Game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
        CreateLabel(vert).SetText("This order will not be processed. Any move that makes your armies move from one side to the other side of the map are skipped");
        CreateButton(vert).SetText("Remove order").SetColor(colors.Lime).SetOnClick(function() removeOrder(order, i); end)
    end
    CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showOrderList);
end

function removeOrder(order, i)
    local t = Game.Orders;
    table.remove(t, i);
    Game.Orders = t;
end