---@diagnostic disable: undefined-field

---@class UI2
---@field LABEL fun(parent: UIObject): Label
---@field BUTTON fun(parent: UIObject): Button
---@field CHECK_BOX fun(parent: UIObject): CheckBox
---@field NUMBER_INPUT fun(parent: UIObject): NumberInputField
---@field TEXT_INPUT fun(parent: UIObject): TextInputField
---@field EMPTY fun(parent: UIObject): Empty
---@field VERTICAL_LAYOUT_GROUP fun(parent: UIObject): VerticalLayoutGroup
---@field HORIZONTAL_LAYOUT_GROUP fun(parent: UIObject): HorizontalLayoutGroup

---Initializes the necessary globals
---```
--- function Client_PresentConfigureUI(rootParent)
---     init();
---     -- The rest of the code     
---```
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

---Returns a table with all available colors for buttons
---@return table<string, string>
---```
--- --Stores the table in a global variable to allow access to it everywhere
--- colors = GetColors();
--- print(colors.Blue);     -- Prints "#0000FF"
---```
function GetColors()
    local colors = {};					-- Stores all the built-in colors (player colors only)
    colors.Blue = "#0000FF"; colors.Purple = "#59009D"; colors.Orange = "#FF7D00"; colors["Dark Gray"] = "#606060"; colors["Hot Pink"] = "#FF697A"; colors["Sea Green"] = "#00FF8C"; colors.Teal = "#009B9D"; colors["Dark Magenta"] = "#AC0059"; colors.Yellow = "#FFFF00"; colors.Ivory = "#FEFF9B"; colors["Electric Purple"] = "#B70AFF"; colors["Deep Pink"] = "#FF00B1"; colors.Aqua = "#4EFFFF"; colors["Dark Green"] = "#008000"; colors.Red = "#FF0000"; colors.Green = "#00FF05"; colors["Saddle Brown"] = "#94652E"; colors["Orange Red"] = "#FF4700"; colors["Light Blue"] = "#23A0FF"; colors.Orchid = "#FF87FF"; colors.Brown = "#943E3E"; colors["Copper Rose"] = "#AD7E7E"; colors.Tan = "#FFAF56"; colors.Lime = "#8EBE57"; colors["Tyrian Purple"] = "#990024"; colors["Mardi Gras"] = "#880085"; colors["Royal Blue"] = "#4169E1"; colors["Wild Strawberry"] = "#FF43A4"; colors["Smoky Black"] = "#100C08"; colors.Goldenrod = "#DAA520"; colors.Cyan = "#00FFFF"; colors.Artichoke = "#8F9779"; colors["Rain Forest"] = "#00755E"; colors.Peach = "#FFE5B4"; colors["Apple Green"] = "#8DB600"; colors.Viridian = "#40826D"; colors.Mahogany = "#C04000"; colors["Pink Lace"] = "#FFDDF4"; colors.Bronze = "#CD7F32"; colors["Wood Brown"] = "#C19A6B"; colors.Tuscany = "#C09999"; colors["Acid Green"] = "#B0BF1A"; colors.Amazon = "#3B7A57"; colors["Army Green"] = "#4B5320"; colors["Donkey Brown"] = "#664C28"; colors.Cordovan = "#893F45"; colors.Cinnamon = "#D2691E"; colors.Charcoal = "#36454F"; colors.Fuchsia = "#FF00FF"; colors["Screamin' Green"] = "#76FF7A"; colors.TextColor = "#DDDDDD";
    return colors;
end

---@generic T: UIObject
---Creates a new window
---@param parent T # The UI object which will enclose the entire window. This object will be returned
---@param name number | string | nil # An identifier to identify this window. Useful when you want to destroy only specific windows
---@return T # The passed parent, to allow for chaining
---```
--- function mainMenu(parent)
---     CreateWindow(parent).SetFlexibleWidth(1);
---     -- Or
---     CreateWindow(parent, "main").SetFlexibleWidth(1);
---     -- 'parent' is returned to allow for chaining
---```
function CreateWindow(parent, name)
    local index = name or parent.id
    Windows_JAD[index] = parent;
    LastCreatedWindow_JAD = index;
    return parent;
end

