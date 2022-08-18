---------------------------------------------------
-- Created by Just_A_Dutchman_ ---- Version: 1.0 --
---------------------------------------------------



--
--		windows						(key = window name)		(value = table)
--		windows[window name]		(key = object name)		(value = UI Object id)
--
--		objects						(key = UI Object id)	(value = table)
--		objects.Object				(key = "Object")		(value = UI Object)
--		objects.Type				(key = "Type")			(value = string)
--		objects.Parent				(key = "Parent")		(value = UI Object id)
--		objects.function			(key = "Function")		(value = function or nil)
--
--		objectsID					(key = object name)		(value = UI Object id)			Will be used to quickly get the object if the user wants a certain object by their name
--
--		layoutGroups				(key = object name)		(value = UI Object)
--


-- Initialize UI.lua --
-----------------------
-- should be called at the start of every UI Client file!
-- Mandatory paramaters:
--	+ root			[UI Object]				The root of all UI Objects

function init(root)
	windows = {};					-- Will store all the different windows (key = window name)
	windows[root.id] = {};
	objects = {};					-- Will store all the objects (key = UI Object id)
	objectsID = {};					-- Will store all the IDs indexed by the name identifier (key = name, value = UI Object id)
	currentWindow = root.id;		-- Keeps track which window is currently shown to the player
	functions = {};					-- Will store the functions since these are not acquirable with getters
	layoutGroups = {};
	layoutGroups["root"] = UI.CreateVerticalLayoutGroup(root);
	colors = {};					-- Stores all the built-in colors (player colors only)
	colors["Blue"] = "#0000FF"; colors["Purple"] = "#59009D"; colors["Orange"] = "#FF7D00"; colors["Dark Gray"] = "#606060"; colors["Hot Pink"] = "#FF697A"; colors["Sea Green"] = "#00FF8C"; colors["Teal"] = "#009B9D"; colors["Dark Magenta"] = "#AC0059"; colors["Yellow"] = "#FFFF00"; colors["Ivory"] = "#FEFF9B"; colors["Electric Purple"] = "#B70AFF"; colors["Deep Pink"] = "#FF00B1"; colors["Aqua"] = "#4EFFFF"; colors["Dark Green"] = "#008000"; colors["Red"] = "#FF0000"; colors["Green"] = "#00FF05"; colors["Saddle Brown"] = "#94652E"; colors["Orange Red"] = "#FF4700"; colors["Light Blue"] = "#23A0FF"; colors["Orchid"] = "#FF87FF"; colors["Brown"] = "#943E3E"; colors["Copper Rose"] = "#AD7E7E"; colors["Tan"] = "#FFAF56"; colors["Lime"] = "#8EBE57"; colors["Tyrian Purple"] = "#990024"; colors["Mardi Gras"] = "#880085"; colors["Royal Blue"] = "#4169E1"; colors["Wild Strawberry"] = "#FF43A4"; colors["Smoky Black"] = "#100C08"; colors["Goldenrod"] = "#DAA520"; colors["Cyan"] = "#00FFFF"; colors["Artichoke"] = "#8F9779"; colors["Rain Forest"] = "#00755E"; colors["Peach"] = "#FFE5B4"; colors["Apple Green"] = "#8DB600"; colors["Viridian"] = "#40826D"; colors["Mahogany"] = "#C04000"; colors["Pink Lace"] = "#FFDDF4"; colors["Bronze"] = "#CD7F32"; colors["Wood Brown"] = "#C19A6B"; colors["Tuscany"] = "#C09999"; colors["Acid Green"] = "#B0BF1A"; colors["Amazon"] = "#3B7A57"; colors["Army Green"] = "#4B5320"; colors["Donkey Brown"] = "#664C28"; colors["Cordovan"] = "#893F45"; colors["Cinnamon"] = "#D2691E"; colors["Charcoal"] = "#36454F"; colors["Fuchsia"] = "#FF00FF"; colors["Screamin' Green"] = "#76FF7A";
end


-- Returns the name identifier current window being shown --
------------------------------------------------------------

function getCurrentWindow()
	return currentWindow;
end


-- Resets the window --
-----------------------
-- Mandatory paramaters:
--	+ win			[string]			The name identifier of the window

function resetWindow(win)
	windows[win] = {};
end


-- Creates a new window --
--------------------------
-- Mandatory paramaters:
--	+ win			[string]			The name identifier of the window

