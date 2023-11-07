function Server_StartGame(game, Settings)
    local terrs = {};
    for i, _ in pairs(game.Map.Territories) do
        table.insert(terrs, i);
    end
    
    local doomsdays = {};
    for _, data in ipairs(Mod.Settings.Data.Special) do
        table.insert(doomsdays, {Turn = getDoomsdayTurn(data), Data = data});
    end

    local normalStorms = {};
    for _, data in ipairs(Mod.Settings.Data.Normal) do
        local t = createNormal(data);
        t.Data = data;
        table.insert(normalStorms, t);
    end
    
    local priv = Mod.PrivateGameData;
    priv.Territories = terrs;
    priv.Doomsdays = doomsdays;
    priv.NormalStorms = normalStorms;
    Mod.PrivateGameData = priv;
end

function getDoomsdayTurn(data)
    if data.RandomTurn then
        return math.random(0, data.MaxTurnNumber - data.MinTurnNumber) + data.MinTurnNumber;
    else
        return data.FixedTurn;
    end
end

function createNormal(data)
    local t = {};
    if data.NotEveryTurn then
        t.NotEveryTurn = true;
        t.StartStorm = data.StartStorm;
        t.EndStorm = data.EndStorm;
    else
        t.NotEveryTurn = false;
    end
    return t;
end