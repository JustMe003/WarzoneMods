
require("UI");

function Client_PresentConfigureUI(rootParent)
    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
    colors = GetColors();
    
    conf = Mod.Settings.Data;
    counter = Mod.Settings.Counter;
    genSet = Mod.Settings.GeneralSettings;
    openConfig = "None";
    if conf == nil then
        conf = {};
        conf.Normal = {};
        conf.Special = {};
        counter = 1;
    end
    if genSet == nil then
        genSet = {};
        genSet.HitTerritoriesMultTimes = false;
        genSet.ZeroDamageTotalDestruction = false;
        genSet.UseSuprise = true;
        genSet.UseDataGameCreator = false;
        genSet.WeatherForcastMessage = "";
    end
    
    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");
    
    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Normal storms").SetColor(colors.Green).SetOnClick(function() saveConfig(); showNormalStorms(); end);
    CreateButton(line).SetText("Doomsday storms").SetColor(colors.Yellow).SetOnClick(function() saveConfig(); showDoomsdayStorms(); end);
    CreateButton(line).SetText("General settings").SetColor(colors.Blue).SetOnClick(function() saveConfig(); showGeneralSettings(); end);
    CreateEmpty(line).SetFlexibleWidth(0.5);

    CreateEmpty(root).SetPreferredHeight(20);

    SetWindow("Dummy");

    CreateLabel(root).SetText("Welcome to the Meteor Strike + mod!").SetColor(colors.TextColor);
    CreateLabel(root).SetText("Number of normal storms: " .. #conf.Normal).SetColor(colors.TextColor);
    CreateLabel(root).SetText("Number of doomsday storms: " .. #conf.Special).SetColor(colors.TextColor);
end

function showNormalStorms()
    DestroyWindow();
    SetWindow("NormalStorms");

    CreateButton(root).SetText("Create New").SetColor(colors.Green).SetOnClick(function() local t = createNormal(); table.insert(conf.Normal, t); modifyNormal(#conf.Normal, t); end);

    CreateEmpty(root).SetPreferredHeight(10);
    
    if #conf.Normal == 0 then
        CreateLabel(root).SetText("There are no normal storms yet").SetColor(colors.TextColor);
    else
        CreateLabel(root).SetText("Normal meteor storms").SetColor(colors.TextColor);
        for i, rain in ipairs(conf.Normal) do
            line = CreateHorz(root);
            CreateButton(line).SetText(getDataString(rain)).SetColor(colors.Blue).SetOnClick(function() modifyNormal(i, rain); end);
            local line2 = CreateHorz(root);
            CreateEmpty(line2).SetPreferredWidth(20);
            local vert = CreateVert(line2);
            local showMoreButton = CreateButton(line).SetText("^").SetColor(colors.Green);
            showMoreButton.SetOnClick(function() showMoreNormalData(rain, vert, showMoreButton); end)
        end
    end
end

function showDoomsdayStorms()
    DestroyWindow();
    SetWindow("DoomsdayStorms");
    
    CreateButton(root).SetText("Create New").SetColor(colors.Green).SetOnClick(function() local t = createSpecial(); table.insert(conf.Special, t); modifySpecial(#conf.Special, t); end);
    
    CreateEmpty(root).SetPreferredHeight(10);

    if #conf.Special == 0 then
        CreateLabel(root).SetText("There are no doomsday storms yet").SetColor(colors.TextColor);
    else
        CreateLabel(root).SetText("Doomsday meteor storms").SetColor(colors.TextColor);
        for i, rain in ipairs(conf.Special) do
            line = CreateHorz(root);
            CreateButton(line).SetText(getSpecialDataString(rain)).SetColor(colors.Blue).SetOnClick(function() modifySpecial(i, rain); end);
            local line2 = CreateHorz(root);
            CreateEmpty(line2).SetPreferredWidth(20);
            local vert = CreateVert(line2);
            local showMoreButton = CreateButton(line).SetText("^").SetColor(colors.Green);
            showMoreButton.SetOnClick(function() showMoreSpecialData(rain, vert, showMoreButton); end)
        end
    end
end

function showGeneralSettings()
    DestroyWindow();
    SetWindow("generalSettings");

    local inputs = {};

    local line = CreateHorz(root).SetFlexibleWidth(1);
    inputs.HitTerritoriesMultTimes = CreateCheckBox(line).SetText(" ").SetIsChecked(genSet.HitTerritoriesMultTimes);
    CreateLabel(line).SetText("Meteors can hit the same territory multiple times").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When unchecked, each territory can only be hit by 1 meteor. If checked, each territory can be hit multiple times") end);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    inputs.ZeroDamageTotalDestruction = CreateCheckBox(line).SetText(" ").SetIsChecked(genSet.ZeroDamageTotalDestruction);
    CreateLabel(line).SetText("0 damage is total destruction").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked, any meteor that deals 0 damage will wipe out everything on the territory, including turning it neutral. If unchecked, 0 damage will be applied to the territory"); end);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    inputs.UseSuprise = CreateCheckBox(line).SetText(" ").SetIsChecked(genSet.UseSuprise);
    CreateLabel(line).SetText("Allow easter egg to occur").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked, there is a small chance of a little easter egg. If unchecked, the mod will not use the easter egg"); end);

    line = CreateHorz(root).SetFlexibleWidth(1);
    inputs.UseDataGameCreator = CreateCheckBox(line).SetText(" ").SetIsChecked(genSet.UseDataGameCreator);
    CreateLabel(line).SetText("Presenter of weather forecast is game creator").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked, the name of the \"presentor\" of the weather forecast will be the name of the game creator. If unchecked, the mod will use the data of the original game creator, Unfairerorb76"); end);

    CreateLabel(root).SetText("Additional weather forecast message").SetColor(colors.TextColor);
    inputs.WeatherForcastMessage = CreateTextInputField(root).SetFlexibleWidth(1).SetPreferredWidth(300).SetPlaceholderText("Enter message here").SetText(genSet.WeatherForcastMessage).SetCharacterLimit(200);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Save").SetColor(colors.Orange).SetOnClick(function() saveGeneralSettings(inputs); end)
    CreateEmpty(line).SetFlexibleWidth(0.5);

    generalSettingsInputs = inputs;
end

function saveGeneralSettings(inputs)
    genSet.HitTerritoriesMultTimes = inputs.HitTerritoriesMultTimes.GetIsChecked();
    genSet.ZeroDamageTotalDestruction = inputs.ZeroDamageTotalDestruction.GetIsChecked();
    genSet.UseSuprise = inputs.UseSuprise.GetIsChecked();
    genSet.UseDataGameCreator = inputs.UseDataGameCreator.GetIsChecked();
    genSet.WeatherForcastMessage = inputs.WeatherForcastMessage.GetText();
end

function modifyNormal(index, data)
    DestroyWindow();
    SetWindow("modifyNormal");
    local inputs = {};
    
    openConfig = "Normal";
    globalData = {data, inputs};
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() saveNormalInputs(data, inputs); showNormalStorms(); end)
    
    CreateEmpty(root).SetPreferredHeight(10)
    
    local line = CreateHorz(root);
    inputs.NotEveryTurn = CreateCheckBox(line).SetText(" ").SetIsChecked(data.NotEveryTurn);
    CreateLabel(line).SetText("Falls only between an interval").SetColor(colors.TextColor);
    local vert = CreateVert(root);
    
    if data.NotEveryTurn then
        showEveryTurnInputs(data, inputs, vert, inputs.NotEveryTurn);
    else
        inputs.NotEveryTurn.SetOnValueChanged(function() showEveryTurnInputs(data, inputs, vert, inputs.NotEveryTurn); end);
    end

    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateLabel(root).SetText("Chance of falling each turn").SetColor(colors.TextColor);
    inputs.ChanceofFalling = CreateNumberInputField(root).SetWholeNumbers(false).SetSliderMinValue(0.1).SetSliderMaxValue(100).SetValue(data.ChanceofFalling);
    
    CreateEmpty(root).SetPreferredHeight(5);

    showGeneralInputs(data, inputs);
    
    local line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Delete").SetColor(colors.Red).SetOnClick(function() conf.Normal[index] = conf.Normal[#conf.Normal]; table.remove(conf.Normal); showMain(); end)
    CreateEmpty(line).SetFlexibleWidth(0.5);
end

function modifySpecial(index, data)
    DestroyWindow();
    SetWindow("modifySpecial");
    local inputs = {};
    
    openConfig = "Special";
    globalData = {data, inputs};
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() saveSpecialInputs(data, inputs); showDoomsdayStorms(); end)
    
    local line = CreateHorz(root);
    inputs.RandomTurn = CreateCheckBox(line).SetText(" ").SetIsChecked(data.RandomTurn);
    CreateLabel(line).SetText("Random doomsday turn").SetColor(colors.TextColor);
    local vert = CreateVert(root);
    
    if data.RandomTurn then
        showRandomTurn(data, inputs, vert, inputs.RandomTurn);
    else
        showFixedTurn(data, inputs, vert, inputs.RandomTurn);
    end
    
    CreateEmpty(root).SetPreferredHeight(5);

    showGeneralInputs(data, inputs);

    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root);
    inputs.Repeat = CreateCheckBox(line).SetText(" ").SetIsChecked(data.Repeat);
    CreateLabel(line).SetText("Repeat doomsday").SetColor(colors.TextColor);
    local vert = CreateVert(root);

    if data.Repeat then
        showRepeatInputs(data, inputs, vert, inputs.Repeat);
    else
        inputs.Repeat.SetOnValueChanged(function() showRepeatInputs(data, inputs, vert, inputs.Repeat); end)
    end
    
    line = CreateHorz(root);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Delete").SetColor(colors.Red).SetOnClick(function() conf.Special[index] = conf.Special[#conf.Special]; table.remove(conf.Special); showMain() end)
    CreateEmpty(line).SetFlexibleWidth(0.5);
end

function showGeneralInputs(data, inputs)
    CreateLabel(root).SetText("Number of meteors falling").SetColor(colors.TextColor);
    inputs.NumOfMeteors = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(data.NumOfMeteors);
    
    CreateLabel(root).SetText("Additional (random) number of meteors").SetColor(colors.TextColor);
    inputs.RandomNumOfMeteor = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(data.RandomNumOfMeteor);
    
    CreateLabel(root).SetText("Meteor damage").SetColor(colors.TextColor);
    inputs.MeteorDamage = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(data.MeteorDamage);
    
    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root);
    inputs.CanSpawnAlien = CreateCheckBox(line).SetText(" ").SetIsChecked(data.CanSpawnAlien);
    CreateLabel(line).SetText("Meteor can spawn an alien").SetColor(colors.TextColor);
    local vert2 = CreateVert(root);
    inputs.CanSpawnAlien.SetOnValueChanged(function() showAlienConfig(data, inputs, vert2, inputs.CanSpawnAlien); end)

    CreateLabel(root).SetText("Name of the meteor storm").SetColor(colors.TextColor);
    inputs.Name = CreateTextInputField(root).SetPlaceholderText("Name here").SetText(data.Name).SetFlexibleWidth(1).SetPreferredWidth(300).SetCharacterLimit(50);

    if data.CanSpawnAlien then
        showAlienConfig(data, inputs, vert2, inputs.CanSpawnAlien);
    end
