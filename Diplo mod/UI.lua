---Initializes the necessary globals
---```
--- function Client_PresentConfigureUI(rootParent)
---     init();
---     -- The rest of the code     
---```
function Init()
    Windows_JAD = {};
    Dialogs_JAD = {};
    History_JAD = History_JAD or {};
    HistoryIndex_JAD = HistoryIndex_JAD or 0;
end

---Returns a table with all available colors for buttons
---@return UIColor
---```
--- --Stores the table in a global variable to allow access to it everywhere
--- colors = GetColors();
--- print(colors.Blue);     -- Prints "#0000FF"
---```
function GetColors()
    local colors = {};					-- Stores all the built-in colors (player colors only)
    colors.Blue = "#0000FF"; colors.Purple = "#59009D"; colors.Orange = "#FF7D00"; colors.DarkGray = "#606060"; colors.HotPink = "#FF697A"; colors.SeaGreen = "#00FF8C"; colors.Teal = "#009B9D"; colors.DarkMagenta = "#AC0059"; colors.Yellow = "#FFFF00"; colors.Ivory = "#FEFF9B"; colors.ElectricPurple = "#B70AFF"; colors.DeepPink = "#FF00B1"; colors.Aqua = "#4EFFFF"; colors.DarkGreen = "#008000"; colors.Red = "#FF0000"; colors.Green = "#00FF05"; colors.SaddleBrown = "#94652E"; colors.OrangeRed = "#FF4700"; colors.LightBlue = "#23A0FF"; colors.Orchid = "#FF87FF"; colors.Brown = "#943E3E"; colors.CopperRose = "#AD7E7E"; colors.Tan = "#FFAF56"; colors.Lime = "#8EBE57"; colors.TyrianPurple = "#990024"; colors.MardiGras = "#880085"; colors.RoyalBlue = "#4169E1"; colors.WildStrawberry = "#FF43A4"; colors.SmokyBlack = "#100C08"; colors.Goldenrod = "#DAA520"; colors.Cyan = "#00FFFF"; colors.Artichoke = "#8F9779"; colors.RainForest = "#00755E"; colors.Peach = "#FFE5B4"; colors.AppleGreen = "#8DB600"; colors.Viridian = "#40826D"; colors.Mahogany = "#C04000"; colors.PinkLace = "#FFDDF4"; colors.Bronze = "#CD7F32"; colors.WoodBrown = "#C19A6B"; colors.Tuscany = "#C09999"; colors.AcidGreen = "#B0BF1A"; colors.Amazon = "#3B7A57"; colors.ArmyGreen = "#4B5320"; colors.DonkeyBrown = "#664C28"; colors.Cordovan = "#893F45"; colors.Cinnamon = "#D2691E"; colors.Charcoal = "#36454F"; colors.Fuchsia = "#FF00FF"; colors.ScreaminGreen = "#76FF7A"; colors.TextColor = "#DDDDDD";
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

---Destroys a window. If no identifier is passed, destroys last created window
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
function CreatePageButtons(parent, pageN, maxPage, prevFunc, nextFunc, color)
    color = color or "#4169E1";
    local line = CreateHorz(parent).SetFlexibleWidth(1).SetCenter(true);
    CreateButton(line).SetText("Previous").SetColor(color).SetOnClick(prevFunc).SetInteractable(pageN > 1);
    CreateEmpty(line).SetPreferredWidth(5);
    CreateLabel(line).SetText(pageN .. " / " .. maxPage).SetColor("#DDDDDD");
    CreateEmpty(line).SetPreferredWidth(5);
    CreateButton(line).SetText("Next").SetColor(color).SetOnClick(nextFunc).SetInteractable(pageN < maxPage);
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
---         UI.Destroy(label);  -- 'label' is a global variable
---     end, 
---     "X", 
---     "#FF0000");       -- color Red
---```
function CreateActionButtonLine(parent, func, action, actionText, actionButtonColor)
    local line = CreateHorz(parent).SetFlexibleWidth(1);
    func(line);
    CreateEmpty(line).SetFlexibleWidth(1).SetPreferredWidth(20);
    CreateButton(line).SetText(actionText or "?").SetColor(actionButtonColor or "#4169E1").SetOnClick(action);
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
function CreateInfoButtonLine(parent, func, text)
    CreateActionButtonLine(parent, func, function() UI.Alert(text); end, "?", "#4169E1");
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
---         UI.Destroy(object);     -- 'object' is a global variable
---         print("Object destroyed!");
---     end)
---```
function CreateDeleteButtonLine(parent, func, action)
    CreateActionButtonLine(parent, func, action, "X", "#FF0000");
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
function canReadObject(obj)
    return not UI.IsDestroyed(obj);
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
function NewDialog(id, rootParent, close)
    if Dialogs_JAD[id] and not UI.IsDestroyed(Dialogs_JAD[id].RootParent) then
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
function CloseDialog(id)
    if Dialogs_JAD[id] and not UI.IsDestroyed(Dialogs_JAD[id].RootParent) then
        Dialogs_JAD[id].Close();
    end
