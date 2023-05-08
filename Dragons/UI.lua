function Init(root)
	windows_JAD = {};
	subWindows_JAD = {};
	root_JAD = UI.CreateVerticalLayoutGroup(root);
	SetWindow(root.id);
end

function GetRoot()
	return root_JAD;
end

function GetColors()
	colors = {};					-- Stores all the built-in colors (player colors only)
	colors["Blue"] = "#0000FF"; colors["Purple"] = "#59009D"; colors["Orange"] = "#FF7D00"; colors["Dark Gray"] = "#606060"; colors["Hot Pink"] = "#FF697A"; colors["Sea Green"] = "#00FF8C"; colors["Teal"] = "#009B9D"; colors["Dark Magenta"] = "#AC0059"; colors["Yellow"] = "#FFFF00"; colors["Ivory"] = "#FEFF9B"; colors["Electric Purple"] = "#B70AFF"; colors["Deep Pink"] = "#FF00B1"; colors["Aqua"] = "#4EFFFF"; colors["Dark Green"] = "#008000"; colors["Red"] = "#FF0000"; colors["Green"] = "#00FF05"; colors["Saddle Brown"] = "#94652E"; colors["Orange Red"] = "#FF4700"; colors["Light Blue"] = "#23A0FF"; colors["Orchid"] = "#FF87FF"; colors["Brown"] = "#943E3E"; colors["Copper Rose"] = "#AD7E7E"; colors["Tan"] = "#FFAF56"; colors["Lime"] = "#8EBE57"; colors["Tyrian Purple"] = "#990024"; colors["Mardi Gras"] = "#880085"; colors["Royal Blue"] = "#4169E1"; colors["Wild Strawberry"] = "#FF43A4"; colors["Smoky Black"] = "#100C08"; colors["Goldenrod"] = "#DAA520"; colors["Cyan"] = "#00FFFF"; colors["Artichoke"] = "#8F9779"; colors["Rain Forest"] = "#00755E"; colors["Peach"] = "#FFE5B4"; colors["Apple Green"] = "#8DB600"; colors["Viridian"] = "#40826D"; colors["Mahogany"] = "#C04000"; colors["Pink Lace"] = "#FFDDF4"; colors["Bronze"] = "#CD7F32"; colors["Wood Brown"] = "#C19A6B"; colors["Tuscany"] = "#C09999"; colors["Acid Green"] = "#B0BF1A"; colors["Amazon"] = "#3B7A57"; colors["Army Green"] = "#4B5320"; colors["Donkey Brown"] = "#664C28"; colors["Cordovan"] = "#893F45"; colors["Cinnamon"] = "#D2691E"; colors["Charcoal"] = "#36454F"; colors["Fuchsia"] = "#FF00FF"; colors["Screamin' Green"] = "#76FF7A"; colors["Textcolor"] = "#DDDDDD";
	return colors;
end

function GetCurrentWindow()
	return currentWindow_JAD
end

function SetWindow(win)
	currentWindow_JAD = win
	if windows_JAD[win] == nil then
		windows_JAD[win] = {};
	end
end

function AddSubWindow(win, subWin)
	if subWindows_JAD[win] == nil then
		subWindows_JAD[win] = {};
	end
	if not valueInTable_JAD(subWindows_JAD[win], subWin) and win ~= subWin then
		table.insert(subWindows_JAD[win], subWin);
	end
end

function CreateVerticalLayoutGroup(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateVerticalLayoutGroup(parent));
end

function CreateVert(parent)
	return CreateVerticalLayoutGroup(parent);
end

function CreateHorizontalLayoutGroup(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateHorizontalLayoutGroup(parent));
end

function CreateHorz(parent)
	return CreateHorizontalLayoutGroup(parent);
end

function CreateEmpty(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateEmpty(parent));
end

function CreateLabel(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateLabel(parent));
end

function CreateButton(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateButton(parent));
end

function CreateCheckBox(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateCheckBox(parent));
end

function CreateTextInputField(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateTextInputField(parent));
end

function CreateNumberInputField(parent)
	return AddObjectToWindowAndReturnObject(UI.CreateNumberInputField(parent));
end

function AddObjectToWindowAndReturnObject(obj)
	table.insert(windows_JAD[currentWindow_JAD], obj);
	return obj;
end

function DestroyWindow(win, bool)
	win = win or currentWindow_JAD;
	bool = bool or false;
	if windows_JAD[win] ~= nil then
		for _, obj in pairs(windows_JAD[win]) do
			UI.Destroy(obj);
		end
	end
	if bool and subWindows_JAD[win] ~= nil and #subWindows_JAD[win] > 0 then
		for _, subWin in pairs(subWindows_JAD[win]) do
			DestroyWindow(subWin, true);
		end
	end
end

function valueInTable_JAD(t, v)
	for _, v2 in pairs(t) do
		if v2 == v then return true; end
	end
	return false;
end