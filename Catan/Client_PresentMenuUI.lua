require("Catan");
require("UI");
require("Annotations");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    if game.Game.TurnNumber < 1 then
        close();
        UI.Alert("You can only open the menu when the distribution has ended");
    end
    if game.Us == nil then
        close();
        UI.Alert("Spectators are not allowed to view the menu");
    end

    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    Game = game;
    territories = game.LatestStanding.Territories;
    CancelClickIntercept = true;
    
    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");
    Resources = copyTable(Mod.PlayerGameData.Resources)

    local resources = Mod.PlayerGameData.Resources;

    CreateButton(root).SetText("Build village").SetColor(colors.Blue).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.Village), resources)).SetOnClick(function() selectTerritory(addBuildVillageOrder); end);
    CreateButton(root).SetText("Upgrade village").SetColor(colors.Green).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.UpgradeVillage), resources)).SetOnClick(function() selectTerritory(upgradeVillage); end);
    CreateButton(root).SetText("Purchase warrior").SetColor(colors.Yellow).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.Warrior), resources)).SetOnClick(function() selectTerritory(purchaseWarrior) end)
    CreateButton(root).SetText("Build warrior camp").SetColor(colors.Cyan).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.WarriorCamp), resources)).SetOnClick(function() selectTerritory(buildWarriorCamp) end)

    CreateEmpty(root).SetPreferredHeight(10);

    CreateButton(root).SetText("Show orders").SetColor(colors.Orange).SetOnClick(showOrders)
end

function showOrders()
    DestroyWindow()
    SetWindow("showOrders");

    local orderTypes = {};
    for _, type in pairs(Catan.OrderType) do
        orderTypes[type] = {};
    end

    for _, order in ipairs(Mod.PlayerGameData.OrderList) do
        table.insert(orderTypes[order.OrderType], order);
    end

    CreateButton(root).SetText("Build village orders: " .. #orderTypes.BuildVillage).SetColor(colors.Blue).SetOnClick(function() viewBuildVillageOrders(orderTypes.BuildVillage); end);

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain)
end

function viewBuildVillageOrders(orders)
    DestroyWindow()
    SetWindow("showBuildVillageOrders");

    local deleteMode = false;
    local deleteButtons = {};
    local deleteOrders = {};
    local deleteSelectedButton;

    local line = CreateHorz(root);
    local modeBox = CreateCheckBox(line).SetText(" ").SetIsChecked(false);
    local modeLabel = CreateLabel(line).SetText("Toggle to deletion mode").SetColor(colors.TextColor);
    modeBox.SetOnValueChanged(function()  
        if modeBox.GetIsChecked() then
            modeLabel.SetText("Toggle to view mode");
            deleteMode = true;
        else
            modeLabel.SetText("Toggle to deletion mode");
            deleteMode = false;
        end
        deleteSelectedButton.SetInteractable(deleteMode);
        for _, but in ipairs(deleteButtons) do
            but.SetInteractable(deleteMode);
        end
    end)

    CreateLabel(root).SetText("You will be building villages on the following territories").SetColor(colors.TextColor);
    for i, order in ipairs(orders) do
        local details = Game.Map.Territories[order.TerritoryID];
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateButton(line).SetText(details.Name).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY); 
            Game.HighlightTerritories({details.ID});
        end);
        local delBut = CreateButton(line).SetText("X").SetColor(colors.Yellow).SetInteractable(deleteMode)
        delBut.SetOnClick(function()  
            if delBut.GetColor() == colors.Yellow then
                -- Selected for deletion
                delBut.SetColor(colors["Orange Red"]);
                table.insert(deleteOrders, i);
                increaseGain(order.Cost);
                showGainRemoveVillage(order.TerritoryID, true);
            else
                -- Unselected for deletion
                delBut.SetColor(colors.Yellow);
                decreaseGain(order.Cost);
                showGainUnremoveVillage(order.TerritoryID, true);
                local index = 0;
                for k, v in ipairs(deleteOrders) do
                    if v == i then
                        index = k;
                        break;
                    end
                end
                if index ~= 0 then
                    table.remove(deleteOrders, index);
                end
            end
        end);
        table.insert(deleteButtons, delBut);
    end

    CreateEmpty(root).SetPreferredHeight(5);

    local line = CreateHorz(root);
    CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(function() 
        resetAllResourceLabels();
        showOrders(); 
    end);
    deleteSelectedButton = CreateButton(line).SetText("Delete").SetColor(colors.Red).SetInteractable(deleteMode).SetOnClick(function()  
        if #deleteOrders > 0 then
            deleteOrders = table.sort(deleteOrders, function(v, v2) return v > v2; end);
            local t = {};
            for _, k in ipairs(deleteOrders) do
                table.insert(t, orders[k]);
            end
            resetAllResourceLabels();
            getAndDeleteOrders(t);
        end
    end)