end

function showAlienConfig(data, inputs, vert, box)
    local win = GetCurrentWindow();
    local currWin = "alienConfig";
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    box.SetOnValueChanged(function() DestroyWindow(currWin); saveAlienInputs(data, inputs); box.SetOnValueChanged(function()
    showAlienConfig(data, inputs, vert, box); end) end);
    
    CreateLabel(vert).SetText("Alien spawn chance").SetColor(colors.TextColor);
    inputs.AlienSpawnChance = CreateNumberInputField(vert).SetWholeNumbers(false).SetSliderMinValue(0.1).SetSliderMaxValue(100).SetValue(data.AlienSpawnChance);
    
    CreateLabel(vert).SetText("Alien default health").SetColor(colors.TextColor);
    inputs.AlienDefaultHealth = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(data.AlienDefaultHealth);
    
    CreateLabel(vert).SetText("Additional (random) health").SetColor(colors.TextColor);
    inputs.AlienRandomHealth = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(data.AlienRandomHealth);
    
    SetWindow(win);
end

function showEveryTurnInputs(data, inputs, vert, box)
    local win = GetCurrentWindow();
    local currWin = "NotEveryTurn";
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    box.SetOnValueChanged(function() saveEveryTurn(data, inputs); DestroyWindow(currWin); box.SetOnValueChanged(function() showEveryTurnInputs(data, inputs, vert, box); end); end)

    CreateLabel(vert).SetText("The number of turns after the meteors can fall").SetColor(colors.TextColor);
    inputs.StartStorm = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(data.StartStorm);
    
    CreateLabel(vert).SetText("The number of turns after the meteors stop falling").SetColor(colors.TextColor);
    inputs.EndStorm = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(data.EndStorm);

    CreateEmpty(vert).SetPreferredHeight(5);

    local line = CreateHorz(vert);
    inputs.Repeat = CreateCheckBox(line).SetText(" ").SetIsChecked(data.Repeat);
    CreateLabel(line).SetText("This interval repeats itself").SetColor(colors.TextColor);
    local vert2 = CreateVert(vert);

    if data.Repeat then
        showRepeatInputs(data, inputs, vert2, inputs.Repeat);
    else
        inputs.Repeat.SetOnValueChanged(function() showRepeatInputs(data, inputs, vert2, inputs.Repeat); end);
    end

    SetWindow(win);
