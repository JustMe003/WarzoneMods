require("Catan");
require("Annotations");

---Server_StartGame hook
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    if game.Settings.AutomaticTerritoryDistribution then
        setupData(game, standing);
    end
    local data = Mod.PublicGameData;
    for terrID, terr in pairs(standing.Territories) do
        if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
            standing.Territories[terrID].Structures = {[WL.StructureType.City] = 1};
            setToVillage(data, terrID);
        end
    end
    Mod.PublicGameData = data;
    
    local playerData = Mod.PlayerGameData;
    setOrderLists(game.Game.PlayingPlayers, playerData);
    Mod.PlayerGameData = playerData;

    local privateData = Mod.PrivateGameData;
    privateData = {};
    privateData.PlayerData = {};
    setResourcesTable(game.Game.PlayingPlayers, privateData.PlayerData);
    Mod.PrivateGameData = privateData;
end