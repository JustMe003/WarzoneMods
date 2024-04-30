require("Catan")

local CatanReceiveResourcesOrder = "Catan_JAD_RecRes"

function Server_AdvanceTurn_Start(game, addNewOrder)
    local standing = game.ServerGame.LatestTurnStanding;

    playerData = Mod.PlayerGameData;
    privateData = Mod.PrivateGameData;
    publicData = Mod.PublicGameData;

    Server_AdvanceTurn_UpdateUnits(game, addNewOrder);

    local dieValues = {};
    for _ = 1, 2 do
        table.insert(dieValues, throwDice());
    end
    
        for p, _ in pairs(game.Game.PlayingPlayers) do
            updatePassiveResourceGeneration(playerData[p].Modifiers, playerData[p].PassiveResourceGeneration);
            local recipe = getEmptyResourceTable();
            for res, n in ipairs(playerData[p].PassiveResourceGeneration) do
                if n >= 1 then
                    recipe[res] = math.floor(n);
                    playerData[p].PassiveResourceGeneration[res] = n - math.floor(n);
                    addNewOrder(WL.GameOrderCustom.Create(p, "Received " .. math.floor(n) .. " " .. getResourceName(res) .. " (passively generated)", CatanReceiveResourcesOrder));
                end
            end
            if countTotalResources(recipe) > 0 then
                addPlayerResources(privateData.PlayerData, p, recipe);
            end
        end

    addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "The die have been rolled! All territory with die value " .. table.concat(dieValues, ", ") .. " will produce resources", nil, {}, {}));

    local resourcesAreDoubled = function(b)
        if b then 
            return " (2x)";
        else
            return "";
        end 
    end

    for _, dieValue in ipairs(dieValues) do
        for _, terrID in ipairs(getDieGroup(publicData, dieValue)) do
            for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
                local terr = standing.Territories[connID];
                if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
                    if terr.Structures ~= nil and terr.Structures[Catan.Village] ~= nil and terr.Structures[Catan.Village] > 0 then
                        local numRes = getNumberOfVillages(terr.Structures);
                        local res = getResource(standing.Territories[terrID]);
                        local b = false;
                        if math.random() < getResourceDoubleModifiers(playerData[terr.OwnerPlayerID].Modifiers)[res] then
                            numRes = numRes * 2;
                            b = true;
                        end
                        addNewOrder(WL.GameOrderCustom.Create(terr.OwnerPlayerID, "Recieved " .. numRes .. " " .. getResourceName(res) .. resourcesAreDoubled(b), CatanReceiveResourcesOrder));
                        updatePlayerResource(privateData.PlayerData, terr.OwnerPlayerID, getResource(standing.Territories[terrID]), numRes);
                    end
                end
            end
        end
    end
    
    local orders = createTurnOrderList(game.Game.PlayingPlayers, game.ServerGame.CyclicMoveOrder, playerData);
    local commandMap = {
        [Catan.OrderType.ExchangeResourceWithBank] = exchangeResourcesWithBank,
        [Catan.OrderType.BuildVillage] = addBuildVillageOrder,
        [Catan.OrderType.UpgradeVillage] = addUpgradeVillageOrder,
        [Catan.OrderType.BuildArmyCamp] = addBuildArmyCampOrder,
        [Catan.OrderType.PurchaseUnits] = addPurchaseUnitOrder,
        [Catan.OrderType.SplitUnitStack] = addTurnEndOrder,
    }
    
    for i, order in ipairs(orders) do
        commandMap[order.OrderType](game, standing, addNewOrder, order);
    end
    
    Mod.PrivateGameData = privateData;
    Mod.PublicGameData = publicData;
end

