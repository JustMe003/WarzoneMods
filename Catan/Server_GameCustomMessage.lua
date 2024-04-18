require("Catan");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    publicGameData = Mod.PublicGameData;
    playerGameData = Mod.PlayerGameData;
    standing = game.ServerGame.LatestTurnStanding;

	local commandHandler = {
        UpdateClient = function(_, _, _, s) returnSuccess(s, "Updated client"); end,
        BuildVillage = buildVillage,
        BuildMultipleVillages = buildMultipleVillages,
        UpgradeVillage = upgradeVillage,
        UpgradeMultipleVillages = upgradeMultipleVillages,
        BuildArmyCamp = buildArmyCamp,
        BuildMultipleArmyCamps = buildMultipleArmyCamps,
        PurchaseUnits = purchaseUnits,
        PurchaseMultipleUnits = purchaseMultipleUnits,
        ModifyUnitPurchaseOrder = modifyUnitPurchaseOrder;
        SplitMultipleUnits = addMultipleSplitUnitOrders,
        SplitUnit = addSplitUnitOrder,
        DeleteOrders = deleteOrders,
        ExchangeOwnResources = exchangeOwnResources,
        PurchaseResearch = purchaseResearch,

    }
    if payload.Command == nil then
        returnError(setReturn, "No command given");
        return;
    end
    commandHandler[payload.Command](game, playerID, payload, setReturn);
    
    Mod.PlayerGameData = playerGameData;
    Mod.PublicGameData = publicGameData;
end

function buildVillage(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID"});
    if not bool then
        returnError(setReturn, field .. " was nil while building village");
        return false;
    end
    local terr = standing.Territories[payload.TerritoryID];
    if terrHasVillage(terr.Structures) or (playerGameData[playerID].Orderlist and retrieveOrder(playerGameData[playerID].OrderList, getBuildVillageEnum(), payload.TerritoryID)) then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, "BuildVillage");
    end
    if terr.OwnerPlayerID == playerID then
        if hasEnoughResources(getRecipe(Catan.Recipes.Village), playerGameData[playerID].Resources) then
            local order = createBuildVillageOrder(playerID, payload.TerritoryID);
            addOrderToOrderList(playerGameData[playerID].OrderList, order);
            removePlayerResources(playerGameData, playerID, order.Cost);
            returnSuccess(setReturn, "Build village order created", {Order = order});
            return true;
        else
            returnInsufficientResources(setReturn, "BuildVillage");
            return false;
        end
    else
        returnFail(setReturn, "Owner was not the same as invoker while building village");
        return false;
    end
end

