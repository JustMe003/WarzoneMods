require("DataConverter");

function Server_AdvanceTurn_Start(game, addNewOrder)
    
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    
end

function Server_AdvanceTurn_End(game, addNewOrder)
    for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
        if #terr.NumArmies.SpecialUnits > 0 then
            local mod = WL.TerritoryModification.Create(terr.ID);
            mod.AddSpecialUnits = {};
            mod.RemoveSpecialUnitsOpt = {};
            for _, sp in ipairs(terr.NumArmies.SpecialUnits) do
                if sp.proxyType == "CustomSpecialUnit" then
                    local clone = WL.CustomSpecialUnitBuilder.CreateCopy(sp);
                    local t = stringToData(clone.ModData);
                    if t.TestingOnly == nil then
                        t.TestingOnly = {};
                        if t.TestingOnly.Counter == nil then
                            t.TestingOnly.Counter = 0;
                        end
                    end
                    t.TestingOnly.Counter = t.TestingOnly.Counter + 1;
                    clone.ModData = dataToString(t);
                    printTable(t);
                    table.insert(mod.RemoveSpecialUnitsOpt, sp.ID);
                    table.insert(mod.AddSpecialUnits, clone.Build());
                end
            end
            addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Updated units", {}, {mod}));
        end
    end
end

function printTable(t, s)
    if s == nil then s = ""; end
    for i, v in pairs(t) do
        print(s .. i .. "\t" .. type(v) .. "\t" .. tostring(v));
        if type(v) == type({}) then
            printTable(v, s .. "\t");
        end
    end
end