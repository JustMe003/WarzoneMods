require("Dialog");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    getFunction(payload.Type)(game, playerID, payload, setReturn);
end