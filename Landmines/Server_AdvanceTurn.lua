function Server_AdvanceTurn_Start(game, addNewOrder)
    data = Mod.PublicGameData;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyLandmine_") then
        local terrID = tonumber(string.sub(order.Payload, #"BuyLandmine_" + 1));
        if order.CostOpt ~= nil and Mod.Settings.Cost == order.CostOpt[WL.ResourceType.Gold] + (data.LandminesBought[order.PlayerID] * Mod.Settings.CostIncrease) and game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID == order.PlayerID then
            local builder = WL.CustomSpecialUnitBuilder.Create(order.PlayerID);
            builder.Name = "Landmine";
            builder.AttackPower = 0;
            builder.CanBeAirliftedToSelf = false;
            builder.CanBeAirliftedToTeammate = false;
            builder.CanBeGiftedWithGiftCard = false;
            builder.CanBeTransferredToTeammate = false;
            builder.CombatOrder = 13;
            builder.DamageAbsorbedWhenAttacked = Mod.Settings.DamageAbsorbed;
            builder.DamageToKill = 1;
            builder.DefensePower = 1;
            builder.ImageFilename = "landmine.png";
            builder.IncludeABeforeName = true;
            builder.TextOverHeadOpt = ">!!!<";
            local mod = WL.TerritoryModification.Create(terrID);
            mod.AddSpecialUnits = {builder.Build()};

            local event = WL.GameOrderEvent.Create(order.PlayerID, "Purchased a Landmine", {}, {mod});
            event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
            addNewOrder(event);
            data.LandminesBought[order.PlayerID] = data.LandminesBought[order.PlayerID] + 1;
        end
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
    elseif order.proxyType == "GameOrderAttackTransfer" then
        if #orderResult.ActualArmies.SpecialUnits > 0 then
            local t = {};
            for _, sp in pairs(orderResult.ActualArmies.SpecialUnits) do
                if sp.proxyType == "CustomSpecialUnit" and sp.Name == "Landmine" then
                    table.insert(t, sp);
                end
            end
            orderResult.ActualArmies = orderResult.ActualArmies.Subtract(WL.Armies.Create(0, t));
        end
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	Mod.PublicGameData = data;
end

function getNMedics(armies)
    local ret = 0;
    for _, sp in pairs(armies.SpecialUnits) do
        if sp.proxyType == "CustomSpecialUnit" and sp.Name == "Medic" then
            ret = ret + 1;
        end
    end
    return ret;
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end

function round(n)
    return math.floor(n + 0.5);
end