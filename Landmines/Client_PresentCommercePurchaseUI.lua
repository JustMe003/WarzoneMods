require("UI")
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    Init(rootParent);

    Game = game;
    Close = close;
    root = GetRoot();
    colors = GetColors();
    WebOrders = getNumWebOrders(Game.Orders);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("A Web cannot be moved, but will absorb " .. Mod.Settings.DamageAbsorbed .. " once when attacked").SetColor(colors.Textcolor).SetFlexibleWidth(0);
    CreateButton(line).SetText("Purchase Web").SetColor(colors["Dark Green"]).SetOnClick(function() Game.CreateDialog(pickTerr); end).SetPreferredWidth(250).SetFlexibleWidth(0.2);
    CreateLabel(root).SetText("Your next Web will cost " .. Mod.Settings.Cost + ((Mod.PublicGameData.WebsBought[game.Us.ID] + WebOrders) * Mod.Settings.CostIncrease) .. ", after each time you buy a Web the price will go up by " .. Mod.Settings.CostIncrease .. " gold").SetColor(colors.Textcolor)
end

function pickTerr(rootParent, setMaxSize, setScrollable, game, close)
    Close();
    Close = close;

    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);

    selected = CreateButton(root).SetText("Pick territory").SetColor(colors.Orange).SetOnClick(selectTerr);
    label = CreateLabel(root).SetText("").SetColor(colors.Tan);
    purchase = CreateButton(root).SetText("Purchase Web").SetColor(colors.Green).SetOnClick(purchaseLandmine).SetInteractable(false);
    selectTerr();
end

function selectTerr()
    UI.InterceptNextTerritoryClick(terrClicked);
    label.SetText("Click the territory you want to deploy a Web on. If needed you can move this dialog out of the way");
    selected.SetInteractable(false);
end

function terrClicked(terrDetails)
    selected.SetInteractable(true);
    if terrDetails == nil then
        label.SetText("");
        selectedTerr = nil;
    else
        label.SetText("Selected territory: " .. terrDetails.Name);
        selectedTerr = terrDetails;
        purchase.SetInteractable(true);
    end
end

function purchaseLandmine()
    local orders = Game.Orders;
    local index = 0;
    for i, order in pairs(orders) do
        if order.OccursInPhase ~= nil and order.OccursInPhase > WL.TurnPhase.Deploys + 1 then
            index = i + 1;
            break;
        end
    end
    if index == 0 then index = #orders + 1; end
    table.insert(orders, index, WL.GameOrderCustom.Create(Game.Us.ID, "Buy a Web on " .. selectedTerr.Name, "BuyWeb_" .. selectedTerr.ID, {[WL.ResourceType.Gold] = Mod.Settings.Cost + ((Mod.PublicGameData.WebsBought[Game.Us.ID] + WebOrders) * Mod.Settings.CostIncrease)}, WL.TurnPhase.Deploys + 1));
    Game.Orders = orders;
    Close();
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end

function getNumWebOrders(orders)
    local c = 0;
    for _, order in pairs(orders) do
        if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyWeb_") then
            c = c + 1;
        end
    end
    return c;
end