function Server_AdvanceTurn_Order(game, order, orderDetails, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderDeploy" then
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
    elseif order.proxyType == "GameOrderCustom" then
        if order.Payload ~= CatanReceiveResourcesOrder then
            skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
        end
        if order.Payload == "Catan_JAD_MergeUnits" then
            Server_AdvanceTurn_MergeUnit(game, addNewOrder);
        elseif order.Payload == "Catan_JAD_TurnEndOrders" then
            Server_AdvanceTurn_TurnEndOrders(game, addNewOrder);
        elseif order.Payload == "Catan_JAD_ResetData" then
            Server_AdvanceTurn_ResetData(game, addNewOrder);
        end
    elseif order.proxyType == "GameOrderAttackTransfer" and orderDetails.IsAttack then
        -- update units
        if not tableIsEmpty(orderDetails.DamageToSpecialUnits) then
            for i, v in pairs(orderDetails.DamageToSpecialUnits) do
                print(v, i);
            end
            local mod = WL.TerritoryModification.Create(order.To);
            if orderDetails.IsSuccessful then
                -- Only have to check attacking armies, defending armies all died
                mod = extractDamagedUnits(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.SpecialUnits, orderDetails.DamageToSpecialUnits, mod);
                if #mod.AddSpecialUnits > 0 then
                    local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, "Updated units", {}, {mod});
                    setActionWindow(event, game.Map.Territories[order.From]);
                    addNewOrder(event, true);
                end
            else
                mod = extractDamagedUnits(game.ServerGame.LatestTurnStanding.Territories[order.To].NumArmies.SpecialUnits, orderDetails.DamageToSpecialUnits, mod);
                if #mod.AddSpecialUnits > 0 then
                    local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID, "Updated units", {}, {mod});
                    setActionWindow(event, game.Map.Territories[order.To]);
                    addNewOrder(event, true);
                end
                if #mod.AddSpecialUnits < getTableLength(orderDetails.DamageToSpecialUnits) then
                    local mod2 = WL.TerritoryModification.Create(order.From);

                    mod2 = extractDamagedUnits(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.SpecialUnits, orderDetails.DamageToSpecialUnits, mod2);
                    
                    local event = WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, "Updated units", {}, {mod2});
                    setActionWindow(event, game.Map.Territories[order.From]);
                    addNewOrder(event, true);
                end
            end
        end
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
    -- inserting GameOrderCustom orders to update the map properly
    local p;
    for i, _ in pairs(game.Game.PlayingPlayers) do
        p = i;
        break;
    end
    if p then
        addNewOrder(WL.GameOrderCustom.Create(p, "Catan Internal Order", "Catan_JAD_MergeUnits"));
        addNewOrder(WL.GameOrderCustom.Create(p, "Catan Internal Order", "Catan_JAD_TurnEndOrders"));
        addNewOrder(WL.GameOrderCustom.Create(p, "Catan Internal Order", "Catan_JAD_ResetData"));
    end
end

function Server_AdvanceTurn_UpdateUnits(game, addNewOrder)
    -- Update all units that need to be updated
    playerData = playerData or Mod.PlayerGameData;
    local t = {};
    local b = false;
    for p, data in pairs(playerData) do
        if data.UpdateUnits then
            b = true
            t[p] = {};
            for type, n in pairs(data.UpdateUnits) do
                t[p][type] = n;
            end
            data.UpdateUnits = nil;
        end
    end
    if b then
        for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
            if #terr.NumArmies.SpecialUnits > 0 and t[terr.OwnerPlayerID] then
                local playerID = terr.OwnerPlayerID;
                for _, unit in ipairs(terr.NumArmies.SpecialUnits) do
                    if unit.proxyType == "CustomSpecialUnit" and isCatanUnit(unit) then
                        local type = getUnitType(unit);
                        if t[playerID][type] then
                            local count = unit.Health / t[playerID][type];
                            local mod = WL.TerritoryModification.Create(terr.ID);
                            mod.RemoveSpecialUnitsOpt = {unit.ID};
                            mod.AddSpecialUnits = {createUnit(playerData[playerID].Modifiers, playerID, type, count)};
                            local event = WL.GameOrderEvent.Create(playerID, "Updated " .. getUnitNameByType(type) .. " unit", {}, {mod});
                            setActionWindow(event, game.Map.Territories[terr.ID]);
                            addNewOrder(event);
                        end
                    end
                end
            end
        end
    end
    Mod.PlayerGameData = playerData;