function buildMultipleVillages(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryIDs"});
    if not bool then
        returnError(setReturn, field .. " was nil while building multiple villages");
        return false;
    end
    for _, terrID in ipairs(payload.TerritoryIDs) do
        if not buildVillage(game, playerID, {TerritoryID = terrID}, setReturn) then
            break;
        end
    end
end

function upgradeVillage(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID"});
    if not bool then
        returnError(setReturn, field .. " was nil while upgrading village");
        return false;
    end
    local terr = standing.Territories[payload.TerritoryID];
    if not terrHasVillage(terr.Structures) or (playerGameData[playerID].OrderList and retrieveOrder(playerGameData[playerID].OrderList, getUpgradeVillageEnum(), payload.TerritoryID)) then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, "UpgradeVillage");
        return false;
    end
    if terr.OwnerPlayerID == playerID then
        if hasEnoughResources(getRecipeLevel(getRecipe(Catan.Recipes.UpgradeVillage), terr.Structures[Catan.Village]), playerGameData[playerID].Resources) then
            local order = createUpgradeVillageOrder(playerID, payload.TerritoryID, terr.Structures[Catan.Village]);
            addOrderToOrderList(playerGameData[playerID].OrderList, order);
            removePlayerResources(playerGameData, playerID, order.Cost);
            returnSuccess(setReturn, "Upgrade village order created", {Order = order});
            return true;
        else
            returnInsufficientResources(setReturn, "upgradeVillage");
            return false;
        end
    else
        returnError(setReturn, "Owner was not the same as invoker while upgrading village");
        return false;
    end
end

function upgradeMultipleVillages(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryIDs"});
    if not bool then
        returnError(setReturn, field .. " was nil while upgrading village");
        return false;
    end
    for _, terrID in ipairs(payload.TerritoryIDs) do
        if not upgradeVillage(game, playerID, {TerritoryID = terrID}, setReturn) then
            break;
        end
    end
end

function buildArmyCamp(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID"});
    if not bool then
        returnError(setReturn, field .. " was nil while building army camp");
        return false;
    end
    local terr = standing.Territories[payload.TerritoryID];
    if terrHasArmyCamp(terr.Structures) then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, "BuildArmyCamp");
        return false;
    end
    if terr.OwnerPlayerID == playerID then
        if hasEnoughResources(getRecipe(Catan.Recipes.ArmyCamp), playerGameData[playerID].Resources) then
            local order = createBuildArmyCampOrder(playerID, payload.TerritoryID);
            addOrderToOrderList(playerGameData[playerID].OrderList, order);
            removePlayerResources(playerGameData, playerID, order.Cost);
            returnSuccess(setReturn, "Build army camp order created", {Order = order});
            return true;
        else
            returnInsufficientResources(setReturn, "BuildArmyCamp");
            return false;
        end
    else
        returnError(setReturn, "Owner was not the same as invoker while building army camp");
        return false;
    end
end

function buildMultipleArmyCamps(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryIDs"});
    if not bool then
        returnError(setReturn, field .. " was nil while upgrading village");
        return false;
    end
    for _, terrID in ipairs(payload.TerritoryIDs) do
        if not buildArmyCamp(game, playerID, {TerritoryID = terrID}, setReturn) then
            break;
        end
    end
end

function purchaseUnits(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID", "Units", "Cost"});
    local action = "purchase units";
    if not bool then
        returnError(setReturn, field .. " was nil during action " .. action);
        return false;
    end
    
    local terr = standing.Territories[payload.TerritoryID];
    if terr.OwnerPlayerID ~= playerID then
        returnInvalidOwner(setReturn, action);
        return false;
    end

    if not terrHasArmyCamp(terr.Structures) then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, action);
        return false;
    end

    print("TODO: Check whether all units in purchase order are available to player");

    local cost = getEmptyResourceTable();
    for unit, n in ipairs(payload.Units) do
        cost = combineRecipes(cost, multiplyRecipe(getUnitRecipe(playerGameData[playerID].Modifiers, unit), n));
    end

    if not compareTables(cost, payload.Cost) then
        returnFail(setReturn, "Cost of order was invalid");
        return false;
    end

    if not hasEnoughResources(cost, playerGameData[playerID].Resources) then
        returnInsufficientResources(setReturn, action);
        return false;
    end

    local order = createPurchaseUnitsOrder(playerID, payload.TerritoryID, payload.Units, cost);
    addOrderToOrderList(playerGameData[playerID].OrderList, order);
    removePlayerResources(playerGameData, playerID, cost);
    returnSuccess(setReturn, "Successfully purchased new units", {Order = order});
    return true;
end

function purchaseMultipleUnits(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"Orders"});
    local action = "purchase units";
    if not bool then
        returnError(setReturn, field .. " was nil during action " .. action);
        return false;
    end
    for _, order in ipairs(payload.Orders) do
        if not purchaseUnits(game, playerID, order, setReturn) then
            return false;
        end
    end
    return true;
end

function addSplitUnitOrder(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID", "SplitPercentage", "UnitType"});
    local action = "split unit stack";
    if not bool then
        returnError(setReturn, field .. " was nil during action " .. action);
        return false;
    end

    local terr = game.ServerGame.LatestTurnStanding.Territories[payload.TerritoryID];
    if terr.OwnerPlayerID ~= playerID then
        returnInvalidOwner(setReturn, action);
        return false;
    end

    if payload.SplitPercentage >= 1 or payload.SplitPercentage <= 0 then
        returnFail(setReturn, "Split percentage cannot be higher than 1 or lower than 0");
        return false;
    end
    
    if #terr.NumArmies.SpecialUnits <= 0 then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, action);
        return false;
    end

    for _, unit in ipairs(terr.NumArmies.SpecialUnits) do
        if unit.proxyType == "CustomSpecialUnit" and isCatanUnit(unit) and getUnitType(unit) == payload.UnitType then
            local order = createSplitUnitOrder(playerID, payload.TerritoryID, payload.SplitPercentage, payload.UnitType);
            addOrderToOrderList(playerGameData[playerID].OrderList, order);
            returnSuccess(setReturn, "Successfully added unit split orders", {Order = order});
            return true;
        end
    end

    returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, action);
    return false;
end

function modifyUnitPurchaseOrder(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"OrderIndex", "NewOrder"});
    if not bool then
        returnError(setReturn, field .. " was nil while upgrading village");
        return false;
    end

    local oldOrder = playerGameData[playerID].OrderList[payload.OrderIndex];
    if oldOrder.OrderType ~= getPurchaseUnitEnum() then
        returnError(setReturn, "Order index pointed to an order of the wrong type");
        return false;
    end

    local costDifference = combineRecipes(multiplyRecipe(oldOrder.Cost, -1), payload.NewOrder.Cost);

    if not hasEnoughResources(costDifference, playerGameData[playerID].Resources) then
        returnInsufficientResources(setReturn, "Modify unit purchase order");
        return false;
    end

    addPlayerResources(playerGameData, playerID, oldOrder.Cost);
    table.remove(playerGameData[playerID].OrderList, payload.OrderIndex);
    return purchaseUnits(game, playerID, payload.NewOrder, setReturn);
end

function addMultipleSplitUnitOrders(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"Details"});
    if not bool then
        returnError(setReturn, field .. " was nil while upgrading village");
        return false;
    end
    for _, details in ipairs(payload.Details) do
        addSplitUnitOrder(game, playerID, details, setReturn);
    end
