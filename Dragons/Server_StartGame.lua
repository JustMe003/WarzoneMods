function Server_StartGame(game, standing)
    data = Mod.PublicGameData;
    data.Errors = {};
    local s = Mod.Settings.DragonPlacements
    local start, ending = s:find("%[[%d]+%]");
    if #s > 0 then
        local mapID = tonumber(s:sub(start + 1, ending - 1));
        if mapID ~= nil and game.Map.ID == mapID then
            s = s:sub(ending + 2, -1);
            data.DragonPlacements = getTable(s);
            if data.DragonPlacements == nil then data.DragonPlacements = {}; end
        else
            table.insert(data.Errors, "The map does not correspond to the inputted data, please update the data and try again");
        end
    end
    if data.DragonPlacements == nil then
        data.DragonPlacements = {};
    end
    local s = standing;
    for terr, arr in pairs(data.DragonPlacements) do
        if type(terr) == type(0) and game.Map.Territories[terr] ~= nil then
            local t = {};
            for _, v in pairs(arr) do
                table.insert(t, getDragon(s.Territories[terr].OwnerPlayerID, v))
            end
            s.Territories[terr].NumArmies = s.Territories[terr].NumArmies.Add(WL.Armies.Create(0, t));
        else
            table.insert(data.Errors, "There does not exist a territory with ID [" .. terr .. "]");
        end
    end
    Mod.PublicGameData = data;
    standing = s;
end

function getDragon(p, dragonID)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.ImageFilename = "Dragon_" .. Mod.Settings.Dragons[dragonID].ColorName .. ".png";
    builder.Name = Mod.Settings.Dragons[dragonID].Name;
    builder.IsVisibleToAllPlayers = Mod.Settings.Dragons[dragonID].IsVisibleToAllPlayers;
    builder.CanBeAirliftedToSelf = Mod.Settings.Dragons[dragonID].CanBeAirliftedToSelf;
    builder.CanBeGiftedWithGiftCard = Mod.Settings.Dragons[dragonID].CanBeGiftedWithGiftCard;
    builder.IncludeABeforeName = Mod.Settings.Dragons[dragonID].IncludeABeforeName;
    builder.AttackPower = Mod.Settings.Dragons[dragonID].AttackPower;
    builder.AttackPowerPercentage = (Mod.Settings.Dragons[dragonID].AttackPowerPercentage / 100) + 1;
    builder.DefensePowerPercentage = (Mod.Settings.Dragons[dragonID].DefensePowerPercentage / 100) + 1;
    if Mod.Settings.Dragons[dragonID].UseHealth then
        builder.Health = Mod.Settings.Dragons[dragonID].Health;
        if Mod.Settings.Dragons[dragonID].DynamicDefencePower then
            builder.DefensePower = Mod.Settings.Dragons[dragonID].Health;
        else
            builder.DefensePower = Mod.Settings.Dragons[dragonID].DefensePower;
        end
    else
        builder.DamageAbsorbedWhenAttacked = Mod.Settings.Dragons[dragonID].DamageAbsorbedWhenAttacked;
        builder.DamageToKill = Mod.Settings.Dragons[dragonID].DamageToKill;
        builder.DefensePower = Mod.Settings.Dragons[dragonID].DefensePower;
    end
    
    builder.ModData = "DynamicDefencePower:" .. tostring(Mod.Settings.Dragons[dragonID].DynamicDefencePower) .. "|DragonBreathAttack" .. tostring(Mod.Settings.Dragons[dragonID].DragonBreathAttack);
    return builder.Build();
end

function getTable(s)
    local t = {};
    local key = nil;
    while #s > 0 do
        local nextChar = s:sub(1, 1);
        if nextChar == "}" then
            return t, s:sub(2, -1);
        elseif nextChar == "," then
            s = s:sub(2, -1);
        else
            local start, ending = s:find("%w+");
            if start ~= nil and ending ~= nil then
                local commandChar = s:sub(ending + 1, ending + 1);
                if commandChar == ":" then
                    key = getCorrectType(s:sub(start, ending));
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