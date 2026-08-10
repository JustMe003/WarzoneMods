require("UI");
require("PresentConfiguration");

---Client_PresentSettingsUI
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    local root = UI2.CreateVert(rootParent);

    PresentConfiguration(root, Mod.Settings);
end