end

function getAndDeleteOrders(orders)
    local t = {};
    for _, order in ipairs(orders) do
        local type = order.OrderType;
        for k, o in ipairs(Mod.PlayerGameData.OrderList) do
            if o.OrderType == type and compareTables(order, o) then
                table.insert(t, k);
                break;
            end
        end
    end
    if #orders ~= #t then
        UI.Alert("Not all orders were deleted successfully");
    end
    if #t > 0 then
        Game.SendGameCustomMessage("Deleting orders...", {Command = "DeleteOrders", OrderIndexes = t}, serverCallback);
    end
end

function showBuildVillageOrders(terrDetails)
    DestroyWindow()
    SetWindow("showBuildVillageOrders");

    selectTerritoryWithAlerts(addBuildVillageOrder);
    local recipe = getRecipe(Catan.Recipes.Village);

    BuildVillageOrderList = BuildVillageOrderList or {};
    if terrDetails then
        table.insert(BuildVillageOrderList, terrDetails);
        removeLocalResources(recipe);
        addToGainScore(terrDetails.ID, true);
    end

    
    CreateLabel(root).SetText("Currently you're trying to build villages on the following territories:").SetColor(colors.TextColor);
    for i, details in ipairs(BuildVillageOrderList) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getStringForButton(details.Name)).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY); 
            Game.HighlightTerritories({details.ID}); 
        end);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("X").SetColor(colors["Orange Red"]).SetOnClick(function() 
            table.remove(BuildVillageOrderList, i); 
            addLocalResources(recipe, true);
            removeFromGainScore(details.ID, true);
            showBuildVillageOrders(); 
        end);
    end

    CreateEmpty(root).SetPreferredHeight(10);

    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Build").SetColor(colors.Green).SetOnClick(function() 
        CancelClickIntercept = true; 
        Game.SendGameCustomMessage("Building villages...", {Command = "BuildMultipleVillages", TerritoryIDs = getTerritoryIDs(BuildVillageOrderList)}, serverCallback); 
        BuildVillageOrderList = nil;
        resetAllResourceLabels();
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() 
        CancelClickIntercept = true; 
        BuildVillageOrderList = nil; 
        resetAllResourceLabels();
        showMain(); 
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function addBuildVillageOrder(terrDetails)
    if CancelClickIntercept or terrDetails == nil or UI.IsDestroyed(root) then return WL.CancelClickIntercept; end
    
    local terr = territories[terrDetails.ID];
    local f;
    if BuildVillageOrderList == nil then
        f = selectTerritory;
    else
        f = selectTerritoryWithAlerts;
    end
    
    if terr.OwnerPlayerID ~= Game.Us.ID then
        f(addBuildVillageOrder, "You must select a territory you own. Please select a territory again");
        return;
    end
    if terrHasVillage(terr.Structures) then
        f(addBuildVillageOrder, "You cannot build a village on a territory that already has a village. Please select a territory again");
        return;
    end
    if BuildVillageOrderList and terrInTable(BuildVillageOrderList, terrDetails) then
        f(addBuildVillageOrder, "You already have an existing build village order for this territory");
        return;
    end
    if not hasEnoughResources(getRecipe(Catan.Recipes.Village), Resources) then
        f(addBuildVillageOrder, "You cannot build a village, you don't have enough resources to build one");
        return;
    end

    showBuildVillageOrders(terrDetails);
end

