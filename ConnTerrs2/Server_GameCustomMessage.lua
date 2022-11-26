function Server_GameCustomMessage(game, playerID, payload, setReturn)
	local data = Mod.PlayerGameData;
    if data == nil then data = {}; end
    if data[playerID] == nil then data[playerID] == {}; end
    data[playerID].HasSeenMessage = true;
    Mod.PlayerGameData = data;
end
