require("UI");
require("Dialog");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init();
    colors = GetColors();
    Game = game;
    if Game.Us == nil then close(); return; end
    setMaxSize(400, 400);
    Close = close;
    SetWindow("ROOT");
    vert = CreateVerticalLayoutGroup(rootParent);
    SetWindow("LKDJOIGH");
    showOrderList();
end

function showOrderList()
    DestroyWindow();
    SetWindow("showOrderList");
    local cnt = 0;
    CreateLabel(vert).SetText("Note: This is about your orders in turn " .. Game.Game.TurnNumber .. " only! Sometimes the turn has already advanced when this window is opened\n\nThe following orders are 'illegal'. that is, they will be skipped when your orders are processed. With this mod you cannot use connections that go around the map (top / bottom or left / right). Therefore attacks / transfers and will be skipped. Also bomb cards played using a connection that goes around the map will be skipped").SetColor(colors.Tan);
    CreateButton(vert).SetText("Refresh").SetColor(colors.Orange).SetOnClick(function() Close(); Game.CreateDialog(Client_PresentMenuUI); end);
    for i, order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderAttackTransfer"  and Game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
            CreateButton(vert).SetText("attack / transfer " .. order.NumArmies.NumArmies .. " armies from " .. Game.Map.Territories[order.From].Name .. " to " .. Game.Map.Territories[order.To].Name).SetColor(colors.OrangeRed).SetOnClick(function() showMoveDetails(order, i); end);
            cnt = cnt + 1;
        elseif order.proxyType == "GameOrderPlayCardBomb" then
            local b = false;
            for connID, conn in pairs(Game.Map.Territories[order.TargetTerritoryID].ConnectedTo) do
                if conn.Wrap == WL.TerritoryConnectionWrap.Normal and Game.LatestStanding.Territories[connID].OwnerPlayerID == Game.Us.ID then
                    b = true;
                    break;
                end
            end
            if not b then
                CreateButton(vert).SetText("Bomb " .. Game.Map.Territories[order.TargetTerritoryID].Name).SetColor(colors.OrangeRed).SetOnClick(function() showBombDetails(order, i); end);
                cnt = cnt + 1;
            end
        end
    end
    if cnt == 0 then
        if CalledFromRefresh ~= nil then
            Close();
            CalledFromRefresh = nil;
            return;
        end
        CreateLabel(vert).SetText("All orders are valid (for this mod at least)!").SetColor(colors.Lime);
    end
    CreateEmpty(vert).SetPreferredHeight(10);
    CreateButton(vert).SetText("Change notifications settings").SetColor(colors.Blue).SetOnClick(changeNotifications)
end

function showBombDetails(order, i)
    DestroyWindow();
    SetWindow("ShowBombDetails");
    local line = CreateHorz(vert);
    CreateLabel(line).SetText("From: ").SetColor(colors.Ivory);
    CreateButton(line).SetText(Game.Map.Territories[order.TargetTerritoryID].Name).SetColor(colors.Orange).SetOnClick(function() if WL.IsVersionOrHigher("5.21") then Game.CreateLocatorCircle(Game.Map.Territories[order.TargetTerritoryID].MiddlePointX, Game.Map.Territories[order.TargetTerritoryID].MiddlePointY); Game.HighlightTerritories({order.TargetTerritoryID}); end end);
    CreateLabel(vert).SetText("This order will be skipped. Any bomb card that is played at the other side of the map will be skipped").SetColor(colors.OrangeRed);
    CreateButton(vert).SetText("Remove order").SetColor(colors.Lime).SetOnClick(function() removeOrder(i); showOrderList(); end)
    CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showOrderList);
end

function showMoveDetails(order, i)
    if order == nil then UI.Alert("The order does not exists anymore"); return; end
    DestroyWindow();
    SetWindow("ShowOrderDetails");
    local line = CreateHorz(vert);
    CreateLabel(line).SetText("From: ").SetColor(colors.Ivory);
    CreateButton(line).SetText(Game.Map.Territories[order.From].Name).SetColor(colors.Orange).SetOnClick(function() if WL.IsVersionOrHigher("5.21") then Game.CreateLocatorCircle(Game.Map.Territories[order.From].MiddlePointX, Game.Map.Territories[order.From].MiddlePointY); Game.HighlightTerritories({order.From}); end end);
    line = CreateHorz(vert);
    CreateLabel(line).SetText("To: ").SetColor(colors.Ivory);
    CreateButton(line).SetText(Game.Map.Territories[order.To].Name).SetColor(colors.Orange).SetOnClick(function() if WL.IsVersionOrHigher("5.21") then Game.CreateLocatorCircle(Game.Map.Territories[order.To].MiddlePointX, Game.Map.Territories[order.To].MiddlePointY); Game.HighlightTerritories({order.To}) end end);
    CreateLabel(vert).SetText("This order will be skipped. Any move that makes your armies move from one side to the other side of the map are skipped").SetColor(colors.OrangeRed);
    CreateButton(vert).SetText("Remove order").SetColor(colors.Lime).SetOnClick(function() removeOrder(i); showOrderList() end)
    CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showOrderList);
end

function removeOrder(i)
    if Game.Us.HasCommittedOrders then
        UI.Alert("You need to uncommit first!");
        return;
    end
    local t = {};
    for k, order in pairs(Game.Orders) do
        if i ~= k then
            table.insert(t, order);
        end
    end
    Game.Orders = t;
end

function changeNotifications()
    DestroyWindow();
    SetWindow("changeNotifications");
    createYesNoButtons(vert, Game, Close)
end

