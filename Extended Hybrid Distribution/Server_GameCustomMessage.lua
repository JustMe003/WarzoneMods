function Server_GameCustomMessage(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData[playerID];
	print(playerData)
	if payload.Message == "HasSeenPlayMessage" then
		playerData.HasSeenPlayMessage = true;
	elseif payload.Message == "LastTurnSinceMessage" then
		print(playerData.LastTurnSinceMessage)
		playerData.LastTurnSinceMessage = payload.TurnNumber;
	end
	Mod.PlayerGameData[playerID] = playerData;
	print(playerData.LastTurnSinceMessage, playerData.HasSeenPlayMessage)
end