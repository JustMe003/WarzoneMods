function Client_PresentSettingsUI(rootParent)
    local par = UI.CreateHorizontalLayoutGroup(rootParent);
    UI.CreateLabel(par)
        .SetText("When a territory is hit by a bomb card, " .. Mod.Settings.NumCities .. " cities will be removed from that territory")
        .SetColor("#DDDDDD");
end