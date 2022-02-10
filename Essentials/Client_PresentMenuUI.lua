require("UI");
require("utilities");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(500, 500)
	Close = close;
	init(rootParent);
	initManuals();
	route = {};
	currentPageIndex = #route;
	routingBack = false;
	showMainMenu();
end

function showMainMenu()
	local win = "showMainMenu";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "Label1", vert, "Main Menu", "Electric Purple");
		newButton(win .. "InGameMods", vert, "Mod manuals", inGameMods, "Lime");
		newButton(win .. "NotInGameMods", vert, "Other Mod manuals", notInGameMods, "Orange Red");
		newButton("return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function notInGameMods()
	local win = "notInGameModsMain";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		for i, v in pairs(Mod.Settings.Mods) do
			print(i, v);
			if not v then
				local interactable = not (getContents(i) == nil);
				newButton(win .. i, vert, i, function() seeContents(i); end, "Light Blue", interactable);
			end
		end
		newButton("return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function inGameMods()
	local win = "inGameModsMain";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		for i, v in pairs(Mod.Settings.Mods) do
			if v then
				local interactable = not (getContents(i) == nil);
				newButton(win .. i, vert, i, function() seeContents(i); end, "Light Blue", interactable);
			end
		end
		newButton("return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function seeContents(path)
	print(path);
	local win = path;
	if windowExists(win) then
		if getCurrentWindow(win) ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local contents = getContents(path);
		local vert = newVerticalGroup("vert", "root");
		if type(contents) == type(table) then
			newLabel(win .. "ChoosePath", vert, "Choose from one of the options", "Orange");
			for i, v in pairs(contents) do
				newButton(win .. i, vert, i, function() seeContents(path .. "/" .. i); end, "Royal Blue")
			end
		elseif type(contents) == type("") then
			newLabel(win .. "Text", vert, contents, "#DDDDDD");
		end
		newButton(win .. "return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function routeBack()
	if currentPageIndex > 1 then
		currentPageIndex = currentPageIndex - 1;
		destroyWindow(getCurrentWindow());
		restoreWindow(route[currentPageIndex]);
	else
		Close();
	end
end

function showModMenuManual()
	local win = "showModMenuManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel("title showModMenuManual", vert, "Mod Menu", "Ivory");
		newLabel("text1 showModMenuManual", vert, "One property a lot of mods make use of is a mod menu. A menu is mostly used to get input from the player, process the input and do something according to the input (give gold to a certain player, send an alliance request or create a new window to ask for more input).");
	end
end


function showOrderListManual()
	local win = "showOrderListManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
	end
end

function showTurnManual()
	local win = "showTurnManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
	end
end


function showStandingManual()
	local win = "showStandingManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
	end
end



function showModConfigurationManual()
	local win = "showModConfigurationManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
	end
end


function showModSettingsManual()
	local win = "showModSettingsManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
	end
end


function showInputOutputManual()
	local win = "showInputOutputManual";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
	end
end


function initFunctions()
	local t = {};
	t.Essentials = {};
	t.Manuals = {};
	t.Essentials.ModMenu = showModMenuManual;
	t.Essentials.OrderList = showOrderListManual;
	t.Essentials.Turn = showTurnManual;
	t.Essentials.Standing = showStandingManual;
	t.Essentials.ModConfiguration = showModConfigurationManual;
	t.Essentials.ModSettings = showModSettingsManual;
	t.Essentials.InputOutput = showInputOutputManual;
--	t.Manuals.ModDescription = showModDescription;
--	t.Manuals.HowToUse = showHowToUse;
--	t.Manuals.HowToSetUp = showHowToSetUp;
--	t.manuals.Bugs = showBugs;
--	t.manuals.Compatibility = showCompatibility;
end