end

function showFixedTurn(data, inputs, vert, box)
    local win = GetCurrentWindow();
    local currWin = "FixedTurn";
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    box.SetOnValueChanged(function() saveFixedTurn(data, inputs); DestroyWindow(currWin); showRandomTurn(data, inputs, vert, box); end);
    
    CreateLabel(vert).SetText("Doomsday turn").SetColor(colors.TextColor);
    inputs.FixedTurn = CreateNumberInputField(vert).SetSliderMinValue(5).SetSliderMaxValue(50).SetValue(data.FixedTurn);
    
    SetWindow(win);
end

function showRandomTurn(data, inputs, vert, box)
    local win = GetCurrentWindow();
    local currWin = "RandomTurn";
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    box.SetOnValueChanged(function() saveRandomTurn(data, inputs); DestroyWindow(currWin); showFixedTurn(data, inputs, vert, box); end);
    
    CreateLabel(vert).SetText("Minimum turn bound").SetColor(colors.TextColor);
    inputs.MinTurnNumber = CreateNumberInputField(vert).SetSliderMinValue(5).SetSliderMaxValue(20).SetValue(data.MinTurnNumber);
    
    CreateLabel(vert).SetText("Maximum turn bound").SetColor(colors.TextColor);
    inputs.MaxTurnNumber = CreateNumberInputField(vert).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(data.MaxTurnNumber);
    
    SetWindow(win);
