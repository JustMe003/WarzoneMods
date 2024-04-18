require("Catan");
require("UI");
require("Annotations");
require("Client_GameRefresh");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
---@param func fun()? # Zero parameter function that will be called if not nil
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, func)
    print(101);
    if game.Game.TurnNumber < 1 then
        close();
        UI.Alert("You can only open the menu when the distribution has ended");
    end
    print(102);
    if game.Us == nil then
        close();
        UI.Alert("Spectators are not allowed to view the menu");
    end
    print(103);
    
    
    print(104);
    setMaxSize(400, 500);
    print(105);
    
    print(106);
    Init(rootParent);
    print(107);
    vert = GetRoot().SetFlexibleWidth(1);
    print(108);
    colors = GetColors();
    print(109);
    Game = game;
    print(110);
    territories = game.LatestStanding.Territories;
    print(111);
    CancelClickIntercept = true;
    print(112);
    Waiting = false;
    print(113);
    Settings = Mod.Settings.Config;
    print(114);

    showHomeButtons();

    SetWindow("Dummy");
    
    if func then
        func();
    else
        showMain();
    end
end


--#region Main functions


function showMain()
    DestroyWindow();
    SetWindow("Main");
    Resources = copyTable(Mod.PlayerGameData.Resources)

    updateHomeButtons(void, showMain, TODO);

    CreateButton(root).SetText("Build village").SetColor(colors.Blue).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.Village), Resources)).SetOnClick(function() selectTerritory(addBuildVillageOrder); end);
    CreateButton(root).SetText("Upgrade village").SetColor(colors.Green).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.UpgradeVillage), Resources)).SetOnClick(function() selectTerritory(addUpgradeVillageOrder); end);
    CreateButton(root).SetText("Build army camp").SetColor(colors.Cyan).SetInteractable(hasEnoughResources(getRecipe(Catan.Recipes.ArmyCamp), Resources)).SetOnClick(function() selectTerritory(addBuildArmyCampOrder) end)
    CreateButton(root).SetText("Purchase units").SetColor(colors.Bronze).SetInteractable(canPurchaseCatanUnits()).SetOnClick(function() selectTerritory(addPurchaseUnitsOrder) end)
    CreateButton(root).SetText("Split unit").SetColor(colors.Teal).SetOnClick(function() selectTerritory(addSplitUnitOrder) end)

    CreateEmpty(root).SetPreferredHeight(10);

    CreateButton(root).SetText("Show orders").SetColor(colors.Orange).SetOnClick(showOrders)
    CreateButton(root).SetText("Exchange resources").SetColor(colors.Yellow).SetOnClick(exchangeResourcesWindow);
    CreateButton(root).SetText("Tech tree").SetColor(colors.Lime).SetOnClick(showAllTechTrees);
end

function showHomeButtons();
    HomeButtons = {};
    local line = CreateHorz(vert).SetFlexibleWidth(1);
    HomeButtons.Home = CreateButton(line).SetText("H").SetColor(colors.Lime)
    HomeButtons.Return = CreateButton(line).SetText("<").SetColor(colors.Orange)

    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Catan").SetColor("#FFC200");
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    CreateButton(line).SetText("i").SetColor(colors.Yellow).SetOnClick(reopenResourceWindow);
    HomeButtons.Help = CreateButton(line).SetText("?").SetColor(colors["Light Blue"])

    CreateEmpty(vert).SetPreferredHeight(10);

    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(20);
    root = CreateVert(line).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(20);
end

function updateHomeButtons(homeFunc, returnFunc, helpFunc)
    HomeButtons.Home.SetOnClick(function()
        homeFunc();
        showMain();    
    end);
    HomeButtons.Return.SetOnClick(returnFunc);
    HomeButtons.Help.SetOnClick(helpFunc);
end


--#endregion Main functions
--#region Order management windows


function showOrders()
    DestroyWindow()
    SetWindow("showOrders");

    updateHomeButtons(void, showMain, TODO);

    local orderTypes = {};
    for _, type in pairs(Catan.OrderType) do
        orderTypes[type] = {};
    end

    for _, order in ipairs(Mod.PlayerGameData.OrderList) do
        table.insert(orderTypes[order.OrderType], order);
    end

    CreateButton(root).SetText("Build village orders: " .. #orderTypes[getBuildVillageEnum()]).SetColor(colors.Blue).SetOnClick(function() 
        viewTypeOrders(orderTypes[getBuildVillageEnum()], "You will be building villages on the following territories", 
        function(details, terr)
            showGainRemoveVillage(terr.ID, true);
        end,
        function(details, terr)
            showGainUnremoveVillage(terr.ID, true);
        end, returnTerrName); 
    end);

    CreateButton(root).SetText("Upgrade village orders: " .. #orderTypes[getUpgradeVillageEnum()]).SetColor(colors.Blue).SetOnClick(function() 
        viewTypeOrders(orderTypes[getUpgradeVillageEnum()], "You will be upgrading villages on the following territories", 
        function(details, terr)  
            increaseScoreCost(getGainScoreFromOneTerr(Game.LatestStanding.Territories, Game.Map.Territories[details.ID].ConnectedTo, Mod.PublicGameData));
        end, 
        function(details, terr)
            decreaseScoreCost(getGainScoreFromOneTerr(Game.LatestStanding.Territories, Game.Map.Territories[details.ID].ConnectedTo, Mod.PublicGameData));
        end, returnTerrName); 
    end);

    CreateButton(root).SetText("Build army camp orders: " .. #orderTypes[getBuildArmyCampEnum()]).SetColor(colors.Blue).SetOnClick(function()
        viewTypeOrders(orderTypes[getBuildArmyCampEnum()], "You will build army camps on the following territories", TwoArgVoid, TwoArgVoid, returnTerrName);
    end)

    CreateButton(root).SetText("Split unit orders: " .. #orderTypes[getSplitUnitStackOrderEnum()]).SetColor(colors.Blue).SetOnClick(function()
        viewTypeOrders(orderTypes[getSplitUnitStackOrderEnum()], "You have the following split unit orders", TwoArgVoid, TwoArgVoid,
        function(order, name)
            return round(order.SplitPercentage, 2) .. ", " .. getUnitNameByType(order.UnitType) .. ", " .. name;
        end)
    end)

    CreateButton(root).SetText("Unit purchase orders: " .. #orderTypes[getPurchaseUnitEnum()]).SetColor(colors.Blue).SetOnClick(function()
        showUnitPurchaseOrdersList(orderTypes[getPurchaseUnitEnum()]);
    end)

    CreateButton(root).SetText("Resource exchanges: " .. #orderTypes[getExchangeResourcesWithBankEnum()]).SetColor(colors.Blue).SetOnClick(function() showResourceExchangeOrders(orderTypes[getExchangeResourcesWithBankEnum()]); end);

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain)
end

