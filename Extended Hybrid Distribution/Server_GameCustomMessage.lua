function Server_GameCustomMessage(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData[playerID];
	if payload.Message == "HasSeenPlayMessage" then
		playerData.HasSeenPlayMessage = true;
	elseif payload.Message == "LastTurnSinceMessage" then
		print(payload.TurnNumber)
		playerData.LastTurnSinceMessage = payload.TurnNumber;
	end
	Mod.PlayerGameData[playerID] = playerData;
	print(playerData.LastTurnSinceMessage, playerData.HasSeenPlayMessage)
end