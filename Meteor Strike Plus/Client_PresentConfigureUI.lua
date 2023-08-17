
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
    for i, rain in ipairs(data.Normal) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getDataString(rain)).SetColor(colors.Blue).SetOnClick(function() modifyNormal(i, rain); end);
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
end

function modifyNormal(index, data)
    DestroyWindow();
    SetWindow("modifyNormal");
    local inputs = {};
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() showMain(); end)
    
    CreateEmpty(root).SetPreferredHeight(10)
    
    inputs.ChanceofFalling= CreateNumberInputField(root).SetWholeNumbers(false).SetSliderMinValue(0.1).SetSliderMaxValue(100).SetValue(data.ChanceofFalling);
    
    showGeneralInputs(index, data, inputs);
end

function showGeneralInputs(index, data, inputs)
    
end

function showMoreData(data, vert, button)
    local win = GetCurrentWindow();
    local currWin = "MoreData" .. data.ID;
    AddSubWindow(win, currWin);
    SetWindow(currWin);
    
    button.SetText("《》").SetOnClick(function() DestroyWindow(currWin); button.SetText("^").SetOnClick(function() showMoreData(data, vert, button) end) end);
    CreateLabel(vert).SetText("Chance of meteors falling: " .. data.ChanceofFalling).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("number of meteors: " .. getNumOfMeteorsString(data));
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
    return data.ChanceofFalling .. "% | ○: " .. getNumOfMeteorsString(data) .. " | ¤: " .. data.MeteorDamage;
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
        CanSpawnAlien = false,
        AlienSpawnChance = 20,
        AlienDefaultHealth = 10,
        AlienRandomHealth = 3
    };
    counter = counter + 1;
    return t;
end
