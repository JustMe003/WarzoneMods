function Client_GameOrderCreated(game, order, skipOrder)
    if Mod.Settings.DoNotAllowDeployments and order.proxyType == "GameOrderDeploy" then
        local p = game.Us.ID;
        local terrID = order.DeployOn;
        local isEncircled = true;
        for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
            local terr = game.LatestStanding.Territories[connID];
            if terr.OwnerPlayerID == p or terr.OwnerPlayerID == WL.PlayerID.Neutral then
                isEncircled = false;
                break;
            end
        end
        if isEncircled then
            UI.Alert("You cannot deploy on " .. game.Map.Territories[terrID].Name .. " because the territory is surrounded\n\nUnless you are required to deploy your armies here, you should deploy your armies elsewhere");
        end
    end
end