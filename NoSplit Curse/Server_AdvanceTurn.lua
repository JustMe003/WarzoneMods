function Server_AdvanceTurn_Start(game, addNewOrder)
    local data = Mod.PublicGameData;
    for p, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
        for _, order in pairs(game.ServerGame.ActiveTurnOrders[p]) do
            if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyNo-splitCurse_") then
                local terrID = tonumber(string.sub(order.Payload, #"BuyNo-splitCurse_" + 1));
                if order.CostOpt ~= nil and Mod.Settings.Cost + (data.NoSplitCursesPurchased[p] * Mod.Settings.Increment) == order.CostOpt[WL.ResourceType.Gold] then
                    local owner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID;
                    if owner == WL.PlayerID.Neutral then owner = p; end
                    local builder = WL.CustomSpecialUnitBuilder.Create(owner);
                    builder.Name = "No-splitCurse";
                    builder.AttackPower = 0;
                    builder.CanBeAirliftedToSelf = true;
                    builder.CanBeAirliftedToTeammate = true;
                    builder.CanBeGiftedWithGiftCard = true;
                    builder.CanBeTransferredToTeammate = true;
                    builder.CombatOrder = 9121;
                    builder.DamageAbsorbedWhenAttacked = 0;
                    builder.DamageToKill = 0;
                    builder.DefensePower = 0;
                    builder.ImageFilename = "No-SplitCurse.png";
                    builder.IncludeABeforeName = true;
                    builder.TextOverHeadOpt = "Curse";
                    local mod = WL.TerritoryModification.Create(terrID);
                    mod.AddSpecialUnits = {builder.Build()};

                    local event = WL.GameOrderEvent.Create(p, game.Game.PlayingPlayers[p].DisplayName(nil, false) .. "'s mage cursed " .. game.Map.Territories[terrID].Name .. " with No-split", {}, {mod}, {[p]={[WL.ResourceType.Gold]=order.CostOpt[WL.ResourceType.Gold]}});
                    event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
                    addNewOrder(event);
                    data.NoSplitCursesPurchased[p] = data.NoSplitCursesPurchased[p] + 1;
                end
            end
        end
    end
    Mod.PublicGameData = data;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "BuyNo-splitCurse_") then
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
    elseif order.proxyType == "GameOrderAttackTransfer" then
        if not orderResult.IsNullified and hasNoSplitCurse(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies) and not compareArmies(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies, order.NumArmies) then
            orderResult.ActualArmies = WL.Armies.Create(0, {});
            orderResult.AttackingArmiesKilled = WL.Armies.Create(0, {});
            orderResult.DefendingArmiesKilled = WL.Armies.Create(0, {});
            addNewOrder(WL.GameOrderAttackTransfer.Create(order.PlayerID, order.From, order.To, order.AttackTransfer, order.ByPercent, game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies, order.AttackTeammates));
        end
    end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	
end

function compareArmies(a1, a2)
    if a1.NumArmies ~= a2.NumArmies or #a1.SpecialUnits ~= #a2.SpecialUnits then return false; end
    for _, unit1 in pairs(a1.SpecialUnits) do
        local bool = false;
        for _, unit2 in pairs(a2.SpecialUnits) do
            if unit1.ID == unit2.ID then
                bool = true;
                break;
            end
        end
        if not bool then
            return false;
        end
    end
    return true;
end

function hasNoSplitCurse(armies)
    for _, sp in pairs(armies.SpecialUnits) do
        if sp.Name == "No-splitCurse" then
            return true;
        end
    end
    return false;
end

function startsWith(s, sub)
    return string.sub(s, 1, #sub) == sub;
end
