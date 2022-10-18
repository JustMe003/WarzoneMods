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
    local cnt = 0;
    for i, order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderAttackTransfer"  and Game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
            CreateButton(vert).SetText("Move " .. order.NumArmies.NumArmies .. " from " .. Game.Map.Territories[order.From].Name .. " to " .. Game.Map.Territories[order.To].Name).SetColor(colors.OrangeRed).SetOnClick(function() showMoveDetails(order, i); end);
            cnt = cnt + 1;
        end
    end
    if cnt == 0 then
        CreateLabel(vert).SetText("All orders are valid (for this mod at least)!").SetColor(colors.Lime);
    end
end

function showMoveDetails(order, i)
    DestroyWindow();
    SetWindow("ShowOrderDetails");
    CreateLabel(vert).SetText("This order will not be processed. Any move that makes your armies move from one side to the other side of the map are skipped").SetColor(colors.OrangeRed);
    CreateButton(vert).SetText("Remove order").SetColor(colors.Lime).SetOnClick(function() removeOrder(i); showOrderList() end)
    CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showOrderList);
end

function removeOrder(i)
    local t = {};
    for k, order in pairs(Game.Orders) do
        if i ~= k then
            table.insert(t, order);
        end
    end
    Game.Orders = t;
end