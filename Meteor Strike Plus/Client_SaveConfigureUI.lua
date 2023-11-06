function Client_SaveConfigureUI()
    saveConfig();
    for _, data in ipairs(conf.Special) do
        if data.MinTurnNumber > data.MaxTurnNumber then
            local x = data.MinTurnNumber;
            data.MinTurnNumber = data.MaxTurnNumber;
            data.MaxTurnNumber = x;
        end
        if data.RepeatAfterMin > data.RepeatAfterMax then
            local x = data.RepeatAfterMin;
            data.RepeatAfterMin = data.RepeatAfterMax;
            data.RepeatAfterMax = x;
        end
    end
    for _, data in ipiars(conf.Normal) do
        if data.StartStorm > data.EndStorm then
            local x = data.StartStorm;
            data.StartStorm = data.EndStorm;
            data.EndStorm = x;
        end
        if data.RepeatAfterMin > data.RepeatAfterMax then
            local x = data.RepeatAfterMin;
            data.RepeatAfterMin = data.RepeatAfterMax;
            data.RepeatAfterMax = x;
        end
    end
    if generalSettingsInputs ~= nil then
        saveGeneralSettings(generalSettingsInputs);
    end
    Mod.Settings.GeneralSettings = genSet;
    Mod.Settings.Data = conf;
    Mod.Settings.Counter = counter;
end

function saveConfig()
    if openConfig ~= "None" then
        if openConfig == "Normal" then
            saveNormalInputs(globalData[1], globalData[2]);
        else
            saveSpecialInputs(globalData[1], globalData[2]);
        end
    end
    if generalSettingsInputs ~= nil then
        saveGeneralSettings(generalSettingsInputs);
    end
    openConfig = "None";
end
