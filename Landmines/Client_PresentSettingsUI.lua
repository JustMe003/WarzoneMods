require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    local root = GetRoot();
    local colors = GetColors();

    local line = CreateHorz(root);
    CreateLabel(line).SetText("The price of a landmine: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(Mod.Settings.UnitCost).SetColor(colors.Cyan);

    line = CreateHorz(root);
    CreateLabel(line).SetText("The damage upon exploding of a landmine: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(Mod.Settings.Damage).SetColor(colors.Cyan);
    
    line = CreateHorz(root);
    CreateLabel(line).SetText("The maximum number of landmines a player may control: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(Mod.Settings.MaxUnits).SetColor(colors.Cyan);
    
    line = CreateHorz(root);
    CreateLabel(line).SetText("The cooldown after a failed guess: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(Mod.Settings.GuessCooldown).SetColor(colors.Cyan);
end