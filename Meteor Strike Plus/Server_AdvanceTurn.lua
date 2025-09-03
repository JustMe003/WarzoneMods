require("RemoveArmies");
require("DataConverter");

-- Avoid allocating memory for this string every time
MODDATA = dataToString({UnitDescription = "This is an {{Name}}. {{Name}} is controlled by no one, not even neutrals...\n\n{{Name}} has {{Health}} health, and its attacking and defensive power is always equal to its health. You can decrease the power of {{Name}} by damaging it\n\n{{Name}} moves all by himself, he has a mind of its own. But be aware, they might attack you... When they attack, they deal damage equal to their health, so currently they would deal {{Health}} armies damage. If they deal enough damage to get rid of all armies and special units, they will take the territory from you\n\nWhen {{Name}} moves to another territory where a friend resides, they will do what {{Name}}s do best, and merge together to become an even more frightning {{Name}}?"});

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

    local privData = Mod.PrivateGameData;
    local publData = Mod.PublicGameData;
    local turnNumber = game.Game.TurnNumber;

    for i, data in ipairs(privData.Doomsdays) do
        if turnNumber == data.Turn then
            local num = data.Data.NumOfMeteors + math.random(0, data.Data.RandomNumOfMeteor);
            table.insert(meteors, {Weight = num, Data = data.Data});
            totalWeight = totalWeight + num;
            if data.Data.Repeat then
                local doomsday = data;
                doomsday.Turn = turnNumber + math.random(data.Data.RepeatAfterMin, data.Data.RepeatAfterMax) + getDoomsdayTurn(data.Data);
                privData.Doomsdays[i] = doomsday;
            end
            if data.Data.Repeat or data.Data.RandomTurn then
                publData.DoomsdaysLastTurn[data.Data.ID] = turnNumber;
            end
        end
    end

    for i, data in pairs(privData.NormalStorms) do
        if (not data.NotEveryTurn or (turnNumber >= data.StartStorm and turnNumber <= data.EndStorm)) and math.random(10000) / 100 <= data.Data.ChanceofFalling then
            if data.NotEveryTurn and data.StartStorm == turnNumber then
                publData.NormalStormsStartTurn[data.Data.ID] = turnNumber;
            end
            local num = data.Data.NumOfMeteors + math.random(0, data.Data.RandomNumOfMeteor);
            table.insert(meteors, {Weight = num, Data = data.Data});
            totalWeight = totalWeight + num;
            if data.NotEveryTurn and turnNumber == data.EndStorm and data.Data.Repeat then
                local storm = data;
                local interval = math.random(data.Data.RepeatAfterMin, data.Data.RepeatAfterMax);
                storm.StartStorm = turnNumber + interval;
                storm.EndStorm = turnNumber + interval + data.Data.EndStorm - data.Data.StartStorm;
                privData.NormalStorms[i] = storm;
                publData.NormalStormsLastTurn[data.Data.ID] = turnNumber;
            end
        end
    end

    local orders = {};
    local terrs = privData.Territories;
    local terrRem = {};
    local numTerrs = #terrs;

    for i = 1, math.min(totalWeight, getMaxMeteors(numTerrs)) do
        local rand = math.random(totalWeight);
        for _, meteor in ipairs(meteors) do
            rand = rand - meteor.Weight;
            if rand <= 0 then
                meteor.Weight = meteor.Weight - 1;
                local randTerr = math.random(#terrs);
                local terrID = terrs[randTerr];
                local terr = game.ServerGame.LatestTurnStanding.Territories[terrID];
                if not Mod.Settings.GeneralSettings.HitTerritoriesMultTimes then
                    table.remove(terrs, randTerr);
                    table.insert(terrRem, terrID);
                end
                local mod = removeArmies(terr, meteor.Data.MeteorDamage + math.random(0, meteor.Data.MeteorRandomDamage));
            --    print(game.Map.Territories[terrID].Name, mod.AddArmies);
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
                        newAlienPlaces[terrID] = alien;
                    end
                end
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Meteor landed on " .. game.Map.Territories[terrID].Name .. " (" .. meteor.Data.Name .. ")", {}, {mod});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
                event.TerritoryAnnotationsOpt = { [terrID] = WL.TerritoryAnnotation.Create("Meteor") };
                table.insert(orders, event);
                break;
            end
        end
        totalWeight = totalWeight - 1;
    end

    for _, order in ipairs(orders) do
        addNewOrder(order);
    end

    if not Mod.Settings.GeneralSettings.HitTerritoriesMultTimes then
        terrs = concatArrays(terrs, terrRem);
    end

    
    Mod.PrivateGameData = privData;
    Mod.PublicGameData = publData;
end

function moveAllAliens(game, addNewOrder)
    newAlienPlaces = {};
    for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
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
            if game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID ~= WL.PlayerID.Neutral then
                modTo = removeArmies(game.ServerGame.LatestTurnStanding.Territories[connID], alien.Health);
            end
            if game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID == WL.PlayerID.Neutral or modTo.SetOwnerOpt == WL.PlayerID.Neutral then
                modFrom.RemoveSpecialUnitsOpt = {alien.ID};
                modTo.AddSpecialUnits = {solveAlienConflicts(modTo, alien, connID)};
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, getEventMessage(modTo, game.Map.Territories[connID].Name, game.Map.Territories[terr.ID].Name), {}, {modFrom, modTo});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY, game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY);
                addNewOrder(event);
            else
                solveAlienConflicts(modTo, alien, terr.ID);
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Aliens attacked " .. game.Map.Territories[connID].Name, {}, {modFrom, modTo});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY, game.Map.Territories[connID].MiddlePointX, game.Map.Territories[connID].MiddlePointY);
                addNewOrder(event);
            end
        end
    end
