function Client_PresentSettingsUI(rootParent)
    local par = UI.CreateHorizontalLayoutGroup(rootParent);
    UI.CreateLabel(par)
        .SetText("The number of cities that are removed when a territory is hit with a bomb")
        .SetColor("#DDDDDD");

    UI.CreateEmpty(par)
        .SetPreferredWidth(10);
        
        UI.CreateLabel(par)
        .SetText(Mod.Settings.NumCities)
        .SetColor("#0077FF");

    UI.CreateEmpty(par)
        .SetPreferredWidth(40);
end