---Creates a sub-window in another window
---@param parent UIObject # The UI object which will enclose the entire sub-window. This object will be returned
---@param name number | string | nil # An identifier to identify this window. Useful when you want to destroy only specific windows
---@param parentWin number | string | nil # The identifier to identify the parent of this window. Defaults to the last created window
---@return UIObject # The passed parent, to allow for chaining
---```
--- function subMenu(parent)
---     -- Assume we created a window "main" before this
---     CreateSubWindow(parent).SetFlexibleWidth(1);
---     -- Or
---     CreateSubWindow(parent, "sub-window").SetFlexibleWidth(1);
---     -- Or
---     CreateSubWindow(parent, "sub-window", "main").SetFlexibleWidth(1);
---     -- Or
---     CreateSubWindow(parent, nil, "main").SetFlexibleWidth(1);
---     
---     -- All of the above will create a sub-window
---```
function CreateSubWindow(parent, name, parentWin)
    local parentWindow = parentWin or LastCreatedWindow_JAD;
    CreateWindow(parent, name);
    LastCreatedWindow_JAD = parentWindow;
    return parent;
end

---Destroys a window. If no identifier is passed, destroy last created window
---@param name number | string | nil # The identifier of the window
---```
--- function nextMenu()
---     -- First destroy last created window
---     DestroyWindow();
---     -- Or if we know the name ("main") of the window
---     DestroyWindow("main")
---```
function DestroyWindow(name)
    name = name or LastCreatedWindow_JAD;
    if name == nil or Windows_JAD[name] == nil or UI.IsDestroyed(Windows_JAD[name]) then return; end
    UI.Destroy(Windows_JAD[name]);
    Windows_JAD[name] = nil;
end

---Creates an object and centers it. Returns the created object
---@param parent UIObject # The parent of the object
---@param func fun(parent: UIObject): UIObject # Pass either a create function from UI, or one of the elements in table UI2
---@return UIObject # The created object
---```
--- -- We want to center this text
--- CenterObject(parent, UI2.LABEL).SetText("Hello, world!");
--- -- Or
--- CenterObject(parent, UI.CreateLabel).SetText("Hello, world!");
---```
function CenterObject(parent, func)
    local line = UI.CreateHorizontalLayoutGroup(parent).SetFlexibleWidth(1);
    UI.CreateEmpty(line).SetFlexibleWidth(0.5);
    local obj = func(line);
    UI.CreateEmpty(line).SetFlexibleWidth(0.5);
    return obj;
end

---Creates and centers multiple objects. Returns a table with the created objects
---@param parent UIObject # The parent of the objects
---@param objectNames table<number | string, fun(parent: UIObject): UIObject> # Table mapping the identifiers and create object functions 
---@param spaceBetweenObjects number # The space in between the objects
---@return table<number | string, UIObject> # Table mapping the identifiers and the created objects
---```
--- -- Center 2 buttons
--- local buttons = CenterMultipleObjects(parent, { Previous = UI2.BUTTON, Next = UI2.BUTTON }, 0.1);
--- -- Or
--- local buttons = CenterMultipleObjects(parent, { Previous = UI.CreateButton, Next = UI.CreateButton }, 0.1);
--- -- Now we modify the buttons
--- buttons.Previous.SetText("Previous");
--- buttons.Next.SetText("Next");
---```
function CenterMultipleObjects(parent, objectNames, spaceBetweenObjects)
    local numObjects = (function (t)
        local c = 0;
        for _, _ in pairs(t) do
            c = c + 1;
        end
        return c;
    end)(objectNames);
    if numObjects == 1 then
        for key, type in pairs(objectNames) do
            return { [key] = CenterObject(parent, type)};
        end
    end
    
    local totalSpaceBetweenObjects = spaceBetweenObjects * (numObjects - 1);
    local outsideSpace = (math.ceil(totalSpaceBetweenObjects) - totalSpaceBetweenObjects) / 2;
    if totalSpaceBetweenObjects % 1 == 0 then 
        outsideSpace = 0.5;
    end
    local objects = {};

    local line = UI.CreateHorizontalLayoutGroup(parent).SetFlexibleWidth(1);
    UI.CreateEmpty(line).SetFlexibleWidth(outsideSpace);
    
    local objectPlaced = false;
    for name, type in pairs(objectNames) do
        if objectPlaced then UI.CreateEmpty(line).SetFlexibleWidth(spaceBetweenObjects); end
        objects[name] = type(line)
        objectPlaced = true;
    end
    
    UI.CreateEmpty(line).SetFlexibleWidth(outsideSpace);
    return objects;
end

function createPageButtons(parent, pageN, maxPage, prevFunc, nextFunc, color)
    color = color or "#4169E1";
    local line = CreateHorz(parent).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Previous").SetColor("#4169E1").SetOnClick(prevFunc).SetInteractable(pageN > 1);
    CreateEmpty(line).SetFlexibleWidth(0.05);
    CreateLabel(line).SetText(pageN .. " / " .. maxPage).SetColor("#DDDDDD");
    CreateEmpty(line).SetFlexibleWidth(0.05);
    CreateButton(line).SetText("Next").SetColor("#4169E1").SetOnClick(nextFunc).SetInteractable(pageN < maxPage);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

