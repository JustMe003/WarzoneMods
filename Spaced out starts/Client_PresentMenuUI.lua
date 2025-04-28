function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    if not game.Settings.AutomaticTerritoryDistribution or game.Settings.CustomScenario then
        close();
        UI.Alert("This mod will not show anything if the game does not use automatic territory distribution");
        return;
    end
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    print(Mod.PublicGameData.NumOfStartingConflicts, Mod.PublicGameData.NumOfEndingConflicts);
    UI.CreateLabel(vert).SetText("At the start of the game, warzone has auto distributed the territories to the players. However, there were " .. (Mod.PublicGameData.NumOfStartingConflicts or 0) .. " territories that were " .. Mod.Settings.SpaceBetweenStarts .. " or less territories apart from eachother. This mod has been able to reduce this number to " .. (Mod.PublicGameData.NumOfEndingConflicts or 0) .. " territories").SetColor("#DDDDDD");
end
