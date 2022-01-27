require("UI");
require("utilities");

function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	
	local vert = newVerticalGroup("vert", "root");
	
	mods = getMods();
	modsInit = Mod.Settings.Mods
	if modsInit == nil then
		modsInit = {};
		for _, mod in pairs(mods) do
			modsInit[mod] = false;
		end
	end
	
	modsChecked = getTotalModsIncluded();
	
	pages = {pageOne, pageTwo, pageThree, pageFour, pageFive};
		
	allObjects = getAllObjects();
	
	showButtons(vert)
end


function showDescription()
	local win = "Desc";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("desc1", vert, "This mod was made to provide manuals for all the individual mods and help to avoid games having incompatible mods combined. As game creator you should check every checkbox according to which mods the game is using. This is because mods can not detect which other mods are being used in the game, I hope to be able to detect other mods being used somewhere soon.", "Lime");
		newLabel("desc2", vert, "The other use for this mod is to showcase this new UI.lua file that helps with creating the UI. These settings are 1 showcase, the other can be found in the mod menu", "Apple Green");
	end
	allObjects = getAllObjects();
end

function showSettings()
	local win = "Set";
	page = 1;
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
		pageOne();
	else
		destroyWindow(getCurrentWindow());
		window(win);
		pageOne();
	end
	allObjects = getAllObjects();
end

function pageUp()
	if page + 1 <= #pages then
		page = page + 1;
		pages[page]();
	elseif page == #pages then
		page = 1;
		pages[page]();
	end
end

function pageDown()
	if page - 1 >= 1 then
		page = page - 1
		pages[page]();
	elseif page == 1 then
		page = #pages;
		pages[page]();
	end
end

