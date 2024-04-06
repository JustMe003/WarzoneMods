require("Catan")

function Server_AdvanceTurn_Start(game, addNewOrder)
    local standing = game.ServerGame.LatestTurnStanding;

    playerData = Mod.PlayerGameData;
    privateData = Mod.PrivateGameData;
    publicData = Mod.PublicGameData;

    local orders = createTurnOrderList(game.Game.PlayingPlayers, game.ServerGame.CyclicMoveOrder, playerData);
    local commandMap = {
        BuildVillage = addBuildVillageOrder,
        UpgradeVillage = addUpgradeVillageOrder,
        BuildWarriorCamp = addBuildWarriorCampOrder
    }
    
    for i, order in ipairs(orders) do
        commandMap[order.OrderType](game, standing, addNewOrder, order);
    end
    
    local dieValue = throwDice();

    for _, terrID in ipairs(getDieGroup(Mod.PublicGameData, dieValue)) do
        for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
            local terr = standing.Territories[connID];
            if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
                if terr.Structures ~= nil and terr.Structures[Catan.Village] ~= nil and terr.Structures[Catan.Village] > 0 then
                    addNewOrder(WL.GameOrderCustom.Create(terr.OwnerPlayerID, "Recieved " .. terr.Structures[Catan.Village] .. " " .. getResourceNameFromStructure(standing.Territories[terrID]), ""));
                    updatePlayerResource(privateData.PlayerData, terr.OwnerPlayerID, getResource(standing.Territories[terrID]), terr.Structures[Catan.Village]);
                end
            end
        end
    end

    Mod.PrivateGameData = privateData;
    Mod.PublicGameData = publicData;
end

function Server_AdvanceTurn_Order(game, order, orderDetails, skipThisOrder, addNewOrder)
    
end

function Server_AdvanceTurn_End(game, addNewOrder)
    setOrderLists(game.Game.PlayingPlayers, playerData);
    for p, t in pairs(Mod.PrivateGameData.PlayerData) do
        setPlayerResources(playerData, p, t.Resources);
    end
    Mod.PlayerGameData = playerData;
end


function addBuildVillageOrder(game, standing, addNewOrder, order)
    local action = "addBuildVillageOrder";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID"});
    if not bool then 
        print(1);
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        print(2);
        return;
    end
    if standing.Territories[order.TerritoryID].OwnerPlayerID ~= order.PlayerID then 
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't control " .. game.Map.Territories[order.TerritoryID].Name .. " anymore, you cannot build the village", "")); 
        return;
    end
    if terrHasVillage(standing.Territories[order.TerritoryID].Structures) then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Territory " .. game.Map.Territories[order.TerritoryID].Name .. " has a village, you cannot build a village on a territory that already has a village", "")); 
        return;
    end
    if not compareTables(order.Cost, getRecipe(Catan.Recipes.Village)) then
        addNewOrder(createCostDifferenceOrder(order.PlayerID, action));
        return;
    end
    if not hasEnoughResources(getRecipe(Catan.Recipes.Village), privateData.PlayerData[order.PlayerID].Resources) then
        addNewOrder(createInsufficientResourcesOrder(order.PlayerID, action, game.Map.Territories[order.TerritoryID].Name));
        return;
    end
    setToVillage(publicData, order.TerritoryID);
    local mod = WL.TerritoryModification.Create(order.TerritoryID);
    local t = {};
    for _, struct in ipairs(Catan.Structures) do
        t[struct] = 0;
    end
    t[Catan.Village] = 1;
    mod.SetStructuresOpt = t;
    local event = WL.GameOrderEvent.Create(order.PlayerID, "Build village on " .. game.Map.Territories[order.TerritoryID].Name, {}, {mod});
    setActionWindow(event, game.Map.Territories[order.TerritoryID]);
    addNewOrder(event);
    removePlayerResources(privateData.PlayerData, order.PlayerID, order.Cost);
end

