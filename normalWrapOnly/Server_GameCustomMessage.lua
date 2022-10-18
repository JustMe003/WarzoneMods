require("Dialog");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    pd = Mod.PlayerGameData[playerID];
    getFunction(payload.Type)(game, playerID, payload, setReturn);
    Mod.PlayerGameData[playerID] = pd;
end