function viewTypeOrders(orders, message, selectedForDeletion, unselectedForDeletion, buttonText)
    DestroyWindow()
    SetWindow("viewTypeOrders");

    updateHomeButtons(resetAllResourceLabels, function()
        resetAllResourceLabels();
        showOrders(); 
    end, TODO);

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

    CreateLabel(root).SetText(message).SetColor(colors.TextColor);
    for i, order in ipairs(orders) do
        local details = Game.Map.Territories[order.TerritoryID];
        local terr = Game.LatestStanding.Territories[order.TerritoryID];
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateButton(line).SetText(getStringForButton(buttonText(order, details.Name), 25)).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY); 
            Game.HighlightTerritories({details.ID});
        end);
        local delBut = CreateButton(line).SetText("X").SetColor(colors.Yellow).SetInteractable(deleteMode)
        delBut.SetOnClick(function()  
            if delBut.GetColor() == colors.Yellow then
                -- Selected for deletion
                delBut.SetColor(colors.Red);
                table.insert(deleteOrders, i);
                increaseGain(order.Cost);
                selectedForDeletion(details, terr);
            else
                -- Unselected for deletion
                delBut.SetColor(colors.Yellow);
                decreaseGain(order.Cost);
                unselectedForDeletion(details, terr);
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

function showUnitPurchaseOrdersList(orders)
    DestroyWindow()
    SetWindow("showUnitPurchaseOrdersList");

    updateHomeButtons(resetAllResourceLabels, function()
        resetAllResourceLabels();
        showOrders(); 
    end, TODO);

    local deleteMode = false;
    local deleteButtons = {};
    local editButtons = {};
    local deleteOrders = {};
    local deleteSelectedButton;

    local returnFunc = function()
        resetAllResourceLabels();
        showUnitPurchaseOrdersList(orders);
    end;

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
        for _, but in ipairs(editButtons) do
            but.SetInteractable(not deleteMode);
        end
    end)

    CreateLabel(root).SetText("You will deploy units on the following territories").SetColor(colors.TextColor);
    for i, order in ipairs(orders) do
        local details = Game.Map.Territories[order.TerritoryID];
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateButton(line).SetText(getStringForButton(details.Name, 25)).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY); 
            Game.HighlightTerritories({details.ID});
        end);
        table.insert(editButtons, CreateButton(line).SetText("Edit").SetColor(colors.Aqua).SetOnClick(function() 
            showPurchaseUnitsWindow(order, void, returnFunc, function(newOrder)
                Game.SendGameCustomMessage("Updating order...", {Command =  "ModifyUnitPurchaseOrder", OrderIndex = i, NewOrder = newOrder}, serverCallback);
                resetAllResourceLabels();
                waitWindow();
            end)
        end).SetInteractable(not deleteMode))
        local delBut = CreateButton(line).SetText("X").SetColor(colors.Yellow).SetInteractable(deleteMode)
        delBut.SetOnClick(function()  
            if delBut.GetColor() == colors.Yellow then
                -- Selected for deletion
                delBut.SetColor(colors.Red);
                table.insert(deleteOrders, i);
                increaseGain(order.Cost);
            else
                -- Unselected for deletion
                delBut.SetColor(colors.Yellow);
                decreaseGain(order.Cost);
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

function showResourceExchangeOrders(orders)
    DestroyWindow()
    SetWindow("viewUpgradeVillageOrders");

    updateHomeButtons(resetAllResourceLabels, function()
        resetAllResourceLabels();
        showOrders(); 
    end, TODO);

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

    CreateLabel(root).SetText("You will be exchanging the following resources").SetColor(colors.TextColor);
    for i, order in ipairs(orders) do
        local giveRes;
        local gainRes;
        for res, n in ipairs(order.Cost) do
            if n > 0 then giveRes = res; break; end
        end
        for res, n in ipairs(order.Gain) do
            if n > 0 then gainRes = res; break; end
        end

        local line = CreateHorz(root).SetFlexibleWidth(1);
        if giveRes and gainRes then
            CreateLabel(line).SetText(order.Cost[giveRes]).SetColor(colors.TextColor);
            CreateLabel(line).SetText(" ").SetColor(colors.TextColor);
            CreateLabel(line).SetText(getResourceName(giveRes)).SetColor(getResourceColor(giveRes));
            CreateLabel(line).SetText(" --> ").SetColor(colors.TextColor);
            CreateLabel(line).SetText(order.Gain[gainRes]).SetColor(colors.TextColor);
            CreateLabel(line).SetText(" ").SetColor(colors.TextColor);
            CreateLabel(line).SetText(getResourceName(gainRes)).SetColor(getResourceColor(gainRes));
        else
            CreateLabel(line).SetText("This order is faulty").SetColor(colors.TextColor);
        end
        local delBut = CreateButton(line).SetText("X").SetColor(colors.Yellow).SetInteractable(deleteMode)
        delBut.SetOnClick(function()  
            if delBut.GetColor() == colors.Yellow then
                -- Selected for deletion
                delBut.SetColor(colors.Red);
                table.insert(deleteOrders, i);
                increaseGain(order.Cost);
                increaseCost(order.Gain);
            else
                -- Unselected for deletion
                delBut.SetColor(colors.Yellow);
                decreaseGain(order.Cost);
                decreaseCost(order.Gain);
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
        waitWindow();
    end
end


--#endregion Order management windows
--#region Multi selecting windows


function showBuildVillageOrders(terrDetails)
    DestroyWindow()
    SetWindow("showBuildVillageOrders");
    
    local recipe = getRecipe(Catan.Recipes.Village);
    local reset = function()
        CancelClickIntercept = true; 
        BuildVillageOrderList = nil; 
        resetAllResourceLabels();
    end

    updateHomeButtons(reset, function()
        reset();
        showMain();
    end, TODO);

    selectTerritoryWithAlerts(addBuildVillageOrder);

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
        Game.SendGameCustomMessage("Building villages...", {Command = "BuildMultipleVillages", TerritoryIDs = getTerritoryIDs(BuildVillageOrderList)}, serverCallback); 
        reset();
        waitWindow();
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() 
        reset();
        showMain(); 
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function showUpgradeVillageOrders(terrDetails)
    DestroyWindow()
    SetWindow("showUpgradeVillageOrders");

    local recipe = getRecipe(Catan.Recipes.UpgradeVillage);
    local reset = function()
        CancelClickIntercept = true;
        UpgradeVillageOrderList = nil; 
        resetAllResourceLabels();
    end

    updateHomeButtons(reset, function()
        reset();
        showMain();
    end, TODO);

    selectTerritoryWithAlerts(addUpgradeVillageOrder);

    UpgradeVillageOrderList = UpgradeVillageOrderList or {};
    if terrDetails then
        table.insert(UpgradeVillageOrderList, terrDetails);
        removeLocalResources(getRecipeLevel(recipe, Game.LatestStanding.Territories[terrDetails.ID].Structures[Catan.Village]));
        increaseScoreGain(getGainScoreFromOneTerr(Game.LatestStanding.Territories, Game.Map.Territories[terrDetails.ID].ConnectedTo, Mod.PublicGameData));
    end

    
    CreateLabel(root).SetText("Currently you're trying to upgrade the villages on the following territories:").SetColor(colors.TextColor);
    for i, details in ipairs(UpgradeVillageOrderList) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getStringForButton(details.Name)).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY); 
            Game.HighlightTerritories({details.ID}); 
        end);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("X").SetColor(colors["Orange Red"]).SetOnClick(function() 
            table.remove(UpgradeVillageOrderList, i);
            addLocalResources(getRecipeLevel(recipe, Game.LatestStanding.Territories[terrDetails.ID].Structures[Catan.Village]), true);
            decreaseScoreGain(getGainScoreFromOneTerr(Game.LatestStanding.Territories, Game.Map.Territories[terrDetails.ID].ConnectedTo, Mod.PublicGameData));
            showUpgradeVillageOrders();
        end);
    end

    CreateEmpty(root).SetPreferredHeight(10);

    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Upgrade").SetColor(colors.Green).SetOnClick(function() 
        Game.SendGameCustomMessage("Upgrading villages...", {Command = "UpgradeMultipleVillages", TerritoryIDs = getTerritoryIDs(UpgradeVillageOrderList)}, serverCallback); 
        reset();
        waitWindow();
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() 
        reset();
        showMain(); 
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function showBuildArmyCampOrder(terrDetails)
    DestroyWindow()
    SetWindow("showBuildArmyCampOrder");

    local reset = function()
        CancelClickIntercept = true;
        BuildArmyCampOrderList = nil; 
        resetAllResourceLabels();
    end

    updateHomeButtons(reset, function()
        reset();
        showMain();
    end, TODO);

    selectTerritoryWithAlerts(addBuildArmyCampOrder);
    local recipe = getRecipe(Catan.Recipes.ArmyCamp);

    BuildArmyCampOrderList = BuildArmyCampOrderList or {};
    if terrDetails then
        table.insert(BuildArmyCampOrderList, terrDetails);
        addToGainScore(terrDetails.ID, false);
        removeLocalResources(recipe);
    end

    
    CreateLabel(root).SetText("Currently you're trying to build army camps on the following territories:").SetColor(colors.TextColor);
    for i, details in ipairs(BuildArmyCampOrderList) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getStringForButton(details.Name)).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY); 
            Game.HighlightTerritories({details.ID}); 
        end);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("X").SetColor(colors["Orange Red"]).SetOnClick(function() 
            table.remove(BuildArmyCampOrderList, i);
            addLocalResources(recipe, true);
            removeFromGainScore(details.ID, false);
            showBuildArmyCampOrder()
        end);
    end

    CreateEmpty(root).SetPreferredHeight(10);

    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Build").SetColor(colors.Green).SetOnClick(function() 
        Game.SendGameCustomMessage("Upgrading villages...", {Command = "BuildMultipleArmyCamps", TerritoryIDs = getTerritoryIDs(BuildArmyCampOrderList)}, serverCallback); 
        reset();
        waitWindow();
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() 
        reset();
        showMain(); 
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function showPurchaseUnitsWindow(order, cancelFunc, returnFunc, callback, reverseMode)
    callback = callback or showPurchaseUnitsOrders;
    reverseMode = reverseMode or false;
    DestroyWindow()
    SetWindow("showPurchaseUnitsWindow");

    updateHomeButtons(function() 
        resetAllResourceLabels();
        if cancelFunc then cancelFunc(); end
    end, function()
        if returnFunc then 
            returnFunc(); 
        else
            showMain();
        end
    end, TODO);

    local orderCopy = copyTable(order);

    for name, unit in pairs(getArmyCampUnits()) do
        if canPurchaseUnit(unit) then
            local recipe = getUnitRecipe(Mod.PlayerGameData.Modifiers, unit);
            local valueLabel;
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateButton(line).SetText("-").SetColor(colors.Red).SetOnClick(function()
                if orderCopy.Units[unit] > 0 then
                    orderCopy.Units[unit] = orderCopy.Units[unit] - 1;
                    addLocalResources(recipe, not reverseMode);
                    orderCopy.Cost = combineRecipes(orderCopy.Cost, multiplyRecipe(recipe, -1));
                else
                    orderCopy.Units[unit] = math.min(getUnitPurchaseLimit(Mod.PlayerGameData.Modifiers, unit), getMaxRecipeUse(recipe, Resources));
                    local multRecipe = multiplyRecipe(recipe, orderCopy.Units[unit]);
                    removeLocalResources(multRecipe, reverseMode);
                    orderCopy.Cost = combineRecipes(orderCopy.Cost, multRecipe);
                end
                valueLabel.SetText(orderCopy.Units[unit]);
            end);
            CreateButton(line).SetText("+").SetColor(colors.Green).SetOnClick(function()
                if orderCopy.Units[unit] < getUnitPurchaseLimit(Mod.PlayerGameData.Modifiers, unit) and hasEnoughResources(recipe, Resources) then
                    orderCopy.Units[unit] = orderCopy.Units[unit] + 1;
                    removeLocalResources(recipe, reverseMode);
                    orderCopy.Cost = combineRecipes(orderCopy.Cost, recipe);
                else
                    local multRecipe = multiplyRecipe(recipe, orderCopy.Units[unit]);
                    addLocalResources(multRecipe, not reverseMode);
                    orderCopy.Units[unit] = 0;
                    orderCopy.Cost = combineRecipes(orderCopy.Cost, multiplyRecipe(multRecipe, -1));
                end
                valueLabel.SetText(orderCopy.Units[unit]);
            end);
            valueLabel = CreateLabel(line).SetText(orderCopy.Units[unit]).SetColor(colors.Peach);
            CreateLabel(line).SetText(name).SetColor(colors.TextColor);
        else
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateButton(line).SetText("-").SetColor(colors.Red).SetInteractable(false);
            CreateButton(line).SetText("+").SetColor(colors.Green).SetInteractable(false);
            CreateLabel(line).SetText("Locked").SetColor(colors.TextColor);
        end
    end

    CreateEmpty(root).SetPreferredHeight(5);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Add order").SetColor(colors.Green).SetOnClick(function() 
        if PurchaseUnitsOrders and valueInTable(PurchaseUnitsOrders, order) then
            for i, o in ipairs(PurchaseUnitsOrders) do
                if order == o then
                    table.remove(PurchaseUnitsOrders, i);
                    break;
                end
            end
        end
        callback(orderCopy);
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(function() 
        if returnFunc then
            addLocalResources(orderCopy.Cost, true);
            returnFunc(); 
        else
            showMain();
        end
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function showPurchaseUnitsOrders(order)
    DestroyWindow()
    SetWindow("showPurchaseUnitsOrders");

    local reset = function()
        CancelClickIntercept = true;
        PurchaseUnitsOrders = nil;
        resetAllResourceLabels();
    end

    updateHomeButtons(reset, function()
        reset();
        showMain();
    end, TODO);

    selectTerritoryWithAlerts(addPurchaseUnitsOrder)

    PurchaseUnitsOrders = PurchaseUnitsOrders or {};
    if order and not valueInTable(PurchaseUnitsOrders, order) then
        table.insert(PurchaseUnitsOrders, order);
    end

    CreateLabel(root).SetText("Currently you have the following unit purchase orders").SetColor(colors.TextColor);
    for i, details in ipairs(PurchaseUnitsOrders) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getStringForButton(Game.Map.Territories[details.TerritoryID].Name, 10) .. ": " .. getTotalUnitCount(details.Units) .. " units").SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(Game.Map.Territories[details.TerritoryID].MiddlePointX, Game.Map.Territories[details.TerritoryID].MiddlePointY);
            Game.HighlightTerritories({details.TerritoryID});
        end);
        CreateButton(line).SetText("Edit").SetColor(colors.Yellow).SetOnClick(function() 
            showPurchaseUnitsWindow(details, reset, function()
                removeLocalResources(details.Cost);
                showPurchaseUnitsOrders(); 
            end);
        end);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("X").SetColor(colors["Orange Red"]).SetOnClick(function() 
            table.remove(PurchaseUnitsOrders, i);
            addLocalResources(details.Cost, true);
            showPurchaseUnitsOrders();
        end);
    end

    CreateEmpty(root).SetPreferredHeight(10);

    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Send").SetColor(colors.Green).SetOnClick(function() 
        Game.SendGameCustomMessage("Purchasing units...", {Command = "PurchaseMultipleUnits", Orders = PurchaseUnitsOrders}, serverCallback); 
        reset();
        waitWindow();
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() 
        reset();
        showMain(); 
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function showSplitUnitOrders(data)
    DestroyWindow()
    SetWindow("showSplitUnitOrders");

    local reset = function()
        CancelClickIntercept = true;
        SplitUnitOrders = nil;
    end

    selectTerritoryWithAlerts(addSplitUnitOrder);

    updateHomeButtons(reset, function()
        reset();
        showMain();
    end, TODO);

    SplitUnitOrders = SplitUnitOrders or {};
    if data then
        table.insert(SplitUnitOrders, {Details = data.Details, TerritoryID = data.Details.ID, SplitPercentage = data.Percentage, UnitType = data.UnitType});
    end

    
    CreateLabel(root).SetText("Currently you are splitting the following units:").SetColor(colors.TextColor);
    for i, order in ipairs(SplitUnitOrders) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getStringForButton(round(order.SplitPercentage * 100, 2) .. "%, " .. getUnitNameByType(order.UnitType) .. ", " .. order.Details.Name, 24)).SetColor(colors.Blue).SetOnClick(function() 
            Game.CreateLocatorCircle(order.Details.MiddlePointX, order.Details.MiddlePointY);
            Game.HighlightTerritories({order.TerritoryID}); 
        end);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("X").SetColor(colors["Orange Red"]).SetOnClick(function() 
            table.remove(SplitUnitOrders, i);
            showSplitUnitOrders();
        end);
    end

    CreateEmpty(root).SetPreferredHeight(10);

    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Send").SetColor(colors.Green).SetOnClick(function() 
        Game.SendGameCustomMessage("Splitting units...", {Command = "SplitMultipleUnits", Details = SplitUnitOrders}, serverCallback); 
        reset();
        waitWindow();
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() 
        reset();
        showMain(); 
    end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end


