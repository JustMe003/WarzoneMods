require("Annotations");
require("Util");
require("DataConverter");

---Server_AdvanceTurn_Start hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Start(game, addNewOrder)
	
end

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder, skipIfSkipped?: boolean) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #PREFIX_AS2) == PREFIX_AS2 then
        -- is AS2 order
        print(order.Payload);
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
        local splits = split(order.Payload, SEPARATOR_AS2);
        if splits[2] == BUY_ARTILLERY then
            local unitType = tonumber(splits[3]);
            local terrID = tonumber(splits[4]);
            
            if unitType == nil or Mod.Settings.Artillery[unitType] == nil then
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Could not extract unit type from order", ""));
                return;
            end
            local art = Mod.Settings.Artillery[unitType];
            if terrID == nil or game.ServerGame.LatestTurnStanding.Territories[terrID] == nil then
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Could not extract territory from order", ""));
                return;
            end
            if countArtilleryOfType(game.ServerGame.LatestTurnStanding.Territories, art.Name, order.PlayerID) >= art.MaxNumOfArtillery then
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You already have the maximum number of " .. art.Name, ""));
                return;
            end
            
            local mod = WL.TerritoryModification.Create(terrID);
            mod.AddSpecialUnits = {createArtillery(art, order.PlayerID)};
            local event = WL.GameOrderEvent.Create(order.PlayerID, "Purchased " .. art.Name .. " and placed on " .. game.Map.Territories[terrID].Name, {}, {mod});
            event.JumpToActionSpotOpt = setActionSpot(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
            local t = {};
            for i, n in pairs(order.CostOpt) do
                t[i] = -n;
            end
            event.AddResourceOpt = {[order.PlayerID] = t};
            addNewOrder(event);
        elseif splits[2] == ARTILLERY_STRIKE then
            local t = {};
            local updateUnitOrders = {};
            local targetID = splits[3];

            for i = 4, #splits do
                local pair = split(splits[i], "|");
                local terrID = pair[1];
                local unitID = pair[2];
                if game.Map.Territories[terrID] == nil then
                    addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Incorrect unit territory ID, skipping unit", ""));
                    break;
                end
                local unit;
                for _, sp in pairs(game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.SpecialUnits) do
                    if sp.ID == unitID then
                        unit = sp;
                        break;
                    end
                end

                if unit == nil or not isArtillery(unit) then
                    addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Could not find unit, skipping unit", ""));
                    break;
                end
                
                table.insert(t, unit);
                local art = Mod.Settings.Artillery[nameToArtilleryID(unit.Name)];
                if art.ReloadDuration > 0 then
                    local mod = WL.TerritoryModification.Create(terrID);
                    mod.RemoveSpecialUnitsOpt = {unit.ID};
                    mod.AddSpecialUnits = {createArtillery(art, order.PlayerID, game.Game.TurnNumber + art.ReloadDuration)};
                    local event = WL.GameOrderEvent.Create(order.PlayerID, "Updated artillery unit", {}, {mod});
                    event.JumpToActionSpotOpt = setActionSpot(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
                    table.insert(updateUnitOrders, event);
                end
            end
            
            if #t > 0 then
                local fixedDamage = 0;
                local percentageDamage = 0;

                for _, unit in ipairs(t) do
                    local art = Mod.Settings.Artillery[nameToArtilleryID(unit.Name)];
                    if art.MissPercentage > 0 and math.random() <= art.MissPercentage / 100 then
                        -- miss
                        local damage;
                        if art.DealsPercentageDamage then
                            damage = math.random(art.MinimumDamage * 100, art.MaximumDamage * 100) / 10000;
                        else
                            damage = math.random(art.MinimumDamage, art.MaximumDamage);
                        end
                        local neighbours = {};
                        for connID, _ in pairs(game.Map.Territories[targetID].ConnectedTo) do
                            table.insert(neighbours, connID);
                        end
                        local missTargetID = neighbours[math.random(#neighbours)];

                        local mod = WL.TerritoryModification.Create(missTargetID);
                        if art.DealsPercentageDamage then
                            mod.AddArmies = -round(game.ServerGame.LatestTurnStanding.Territories[missTargetID].NumArmies.NumArmies * damage);
                        else
                            mod.AddArmies = -round(damage);
                        end
                        local event = WL.GameOrderEvent.Create(order.PlayerID, "Missed artillery strike on " .. game.Map.Territories[targetID].Name, {}, {mod});
                        event.JumpToActionSpotOpt = setActionSpot(game.Map.Territories[missTargetID].MiddlePointX, game.Map.Territories[missTargetID].MiddlePointY);
                        addNewOrder(event);
                    else
                        if art.DealsPercentageDamage then
                            percentageDamage = percentageDamage + math.random(art.MinimumDamage * 100, art.MaximumDamage * 100) / 10000;
                        else
                            fixedDamage = fixedDamage + math.random(art.MinimumDamage * 10000, art.MaximumDamage * 10000) / 10000;
                        end
                    end
                end
                local mod = WL.TerritoryModification.Create(targetID);
                mod.AddArmies = -round(fixedDamage);
                mod.AddArmies = mod.AddArmies - round(math.max(game.ServerGame.LatestTurnStanding.Territories[targetID].NumArmies.NumArmies - mod.AddArmies, 0) * percentageDamage);
                local event = WL.GameOrderEvent.Create(order.PlayerID, "Artillery strike on " .. game.Map.Territories[targetID].Name, {}, {mod});
                event.JumpToActionSpotOpt = setActionSpot(game.Map.Territories[targetID].MiddlePointX, game.Map.Territories[targetID].MiddlePointY);
                local cost = {};
                for i, n in pairs(order.CostOpt) do
                    cost[i] = -n;
                end
                event.AddResourceOpt = {[order.PlayerID] = cost};
                addNewOrder(event);
            else
                addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "0 units were found, skipping order", ""));
                return;
            end
            if #updateUnitOrders > 0 then
                for _, o in ipairs(updateUnitOrders) do
                    addNewOrder(o);
                end
            end
        end
    elseif order.proxyType == "GameOrderAttackTransfer" then
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
                        if isArtillery(sp) and hasDynamicHealth(nameToArtilleryID(sp.Name)) then
                            modTo = replaceArtillery(modTo, sp, v);
                        end
                        break;
                    end
                end
                for _, sp in pairs(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.SpecialUnits) do
                    if sp.ID == ID then
                        if isArtillery(sp) and hasDynamicHealth(nameToArtilleryID(sp.Name)) then
                            if orderResult.IsSuccessful then
                                modTo = replaceArtillery(modTo, sp, v);
                            else
                                modFrom = replaceArtillery(modFrom, sp, v);
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
                local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Updated Artillery", {}, mods);
                event.JumpToActionSpotOpt = WL.RectangleVM.Create((game.Map.Territories[order.To].MiddlePointX + game.Map.Territories[order.From].MiddlePointX) / 2, (game.Map.Territories[order.To].MiddlePointY + game.Map.Territories[order.From].MiddlePointY) / 2, (game.Map.Territories[order.To].MiddlePointX + game.Map.Territories[order.From].MiddlePointX) / 2, (game.Map.Territories[order.To].MiddlePointY + game.Map.Territories[order.From].MiddlePointY) / 2);
                addNewOrder(event, true);
            end
        end
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
	
end

function createArtillery(art, p, reloadTurn)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.ImageFilename = "Artillery_" .. art.ColorName .. ".png";
    builder.Name = art.Name;
    builder.IsVisibleToAllPlayers = art.IsVisibleToAllPlayers;
    builder.CanBeAirliftedToSelf = art.CanBeAirliftedToSelf;
    builder.CanBeGiftedWithGiftCard = art.CanBeGiftedWithGiftCard;
    builder.CanBeTransferredToTeammate = art.CanBeTransferredToTeammate;
    builder.CanBeAirliftedToTeammate = builder.CanBeAirliftedToSelf and builder.CanBeTransferredToTeammate;
    builder.IncludeABeforeName = art.IncludeABeforeName;
    builder.AttackPower = art.AttackPower;
    builder.AttackPowerPercentage = math.max(0, art.AttackPowerPercentage / 100) + 1;
    builder.DefensePowerPercentage = math.max(0, art.DefensePowerPercentage / 100) + 1;
    builder.CombatOrder = art.CombatOrder + 6971;
    if art.UseHealth then
        builder.Health = art.Health;
        if art.DynamicDefencePower then
            builder.DefensePower = art.Health;
        else
            builder.DefensePower = art.DefensePower;
        end
    else
        builder.DamageAbsorbedWhenAttacked = art.DamageAbsorbedWhenAttacked;
        builder.DamageToKill = art.DamageToKill;
        builder.DefensePower = art.DefensePower;
    end
    builder.ModData = DataConverter.DataToString(getModDataTable(reloadTurn or 0, art.ID), Mod);

    return builder.Build();
end

function getModDataTable(reloadTurn, artID)
    return {
        AS2 = {
            ReloadTurn = reloadTurn, 
            TypeID = artID
        }, 
        Essentials = {
            UnitDescription = "This unit can target a territory and deal damage to distant territories. Check the full settings page to see my full details"
        }
    };
end

function replaceArtillery(mod, sp, v)
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

function setActionSpot(x, y)
    WL.RectangleVM.Create(x, y, x, y);
end

function hasDynamicHealth(id)
    return Mod.Settings.Artillery[id].DynamicDefencePower;
end