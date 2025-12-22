
---@class UI2 : UI
---@field GetButtonColors fun(): UIButtonColors
---@field GetGrayColors fun(): UIGrayColors
---@field GetColors fun(): UIColors
---@field CreateWindow fun(parent: UIObject, name: windowIdentifier): UIObject
---@field CreateSubWindow fun(parent: UIObject, name: windowIdentifier, parentWin: windowIdentifier): UIObject
---@field DestroyWindow fun(name: windowIdentifier)
---@field CreatePageButtons fun(parent: UIObject, pageN: integer, maxPage: integer, prevFunc: fun(), nextFunc: fun(), color: string | nil)
---@field CreateActionButtonLine fun(parent: UIObject, func: fun(line: HorizontalLayoutGroup), action: fun(), actionText: string, actionButtonColor: string | nil)
---@field CreateInfoButtonLine fun(parent: UIObject, func: fun(line: HorizontalLayoutGroup), info: string)
---@field CreateDeleteButtonLine fun(parent: UIObject, func: fun(line: HorizontalLayoutGroup), delete: fun())
---@field canReadObject fun(object: UIObject): boolean
---@field NewDialog fun(id: string | number, rootParent: RootParent, close: fun())
---@field CloseDialog fun(id: string | number)
---@field CloseAllDialogs fun()
---@field CreateVert fun(parent: UIObject): VerticalLayoutGroup
---@field CreateHorz fun(parent: UIObject): HorizontalLayoutGroup

---@alias windowIdentifier string | number | nil

local Windows_JAD = {};
local Dialogs_JAD = {};
local LastCreatedWindow_JAD = nil;

---@type UI2
---@diagnostic disable-next-line: missing-fields
UI2 = {};
setmetatable(UI2, {
    __index = UI;
}); 



---Returns a table with all available colors for buttons
---@return UIButtonColors
---```
--- --Stores the table in a global variable to allow access to it everywhere
--- colors = GetColors();
--- print(colors.Blue);     -- Prints "#0000FF"
---```
function UI2.GetButtonColors()
    return {
        Blue = "#0000FF"; 
        Purple = "#59009D"; 
        Orange = "#FF7D00"; 
        DarkGray = "#606060"; 
        HotPink = "#FF697A"; 
        SeaGreen = "#00FF8C"; 
        Teal = "#009B9D"; 
        DarkMagenta = "#AC0059"; 
        Yellow = "#FFFF00"; 
        Ivory = "#FEFF9B"; 
        ElectricPurple = "#B70AFF"; 
        DeepPink = "#FF00B1"; 
        Aqua = "#4EFFFF"; 
        DarkGreen = "#008000"; 
        Red = "#FF0000"; 
        Green = "#00FF05"; 
        SaddleBrown = "#94652E"; 
        OrangeRed = "#FF4700"; 
        LightBlue = "#23A0FF"; 
        Orchid = "#FF87FF"; 
        Brown = "#943E3E"; 
        CopperRose = "#AD7E7E"; 
        Tan = "#FFAF56"; 
        Lime = "#8EBE57"; 
        TyrianPurple = "#990024"; 
        MardiGras = "#880085"; 
        RoyalBlue = "#4169E1"; 
        WildStrawberry = "#FF43A4"; 
        SmokyBlack = "#100C08"; 
        Goldenrod = "#DAA520"; 
        Cyan = "#00FFFF"; 
        Artichoke = "#8F9779"; 
        RainForest = "#00755E"; 
        Peach = "#FFE5B4"; 
        AppleGreen = "#8DB600"; 
        Viridian = "#40826D"; 
        Mahogany = "#C04000";
        PinkLace = "#FFDDF4";
        Bronze = "#CD7F32";
        WoodBrown = "#C19A6B";
        Tuscany = "#C09999";
        AcidGreen = "#B0BF1A";
        Amazon = "#3B7A57";
        ArmyGreen = "#4B5320";
        DonkeyBrown = "#664C28";
        Cordovan = "#893F45";
        Cinnamon = "#D2691E";
        Charcoal = "#36454F";
        Fuchsia = "#FF00FF";
        ScreaminGreen = "#76FF7A";
    };
end

---Returns a table with all the gray colors for text
---@return UIGrayColors
---```
--- -- Get gray colors
--- local grayColors = GetGrayColors();
--- CreateLabel(parent).SetText("This text is slightly more white!").SetColor(grayColors.TextLight);
---```
function UI2.GetGrayColors()
    return {
        TextLighter = "#EEEEEE";
        TextLight = "#DDDDDD";
        TextDefault = "#CCCCCC";
        TextDark = "#BBBBBB";
        TextDarker = "#AAAAAA";
        TextColor = "#DDDDDD";
    };
