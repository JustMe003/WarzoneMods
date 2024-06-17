require("Annotations");
require("UI");
require("Util")

---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    colors = GetColors();
    root = GetRoot();

    showMain();
end

function showMain()
    CreateLabel(root).SetText("The following slots have a modified amount of gold banked at the start of the game").SetColor(colors.TextColor).SetPreferredWidth(300);

    for slot, reserve in pairs(Mod.Settings.Config) do
        local line = CreateHorz(root).SetFlexibleWidth(1);
        local vert1 = CreateVert(line).SetFlexibleWidth(0.475);
        CreateEmpty(line).SetFlexibleWidth(0.05);
        local vert2 = CreateVert(line).SetFlexibleWidth(0.475);
        line = CreateHorz(vert1).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText(getSlotName(slot)).SetColor(getSlotColor(slot));
        line = CreateHorz(vert2).SetFlexibleWidth(1);
        CreateLabel(line).SetText(getReserveText(reserve)).SetColor(getReserveTextColor(reserve));
        CreateEmpty(line).SetFlexibleWidth(1);
    end
end
