require("UI");
function Client_PresentSettingsUI(rootParent)
    Init(rootParent);

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a Landmine: " .. Mod.Settings.Cost).SetColor(colors.Tan);
    CreateLabel(root).SetText("The damage absorbed by a Landmine: " .. Mod.Settings.Percentage).SetColor(colors.Tan);
    
end