end

function showRepeatInputs(data, inputs, vert, box)
    local win = GetCurrentWindow();
    local currWin = "Repeat";
    AddSubWindow(win, currWin);
    SetWindow(currWin);

    box.SetOnValueChanged(function() saveRepeatInputs(data, inputs); DestroyWindow(currWin); box.SetOnValueChanged(function() showRepeatInputs(data, inputs, vert, box); end) end);

    CreateLabel(vert).SetText("The minimum amount of turns until meteor storm is repeated").SetColor(colors.TextColor);
    inputs.RepeatAfterMin = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(data.RepeatAfterMin);
    
    CreateLabel(vert).SetText("The maximum amount of turns until meteor storm is repeated").SetColor(colors.TextColor);
    inputs.RepeatAfterMax = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(data.RepeatAfterMax);

    SetWindow(win);
end

function saveNormalInputs(data, inputs)
    data.ChanceofFalling = inputs.ChanceofFalling.GetValue();
    data.NotEveryTurn = inputs.NotEveryTurn.GetIsChecked();
    if data.NotEveryTurn then
        saveEveryTurn(data, inputs);
    end
    saveInputs(data, inputs);
end

function saveSpecialInputs(data, inputs)
    data.RandomTurn = inputs.RandomTurn.GetIsChecked();
    if data.RandomTurn then
        saveRandomTurn(data, inputs);
    else
        saveFixedTurn(data, inputs);
    end
    saveInputs(data, inputs);
    data.Repeat = inputs.Repeat.GetIsChecked();
    if data.Repeat then
        saveRepeatInputs(data, inputs);
    end
end

function saveInputs(data, inputs)
    data.Name = inputs.Name.GetText();
    data.NumOfMeteors = inputs.NumOfMeteors.GetValue();
    saveRandNumMeteor(data, inputs);
    data.MeteorDamage = inputs.MeteorDamage.GetValue();
    data.CanSpawnAlien = inputs.CanSpawnAlien.GetIsChecked();
    if data.CanSpawnAlien then
        saveAlienInputs(data, inputs);
    end
end

function saveRandNumMeteor(data, inputs)
    data.RandomNumOfMeteor = inputs.RandomNumOfMeteor.GetValue();
end

function saveAlienInputs(data, inputs)
    data.AlienSpawnChance = inputs.AlienSpawnChance.GetValue();
    data.AlienDefaultHealth = inputs.AlienDefaultHealth.GetValue();
    data.AlienRandomHealth = inputs.AlienRandomHealth.GetValue();
end

function saveEveryTurn(data, inputs)
    data.StartStorm = inputs.StartStorm.GetValue();
    data.EndStorm = inputs.EndStorm.GetValue();
    data.Repeat = inputs.Repeat.GetIsChecked();
    if data.Repeat then
        saveRepeatInputs(data, inputs);
    end
