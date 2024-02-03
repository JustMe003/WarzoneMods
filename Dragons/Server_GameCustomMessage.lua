function Server_GameCustomMessage(game, playerID, payload, setReturn)
    local data = Mod.PublicGameData;
	if payload.Type == "addDragon" then
        if data.DragonPlacements[payload.TerrID] == nil then data.DragonPlacements[payload.TerrID] = {}; end
        table.insert(data.DragonPlacements[payload.TerrID], payload.DragonID);
    elseif payload.Type == "removeDragon" then
        if data.DragonPlacements[payload.TerrID] ~= nil then
            for i, dragon in pairs(data.DragonPlacements[payload.TerrID]) do
                if dragon == payload.DragonID then
                    table.remove(data.DragonPlacements[payload.TerrID]);
                    break;
                end
            end
        end
    elseif payload.Type == "updateNotification" then
        local pd = Mod.PlayerGameData;
        if pd == nil then pd = {}; end
        if pd[playerID] == nil then pd[playerID] = {}; end
        pd[playerID].HasSeenNotification = true;
        Mod.PlayerGameData = pd;
    elseif payload.Type == "hasSeenCrashMessage" then
        local pd = Mod.PlayerGameData;
        if pd == nil then pd = {}; end
        if pd[playerID] == nil then pd[playerID] = {}; end
        pd[playerID].HasSeenCrashMessage = true;
        Mod.PlayerGameData = pd;
    end
    Mod.PublicGameData = data;
    setReturn({});
end