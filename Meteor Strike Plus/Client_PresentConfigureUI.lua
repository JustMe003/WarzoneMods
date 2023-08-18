
require("UI");

function Client_PresentConfigureUI(rootParent)
    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    
    data = Mod.Settings.Data;
    counter = Mod.Settings.Counter;
    if data == nil then
        data = {};
        data.Normal = {};
        data.Special = {};
        counter = 1;
    end
    
    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");
    
    CreateLabel(root).SetText("Normal meteor storms").SetColor(colors.Orange);
    for i, rain in ipairs(data.Normal) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getDataString(rain)).SetColor(colors.Blue).SetOnClick(function() modifyNormal(i, rain); end)
        local line2 = CreateHorz(root);
        CreateEmpty(line2).SetPreferredWidth(20);
        local vert = CreateVert(line2);
        local showMoreButton = CreateButton(line).SetText("^").SetColor(colors.Green);
        showMoreButton.SetOnClick(function() showMoreData(rain, vert, showMoreButton); end);
        
    end
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Create New").SetColor(colors.Green).SetOnClick(function() local t = createNormal(); table.insert(data.Normal, t); modifyNormal(#data.Normal, t); end);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    CreateEmpty(root).SetPreferredHeight(10);
    
    CreateLabel(root).SetText("Doomsday meteor storms").SetColor(colors.Red);
    for i, rain in ipairs(data.Special) do
        line = CreateHorz(root);
        CreateButton(line).SetText(getSpecialDataString(rain)).SetColor(colors.Lime).SetOnClick(function() modifySpecial(i, rain) end);
        local line2 = CreateHorz(root);
        local vert = CreateVert(root);
        CreateEmpty(line2).SetPreferredWidth(20);
        local showMoreButton = CreateButton(line).SetText("^").SetColor(colors.TextColor);
        showMoreButton.SetOnClick(function() showMoreSpecialData(rain, vert, showMoreButton); end)
    end
end

function modifyNormal(index, data)
    DestroyWindow();
    SetWindow("modifyNormal");
    local inputs = {};
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() saveNormalInputs(data, inputs); showMain(); end)
    
    CreateEmpty(root).SetPreferredHeight(10)
    
    CreateLabel(root).SetText("Chance of falling each turn").SetColor(colors.TextColor);
    inputs.ChanceofFalling = CreateNumberInputField(root).SetWholeNumbers(false).SetSliderMinValue(0.1).SetSliderMaxValue(100).SetValue(data.ChanceofFalling);
    
    showGeneralInputs(data, inputs);
end

function modifySpecial(index, dats)
    DestroyWindow();
    SetWindow("modifySpecial");
    local inputs = {};
    
    CreateButton(root).SetText("Return").SetColor(colors.TextColor).SetOnClick(function() saveSpecialInputs(data, inputs); showMain(); end)
    
    local line = CreateHorz(root);
    inputs.RandomTurn = CreateCheckBox(line).SetText(" ").SetIsChecked(data.RandomTurn);
    CreateLabel(line).SetText("Random doomsday turn").SetColor(colors.TextColor);
    local vert = CreateVert(root);
    
    if data.RandomTurn then
        inputs.RandomTurn.SetOnValueChanged(function() saveFixedTurn(data, inputs); showRandomTurn(data, inputs, vert); end);
        showRandomTurn(data, inputs, vert);
    else
        showFixedTurn(data, inputs, vert, inputs.FixedTurn);
    end
    
    showGeneralInputs(data, inputs);
end

function showGeneralInputs(data, inputs)
    CreateLabel(root).SetText("Number of meteors falling").SetColor(colors.TextColor);
    inputs.NumOfMeteors = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(data.NumOfMeteors);
    
    local line = CreateHorz(root);
    local vert = CreateVert(root);
    inputs.UsesRandomMeteorNumber = CreateCheckBox(line).SetText(" ").SetIsChecked(data.UsesRandomMeteorNumber);
    CreateLabel(line).SetText("± random number of meteors").SetColor(colors.TextColor);
    
    inputs.UsesRandomMeteorNumber.SetOnValueChanged(function() showRandNumMeteor(data, inputs, vert, inputs.UsesRandomMeteorNumber); end);
    if data.UsesRandomMeteorNumber then
        showRandNumMeteor(data, inputs, vert, inputs.UsesRandomMeteorNumber);
    end
    
    CreateLabel(root).SetText("Meteor damage").SetColor(colors.TextColor);
    inputs.MeteorDamage = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(data.MeteorDamage);
    
    line = CreateHorz(root);
    inputs.CanSpawnAlien = CreateCheckBox(line).SetText(" ").SetIsChecked(data.CanSpawnAlien);
    CreateLabel(line).SetText("Meteor can spawn an alien").SetColor(colors.TextColor);
    local vert2 = CreateVert(root);
    inputs.CanSpawnAlien.SetOnValueChanged(function() showAlienConfig(data, inputs, vert2, inputs.CanSpawnAlien); end)
    if data.CanSpawnAlien then
        showAlienConfig(data, inputs, vert2, inputs.CanSpawnAlien);
    end
