---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    local root = UI.CreateVerticalLayoutGroup(rootParent).SetCenter(true);
    
    local line = UI.CreateHorizontalLayoutGroup(root).SetCenter(true).SetFlexibleWidth(1);
    UI.CreateLabel(line).SetText("Number of territories between each start: ").SetColor("#DDDDDD");
    UI.CreateLabel(line).SetText(Mod.Settings.SpaceBetweenStarts).SetColor("#00BB00");
    
    UI.CreateLabel(root).SetText("Please note that this mod will try to put every start " .. Mod.Settings.SpaceBetweenStarts .. " territories apart, but will not necessarily succeed in doing so. This depends on the map (size) and the setting itself. The smaller the map or higher the value, the less likely the mod will succeed").SetColor("#DDDDDD");
end