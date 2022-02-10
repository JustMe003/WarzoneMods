require("UI");
require("utilities");

function Client_PresentConfigureUI(rootParent)
	init(rootParent);

	initManuals();
	initCompatibility();
	bugs = getBugs();
	
	local vert = newVerticalGroup("vert", "root");
	
	modList = getMods();
	modsInit = Mod.Settings.Mods
	if modsInit == nil then
		modsInit = {};
		for _, mod in pairs(modList) do
			modsInit[mod] = false;
		end
	end
	
	modsChecked = getTotalModsIncluded();
	
	pages = {pageOne, pageTwo, pageThree, pageFour, pageFive};
	page = 1;
		
	allObjects = getAllObjects();
	
	showDescription();
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
end


function pageUp()
	if page + 1 <= math.ceil(getTableLength(modList) / 10) then
		page = page + 1;
		showPage();
	elseif page == math.ceil(getTableLength(modList) / 10) then
		page = 1;
		showPage();
	end
end

function pageDown()
	if page - 1 >= 1 then
		page = page - 1
		showPage();
	elseif page == 1 then
		page = math.ceil(getTableLength(modList) / 10);
		showPage();
	end
end

function showPage()
	local win = "page" .. page;
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
			updateText("pageNumber", page .. " / " .. math.ceil(getTableLength(modList) / 10));
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel("DescriptionLabel", vert, "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked", "Orange Red");
		newLabel("MoreInfoInExtras", vert, "For more information about the mods their colors please go to [Extras]", "Orange");
		for _, str in pairs(getSubArray(modList, (page - 1) * 10 + 1, page * 10)) do
			local line = newHorizontalGroup(str .. "Hor", vert)
			newCheckbox(str, line, " ", modsInit[str], true, function() updateLabel(str); end);
			newLabel(str .. "Label", line, str, getColorFromStatus(str));
			if tostring(bugs[str]) ~= "nil" and bugs[str] ~= getBugFreeMessage() then
				newButton(str .. " Bugs", line, "?", function() UI.Alert(tostring(bugs[str])); end, "Green");
			end
		end
		local line = newHorizontalGroup("buttons", vert);
		newButton("PageDown", line, "Page down", pageDown, "Hot Pink");
		newLabel("pageNumber", line, page .. " / " .. math.ceil(getTableLength(modList) / 10), "Orchid");
		newButton("PageUp", line, "Page up", pageUp, "Hot Pink");
	end
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
end

function showModInformation()
	local win = "modInformation";
	if windowExists(win) then
		destroyWindow(getCurrentWindow());
		resetWindow(win)
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel(win .. "descriptionLabel", vert, "Here below you will find every mod you've added so far as a button. When you click on a button it will take you to the mod manual where you can more information on how you can set the mod up, what bugs there currently are and what the compatibility of the mod is", "yellow");
		for mod, bool in pairs(modsInit) do
			if bool then
				newButton(mod .. "buttonInformation", vert, mod, function() showModManual(mod); end, getColorFromStatus(mod), getContents(mod) ~= nil)
			elseif objectExists(mod) then
				if getIsChecked(mod) then
					newButton(mod .. "buttonInformation", vert, mod, function() showModManual(mod); end, getColorFromStatus(mod), getContents(mod) ~= nil)
				end
			end
		end
	else	
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		showButtons(vert);
		newLabel(win .. "descriptionLabel", vert, "Here below you will find every mod you've added so far as a button. When you click on a button it will take you to the mod manual where you can more information on how you can set the mod up, what bugs there currently are and what the compatibility of the mod is", "yellow");
		for mod, bool in pairs(modsInit) do
			if bool then
				newButton(mod .. "buttonInformation", vert, mod, function() showModManual(mod); end, getColorFromStatus(mod), getContents(mod) ~= nil)
			elseif objectExists(mod) then
				if getIsChecked(mod) then
					newButton(mod .. "buttonInformation", vert, mod, function() showModManual(mod); end, getColorFromStatus(mod), getContents(mod) ~= nil)
				end
			end
		end
	end
end

function showModManual(path)
	local win = path;
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
		local content = getContents(path);
		if type(content) == type(table) then
			for i,_ in pairs(content) do
				newButton(win .. i, vert, i, function() showModManual(path .. "/" .. i); end, "Tyrian Purple");
			end
		else
			newLabel(win .. "label", vert, content);
		end
		newButton(win .. "return", vert, "Return", showModInformation, "Green");
	end
end

function updateLabel(name)
	if checkModInterference(name) then
		for mod, bool in pairs(modsInit) do
			if bool then
				local modInterference = checkModInterference(name, mod)
				if type(modInterference) == type(table) then
					UI.Alert("Mods: " .. name .. ", " .. mod .. "\nOccurance: " .. modInterference.Occurance .. "\n\n" .. modInterference.Message);
				end
			elseif objectExists(mod) then
				if getIsChecked(mod) then
					local modInterference = checkModInterference(name, mod)
					if type(modInterference) == type(table) then
						UI.Alert("Mods: " .. name .. ", " .. mod .. "\nOccurance: " .. modInterference.Occurance .. "\n\n" .. modInterference.Message);
					end
				end
			end
		end
	end
	if getIsChecked(name) then
		modsChecked = modsChecked + 1;
		updateColor(name .. "Label", "#3333FF");
	else
		modsChecked = modsChecked - 1;
		updateColor(name .. "Label", getColorFromStatus(name));
	end
	updateText("DescriptionLabel", "Check all the mods the game will use. Currently " .. modsChecked .. " mods checked");
	updateInteractable(modInformation, modsChecked > 0);
end

function showButtons(vert)
	local line = newHorizontalGroup("hor", vert);
	description = newButton("desc", line, "Description", showDescription, "Green");
	settings = newButton("sett", line, "Settings", showPage, "Blue");
	extra = newButton("extr", line, "Extra", showExtras, "Tyrian Purple");
	modInformation = newButton("modInformation", line, "Mod information", showModInformation, "Orange", modsChecked > 0);
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