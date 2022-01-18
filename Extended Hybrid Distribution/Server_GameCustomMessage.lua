function Server_GameCustomMessage(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	if playerData[playerID] == nil then playerData[playerID] = {}; end
	if payload.Message == "HasSeenPlayMessage" then
		playerData[playerID].HasSeenPlayMessage = payload.Value;
	elseif payload.Message == "LastTurnSinceMessage" then
		playerData[playerID].LastTurnSinceMessage = payload.TurnNumber;
	end
	Mod.PlayerGameData = playerData;
end