function upgradeVillage(terrDetails)
    if terrDetails == nil then return WL.CancelClickIntercept; end
    if UI.IsDestroyed(root) then return WL.CancelClickIntercept; end

    local terr = territories[terrDetails.ID];
    if terr.OwnerPlayerID ~= Game.Us.ID then
        selectTerritory(upgradeVillage, "You must select a territory you own. Please select a territory again");
        return;
    end
    if not terrHasVillage(terr.Structures) then
        selectTerritory(upgradeVillage, "You cannot upgrade a village on a territory that doesn't have a village. Please select a territory again");
        return;
    end
    if not hasEnoughResources(getRecipeLevel(getRecipe(Catan.Recipes.UpgradeVillage), terr.Structures[Catan.Village]), Resources) then
        selectTerritory(upgradeVillage, "You don't have enough resources for upgrading the village at " .. Game.Map.Territories[terrDetails.ID].Name .. ". Please select another territory");
        return;
    end

    Game.SendGameCustomMessage("Upgrading village...", {Command = "UpgradeVillage", TerritoryID = terrDetails.ID}, serverCallback);
end

function purchaseWarrior(terrDetails)
    if terrDetails == nil then return WL.CancelClickIntercept; end
    if UI.IsDestroyed(root) then return WL.CancelClickIntercept; end

    local terr = territories[terrDetails.ID];
    if terr.OwnerPlayerID ~= Game.Us.ID then
        selectTerritory(upgradeVillage, "You must select a territory you own. Please select a territory again");
        return;
    end
    
end

function buildWarriorCamp(terrDetails)
    if terrDetails == nil then return WL.CancelClickIntercept; end
    if UI.IsDestroyed(root) then return WL.CancelClickIntercept; end

    local terr = territories[terrDetails.ID];
    if terr.OwnerPlayerID ~= Game.Us.ID then
        selectTerritory(upgradeVillage, "You must select a territory you own. Please select a territory again");
        return;
    end
    if terrHasWarriorCamp(terr.Structures) then
        selectTerritory(buildWarriorCamp, "You must select a territory without a warrior camp. Please select a territory again");
        return;
    end
    
    Game.SendGameCustomMessage("Building warrior camp...", {Command = "BuildWarriorCamp", TerritoryID = terrDetails.ID}, serverCallback);
end

function selectTerritory(callback, message)
    CancelClickIntercept = false;
    
    DestroyWindow();
    SetWindow("selectTerritory");

    message = message or "Click a territory to select it"

    CreateLabel(root).SetText(message).SetColor(colors.TextColor);
    CreateLabel(root).SetText("You can move this window out of the way if necessary").SetColor(colors.TextColor);

    UI.InterceptNextTerritoryClick(callback);

    CreateEmpty(root).SetPreferredHeight(5);

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
end

function selectTerritoryWithAlerts(callback, message)
    if message then
        UI.Alert(message);
    end
    UI.InterceptNextTerritoryClick(callback);
end

function addToGainScore(terrID, isVillage)
    if not resourceWindowIsOpen() then return; end
    local terrRes = getResource(Game.LatestStanding.Territories[terrID]);
    local localBuildOrders = getTerritoryIDs(BuildVillageOrderList);
    local futureVillages = extractBuildVillageTerrIDs();
    for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
        local conn = Game.LatestStanding.Territories[connID];
        if terrRes ~= nil and conn.OwnerPlayerID == Game.Us.ID then
            if terrHasVillage(conn.Structures) then     -- Has already got a village
                ExpectedGainsLabels[terrRes].PotentiallyRemoved = ExpectedGainsLabels[terrRes].PotentiallyRemoved + (conn.Structures[Catan.Village] * getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID)));
            elseif valueInTable(futureVillages, connID) then    -- Has a order for building a village
                ExpectedGainsLabels[terrRes].PotentiallyRemoved = ExpectedGainsLabels[terrRes].PotentiallyRemoved + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID));
            elseif valueInTable(localBuildOrders, connID) then  -- Has a local order for building a village
                ExpectedGainsLabels[terrRes].PotentiallyAdded = ExpectedGainsLabels[terrRes].PotentiallyAdded - getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID));
            end
        end
        if isVillage and terrHasResource(conn.Structures) then
            local res = getResource(conn);
            if res ~= nil then
                if not (valueInTable(localBuildOrders, connID) or valueInTable(futureVillages, connID)) then
                    ExpectedGainsLabels[res].PotentiallyAdded = ExpectedGainsLabels[res].PotentiallyAdded + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, connID));
                end
            end
        end
    end
    updateExpectedGainsLabels(Game, true);
