function Server_GameCustomMessage(game, playerID, payload, setReturn)
    print(payload.Type);
	playerData = Mod.PlayerGameData;
    if payload.Type == "SaveInputs" then
        saveInputs(playerID, payload);
    elseif payload.Type == "PickOption" then
        saveDefaultOption(playerID, payload);
    end
    Mod.PlayerGameData = playerData;
end

function saveInputs(playerID, payload)
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    if playerData[playerID].SavedInputs == nil then playerData[playerID].SavedInputs = {}; end
    for key, value in pairs(payload.Data) do
        playerData[playerID].SavedInputs[key] = value;
    end
end

function saveDefaultOption(playerID, payload)
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    if payload.DoNothing then playerData[playerID].NewTurnAction = "DoNothing"; end
    if payload.ShowWindow then playerData[playerID].NewTurnAction = "ShowWindow"; end
    if payload.AutoDeploy then playerData[playerID].NewTurnAction = "AutoDeploy"; end
end