function addUpgradeVillageOrder(game, standing, addNewOrder, order)
    local action = "addUpgradeVillageOrder";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID", "Level"});
    if not bool then 
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        return;
    end
    local terr = standing.Territories[order.TerritoryID];
    if terr.OwnerPlayerID ~= order.PlayerID then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't control " .. game.Map.Territories[order.TerritoryID].Name .. " anymore, you cannot build the village", "")); 
        return;
    end
    if not terrHasVillage(terr.Structures) then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Territory " .. game.Map.Territories[order.TerritoryID].Name .. " does not have a village, you cannot upgrade village if there isn't one", "")); 
        return;
    end
    if order.Level ~= terr.Structures[Catan.Village] then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "The order does not match with the level of the village on territory " .. game.Map.Territories[order.TerritoryID].Name, ""));
        return;
    end
    if not compareTables(order.Cost, getRecipeLevel(getRecipe(Catan.Recipes.UpgradeVillage), order.Level)) then
        addNewOrder(createCostDifferenceOrder(order.PlayerID, action));
        return;
    end
    if not hasEnoughResources(order.Cost, privateData.PlayerData[order.PlayerID].Resources) then
        addNewOrder(createInsufficientResourcesOrder(order.PlayerID, action, game.Map.Territories[order.TerritoryID].Name));
        return;
    end
    local mod = WL.TerritoryModification.Create(order.TerritoryID);
    mod.AddStructuresOpt = {[Catan.Village] = 1};
    local event = WL.GameOrderEvent.Create(order.PlayerID, "Upgrade village on " .. game.Map.Territories[order.TerritoryID].Name, {}, {mod});
    setActionWindow(event, game.Map.Territories[order.TerritoryID]);
    addNewOrder(event);
    removePlayerResources(privateData.PlayerData, order.PlayerID, order.Cost);
end

function addBuildWarriorCampOrder(game, standing, addNewOrder, order)
    local action = "addBuildWarriorCampOrder";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID"});
    if not bool then 
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        return;
    end
    local terr = standing.Territories[order.TerritoryID];
    if terr.OwnerPlayerID ~= order.PlayerID then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't control " .. game.Map.Territories[order.TerritoryID].Name .. " anymore, you cannot build the village", "")); 
        return;
    end
    if terrHasWarriorCamp(terr.Structures) then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, game.Map.Territories[order.TerritoryID] .. " already has a warrior camp. You cannot build a warrior camp if there is already a warrior camp", ""));
        return;
    end
    if not hasEnoughResources(order.Cost, privateData.PlayerData[order.PlayerID].Resources) then
        addNewOrder(createInsufficientResourcesOrder(order.PlayerID, action, game.Map.Territories[order.TerritoryID].Name));
        return;
    end
    setToWarriorCamp(publicData, order.TerritoryID);
    local mod = WL.TerritoryModification.Create(order.TerritoryID);
    local t = {};
    for _, struct in ipairs(Catan.Structures) do
        t[struct] = 0;
    end
    t[Catan.WarriorCamp] = 1;
    mod.SetStructuresOpt = t;
    local event = WL.GameOrderEvent.Create(order.PlayerID, "Build warrior camp on " .. game.Map.Territories[order.TerritoryID].Name, {}, {mod});
    setActionWindow(event, game.Map.Territories[order.TerritoryID]);
    addNewOrder(event);
    removePlayerResources(privateData.PlayerData, order.PlayerID, order.Cost);
end

function createMissingFieldOrder(playerID, action, field)
    return WL.GameOrderCustom.Create(playerID, "Something went wrong (" .. field .." was Nil in function '" .. action .. "')", "");
end

function createCostDifferenceOrder(playerID, action)
    return WL.GameOrderCustom.Create(playerID, "The cost was modified, hence the order has been discarded ( '" .. action .. "')", "");
end

function createInsufficientResourcesOrder(playerID, action, name)
    return WL.GameOrderCustom.Create(playerID, "You don't have enough resources for the action " .. action .. " on territory " .. name, "");
end

function setActionWindow(event, mapTerr)
    event.JumpToActionSpotOpt = WL.RectangleVM.Create(mapTerr.MiddlePointX, mapTerr.MiddlePointY, mapTerr.MiddlePointX, mapTerr.MiddlePointY)
end