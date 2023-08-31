require("RemoveArmies");

function Server_AdvanceTurn_Start(game, addNewOrder)
    
end

function Server_AdvanceTurn_Order(game, order, orderDetails, skipThisOrder, addNewOrder)
    
end

function Server_AdvanceTurn_End(game, addNewOrder)
    local totalWeight = 0;
    local meteors = {};
    
    local turnNumber = game.Game.TurnNumber;
    for _, data in ipairs(Mod.PrivateGameData.Doomsdays) do
        if TurnNumber == data.Turn then
            local num = data.Data.NumOfMeteors + math.random(0, data.Data.RandomNumOfMeteor);
            table.insert(meteors, {Weight = num, Data = data.Data});
            totalWeight = totalWeight + num;
        end
    end
    
    for _, data in pairs(Mod.Settings.Data.Normal) do
        if math.random(10000) / 100 <= data.ChanceofFalling then
            local num = data.NumOfMeteors + math.random(0, data.RandomNumOfMeteor);
            table.insert(meteors, {Weight = num, Data = data});
            totalWeight = totalWeight + num;
        end
    end
    
    local terrsHit = {};
    local orders = {};
    local privData = Mod.PrivateGameData;
    local terrs = privData.Territories;
    local numTerrs = #terrs;
    for i = 1, math.min(totalWeight, numTerrs) do
        local rand = math.random(totalWeight);
        for _, meteor in ipairs(meteors) do
            rand = rand - meteor.Weight;
            if rand <= 0 then
                local randTerr = math.random(#terrs);
                local terrID = terrs[randTerr];
                local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
                table.remove(terrs, randTerr);
                table.insert(terrsHit, terrID);
                local mod = removeArmies(terr, meteor.Data.MeteorDamage);
                if meteor.Data.CanSpawnAlien and math.random(10000) / 100 <= meteor.Data.AlienSpawnChance and (terr.OwnerPlayerID == WL.PlayerID.Neutral or (mod.SetOwnerOpt ~= nil and mod.SetOwnerOpt == WL.PlayerID.Neutral)) then
                	if armiesHasAlien(terr.NumArmies) then
                        local alien = nil;
                        for _, sp in ipairs(terr.NumArmies.SpecialUnits) do
                            if unitIsAlien(sp) then alien = sp; break; end
                        end
                        local clone = getClone(alien, -(meteor.Data.AlienDefaultHealth + math.random(0, meteor.Data.AlienRandomHealth)));
                        mod.AddSpecialUnits = concatArrays(mod.AddSpecialUnits, {clone});
                        mod.RemoveSpecialUnitsOpt = concatArrays(mod.RemoveSpecialUnitsOpt, {alien});
                    else
                        local alien = createAlien(meteor.Data.AlienDefaultHealth + math.random(0, meteor.Data.AlienRandomHealth));
                        mod.AddSpecialUnits = concatArrays(mod.AddSpecialUnits, {alien});
                    end
                end
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Meteor landed on " .. game.Map.Territories[terrID], {mod});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
                table.insert(orders, event);
                break;
            end
        end
        totalWeight = totalWeight - 1;
    end

    terrs = concatArrays(terrsHit, terrs);

    for _, order in ipairs(orders) do
        addNewOrder(order);
    end
end

function moveAllAliens(game, addNewOrder)
    for terrID, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
        if #terr.NumArmies.SpecialUnits > 0 then
            for _, sp in pairs(terr.NumArmies.SpecialUnits) do
                if unitIsAlien(sp) and not alienHasMoved(game, sp) then
                    moveAlien(game, addNewOrder, terr, sp)
                end
            end
        end
    end
end

function moveAlien(game, addNewOrder, terr, alien)
    local rand = math.random(#game.Map.Territories[terr.ID].ConnectedTo);
    for connID, _ in pairs(game.Map.Territories[terr.ID].ConnectedTo) do
        if rand == 0 then
            local modFrom = WL.TerritoryModification.Create(terr.ID);
            local modTo = WL.TerritoryModification.Create(connID);
        end
    end
end

function alienHasMoved(game, alien)
    
end

function unitIsAlien(sp)
    return sp.proxyType == "CustomSpecialUnit" and sp.Name == "Alien";
end

function createAlien(health)
	local builder = WL.CustomSpecialUnitBuilder.Create(WL.PlayerID.Neutral);
	builder.Health = health;
end

function armiesHasAlien(armies)
    for _, sp in ipairs(armies.SpecialUnits) do
        if unitIsAlien(sp) then return true; end
    end
    return false;
end

function concatArrays(arr1, arr2)
    if arr1 == nil and arr2 == nil then
        return {};
    elseif arr1 == nil and type(arr2) == type({}) then
        return arr2;
    elseif arr2 == nil and type(arr1) == type({}) then
        return arr1;
    end
    if #arr2 <= #arr1 then
        for _, v in ipairs(arr2) do
            table.insert(arr1, v);
        end
        return arr1;
    else
        for _, v in ipairs(arr1) do
            table.insert(arr2, v);
        end
        return arr2;
    end
end