local LIMIT = 9500

---Server_StartGame hook
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    conflicts = {};
    local start = WL.TickCount();
    local startIteration = start;
    local finish;
    local try = 0;
    local spaceBetweenStarts = Mod.Settings.SpaceBetweenStarts or 4;

    if game.Settings.AutomaticTerritoryDistribution then
        while try == 0 or (try < 100 and countConflicts() > 0 and (finish - start) + (finish - startIteration) < LIMIT) do
            startIteration = WL.TickCount();
            conflicts = {};
            available = {};
            claimed = {};
        
            for terrID, terr in pairs(standing.Territories) do
                if terr.OwnerPlayerID == WL.PlayerID.Neutral then
                    available[terrID] = true;
                elseif terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
                    table.insert(claimed, terrID);
                end
            end
    
            -- At most you can have a map that only has a single line of territories connected
            -- Then, with for example 2 spaces in between starts, you need at least
            -- starts * 2 - 2 available territories
            -- X - - X - - X - - X      (4 * 2 - 2 = 6)
            if getTableLength(available) < #claimed * spaceBetweenStarts - spaceBetweenStarts then
                print("Not enough territories!");
                break;
            end
            
            
            for _, claim in ipairs(claimed) do
                findConflicts(game, standing, claim);
            end
            local numConflicts = countConflicts();
            if Mod.PublicGameData.NumOfStartingConflicts == nil then
                local data = Mod.PublicGameData;
                data.NumOfStartingConflicts = numConflicts;
                Mod.PublicGameData = data;
            end
            print(numConflicts .. " conflicts");
            
            local conflictPriority = {};
            for terr, arr in pairs(conflicts) do
                local index = 0;
                for i, terrPrio in ipairs(conflictPriority) do
                    if #conflicts[terrPrio] <= #arr then
                        index =  i;
                        break;
                    end
                end
                if index == 0 then index = #conflictPriority + 1; end
                table.insert(conflictPriority, index, terr);
            end
        
            for _, terr in ipairs(conflictPriority) do
                local keys = getKeys(available);
                if #keys == 0 then break; end
                if #conflicts[terr] > 0 then
                    
                    local rand = math.random(#keys);
                    local randTerr = keys[rand];
                    available[randTerr] = nil;
            
                    findConflicts(game, standing, randTerr);
            
                    local temp = {OwnerPlayerID = standing.Territories[randTerr].OwnerPlayerID, NumArmies = standing.Territories[randTerr].NumArmies}
                    standing.Territories[randTerr].OwnerPlayerID = standing.Territories[terr].OwnerPlayerID;
                    standing.Territories[randTerr].NumArmies = standing.Territories[terr].NumArmies;
                    standing.Territories[terr].OwnerPlayerID = temp.OwnerPlayerID;
                    standing.Territories[terr].NumArmies = temp.NumArmies;
            
                    for _, conflictTerr in ipairs(conflicts[terr]) do
                        for key, value in ipairs(conflicts[conflictTerr]) do
                            if value == terr then
                                table.remove(conflicts[conflictTerr], key);
                                break;
                            end
                        end
                    end
        
                    conflicts[terr] = {};
                end
            end
            finish = WL.TickCount();
            if numConflicts == countConflicts() then
                print("Could not improve the number of conflicts!");
                break;
            end
            print("Finished in " .. finish - startIteration .. " miliseconds");
            print(countConflicts() .. " conflicts remaining!");
            local data = Mod.PublicGameData;
            data.NumOfEndingConflicts = countConflicts();
            Mod.PublicGameData = data;
        
            try = try + 1;
        end 
        
        print("took " .. (finish or start) - start .. " miliseconds");
    
    
        -- local terrs = standing;
        -- for id, _ in pairs(available) do
        --     terrs.Territories[id].OwnerPlayerID = 1;
        -- end
        -- standing = terrs;
    end
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end

function getKeys(t)
    local keys = {};
    for k, _ in pairs(t) do
        table.insert(keys, k);
    end
    return keys;
end

function findConflicts(game, standing, claim)
    local spaceBetweenStarts = Mod.Settings.SpaceBetweenStarts or 4;
    local mapTerritories = game.Map.Territories;

    -- print("claim: " .. mapTerritories[claim].Name);
    local range = 0;
    local flaggedTerrs = {claim};
    local nextTerrs = {mapTerritories[claim]};
    while range < spaceBetweenStarts do
        local newNext = {};
        for _, terr in ipairs(nextTerrs) do
            for connID, _ in pairs(terr.ConnectedTo) do
                if available[connID] then
                    available[connID] = nil;
                end
                if not valueInTable(flaggedTerrs, connID) then
                    table.insert(flaggedTerrs, connID);
                    table.insert(newNext, mapTerritories[connID]);
                    if standing.Territories[connID].OwnerPlayerID ~= WL.PlayerID.Neutral then
                        -- print("Conflict! " .. mapTerritories[claim].Name .. " and " .. mapTerritories[connID].Name)
                        conflicts[claim] = conflicts[claim] or {};
                        table.insert(conflicts[claim], connID);
                    end
                end
            end
        end
        nextTerrs = newNext;
        range = range + 1;
    end
end

function countConflicts()
    local c = 0;
    for _, v in pairs(conflicts) do
        c = c + #v;
    end
    return c;
end

function getTableLength(t)
    local c = 0;
    for _, _ in pairs(t) do c = c + 1; end
    return c;
end



-- only check min_space_between_starts / 2
-- if min_space_between_starts is odd, check last range + 1, but don't flag them