require("UI");
require("Util");

---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    Init();
    local textColor = GetColors().TextColor;
    local root = CreateVert(rootParent).SetCenter(true);
    CreateLabel(root).SetText("Note that structures will only be added to neutral a random neutral territory").SetColor(textColor);
    for _, group in ipairs(Mod.Settings.Config) do
        for i, v in pairs(group) do
            print(i, v);
        end
        CreateLabel(root).SetText(getGroupText(group)).SetColor(textColor);
    end
end
