require("DataConverter");

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" and orderResult.IsAttack then
        if #orderResult.ActualArmies.SpecialUnits > 0 then
            local dragonBreathDamage = 0;
            for _, sp in pairs(orderResult.ActualArmies.SpecialUnits) do
                if sp.proxyType == "CustomSpecialUnit" then
                    if sp.ModID ~= nil and sp.ModID == 594 and Mod.PublicGameData.DragonBreathAttack[Mod.PublicGameData.DragonNamesIDs[sp.Name]] ~= nil then
                        dragonBreathDamage = dragonBreathDamage + Mod.PublicGameData.DragonBreathAttack[Mod.PublicGameData.DragonNamesIDs[sp.Name]];
                    end
                end
            end
            if dragonBreathDamage > 0 then
                local mods = {};
                for connID, _ in pairs(game.Map.Territories[order.To].ConnectedTo) do
                    if game.ServerGame.LatestTurnStanding.Territories[connID].OwnerPlayerID ~= order.PlayerID then
                        local mod = WL.TerritoryModification.Create(connID);
                        mod.AddArmies = -math.min(game.ServerGame.LatestTurnStanding.Territories[connID].NumArmies.NumArmies, dragonBreathDamage);
                        if mod.AddArmies ~= 0 then
                            table.insert(mods, mod);
                        end
                    end
                end
                local event = WL.GameOrderEvent.Create(order.PlayerID, "Dragon breath", {}, mods);
                event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[order.To].MiddlePointX, game.Map.Territories[order.To].MiddlePointY, game.Map.Territories[order.To].MiddlePointX, game.Map.Territories[order.To].MiddlePointY)
                addNewOrder(event, true);
            end
            if not tableIsEmpty(orderResult.DamageToSpecialUnits) then
                local modTo = WL.TerritoryModification.Create(order.To);
                modTo.AddSpecialUnits = {};
                modTo.RemoveSpecialUnitsOpt = {};
                local modFrom = WL.TerritoryModification.Create(order.From);
                modFrom.AddSpecialUnits = {};
                modFrom.RemoveSpecialUnitsOpt = {};
                for ID, v in pairs(orderResult.DamageToSpecialUnits) do 
                    for _, sp in pairs(game.ServerGame.LatestTurnStanding.Territories[order.To].NumArmies.SpecialUnits) do
                        if sp.ID == ID then
                            if sp.ModID ~= nil and sp.ModID == 594 and Mod.PublicGameData.DynamicDefencePower ~= nil and Mod.PublicGameData.DynamicDefencePower[Mod.PublicGameData.DragonNamesIDs[sp.Name]] ~= nil then
                                modTo = replaceDragon(modTo, sp, v);
                            end
                            break;
                        end
                    end
                    for _, sp in pairs(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.SpecialUnits) do
                        if sp.ID == ID then
                            if sp.ModID ~= nil and sp.ModID == 594 and Mod.PublicGameData.DynamicDefencePower ~= nil and Mod.PublicGameData.DynamicDefencePower[Mod.PublicGameData.DragonNamesIDs[sp.Name]] ~= nil then
                                if orderResult.IsSuccessful then
                                    modTo = replaceDragon(modTo, sp, v);
                                else
                                    modFrom = replaceDragon(modFrom, sp, v);
                                end
                            end
                            break;
                        end
                    end
                end
                local mods = {};
                if #modTo.AddSpecialUnits > 0 then table.insert(mods, modTo); end
                if #modFrom.AddSpecialUnits > 0 then table.insert(mods, modFrom); end
                if #mods > 0 then
                    local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Updated dragons", {}, mods);
                    event.JumpToActionSpotOpt = WL.RectangleVM.Create((game.Map.Territories[order.To].MiddlePointX + game.Map.Territories[order.From].MiddlePointX) / 2, (game.Map.Territories[order.To].MiddlePointY + game.Map.Territories[order.From].MiddlePointY) / 2, (game.Map.Territories[order.To].MiddlePointX + game.Map.Territories[order.From].MiddlePointX) / 2, (game.Map.Territories[order.To].MiddlePointY + game.Map.Territories[order.From].MiddlePointY) / 2);
                    addNewOrder(event, true);
                end
            end
        end
    elseif order.proxyType == "GameOrderCustom" then
        if order.Payload:sub(1, #"Dragons_") == "Dragons_" then
            print(order.Payload);
            local splitData = split(order.Payload, "_");
            splitData[2] = tonumber(splitData[2]);
            splitData[3] = tonumber(splitData[3]);
            if splitData[2] ~= nil and splitData[3] ~= nil then
                if Mod.Settings.Dragons[splitData[2]].MaxNumOfDragon > getNumOfOwnedDragons(game.ServerGame.LatestTurnStanding.Territories, splitData[2], order.PlayerID) then
                    local mod = WL.TerritoryModification.Create(splitData[3]);
                    mod.AddSpecialUnits = {getDragon(order.PlayerID, splitData[2])};
                    local event = WL.GameOrderEvent.Create(order.PlayerID, "Purchased a '" .. Mod.Settings.Dragons[splitData[2]].Name .. "'", {}, {mod});
                    event.AddResourceOpt = {[order.PlayerID] = {[WL.ResourceType.Gold] = -Mod.Settings.Dragons[splitData[2]].Cost}};
                    event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[splitData[3]].MiddlePointX, game.Map.Territories[splitData[3]].MiddlePointY, game.Map.Territories[splitData[3]].MiddlePointX, game.Map.Territories[splitData[3]].MiddlePointY);
                    addNewOrder(event);
                    print("Added order!");
                else
                    addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You tried to purchase a '" .. Mod.Settings.Dragons[splitData[2]].Name .. "', but you already have the maximum of this type of dragon", ""));
                end
            else
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You tried to purchase a '" .. Mod.Settings.Dragons[splitData[2]].Name .. "', but something went wrong", ""));
            end
            skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
        end
    end
