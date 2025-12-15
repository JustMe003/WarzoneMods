---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: integer, height: integer)
---@param setScrollable fun(hor: boolean, vert: boolean)
---@param game GameClientHook
---@param close fun()
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    local root = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1);
    
    for turn, orders in pairs(Mod.PublicGameData.Logs) do
        local vert;
        UI.CreateButton(root).SetText("Turn " .. turn).SetColor("#0000FF").SetOnClick(function()
            if UI.IsDestroyed(vert) then
                for _, order in pairs(orders) do
                    UI.CreateLabel(vert).SetText(order);
                end
            else
                UI.Destroy(vert);
            end
        end);
        vert = UI.CreateVerticalLayoutGroup(root).SetFlexibleWidth(1);
    end
end