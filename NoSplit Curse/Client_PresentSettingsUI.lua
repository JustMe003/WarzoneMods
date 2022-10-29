require("UI");
function Client_PresentSettingsUI(rootParent)
    Init(rootParent);

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a No-split Curse: " .. Mod.Settings.Cost).SetColor(colors.Tan);
    CreateLabel(root).SetText("The extra gold added for the next purchase: " .. Mod.Settings.Increment).SetColor(colors.Tan);
    
end