end

function solveAlienConflicts(modTo, alien, terrID)
    local alienOnTerr = newAlienPlaces[terrID];
    local clone = alien;
    if alienOnTerr ~= nil then
        if alienOnTerr.Name:find("UFO") ~= nil then
            clone = getClone(alienOnTerr, -alien.Health);
            modTo.RemoveSpecialUnitsOpt = concatArrays({alienOnTerr.ID}, modTo.RemoveSpecialUnitsOpt);
        else
            clone = getClone(alien, -alienOnTerr.Health);
            modTo.RemoveSpecialUnitsOpt = concatArrays({alienOnTerr.ID}, modTo.RemoveSpecialUnitsOpt);
        end
    end
    newAlienPlaces[terrID] = clone;
    return clone;
end

function unitIsAlien(sp)
    return sp.proxyType == "CustomSpecialUnit" and sp.Name:find("Alien") ~= nil and (sp.ImageFilename == "Alien.png" or sp.ImageFilename == "UFO.png");
end

function createAlien(health)
	local builder = WL.CustomSpecialUnitBuilder.Create(WL.PlayerID.Neutral);
    builder.ModData = MODDATA;
    if Mod.Settings.GeneralSettings.UseSuprise and math.random(10000) / 100 <= 1 then
        print("Easter egg!")
        builder.Health = health * 2;
        builder.AttackPower = health * 2;
        builder.DefensePower = health * 2;
        builder.CombatOrder = 477;
        builder.ImageFilename = "UFO.png"
        builder.Name = "Alien UFO " .. math.random(100);
    else
        builder.Health = health;
        builder.AttackPower = health;
        builder.DefensePower = health;
        builder.CombatOrder = 478;
        builder.ImageFilename = "Alien.png"
        builder.Name = "Alien";
    end
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

function getEventMessage(mod, to, from)
    if mod.AddArmies ~= nil and mod.AddArmies ~= 0 or mod.SetOwnerOpt == WL.PlayerID.Neutral then
        return "Aliens attacked " .. to .. " from " .. from;
    else
        return "Aliens moved from " .. from .. " to " .. to;
    end
end

function getDoomsdayTurn(data)
    if data.RandomTurn then
        return math.random(0, data.MaxTurnNumber - data.MinTurnNumber);
    else
        return 0;
    end
end

function getMaxMeteors(numTerrs)
    if Mod.Settings.GeneralSettings.HitTerritoriesMultTimes then
        return 1000;        -- On a 4000 terr map, takes about 5 seconds
    else
        return math.min(numTerrs, 1000);
    end
end