end

function Server_AdvanceTurn_MergeUnit(game, addNewOrder);
    -- Merge all units that are on the same territory
    for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
        if #terr.NumArmies.SpecialUnits > 1 then
            local playerID = terr.OwnerPlayerID;
            for enum, type in pairs(Catan.UnitType) do
                local units = {};
                for _, unit in ipairs(terr.NumArmies.SpecialUnits) do
                    if unit.proxyType == "CustomSpecialUnit" and isCatanUnit(unit) and getUnitType(unit) == type and unit.OwnerID == playerID then
                        table.insert(units, unit);
                    end
                end
                if #units > 1 then
                    -- There is more than 1 unit
                    local mod = WL.TerritoryModification.Create(terr.ID);
                    local t = {};
                    for _, unit in ipairs(units) do
                        table.insert(t, unit.ID);
                    end
                    mod.RemoveSpecialUnitsOpt = t;
                    mod.AddSpecialUnits = {mergeUnits(units, type, Mod.PlayerGameData[playerID].Modifiers)};
                    local event = WL.GameOrderEvent.Create(playerID, "Merged " .. enum .. " units", {}, {mod});
                    setActionWindow(event, game.Map.Territories[terr.ID]);
                    addNewOrder(event);
                end
            end
        end
    end
end

function Server_AdvanceTurn_TurnEndOrders(game, addNewOrder)
    -- Turn end orders
    if TurnEndOrders then
        publicData = Mod.PublicGameData;
        privateData = Mod.PrivateGameData;

        local standing = game.ServerGame.LatestTurnStanding;

        local commandMap = {
            [Catan.OrderType.SplitUnitStack] = addSplitUnitStackOrder,
        }

        for _, order in ipairs(TurnEndOrders) do
            commandMap[order.OrderType](game, standing, addNewOrder, order);
        end

        Mod.PublicGameData = publicData;
        Mod.PrivateGameData = privateData
    end
end

function Server_AdvanceTurn_ResetData(game, addNewOrder)
    -- Remove all income
    local incomeMods = {};
    for p, _ in pairs(game.Game.PlayingPlayers) do
        table.insert(incomeMods, WL.IncomeMod.Create(p, -100000, "Remove all income"));
    end
    addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Remove all income", nil, {}, {}, incomeMods));
    
    -- Reset the order list of each player
    playerData = playerData or Mod.PlayerGameData;
    setOrderLists(game.Game.PlayingPlayers, playerData);
    for p, t in pairs(Mod.PrivateGameData.PlayerData) do
        setPlayerResources(playerData, p, t.Resources);
    end
    Mod.PlayerGameData = playerData;
end


function extractDamagedUnits(units, damagedUnits, terrMod)
    local add = {};
    local remove = {};
    for unitID, v in pairs(damagedUnits) do
        for _, unit in ipairs(units) do
            if unit.proxyType == "CustomSpecialUnit" and isCatanUnit(unit) and unit.ID == unitID then
                table.insert(remove, unitID);
                table.insert(add, getUnitAfterApplyingDamage(Mod.PlayerGameData[unit.OwnerID].Modifiers, getUnitType(unit), unit, v));
                break;
            end
        end
    end
    terrMod.RemoveSpecialUnitsOpt = remove;
    terrMod.AddSpecialUnits = add;
    return terrMod;
end

