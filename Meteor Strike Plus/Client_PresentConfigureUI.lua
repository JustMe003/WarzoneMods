
require("UI");

function Client_PresentConfigureUI(rootParent)
    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    
    data = Mod.Settings.Data;
    if data == nil then
        data = {};
        data.Normal = {};
        data.Special = {};
    end
    
    for i, rain in ipairs(data.Normal) do
        local line = CreateHorz(root);
        CreateButton(line).SetText(getDataString(rain)).SetColor(colors.Blue).SetOnClick(function() modifyNormal(i, rain); end);
        local vert = CreateVert(root);
        local showMoreButton = CreateButton(line).SetText("^").SetColor(colors.Green);
        showMoreButton.SetOnClick(function() showMoreData(rain, vert, showMoreButton); end);
        
    end
end

function showMoreData(data, vert, button)
    button.SetText("《》");
    CreateLabel(vert).SetText("Chance of meteors falling: " .. data.ChanceofFalling).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("number of meteors: " .. getNumOfMeteorsString(data));
    CreateLabel(vert).SetText("Meteor damage: " .. data.MeteorDamage).SetColor(colors.TextColor);
    CreateLabel(vert).SetText("Can spawn an alien: " .. tostring(data.CanSpawnAlien)).SetColor(colors.TextColor);
    if data.CanSpawnAlien then
        CreateLabel(vert).SetText("Alien spawn chance: " .. data.AlienSpawnChance).SetColor(colors.TextColor);
        CreateLabel(vert).SetText("Number of aliens: " .. data.AlienDefaultHealth).SetColor(colors.TextColor);
        CreateLabel(vert).SetText("Random number of aliens: " .. data.AlienRandomHealth).SetColor(colors.TextColor);
    end
    
end

function getDataString(data)
    return s = data.ChanceofFalling .. "% | ○: " .. getNumOfMeteorsString(data) .. " | ¤: " .. data.MeteorDamage;
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
    return {
        NumOfMeteors = 3,
        MeteorDamage = 5,
        UsesRandomMeteorNumber = false,
        MinMaxLimitNumRandomMeteor = 2,
        CanSpawnAlien = false,
        AlienSpawnChance = 20,
        AlienDefaultHealth = 10,
        AlienRandomHealth = 3
    };
end