function window(win)
	if windows[win] == nil then 
		windows[win] = {};
	end
	currentWindow = win;
end


-- Returns true or false depending if the window already exists --
------------------------------------------------------------------
-- If an window exists you should either reset the window [resetWindow()] or restore the window [restoreWindow()]
-- Mandatory paramaters:
--	+ win			[string]			The name identifier of the window

function windowExists(win)
	return windows[win] ~= nil;
end


-- Restores an existing window by re-creating its UI Objects --
---------------------------------------------------------------
-- Make sure the window exists before calling this function!
-- Mandatory parameters:
--	+ win			[string]			The name identifier of the window

function restoreWindow(win)
	local newWin = {};
	for i,v in pairs(windows[win]) do				-- i = object name; 	v = UI Object id
		local oldObj = objects[objectsID[v]];
		if oldObj ~= nil then
			local newObj;
			if oldObj.Type == "Vert" then
				newObj = verticalLayoutGroup(getParent(oldObj.Parent));
				layoutGroups[v] = newObj;
			elseif oldObj.Type == "Hor" then
				newObj = horizontalLayoutGroup(getParent(oldObj.Parent));
				layoutGroups[v] = newObj;
			elseif oldObj.Type == "Label" then
				newObj = label(getParent(oldObj.Parent), oldObj.Object.GetText(), oldObj.Object.GetColor(), oldObj.Object.GetPreferredWidth(), oldObj.Object.GetPreferredHeight(), oldObj.Object.GetFlexibleWidth(), oldObj.Object.GetFlexibleHeight());
			elseif oldObj.Type == "Button" then
				newObj = button(getParent(oldObj.Parent), oldObj.Object.GetText(), getFunction(oldObj.Object.id), oldObj.Object.GetColor(), oldObj.Object.GetInteractable(), oldObj.Object.GetPreferredWidth(), oldObj.Object.GetPreferredHeight(), oldObj.Object.GetFlexibleWidth(), oldObj.Object.GetFlexibleHeight())
			elseif oldObj.Type == "CheckBox" then
				newObj = checkbox(getParent(oldObj.Parent), oldObj.Object.GetText(), oldObj.Object.GetIsChecked(), oldObj.Object.GetInteractable(), getFunction(oldObj.Object.id), oldObj.Object.GetPreferredWidth(), oldObj.Object.GetPreferredHeight(), oldObj.Object.GetFlexibleWidth(), oldObj.Object.GetFlexibleHeight());
			elseif oldObj.Type == "TextInputField" then
				newObj = textInputField(getParent(oldObj.Parent), oldObj.Object.GetPlaceholderText(), oldObj.Object.GetText(), oldObj.Object.GetCharacterLimit(), oldObj.Object.GetInteractable(), oldObj.Object.GetPreferredWidth(), oldObj.Object.GetPreferredHeight(), oldObj.Object.GetFlexibleWidth(), oldObj.Object.GetFlexibleHeight())
			elseif oldObj.Type == "NumberInputField" then
				newObj = numberInputField(getParent(oldObj.Parent), oldObj.Object.GetSliderMinValue(), oldObj.Object.GetSliderMaxValue(), oldObj.Object.GetValue(), oldObj.Object.GetInteractable(), oldObj.Object.GetWholeNumbers(), oldObj.Object.GetBoxPreferredWidth(), oldObj.Object.GetSliderPreferredWidth(), oldObj.Object.GetPreferredWidth(), oldObj.Object.GetPreferredHeight(), oldObj.Object.GetFlexibleWidth(), oldObj.Object.GetFlexibleHeight())
			end
			createNewObject(newObj.id, newObj, oldObj.Parent, oldObj.Type, v);
			deleteObject(objectsID[v]);
			objectsID[v] = newObj.id;
			newWin[i] = v;
		end
	end
	windows[win] = newWin;
	currentWindow = win;
end


-- Destroys all UI Objects in the window --
-------------------------------------------
-- Mandatory paramaters:
--	+ win			[string]			The name identifier of the window

function destroyWindow(win)
	if win == nil or windows[win] == {} then return; end
	for _, v in pairs(windows[win]) do
		UI.Destroy(objects[objectsID[v]].Object);
	end
end


-- Deletes the field in object corresponding the id --
------------------------------------------------------
-- Mandatory paramaters:
--	+ id			[string]			The string identifier of the UI Object

