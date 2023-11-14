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
        CreateButton(root).SetText(rain.Name).SetColor(colors.Aqua).SetOnClick(function() showNormalStorm(rain); end)
    end

    CreateEmpty(root).SetPreferredHeight(10);

    CreateLabel(root).SetText("There are " .. #Mod.Settings.Data.Special .. " doomsday storms").SetColor(colors.TextColor);
    for _, rain in ipairs(Mod.Settings.Data.Special) do
        CreateButton(root).SetText(rain.Name).SetColor(colors.Aqua).SetOnClick(function() showDoomsdayStorm(rain); end)
    end
end

function showNormalStorm(data, b)
    if not b then
        DestroyWindow();
        SetWindow("Normal");
    end

    showName(data);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Chance of falling:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(showDecimal(data.ChanceofFalling, 2) .. "%").SetColor(colors.Aqua);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("Every turn this storm is active, it has a chance of actually damaging the map. 100% means that every active turn the map will be damages, 50% means half of the turns the storm is active and 1% means that on average, 1 in 100 turns the map will get damaged") end)

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
        CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("This doomsday storm will be active on a random turn"); end);
        
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Minimum turn:").SetColor(colors.TextColor);
        CreateLabel(line).SetText(data.MinTurnNumber).SetColor(colors.Aqua);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("The doomsday can only become active at turn " .. data.MinTurnNumber .. " or after it"); end);
        
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Maximum turn:").SetColor(colors.TextColor);
        CreateLabel(line).SetText(data.MaxTurnNumber).SetColor(colors.Aqua);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("The doomsday will become active at or before turn " .. data.MaxTurnNumber); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors.Red);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("This doomsday storm will be active on a fixed turn") end);
    
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Fixed turn:").SetColor(colors.TextColor);
        CreateLabel(line).SetText(data.FixedTurn).SetColor(colors.Aqua);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("The doomsday will become active at turn " .. data.FixedTurn); end);    
    end

    showGeneralData(data);

    if not b then
        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
    end
end

function showName(data)
    local line = CreateLabel(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Name:").SetColor(colors.TextColor);
    CreateLabel(line).SetText(data.Name).SetColor(colors.Yellow);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("The name of the storm. Mostly used to easily identify storms from each other") end)
end

function showGeneralData(data)
    
end

function showAll() 
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