--#endregion Multi selecting windows
--#region Input territory validatition


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
    if Mod.PlayerGameData.OrderList and valueInTable(extractBuildVillageTerrIDs(Mod.PlayerGameData), terrDetails.ID) then
        f(addBuildVillageOrder, "You already have a existing build village order for this territory");
        return;
    end
    
    showBuildVillageOrders(terrDetails);
end

function addUpgradeVillageOrder(terrDetails)
    if CancelClickIntercept or terrDetails == nil or UI.IsDestroyed(root) then return WL.CancelClickIntercept; end

    local terr = territories[terrDetails.ID];
    local f;
    if UpgradeVillageOrderList == nil then
        f = selectTerritory;
    else
        f = selectTerritoryWithAlerts;
    end

    if terr.OwnerPlayerID ~= Game.Us.ID then
        f(addUpgradeVillageOrder, "You must select a territory you own. Please select a territory again");
        return;
    end
    if not terrHasVillage(terr.Structures) then
        f(addUpgradeVillageOrder, "You cannot upgrade a village on a territory that doesn't have a village. Please select a territory again");
        return;
    end
    if UpgradeVillageOrderList and terrInTable(UpgradeVillageOrderList, terrDetails) then
        f(addUpgradeVillageOrder, "You already have an existing build village order for this territory");
        return;
    end
    if not hasEnoughResources(getRecipeLevel(getRecipe(Catan.Recipes.UpgradeVillage), terr.Structures[Catan.Village]), Resources) then
        f(addUpgradeVillageOrder, "You don't have enough resources for upgrading the village at " .. Game.Map.Territories[terrDetails.ID].Name .. ". Please select another territory");
        return;
    end
    if Mod.PlayerGameData.OrderList and valueInTable(extractBuildOrdersTerrIDs(Mod.PlayerGameData), terrDetails.ID) then
        f(addBuildVillageOrder, "You already have a existing build order for this territory, you can only have 1");
        return;
    end
    
    showUpgradeVillageOrders(terrDetails);
