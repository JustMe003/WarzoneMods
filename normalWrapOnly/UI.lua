function Init()
	windows_JAD = {};
end

function GetColors()
	colors = {};					-- Stores all the built-in colors (player colors only)
	colors["Blue"] = "#0000FF"; colors["Purple"] = "#59009D"; colors["Orange"] = "#FF7D00"; colors["DarkGray"] = "#606060"; colors["HotPink"] = "#FF697A"; colors["SeaGreen"] = "#00FF8C"; colors["Teal"] = "#009B9D"; colors["DarkMagenta"] = "#AC0059"; colors["Yellow"] = "#FFFF00"; colors["Ivory"] = "#FEFF9B"; colors["ElectricPurple"] = "#B70AFF"; colors["DeepPink"] = "#FF00B1"; colors["Aqua"] = "#4EFFFF"; colors["DarkGreen"] = "#008000"; colors["Red"] = "#FF0000"; colors["Green"] = "#00FF05"; colors["SaddleBrown"] = "#94652E"; colors["OrangeRed"] = "#FF4700"; colors["LightBlue"] = "#23A0FF"; colors["Orchid"] = "#FF87FF"; colors["Brown"] = "#943E3E"; colors["CopperRose"] = "#AD7E7E"; colors["Tan"] = "#FFAF56"; colors["Lime"] = "#8EBE57"; colors["TyrianPurple"] = "#990024"; colors["MardiGras"] = "#880085"; colors["RoyalBlue"] = "#4169E1"; colors["WildStrawberry"] = "#FF43A4"; colors["SmokyBlack"] = "#100C08"; colors["Goldenrod"] = "#DAA520"; colors["Cyan"] = "#00FFFF"; colors["Artichoke"] = "#8F9779"; colors["RainForest"] = "#00755E"; colors["Peach"] = "#FFE5B4"; colors["AppleGreen"] = "#8DB600"; colors["Viridian"] = "#40826D"; colors["Mahogany"] = "#C04000"; colors["PinkLace"] = "#FFDDF4"; colors["Bronze"] = "#CD7F32"; colors["WoodBrown"] = "#C19A6B"; colors["Tuscany"] = "#C09999"; colors["AcidGreen"] = "#B0BF1A"; colors["Amazon"] = "#3B7A57"; colors["ArmyGreen"] = "#4B5320"; colors["DonkeyBrown"] = "#664C28"; colors["Cordovan"] = "#893F45"; colors["Cinnamon"] = "#D2691E"; colors["Charcoal"] = "#36454F"; colors["Fuchsia"] = "#FF00FF"; colors["Screamin'Green"] = "#76FF7A";
	return colors;
end

function SetWindow(win)
	currentWindow_JAD = win
	if windows_JAD[win] == nil then
		windows_JAD[win] = {};
	end
end

function CreateVertFromRoot(root)
	return UI.CreateVerticalLayoutGroup(root);
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

function CreateEmpty(parent);
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
	table.insert(windows_JAD[currentWindow_JAD], obj)
	return obj;
end

function DestroyWindow(win)
	win = win or currentWindow_JAD;
	if windows_JAD[win] ~= nil then
		for _, obj in pairs(windows_JAD[win]) do
			UI.Destroy(obj);
		end
	end
end
