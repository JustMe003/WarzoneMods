function Server_GameCustomMessage(game, playerID, payload, setReturn)
	if payload.Type == "addDragon" then
        local data = Mod.PublicGameData;
        if data.DragonPlacements[payload.TerrID] == nil then data.DragonPlacements[payload.TerrID] = {}; end
        table.insert(data.DragonPlacements[payload.TerrID], payload.DragonID);
        Mod.PublicGameData = data;
    end
    setReturn({});
end