end

function addBuildArmyCampOrder(terrDetails)
    if CancelClickIntercept or terrDetails == nil or UI.IsDestroyed(root) then return WL.CancelClickIntercept; end

    local terr = territories[terrDetails.ID];
    local f;
    if BuildArmyCampOrderList == nil then
        f = selectTerritory;
    else
        f = selectTerritoryWithAlerts;
    end

    if terr.OwnerPlayerID ~= Game.Us.ID then
        f(addBuildArmyCampOrder, "You must select a territory you own. Please select a territory again");
        return;
    end
    if terrHasArmyCamp(terr.Structures) then
        f(addBuildArmyCampOrder, "You must select a territory without a army camp. Please select a territory again");
        return;
    end
    if terrHasVillage(terr.Structures) then
        UI.Alert(terrDetails.Name .. " has a village, building a army camp will remove the village, so be sure about this!");
    end
    if not hasEnoughResources(getRecipe(Catan.Recipes.ArmyCamp), Resources) then
        f(addBuildArmyCampOrder, "You don't have enough resources to build an additional army camp");
        return;
    end
    if BuildArmyCampOrderList and terrInTable(BuildArmyCampOrderList, terrDetails) then
        f(addBuildArmyCampOrder, "You already have an order for this territory");
        return;
    end
    if Mod.PlayerGameData.OrderList and valueInTable(extractBuildOrdersTerrIDs(Mod.PlayerGameData), terrDetails.ID) then
        f(addBuildArmyCampOrder, "You already have a build order for this territory, you can only have 1");
        return;
    end
    
    showBuildArmyCampOrder(terrDetails);
end