end

function saveFixedTurn(data, inputs)
    data.FixedTurn = inputs.FixedTurn.GetValue();
end

function saveRandomTurn(data, inputs)
    data.MinTurnNumber = inputs.MinTurnNumber.GetValue();
    data.MaxTurnNumber = inputs.MaxTurnNumber.GetValue();
end

function saveRepeatInputs(data, inputs)
    data.RepeatAfterMin = inputs.RepeatAfterMin.GetValue();
    data.RepeatAfterMax = inputs.RepeatAfterMax.GetValue();
end

function showMoreNormalData(data, vert, button)
    local win = GetCurrentWindow();
    local currWin = "MoreData" .. data.ID;
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    button.SetText("!").SetOnClick(function() DestroyWindow(currWin); button.SetText("^").SetOnClick(function() showMoreNormalData(data, vert, button) end) end);
    CreateLabel(vert).SetText("Chance of meteors falling: " .. round(data.ChanceofFalling, 2)).SetColor(colors.TextColor);
    
    showMoreData(data, vert);
    
    SetWindow(win);
end

function showMoreSpecialData(data, vert, button)
    local win = GetCurrentWindow();
    local currWin = "MoreData" .. data.ID;
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    button.SetText("!").SetOnClick(function() DestroyWindow(currWin); button.SetText("^").SetOnClick(function() showMoreSpecialData(data, vert, button) end) end);
    
    CreateLabel(vert).SetText("Random doomsday turn: " .. tostring(data.RandomTurn)).SetColor(colors.TextColor);
    if data.RandomTurn then
        CreateLabel(vert).SetText("Doomsday turn: " .. data.MinTurnNumber .. "-" .. data.MaxTurnNumber).SetColor(colors.TextColor);
    else
        CreateLabel(vert).SetText("Doomsday turn: " .. data.FixedTurn).SetColor(colors.TextColor);
    end
    
    showMoreData(data, vert);
    
    SetWindow(win);
end

function showMoreData(data, vert)
    CreateLabel(vert).SetText("Number of meteors: " .. getNumOfMeteorsString(data)).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("Meteor damage: " .. data.MeteorDamage).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("Can spawn an alien: " .. tostring(data.CanSpawnAlien)).SetColor(colors.TextColor);
    if data.CanSpawnAlien then
        CreateLabel(vert).SetText("Alien spawn chance: " .. data.AlienSpawnChance).SetColor(colors.TextColor);
        CreateLabel(vert).SetText("Number of aliens: " .. data.AlienDefaultHealth).SetColor(colors.TextColor);
        CreateLabel(vert).SetText("Random number of aliens: " .. data.AlienRandomHealth).SetColor(colors.TextColor);
    end
end

function getDataString(data)
    return round(data.ChanceofFalling, 2) .. "% | ○ " .. getNumOfMeteorsString(data) .. " | ¤ " .. data.MeteorDamage;
end

function getNumOfMeteorsString(data)
    return data.NumOfMeteors .. " + " .. data.RandomNumOfMeteor .. "?";
end

function getSpecialDataString(data)
    local s = "t ";
    if data.RandomTurn then
        s = s .. data.MinTurnNumber .. "-" .. data.MaxTurnNumber .. " | ○ ";
    else
        s = s .. data.FixedTurn .. " | ○ ";
    end
    return s .. getNumOfMeteorsString(data) .. " | ¤ " .. data.MeteorDamage;
end

function createNormal()
    local t = initializeVariables();
    t.ChanceofFalling = 100;
    t.NotEveryTurn = false;
    t.StartStorm = 5;
    t.EndStorm = 20;
    return t;
end

function createSpecial()
    local t = initializeVariables();
    t.RandomTurn = false;
    t.FixedTurn = 20;
    t.MinTurnNumber = 10;
    t.MaxTurnNumber = 30;
    return t;
end

function initializeVariables()
    local t = {
        ID = counter,
        Name = "Meteor storm " .. counter,
        NumOfMeteors = 3,
        MeteorDamage = 5,
        RandomNumOfMeteor = 2,
        CanSpawnAlien = false,
        AlienSpawnChance = 20,
        AlienDefaultHealth = 10,
        AlienRandomHealth = 3,
        Repeat = false,
        RepeatAfterMin = 10,
        RepeatAfterMax = 20,
    };
    counter = counter + 1;
    return t;
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