end

function showRandNumMeteor(data, inputs, vert, box)
    local win = GetCurrentWindow();
    local currWin = "RandNumOfMeteor";
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    box.SetOnValueChanged(function() DestroyWindow(currWin); saveRandNumMeteor(data, inputs); box.SetOnValueChanged(function() showRandNumMeteor(data, inputs, vert, box); end) end);
    
    CreateLabel(vert).SetText("± range of meteors").SetColor(colors.TextColor);
    inputs.MinMaxLimitNumRandomMeteor = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(data.MinMaxLimitNumRandomMeteor);
    
    SetWindow(win);
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
    
    box.SetOnValueChanged(function()  saveRandomTurn(data, inputs); DestroyWindow(currWin); showFixedTurn(data, inputs, vert, box); end);
    
    CreateLabel(vert).SetText("Minimum turn bound").SetColor(colors.TextColor);
    inputs.MinTurnNumber = CreateNumberInputField(vert).SetSliderMinValue(5).SetSliderMaxValue(20).SetValue(data.MinTurnNumber);
    
    CreateLabel(vert).SetText("Maximum turn bound").SetColor(colors.TextColor);
    inputs.MaxTurnNumber = CreateNumberInputField(vert).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(data.MaxTurnNumber);
    
    SetWindow(win);
end

function saveNormalInputs(data, inputs)
    data.ChanceofFalling = inputs.ChanceofFalling.GetValue();
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
end

function saveInputs(data, inputs)
    data.NumOfMeteors = inputs.NumOfMeteors.GetValue();
    data.UsesRandomMeteorNumber = inputs.UsesRandomMeteorNumber.GetIsChecked();
    if data.UsesRandomMeteorNumber then
        saveRandNumMeteor(data, inputs);
    end
    data.MeteorDamage = inputs.MeteorDamage.GetValue();
    data.CanSpawnAlien = inputs.CanSpawnAlien.GetIsChecked();
    if data.CanSpawnAlien then
        saveAlienInputs(data, inputs);
    end
end

function saveRandNumMeteor(data, inputs)
    data.MinMaxLimitNumRandomMeteor = inputs.MinMaxLimitNumRandomMeteor.GetValue();
end

function saveAlienInputs(data, inputs)
    data.AlienSpawnChance = inputs.AlienSpawnChance.GetValue();
    data.AlienDefaultHealth = inputs.AlienDefaultHealth.GetValue();
    data.AlienRandomHealth = inputs.AlienRandomHealth.GetValue();
end

function saveFixedTurn(data, inputs)
    data.FixedTurn = inputs.FixedTurn.GetValue();
end

function saveRandomTurn(data, inputs)
    data.MinTurnNumber = inputs.MinTurnNumber.GetValue();
    data.MaxTurnNumber = inputs.MaxTurnNumber.GetValue();
end

function showMoreNormalData(rain, vert, button)
    local win = GetCurrentWindow();
    local currWin = "MoreData" .. data.ID;
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    button.SetText("!").SetOnClick(function() DestroyWindow(currWin); button.SetText("^").SetOnClick(function() showMoreNormalData(data, vert, button) end) end);
    CreateLabel(vert).SetText("Chance of meteors falling: " .. round(data.ChanceofFalling, 2)).SetColor(colors.TextColor);
    
    showMoreData(rain, vert);
    
    SetWindow(win);
end

function showMoreSpecialData(rain, vert, button)
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
    
    showMoreData(rain, vert);
    
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
    local s = data.NumOfMeteors;
    if data.UsesRandomMeteorNumber then
        s = s .. " ± " .. data.MinMaxLimitNumRandomMeteor;
    end
    return s;
end

function getSpecialDataString(data)
    local s = "t ";
    if data.RandomTurn then
        s = s .. data.MinTurnNumber .. "-" .. data.MaxTurnNumber .. " | ";
    else
        s = s .. data.FixedTurn .. " | ○ ";
    end
    return s .. getNumOfMeteorsString(data) .. " | ¤ " .. data.MeteorDamage;
end

function createNormal()
    local t = initializeVariables();
    t.ChanceofFalling = 100;
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
        ID = counter;
        NumOfMeteors = 3,
        MeteorDamage = 5,
        UsesRandomMeteorNumber = false,
        MinMaxLimitNumRandomMeteor = 2,
        CanSpawnAlien = false,
        AlienSpawnChance = 20,
        AlienDefaultHealth = 10,
        AlienRandomHealth = 3
    };
    counter = counter + 1;
    return t;
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