end

---Get all UI colors
---@return UIColors
---```
--- -- Get and save the colors
--- local colors = GetColors();
--- CreateButton(parent).SetText("Press me!").SetColor(colors.Orange).SetTextColor(colors.TextDefault)
---```
function UI2.GetColors()
    local buttonColors = UI2.GetButtonColors();
    setmetatable(buttonColors, {
        __index = UI2.GetGrayColors();      -- If index is not found, try to take index of UIGrayColors
    });
    ---@cast buttonColors UIColors
    return buttonColors;
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
function UI2.CreateWindow(parent, name)
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
function UI2.CreateSubWindow(parent, name, parentWin)
    local parentWindow = parentWin or LastCreatedWindow_JAD;
    UI2.CreateWindow(parent, name);
    LastCreatedWindow_JAD = parentWindow;
    return parent;
end

---Destroys a window. If no identifier is passed, destroys last created window
---@param name number | string | nil # The identifier of the window
---```
--- function nextMenu()
---     -- First destroy last created window
---     DestroyWindow();
---     -- Or if we know the name ("main") of the window
---     DestroyWindow("main")
---```
function UI2.DestroyWindow(name)
    name = name or LastCreatedWindow_JAD;
    if name == nil or Windows_JAD[name] == nil or UI2.IsDestroyed(Windows_JAD[name]) then return; end
    UI2.Destroy(Windows_JAD[name]);
    Windows_JAD[name] = nil;
end

---Creates buttons that allow you to paginize windows
---@param parent UIObject # The parent object
---@param pageN integer # The current page number
---@param maxPage integer # The number of pages that exist
---@param prevFunc fun() # A 0 argument callback function, invoked when the user interacts with the [Previous] button
---@param nextFunc fun() # A 0 argument callback function, invoked when the user interacts with the [Next] button
---@param color string | nil # Optional color for the buttons. If none specified, it defaults to Royal Blue (#4169E1)
---```
--- function showOptions(parent, pageNumber)
---     pageNumber = pageNumber or 1;       -- same as: If pageNumber == nil then pagenumber = 1; end
---     local numberOfOptions = 32;
---     local optionsPerPage = 10;
--- 
---     -- We want to show 10 options per page
---     for i = optionsPerPage * (pageN - 1) + 1, optionsPerPage * pageN do
---         -- show option
---     end
--- 
---     CreatePageButtons(parent, pageNumber, math.ceil(numberOfOptions / optionsPerPage),
---         function()
---             showOptions(parent, pageNumber - 1);
---         end,
---         function()
---             showOptions(parent, pageNumber + 1);
---         end);
--- end
---```
function UI2.CreatePageButtons(parent, pageN, maxPage, prevFunc, nextFunc, color)
    color = color or "#4169E1";
    local line = UI2.CreateHorz(parent).SetFlexibleWidth(1).SetCenter(true);
    UI2.CreateButton(line).SetText("Previous").SetColor(color).SetOnClick(prevFunc).SetInteractable(pageN > 1);
    UI2.CreateEmpty(line).SetPreferredWidth(5);
    UI2.CreateLabel(line).SetText(pageN .. " / " .. maxPage).SetColor("#DDDDDD");
    UI2.CreateEmpty(line).SetPreferredWidth(5);
    UI2.CreateButton(line).SetText("Next").SetColor(color).SetOnClick(nextFunc).SetInteractable(pageN < maxPage);
end

