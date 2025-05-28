require("UI");
require("Util");

---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    Init();
    local textColor = GetColors().TextColor;
    local root = CreateVert(rootParent).SetCenter(true);
    for _, group in ipairs(Mod.Settings.Config) do
        CreateLabel(root).SetText(getGroupText(group)).SetColor(textColor);
    end
end
