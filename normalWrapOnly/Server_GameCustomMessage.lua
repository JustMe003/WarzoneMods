function Server_GameCustomMessage(game, playerID, payload, setReturn)
    local functions = {showMessages=setPlayerNotifications};

    functions[payload.Type](game, playerID, payload, setReturn);
end

function setPlayerNotifications(game, playerID, payload, setReturn)
    local playerData = Mod.PlayerGameData;
    if playerData == nil then playerData = {}; end
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    playerData[playerID].Notifications_JAD = payload.Value;
    Mod.PlayerGameData = playerData;
end