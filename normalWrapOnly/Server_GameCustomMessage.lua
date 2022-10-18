require("Dialog");
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    if payload.Type == 0 then
        pd = Mod.PlayerGameData[playerID];
        if pd == nil then pd = {}; end
        pd.ABC_JAD = 0;
        Mod.PlayerGameData[playerID] = pd;
    end
    pd = Mod.PlayerGameData[playerID];
    getFunction(payload.Type)(game, playerID, payload, setReturn);
    Mod.PlayerGameData[playerID] = pd;
end