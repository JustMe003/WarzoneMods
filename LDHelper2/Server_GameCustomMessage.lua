function Server_GameCustomMessage(game, playerID, payload, setReturn)
    print(payload.Type);
	playerData = Mod.PlayerGameData;
    if payload.Type == "SaveInputs" then
        saveInputs(playerID, payload);
    elseif payload.Type == "PickOption" then
        saveDefaultOption(playerID, payload);
    elseif payload.Type == "UpdateVersion" then
        updateVersion(game);
    end
    Mod.PlayerGameData = playerData;
end

function saveInputs(playerID, payload)
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    if playerData[playerID].SavedInputs == nil then playerData[playerID].SavedInputs = {}; end
    for key, value in pairs(payload.Data) do
        print(key, value);
        playerData[playerID].SavedInputs[key] = value;
    end
end

function saveDefaultOption(playerID, payload)
    if playerData[playerID] == nil then playerData[playerID] = {}; end
    if payload.DoNothing then playerData[playerID].NewTurnAction = "DoNothing"; end
    if payload.ShowWindow then playerData[playerID].NewTurnAction = "ShowWindow"; end
    if payload.AutoDeploy then playerData[playerID].NewTurnAction = "AutoDeploy"; end
end

function updateVersion(game)
    if Mod.PublicGameData.ModVersion == nil or Mod.PublicGameData.ModVersion < "3.0" then
        local data = Mod.PublicGameData;
        data.TerritoryToBonusMap = createTerritoryToBonusMap(game, game.Map.Territories);
        data.ModVersion = "3.0";
        Mod.PublicGameData = data;

        for p, t in pairs(playerData) do
            if t ~= nil then
                print(p);
                if t.SavedInputs ~= nil then
                    t.SavedInputs.AddAttacks = nil;
                    t.SavedInputs.MoveUnmovedArmies = false;
                    t.SavedInputs.MoveSpecialUnits = false;
                end
            end
        end
    end
end

function createTerritoryToBonusMap(game, territories)
	local t = {};
	for terrID, terr in pairs(territories) do
		t[terrID] = getSmallestBonusID(game, terr);
	end
	return t;
end

function getBonusValue(game, bonusID)
	if game.Settings.OverriddenBonuses[bonusID] ~= nil then
		return game.Settings.OverriddenBonuses[bonusID];
	else
		return game.Map.Bonuses[bonusID].Amount;
	end
end

function getSmallestBonusID(game, terr)
	local terrCount = 10000;
	local smallestBonusID = 0;
	for _, bonusID in pairs(terr.PartOfBonuses) do
		if getBonusValue(game, bonusID) ~= 0 then
			if #game.Map.Bonuses[bonusID].Territories < terrCount then
				terrCount = #game.Map.Bonuses[bonusID].Territories;
				smallestBonusID = bonusID;
			end
		end
	end
	return smallestBonusID;
end
