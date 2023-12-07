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
                        t.TestingOnly.Counter = t.TestingOnly.Counter + 1;
                    end
                    clone.ModData = dataToString(t);
                    table.insert(mod.RemoveSpecialUnitsOpt, sp.ID);
                    table.insert(mod.AddSpecialUnits, clone.Build());
                end
            end
            addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Updated units", {}, {mod}));
        end
    end
end