function Client_PresentSettingsUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("[Mod Description]");
    UI.CreateLabel(vert).SetText("Super bonuses also use this bonus system: " .. tostring(Mod.Settings.UseSuperBonuses)).SetColor("#FFAF56");
    UI.CreateLabel(vert).SetText("Negative bonuses also use this bonus system: " .. tostring(Mod.Settings.UseNegativeBonuses)).SetColor("#FFAF56");
end