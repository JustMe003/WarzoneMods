require("UI");
function Client_PresentSettingsUI(rootParent)
    Init(rootParent);

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a Medic: \t" .. Mod.Settings.Cost).SetColor(colors.Tan);
    CreateLabel(root).SetText("The percentage of armies that are recovered by Medics: \t" .. Mod.Settings.Percentage).SetColor(colors.Tan);
    CreateLabel(root).SetText("The amount of armies a Medic is worth (note that it cannot be damaged, only be killed in one attack): \t" .. Mod.Settings.Health).SetColor(colors.Tan);
    CreateLabel(root).SetText("The maximum number of Medic units a player can have: \t" .. Mod.Settings.MaxUnits).SetColor(colors.Tan);


end