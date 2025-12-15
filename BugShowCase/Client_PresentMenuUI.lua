---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: integer, height: integer)
---@param setScrollable fun(hor: boolean, vert: boolean)
---@param game GameClientHook
---@param close fun()
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    local root = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1);
    
    for turn, orders in pairs(Mod.PublicGameData.Logs) do
        UI.CreateLabel(root).SetText("Turn " .. turn).SetColor("#DDDDDD");
        for _, order in pairs(orders) do
            UI.CreateLabel(root).SetText(order);
        end
    end
end