end

function deleteOrders(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"OrderIndexes"});
    if not bool then
        returnError(setReturn, field .. " was nil while building army camp");
        return false;
    end
    local t = table.sort(payload.OrderIndexes, function(v, v2) return v > v2; end);
    local exchangeResourceEnum = getExchangeResourcesWithBankEnum();
    for _, k in ipairs(t) do
        local order = playerGameData[playerID].OrderList[k];
        addPlayerResources(playerGameData, playerID, order.Cost);
        if order.OrderType == exchangeResourceEnum then
            removePlayerResources(playerGameData, playerID, order.Gain);
        end
        table.remove(playerGameData[playerID].OrderList, k);
    end
    returnSuccess(setReturn, "Successfully deleted orders", {});
end

function exchangeOwnResources(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"ExchangeResourceFrom", "ExchangeResourceInto", "Count"});
    if not bool then
        returnError(setReturn, field .. " was nil while exchanging resources");
        return false;
    end
    local exchangeRate = getExchangeRateOfPlayer(playerGameData[playerID].Modifiers)[payload.ExchangeResourceFrom];
    local resources = playerGameData[playerID].Resources;
    if exchangeRate * payload.Count <= resources[payload.ExchangeResourceFrom] then
        -- Has enough resources
        local t = getEmptyResourceTable()
        t[payload.ExchangeResourceFrom] = exchangeRate * payload.Count;
        removePlayerResources(playerGameData, playerID, t);
        t = getEmptyResourceTable();
        t[payload.ExchangeResourceInto] = payload.Count;
        addPlayerResources(playerGameData, playerID, t);
        
        local order = createResourceExchangeWithBankOrder(playerGameData[playerID].Modifiers, playerID, payload.ExchangeResourceFrom, payload.ExchangeResourceInto, payload.Count);
        addOrderToOrderList(playerGameData[playerID].OrderList, order);
        
        returnSuccess(setReturn, "Successfully exchanged resources", {Order = order});
        return true;
    end
    returnInsufficientResources(setReturn, "exchangeOwnResources");
    return false;
