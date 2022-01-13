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
	colors.TextColor = "#AAAAAA"; colors.ErrorColor = "#FF2222"; colors.TrueColor = "#33AA33"; colors.FalseColor = "#AA3333"; colors.NumberColor = "#3333AA"; colors.WarningNumberColor = "#DD1111"; colors.Lime = "#88DD00"; colors.Blue = "#0000FF"; colors.Purple = "#800080"; colors.Orange = "#ffa500"; colors.DarkGray = "#A9A9A9"; colors.HotPink = "#FF69B4"; colors.SeaGreen = "#93E9BE"; colors.Teal = "#008080"; colors.DarkMagenta = "#8b008b"; colors.Yellow = "#FFFF00"; colors.Ivory = "#FFFFF0"; colors.ElectricPurple = "#bf00ff"; colors.DeepPink = "#FF1493"; colors.Aqua = "#00FFFF"; colors.DarkGreen = "#006400"; colors.Red = "#FF0000"; colors.Green = "#00FF00"; colors.SaddleBrown = "#8b4513"; colors.OrangeRed = "#FF5349"; colors.LightBlue = "#ADD8E6"; colors.Orchid = "#DA70D6"; colors.Brown = "#964B00"; colors.CopperRose = "#996666"; colors.Tan = "#D2B48C"; colors.TyrianPurple = "#630330"; colors.MardiGras = "#880085"; colors.RoyalBlue = "#4169e1"; colors.WildStrawberry = "#ff43a4";
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
	Interactable = interactable or true;
	CheckBox = UI.CreateCheckBox(parent).SetIsChecked(value).SetText(text).SetInteractable(Interactable);
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