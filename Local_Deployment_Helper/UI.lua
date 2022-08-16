local horzs;
local verts;
local labels;
local buttons;
local texts;
local numbers;
local boxes;

function init()
	horzs = {};
	verts = {};
	labels = {};
	buttons = {};
	texts = {};
	numbers = {};
	boxes = {};
end

function initColors()
	local colors = {};
	colors.TextColor = "#AAAAAA"; colors.ErrorColor = "#FF2222"; colors.TrueColor = "#33AA33"; colors.FalseColor = "#AA3333"; colors.NumberColor = "#3333AA"; colors.WarningNumberColor = "#DD1111"; colors["Blue"] = "#0000FF"; colors["Purple"] = "#59009D"; colors["Orange"] = "#FF7D00"; colors["Dark Gray"] = "#606060"; colors["Hot Pink"] = "#FF697A"; colors["Sea Green"] = "#00FF8C"; colors["Teal"] = "#009B9D"; colors["Dark Magenta"] = "#AC0059"; colors["Yellow"] = "#FFFF00"; colors["Ivory"] = "#FEFF9B"; colors["Electric Purple"] = "#B70AFF"; colors["Deep Pink"] = "#FF00B1"; colors["Aqua"] = "#4EFFFF"; colors["Dark Green"] = "#008000"; colors["Red"] = "#FF0000"; colors["Green"] = "#00FF05"; colors["Saddle Brown"] = "#94652E"; colors["Orange Red"] = "#FF4700"; colors["Light Blue"] = "#23A0FF"; colors["Orchid"] = "#FF87FF"; colors["Brown"] = "#943E3E"; colors["Copper Rose"] = "#AD7E7E"; colors["Tan"] = "#FFAF56"; colors["Lime"] = "#8EBE57"; colors["Tyrian Purple"] = "#990024"; colors["Mardi Gras"] = "#880085"; colors["Royal Blue"] = "#4169E1"; colors["Wild Strawberry"] = "#FF43A4"; colors["Smoky Black"] = "#100C08"; colors["Goldenrod"] = "#DAA520"; colors["Cyan"] = "#00FFFF"; colors["Artichoke"] = "#8F9779"; colors["Rain Forest"] = "#00755E"; colors["Peach"] = "#FFE5B4"; colors["Apple Green"] = "#8DB600"; colors["Viridian"] = "#40826D"; colors["Mahogany"] = "#C04000"; colors["Pink Lace"] = "#FFDDF4"; colors["Bronze"] = "#CD7F32"; colors["Wood Brown"] = "#C19A6B"; colors["Tuscany"] = "#C09999"; colors["Acid Green"] = "#B0BF1A"; colors["Amazon"] = "#3B7A57"; colors["Army Green"] = "#4B5320"; colors["Donkey Brown"] = "#664C28"; colors["Cordovan"] = "#893F45"; colors["Cinnamon"] = "#D2691E"; colors["Charcoal"] = "#36454F"; colors["Fuchsia"] = "#FF00FF"; colors["Screamin' Green"] = "#76FF7A";
	return colors;
end

function getNewHorz(parent)
	horz = UI.CreateHorizontalLayoutGroup(parent);
	table.insert(horzs, horz)
	return horz;
end

function getNewVert(parent)
	vert = UI.CreateVerticalLayoutGroup(parent);
	table.insert(verts, vert);
	return vert;
end

function createLabel(parent, text, color)
	table.insert(labels, UI.CreateLabel(parent).SetText(text).SetColor(color));
end

function createButton(parent, text, color, func)
	table.insert(buttons, UI.CreateButton(parent).SetText(text).SetColor(color).SetOnClick(func));
end

function createTextInputField(parent, text, interactable)
	interactable = interactable or true;
	field = UI.CreateTextInputField(parent).SetText(text).SetInteractable(interactable)
	table.insert(texts, field);
	return field;
end

function createNumberInputField(parent, value, sliderMinValue, sliderMaxValue, wholeNumbers, interactable)
	wholeNumbers = wholeNumbers or true;
	interactable = interactable or true;
	field = UI.CreateNumberInputField(parent).SetSliderMinValue(sliderMinValue).SetSliderMaxValue(sliderMaxValue).SetValue(value).SetWholeNumbers(wholeNumbers).SetInteractable(interactable);
	table.insert(numbers, field);
	return field;
end

function createCheckBox(parent, value, text, interactable)
	interactable = interactable or true;
	CheckBox = UI.CreateCheckBox(parent).SetIsChecked(value).SetText(text).SetInteractable(interactable);
	table.insert(boxes, CheckBox)
	return CheckBox;
end

function getColor(playerName, players, colorString)
	colorString = colorString or "#FF2222";
	for ID, player in pairs(players) do
		if player.DisplayName(nil, false) == playerName then 
			return player.Color.HtmlColor
		end
	end
	return colorString;
end

function destroyAll()
	destroyItems(horzs);
	destroyItems(verts);
	destroyItems(labels);
	destroyItems(buttons);
	destroyItems(texts);
	destroyItems(numbers);
	destroyItems(boxes);
	init()
end

function destroyItems(list)
	for _, item in pairs(list) do
		UI.Destroy(item);
	end
end