function deleteObject(id)
	objects[id] = nil;
end


-- Creates a new object field in objects --
-------------------------------------------
-- Mandatory paramaters:
--	+ id			[string]			The string identifier of the UI Object
--	+ object		[UI Object]			The UI Object itself
--	+ parent		[UI Object]			the parent of the UI object
--	+ typ			[string]			The type of the object
--	+ name			[string]			The name identifier of the UI object

function createNewObject(id, obj, parent, typ, name)
	objects[id] = {};
	objects[id].Object = obj;
	objects[id].Parent = parent;
	objects[id].Type = typ;
	objects[id].Name = name;
end



function getParent(name)
	return layoutGroups[name];
end


-- Parent function of label() --
--------------------------------
-- This function should be called when using the window system!
-- Mandatory paramaters:
--	+ name			[string]			Name identifier of the UI object
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ text			[string]			Text to be displayed
-- 
-- Optional parameters:
--	+ color			[string]			Color string in the format #HHHHHH (H = hexadecimal) or one of the build in colors (Blue, Green, Aqua, etc)
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ prefHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function newLabel(name, parent, text, color, prefWidth, prefHeight, flexWidth, flexHeigth)
	local lab = label(getParent(parent), text, color, prefWidth, prefHeight, flexWidth, flexHeigth);			-- Create the label
	createNewObject(lab.id, lab, parent, "Label", name);											-- Store the new object
	table.insert(windows[getCurrentWindow()], name);												-- Store the object in the window
	objectsID[name] = lab.id;																		-- Store the object name and id to allow for quick search
	return name;																						-- Return the label so changes can be applied to it
end


-- Parent function of button() --
---------------------------------
-- This function should be called when using the window system!
-- Mandatory paramaters:
--	+ name			[string]			Name identifier of the UI object
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ text			[string]			Text to be displayed
--	+ onClick		[function]			Name of the function that will be called when the player clicks the button
-- 
-- Optional parameters:
--	+ color			[string]			Color string in the format #HHHHHH (H = hexadecimal) or one of the build in colors (Blue, Green, Aqua, etc)
--	+ interactable	[boolean]			If true the button can be interacted with, if false the button cannot be interacted with
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ prefHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function newButton(name, parent, text, onClick, color, interactable, prefWidth, prefHeight, flexWidth, flexHeigth)
	local but = button(getParent(parent), text, onClick, color, interactable, prefWidth, prefHeight, flexWidth, flexHeigth);		-- Create the button
	createNewObject(but.id, but, parent, "Button", name);											-- Store the new object
	table.insert(windows[getCurrentWindow()], name);														-- Store the object in the window
	objectsID[name] = but.id;																		-- Store the object name and id to allow for quick search
	return name;																						-- Return the button so changes can be applied to it
end



-- Parent function of checkbox() --
-----------------------------------
-- This function should be called when using the window system!
-- Mandatory paramaters:
--	+ name			[string]			Name identifier of the UI object
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ text			[string]			Text to be displayed next to the checkbox
--
-- Optional paramaters:
--	+ isChecked		[boolean]			If true, the checkbox will be checked. If false, the checkbox will not be checked
--	+ interactable	[boolean]			If true the button can be interacted with, if false the button cannot be interacted with
--	+ onValueChange	[function]			Name of the function that will be called when the player or the mod itself changes the value
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ prefHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function newCheckbox(name, parent, text, isChecked, interactable, onValueChanged, prefWidth, prefHeight, flexWidth, flexHeigth)
	local box = checkbox(getParent(parent), text, isChecked, interactable, onValueChanged, prefWidth, prefHeight, flexWidth, flexHeigth);		-- Create the checkbox
	createNewObject(box.id, box, parent, "CheckBox", name);											-- Store the new object
	table.insert(windows[getCurrentWindow()], name);												-- Store the object in the window
	objectsID[name] = box.id;																		-- Store the object name and id to allow for quick search
	return name;																						-- Return the checkbox so changes can be applied to it
end