function addPurchaseUnitsOrder(terrDetails)
    if CancelClickIntercept or terrDetails == nil or UI.IsDestroyed(root) then return WL.CancelClickIntercept; end
    
    local terr = territories[terrDetails.ID];
    local f;
    if PurchaseUnitsOrders == nil then
        f = selectTerritory;
    else
        f = selectTerritoryWithAlerts;
    end

    if terr.OwnerPlayerID ~= Game.Us.ID then
        f(addPurchaseUnitsOrder, "You must select a territory you own");
        return;
    end

    if not terrHasArmyCamp(terr.Structures) then
        f(addPurchaseUnitsOrder, "You must select a territory with an army camp");
        return;
    end

    if Mod.PlayerGameData.OrderList and valueInTable(extractPurchaseUnitOrdersTerrIDs(Mod.PlayerGameData), terrDetails.ID) then
        f(addPurchaseUnitsOrder, "You already have an purchase units order for this territory, please modify the existing order");
        return;
    end

    if not canPurchaseCatanUnits() then
        f(addPurchaseUnitOrder, "You don't have enough resources to purchase more units");
        return;
    end

    if PurchaseUnitsOrders ~= nil and valueInTable(getTerritoryIDs(PurchaseUnitsOrders), terrDetails.ID) then
        local order;
        for _, purchaseOrder in ipairs(PurchaseUnitsOrders) do
            if purchaseOrder.TerritoryID == terrDetails.ID then
                order = purchaseOrder;
                break;
            end
        end
        showPurchaseUnitsWindow(order, function() 
            CancelClickIntercept = true;
            PurchaseUnitsOrders = nil;
            resetAllResourceLabels();
        end, function ()
            removeLocalResources(order.Cost);
            showPurchaseUnitsOrders();
        end);
    else
        local order = {
            Command = "PurchaseUnits",
            TerritoryID = terrDetails.ID,
            Units = {},
            Cost = getEmptyResourceTable()
        };
        for _, unit in pairs(getArmyCampUnits()) do
            order.Units[unit] = 0;
        end
        showPurchaseUnitsWindow(order);
    end

end

function addSplitUnitOrder(terrDetails)
    if CancelClickIntercept or terrDetails == nil or UI.IsDestroyed(root) then return WL.CancelClickIntercept; end

    local terr = territories[terrDetails.ID];
    local f;
    if SplitUnitOrders == nil then
        f = selectTerritory;
    else
        f = selectTerritoryWithAlerts;
    end

    if not territoryIsFullyVisible(terr) then
        f(addSplitUnitOrder, "You must select a territory that is actually fully visible for you");
        return;
    end

    if terr.OwnerPlayerID ~= Game.Us.ID then
        f(addSplitUnitOrder, "You must select a territory that you own");
        return;
    end

    if #terr.NumArmies.SpecialUnits <= 0 then
        f(addSplitUnitOrder, "You must select a territory that has some units");
        return;
    end

    local terrUnitTypes = {};
    if SplitUnitOrders then
        for _, order in ipairs(SplitUnitOrders) do
            if order.TerritoryID == terrDetails.ID then
                table.insert(terrUnitTypes, order.UnitType);
            end
        end
    end

    if Mod.PlayerGameData.OrderList then
        for _, order in ipairs(extractSplitUnitOrders(Mod.PlayerGameData)) do
            if order.TerritoryID == terrDetails.ID then
                table.insert(terrUnitTypes, order.UnitType);
            end
        end
    end

    terrUnitTypes = makeSet(terrUnitTypes);

    local c = 0;
    for _, unit in ipairs(terr.NumArmies.SpecialUnits) do
        if isCatanUnit(unit) and not valueInTable(terrUnitTypes, getUnitType(unit)) then c = c + 1 end
    end
    if c < 1 then
        f(addSplitUnitOrder, "You must select a territory with a Catan unit, or maybe you already have split orders for all units on this territory");
        return;
    end

    if c > 1 then
        local list = {};
        for _, unit in ipairs(terr.NumArmies.SpecialUnits) do
            if isCatanUnit(unit) and not valueInTable(terrUnitTypes, getUnitType(unit)) then
                table.insert(list, {Text = getUnitNameByType(getUnitType(unit)) .. " (" .. math.ceil(getNumberOfUnits(Mod.PlayerGameData.Modifiers, unit)) .. ")", Selected = function() return unit; end});
            end
        end
        pickFromList(list, function(choice)
            for i, v in pairs(choice) do
                print(i, v);
            end
            showPercentage(function(per)
                showSplitUnitOrders({Details = terrDetails, Percentage = per, UnitType = getUnitType(choice)});
            end, showMain);
        end, showMain);
    else
        for _, unit in ipairs(terr.NumArmies.SpecialUnits) do
            if isCatanUnit(unit) and not valueInTable(terrUnitTypes, getUnitType(unit)) then
                showPercentage(function(per)
                    showSplitUnitOrders({Details = terrDetails, Percentage = per, UnitType = getUnitType(unit)});
                end, showMain);
                break;
            end
        end
    end
end


--#endregion Input territory validatition
--#region Exchange resources windows


function exchangeResourcesWindow()
    DestroyWindow();
    SetWindow("ExchangeResourcesWindow")

    updateHomeButtons(void, showMain, TODO);

    local bankExchangeRates = getExchangeRateOfPlayer(Mod.PlayerGameData.Modifiers);

    CreateLabel(root).SetText("Your default exchange rates are:").SetColor(colors.TextColor);
    for res, rate in ipairs(bankExchangeRates) do
        local line = CreateHorz(root);
        CreateLabel(line).SetText(getResourceName(res)).SetColor(colors.TextColor);
        CreateButton(line).SetText(rate .. " to 1").SetColor(getResourceColor(res)).SetOnClick(function() exchangeWithBank(res, rate); end).SetInteractable(Resources[res] >= rate);
    end

    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
end

function exchangeWithBank(res, rate)
    DestroyWindow();
    SetWindow("exchangeWithBank");

    
    ExchangeWithBank = ExchangeWithBank or {
        Count = 0,
        ExchangeResourceFrom = res,
        ExchangeResourceInto = res,
        Rate = rate,
    }
    
    CreateLabel(root).SetText("Exchanging " .. getResourceName(ExchangeWithBank.ExchangeResourceFrom) .. " with the bank").SetColor(colors.TextColor);
    local resButton = CreateButton(root).SetText(setButtonTextOfResourceSelection(ExchangeWithBank.ExchangeResourceFrom, ExchangeWithBank.ExchangeResourceInto)).SetColor(getResourceColor(ExchangeWithBank.ExchangeResourceInto))
    local countNumInput = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(math.floor(Resources[ExchangeWithBank.ExchangeResourceFrom] / ExchangeWithBank.Rate)).SetValue(ExchangeWithBank.Count);
    resButton.SetOnClick(function()
        ExchangeWithBank.Count = countNumInput.GetValue();
        selectResourceWindow({ExchangeWithBank.ExchangeResourceFrom}); 
    end);

    local reset = function()
        ExchangeWithBank.Count = countNumInput.GetValue();
        ExchangeWithBank = nil;
    end

    updateHomeButtons(reset, function()
        reset();
        exchangeResourcesWindow();
    end, TODO);
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    local line = CreateHorz(root);
    CreateButton(line).SetText("Exchange").SetColor(colors.Green).SetOnClick(function()
        ExchangeWithBank.Count = countNumInput.GetValue();
        if ExchangeWithBank.ExchangeResourceFrom == ExchangeWithBank.ExchangeResourceInto then
            UI.Alert("You must select a resource to exchange your " .. getResourceName(ExchangeWithBank.ExchangeResourceFrom) .. " into");
            return;
        end
        if ExchangeWithBank.Count <= 0 then
            UI.Alert("You can only create a exchange order if you actually exchange stuff");
            return;
        end
        Game.SendGameCustomMessage("Exchanging resources", mergeTables(ExchangeWithBank, {Command = "ExchangeOwnResources"}), serverCallback)
        ExchangeWithBank = nil;
        waitWindow();
    end);
    CreateButton(line).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(function()
        reset();
        exchangeResourcesWindow();
    end);