---Creates an action button at the right side
---@param parent UIObject # The parent
---@param func fun(parent: HorizontalLayoutGroup) # A function that takes an UIObject. In this function you can create more objects to appear in the line
---@param action fun() # A callback function for when the action button is clicked
---@param actionText string # The text that will be shown in the button
---@param actionButtonColor string # The color of the button
---```
--- local label;
--- CreateActionButtonLine(parent, 
---     function(line)
---         label = CreateLabel(line).SetText("Clicking the 'X' will remove this line");
---     end, function()
---         UI.Destroy(label);
---     end, 
---     "X", 
---     "#FF0000");       -- color Red
---```
function CreateActionButtonLine(parent, func, action, actionText, actionButtonColor)
    local line = UI2.HORIZONTAL_LAYOUT_GROUP(parent).SetFlexibleWidth(1);
    func(line);
    UI2.EMPTY(line).SetFlexibleWidth(1);
    UI2.BUTTON(line).SetText(actionText or "?").SetColor(actionButtonColor or "#4169E1").SetOnClick(action);
end

---Creates an info action button, with text '?' and colored royal blue
---@param parent UIObject # The parent
---@param func fun(line: HorizontalLayoutGroup) # A function that takes an UIObject. In this function you can create more objects to appear in the line
---@param text string # The text that will be shown once the user clicks the info action button
---```
--- CreateInfoButtonLine(parent, 
---     function(line)
---         CreateLabel(line).SetText("Click the '?' button for more information");
---     end, "This is the explanation. You have clicked the button!");
---```
function CreateInfoButtonLine(parent, func, text)
    CreateActionButtonLine(parent, func, function() UI.Alert(text); end, "?", "#4169E1");
end

---Creates a delete action button, with text 'X' and colored red
---@param parent UIObject # The parent
---@param func fun(line: HorizontalLayoutGroup) # A function that takes an UIObject. In this function you can create more objects to appear in the line
---@param action fun() # Callback function that is called when the button is clicked
---```
--- local object;
--- CreateDeleteButtonLine(parent, 
---     function(line)
---         object = CreateTextInputField(line).SetText("Type here").SetPreferredWidth(200);
---     end, 
---     function()
---         UI.Destroy(object);
---         print("Object destroyed!");
---     end)
---```
function CreateDeleteButtonLine(parent, func, action)
    CreateActionButtonLine(parent, func, action, "X", colors.Red);
end

---Creates and returns a vertical layout group
---@param parent UIObject # The parent
---@return VerticalLayoutGroup # The created vertial layout group
function CreateVerticalLayoutGroup(parent)
	return UI.CreateVerticalLayoutGroup(parent);
end

---Creates and returns a vertical layout group
---@param parent UIObject # The parent
---@return VerticalLayoutGroup # The created vertical layout group
function CreateVert(parent)
	return UI.CreateVerticalLayoutGroup(parent);
end

---Creates and returns a horizontal layout group
---@param parent UIObject # The parent
---@return HorizontalLayoutGroup # The created horizontal layout group
function CreateHorizontalLayoutGroup(parent)
	return UI.CreateHorizontalLayoutGroup(parent);
end

---Creates and returns a horizontal layout group
---@param parent UIObject # The parent
---@return HorizontalLayoutGroup # The created horizontal layout group
function CreateHorz(parent)
	return UI.CreateHorizontalLayoutGroup(parent);
end

---Creates and returns an empty object
---@param parent UIObject # The parent
---@return Empty # The created empty object
function CreateEmpty(parent)
	return UI.CreateEmpty(parent);
end

---Creates and returns a label object
---@param parent UIObject # The parent
---@return Label # The created label object
function CreateLabel(parent)
	return UI.CreateLabel(parent);
end

---Creates and returns a button object
---@param parent UIObject # The parent
---@return Button # The created button object
function CreateButton(parent)
	return UI.CreateButton(parent);
end

---Creates and returns a checkbox object
---@param parent UIObject # The parent
---@return CheckBox # The created checkbox object
function CreateCheckBox(parent)
	return UI.CreateCheckBox(parent);
end

---Creates and returns a text input field
---@param parent UIObject # The parent
---@return TextInputField # The created text input field
function CreateTextInputField(parent)
	return UI.CreateTextInputField(parent);
end

---Creates and returns a number input field
---@param parent UIObject # The parent
---@return NumberInputField # The created number input field
function CreateNumberInputField(parent)
	return UI.CreateNumberInputField(parent);
end