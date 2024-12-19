function Client_PresentSettingsUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("Number of cities required to airlift: " .. tostring(Mod.Settings.RequiredCities)).SetColor("#DDDDDD");
end