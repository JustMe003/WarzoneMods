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

    CreateLabel(root).SetText("")
end

function getColorIfNil(color)
    if color == nil then return colors.TextColor; end
    return color;
end