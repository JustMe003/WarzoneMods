function Server_GameCustomMessage(game, playerID, payload, setReturn)
    if payload.Type == 0 then
        pd = Mod.PlayerGameData[playerID];
        if pd == nil then pd = {}; end
        pd.ABC_JAD = 0;
        Mod.PlayerGameData[playerID] = pd;
        return;
    end

    local functions = {showMessages=setPlayerNotifications()};

    pd = Mod.PlayerGameData;
    functions[payload.Type](game, playerID, payload, setReturn);
    Mod.PlayerGameData = pd;
end

function setPlayerNotifications(game, playerID, payload, setReturn)
    if pd == nil then pd = {}; end
    print(pd[playerID])
    if pd[playerID] == nil then pd[playerID] = {}; end
    pd[playerID].Notifications_JAD = payload.Value;
end