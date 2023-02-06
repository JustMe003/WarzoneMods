function Server_StartGame(game, standing)
    data = Mod.PublicGameData;
    data.Errors = {};
    local s = Mod.Settings.DragonPlacements
    local start, ending = s:find("%[[%d]+%]");
    if #s > 0 then
        local mapID = tonumber(s:sub(start + 1, ending - 1));
        if mapID ~= nil and game.Map.ID == mapID then
            s = s:sub(ending + 2, -1);
            print(s);
            data.DragonPlacements = getTable(s);
            printCompleteTable(data.DragonPlacements);
            if data.DragonPlacements == nil then data.DragonPlacements = {}; end
        else
            table.insert(data.Errors, "The map does not correspond to the inputted data, please update the data and try again");
        end
    end
    if data.DragonPlacements == nil then
        data.DragonPlacements = {};
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
    local key = nil;
    print(s);
    while #s > 0 do
        local nextChar = s:sub(1, 1);
        print(nextChar);
        if nextChar == "}" then
            print("returning");
            return t, s:sub(2, -1);
        elseif nextChar == "," then
            print("',' found");
            s = s:sub(2, -1);
        else
            local start, ending = s:find("%w+");
            if start ~= nil and ending ~= nil then
                local commandChar = s:sub(ending + 1, ending + 1);
                if commandChar == ":" then
                    key = getCorrectType(s:sub(start, ending));
                    print(key);
                    s = s:sub(ending + 2, -1);
                    local valueChar = s:sub(1, 1);
                    if valueChar == "{" then
                        t[key], s = getTable(s:sub(2, -1));
                    else
                        start, ending = s:find("%w+");
                        local value = getCorrectType(s:sub(start, ending));
                        if value ~= nil then
                            t[key] = value;
                            s = s:sub(ending + 1, -1);
                            print(key, value);
                        else
                            table.insert(data.Errors, "The inputted data didn't have the right format. DO NOT CHANGE ANYTHING MANUALLY TO THE INPUT DATA. If you didn't, please let me know so I can fix it.")
                            return t, "";
                        end
                    end
                else
                    table.insert(t, getCorrectType(s:sub(start, ending)));
                    s = s:sub(ending + 1, -1);
                end
            else
                table.insert(data.Errors, "The inputted data didn't have the right format. DO NOT CHANGE ANYTHING MANUALLY TO THE INPUT DATA. If you didn't, please let me know so I can fix it.")
                return t, "";
            end
        end
    end
    return t, s;
end

function getCorrectType(input)
    if input == nil then
        return nil;
    elseif tonumber(input) ~= nil then
        return tonumber(input);
    end
    return input;
end

function printCompleteTable(t)
    for i, v in pairs(t) do
        print(i, v);
        if type(v) == type({}) then
            printCompleteTable(v);
        end
    end
end