function Server_StartGame(game, standing)
    local data = Mod.PublicGameData;
    data.Errors = {};
    local s = Mod.Settings.DragonPlacements
    local start, ending = s:find("%[[%d]+%]");
    local mapID = tonumber(s:sub(start + 1, ending - 1));
    if mapID ~= nil and game.Map.ID == mapID then
        s = s:sub(ending + 1, -1);
        data.DragonPlacements = getTable(s);
        if data.DragonPlacements == nil then data.DragonPlacements = {}; end
    else
        table.insert(data.Errors, "The map does not correspond to the inputted data, please update the data and try again");
    end
    Mod.PublicGameData = data;
    local s = standing;
    for _, terr in pairs(s.Territories) do
        if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
            s.Territories[terr.ID].NumArmies = s.Territories[terr.ID].NumArmies.Add(WL.Armies.Create(0, {getDragon(terr.OwnerPlayerID)}))
        end
    end
    standing = s;
end

function getDragon(p)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.Name = "Dragon";
    builder.IncludeABeforeName = true;
    builder.ImageFilename = 'dragon.png';
    builder.AttackPower = 200;
    builder.DefensePower = 200;
    builder.Health = 200;
    builder.CombatOrder = 1362;
    builder.CanBeGiftedWithGiftCard = true;
    builder.CanBeTransferredToTeammate = true;
    builder.CanBeAirliftedToSelf = true;
    builder.CanBeAirliftedToTeammate = true;
    builder.IsVisibleToAllPlayers = false;
    return builder.Build();
end

function getTable(s)
    local t = {};
    while #s > 0 do
        local char = s:sub(s:find("[,:}]"));
        print(char);
        break;
    end
    return t;
end