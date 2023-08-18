
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
    
    for i, rain in ipairs(data.Normal) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getDataString(rain)).SetColor(colors.Blue).SetPreferredWidth(20);
        local vert = CreateVert(line2);
        local showMoreButton = CreateButton(line).SetText("^").SetColor(colors.Green);
        showMoreButton.SetOnClick(function() showMoreData(rain, vert, showMoreButton); end);
        
    end
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Create New").SetColor(colors.Green).SetOnClick(function() local t = createNormal(); table.insert(data.Normal, t); modifyNormal(#data.Normal, t); end);
    CreateEmpty(line).SetFlexibleWidth(0.5);
end

function modifyNormal(index, data)
    DestroyWindow();
    SetWindow("modifyNormal");
    local inputs = {};
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() saveNormalInputs(data, inputs); showMain(); end)
    
    CreateEmpty(root).SetPreferredHeight(10)
    
    CreateLabel(root).SetText("Chance of falling each turn").SetColor(colors.TextColor);
    inputs.ChanceofFalling = CreateNumberInputField(root).SetWholeNumbers(false).SetSliderMinValue(0.1).SetSliderMaxValue(100).SetValue(data.ChanceofFalling);
    
    showGeneralInputs(index, data, inputs);
end

function showGeneralInputs(index, data, inputs)
    CreateLabel(root).SetText("Number of meteors falling").SetColor(colors.TextColor);
    inputs.NumOfMeteors = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(data.NumOfMeteors);
    
    local line = CreateHorz(root);
    local vert = CreateVert(root);
    inputs.UsesRandomMeteorNumber = CreateCheckBox(line).SetText(" ").SetIsChecked(data.UsesRandomMeteorNumber).SetOnValueChanged(function() showRandNumMeteor(data, inputs, vert); end);
    CreateLabel(line).SetText("± random number of meteors").SetColor(colors.TextColor);
    
    CreateLabel(root).SetText("Meteor damage").SetColor(colors.TextColor);
    inputs.MeteorDamage = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(data.MeteorDamage);
    
    line = CreateHorz(root);
    inputs.CanHitSameTerrMoreThanOnce = CreateCheckBox(line).SetText(" ").SetIsChecked(data.CanHitSameTerrMoreThanOnce);
    CreateLabel(line).SetText("Meteors can hit the same territory more than once").SetColor(colors.TextColor);
end

function showRandNumMeteor(data, inputs, vert)
    local win = GetCurrentWindow();
    local currWin = "RandNunOfMeteor";
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    CreateLabel(vert).SetText("± range of meteors").SetColor(colors.TextColor);
    inputs.MinMaxLimitNumRandomMeteor = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(data.MinMaxLimitNumRandomMeteor);
    
    SetWindow(win);
end

function saveNormalInputs(data, inputs)
    data.ChanceofFalling = inputs.ChanceofFalling.GetValue();
    saveInputs(data, inputs);
end

function saveInputs(data, inputs)
    data.NumOfMeteors = inputs.NumOfMeteors.GetValue();
    data.UsesRandomMeteorNumber = inputs.UsesRandomMeteorNumber.GetIsChecked();
    if data.UsesRandomMeteorNumber then
        data.MinMaxLimitNumRandomMeteor = inputs.MinMaxLimitNumRandomMeteor.GetValue();
    end
    data.MeteorDamage = inputs.MeteorDamage.GetValue();
    data.CanHitSameTerrMoreThanOnce = inputs.CanHitSameTerrMoreThanOnce.GetIsChecked();
end

function showMoreData(data, vert, button)
    local win = GetCurrentWindow();
    local currWin = "MoreData" .. data.ID;
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    button.SetText("!").SetOnClick(function() DestroyWindow(currWin); button.SetText("^").SetOnClick(function() showMoreData(data, vert, button) end) end);
    CreateLabel(vert).SetText("Chance of meteors falling: " .. round(data.ChanceofFalling, 2)).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("Number of meteors: " .. getNumOfMeteorsString(data)).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("Meteor damage: " .. data.MeteorDamage).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("Can spawn an alien: " .. tostring(data.CanSpawnAlien)).SetColor(colors.TextColor);
    if data.CanSpawnAlien then
        CreateLabel(vert).SetText("Alien spawn chance: " .. data.AlienSpawnChance).SetColor(colors.TextColor);
        CreateLabel(vert).SetText("Number of aliens: " .. data.AlienDefaultHealth).SetColor(colors.TextColor);
        CreateLabel(vert).SetText("Random number of aliens: " .. data.AlienRandomHealth).SetColor(colors.TextColor);
    end
    
    SetWindow(win);
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
        CanHitSameTerrMoreThanOnce = false,
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
