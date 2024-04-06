function Server_StartDistribution(game, standing)
    setupData(game, standing);
end

function setupData(game, standing)
    local data = Mod.PublicGameData;
    local dieNumbers = {};
    local orderedByNumber = {};
    for i = 1, 11 do
        orderedByNumber[i] = {};
    end
    local structures = {WL.StructureType.Smelter, WL.StructureType.DigSite, WL.StructureType.Arena, WL.StructureType.Mine, WL.StructureType.MercenaryCamp}
    for terrID, _ in pairs(standing.Territories) do
        local terrStructures = standing.Territories[terrID].Structures;
        terrStructures = {};
        local rand = structures[math.random(1, 5)];
        terrStructures[rand] = 1;
        standing.Territories[terrID].Structures = terrStructures;
        local dieNumber = math.random(2, 12);
        dieNumbers[terrID] = dieNumber;
        table.insert(orderedByNumber[dieNumber - 1], terrID);
    end
    data.DieNumbers = dieNumbers;
    data.DieGroups = orderedByNumber;
    Mod.PublicGameData = data;

    local playerData = Mod.PlayerGameData;
    local resources = {"Wood", "Stone", "Metal", "Animals", "Grain"}
    for playerID, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
        local t = {};
        for _, resource in ipairs(resources) do
            t[resource] = 0;
        end
        playerData[playerID] = t;
    end
    Mod.PlayerGameData = playerData;
end