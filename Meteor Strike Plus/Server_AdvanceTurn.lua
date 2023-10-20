require("RemoveArmies");

function Server_AdvanceTurn_Start(game, addNewOrder)
    
end

function Server_AdvanceTurn_Order(game, order, orderDetails, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderAttackTransfer" then
        if orderDetails.DamageToSpecialUnits ~= nil and orderDetails.DamageToSpecialUnits ~= {} then
            for _, sp in pairs(game.ServerGame.LatestTurnStanding.Territories[order.To].NumArmies.SpecialUnits or {}) do
                if unitIsAlien(sp) then
                    for i, v in pairs(orderDetails.DamageToSpecialUnits) do
                        if i == sp.ID then
                            local mod = WL.TerritoryModification.Create(order.To);
                            mod.RemoveSpecialUnitsOpt = {i};
                            local clone = getClone(sp, v);
                            mod.AddSpecialUnits = {clone};
                            local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Updated data", {}, {mod});
                            event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[order.To].MiddlePointX, game.Map.Territories[order.To].MiddlePointY, game.Map.Territories[order.To].MiddlePointX, game.Map.Territories[order.To].MiddlePointY);
                            addNewOrder(event, true);            
                        end
                    end
                end
            end
        end
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
    moveAllAliens(game, addNewOrder);

    local totalWeight = 0;
    local meteors = {};
    
    local turnNumber = game.Game.TurnNumber;
    for _, data in ipairs(Mod.PrivateGameData.Doomsdays) do
        if turnNumber == data.Turn then
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
                meteor.Weight = meteor.Weight - 1;
                local randTerr = math.random(#terrs);
                local terrID = terrs[randTerr];
                local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
                table.remove(terrs, randTerr);
                table.insert(terrsHit, terrID);
                local mod = removeArmies(terr, meteor.Data.MeteorDamage);
                if meteor.Data.MeteorDamage == 0 and not Mod.Settings.GeneralSettings.ZeroDamageTotalDestruction then
                    mod = WL.TerritoryModification.Create(terr.ID);
                end
                if meteor.Data.CanSpawnAlien and math.random(10000) / 100 <= meteor.Data.AlienSpawnChance and (terr.OwnerPlayerID == WL.PlayerID.Neutral or (mod.SetOwnerOpt ~= nil and mod.SetOwnerOpt == WL.PlayerID.Neutral)) then
                	if newAlienPlaces[terrID] ~= nil then
                        mod.RemoveSpecialUnitsOpt = {newAlienPlaces[terrID].ID};
                        local clone = getClone(newAlienPlaces[terrID], -(meteor.Data.AlienDefaultHealth + math.random(0, meteor.Data.AlienRandomHealth)));
                        newAlienPlaces[terrID] = clone;
                        mod.AddSpecialUnits = {clone};
                    else
                        local alien = createAlien(meteor.Data.AlienDefaultHealth + math.random(0, meteor.Data.AlienRandomHealth));
                        mod.AddSpecialUnits = concatArrays(mod.AddSpecialUnits, {alien});
                    end
                end
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Meteor landed on " .. game.Map.Territories[terrID].Name .. " (" .. meteor.Data.Name .. ")", {}, {mod});
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
    newAlienPlaces = {};
    for terrID, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
        if #terr.NumArmies.SpecialUnits > 0 then
            for _, sp in pairs(terr.NumArmies.SpecialUnits) do
                if unitIsAlien(sp) then
                    moveAlien(game, addNewOrder, terr, sp);
                    break;
                end
            end
        end
    end
end

function moveAlien(game, addNewOrder, terr, alien)
    local rand = math.random(#game.Map.Territories[terr.ID].ConnectedTo);
    for connID, _ in pairs(game.Map.Territories[terr.ID].ConnectedTo) do
        rand = rand - 1;
        if rand == 0 then
            local modTo = WL.TerritoryModification.Create(connID);
            local modFrom = WL.TerritoryModification.Create(terr.ID);
            if game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID == WL.PlayerID.Neutral or game.ServerGame.LatestTurnStanding.Territories[connID].NumArmies.DefensePower <= alien.Health then
                modFrom.RemoveSpecialUnitsOpt = {alien.ID};
                modTo.AddSpecialUnits = {solveAlienConflicts(modTo, modFrom, alien, connID)};
                modTo.AddArmies = -game.ServerGame.LatestTurnStanding.Territories[connID].NumArmies.NumArmies;
                modTo.SetOwnerOpt = WL.PlayerID.Neutral;
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Aliens moved from " .. game.Map.Territories[terr.ID].Name .. " to " .. game.Map.Territories[connID].Name, {}, {modFrom, modTo});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY, game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY);
                addNewOrder(event);
            else
                solveAlienConflicts(modTo, modFrom, alien, terr.ID);
                modTo.AddArmies = -alien.Health;
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Aliens attacked " .. game.Map.Territories[connID].Name, {}, {modFrom, modTo});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY, game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY);
                addNewOrder(event);
            end
        end
    end
end

function solveAlienConflicts(modTo, modFrom, alien, terrID)
    local alienOnTerr = newAlienPlaces[terrID];
    local clone = alien;
    if alienOnTerr ~= nil then
        clone = getClone(alien, -alienOnTerr.Health)
        modTo.RemoveSpecialUnitsOpt = {alienOnTerr.ID}
    end
    newAlienPlaces[terrID] = clone;
    return clone;
end

function unitIsAlien(sp)
    return sp.proxyType == "CustomSpecialUnit" and sp.Name == "Alien";
end

function createAlien(health)
	local builder = WL.CustomSpecialUnitBuilder.Create(WL.PlayerID.Neutral);
	builder.Health = health;
    builder.AttackPower = health;
    builder.DefensePower = health;
    builder.CombatOrder = 478;
    builder.ImageFilename = "Alien.png"
    builder.Name = "Alien";
    return builder.Build();
end

function getClone(alien, damage)
    local clone = WL.CustomSpecialUnitBuilder.CreateCopy(alien);
    clone.Health = clone.Health - damage;
    clone.AttackPower = clone.Health;
    clone.DefensePower = clone.Health;
    return clone.Build();
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