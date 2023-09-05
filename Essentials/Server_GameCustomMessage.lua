function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	local pData = Mod.PlayerGameData;
	pData[playerID] = pData[playerID] or {};
	pData[playerID].HasSeenLinks = true;
	Mod.PlayerGameData = pData;
end