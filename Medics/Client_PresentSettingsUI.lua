require("UI");
function Client_PresentSettingsUI(rootParent)
    Init(rootParent);

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a Medic: " .. Mod.Settings.Cost).SetColor(colors.Text);
    CreateLabel(root).SetText("The percentage of armies that are recovered by Medics: " .. Mod.Settings.Percentage).SetColor(colors.Text);
    CreateLabel(root).SetText("The amount of armies a Medic is worth: " .. Mod.Settings.Health).SetColor(colors.Text);
    CreateLabel(root).SetText("(note that a Medic cannot be damaged, only be killed in one, single attack)").SetColor(colors.Orange);
    CreateLabel(root).SetText("The maximum number of Medic units a player can have: " .. Mod.Settings.MaxUnits).SetColor(colors.Text);
    CreateLabel(root).SetText("Medics do not recover armies when attacking neutral: " .. tostring(Mod.Settings.DontAffectNeutrals or false)).SetColor(colors.Text);
end