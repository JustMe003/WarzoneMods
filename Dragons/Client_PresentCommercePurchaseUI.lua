require("UI");
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    local root = UI.CreateVerticalLayoutGroup(rootParent);
    local b = false;
    for _, dragon in pairs(Mod.Settings.Dragons) do
        if dragon.CanBeBought then
            b = true;
            break;
        end
    end
    if b then
        local line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
        UI.CreateLabel(line).SetText("There are (some) dragons that can be purchased")
        UI.CreateEmpty(line).SetFlexibleWidth(1);
        UI.CreateButton(line).SetText("Buy a dragon").SetColor(colors.Orange).SetOnClick(function() close(); game.CreateDialog(createDialog); end)
    end
end

function createDialog(rootParent, setMaxSize, setScrollable, game, close)
    for _, order in pairs(game.Orders) do
        if order.proxyType == "GameOrderCustom" and order.Payload:sub(1, #"Dragons_") == "Dragons_" then
            close();
            UI.Alert("you can only buy 1 dragon each turn");
            return;
        end
    end
    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    Game = game;
    Close = close;

    for _, dragon in pairs(Mod.Settings.Dragons) do
        if dragon.CanBeBought then
            CreateButton(root).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() pickTerritory(dragon); end);
        else
            local line = CreateHorz(root);
            CreateButton(line).SetText(dragon.Name).SetColor(dragon.Color).SetInteractable(false);
            CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon cannot be purchased") end);
        end
    end
end

function pickTerritory(dragon)
    DestroyWindow();
    selected = CreateButton(root).SetText("Pick territory").SetColor(colors.Orange).SetOnClick(function() selectTerr(dragon); end);
    label = CreateLabel(root).SetText("").SetColor(colors.Ivory);
    purchase = CreateButton(root).SetText("Purchase").SetColor(colors.Green).SetOnClick(function() purchaseDragon(dragon); end).SetInteractable(false);
    selectTerr();
end

function selectTerr(dragon)
    UI.InterceptNextTerritoryClick(function(t) terrClicked(t, dragon); end);
    label.SetText("Click the territory you want to receive " .. returnA(dragon) .. "'" .. dragon.Name "' on. If needed you can move this dialog out of the way");
    selected.SetInteractable(false);
end

function terrClicked(terrDetails, dragon)
    selected.SetInteractable(true);
    if terrDetails == nil then
        label.SetText("");
        selectedTerr = nil;
    else
        if Game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID ~= Game.Us.ID then
            label.SetText("You can only receive " .. returnA(dragon) .. "'" .. dragon.Name .. "' on a territory you own. Please try again");
        else
            label.SetText("Selected territory: " .. terrDetails.Name);
            selectedTerr = terrDetails;
            purchase.SetInteractable(true);
        end
    end
end

function purchaseDragon(dragon)
    local orders = Game.Orders;
    local index = 0;
    for i, order in pairs(orders) do
        if order.OccursInPhase ~= nil and order.OccursInPhase > WL.TurnPhase.Deploys then
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders + 1; end
    table.insert(orders, index, WL.GameOrderCustom.Create(Game.Us.ID, "Purchased " .. returnA(dragon); .. "'" .. dragon.Name .. "' on " .. selectedTerr.Name, "BuyWeb_" .. selectedTerr.ID, {[WL.ResourceType.Gold] = dragon.Cost}, WL.TurnPhase.Deploys + 1));
    Game.Orders = orders;
    Close();
end

function returnA(dragon)
    if dragon.IncludeABeforeName then return "a "; end
    return "";
end