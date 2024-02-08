require("UI");
require("Client_PresentSettingsUI")
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    colors = GetColors();
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
        UI.CreateLabel(line).SetText("There are (some) dragons that can be purchased").SetColor(colors.Textcolor);
        UI.CreateEmpty(line).SetFlexibleWidth(1);
        UI.CreateButton(line).SetText("Buy a dragon").SetColor(colors.Orange).SetOnClick(function() close(); game.CreateDialog(createDialog); end);

        UI.CreateEmpty(root).SetPreferredHeight(5);

        UI.CreateLabel(root).SetText("These are the dragons in the game").SetColor(colors.Textcolor);
        for _, dragon in pairs(Mod.Settings.Dragons) do
            local line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
            UI.CreateLabel(line).SetText(dragon.Name).SetColor(dragon.Color);
            UI.CreateEmpty(line).SetFlexibleWidth(1);
            UI.CreateLabel(line).SetText(dragon.Cost .. " gold").SetColor(colors.Yellow).SetPreferredWidth(100);
        end
    else
        UI.CreateLabel(root).SetText("There a no dragons that can be bought").SetColor(colors.Textcolor);
    end

end

function createDialog(rootParent, setMaxSize, setScrollable, game, close)
    Game = game;
    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
    Close = close;

    purchaseMain();
end

function purchaseMain()
    DestroyWindow();
    SetWindow("purchaseMain");

    local dragonsOwned = getOwnedDragons();
    for _, order in pairs(Game.Orders) do
        if order.proxyType == "GameOrderCustom" and order.Payload:sub(1, #"Dragons_") == "Dragons_" then
            local info = split(order.Payload, "_");
            info[2] = tonumber(info[2]);
            dragonsOwned[info[2]] = dragonsOwned[info[2]] + 1;
        end
    end
    
    CreateLabel(root).SetText("Click on a dragon to pick which dragon you want to purchase").SetColor(colors.Textcolor);

    for _, dragon in pairs(Mod.Settings.Dragons) do
        if not dragon.CanBeBought then
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateButton(line).SetText(dragon.Name).SetColor(dragon.Color).SetInteractable(false);
            CreateLabel(line).SetText("   " .. dragon.Cost .. " gold").SetColor(colors.Yellow).SetPreferredWidth(100);
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateButton(line).SetText("Stats").SetColor(colors.Lime).SetOnClick(function() showDragonSettings(dragon, false, purchaseMain); end);
            CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon cannot be purchased") end);
        elseif dragon.MaxNumOfDragon <= dragonsOwned[dragon.ID] then
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateButton(line).SetText(dragon.Name).SetColor(dragon.Color).SetInteractable(false);
            CreateLabel(line).SetText("   " .. dragon.Cost .. " gold").SetColor(colors.Yellow).SetPreferredWidth(100);
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateButton(line).SetText("Stats").SetColor(colors.Lime).SetOnClick(function() showDragonSettings(dragon, false, purchaseMain); end);
            CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("You already have the maximum number of this dragon. Note that also dragon purchase orders are counted") end);
        else
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateButton(line).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() pickTerritory(dragon); end);
            CreateLabel(line).SetText("   " .. dragon.Cost .. " gold").SetColor(colors.Yellow).SetPreferredWidth(100);
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateButton(line).SetText("Stats").SetColor(colors.Lime).SetOnClick(function() showDragonSettings(dragon, false, purchaseMain); end);
        end
    end

end

function pickTerritory(dragon)
    DestroyWindow();
    selected = CreateButton(root).SetText("Pick territory").SetColor(colors.Orange).SetOnClick(function() selectTerr(dragon); end);
    label = CreateLabel(root).SetText("").SetColor(colors.Ivory);
    purchase = CreateButton(root).SetText("Purchase").SetColor(colors.Green).SetOnClick(function() purchaseDragon(dragon); end).SetInteractable(false);
    selectTerr(dragon);
end

function selectTerr(dragon)
    UI.InterceptNextTerritoryClick(function(t) terrClicked(t, dragon); end);
    label.SetText("Click the territory you want to receive " .. returnA(dragon) .. "'" .. dragon.Name .. "' on. If needed you can move this dialog out of the way");
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
    table.insert(orders, index, WL.GameOrderCustom.Create(Game.Us.ID, "Purchase " .. returnA(dragon) .. "'" .. dragon.Name .. "' on " .. selectedTerr.Name, "Dragons_" .. dragon.ID .. "_" .. selectedTerr.ID, {[WL.ResourceType.Gold] = dragon.Cost}, WL.TurnPhase.Deploys + 1));
    Game.Orders = orders;
    Close();
end

function returnA(dragon)
    if dragon.IncludeABeforeName then return "a "; end
    return "";
end

function getOwnedDragons()
    local t = {};
    for _, v in pairs(Mod.Settings.Dragons) do
        t[v.ID] = 0;
    end
    for _, terr in pairs(Game.LatestStanding.Territories) do
        if #terr.NumArmies.SpecialUnits > 0 and Game.Us.ID == terr.OwnerPlayerID then
            for _, sp in pairs(terr.NumArmies.SpecialUnits) do
                if sp.proxyType == "CustomSpecialUnit" and sp.ModID ~= nil and sp.ModID == 594 and Mod.PublicGameData.DragonNamesIDs[sp.Name] ~= nil then
                    if t[Mod.PublicGameData.DragonNamesIDs[sp.Name]] ~= nil then
                        t[Mod.PublicGameData.DragonNamesIDs[sp.Name]] = t[Mod.PublicGameData.DragonNamesIDs[sp.Name]] + 1;
                    else
                        t[Mod.PublicGameData.DragonNamesIDs[sp.Name]] = 1;
                    end
                end
            end
        end
    end
    return t;
end

function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t,cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
 end
