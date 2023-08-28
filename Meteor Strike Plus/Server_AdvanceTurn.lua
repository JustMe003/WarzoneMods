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
            local num = data.Data.NumOfMeteors + math.random(data.Data.RandomNumOfMeteor);
            table.insert(meteors, {Weight = num, Data = data.Data});
            totalWeight = totalWeight + num;
        end
    end
    
    for _, data in pairs(Mod.Settings.Data.Normal) do
        if math.random(10000) / 100 <= data.ChanceofFalling then
            local num = data.NumOfMeteors + math.random(data.RandomNumOfMeteor);
            table.insert(meteors, {Weight = num, Data = data});
            totalWeight = totalWeight + num;
        end
    end
    
    local terrsHit = {};
    local terrs = Mod.PrivateGameData.Territories;
    local numTerrs = #terrs;
    for i = 1, math.min(totalWeight, numTerrs) do
        local rand = math.random(totalWeight);
        for _, meteor in ipairs(meteors) do
            rand = rand - meteor.Weight;
            if rand <= 0 then
                local randTerr = math.random(#terrs);
                local terr = terrs[randTerr];
                table.remove(terrs, randTerr);
                table.insert(terrsHit, terr);
                local mod = removeArmies(game.ServerGame.LatestTurnStanding.Territories[terr], meteor.Data.MeteorDamage);
                if meteor.Data.CanSpawnAlien and math.random(10000) / 100 <= meteor.Data.AlienSpawnChance and (game.ServerGame.LatestTurnStanding.Territories[terr].OwnerPlayerID == WL.PlayerID.Neutral or mod.SetOwnerOpt == WL.PlayerID.Neutral) then
                	local alien = createAlien(meteor.Data.AlienDefaultHealth + math.random(meteor.Data.AlienRandomHealth));
                end
                break;
            end
        end
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
