function Server_GameCustomMessage(game, playerID, payload, setReturn)
    local data = Mod.PublicGameData;
    if data.Players == nil then data.Players = {}; end
    if not valueInTable(data.Players, payload.ID) then
        table.insert(data.Players, payload.ID);
    end
    Mod.PublicGameData = data;
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v2 == v then return true; end
    end
    return false;
end