-- Creates a text input field to allow for text input --
--------------------------------------------------------
-- This function should be called when using the window system!
-- Mandatory paramaters:
--	+ name			[string]			Name identifier of the UI object
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ placeholderText	[string]		A string that gets displayed in the text input field when no text has been entered yet
--
-- Optional paramaters:
--	+ text			[string]			A string with the value of the text input field
--	+ characterLimit	[integer]		The maximum number of characters allowed for the player and mod to input
--	+ interactable	[boolean]			If true the text input field can be interacted with, if false the text input field cannot be interacted with
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ prefHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function newTextField(name, parent, placeholderText, text, characterLimit, interactable, prefWidth, prefHeight, flexWidth, flexHeigth)
	local tif = textInputField(getParent(parent), placeholderText, text, characterLimit, interactable, prefWidth, prefHeight, flexWidth, flexHeigth);
	createNewObject(tif.id, tif, parent, "TextInputField", name);									-- Store the new object
	table.insert(windows[getCurrentWindow()], name);												-- Store the object in the window
	objectsID[name] = tif.id;																		-- Store the object name and id to allow for quick search
	return name;
end


-- Creates a number input field to allow for number input --
------------------------------------------------------------
-- This function should be called when using the window system!
-- Mandatory paramaters:
--	+ name			[string]			Name identifier of the UI object
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ sliderMin		[number]			A number that should be less than sliderMax. If this is not an integer the number will get rounded if wholeNumbers is not equal to true
--	+ sliderMax		[number]			A number that should be bigger than sliderMin. If this is not an integer the number will get rounded if wholeNumbers is not equal to true
--	+ value			[number]			Display a default value in the box. The slider will be adjusted as well
--
-- Optional paramaters:
--	+ interactable	[boolean]			If true the number input field can be interacted with, if false the number input field cannot be interacted with
--	+ wholeNumbers	[boolean]			If true only whole number (integers) are allowed to input, if false float values are also allowed
--	+ boxPreferredWidth 	[number]	Set the preferred width of the box. This might affect the slider if the window is to small
--	+ sliderPreferredWidth	[number]	Set the preferred height of the slider. This might affect the slider if the window is to small
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ prefHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function newNumberField(name, parent, sliderMin, sliderMax, value, interactable, wholeNumbers, boxPreferredWidth, sliderPreferredWidth, prefWidth, prefHeight, flexWidth, flexHeigth)
	local nif = numberInputField(getParent(parent), sliderMin, sliderMax, value, interactable, wholeNumbers, boxPreferredWidth, sliderPreferredWidth, prefWidth, prefHeight, flexWidth, flexHeigth);
	createNewObject(nif.id, nif, parent, "NumberInputField", name);									-- Store the new object
	table.insert(windows[getCurrentWindow()], name);												-- Store the object in the window
	objectsID[name] = nif.id;																		-- Store the object name and id to allow for quick search
	return name;
end


function newVerticalGroup(name, parent)
	local vert = verticalLayoutGroup(getParent(parent));
	createNewObject(vert.id, vert, parent, "Vert", name);
	table.insert(windows[getCurrentWindow()], name);
	objectsID[name] = vert.id;
	layoutGroups[name] = vert;
	return name;
end


function newHorizontalGroup(name, parent)
	local hor = horizontalLayoutGroup(getParent(parent));
	createNewObject(hor.id, hor, parent, "Hor", name);
	table.insert(windows[getCurrentWindow()], name);
	objectsID[name] = hor.id;
	layoutGroups[name] = hor;
	return name;
end


-- Creates a label to display text --
-------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ text			[string]			Text to be displayed
-- 
-- Optional parameters:
--	+ color			[string]			Color string in the format #HHHHHH (H = hexadecimal) or one of the build in colors (Blue, Green, Aqua, etc)
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ flexHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function label(parent, text, color, prefWidth, prefHeight, flexWidth, flexHeigth)
	prefWidth = prefWidth or -1; prefHeight = prefHeight or -1; flexWidth = flexWidth or 0; flexHeigth = flexHeigth or 0;			-- Set optional paramaters to default value if not specified
	return UI.CreateLabel(parent).SetText(text).SetColor(getColorFromString(color)).SetPreferredWidth(prefWidth).SetPreferredHeight(prefHeight).SetFlexibleWidth(flexWidth).SetFlexibleHeight(flexHeigth);
end


