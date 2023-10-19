function Client_SaveConfigureUI()
    if openConfig ~= "None" then
        if openConfig == "Normal" then
            saveNormalInputs(globalData[1], globalData[2]);
        else
            saveSpecialInputs(globalData[1], globalData[2]);
        end
    end
    for i, data in ipairs(conf.Special) do
        if data.MinTurnNumber > data.MaxTurnNumber then
            local x = data.MinTurnNumber;
            data.MinTurnNumber = data.MaxTurnNumber;
            data.MaxTurnNumber = x;
        end
    end
    if generalSettingsInputs ~= nil then
        saveGeneralSettings(generalSettingsInputs);
    end
    Mod.Settings.GeneralSettings = genSet;
    Mod.Settings.Data = conf;
    Mod.Settings.Counter = counter;
end
