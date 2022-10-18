require("Dialog");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    pd = Mod.PlayerGameData;
    getFunction(payload.Type)(game, playerID, payload, setReturn);
    Mod.PlayerGameData = pd;
end