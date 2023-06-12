function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder) 
    if Mod.Settings.DoNotAllowDeployments and order.proxyType == "GameOrderDeploy" and game.Game.TurnNumber > 1 then
        local t = {order.PlayerID, WL.PlayerID.Neutral};
        for connID, _ in pairs(game.Map.Territories[order.DeployOn].ConnectedTo) do
            if valueInTable(t, game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID) then
                return;
            end
        end
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
        addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You cannot deploy on a territory that is not connected to another territory you control", "_"))
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
    if Mod.Settings.RemoveArmiesFromEncircledTerrs then
        local evaluated = {};
        for terrID, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
            if not valueInTable(evaluated, terrID) and terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
                local owner = terr.OwnerPlayerID;
                local b = false;
                for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
                    if owner == game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID then
                        table.insert(evaluated, terrID);
                        b = true;
                        break;
                    elseif game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID == WL.PlayerID.Neutral then
                        b = true;
                        break;
                    end
                end
                if not b then
                    local mod = WL.TerritoryModification.Create(terrID);
                    if Mod.Settings.TerritoriesTurnNeutral then
                        mod.SetOwnerOpt = WL.PlayerID.Neutral;
                    else
                        print(Mod.Settings.PercentageLost);
                        mod.AddArmies = -math.ceil(terr.NumArmies.NumArmies * (Mod.Settings.PercentageLost / 100));
                        if terr.NumArmies.NumArmies + mod.AddArmies <= 0 then
                            mod.SetOwnerOpt = WL.PlayerID.Neutral;
                        end
                    end
                    local event = WL.GameOrderEvent.Create(owner, game.Map.Territories[terrID].Name .. " got encircled", {}, {mod});
                    event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
                    addNewOrder(event);
                end
            end
        end
    end
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end