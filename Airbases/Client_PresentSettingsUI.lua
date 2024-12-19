function Client_PresentSettingsUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("Number of cities needed to airlift: " .. tostring(Mod.Settings.RequiredCities)).SetColor("#DDDDDD");
    UI.CreateEmpty(vert).SetPreferredHeight(5);
    UI.CreateLabel(vert).SetText("Note that both sending and receiving territiries need to have this amount of cities. When either or both territories has not enough cities, the order is cancelled").SetColor("#DDDDDD");
end