---Creates an action button at the right side. See also [CreateInfoButtonLine](lua://CreateInfoButtonLine) and [CreateDeleteButtonLine](lua://CreateDeleteButtonLine)
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
---     end, 
---     function()
---         UI2.Destroy(label);  -- 'label' is a global variable
---     end, 
---     "X", 
---     "#FF0000");       -- color Red
---```
function UI2.CreateActionButtonLine(parent, func, action, actionText, actionButtonColor)
    local line = UI2.CreateHorz(parent).SetFlexibleWidth(1);
    func(line);
    UI2.CreateEmpty(line).SetFlexibleWidth(1).SetPreferredWidth(20);
    UI2.CreateButton(line).SetText(actionText or "?").SetColor(actionButtonColor or "#4169E1").SetOnClick(action);
end

---Creates an info action button, with text '?' and colored royal blue
---@param parent UIObject # The parent
---@param func fun(line: HorizontalLayoutGroup) # A function that takes an UIObject. In this function you can create more objects to appear in the line
---@param text string # The text that will be shown once the user clicks the info action button
---```
--- CreateInfoButtonLine(parent, 
---     function(line)
---         CreateLabel(line).SetText("Click the '?' button for more information");
---     end, 
---     "This is the explanation. You have clicked the button!");
---```
function UI2.CreateInfoButtonLine(parent, func, text)
    UI2.CreateActionButtonLine(parent, func, function() UI2.Alert(text); end, "?", "#4169E1");
end

---Creates a delete action button, with text 'X' and with a red color
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
---         UI2.Destroy(object);     -- 'object' is a global variable
---         print("Object destroyed!");
---     end)
---```
function UI2.CreateDeleteButtonLine(parent, func, action)
    UI2.CreateActionButtonLine(parent, func, action, "X", "#FF0000");
end

---Helper function that returns true if you can write/read this object
---@param obj UIObject
---@return boolean # True if the object is not yet destroyed, false if the object is destroyed and therefore cannot be read
---```
--- function saveSettings(checkbox)
---     if canReadObject(checkbox) then     -- Checking whether we can read the object
---         Mod.Settings.SomeSetting = checkbox.GetIsChecked();
---     end
--- end
---```
function UI2.canReadObject(obj)
    return not UI2.IsDestroyed(obj);
end

---Registers a new dialog. If a dialog with the same name is still open, it will closed that dialog
---@param id string | number # Unique identifier of the dialog. Best use case is to give all dialogs a understandable name
---@param rootParent RootParent # The RootParent of the dialog. This is used to check whether the dialog is still open or not
---@param close fun() # The close() function. Needed to close the dialog
---```
--- CreateButton(root).SetText("Click me for more information").SetOnClick(function()
---     game.CreateDialog(function(rootParent, game, setMaxSize, setScrollable, close)  -- Create a new dialog
---         NewDialog("Information_Dialog", rootParent, close);     -- Register the new dialog
---         CreateLabel(rootParent).SetText("Here is some more information!");
---     end);
--- end);
---```
function UI2.NewDialog(id, rootParent, close)
    if Dialogs_JAD[id] and not UI2.IsDestroyed(Dialogs_JAD[id].RootParent) then
        Dialogs_JAD[id].Close();
    end
    Dialogs_JAD[id] = {
        RootParent = rootParent,
        Close = close
    };
end

---Closes the dialog identified by the passed identifier
---@param id string | number # The identifier of the dialog. If the dialog was never registered, or was already closed, this call will result in nothing
---```
--- CloseDialog("ID_Of_Some_Dialog");   -- Will close the dialog "ID_Of_Some_Dialog"
---```
function UI2.CloseDialog(id)
    if Dialogs_JAD[id] and not UI2.IsDestroyed(Dialogs_JAD[id].RootParent) then
        Dialogs_JAD[id].Close();
    end
end

---Closes all dialogs that are still open
---```
--- CloseAllDialogs();      -- Closes all registered dialogs that are open
---```
function UI2.CloseAllDialogs()
    for _, t in pairs(Dialogs_JAD) do
        if not UI2.IsDestroyed(t.RootParent) then
            t.Close();
        end
    end
end

-- ---Creates and returns a vertical layout group
-- ---@param parent UIObject # The parent
-- ---@return VerticalLayoutGroup # The created vertial layout group
-- function UI2.CreateVerticalLayoutGroup(parent)
-- 	return UI2.CreateVerticalLayoutGroup(parent);
-- end

---Creates and returns a vertical layout group
---@param parent UIObject # The parent
---@return VerticalLayoutGroup # The created vertical layout group
function UI2.CreateVert(parent)
	return UI2.CreateVerticalLayoutGroup(parent);
end

-- ---Creates and returns a horizontal layout group
-- ---@param parent UIObject # The parent
-- ---@return HorizontalLayoutGroup # The created horizontal layout group
-- function UI2.CreateHorizontalLayoutGroup(parent)
-- 	return UI2.CreateHorizontalLayoutGroup(parent);
-- end

---Creates and returns a horizontal layout group
---@param parent UIObject # The parent
---@return HorizontalLayoutGroup # The created horizontal layout group
function UI2.CreateHorz(parent)
	return UI2.CreateHorizontalLayoutGroup(parent);
end

