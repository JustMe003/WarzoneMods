require("UI")
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    Init(rootParent);

    Game = game;
    Close = close;
    root = GetRoot();
    colors = GetColors();

    local line = CreateHorz(root);
    CreateLabel(line).SetText("Medics recover " .. Mod.Settings.Percentage .. "% of lost armies on bordering territories if they are stationary. When they are attacking or forced to defend, they cannot recover armies (during that order). Medics are worth " .. Mod.Settings.Health .. " armies and cost " .. Mod.Settings.Cost .. " gold").SetColor(colors.Ivory);
    CreateButton(line).SetText("Purchase Medic").SetColor(colors["Dark Green"]).SetOnClick(buyMedic);
end

function buyMedic()
    local units = 0;
    for _, terr in pairs(Game.LatestStanding.Territories) do
        if terr.OwnerPlayerID == Game.Us.ID then
            units = units + getNMedics(terr);
        end
    end
    for _,order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyMedic_") then
            units = units + 1;
        end
    end
    if units >= Mod.Settings.MaxUnits then
        UI.Alert("You already have the maximum amount of Medics");
        Close();
        return;
    end
    Close();
    Game.CreateDialog(pickTerr)
end

function pickTerr(rootParent, setMaxSize, setScrollable, game, close)
    Close = close;

    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);

    selected = CreateButton(root).SetText("Pick territory").SetColor(colors.Orange).SetOnClick(selectTerr);
    label = CreateLabel(root).SetText("").SetColor(colors.Ivory);
    purchase = CreateButton(root).SetText("Purchase Medic").SetColor(colors.Green).SetOnClick(purchaseMedic).SetInteractable(false);
    selectTerr();
end

function selectTerr()
    UI.InterceptNextTerritoryClick(terrClicked);
    label.SetText("Click the territory you want the Medic to receive on. If needed you can move this dialog out of the way");
    selected.SetInteractable(false);
end

function terrClicked(terrDetails)
    selected.SetInteractable(true);
    if terrDetails == nil then
        label.SetText("");
        selectedTerr = nil;
    else
        if Game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID ~= Game.Us.ID then
            label.SetText("You can only receive a Medic on a territory you own. Please try again");
        else
            label.SetText("Selected territory: " .. terrDetails.Name);
            selectedTerr = terrDetails;
            purchase.SetInteractable(true);
        end
    end
end

function purchaseMedic()
    local orders = Game.Orders;
    table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, "Buy a Medic on " .. selectedTerr.Name, "BuyMedic_" .. selectedTerr.ID, {[WL.ResourceType.Gold] = Mod.Settings.Cost}));
    Game.Orders = orders;
    Close();
end

function getNMedics(terr)
    local ret = 0;
    for _, sp in pairs(terr.NumArmies.SpecialUnits) do
        if sp.Name == "Medic" then
            ret = ret + 1;
        end
    end
    return ret;
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end