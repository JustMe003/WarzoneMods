require("Util");

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)
    local data = Mod.PublicGameData;
    local terrs = nil;
    local structuresMap = getStructuresMap();
    for i, counter in pairs(data.Counters) do
        if counter == 1 then
            if terrs == nil then
                terrs = getAvailableTerrs(game.ServerGame.LatestTurnStanding.Territories);
            end
            if #terrs < 1 then
                break;
            end
            local group = Mod.Settings.Config[i];
            local structID = group.Structures[math.random(#group.Structures)];
            local rand = math.random(#terrs);
            local terrID = terrs[rand];
            table.remove(terrs, rand);

            local mod = WL.TerritoryModification.Create(terrID);
            mod.AddStructuresOpt = {
                [structID] = group.Amount
            }
            local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Added " .. group.Amount .. " of " .. structuresMap[structID], {}, {mod});
            event.JumpToActionSpotOpt = getRectangleVM(game.Map.Territories[terrID]);
            event.TerritoryAnnotationsOpt = {
                [terrID] = WL.TerritoryAnnotation.Create("+" .. group.Amount .. " " .. structuresMap[structID]);
            }
            addNewOrder(event);

            data.Counters[i] = group.Interval;
        else
            data.Counters[i] = counter - 1;
        end
    end
    Mod.PublicGameData = data;
end

function getAvailableTerrs(terrs)
    local terrList = {};
    for terrID, terr in pairs(terrs) do
        if terr.OwnerPlayerID == WL.PlayerID.Neutral then
            table.insert(terrList, terrID);
        end
    end
    return terrList;
end

function getRectangleVM(terrDetails)
    return WL.RectangleVM.Create(terrDetails.MiddlePointX, terrDetails.MiddlePointY, terrDetails.MiddlePointX, terrDetails.MiddlePointY);
end
