function Server_Created(game, settings)
	data = Mod.PublicGameData;
    data.Errors = {};
    local s = Mod.Settings.DragonPlacements
    local start, ending = s:find("%[[%d]+%]");
    local mapID = nil;
    if #s > 0 then
        mapID = tonumber(s:sub(start + 1, ending - 1));
        s = s:sub(ending + 2, -1);
        data.DragonPlacements = getTable(s);
        if data.DragonPlacements == nil then data.DragonPlacements = {}; end
    end
    if data.DragonPlacements == nil then
        data.DragonPlacements = {};
    end
    if mapID == nil or game.Map.ID ~= mapID then
        table.insert(data.Errors, "The map does not correspond to the inputted data, please update the data and try again");
    end
    data.DragonNamesIDs = {};
    data.DragonBreathAttack = {};
    for _, dragon in pairs(Mod.Settings.Dragons) do
        data.DragonNamesIDs[dragon.Name] = dragon.ID;
        if dragon.DragonBreathAttack then
            data.DragonBreathAttack[dragon.ID] = dragon.DragonBreathAttackDamage;
        end
    end
    Mod.PublicGameData = data;
end