function exchangeResourcesWithBank(game, standing, addNewOrder, order)
    local action = "exchangeResourcesWithBank";
    local bool, field = tableHasFields(order, {"Cost", "PlayerID", "Gain", "ExchangeRate"});
    if not bool then 
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        return;
    end
    
    local giveRes;
    local gainRes;
    for res, n in ipairs(order.Cost) do
        if n ~= 0 then
            if giveRes ~= nil then
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Exhange order with bank was misconfigured, skipping order", ""));
                return;
            end
            giveRes = res;
        end
    end

    for res, n in ipairs(order.Gain) do
        if n ~= 0 then
            if gainRes ~= nil then
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Exhange order with bank was misconfigured, skipping order", ""));
                return;
            end
            gainRes = res;
        end
    end


    if order.Cost[giveRes] - (order.Gain[gainRes] * order.ExchangeRate) ~= 0 then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't have enough resources to trade " .. order.Cost[giveRes] .. " " .. getResourceName(giveRes) .. " for " .. order.Gain[gainRes] .. " " .. getResourceName(gainRes), ""));
        return;    
    end

    addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Traded " .. order.Cost[giveRes] .. " " .. getResourceName(giveRes) .. " for " .. order.Gain[gainRes] .. " " .. getResourceName(gainRes), ""));
    removePlayerResources(privateData.PlayerData, order.PlayerID, order.Cost);
    addPlayerResources(privateData.PlayerData, order.PlayerID, order.Gain);
end

function addBuildVillageOrder(game, standing, addNewOrder, order)
    local action = "addBuildVillageOrder";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID"});
    if not bool then 
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
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
    for _, struct in ipairs(Catan.ResourceStructures) do
        t[struct] = 0;
    end
    t[Catan.ArmyCamp] = 0;
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

function addBuildArmyCampOrder(game, standing, addNewOrder, order)
    local action = "addBuildArmyCampOrder";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID"});
    if not bool then
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        return;
    end

    local terr = standing.Territories[order.TerritoryID];
    if terr.OwnerPlayerID ~= order.PlayerID then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't control " .. game.Map.Territories[order.TerritoryID].Name .. " anymore, you cannot build the army camp", "")); 
        return;
    end
    if terrHasArmyCamp(terr.Structures) then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, game.Map.Territories[order.TerritoryID] .. " already has a army camp. You cannot build a army camp if there is already a army camp", ""));
        return;
    end
    if not hasEnoughResources(order.Cost, privateData.PlayerData[order.PlayerID].Resources) then
        addNewOrder(createInsufficientResourcesOrder(order.PlayerID, action, game.Map.Territories[order.TerritoryID].Name));
        return;
    end

    setToArmyCamp(publicData, order.TerritoryID);
    local mod = WL.TerritoryModification.Create(order.TerritoryID);
    local t = {};
    for _, struct in ipairs(Catan.ResourceStructures) do
        t[struct] = 0;
    end
    t[Catan.Village] = 0;      -- In case there is a village on this territory
    t[Catan.ArmyCamp] = 1;
    mod.SetStructuresOpt = t;
    local event = WL.GameOrderEvent.Create(order.PlayerID, "Build army camp on " .. game.Map.Territories[order.TerritoryID].Name, {}, {mod});
    setActionWindow(event, game.Map.Territories[order.TerritoryID]);
    addNewOrder(event);
    removePlayerResources(privateData.PlayerData, order.PlayerID, order.Cost);
end

