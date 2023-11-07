require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    Init(rootParent);
    colors = GetColors();
    root = GetRoot().SetFlexibleWidth(1);
    Game = game;
    TurnNumber = game.Game.TurnNumber;

    setMaxSize(400, 500);

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Weather Forecast").SetColor(colors.Orange);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    local vert1 = CreateVert(line);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    local vert2 = CreateVert(line);
    CreateEmpty(line).SetFlexibleWidth(0.45);

    local lineVert1 = CreateHorz(vert1).SetFlexibleWidth(1);
    CreateEmpty(lineVert1).SetFlexibleWidth(1);
    CreateLabel(lineVert1).SetText("Created by: ").SetColor(colors.TextColor);
    lineVert1 = CreateHorz(vert1).SetFlexibleWidth(1);
    CreateEmpty(lineVert1).SetFlexibleWidth(1);
    CreateLabel(lineVert1).SetText("Presented by: ").SetColor(colors.TextColor);
    
    local lineVert2 = CreateHorz(vert2).SetFlexibleWidth(1);
    CreateLabel(lineVert2).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
    CreateEmpty(lineVert2).SetFlexibleWidth(1);
    lineVert2 = CreateHorz(vert2).SetFlexibleWidth(1);
    if Mod.Settings.GeneralSettings.UseDataGameCreator and Game.Settings.StartedBy ~= nil then
        CreateLabel(lineVert2).SetText(Game.Game.Players[Game.Settings.StartedBy].DisplayName(nil, false)).SetColor(getColorIfNil(Game.Game.Players[Game.Settings.StartedBy].Color.HtmlColor));
    else
        CreateLabel(lineVert2).SetText("UnFairerOrb76").SetColor(colors.Yellow);
    end
    CreateEmpty(lineVert2).SetFlexibleWidth(1);

    CreateEmpty(root).SetPreferredHeight(20);

    SetWindow("Dummy");

    showForecast();
end

function showForecast()
    DestroyWindow();
    SetWindow("Forecast");

    CreateLabel(root).SetText("Expected storms coming turn");
    for _, rain in ipairs(Mod.Settings.Data.Normal) do
        if not rain.NotEveryTurn or (TurnNumber >= rain.StartStorm and TurnNumber <= rain.EndStorm) then
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateLabel(line).SetText(rain.Name .. ": ").SetColor(colors["Light Blue"]);
            CreateEmpty(line).SetFlexibleWidth(0.1);
            createProbabilityLine(line, rain.ChanceofFalling);
            CreateEmpty(line).SetFlexibleWidth(0.1);
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showNormalStormData(rain); end);
        end
    end
    for _, rain in ipairs(Mod.Settings.Data.Special) do
        if not rain.RandomTurn and TurnNumber == rain.FixedTurn then
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateLabel(line).SetText(rain.Name .. ": ").SetColor(colors["Royal Blue"]);
            CreateEmpty(line).SetFlexibleWidth(0.1);
            createProbabilityLine(line, 100);
            CreateEmpty(line).SetFlexibleWidth(0.1);
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showSpecialStormData(rain); end);
        elseif rain.RandomTurn and TurnNumber >= rain.MinTurnNumber and TurnNumber <= rain.MaxTurnNumber then
            local line = CreateHorz(root).SetFlexibleWidth(1);
            CreateLabel(line).SetText(rain.Name .. ": ").SetColor(colors["Royal Blue"]);
            CreateEmpty(line).SetFlexibleWidth(0.1);
            createProbabilityLine(line, 100 / (rain.MaxTurnNumber - rain.MinTurnNumber + 2) * (TurnNumber - rain.MinTurnNumber + 1));
            CreateEmpty(line).SetFlexibleWidth(0.1);
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showSpecialStormData(rain); end);
        end
    end
end

function showNormalStormData(data)
    DestroyWindow();
    SetWindow("NormalData");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showForecast);
end

function showSpecialStormData(data)
    DestroyWindow();
    SetWindow("SpecialData");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showForecast);
end

function createProbabilityLine(line, p)
    local arr = {"#00ff00", "#1ee130", "#97db24", "#d0c82f", "#cfa830", "#bc8232", "#bd6937", "#d64329", "#ea1515", "#d00000", "#bb0000"}
    CreateLabel(line).SetText(showDecimal(p, 2) .. "%").SetColor(arr[math.floor((p + 0.5) / 10) + 1]);
end

function getColorIfNil(color)
    if color == nil then return colors.TextColor; end
    return color;
end

function showDecimal(x, n)
    return math.floor((x * (10^n)) + 0.5) / (10^n);
end