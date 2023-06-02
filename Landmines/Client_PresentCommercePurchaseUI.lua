require("UI")
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    Init(rootParent);

    Game = game;
    Close = close;
    root = GetRoot();
    colors = GetColors();

    local line = CreateHorz(root);
    CreateLabel(line).SetText("Landmines are a special type of unit that cannot be moved. When a territory with a landmine gets attacked it will explode, killing " .. Mod.Settings.Damage .. " attackers. A landmine costs " .. Mod.Settings.UnitCost .. ", but note you're only allowed a maximum of " .. Mod.Settings.MaxUnits .. "!").SetColor(colors.TextColor);
    CreateButton(line).SetText("Purchase Landmine").SetColor(colors["Dark Green"]).SetOnClick(buyLandmine).SetPreferredWidth(250);
end

function buyLandmine()
    Close();
    local units = 0;
    for _, terr in pairs(Game.LatestStanding.Territories) do
        if terr.OwnerPlayerID == Game.Us.ID then
            units = units + getNLandmines(terr);
        end
    end
    for _,order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyLandmine_") then
            units = units + 1;
        end
    end
    if units >= Mod.Settings.MaxUnits then
        UI.Alert("You already have the maximum amount of Landmines");
        return;
    end
    Game.CreateDialog(pickTerr)
end

function pickTerr(rootParent, setMaxSize, setScrollable, game, close)
    Close = close;

    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);

    selected = CreateButton(root).SetText("Pick territory").SetColor(colors.Orange).SetOnClick(selectTerr);
    label = CreateLabel(root).SetText("").SetColor(colors.TextColor);
    purchase = CreateButton(root).SetText("Purchase Landmine").SetColor(colors.Green).SetOnClick(purchaseLandmine).SetInteractable(false);
    selectTerr();
end

function selectTerr()
    UI.InterceptNextTerritoryClick(terrClicked);
    label.SetText("Click the territory you want to receive the Landmine on. If needed you can move this dialog out of the way");
    selected.SetInteractable(false);
end

function terrClicked(terrDetails)
    selected.SetInteractable(true);
    if terrDetails == nil then
        label.SetText("");
        selectedTerr = nil;
    else
        if Game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID ~= Game.Us.ID then
            label.SetText("You can only receive a Landmine on a territory you own. Please try again");
        else
            label.SetText("Selected territory: " .. terrDetails.Name);
            selectedTerr = terrDetails;
            purchase.SetInteractable(true);
        end
    end
end

function purchaseLandmine()
    local orders = Game.Orders;
    local index = 0;
    for i, order in pairs(orders) do
        if order.OccursInPhase ~= nil and order.OccursInPhase > WL.TurnPhase.Deploys then
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders + 1; end
    table.insert(orders, index, WL.GameOrderCustom.Create(Game.Us.ID, "Buy a Landmine on " .. selectedTerr.Name, "BuyLandmine_" .. selectedTerr.ID, {[WL.ResourceType.Gold] = Mod.Settings.UnitCost}, WL.TurnPhase.Deploys + 1));
    Game.Orders = orders;
    Close();
end

function getNLandmines(terr)
    local ret = 0;
    for _, sp in pairs(terr.NumArmies.SpecialUnits) do
        if sp.proxyType == "CustomSpecialUnit" and sp.Name == "Landmine" then
            ret = ret + 1;
        end
    end
    return ret;
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end