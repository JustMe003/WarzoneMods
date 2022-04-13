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
		newButton(win .. "InGameMods", vert, "Mod manuals", function() inGameMods(1) end, "Lime");
		newButton(win .. "NotInGameMods", vert, "Other Mod manuals", function() notInGameMods(1) end, "Orange Red");
		newButton("return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function notInGameMods(n)
	local win = "notInGameModsMain" .. n;
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		local count = 0;
		for i, v in pairs(Mod.Settings.Mods) do
			if not v then
				if count >= (n-1) * 10 and count < n * 10 then
					local interactable = not (getContents(i) == nil);
					newButton(win .. i, vert, i, function() seeContents(i); end, "Light Blue", interactable);
				end
				count = count + 1;
			end
		end
		pageControlButtons(win, vert, notInGameMods, n, math.ceil(count / 10));
		newButton("return", vert, "Return", routeBack, "Green");
	end
	if not string.find(route[currentPageIndex], win) then
		currentPageIndex = currentPageIndex + 1;
	end
	route[currentPageIndex] = win;
end

function inGameMods(n)
	local win = "inGameModsMain" .. n;
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		local count = 0;
		for i, v in pairs(Mod.Settings.Mods) do
			if v then
				if count >= (n-1) * 10 and count < n * 10 then
					local interactable = not (getContents(i) == nil);
					newButton(win .. i, vert, i, function() seeContents(i); end, "Light Blue", interactable);
				end
				count = count + 1;
			end
		end
		pageControlButtons(win, vert, inGameMods, n, math.ceil(count / 10));
		newButton("return", vert, "Return", routeBack, "Green");
	end
	if not string.find(route[currentPageIndex], win) then
		currentPageIndex = currentPageIndex + 1;
	end
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

function pageControlButtons(win, vert, func, n, nPages)
	if nPages <= 1 then return; end
	local line = newHorizontalGroup(win .. "pageControlLine", vert);
	if n == 1 then
		newButton(win .. "pageDown", line, "Page down", function() func(nPages) end, "Orchid");
	else
		newButton(win .. "pageDown", line, "Page down", function() func(n - 1) end, "Orchid");
	end
	newLabel(win .. "pageNumber", line, n .. " / " .. nPages, "Deep Pink");
	if n == nPages then
		newButton(win .. "pageUp", line, "page up", function() func(1) end, "Orchid");
	else
		newButton(win .. "pageUp", line, "Page up", function() func(n + 1) end, "Orchid");
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