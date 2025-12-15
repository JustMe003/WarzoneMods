---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: integer, height: integer)
---@param setScrollable fun(hor: boolean, vert: boolean)
---@param game GameClientHook
---@param close fun()
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    local root = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1);
    
    for i = 1, game.Game.TurnNumber - 1 do
        local vert;
        UI.CreateButton(root).SetText("Turn " .. i).SetColor("#0000FF").SetOnClick(function()
            for _, order in ipairs(Mod.PublicGameData.Logs[i]) do
                UI.CreateLabel(vert).SetText(order);
            end
        end);
        vert = UI.CreateVerticalLayoutGroup(root).SetFlexibleWidth(1);
    end
end