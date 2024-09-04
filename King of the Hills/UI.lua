function Init()
    Windows_JAD = {};
    UI2 = {
        LABEL = UI.CreateLabel,
        BUTTON = UI.CreateButton,
        CHECK_BOX = UI.CreateCheckBox,
        NUMBER_INPUT = UI.CreateNumberInputField,
        TEXT_INPUT = UI.CreateTextInputField,
        EMPTY = UI.CreateEmpty,
        VERTICAL_LAYOUT_GROUP = UI.CreateVerticalLayoutGroup,
        HORIZONTAL_LAYOUT_GROUP = UI.CreateHorizontalLayoutGroup
    }
end

function GetColors()
    local colors = {};					-- Stores all the built-in colors (player colors only)
    colors.Blue = "#0000FF"; colors.Purple = "#59009D"; colors.Orange = "#FF7D00"; colors["Dark Gray"] = "#606060"; colors["Hot Pink"] = "#FF697A"; colors["Sea Green"] = "#00FF8C"; colors.Teal = "#009B9D"; colors["Dark Magenta"] = "#AC0059"; colors.Yellow = "#FFFF00"; colors.Ivory = "#FEFF9B"; colors["Electric Purple"] = "#B70AFF"; colors["Deep Pink"] = "#FF00B1"; colors.Aqua = "#4EFFFF"; colors["Dark Green"] = "#008000"; colors.Red = "#FF0000"; colors.Green = "#00FF05"; colors["Saddle Brown"] = "#94652E"; colors["Orange Red"] = "#FF4700"; colors["Light Blue"] = "#23A0FF"; colors.Orchid = "#FF87FF"; colors.Brown = "#943E3E"; colors["Copper Rose"] = "#AD7E7E"; colors.Tan = "#FFAF56"; colors.Lime = "#8EBE57"; colors["Tyrian Purple"] = "#990024"; colors["Mardi Gras"] = "#880085"; colors["Royal Blue"] = "#4169E1"; colors["Wild Strawberry"] = "#FF43A4"; colors["Smoky Black"] = "#100C08"; colors.Goldenrod = "#DAA520"; colors.Cyan = "#00FFFF"; colors.Artichoke = "#8F9779"; colors["Rain Forest"] = "#00755E"; colors.Peach = "#FFE5B4"; colors["Apple Green"] = "#8DB600"; colors.Viridian = "#40826D"; colors.Mahogany = "#C04000"; colors["Pink Lace"] = "#FFDDF4"; colors.Bronze = "#CD7F32"; colors["Wood Brown"] = "#C19A6B"; colors.Tuscany = "#C09999"; colors["Acid Green"] = "#B0BF1A"; colors.Amazon = "#3B7A57"; colors["Army Green"] = "#4B5320"; colors["Donkey Brown"] = "#664C28"; colors.Cordovan = "#893F45"; colors.Cinnamon = "#D2691E"; colors.Charcoal = "#36454F"; colors.Fuchsia = "#FF00FF"; colors["Screamin' Green"] = "#76FF7A"; colors.TextColor = "#DDDDDD";
    return colors;
end

function CreateWindow(parent, name)
    local index = name or parent.id
    Windows_JAD[index] = parent;
    LastCreatedWindow_JAD = index;
    return parent;
end

function CreateSubWindow(parent, name)
    local parentWindow = LastCreatedWindow_JAD;
    CreateWindow(parent, name);
    LastCreatedWindow_JAD = parentWindow;
    return parent;
end

function DestroyWindow(name)
    name = name or LastCreatedWindow_JAD;
    if name == nil or Windows_JAD[name] == nil or UI.IsDestroyed(Windows_JAD[name]) then return; end
    UI.Destroy(Windows_JAD[name]);
    Windows_JAD[name] = nil;
	
end

function CenterObject(parent, func)
    local line = UI.CreateHorizontalLayoutGroup(parent).SetFlexibleWidth(1);
    UI.CreateEmpty(line).SetFlexibleWidth(0.5);
    local obj = func(line);
    UI.CreateEmpty(line).SetFlexibleWidth(0.5);
    return obj;
end

function CenterMultipleObjects(parent, objectNames, spaceBetweenObjects)
    local totalSpaceBetweenObjects = spaceBetweenObjects * (#objectNames - 1);
    local outsideSpace = (math.ceil(totalSpaceBetweenObjects) - totalSpaceBetweenObjects) / 2;
    if totalSpaceBetweenObjects % 1 == 0 then
        outsideSpace = 0.5;
    end
    local objects = {};

    local line = UI.CreateHorizontalLayoutGroup(parent).SetFlexibleWidth(1);
    UI.CreateEmpty(line).SetFlexibleWidth(outsideSpace);

    for name, type in pairs(objectNames) do
        objects[name] = type(line)
        UI.CreateEmpty(line).SetFlexibleWidth(spaceBetweenObjects);
    end

    UI.CreateEmpty(line).SetFlexibleWidth(outsideSpace);
    return objects;
end

function CreateInfoButtonLine(parent, func, text, color)
    color = color or "#4169E1";
    local line = UI2.HORIZONTAL_LAYOUT_GROUP(parent).SetFlexibleWidth(1);
    func(line);
    UI2.EMPTY(line).SetFlexibleWidth(1);
    UI2.BUTTON(line).SetText("?").SetColor(color).SetOnClick(function()
        UI.Alert(text);
    end);
end


function CreateVerticalLayoutGroup(parent)
	return UI.CreateVerticalLayoutGroup(parent);
end

function CreateVert(parent)
	return UI.CreateVerticalLayoutGroup(parent);
end

function CreateHorizontalLayoutGroup(parent)
	return UI.CreateHorizontalLayoutGroup(parent);
end

function CreateHorz(parent)
	return UI.CreateHorizontalLayoutGroup(parent);
end

function CreateEmpty(parent)
	return UI.CreateEmpty(parent);
end

function CreateLabel(parent)
	return UI.CreateLabel(parent);
end

function CreateButton(parent)
	return UI.CreateButton(parent);
end

function CreateCheckBox(parent)
	return UI.CreateCheckBox(parent);
end

function CreateTextInputField(parent)
	return UI.CreateTextInputField(parent);
end

function CreateNumberInputField(parent)
	return UI.CreateNumberInputField(parent);
end