end

---Closes all dialogs that are still open
---```
--- CloseAllDialogs();      -- Closes all registered dialogs that are open
---```
function CloseAllDialogs()
    for _, t in pairs(Dialogs_JAD) do
        if not UI.IsDestroyed(t.RootParent) then
            t.Close();
        end
    end
end

---Adds a new entry to the history
---@param func fun() # Zero argument callback function that will be called if the user wants to go back a page
---```
--- function subMenu(parent)
---     -- We want to add this function to the history
---     -- This allows the user to back-track when navigating the UI
---     AddToHistory(function()
---         subMenu(parent);
---     end);
--- end
---```
function AddToHistory(func, ...)
    HistoryIndex_JAD = HistoryIndex_JAD + 1;
    History_JAD[HistoryIndex_JAD] = {
        Function = func,
        Arguments = {...}
    };
end

function CompareTables_JAD(t1, t2)
    if t1 == t2 then return true; end
    if type(t1) == "table" and type(t2) == "table" then
        for i, v in pairs(t1) do
            if type(v) ~= type(t2[i]) or v ~= t2[i] then
                return false;
            end
        end
    else 
        return false;
    end
    return true;
end

---Call the previous entry in the history
---```
--- -- This button will, when interacted with, invoke the previous entry in the history
--- CreateButton(root).SetText("Go back").SetOnClick(GetPreviousWindow);
---```
function GetPreviousWindow()
    local currentWindow = History_JAD[HistoryIndex_JAD];
    HistoryIndex_JAD = HistoryIndex_JAD - 1;
    while HistoryIndex_JAD > 1 do
        if currentWindow.Function ~= History_JAD[HistoryIndex_JAD].Function or not CompareTables_JAD(currentWindow.Arguments, History_JAD[HistoryIndex_JAD].Arguments) then
            break;
        end
        HistoryIndex_JAD = HistoryIndex_JAD - 1;
    end
    if History_JAD[HistoryIndex_JAD] ~= nil then
        History_JAD[HistoryIndex_JAD].Function(table.unpack(History_JAD[HistoryIndex_JAD].Arguments));
        HistoryIndex_JAD = HistoryIndex_JAD - 1;
    end
end

---Call the next entry in the history
------```
--- -- This button will, when interacted with, invoke the next entry in the history
--- CreateButton(root).SetText("Go next").SetOnClick(GetNextWindow);
---```
function GetNextWindow()
    local currentWindow = History_JAD[HistoryIndex_JAD];
    HistoryIndex_JAD = HistoryIndex_JAD + 1;
    while HistoryIndex_JAD <= #History_JAD do
        if currentWindow.Function ~= History_JAD[HistoryIndex_JAD].Function or not CompareTables_JAD(currentWindow.Arguments, History_JAD[HistoryIndex_JAD].Arguments) then
            break;
        end
    end
    History_JAD[HistoryIndex_JAD]();
    HistoryIndex_JAD = HistoryIndex_JAD - 1;
end

---Returns whether the history contains a next window
---@return boolean # True if the history has a next window, false otherwise
function GetHasNextWindow()
    return HistoryIndex_JAD ~= #History_JAD;
end

---Returns whether the history contains a previous window
---@return boolean # True if the history has a previous window, false otherwise
function GetHasPreviousWindow()
    return HistoryIndex_JAD > 1;
end

---Invokes the first entry in the history and resets it
---```
--- --
--- CreateButton(root).SetText("Home").SetOnClick(GetFirstWindow);
---```
function GetFirstWindow()
    HistoryIndex_JAD = 0;
    local t = History_JAD[1];    
    History_JAD = {};
    t.Function(table.unpack(t.Arguments));
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

---Creates and returns a radio button group
---@param parent UIObject # The parent
---@return RadioButtonGroup # The created radio button group
function CreateRadioButtonGroup(parent)
    return UI.CreateRadioButtonGroup(parent);
end

---Creates and returns a radio button object
---@param parent UIObject # The parent
---@return RadioButton # The created radio button
function CreateRadioButton(parent)
    return UI.CreateRadioButton(parent);
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

---@class UIColor
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
---@field TextColor "#DDDDDD" # Not an actual color for a button, but used by the library creator for making text more easily readable