end

function selectResourceWindow(exc)
    DestroyWindow();
    SetWindow("selectResourceWindow");

    updateHomeButtons(void, exchangeWithBank, TODO);

    CreateLabel(root).SetText("Select one of the following resources").SetColor(colors.TextColor);
    for _, res in ipairs(Catan.Resources) do
        if not valueInTable(exc, res) then
            CreateButton(root).SetText(getResourceName(res)).SetColor(getResourceColor(res)).SetOnClick(function()
                ExchangeWithBank.ExchangeResourceInto = res;
                exchangeWithBank();
            end);
        end
    end

    CreateEmpty(root).SetPreferredHeight(5);

    CreateButton(root).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(exchangeWithBank);
end


--#endregion Exchange resources windows
--#region Territory selecting functions

function selectTerritory(callback, message)
    CancelClickIntercept = false;
    
    DestroyWindow();
    SetWindow("selectTerritory");
    
    updateHomeButtons(void, showMain, TODO);

    message = message or "Click a territory to select it"

    CreateLabel(root).SetText(message).SetColor(colors.TextColor);
    CreateLabel(root).SetText("You can move this window out of the way if necessary").SetColor(colors.TextColor);

    UI.InterceptNextTerritoryClick(function(t) 
        if TripleTerrClickInterceptor then
            TripleTerrClickInterceptor(Game, t);
        end
        callback(t);
    end);

    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
end

function selectTerritoryWithAlerts(callback, message)
    CancelClickIntercept = false;
    if message then
        UI.Alert(message);
    end
    UI.InterceptNextTerritoryClick(function(t) 
        if TripleTerrClickInterceptor then
            TripleTerrClickInterceptor(Game, t);
        end
        callback(t);
    end);
end


--#endregion Territory selecting functions
--#region Tech tree functions


function showAllTechTrees()
    showTechTree(Mod.PlayerGameData.ResearchTrees[Catan.TechTrees.UnitTechTree], Catan.TechTrees.UnitTechTree);
end

function showTechTree(tree, techTreeID)
    DestroyWindow()
    SetWindow("ShowUnitTechTree");

    updateHomeButtons(void, function()
        showAllTechTrees();
    end, TODO);

    CreateButton(root).SetText("Show full research tree").SetColor(colors.Blue).SetOnClick(function()
        Game.CreateDialog(function(a, b, c, d, e)
            showCompleteTechTree(a, b, c, d, e, tree, {Tree = tree, TechTreeID = techTreeID});
        end);
    end)

    CreateLabel(root).SetText(tree.Name).SetColor(colors.TextColor);
    CreateLabel(root).SetText(tree.NumResearched .. "/" .. tree.TotalResearchNodes).SetColor(colors.TextColor);
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    local researches = {};
    local loopResearches = {};
    local allResearches = {};
    showAllAvailableResearches(tree.Node, allResearches, {Tree = tree, Nodes = {}, TechTreeID = techTreeID});
    for _, pair in ipairs(allResearches) do
        if pair.Path.IsInLoop then
            table.insert(loopResearches, pair);
        else
            table.insert(researches, pair);
        end
    end

    researches = table.sort(researches, compareTwoResearchCosts);
    loopResearches = table.sort(loopResearches, compareTwoResearchCosts);

    CreateLabel(root).SetText("Researches").SetColor(colors.TextColor);
    for _, pair in ipairs(researches) do
        CreateButton(root).SetText(getTechName(Settings, pair.Research.Type) .. " " .. getRomanNumber(pair.Research.ResearchOccurance)).SetColor(colors.Blue).SetOnClick(function()
            showResearch(pair.Research, pair.Path);
        end)
    end

    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateLabel(root).SetText("Researches in loops").SetColor(colors.TextColor);
    for _, pair in ipairs(loopResearches) do
        CreateButton(root).SetText(getTechName(Settings, pair.Research.Type) .. " " .. getRomanNumber(pair.Research.ResearchOccurance)).SetColor(colors.Blue).SetOnClick(function()
            showResearch(pair.Research, pair.Path);
        end)
    end
end

function showAllAvailableResearches(node, list, path)
    if node.IsResearch then
        if node.Unlocked and not node.Researched then
            table.insert(list, {Research = node, Path = path});
        end
    else
        if node.Unlocked then
            for i, child in ipairs(node.Nodes) do
                local newPath = {Tree = path.Tree, Nodes = copyTable(path.Nodes), TechTreeID = path.TechTreeID, IsInLoop = path.IsInLoop};
                table.insert(newPath.Nodes, i);
                if node.IsLoop then 
                    newPath.IsInLoop = true; 
                end
                showAllAvailableResearches(child, list, newPath);
            end
        end
    end
end

function showCompleteTechTree(rootParent, setMaxSize, setScrollable, game, close, tree, treeData)
    setMaxSize(2000, 1500);
    setScrollable(true, true);

    local win = GetCurrentWindow();
    SetWindow("TEMP");
    
    local root = CreateVert(rootParent).SetFlexibleWidth(1);
    CreateLabel(root).SetText(tree.Name).SetColor(colors.TextColor);
    
    showTechTreeNodes(tree.Node, treeData, root, close);
    
    SetWindow(win);
end

function showTechTreeNodes(treeNode, path, parent, close, lastColor)
    local color;
    if lastColor == nil then
        color = colors["Smoky Black"];
    elseif lastColor == colors.Aqua then
        color = colors.Tan;
    else
        color = colors.Aqua;
    end

    local nodesRoot;
    if treeNode.Mode == "Parallel" then
        local but = CreateButton(parent).SetText("").SetColor(color).SetInteractable(false);
        nodesRoot = CreateVert(but).SetFlexibleWidth(1);
    else
        local but = CreateButton(parent).SetText("").SetColor(color).SetInteractable(false);
        nodesRoot = CreateHorz(but).SetFlexibleWidth(1);
    end

    if treeNode.IsLoop then
        CreateLabel(nodesRoot).SetText("Loop: ").SetColor(colors.TextColor);
    end
    path.Nodes = path.Nodes or {};
    for i, node in ipairs(treeNode.Nodes) do
        local line = CreateHorz(nodesRoot);
        CreateEmpty(line).SetPreferredWidth(5);
        if node.IsResearch then
            CreateButton(line).SetText(getTechName(Settings, node.Type) .. " " .. getRomanNumber(node.ResearchOccurance)).SetColor(getResearchColor(node)).SetOnClick(function()
                table.insert(path.Nodes, i);
                close();
                if UI.IsDestroyed(root) then
                    Game.CreateDialog(function(a, b, c, d, e)
                        Client_PresentMenuUI(a, b, c, d, e, function() 
                            showResearch(node, path);
                        end);
                    end)
                else
                    showResearch(node, path);
                end
            end);
        else
            local newPath = {Tree = path.Tree, Nodes = copyTable(path.Nodes), TechTreeID = path.TechTreeID, IsInLoop = path.IsInLoop};
            table.insert(newPath.Nodes, i);
            if node.IsLoop then newPath.IsInLoop = true; end
            showTechTreeNodes(node, newPath, line, close, color);
        end
        CreateEmpty(line).SetPreferredWidth(5);
    end
