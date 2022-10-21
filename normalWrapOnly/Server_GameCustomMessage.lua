function Server_GameCustomMessage(game, playerID, payload, setReturn)
    local functions = {showMessages=setPlayerNotifications, receiveUpdate=receiveUpdate};

    functions[payload.Type](game, playerID, payload, setReturn);
end

function setPlayerNotifications(game, playerID, payload, setReturn)
    local playerData = Mod.PlayerGameData;
    if playerData == nil then playerData = {}; end
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    playerData[playerID].Notifications_JAD = payload.Value;
    playerData[playerID].LastUpdate_JAD = game.Game.ServerTime;
    Mod.PlayerGameData = playerData;
end

function receiveUpdate(game, playerID, payload, setReturn)
    local playerData = Mod.PlayerGameData;
    if playerData == nil then playerData = {}; end
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    playerData[playerID].LastUpdate_JAD = payload.TimeStamp;
    Mod.PlayerGameData = playerData;
end