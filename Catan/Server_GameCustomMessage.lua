require("Catan");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    publicGameData = Mod.PublicGameData;
    playerGameData = Mod.PlayerGameData;
    standing = game.ServerGame.LatestTurnStanding;

	local commandHandler = {
        BuildVillage = buildVillage,
        BuildMultipleVillages = buildMultipleVillages,
        UpgradeVillage = upgradeVillage,
        BuildWarriorCamp = buildWarriorCamp,
        DeleteOrders = deleteOrders
    }
    if payload.Command == nil then
        returnError(setReturn, "No command given");
        return;
    end
    commandHandler[payload.Command](game, playerID, payload, setReturn);
    
    Mod.PlayerGameData = playerGameData;
    Mod.PublicGameData = publicGameData;
    print("finished");
end

function buildVillage(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID"});
    if not bool then
        returnError(setReturn, field .. " was nil while building village");
        return false;
    end
    local terr = standing.Territories[payload.TerritoryID];
    if terrHasVillage(terr.Structures) then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, "BuildVillage");
    end
    if terr.OwnerPlayerID == playerID then
        if hasEnoughResources(getRecipe(Catan.Recipes.Village), playerGameData[playerID].Resources) then
            local order = createBuildVillageOrder(playerID, payload.TerritoryID);
            addOrderToOrderList(playerGameData[playerID].OrderList, order);
            removePlayerResources(playerGameData, playerID, order.Cost);
            returnSuccess(setReturn, "Build village order created");
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
    if not terrHasVillage(terr.Structures) then
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

function buildWarriorCamp(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"TerritoryID"});
    if not bool then
        returnError(setReturn, field .. " was nil while building warrior camp");
        return false;
    end
    local terr = standing.Territories[payload.TerritoryID];
    if terrHasWarriorCamp(terr.Structures) then
        returnInvalidTerritory(setReturn, game.Map.Territories[payload.TerritoryID].Name, "BuildWarriorCamp");
        return false;
    end
    if terr.OwnerPlayerID == playerID then
        if hasEnoughResources(getRecipe(Catan.Recipes.WarriorCamp), playerGameData[playerID].Resources) then
            local order = createBuildWarriorCampOrder(playerID, payload.TerritoryID);
            addOrderToOrderList(playerGameData[playerID].OrderList, order);
            removePlayerResources(playerGameData, playerID, order.Cost);
            returnSuccess(setReturn, "Build warrior camp order created", {Order = order});
            return true;
        else
            returnInsufficientResources(setReturn, "BuildWarriorCamp");
            return false;
        end
    else
        returnError(setReturn, "Owner was not the same as invoker while building warrior camp");
        return false;
    end
end

function deleteOrders(game, playerID, payload, setReturn)
    local bool, field = tableHasFields(payload, {"OrderIndexes"});
    if not bool then
        returnError(setReturn, field .. " was nil while building warrior camp");
        return false;
    end
    local t = table.sort(payload.OrderIndexes, function(v, v2) return v > v2; end);
    for _, k in ipairs(t) do
        addPlayerResources(playerGameData, playerID, playerGameData[playerID].OrderList[k].Cost);
        table.remove(playerGameData[playerID].OrderList, k);
    end
    returnSuccess(setReturn, "Successfully deleted orders");
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