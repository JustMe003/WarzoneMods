require("UI")
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    Init(rootParent);

    Game = game;
    Close = close;
    root = GetRoot();
    colors = GetColors();
    noSplitCurseOrders = getNNoSplitCurseOrders(Game.Orders);

    local line = CreateHorz(root);
    CreateLabel(line).SetText("Your mage offers you to cast a powerful curse, the No-split Curse...\n\n The cursed territory will not be able to split his armies / special units from eachother. The No-split Curse cost " .. Mod.Settings.Cost + ((Mod.PublicGameData.NoSplitCursesPurchased[Game.Us.ID] + noSplitCurseOrders) * Mod.Settings.Increment) .. " gold, which gets increased by " .. Mod.Settings.Increment .. " per purchase.").SetColor(colors.Ivory);
    CreateButton(line).SetText("Purchase No-split Curse").SetColor(colors["Dark Green"]).SetOnClick(function() Game.CreateDialog(pickTerr); end).SetPreferredWidth(250);
end

function pickTerr(rootParent, setMaxSize, setScrollable, game, close)
    Close();
    Close = close;

    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);

    selected = CreateButton(root).SetText("Pick territory").SetColor(colors.Orange).SetOnClick(selectTerr);
    label = CreateLabel(root).SetText("").SetColor(colors.Ivory);
    purchase = CreateButton(root).SetText("Purchase No-split Curse").SetColor(colors.Green).SetOnClick(purchaseNoSplitCurse).SetInteractable(false);
    selectTerr();
end

function selectTerr()
    UI.InterceptNextTerritoryClick(terrClicked);
    label.SetText("Click the territory you want your mage to cast the spell on. If needed you can move this dialog out of the way");
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

function purchaseNoSplitCurse()
    local orders = Game.Orders;
    table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, "Your mage casts a No-split Curse on " .. selectedTerr.Name, "BuyNo-splitCurse_" .. selectedTerr.ID, {[WL.ResourceType.Gold] = Mod.Settings.Cost + ((Mod.PublicGameData.NoSplitCursesPurchased[Game.Us.ID] + noSplitCurseOrders) * Mod.Settings.Increment)}));
    Game.Orders = orders;
    Close();
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end

function getNNoSplitCurseOrders(orders)
    local c = 0;
    for _, order in pairs(orders) do
        if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyNo-splitCurse_") then
            c = c + 1;
        end
    end
    return c;
end