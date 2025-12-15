HomeButtons = {};

---Creates home buttons in the given parent
---@param par UIObject
---@return HorizontalLayoutGroup
function HomeButtons.Create(par)
    local line = UI2.CreateHorz(par).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(History.GetPreviousWindow).SetInteractable(History.GetHasPreviousWindow());
    UI2.CreateButton(line).SetText("Home").SetColor(colors.Lime).SetOnClick(History.GetFirstWindow);
    return line;
end