-- Creates a button to interact with --
---------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ text			[string]			Text to be displayed
--	+ onClick		[function]			Name of the function that will be called when the player clicks the button
-- 
-- Optional parameters:
--	+ color			[string]			Color string in the format #HHHHHH (H = hexadecimal) or one of the build in colors (Blue, Green, Aqua, etc)
--	+ interactable	[boolean]			If true the button can be interacted with, if false the button cannot be interacted with
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ flexHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function button(parent, text, onClick, color, interactable, prefWidth, prefHeight, flexWidth, flexHeigth)
	prefWidth = prefWidth or -1; prefHeight = prefHeight or -1; flexWidth = flexWidth or 0; flexHeigth = flexHeigth or 0; if interactable == nil then interactable = true; end;		-- Set optional paramaters to default value if not specified
	local but = UI.CreateButton(parent).SetText(text).SetColor(getColorFromString(color)).SetOnClick(onClick).SetInteractable(interactable).SetPreferredWidth(prefWidth).SetPreferredHeight(prefHeight).SetFlexibleWidth(flexWidth).SetFlexibleHeight(flexHeigth);
	functions[but.id] = onClick;				-- Return the button so changes can be applied to it
	return but;
end


-- Creates a checkbox to interact with --
-----------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ text			[string]			Text to be displayed next to the checkbox
--
-- Optional paramaters:
--	+ isChecked		[boolean]			If true, the checkbox will be checked. If false, the checkbox will not be checked
--	+ interactable	[boolean]			If true the checkbox can be interacted with, if false the checkbox cannot be interacted with
--	+ onValueChange	[function]			Name of the function that will be called when the player or the mod itself changes the value
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ flexHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function checkbox(parent, text, isChecked, interactable, onValueChange, prefWidth, prefHeight, flexWidth, flexHeigth)
	prefWidth = prefWidth or -1; prefHeight = prefHeight or -1; flexWidth = flexWidth or 0; flexHeigth = flexHeigth or 0; if interactable == nil then interactable = true; end; if isChecked == nil then isChecked = true; end; onValueChange = onValueChange or function() end;			-- Set optional paramaters to default value if not specified
	local box = UI.CreateCheckBox(parent).SetText(text).SetIsChecked(isChecked).SetOnValueChanged(onValueChange).SetInteractable(interactable).SetPreferredWidth(prefWidth).SetPreferredHeight(prefHeight).SetFlexibleWidth(flexWidth).SetFlexibleHeight(flexHeigth);
	functions[box.id] = onValueChange;			-- Return the checkbox so changes can be applied to it
	return box;
end


-- Creates a text input field to allow for text input --
--------------------------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ placeholderText	[string]		A string that gets displayed in the text input field when no text has been entered yet
--
-- Optional paramaters:
--	+ text			[string]			A string with the value of the text input field
--	+ characterLimit	[integer]		The maximum number of characters allowed for the player and mod to input
--	+ interactable	[boolean]			If true the text input field can be interacted with, if false the text input field cannot be interacted with
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ flexHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function textInputField(parent, placeholderText, text, characterLimit, interactable, prefWidth, prefHeight, flexWidth, flexHeigth)
	prefWidth = prefWidth or -1; prefHeight = prefHeight or -1; flexWidth = flexWidth or 0; flexHeigth = flexHeigth or 0; if interactable == nil then interactable = true; end; text = text or ""; characterLimit = characterLimit or 0;
	return UI.CreateTextInputField(parent).SetText(text).SetPlaceholderText(placeholderText).SetCharacterLimit(characterLimit).SetInteractable(interactable).SetPreferredWidth(prefWidth).SetPreferredHeight(prefHeight).SetFlexibleWidth(flexWidth).SetFlexibleHeight(flexHeigth);
end


