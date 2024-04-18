require("Catan");
require("Annotations");

---Server_StartGame hook
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    if game.Settings.AutomaticTerritoryDistribution then
        setupData(game, standing);
    end

    for i, _ in pairs(Mod.PublicGameData) do
        print(i);
    end

    local playerData = Mod.PlayerGameData;
    setOrderLists(game.Game.PlayingPlayers, playerData);
    setPlayerModifiers(game.Game.PlayingPlayers, playerData, Mod.Settings.Config);
    setPlayerResearchTrees(game.Game.PlayingPlayers, playerData, Mod.Settings.Config.ResearchTrees);
    Mod.PlayerGameData = playerData;
    
    local data = Mod.PublicGameData;
    for terrID, terr in pairs(standing.Territories) do
        terr.NumArmies = WL.Armies.Create(0);
        if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
            standing.Territories[terrID].Structures = {[WL.StructureType.City] = 1};
            print("Setting terr to village")
            setToVillage(data, terrID);
            if Mod.Settings.Config.StartInfantryPerVillage > 0 then
                local infantry = {};
                local totalUnitCount = Mod.Settings.Config.StartInfantryPerVillage;
                for i = math.min(totalUnitCount, 3), 1, -1 do
                    local c = totalUnitCount;
                    if totalUnitCount <= 3 then
                        c = 1;
                    elseif totalUnitCount > i then
                        c = math.floor(totalUnitCount / i);
                    end
                    totalUnitCount = totalUnitCount - c;
                    table.insert(infantry, createInfantryUnit(Mod.PlayerGameData[terr.OwnerPlayerID].Modifiers, terr.OwnerPlayerID, c));
                end
                terr.NumArmies = WL.Armies.Create(0, infantry);
            end
        end
    end
    Mod.PublicGameData = data;
    

    local privateData = Mod.PrivateGameData;
    privateData = {};
    privateData.PlayerData = {};
    setResourcesTable(game.Game.PlayingPlayers, privateData.PlayerData);
    Mod.PrivateGameData = privateData;
end