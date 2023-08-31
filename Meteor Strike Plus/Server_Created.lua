function Server_GameCreated(game, settings)
    local terrs = {};
    for i, _ in pairs(game.Map.Territories) do
        table.insert(terrs, i);
    end
    
    local doomsdays = {};
    for _, data in ipairs(Mod.Settings.Data.Special) do
        table.insert(doomsdays, {Turn = getDoomsdayTurn(data), Data = data});
    end
    
    local priv = Mod.PrivateGameData;
    priv.Territories = terrs;
    priv.Doomsdays = doomsdays;
    Mod.PrivateGameData = priv;
end

function getDoomsdayTurn(data)
    if data.RandomTurn then
        return math.random(0, data.MaxTurnNumber - data.MinTurnNumber) + data.MinTurnNumber;
    else
        return data.FixedTurn;
    end
end
