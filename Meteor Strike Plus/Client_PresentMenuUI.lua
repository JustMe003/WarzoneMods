require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    Init(rootParent);
    colors = GetColors();
    root = GetRoot();
    Game = game;

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
    CreateLabel(line).SetText("Created by: ").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateLabel(line).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
    CreateEmpty(line).SetFlexibleWidth(0.45);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateLabel(line).SetText("Presented by: ").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    if Mod.Settings.GeneralSettings.UseDataGameCreator and Game.Settings.StartedBy ~= nil then
        CreateLabel(line).SetText(Game.Game.Players[Game.Settings.StartedBy].DisplayName(nil, false)).SetColor(getColorIfNil(Game.Game.Players[Game.Settings.StartedBy].Color.HtmlColor));
    else
        CreateLabel(line).SetText("UnFairerOrb76").SetColor(colors.Yellow);
    end
    CreateEmpty(line).SetFlexibleWidth(0.45);

    CreateEmpty(root).SetPreferredHeight(20);

    SetWindow("Dummy");

    showForecast();
end

function showForecast()
    DestroyWindow();
    SetWindow("Forecast");

    CreateLabel(root).SetText("Expected storms coming turn");
    for _, rain in ipairs(Mod.Settings.Data.Normal) do
        if not rain.NotEveryTurn then
            local line = CreateHorz(root);
            CreateLabel(line).SetText(rain.Name).SetColor(colors.Cyan);
            CreateLabel(line).SetText(showDecimal(rain.ChanceofFalling, 2)).SetColor(colors.Aqua);
        end
    end
end

function getColorIfNil(color)
    if color == nil then return colors.TextColor; end
    return color;
end

function showDecimal(x, n)
    return math.floor((x * (10^n)) + 0.5) / (10^n);
end