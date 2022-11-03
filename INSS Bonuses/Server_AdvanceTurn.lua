function Server_AdvanceTurn_Start(game, addNewOrder)
	
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local bonusOccupation = {};
    for p, _ in pairs(game.Game.PlayingPlayers) do
        bonusOccupation[p] = {};
    end
    for _, bonus in pairs(game.Map.Bonuses) do
        if Mod.PublicGameData.IsSuperBonus[bonus.ID] == nil and (Mod.Settings.UseNegativeBonuses or getBonusValue(game, bonus.ID) >= 0) then
            for p, v in pairs(getOccupationTable(game, bonus)) do
                bonusOccupation[p][bonus.ID] = v;
            end
        end
    end
    for p, t in pairs(bonusOccupation) do
        local incomeMods = {};
        for i, v in pairs(t) do
            table.insert(incomeMods, WL.IncomeMod.Create(p, getBonusValue(game, i) - #game.Map.Bonuses[i].Territories + v, "Income from controlling " .. v .. " of the " .. #game.Map.Bonuses[i].Territories .. " territories in bonus \"" .. game.Map.Bonuses[i].Name .. "\""));
        end
        if #incomeMods > 0 then
            addNewOrder(WL.GameOrderEvent.Create(p, "Adjusted income", {}, {}, {}, incomeMods));
        end
    end
end


function getBonusValue(game, bonusID)
    if game.Settings.OverriddenBonuses[bonusID] ~= nil then
        return game.Settings.OverriddenBonuses[bonusID];
    else
        return game.Map.Bonuses[bonusID].Amount;
    end
end

function getOccupationTable(game, bonus)
    local t = {};
    local owner;
    for _, terrID in pairs(bonus.Territories) do
        owner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID;
        if owner ~= WL.PlayerID.Neutral then
            if t[owner] == nil then
                t[owner] = 1;
            else
                t[owner] = t[owner] + 1;
            end
        end
    end
    if getTableLength(t) > 1 or #bonus.Territories ~= t[owner] then
        return t;
    else
        return {};
    end
end

function getTableLength(t)
    local c = 0;
    for _, _ in pairs(t) do
        c = c + 1;
    end
    return c;
end