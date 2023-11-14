require("UI");

function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    colors = GetColors();
    root = GetRoot();

    showMenu();
end

function showMenu()
    DestroyWindow();
    SetWindow("MAIN");

    CreateButton(root).SetText("Show all").SetColor(colors.Green).SetOnClick(showAll);
    CreateEmpty(root).SetPreferredHeight(20);

    CreateLabel(root).SetText("There are " .. #Mod.Settings.Data.Normal .. " normal storms").SetColor(colors.TextColor);
    for _, rain in ipairs(Mod.Settings.Data.Normal) do
        CreateButton(root).SetText(rain.Name).SetColor(colors.Cyan).SetOnClick(function() showNormalStorm(rain); end)
    end

    CreateEmpty(root).SetPreferredHeight(10);

    CreateLabel(root).SetText("There are " .. #Mod.Settings.Data.Special .. " doomsday storms").SetColor(colors.TextColor);
    for _, rain in ipairs(Mod.Settings.Data.Special) do
        CreateButton(root).SetText(rain.Name).SetColor(colors.Cyan).SetOnClick(function() showDoomsdayStorm(rain); end)
    end
end

function showNormalStorm(data, b)
    if not b then
        DestroyWindow();
        SetWindow("Normal");
    end

    showName(data);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Active every turn:").SetColor(colors.TextColor);
    if data.NotEveryTurn then
        CreateLabel(line).SetText("No").SetColor(colors.Red);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("This storm is only active on a certain interval of turns"); end);
        
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Storm active:").SetColor(colors.TextColor);
        CreateLabel(line).SetText(data.StartStorm .. " - " .. data.EndStorm).SetColor(colors.Cyan);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("THe storm will be active from turn " .. data.StartStorm .. " till (and including) " .. data.EndStorm); end);
    else
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("This storm is active throughout the whole game"); end);
    end


    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Chance of falling:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(showDecimal(data.ChanceofFalling, 2) .. "%").SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("Every turn this storm is active, it has a chance of actually damaging the map. 100% means that every active turn the map will be damages, 50% means half of the turns the storm is active and 1% means that on average, 1 in 100 turns the map will get damaged"); end);

    showGeneralData(data);

    if not b then
        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
    end
end

function showDoomsdayStorm(data, b)
    if not b then
        DestroyWindow();
        SetWindow("Doomsday");
    end

    showName(data);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Random doomsday turn:").SetColor(colors.TextColor);
    if data.RandomTurn then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("This doomsday storm will be active on a random turn"); end);
        
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Active turn:").SetColor(colors.TextColor);
        CreateLabel(line).SetText(data.MinTurnNumber .. " - " .. data.MaxTurnNumber).SetColor(colors.Cyan);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("The doomsday storm will become active somwhere between turn " .. data.MinTurnNumber .. " and " .. data.MaxTurnNumber); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors.Red);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("This doomsday storm will be active on a fixed turn") end);
    
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Fixed turn:").SetColor(colors.TextColor);
        CreateLabel(line).SetText(data.FixedTurn).SetColor(colors.Cyan);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("The doomsday will become active at turn " .. data.FixedTurn); end);    
    end

    showGeneralData(data);

    if not b then
        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
    end
end

function showName(data)
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Name:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(data.Name).SetColor(colors.Yellow);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("The name of the storm. Mostly used to easily identify storms from each other") end)
end

function showGeneralData(data)
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Number of meteors:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(data.NumOfMeteors .. " + " .. data.RandomNumOfMeteor .. "?").SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert(data.NumOfMeteors .. " meteors will fall, with an additional 0 to " .. data.RandomNumOfMeteor .. " more"); end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Meteor damage:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(data.MeteorDamage).SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("The damage a meteor will inflict on a territory when hit. It takes special units into account, and when the territory is empty after the meteor landed it is turned to neutral"); end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Can spawn Alien:").SetColor(colors.TextColor);
    if data.CanSpawnAlien then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("When a meteor falls, it has a chance of spawning an Alien unit. This applies only to territories that either are neutral or turn neutral after the meteor fell"); end)
    
        showAlienData(data);
    else
        CreateLabel(line).SetText("No").SetColor(colors.Red);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("This storm will not spawn Alien units"); end)
    end
    
end

function showAlienData(data)
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Alien spawn chance:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(showDecimal(data.AlienSpawnChance, 2) .. "%").SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("The chance of an alien spawning when a meteor hits. This only happens if the territory is neutral or turns neutral because of the meteor") end)

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Alien health:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(data.AlienDefaultHealth .. " + " .. data.AlienRandomHealth .. "?").SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Aqua).SetOnClick(function() UI.Alert("Aliens have an amount of hitpoints equal to " .. data.AlienDefaultHealth .. " plus a random amount between 0 and " .. data.AlienRandomHealth); end)
end

function showAll()
    DestroyWindow();
    SetWindow("Show All");

    CreateButton(root).SetText("Close all").SetColor(colors.Orange).SetOnClick(showMenu);
    local empty;
    for _, rain in ipairs(Mod.Settings.Data.Normal) do
        showNormalStorm(rain, true);
        empty = CreateEmpty(root).SetPreferredHeight(10);
    end
    if empty ~= nil then
        UI.Destroy(empty);
        CreateEmpty(root).SetPreferredHeight(20);
    end
    for _, rain in ipairs(Mod.Settings.Data.Special) do
        showDoomsdayStorm(rain, true);
        empty = CreateEmpty(root).SetPreferredHeight(10);
    end
    if empty ~= nil then
        UI.Destroy(empty);
    end
    CreateButton(root).SetText("Close all").SetColor(colors.Orange).SetOnClick(showMenu);
end

function showDecimal(x, n)
    return math.floor((x * (10^n)) + 0.5) / (10^n);
end