function addPurchaseUnitOrder(game, standing, addNewOrder, order)
    local action = "purchaseUnitsOrder";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID", "Units"});
    if not bool then
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        return;
    end

    local terr = standing.Territories[order.TerritoryID];
    if terr.OwnerPlayerID ~= order.PlayerID then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't control " .. game.Map.Territories[order.TerritoryID].Name .. " anymore, you cannot build the village", "")); 
        return;
    end

    if not terrHasArmyCamp(terr.Structures) then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, game.Map.Territories[order.TerritoryID].Name .. " does not have an army camp, an army camp is required to purchase units", "")); 
        return;
    end

    print("TODO: Check whether all units have been unlocked by the player")

    local cost = getEmptyResourceTable();
    for unit, n in ipairs(order.Units) do
        cost = combineRecipes(cost, multiplyRecipe(getUnitRecipe(playerData[order.PlayerID].Modifiers, unit), n));
    end
    if not compareTables(cost, order.Cost) then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "The cost of " .. action .. " is incorrect, skipping order", ""));
        return;
    end

    if not hasEnoughResources(cost, privateData.PlayerData[order.PlayerID].Resources) then
        addNewOrder(createInsufficientResourcesOrder(order.PlayerID, action, game.Map.Territories[order.TerritoryID].Name));
        return false;
    end

    local mod = WL.TerritoryModification.Create(order.TerritoryID);
    local units = {};
    for unit, n in ipairs(order.Units) do
        if n > 0 then
            table.insert(units, createUnit(playerData[order.PlayerID].Modifiers, order.PlayerID, unit, n));
        end
    end
    mod.AddSpecialUnits = units;
    local event = WL.GameOrderEvent.Create(order.PlayerID, "Purchasing units on " .. game.Map.Territories[order.TerritoryID].Name, {}, {mod});
    setActionWindow(event, game.Map.Territories[order.TerritoryID]);
    addNewOrder(event);
    removePlayerResources(privateData.PlayerData, order.PlayerID, cost);
end

function addTurnEndOrder(_, _, _, order)
    TurnEndOrders = TurnEndOrders or {};
    table.insert(TurnEndOrders, order);
end

function addSplitUnitStackOrder(game, standing, addNewOrder, order)
    local action = "splitUnitStack";
    local bool, field = tableHasFields(order, {"TerritoryID", "Cost", "PlayerID", "UnitType", "SplitPercentage"});
    if not bool then
        addNewOrder(createMissingFieldOrder(order.PlayerID, action, field)); 
        return;
    end

    if not hasEnoughResources(order.Cost, privateData.PlayerData[order.PlayerID].Resources) then
        addNewOrder(createInsufficientResourcesOrder(order.PlayerID, action, game.Map.Territories[order.TerritoryID].Name));
        return;
    end

    local terr = standing.Territories[order.TerritoryID];
    if terr.OwnerPlayerID ~= order.PlayerID then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't control " .. game.Map.Territories[order.TerritoryID].Name .. " anymore, you cannot build the army camp", "")); 
        return;
    end

    if order.SplitPercentage >= 1 or order.SplitPercentage <= 0 then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, action .. " order was wrongly configured, skipping order", ""));
        return;
    end

    local unit;
    for _, sp in ipairs(terr.NumArmies.SpecialUnits) do
        if sp.proxyType == "CustomSpecialUnit" and isCatanUnit(sp) and getUnitType(sp) == order.UnitType then 
            unit = sp; 
            break; 
        end
    end
    if unit == nil then
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "There are no " .. tostring(getUnitNameByType(order.UnitType)) .. " units on " .. game.Map.Territories[order.TerritoryID].Name, ""));
        return;
    end

    local mod = WL.TerritoryModification.Create(order.TerritoryID);
    mod.AddSpecialUnits = splitUnit(Mod.PlayerGameData[order.PlayerID].Modifiers, unit, order.UnitType, order.SplitPercentage);
    if #mod.AddSpecialUnits > 1 then
        mod.RemoveSpecialUnitsOpt = {unit.ID};
        local event = WL.GameOrderEvent.Create(order.PlayerID, "Splitted " .. tostring(getUnitNameByType(order.UnitType)) .. " unit", {}, {mod});
        setActionWindow(event, game.Map.Territories[order.TerritoryID]);
        addNewOrder(event);
    else
        local event = WL.GameOrderEvent.Create(order.PlayerID, "Attempted to split units", {}, {});
        setActionWindow(event, game.Map.Territories[order.TerritoryID]);
        addNewOrder(event);
    end

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