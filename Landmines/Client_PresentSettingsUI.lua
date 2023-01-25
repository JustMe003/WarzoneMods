require("UI");
function Client_PresentSettingsUI(rootParent)
    Init(rootParent);

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a Web: " .. Mod.Settings.Cost).SetColor(colors.Tan);
    CreateLabel(root).SetText("After each purchase, the cost is increased by: " .. Mod.Settings.CostIncrease).SetColor(colors.Tan);
    CreateLabel(root).SetText("The damage absorbed by a Web: " .. Mod.Settings.Percentage).SetColor(colors.Tan);
    
end