-- Creates a number input field to allow for number input --
------------------------------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root
--	+ sliderMin		[number]			A number that should be less than sliderMax. If this is not an integer the number will get rounded if wholeNumbers is not equal to true
--	+ sliderMax		[number]			A number that should be bigger than sliderMin. If this is not an integer the number will get rounded if wholeNumbers is not equal to true
--	+ value			[number]			Display a default value in the box. The slider will be adjusted as well
-- Optional paramaters:
--	+ interactable	[boolean]			If true the number input field can be interacted with, if false the number input field cannot be interacted with
--	+ wholeNumbers	[boolean]			If true only whole number (integers) are allowed to input, if false float values are also allowed
--	+ boxPreferredWidth 	[number]	Set the preferred width of the box. This might affect the slider if the window is to small
--	+ sliderPreferredWidth	[number]	Set the preferred height of the slider. This might affect the slider if the window is to small
--	+ prefWidth		[number]			How wide the element prefers to be
--	+ flexHeigth	[number]			How tall the element prefers to be
--	+ flexWidth		[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (horizontal)
--	+ flexHeigth	[number]			A number from 0 to 1 indicating how much of the remaining space this element wishes to take up (vertical)

function numberInputField(parent, sliderMin, sliderMax, value, interactable, wholeNumbers, boxPreferredWidth, sliderPreferredWidth, prefWidth, prefHeight, flexWidth, flexHeigth)
	prefWidth = prefWidth or -1; prefHeight = prefHeight or -1; flexWidth = flexWidth or 0; flexHeigth = flexHeigth or 0; if interactable == nil then interactable = true; end; if wholeNumbers == nil then wholeNumbers = true; end; boxPreferredWidth = boxPreferredWidth or -1; sliderPreferredWidth = sliderPreferredWidth or -1;
	return UI.CreateNumberInputField(parent).SetSliderMinValue(sliderMin).SetSliderMaxValue(sliderMax).SetValue(value).SetInteractable(interactable).SetWholeNumbers(wholeNumbers).SetBoxPreferredWidth(boxPreferredWidth).SetSliderPreferredWidth(sliderPreferredWidth).SetPreferredWidth(prefWidth).SetPreferredHeight(prefHeight).SetFlexibleWidth(flexWidth).SetFlexibleHeight(flexHeigth);
end


-- Creates a vertical layout group --
-------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root

function verticalLayoutGroup(parent)
	return UI.CreateVerticalLayoutGroup(parent);		-- Return the vertical layout group so changes can be applied to it
end


-- Creates a horizontal layout group --
-------------------------------------
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root

function horizontalLayoutGroup(parent)
	return UI.CreateHorizontalLayoutGroup(parent)
end


-- Returns a color string (#HHHHHH) after checking the input --
---------------------------------------------------------------
-- Mandatory paramaters:
--	+ color			[string]			A string containing a color string in the format '#HHHHHH' (H = hexadecimal) 
--										or a color name of a built-in color. If nil or incorrect returns default color

function getColorFromString(color)
	if color == nil then return "#CCCCCC"; end
	if string.sub(color, 1, 1) == "#" and string.len(color) == 7 then return color; end
	if colors[color] ~= nil then return colors[color]; end
	return "#CCCCCC";
end


-- Shows all the built-in colors --
-----------------------------------
-- Should only be used to choose a color! The labels created by this function are not removable
-- Mandatory paramaters:
--	+ parent		[UI Object]			A vertical layout group, a horizontal layout group or root 

function showColors(parent)
	for i, v in pairs(colors) do
		label(parent, i, v);			-- Print every color and its key to index it
	end
end


-- Returns the function corresponding its UI Object --
------------------------------------------------------
-- I got errors after re-initializing buttons and checkboxes, storing and calling them this way prevents it
-- Should not be called from any Client_ files!
-- Mandatory paramaters:
--	+ id			[string]			The string identifier of the UI Object

function getFunction(id)
	return functions[id];
end


-- Returns the type of the UI object --
---------------------------------------
-- Mandatory paramaters:
--	+ name			[string]			The name identifier of the UI object

function getObjectType(name)
	return objects[objectsID[name]].Type;
end


-- Returns the UI object --
---------------------------
-- Mandatory paramaters:
--	+ name			[string]			The name identifier of the UI object

function getObject(name)
	return objects[objectsID[name]].Object;
end

function getAllObjects()
	local t = {};
	for name, id in pairs(objectsID) do
		t[name] = objects[id];
	end
	return t;
end

-- Returns the UI objects in the specified window --
----------------------------------------------------
-- Mandatory paramaters:
--	+ win			[string]			The name identifier of the window

function getObjectsFromWindow(win)
	local t = {};
	for name, id in pairs(windows[win]) do
		t[name] = objects[id].Object;
	end
	return t;
end

-- Updates the text on a label, button, checkbox or text input field --
-----------------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a label, button, checkbox or text input field
--	+ text			[string]			The new text the UI object should show. If not a string the function will overwrite this with tostring()

function updateText(name, text)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(text) ~= type(string) then text = tostring(text); end
	obj.SetText(text);
end


-- Updates the color on a label or button --
--------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a label or button
--	+ color			[string]			A string containing a color string in the format '#HHHHHH' (H = hexadecimal) 
--										or a color name of a built-in color. If nil or incorrect returns default color

function updateColor(name, color)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	obj.SetColor(getColorFromString(color));
end


-- Updates the interactability of buttons, checkboxes, text input fields and number input fields --
---------------------------------------------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a button, checkbox, text input field or number input field
--	+ bool			[boolean]			Value equal to either true or false

function updateInteractable(name, bool)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(bool) ~= type(true) then print("boolean given to updateInteractable was " .. type(bool) .. ", expected " .. type(true)); return; end
	obj.SetInteractable(bool);
end


-- Updates the preferred width of any UI object --
--------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object
--	+ number		[number]			A number equal to -1 or bigger than 0

function updatePreferredWidth(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramater given to updatePreferredWidth was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number ~= -1 and number < 0 then print("number given to updatePreferredWidth was " .. number .. ", expected -1 or a number bigger or equal than 0"); return; end
	obj.SetPreferredWidth(number);
end


-- Updates the preferred height of any UI object --
---------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object
--	+ number		[number]			A number equal to -1 or bigger than 0

function updatePreferredHeight(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramater given to updatePreferredHeight was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number ~= -1 and number < 0 then print("number given to updatePreferredHeight was " .. number .. ", expected -1 or a number bigger or equal than 0"); return; end
	obj.SetPreferredHeight(number);
end


-- Updates the flexible width of any UI object --
-------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object
--	+ number		[number]			A number between (both included) 0 and 1

function updateFlexibleWidth(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramater given to updateFlexibleWidth was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number < 0 or number > 1 then print("number given to updateFlexibleWidth was not between (both included) 0 and 1, but " .. number); return; end
	obj.SetFlexibleWidth(number);
end


-- Updates the flexible height of any UI object --
--------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object
--	+ number		[number]			A number between (both included) 0 and 1

function updateFlexibleHeight(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramater given to updateFlexibleHeight was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number < 0 or number > 1 then print("number given to updateFlexibleHeight was not between (both included) 0 and 1, but " .. number); return; end
	obj.SetFlexibleHeight(number);
end


-- Updates the function on a button or checkbox when interacted with --
-----------------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a button or checkbox
--	+ func			[function]			The new function that should be called when interacted with the UI object

function updateFunction(name, func)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(func) ~= type(print) then print("second paramater given to updateIsChecked was " .. type(func) .. ", expected a " .. type(print)); return; end
	local str = getObjectType(objects[obj.id].Name);
	if str == "Button" then
		obj.SetOnClick(func);
		functions[obj.id] = func;
		return;
	elseif str == "CheckBox" then
		obj.SetOnValueChanged(func);
		functions[obj.id] = func;
		return;
	else
		print("The object given to updateFunction does not have take a function");
		return;
	end
end


-- Updates a checkbox to check / uncheck it --
----------------------------------------------
--	+ obj			[UI Object]			An UI object, specifically a checkbox
-- 	+ bool			[boolean]			An value equal to true or false

function updateIsChecked(name, bool)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(bool) ~= type(true) then print("second paramater given to updateIsChecked was " .. type(bool) .. ", expected " .. type(true)); return; end
	obj.SetIsChecked(bool)
end


-- Updates the placeholder text on text input fields --
-------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a text input field
--	+ text			[string]			The new text the text input field should display when nothing has been typed. If not a string the function overrides the text with tostring()

function updatePlaceholderText(name, text)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(text) ~= type(string) then text = tostring(text); end
	obj.SetPlaceholderText(text);
end


-- Updates the character limit on text input fields --
------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a text input field
--	+ number		[number]			A number ranging from 0 to infinity

function updateCharacterLimit(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramter of updateCharacterLimit was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number < 0 then print("number given to updateCharacterLimit was " .. number .. ", must be bigger than 0"); return; end
	obj.SetCharacterLimit(number);
end


-- Updates the value on number input fields --
----------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field
--	+ number		[number]			Any number. Note that if whole numbers is true the value will get rounded

function updateValue(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramter of updateValue was " .. type(number) .. ", expected " .. type(0.1)); return; end
	obj.SetValue(number);
end

-- Updates the minimum slider value on number input fields --
----------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field
--	+ number		[number]			Any number. Note that if whole numbers is true the value will get rounded

function updateSliderMinValue(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramter of updateSliderMinValue was " .. type(number) .. ", expected " .. type(0.1)); return; end
	obj.SetSliderMinValue(number);
end

-- Updates the maximum slider value on number input fields --
----------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field
--	+ number		[number]			Any number. Note that if whole numbers is true the value will get rounded

function updateSliderMaxValue(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramter of updateSliderMaxValue was " .. type(number) .. ", expected " .. type(0.1)); return; end
	obj.SetSliderMaxValue(number);
end


-- Updates the whole numbers field on number input fields --
------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field
--	+ bool			[boolean]			Pass true if the input should only use integers, pass false if the input can use floats

function updateWholeNumbers(name, bool)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(bool) ~= type(true) then print("second paramater given to updateWholeNumbers was " .. type(bool) .. ", expected " .. type(true)); return; end
	obj.SetWholeNumbers(bool);
end


-- Updates the box preferred width of number input fields --
------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field
-- 	+ number		[number]			A number equal to -1 or bigger than 0

function updateBoxPreferredWidth(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramater given to updateBoxPreferredWidth was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number ~= -1 and number < 0 then print("number given to updateBoxPreferredWidth was " .. number .. ", expected -1 or a number bigger than 0"); return; end
	obj.SetBoxPreferredWidth(number);
end


-- Updates the slider preferred width of number input fields --
---------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field
-- 	+ number		[number]			A number equal to -1 or bigger than 0

function updateSliderPreferredWidth(name, number)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	if type(number) ~= type(0.1) then print("second paramater given to updateSliderPreferredWidth was " .. type(number) .. ", expected " .. type(0.1)); return; end
	if number ~= -1 and number < 0 then print("number given to updateSliderPreferredWidth was " .. number .. ", expected -1 or a number bigger than 0"); return; end
	obj.SetSliderPreferredWidth(number);
end

-- Returns the text on a label, button, checkbox or text input field --
-----------------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a label, button, checkbox or text input field

function getText(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetText();
end


-- Returns the color on a label or button --
--------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a label or button

function getColor(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetColor();
end


-- Returns the interactability of buttons, checkboxes, text input fields and number input fields --
---------------------------------------------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a button, checkbox, text input field or number input field

function getInteractable(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetInteractable();
end


-- Returns the preferred width of any UI object --
--------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object

function getPreferredWidth(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetPreferredWidth();
end


-- Returns the preferred height of any UI object --
---------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object

function getPreferredHeight(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetPreferredHeight();
end


-- Returns the flexible width of any UI object --
-------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object

function getFlexibleWidth(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetFlexibleWidth();
end


-- Returns the flexible height of any UI object --
--------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			Any UI object

function getFlexibleHeight(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetFlexibleHeight();
end


-- Returns the function on a button or checkbox when interacted with --
-----------------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a button or checkbox

function getFunctionFromObj(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return functions[obj.id];
end


-- Returns a checkbox to check / uncheck it --
----------------------------------------------
--	+ obj			[UI Object]			An UI object, specifically a checkbox

function getIsChecked(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetIsChecked()
end


-- Returns the placeholder text on text input fields --
-------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a text input field

function getPlaceholderText(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetPlaceholderText();
end


-- Returns the character limit on text input fields --
------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a text input field

function getCharacterLimit(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetCharacterLimit();
end


-- Returns the value on number input fields --
----------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field

function getValue(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetValue();
end

-- Returns the minimum slider value on number input fields --
----------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field

function getSliderMinValue(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetSliderMinValue();
end

-- Returns the maximum slider value on number input fields --
----------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field

function getSliderMaxValue(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetSliderMaxValue();
end


-- Returns the whole numbers field on number input fields --
------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field

function getWholeNumbers(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetWholeNumbers();
end


-- Returns the box preferred width of number input fields --
------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field

function getBoxPreferredWidth(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetBoxPreferredWidth();
end


-- Returns the slider preferred width of number input fields --
---------------------------------------------------------------
-- Mandatory paramaters:
--	+ obj			[UI Object]			An UI object, specifically a number input field

function getSliderPreferredWidth(name)
	local obj = getObject(name);
	if type(obj) ~= type(table) then print("object given to getSliderPreferredWidth was " .. type(obj) .. ", expected a table"); return; end
	return obj.GetSliderPreferredWidth();
end