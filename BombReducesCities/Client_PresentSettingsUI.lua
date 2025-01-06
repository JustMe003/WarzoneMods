function Client_PresentSettingsUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert)
        .SetText("The number of cities that are removed when a territory is hit with a bomb")
        .SetColor("#DDDDDD");

    UI.Createlabel(vert)
        .SetText(Mod.Settings.NumCities)
        .SetColor("#0077FF");
end