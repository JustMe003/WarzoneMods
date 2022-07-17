require("UI");
require("utilities");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(500, 530)
	Close = close;
	init(rootParent);
	initManuals();
	initSeeAlsoList();
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
		newButton(win .. "showMods", vert, "Mod manuals", function() showMods(1) end, "Lime");
		newButton("return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function showMods(n)
	local win = "showModsMain" .. n;
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
			if count >= (n-1) * 10 and count < n * 10 then
				local interactable = not (getContents(i) == nil);
				newButton(win .. i, vert, i, function() seeContents(i); end, "Light Blue", interactable);
			end
				count = count + 1;
		end
		pageControlButtons(win, vert, showMods, n, math.ceil(count / 10));
		newButton("return", vert, "Return", routeBack, "Green");
	end
	if string.find(route[currentPageIndex], "showModsMain") == nil then
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
		newLabel(win .. "Path", vert, path .. "\n\n", "Cyan");
		if type(contents) == type(table) then
			newLabel(win .. "ChoosePath", vert, "Choose from one of the options", "Orange");
			for i, v in pairs(contents) do
				newButton(win .. i, vert, i, function() seeContents(path .. "/" .. i); end, "Royal Blue")
			end
		elseif type(contents) == type("") then
			newLabel(win .. "Text", vert, contents, "#DDDDDD");
		else
			newLabel(win .. "ErrorMessage", vert, "It seems like this page does not exists. It is most likely that this page has not been implemented yet into the mod, stay tuned.", "Orange");
		end
		if seeAlsoList[path] ~= nil then
			newButton(win .. "SeeAlsoButton", vert, "See also", function() seeAlsoPages(path); end, "Cyan");
		end
		newButton(win .. "return", vert, "Return", routeBack, "Green");
	end
	currentPageIndex = currentPageIndex + 1;
	route[currentPageIndex] = win;
end

function seeAlsoPages(path)
	local win = "seeAlsoPages" .. path;
	if windowExists(win) then
		if getCurrentWindow(win) ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup(win .. "vert", "root");
		for _, v in pairs(seeAlsoList[path]) do
			local arrayOfPath = split(v, "/");
			newButton(win .. v, vert, arrayOfPath[#arrayOfPath], function() seeContents(v); end, "Lime");
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
