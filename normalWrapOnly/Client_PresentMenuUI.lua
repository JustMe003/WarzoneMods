require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init();
    colors = GetColors();
    Game = game;
    vert = CreateVerticalLayoutGroup(rootParent);
    showOrderList();
end

function showOrderList()
    for _, order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderAttackTransfer" then
            if Game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
                CreateButton(vert).SetText("Move " .. order.NumArmies .. " from " .. order.From .. " to " .. order.To).SetColor(colors.OrangeRed);
            else
                CreateButton(vert).SetText("Move " .. order.NumArmies .. " from " .. order.From .. " to " .. order.To).SetColor(colors.Green);
            end
        elseif order.proxyType == "GameOrderDeploy" then
            CreateButton(vert).SetText("Deploy " .. order.NumArmies .. " on " .. Game.Map.Territories[order.DeployOn].Name).SetColor(colors.Green);
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