function Server_AdvanceTurn_Start(game, addNewOrder)
	if Mod.PublicGameData.LandminesFound ~= nil then
        for _, t in pairs(Mod.PublicGameData.LandminesFound) do
            local terrID = t.TerrID;
            local mod = WL.TerritoryModification.Create(terrID);
            local rem = {};
            local add = {};
            for _, sp in pairs(game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.SpecialUnits) do
                if isLandmine(sp) and sp.ImageFilename ~= "Landmine.png" then
                    table.insert(rem, sp.ID);
                    local clone = WL.CustomSpecialUnitBuilder.CreateCopy(sp);
                    clone.ImageFilename = "Landmine.png";
                    table.insert(add, clone.Build());
                end
            end
            if #rem > 0 then
                mod.AddSpecialUnits = add;
                mod.RemoveSpecialUnitsOpt = rem;
                local event = WL.GameOrderEvent.Create(t.Player, "Spotted landmine(s) on " .. game.Map.Territories[terrID].Name, {}, {mod});
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
                addNewOrder(event);
            end
        end
    end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyLandmine_") and order.CostOpt ~= nil and Mod.Settings.UnitCost == order.CostOpt[WL.ResourceType.Gold] and getNLandmines(game.ServerGame.LatestTurnStanding.Territories, order.PlayerID) < Mod.Settings.MaxUnits then
        local terrID = tonumber(string.sub(order.Payload, #"BuyLandmine_" + 1));
        if terrID ~= nil and game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID == order.PlayerID then
            local mod = WL.TerritoryModification.Create(terrID);
            mod.AddSpecialUnits = {createLandmine(game, order.PlayerID, false)};
            local event = WL.GameOrderEvent.Create(order.PlayerID, "Placed a Landmine on " .. game.Map.Territories[terrID].Name, {}, {mod});
            event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
            event.AddResourceOpt = {[order.PlayerID] = {[WL.ResourceType.Gold] = -order.CostOpt[WL.ResourceType.Gold]}};
            skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
            addNewOrder(event);
        end
    elseif order.proxyType == "GameOrderAttackTransfer" then
        if orderResult.ActualArmies.SpecialUnits ~= nil and #orderResult.ActualArmies.SpecialUnits > 0 then
            local t = {};
            for _, sp in pairs(orderResult.ActualArmies.SpecialUnits) do
                if isLandmine(sp) then
                    table.insert(t, sp);
                end
            end
            orderResult.ActualArmies = orderResult.ActualArmies.Subtract(WL.Armies.Create(0, t));
        end
    end
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end

function getNLandmines(territories, p)
    local c = 0;
    for _, terr in pairs(territories) do
        if terr.NumArmies.SpecialUnits ~= nil and #terr.NumArmies.SpecialUnits > 0 then
            for _, sp in pairs(terr.NumArmies.SpecialUnits) do
                if isLandmine(sp) then
                    c = c + 1;
                end
            end
        end
    end
    return c;
end

function isLandmine(sp)
    return sp.proxyType == "CustomSpecialUnit" and sp.Name == "Landmine";
end

function createLandmine(game, p, bool) 
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.Name = "Landmine";
    builder.AttackPower = 0;
    builder.CanBeAirliftedToSelf = false;
    builder.CanBeAirliftedToTeammate = false;
    builder.CanBeGiftedWithGiftCard = true;
    builder.CanBeTransferredToTeammate = false;
    builder.CombatOrder = -9;
    builder.DamageAbsorbedWhenAttacked = Mod.Settings.Damage * game.Settings.OffenseKillRate;
    builder.DamageToKill = 0;
    builder.DefensePower = Mod.Settings.Damage / game.Settings.DefenseKillRate;
    builder.IncludeABeforeName = true;
    builder.ModData = "UnitDescription:\"This is still yet to be added!\"";
    if bool then
        builder.ImageFilename = "Landmine.png";
    end
    return builder.Build();
end