end

function tableIsEmpty(t)
    for _, _ in pairs(t) do
        return false;
    end
    return true;
end

function replaceDragon(mod, sp, v)
    local builder = WL.CustomSpecialUnitBuilder.CreateCopy(sp);
    builder.Health = builder.Health - v;
    builder.DefensePower = builder.Health;
    local t = {};
    for _, v in pairs(mod.AddSpecialUnits) do
        table.insert(t, v);
    end
    table.insert(t, builder.Build());
    mod.AddSpecialUnits = t;
    t = {};
    for _, v in pairs(mod.RemoveSpecialUnitsOpt) do
        table.insert(t, v);
    end
    table.insert(t, sp.ID);
    mod.RemoveSpecialUnitsOpt = t;
    return mod;
end

function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t,cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
 end

function getDragon(p, dragonID)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.ImageFilename = "Dragon_" .. Mod.Settings.Dragons[dragonID].ColorName .. ".png";
    builder.Name = Mod.Settings.Dragons[dragonID].Name;
    builder.IsVisibleToAllPlayers = Mod.Settings.Dragons[dragonID].IsVisibleToAllPlayers;
    builder.CanBeAirliftedToSelf = Mod.Settings.Dragons[dragonID].CanBeAirliftedToSelf;
    builder.CanBeGiftedWithGiftCard = Mod.Settings.Dragons[dragonID].CanBeGiftedWithGiftCard;
    builder.CanBeTransferredToTeammate = Mod.Settings.Dragons[dragonID].CanBeTransferredToTeammate;
    builder.CanBeAirliftedToTeammate = builder.CanBeAirliftedToSelf and builder.CanBeTransferredToTeammate;
    builder.IncludeABeforeName = Mod.Settings.Dragons[dragonID].IncludeABeforeName;
    builder.AttackPower = Mod.Settings.Dragons[dragonID].AttackPower;
    builder.AttackPowerPercentage = (Mod.Settings.Dragons[dragonID].AttackPowerPercentage / 100) + 1;
    builder.DefensePowerPercentage = (Mod.Settings.Dragons[dragonID].DefensePowerPercentage / 100) + 1;
    builder.CombatOrder = Mod.Settings.Dragons[dragonID].CombatOrder + 6971;
    if Mod.Settings.Dragons[dragonID].UseHealth then
        builder.Health = Mod.Settings.Dragons[dragonID].Health;
        if Mod.Settings.Dragons[dragonID].DynamicDefencePower then
            builder.DefensePower = Mod.Settings.Dragons[dragonID].Health;
        else
            builder.DefensePower = Mod.Settings.Dragons[dragonID].DefensePower;
        end
    else
        builder.DamageAbsorbedWhenAttacked = Mod.Settings.Dragons[dragonID].DamageAbsorbedWhenAttacked;
        builder.DamageToKill = Mod.Settings.Dragons[dragonID].DamageToKill;
        builder.DefensePower = Mod.Settings.Dragons[dragonID].DefensePower;
    end
    local s = "This unit can be identified by it's " .. Mod.Settings.Dragons[dragonID].ColorName .. " dragon icon. ";
    if Mod.Settings.Dragons[dragonID].DragonBreathAttack then
        s = s .. "It also has the powerful 'Dragon Attack' ability. Whenever this unit attacks another territory, it will deal " .. Mod.Settings.Dragons[dragonID].DragonBreathAttackDamage .. " damage to all the connected territories. Be aware of this!";
    else
        s = s .. "It does not have the 'Dragon Attack' ability, but still might be a powerful unit!";
    end
    if Mod.Settings.Dragons[dragonID].CanBeBought then
        s = s .. "\n\nThis unit can be bought with " .. Mod.Settings.Dragons[dragonID].Cost .. " gold in the purchase menu (that is the same place where you buy cities)";
    else
        s = s .. "\n\nThis unit is not for sale! You can only acquire this unit if you started with it unfortunately...";
    end
    s = s .. "\n\nEach player can have up to " .. Mod.Settings.Dragons[dragonID].MaxNumOfDragon .. " of this particular unit type. Keep this in mind to gain an advantage over your enemies!";
    builder.ModData = dataToString({UnitDescription = s});
    return builder.Build();
end

function getNumOfOwnedDragons(terrs, dragonID, p) 
    local c = 0;
    for _, terr in pairs(terrs) do
        if not tableIsEmpty(terr.NumArmies.SpecialUnits) and terr.OwnerPlayerID == p then
            for _, sp in pairs(terr.NumArmies.SpecialUnits) do
                if sp.proxyType == "CustomSpecialUnit" and sp.ModID ~= nil and sp.ModID == 594 and Mod.PublicGameData.DragonNamesIDs[sp.Name] ~= nil and Mod.PublicGameData.DragonNamesIDs[sp.Name] == dragonID then
                    c = c + 1;
                end
            end
        end
    end
    print(c);
    return c;
end