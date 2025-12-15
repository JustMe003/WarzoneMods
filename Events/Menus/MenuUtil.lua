MenuUtil = {};

function MenuUtil.SelectFromList(root, list, cancelAction)
    UI2.CreateButton(root).SetText("Cancel").SetColor(colors.Orange).SetOnClick(cancelAction);

    UI2.CreateEmpty(root).SetPreferredHeight(10);

    UI2.CreateLabel(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Select one of the following options").SetColor(colors.TextColor);
    
    UI2.CreateEmpty(root).SetPreferredHeight(5);

    for i, t in pairs(list) do
        MenuUtil.CreateOptionButton(root, t, i);
    end
end

function MenuUtil.SelectFromSubList(root, list, cancelAction, defaultSubList)
    local subWindowName = "OptionListMenu";
    UI2.CreateButton(root).SetText("Cancel").SetColor(colors.Orange).SetOnClick(cancelAction);

    UI2.CreateEmpty(root).SetPreferredHeight(10);

    UI2.CreateLabel(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Select one of the following options").SetColor(colors.TextColor);
    
    UI2.CreateEmpty(root).SetPreferredHeight(5);
    
    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    local categoryButtons = {};
    UI2.CreateEmpty(root).SetPreferredHeight(3);
    local vert = UI2.CreateSubWindow(UI2.CreateVert(root).SetFlexibleWidth(1), subWindowName);
    local buttonClicked = function(category, subList)
        UI2.DestroyWindow(subWindowName);
            vert = UI2.CreateSubWindow(UI2.CreateVert(root).SetFlexibleWidth(1), subWindowName);
            for cat, but in pairs(categoryButtons) do
                but.SetInteractable(cat ~= category);
            end
            for i, t in pairs(subList) do
                MenuUtil.CreateOptionButton(vert, t, i);
            end
    end
    local lastOption;

    for category, subList in pairs(list) do
        categoryButtons[category] = UI2.CreateButton(line).SetText(category).SetColor(colors.Blue).SetOnClick(function()
            buttonClicked(category, subList);
        end);
        lastOption = category;
    end

    if list[defaultSubList] then
        buttonClicked(defaultSubList, list[defaultSubList]);
    else
        buttonClicked(lastOption, list[lastOption]);
    end
end

function MenuUtil.CreateOptionButton(root, option, index)
    index = index or 0;
    if option.Info ~= nil then
        UI2.CreateInfoButtonLine(root, function(line)
            UI2.CreateButton(line).SetText(option.Name).SetColor(option.Color or MenuUtil.GetColorFromList(index)).SetOnClick(option.Action);
        end, option.Info);
    else
        UI2.CreateButton(root).SetText(option.Name).SetColor(option.Color or MenuUtil.GetColorFromList(index)).SetOnClick(option.Action);
    end
end

function MenuUtil.GetColorFromList(n)
    local list = UI2.GetButtonColors();
    n = n % getTableLength(list);
    for _, color in pairs(list) do
        if n == 0 then
            return color;
        end
        n = n - 1;
    end
    return colors.TextColor;
end

function MenuUtil.GetInvalidSlotNameString()
    return "The slot name must contain only letters A-Z, you don't need to write the word 'slot' before it";
end