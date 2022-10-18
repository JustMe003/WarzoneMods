require("Dialog");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    pd = Mod.PlayerGameData[playerID];
    getFunction(payload.Type)(game, playerID, payload, setReturn);
    for i, v in pairs(pd) do
        print(i, v);
    end
    Mod.PlayerGameData[playerID] = pd;
end