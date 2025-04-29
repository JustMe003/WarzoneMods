function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    if not game.Settings.AutomaticTerritoryDistribution or game.Settings.CustomScenario then
        close();
        UI.Alert("This mod will not show anything if the game does not use automatic territory distribution");
        return;
    end
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    print(Mod.PublicGameData.NumOfStartingConflicts, Mod.PublicGameData.NumOfEndingConflicts, Mod.PublicGameData.NotEnoughTerritories);
    if Mod.PublicGameData.NotEnoughTerritories then
        UI.CreateLabel(vert).SetText("There were not enough territories to put every start " .. Mod.Settings.SpaceBetweenStarts .. " apart, so the mod did not even try to do this. This usually means that the map is to small and the distance between each start is to high").SetColor("#BB5555");
    else
        UI.CreateLabel(vert).SetText("At the start of the game, warzone has auto distributed the territories to the players. However, there were " .. (Mod.PublicGameData.NumOfStartingConflicts or 0) .. " territories that were " .. Mod.Settings.SpaceBetweenStarts .. " or less territories apart from eachother. This mod has been able to reduce this number to " .. (Mod.PublicGameData.NumOfEndingConflicts or (Mod.PublicGameData.NumOfStartingConflicts or 0)) .. " territories").SetColor("#DDDDDD");
    end
end