end

function purchaseResearch(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"Path", "FreeCost"});
    if not bool then
        returnError(setReturn, field .. " was nil while purchasing research");
        return false;
    end

    bool, field = tableHasFields(payload.Path, {"TechTreeID", "Nodes"});
    if not bool then
        returnError(setReturn, field .. " was nil while purchasing research");
        return false;
    end

    local tree = playerGameData[playerID].ResearchTrees[payload.Path.TechTreeID];
    if tree == nil then
        returnError(setReturn, "Tree was nil when trying to research");
        return false;
    end

    local node = tree.Node;
    for _, index in ipairs(payload.Path.Nodes) do
        if not node.Unlocked then
            returnError(setReturn, "Node was not unlocked. TreeID: " .. payload.Path.TechTreeID .. " Nodes: " .. table.concat(payload.Path.Nodes, ", "));
            return false;
        end
        if node.IsResearch then
            returnError(setReturn, "Ended up at a research without fully traversing the tree. TreeID: " .. payload.Path.TechTreeID .. " Nodes: " .. table.concat(payload.Path.Nodes, ", "));
            return false;
        end
        node = node.Nodes[index];
        if node == nil then
            returnError(setReturn, "Found a nill node, could not fully traverse the tree. TreeID: " .. payload.Path.TechTreeID .. " Nodes: " .. table.concat(payload.Path.Nodes, ", "));
            return false;    
        end
    end
    
    if not node.IsResearch then
        returnError(setReturn, "Did not ended up at a research while fully traversed the tree. TreeID: " .. payload.Path.TechTreeID .. " Nodes: " .. table.concat(payload.Path.Nodes, ", "));
        return false;
    end

    if node.Researched then
        returnError(setReturn, "Node was already researched. TreeID: " .. payload.Path.TechTreeID .. " Nodes: " .. table.concat(payload.Path.Nodes, ", "));
        return false;
    end

    if node.FreeCost ~= countTotalResources(payload.FreeCost) then
        returnError(setReturn, "Research details are not the same");
        return false;
    end

    local totalCost = combineRecipes(node.FixedCost, payload.FreeCost)
    if not hasEnoughResources(totalCost, playerGameData[playerID].Resources) then
        returnInsufficientResources(setReturn, "Purchase research");
        return false;
    end


    removePlayerResources(playerGameData, playerID, totalCost);
    researchNode(tree, node, payload.Path.IsInLoop or false);

    performTech(Mod.Settings.Config, playerGameData, playerID, node.Type);

    local privateData = Mod.PrivateGameData;
    removePlayerResources(privateData.PlayerData, playerID, totalCost);
    Mod.PrivateGameData = privateData;

    returnSuccess(setReturn, "Successfully researched research!", {Research = node});
end

function returnSuccess(setReturn, message, data)
    setReturn({
        Status = "Pass",
        Text = message,
        Data = data
    });
end

function returnFail(setReturn, message)
    setReturn({
        Status = "Fail",
        Text = message
    });
end

function returnError(setReturn, message)
    setReturn({
        Status = "Error",
        Text = message
    });
end

function returnInsufficientResources(setReturn, action)
    setReturn({
        Status = "InsufficientRecources",
        Text = "Player has insufficient resources for action " .. action
    });
end

function returnInvalidOwner(setReturn, action)
    setReturn({
        Status = "Fail",
        Text = "Territory had a different owner for action " .. action
    });
end

function returnInvalidTerritory(setReturn, terr, action)
    setReturn({
        Status = "InvalidTerritoryState",
        Text = "Territory " .. terr .. " had an invalid state for action " .. action
    });
end