end

function removeFromGainScore(terrID, isVillage)
    if not resourceWindowIsOpen() then return; end
    local terrRes = getResource(Game.LatestStanding.Territories[terrID]);
    local localBuildOrders = getTerritoryIDs(BuildVillageOrderList);
    local futureVillages = extractBuildVillageTerrIDs();
    for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
        local conn = Game.LatestStanding.Territories[connID];
        if terrRes ~= nil and conn.OwnerPlayerID == Game.Us.ID then
            if terrHasVillage(conn.Structures) then
                ExpectedGainsLabels[terrRes].PotentiallyRemoved = ExpectedGainsLabels[terrRes].PotentiallyRemoved - (conn.Structures[Catan.Village] * getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID)));
            elseif valueInTable(futureVillages, connID) then
                ExpectedGainsLabels[terrRes].PotentiallyRemoved = ExpectedGainsLabels[terrRes].PotentiallyRemoved - getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID));
            elseif valueInTable(localBuildOrders, connID) then
                ExpectedGainsLabels[terrRes].PotentiallyAdded = ExpectedGainsLabels[terrRes].PotentiallyAdded + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID));
            end
        end
        if isVillage and terrHasResource(conn.Structures) then
            local res = getResource(conn);
            if res ~= nil then
                if not (valueInTable(localBuildOrders, connID) or valueInTable(futureVillages, connID)) then
                    ExpectedGainsLabels[res].PotentiallyAdded = ExpectedGainsLabels[res].PotentiallyAdded - getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, connID));
                end
            end
        end
    end
    updateExpectedGainsLabels(Game, true);
end

function showGainRemoveVillage(terrID, isVillage)
    if not resourceWindowIsOpen() then return; end
    local terrRes = getResource(Game.LatestStanding.Territories[terrID]);
    local futureVillages = extractBuildVillageTerrIDs();
    for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
        local conn = Game.LatestStanding.Territories[connID];
        if terrRes ~= nil and conn.OwnerPlayerID == Game.Us.ID then
            if terrHasVillage(conn.Structures) then     -- Has already got a village
                ExpectedGainsLabels[terrRes].PotentiallyAdded = ExpectedGainsLabels[terrRes].PotentiallyAdded + (conn.Structures[Catan.Village] * getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID)));
            elseif valueInTable(futureVillages, connID) then    -- Has a order for building a village
                ExpectedGainsLabels[terrRes].PotentiallyAdded = ExpectedGainsLabels[terrRes].PotentiallyAdded + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID));
            end
        end
        if isVillage and terrHasResource(conn.Structures) then
            local res = getResource(conn);
            if res ~= nil then
                if not valueInTable(futureVillages, connID) then
                    ExpectedGainsLabels[res].PotentiallyRemoved = ExpectedGainsLabels[res].PotentiallyRemoved + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, connID));
                end
            end
        end
    end
    updateExpectedGainsLabels(Game, true);
end

function showGainUnremoveVillage(terrID, isVillage)
    if not resourceWindowIsOpen() then return; end
    local terrRes = getResource(Game.LatestStanding.Territories[terrID]);
    local futureVillages = extractBuildVillageTerrIDs();
    for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
        local conn = Game.LatestStanding.Territories[connID];
        if terrRes ~= nil and conn.OwnerPlayerID == Game.Us.ID then
            if terrHasVillage(conn.Structures) then
                ExpectedGainsLabels[terrRes].PotentiallyAdded = ExpectedGainsLabels[terrRes].PotentiallyAdded - (conn.Structures[Catan.Village] * getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID)));
            elseif valueInTable(futureVillages, connID) then
                ExpectedGainsLabels[terrRes].PotentiallyAdded = ExpectedGainsLabels[terrRes].PotentiallyAdded - getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, terrID));
            end
        end
        if isVillage and terrHasResource(conn.Structures) then
            local res = getResource(conn);
            if res ~= nil then
                if not valueInTable(futureVillages, connID) then
                    ExpectedGainsLabels[res].PotentiallyRemoved = ExpectedGainsLabels[res].PotentiallyRemoved - getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, connID));
                end
            end
        end
    end
    updateExpectedGainsLabels(Game, true);