-- ---Creates and returns an empty object
-- ---@param parent UIObject # The parent
-- ---@return Empty # The created empty object
-- function UI2.CreateEmpty(parent)
-- 	return UI2.CreateEmpty(parent);
-- end

-- ---Creates and returns a label object
-- ---@param parent UIObject # The parent
-- ---@return Label # The created label object
-- function UI2.CreateLabel(parent)
-- 	return UI2.CreateLabel(parent);
-- end

-- ---Creates and returns a button object
-- ---@param parent UIObject # The parent
-- ---@return Button # The created button object
-- function UI2.CreateButton(parent)
-- 	return UI2.CreateButton(parent);
-- end

-- ---Creates and returns a checkbox object
-- ---@param parent UIObject # The parent
-- ---@return CheckBox # The created checkbox object
-- function UI2.CreateCheckBox(parent)
-- 	return UI2.CreateCheckBox(parent);
-- end

-- ---Creates and returns a radio button group
-- ---@param parent UIObject # The parent
-- ---@return RadioButtonGroup # The created radio button group
-- function UI2.CreateRadioButtonGroup(parent)
--     return UI2.CreateRadioButtonGroup(parent);
-- end

-- ---Creates and returns a radio button object
-- ---@param parent UIObject # The parent
-- ---@return RadioButton # The created radio button
-- function UI2.CreateRadioButton(parent)
--     return UI2.CreateRadioButton(parent);
-- end

-- ---Creates and returns a text input field
-- ---@param parent UIObject # The parent
-- ---@return TextInputField # The created text input field
-- function UI2.CreateTextInputField(parent)
-- 	return UI2.CreateTextInputField(parent);
-- end

-- ---Creates and returns a number input field
-- ---@param parent UIObject # The parent
-- ---@return NumberInputField # The created number input field
-- function UI2.CreateNumberInputField(parent)
-- 	return UI2.CreateNumberInputField(parent);
-- end

---@class UIButtonColors
---@field Blue "#0000FF"
---@field Purple "#59009D"
---@field Orange "#FF7D00"
---@field DarkGray "#606060"
---@field HotPink "#FF697A" 
---@field SeaGreen "#00FF8C"
---@field Teal "#009B9D"
---@field DarkMagenta "#AC0059"
---@field Yellow "#FFFF00"
---@field Ivory "#FEFF9B"
---@field ElectricPurple "#B70AFF"
---@field DeepPink "#FF00B1"
---@field Aqua "#4EFFFF"
---@field DarkGreen "#008000"
---@field Red "#FF0000"
---@field Green "#00FF05"
---@field SaddleBrown "#94652E"
---@field OrangeRed "#FF4700"
---@field LightBlue "#23A0FF"
---@field Orchid "#FF87FF"
---@field Brown "#943E3E"
---@field CopperRose "#AD7E7E"
---@field Tan "#FFAF56"
---@field Lime "#8EBE57"
---@field TyrianPurple "#990024"
---@field MardiGras "#880085"
---@field RoyalBlue "#4169E1"
---@field WildStrawberry "#FF43A4"
---@field SmokyBlack "#100C08"
---@field GoldenRod "#DAA520"
---@field Cyan "#00FFFF"
---@field Artichoke "#8F9779"
---@field RainForest "#00755E"
---@field Peach "#FFE5B4"
---@field AppleGreen "#8DB600"
---@field Viridian "#40826D"
---@field Mahogany "#C04000"
---@field PinkLace "#FFDDF4"
---@field Bronze "#CD7F32"
---@field WoodBrown "#C19A6B"
---@field Tuscany "#C09999"
---@field AcidGreen "#B0BF1A"
---@field Amazon "#3B7A57"
---@field ArmyGreen "#4B5320"
---@field DonkeyBrown "#664C28"
---@field Cordovan "#893F45"
---@field Cinnamon "#D2691E"
---@field Charcoal "#36454F"
---@field Fuchsia "#FF00FF"
---@field ScreaminGreen "#76FF7A"

---@class UIGrayColors
---@field TextLighter "#EEEEEE" # Lighter gray than the default font color in Warzone
---@field TextLight "#DDDDDD" # Slightly lighter gray than the default font color in Warzone
---@field TextDefault "#CCCCCC" # The same gray color as the default font color in Warzone
---@field TextDark "#BBBBBB" # Slightly darker gray than the default font color in Warzone
---@field TextDarker "#AAAAAA" # Darker gray than the default font color in Warzone
---@field TextColor "#DDDDDD" # Deprecated, only made available to allow for backwards compatibility

---@class UIColors: UIButtonColors, UIGrayColors