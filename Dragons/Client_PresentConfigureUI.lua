require("UI");
function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
    
    dragons = Mod.Settings.Dragons
    if dragons == nil then dragons = {}; end

    root = GetRoot().SetFlexibleWidth(1);
    colors = GetColors();
    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    for _, dragon in pairs(dragons) do
        CreateButton(root).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() modifyDragon(dragon); end);
    end

    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateButton(root).SetText("Add Dragon").SetColor(colors.Lime).SetOnClick(function() table.insert(dragons, initDragon()); modifyDragon(dragons[#dragons]) end).SetInteractable(#dragons < 5);
end

function modifyDragon(dragon)
    DestroyWindow();
    SetWindow("modifyDragon");
    
    local dragonInputs = {};
    
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Dragon name: ").SetColor(colors.Textcolor);
    dragonInputs.Name = CreateTextInputField(root).SetText(dragon.Name).SetFlexibleWidth(1);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Dragon color: ").SetColor(colors.Textcolor);
    CreateButton(line).SetText(dragon.ColorName).SetColor(dragon.Color).SetOnClick(function() changeColor(dragon) end);
    
    CreateButton(root).SetOnClick(showMain).SetColor(colors.Orange).SetText("Return");
    
end

function changeColor(dragon)
    DestroyWindow();
    SetWindow("modifyDragon");

    local c = {Blue=colors.Blue, Green=colors.Green, Red=colors.Red, Yellow=colors.Yellow, White=colors.Ivory};
    CreateLabel(root).SetText("Pick the color you want").SetColor(colors.Textcolor);
    for _, d in pairs(dragons) do
        if d ~= dragon then
            c[d.ColorName] = nil;
        end
    end
    for name, color in pairs(c) do
        CreateButton(root).SetText(name).SetColor(color).SetOnClick(function() dragon.Color = color; dragon.ColorName = name; modifyDragon(dragon); end)
    end
end

function saveDragon(dragon)

end

function initDragon()
    local t = {};
    t.Name = "New Dragon";
    local c = {colors.Blue, colors.Green, colors.Red, colors.Yellow, colors.Ivory};
    for _, dragon in ipairs(dragons) do
        for i, v in ipairs(c) do
            if v == dragon.Color then
                table.remove(c, i);
            end
        end
    end
    t.Color = c[math.random(#c)];
    t.ColorName = getColorName(t.Color);
    return t;
end

function getColorName(s)
    if s == colors.Blue then
        return "Blue";
    elseif s == colors.Red then
        return "Red";
    elseif s == colors.Green then
        return "Green";
    elseif s == colors.Yellow then
        return "Yellow";
    else
        return "White"
    end
end