end

function extractBuildVillageTerrIDs()
    if Mod.PlayerGameData == nil or Mod.PlayerGameData.OrderList == nil then return {}; end
    local t = {};
    local enum = getBuildVillageEnum();
    for _, order in ipairs(Mod.PlayerGameData.OrderList) do
        if order.OrderType == enum then
            table.insert(t, order.TerritoryID);
        end
    end
    return t;
end

function removeLocalResources(recipe, b)
    b = b or false;
    for i, v in ipairs(recipe) do
        Resources[i] = Resources[i] - v;
    end
    if b then
        decreaseGain(recipe);
    else
        increaseCost(recipe);
    end
end

function addLocalResources(recipe, b)
    b = b or false;
    for i, v in ipairs(recipe) do
        Resources[i] = Resources[i] + v;
    end
    if b then
        decreaseCost(recipe);
    else
        increaseGain(recipe);
    end
end

function increaseCost(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in ipairs(resources) do
        ResourceLabels[i].PotentiallyRemoved = ResourceLabels[i].PotentiallyRemoved + v;
    end
    updateLabels();
end

function decreaseCost(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in ipairs(resources) do
        ResourceLabels[i].PotentiallyRemoved = ResourceLabels[i].PotentiallyRemoved - v;
    end
    updateLabels();
end

function increaseGain(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in ipairs(resources) do
        ResourceLabels[i].PotentiallyAdded = ResourceLabels[i].PotentiallyAdded + v;
    end
    updateLabels();
end

function decreaseGain(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in ipairs(resources) do
        ResourceLabels[i].PotentiallyAdded = ResourceLabels[i].PotentiallyAdded - v;
    end
    updateLabels();
end

function resetAddedResources()
    if not resourceWindowIsOpen() then return; end
    for i, _ in ipairs(ResourceLabels) do
        ResourceLabels[i].PotentiallyRemoved = 0;
    end
    updateLabels();
end

function resetRemovedResources()
    if not resourceWindowIsOpen() then return; end
    for i, _ in ipairs(ResourceLabels) do
        ResourceLabels[i].PotentiallyAdded = 0;
    end
    updateLabels();
end

function resetAddedGain()
    if not resourceWindowIsOpen() then return; end
    for i, _ in ipairs(ExpectedGainsLabels) do
        ExpectedGainsLabels[i].PotentiallyAdded = 0;
    end
    updateExpectedGainsLabels(Game, true);
end

function resetRemovedGain()
    if not resourceWindowIsOpen() then return; end
    for i, _ in ipairs(ExpectedGainsLabels) do
        ExpectedGainsLabels[i].PotentiallyRemoved = 0;
    end
    updateExpectedGainsLabels(Game, true);
end

function resetAllResourceLabels()
    if not resourceWindowIsOpen() then return; end
    for i, _ in ipairs(ResourceLabels) do
        ResourceLabels[i].PotentiallyAdded = 0;
        ResourceLabels[i].PotentiallyRemoved = 0;
    end
    for i, _ in ipairs(ExpectedGainsLabels) do
        ExpectedGainsLabels[i].PotentiallyRemoved = 0;
        ExpectedGainsLabels[i].PotentiallyAdded = 0;
    end
    updateLabels();
    updateExpectedGainsLabels(Game, true);
end

function serverCallback(t)
    print(t.Status .. "\t" .. t.Text);
    showMain();
end

function getTerritoryIDs(list)
    if list == nil then return {}; end
    local t = {};
    for _, v in pairs(list) do
        table.insert(t, v.ID);
    end
    return t;
end

function getStringForButton(s)
    if #s > 30 then
        return string.sub(s, 1, 30) .. "...";
    else
        return s;
    end
end

function compareTerrDetailsWithID(v, v2)
    return v == v2.ID;
end

function terrInTable(t, terr)
    for _, v in pairs(t) do
        if v.ID == terr.ID then
            return true;
        end
    end
    return false;
end

function resourceWindowIsOpen()
    return not (rootClientRefresh == nil or UI.IsDestroyed(vertClientRefresh));
end