function pageOne()
	local win = "pageOne";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("pageNumber", "1 / " .. #pages);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("DescriptionLabel", vert, "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked", "Orange Red");
		newLabel("MoreInfoInExtras", vert, "For more information about the mods their colors please go to [Extras]", "Orange");
		for _, str in pairs(getSubArray(mods, 1, 10)) do
			local line = newHorizontalGroup(str .. "Hor", vert)
			newCheckbox(str, line, " ", modsInit[str], true, function() updateLabel(str); end);
			newLabel(str .. "Label", line, str, getColorFromStatus(str));
		end
		local line = newHorizontalGroup("buttons", vert);
		newButton("PageDown", line, "Page down", pageDown, "Hot Pink")
		newLabel("pageNumber", line, "1 / " .. #pages, "Orchid") 
		newButton("PageUp", line, "Page up", pageUp, "Hot Pink");
	end
	allObjects = getAllObjects();
end

function pageTwo()
	local win = "pageTwo";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("pageNumber", "2 / " .. #pages);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("DescriptionLabel", vert, "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked", "Orange Red");
		newLabel("MoreInfoInExtras", vert, "For more information about the mods their colors please go to [Extras]", "Orange");
		for _, str in pairs(getSubArray(mods, 11, 20)) do
			local line = newHorizontalGroup(str .. "Hor", vert);
			newCheckbox(str, line, " ", modsInit[str], true, function() updateLabel(str); end);
			newLabel(str .. "Label", line, str, getColorFromStatus(str));
		end
		local line = newHorizontalGroup("buttons", vert);
		newButton("PageDown", line, "Page down", pageDown, "Hot Pink")
		newLabel("pageNumber", line, "2 / " .. #pages, "Orchid") 		
		newButton("PageUp", line, "Page up", pageUp, "Hot Pink");
	end
	allObjects = getAllObjects();
end

function pageThree()
	local win = "pageThree";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("pageNumber", "3 / " .. #pages);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("DescriptionLabel", vert, "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked", "Orange Red");
		newLabel("MoreInfoInExtras", vert, "For more information about the mods their colors please go to [Extras]", "Orange");
		for _, str in pairs(getSubArray(mods, 21, 30)) do
			local line = newHorizontalGroup(str .. "Hor", vert);
			newCheckbox(str, line, " ", modsInit[str], true, function() updateLabel(str); end);
			newLabel(str .. "Label", line, str, getColorFromStatus(str));
		end
		local line = newHorizontalGroup("buttons", vert);
		newButton("PageDown", line, "Page down", pageDown, "Hot Pink")
		newLabel("pageNumber", line, "3 / " .. #pages, "Orchid") 
		newButton("PageUp", line, "Page up", pageUp, "Hot Pink");
	end
	allObjects = getAllObjects();
end

function pageFour()
	local win = "pageFour";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("pageNumber", "4 / " .. #pages);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("DescriptionLabel", vert, "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked", "Orange Red");
		newLabel("MoreInfoInExtras", vert, "For more information about the mods their colors please go to [Extras]", "Orange");
		for _, str in pairs(getSubArray(mods, 31, 40)) do
			local line = newHorizontalGroup(str .. "Hor", vert);
			newCheckbox(str, line, " ", modsInit[str], true, function() updateLabel(str); end);
			newLabel(str .. "Label", line, str, getColorFromStatus(str));
		end
		local line = newHorizontalGroup("buttons", vert);
		newButton("PageDown", line, "Page down", pageDown, "Hot Pink")
		newLabel("pageNumber", line, "4 / " .. #pages, "Orchid") 
		newButton("PageUp", line, "Page up", pageUp, "Hot Pink");
	end
	allObjects = getAllObjects();
end

function pageFive()
	local win = "pageFive";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("pageNumber", "5 / " .. #pages);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("DescriptionLabel", vert, "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked", "Orange Red");
		newLabel("MoreInfoInExtras", vert, "For more information about the mods their colors please go to [Extras]", "Orange");
		for _, str in pairs(getSubArray(mods, 41, #mods)) do
			local line = newHorizontalGroup(str .. "Hor", vert);
			newCheckbox(str, line, " ", modsInit[str], true, function() updateLabel(str); end);
			newLabel(str .. "Label", line, str, getColorFromStatus(str));
		end
		local line = newHorizontalGroup("buttons", vert);
		newButton("PageDown", line, "Page down", pageDown, "Hot Pink")
		newLabel("pageNumber", line, "5 / " .. #pages, "Orchid") 
		newButton("PageUp", line, "Page up", pageUp, "Hot Pink");
	end
	allObjects = getAllObjects();
end

function showExtras()
	local win = "Extra";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win)
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("credits", vert, "This UI.lua file was a lot of work and probably still will throw errors. If you're missing anything or having trouble using it please message me", "Light Blue")
		newLabel("credits2", vert, "Note that this mod will add the mod list to the description. This way every player has the ability to know which mods are being used without reading the settings", "Royal Blue");
		newLabel("modColorsStart", vert, "You might have noticed the mods in the window [Settings] are all coloured. These colors indicate in what state the mod is:", "Cyan")
		newLabel("modColorExampleTrusted", vert, "(Mod Name)   Trusted", "Lime");
		newLabel("modColorTrusted", vert, "This color (Lime) indicates the mod is trusted. This means that this mod is generally free of bugs and (almost) never crashes. These type of mods can be included in tournaments", "Cyan");
		newLabel("modColorExampleStandard", vert, "(Mod Name)   Standard", "Orange");
		newLabel("modColorStandard", vert, "This color (Orange) indicates the mod has the state 'standard'. This is some sort of state between trusted and experimental and generally means this mod is very unlikely to crash your game", "Cyan");
		newLabel("modColorExampleExperimental", vert, "(Mod Name)   Experimental", "Orange Red");
		newLabel("modColorExperimental", vert, "This is the lowest state a mod can be in and be public, named 'experimental'. These mods are mostly (relatively) new and / or are rarely used. In order to make these mods 'standard' they have to be used in a lot of games without the game crashing which takes time", "Cyan");
		newLabel("modColorExamplePicked", vert, "(Mod Name)   Picked", "#3333FF");
		newLabel("modColorPicked", vert, "This color indicates only that you have checked its checkbox", "Cyan");
	end
	allObjects = getAllObjects();
end

function updateLabel(name)
	if getIsChecked(name) then
		modsChecked = modsChecked + 1;
		updateColor(name .. "Label", "#3333FF");
	else
		modsChecked = modsChecked - 1;
		updateColor(name .. "Label", getColorFromStatus(name));
	end
	updateText("DescriptionLabel", "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked");
end

function showButtons(vert)
	local line = newHorizontalGroup("hor", vert);
	description = newButton("desc", line, "Description", showDescription, "Green");
	settings = newButton("sett", line, "Settings", showSettings, "Blue");
	extra = newButton("extr", line, "Extras", showExtras, "Tyrian Purple");
end


function getSubArray(array, start, ending)
	local ret = {};
	for index = start, ending do
		table.insert(ret, array[index]);
	end
	return ret;
end

function getTotalModsIncluded() 
	local int = 0; 
	for _, v in pairs(modsInit) do 
		if v then 
			int = int + 1; 
		end 
	end 
	return int;
end


function getColorFromStatus(mod)
	local status = getStatus(mod);
	if status == "trusted" then
		return "Lime";
	elseif status == "standard" then
		return "Orange";
	else
		return "Orange Red";
	end
end