end

function showResearch(research, path)
    DestroyWindow()
    SetWindow("ShowResearch")

    updateHomeButtons(void, function()
        path.Nodes = {};
        showTechTree(path.Tree, path.TechTreeID);
    end, TODO);

    CreateLabel(root).SetText(getTechName(Settings, research.Type)).SetColor(colors.Tan);
    CreateLabel(root).SetText(getTechDescription(Settings, research.Type)).SetColor(colors.TextColor);

    CreateEmpty(root).SetPreferredHeight(5);

    if not research.Unlocked then
        CreateLabel(root).SetText("You haven't unlocked this research yet").SetColor(colors["Wild Strawberry"]);
        CreateEmpty(root).SetPreferredHeight(5)
    elseif research.Researched then
        CreateLabel(root).SetText("You have researched this research").SetColor(colors.Lime);
    else
        CreateLabel(root).SetText("You can research this research").SetColor(colors.Yellow);
    end
    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateLabel(root).SetText("Cost");
    for res, n in ipairs(research.FixedCost) do
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText(getResourceName(res)).SetColor(getResourceColor(res));
        CreateLabel(line).SetText(": ").SetColor(colors.TextColor);
        CreateLabel(line).SetText(n).SetColor(colors["Royal Blue"]);
    end
    
    CreateEmpty(root).SetPreferredHeight(5)

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Free cost").SetColor(colors.TextColor);
    CreateLabel(line).SetText(": ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(research.FreeCost).SetColor(colors["Royal Blue"]);

    
    if research.Unlocked and not research.Researched then
        CreateEmpty(root).SetPreferredHeight(5);
        CreateButton(root).SetText("Research").SetColor(colors.Green).SetInteractable(canResearchResearch(research)).SetOnClick(function()
            if research.FreeCost > 0 then
                removeLocalResources(research.FixedCost);
                inputFreeResearchCost(research, path)
            else
                Game.SendGameCustomMessage("Researching", {Command = "PurchaseResearch", Path = path, FreeCost = getEmptyResourceTable()}, serverCallback);
                waitWindow();
            end
        end);
    end
end

function inputFreeResearchCost(research, path)
    DestroyWindow();
    SetWindow("inputFreeResearchCost");

    local freeCost = getEmptyResourceTable();
    updateHomeButtons(function()
        addLocalResources(combineRecipes(research.FixedCost, freeCost), true);
        resetAllResourceLabels();
    end, function()
        addLocalResources(combineRecipes(research.FixedCost, freeCost), true);
        resetAllResourceLabels();
        showResearch(research, path);
    end, TODO);

    CreateLabel(root).SetText(getTechName(Settings, research.Type)).SetColor(colors.Tan);
    CreateLabel(root).SetText(getTechDescription(Settings, research.Type)).SetColor(colors.TextColor);

    CreateEmpty(root).SetPreferredHeight(5);
    
    local costRemaining = research.FreeCost;
    local remainingLabel = CreateLabel(root).SetText(research.FreeCost .. " resources remaining").SetColor(colors.TextColor);

    CreateEmpty(root).SetPreferredHeight(5);

    for res, n in ipairs(freeCost) do
        local valueLabel;
        local line = CreateHorz(root);
        CreateButton(line).SetText("-10").SetColor(colors.Red).SetOnClick(function()
            if freeCost[res] == 0 then
                if math.min(costRemaining, Resources[res]) > 0 then
                    addLocalResources(freeCost, true);
                    freeCost[res] = math.min(Resources[res], costRemaining);
                    removeLocalResources(freeCost);
                    costRemaining = costRemaining - freeCost[res];
                end
            else
                local change = math.min(freeCost[res], 10);
                if change > 0 then
                    addLocalResources(freeCost, true);
                    freeCost[res] = freeCost[res] - change;
                    removeLocalResources(freeCost);
                    costRemaining = costRemaining + change;
                end
            end
            valueLabel.SetText(freeCost[res]);
            remainingLabel.SetText(costRemaining .. " resources remaining");
        end);
        CreateButton(line).SetText("-1").SetColor(colors["Orange Red"]).SetOnClick(function()
            if freeCost[res] == 0 then
                if math.min(costRemaining, Resources[res]) > 0 then
                    addLocalResources(freeCost, true);
                    freeCost[res] = math.min(Resources[res], costRemaining);
                    removeLocalResources(freeCost);
                    costRemaining = costRemaining - freeCost[res];
                end
            else
                local change = math.min(freeCost[res], 1);
                if change > 0 then
                    addLocalResources(freeCost, true);
                    freeCost[res] = freeCost[res] - change;
                    removeLocalResources(freeCost);
                    costRemaining = costRemaining + change;
                end
            end
            valueLabel.SetText(freeCost[res]);
            remainingLabel.SetText(costRemaining .. " resources remaining");
        end);
        CreateButton(line).SetText("+1").SetColor(colors.Lime).SetOnClick(function()
            if Resources[res] == 0 or costRemaining == 0 then
                if freeCost[res] > 0 then
                    costRemaining = costRemaining + freeCost[res];
                    addLocalResources(freeCost, true);
                    freeCost[res] = 0;
                    removeLocalResources(freeCost);
                end
            else
                local change = math.min(1, costRemaining);
                if change > 0 then
                    addLocalResources(freeCost, true);
                    freeCost[res] = freeCost[res] + change;
                    removeLocalResources(freeCost);
                    costRemaining = costRemaining - change;
                end
            end
            valueLabel.SetText(freeCost[res]);
            remainingLabel.SetText(costRemaining .. " resources remaining");
        end);
        CreateButton(line).SetText("+10").SetColor(colors.Green).SetOnClick(function()
            if Resources[res] == 0 or costRemaining == 0 then
                if freeCost[res] > 0 then
                    costRemaining = costRemaining + freeCost[res];
                    addLocalResources(freeCost, true);
                    freeCost[res] = 0;
                    removeLocalResources(freeCost);
                end
            else
                local change = math.min(10, costRemaining);
                if change > 0 then
                    addLocalResources(freeCost, true);
                    freeCost[res] = freeCost[res] + change;
                    removeLocalResources(freeCost);
                    costRemaining = costRemaining - change;
                end
            end
            valueLabel.SetText(freeCost[res]);
            remainingLabel.SetText(costRemaining .. " resources remaining");
        end);

        valueLabel = CreateLabel(line).SetText(n).SetColor(colors.Peach);
        CreateLabel(line).SetText(getResourceName(res)).SetColor(getResourceColor(res));
    end

    local line = CreateHorz(root);
    local submitButton = CreateButton(line).SetText("Research").SetColor(colors.Green).SetOnClick(function()
        if countTotalResources(freeCost) == research.FreeCost and costRemaining == 0 then
            Game.SendGameCustomMessage("Researching", {Command = "PurchaseResearch", Path = path, FreeCost = freeCost}, serverCallback);
            resetAllResourceLabels();
            waitWindow();
        end
    end)
end

function createEmptyBasedOnMode(parent, mode)
    if mode == "Parallel" then
        CreateEmpty(parent).SetFlexibleWidth(1);
    else
        CreateEmpty(parent).SetPreferredHeight(20);
    end
end

function getResearchColor(node)
    if node.Researched then
        return colors.Green;
    elseif node.Unlocked then
        return colors.Yellow;
    else
        return colors["Orange Red"];
    end
end


--#endregion Tech tree functions
--#region Resource window logic


function addToGainScore(terrID, isVillage)
    if not resourceWindowIsOpen() then return; end
    local terrRes = getResource(Game.LatestStanding.Territories[terrID]);
    local localBuildOrders = getTerritoryIDs(BuildVillageOrderList);
    local futureVillages = extractBuildVillageTerrIDs(Mod.PlayerGameData);
    local futureBuilds;
    if isVillage then
        futureBuilds = mergeTables(futureVillages, extractBuildArmyCampTerrIDs(Mod.PlayerGameData));
    end
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
                if not (valueInTable(localBuildOrders, connID) or valueInTable(futureBuilds, connID)) then
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
    local futureVillages = extractBuildVillageTerrIDs(Mod.PlayerGameData);
    local futureBuilds;
    if isVillage then
        futureBuilds = mergeTables(futureVillages, extractBuildArmyCampTerrIDs(Mod.PlayerGameData));
    end    for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
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
                if not (valueInTable(localBuildOrders, connID) or valueInTable(futureBuilds, connID)) then
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
    local futureVillages = extractBuildVillageTerrIDs(Mod.PlayerGameData);
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
    local futureVillages = extractBuildVillageTerrIDs(Mod.PlayerGameData);
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

function increaseScoreCost(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in pairs(resources) do
        ExpectedGainsLabels[i].PotentiallyRemoved = ExpectedGainsLabels[i].PotentiallyRemoved + v;
    end
    updateExpectedGainsLabels(Game, true);
end

function decreaseScoreCost(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in pairs(resources) do
        ExpectedGainsLabels[i].PotentiallyRemoved = ExpectedGainsLabels[i].PotentiallyRemoved - v;
    end
    updateExpectedGainsLabels(Game, true);
end

function increaseScoreGain(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in pairs(resources) do
        ExpectedGainsLabels[i].PotentiallyAdded = ExpectedGainsLabels[i].PotentiallyAdded + v;
    end
    updateExpectedGainsLabels(Game, true);
end

function decreaseScoreGain(resources)
    if not resourceWindowIsOpen() then return; end
    for i, v in pairs(resources) do
        ExpectedGainsLabels[i].PotentiallyAdded = ExpectedGainsLabels[i].PotentiallyAdded - v;
    end
    updateExpectedGainsLabels(Game, true);
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


--#endregion Resource window logic
--#region Utility functions


function serverCallback(t)
    print(t.Status .. "\t" .. t.Text);
    if clientIsWaiting() then
        showMain();
    end
end

function showPercentage(submitFunc, returnFunc)
    DestroyWindow();
    SetWindow("PercentagePick");

    updateHomeButtons(void, returnFunc, TODO);

    local numInput = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(100).SetWholeNumbers(false).SetValue(50);

    CreateEmpty(root).SetPreferredHeight(5);

    CreateButton(root).SetText("Continue").SetColor(colors.Green).SetOnClick(function() 
        local input = numInput.GetValue();
        if input <= 0 or input >= 100 then
            UI.Alert("The number must be bigger than 0 and smaller than 100");
            return;
        end
        submitFunc(input / 100);
    end);
    CreateButton(root).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(returnFunc);
end

function pickFromList(list, func, cancelFunc)
    DestroyWindow();
    SetWindow("PickFromList");

    CreateButton(root).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(cancelFunc);

    for _, choice in ipairs(list) do
        CreateButton(root).SetText(choice.Text).SetColor(colors.Teal).SetOnClick(function() func(choice.Selected()) end);
    end
end

function waitWindow(m)
    DestroyWindow();
    SetWindow("WaitWindow");

    m = m or "Please wait until the server responded";

    CreateLabel(root).SetText(m).SetColor(colors.TextColor);

    toggleWaiting();
end

function reopenResourceWindow()
    Game.SendGameCustomMessage("Updating...", {Command = "UpdateClient"}, serverCallback);
end

function getTerritoryIDs(list)
    if list == nil then return {}; end
    local t = {};
    for _, v in pairs(list) do
        if v.ID ~= nil then
            table.insert(t, v.ID);
        elseif v.TerritoryID ~= nil then
            table.insert(t, v.TerritoryID);
        end
    end
    return t;
end

function getStringForButton(s, limit)
    limit = limit or 30;
    if #s > limit then
        return string.sub(s, 1, limit) .. "...";
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

function setButtonTextOfResourceSelection(res1, res2)
    if res1 == res2 then return "Select resource"; end
    return getResourceName(res2);
end

function getTotalUnitCount(units)
    local c = 0;
    for _, n in ipairs(units) do
        c = c + n;
    end
    return c;
end

function createUnitPurchaseString(units)
    local s = "";
    local first = true;
    for type, n in ipairs(units) do
        if n > 0 then
            if first then
                first = false;
                s = n .. " " .. getUnitNameByType(type);
            else
                s = s .. ", " .. n .. " " .. getUnitNameByType(type);
            end
        end
    end
    return s;
end

function returnTerrName(_, name)
    return name;
end

function menuWindowIsOpen()
    return root ~= nil and not UI.IsDestroyed(root);
end

function clientIsWaiting()
    return Waiting;
end

function toggleWaiting()
    Waiting = not Waiting;
end

function canResearchResearch(research)
    if not hasEnoughResources(research.FixedCost, Resources) then
        return false;
    end
    return countTotalResources(combineRecipes(Resources, multiplyRecipe(research.FixedCost, -1))) >= research.FreeCost;
end

function canPurchaseCatanUnits()
    for _, type in pairs(getArmyCampUnits()) do
        if canPurchaseUnit(type) then
            return true;
        end
    end
    return false;
end

function canPurchaseUnit(type)
    return hasUnlockedUnit(Mod.PlayerGameData.Modifiers, type) and hasEnoughResources(getUnitRecipe(Mod.PlayerGameData.Modifiers, type), Resources);
end

function compareTwoResearchCosts(v1, v2)
    return (countTotalResources(v1.Research.FixedCost) + v1.Research.FreeCost) < (countTotalResources(v2.Research.FixedCost) + v2.Research.FreeCost);
end