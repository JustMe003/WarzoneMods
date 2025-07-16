require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Settings.MultiPlayer then 
		UI.Alert("Building a custom scenario with structures is only possible in singleplayer");
		close();
		return; 
	end
	if game.Game.TurnNumber == 1 then
		UI.Alert("To avoid annoyance you should commit for the first turn. All orders will be skipped");
		close();
		return;
	end
	setMaxSize(420, 350);
	Game = game;
	init(rootParent);
	local vert = newVerticalGroup("vert", "root");
	newButton("start", vert, "Start", selectTerritories, "Green");
	newButton("Stop", vert, "Get data", getDataString, "Orange Red");
	str = "currently selected territories: \n";
	if terrList == nil then 
		terrList = {}; 
	end
	if selectMode == nil then 
		selectMode = "bonus";
	end
end

function selectTerritories()
	local win = "select";
	if windowExists(win) then
		destroyWindow(getCurrentWindow())
		restoreWindow(win)
		updateTerrLabel();
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		local line = newHorizontalGroup(win .. "line1", vert);
		newButton("chooseStructure", line, "Choose structure", pickStructure, "Orange");
		newButton("Remove all selected", line, "Remove all selected", function() terrList = {}; updateTerrLabel(); end, "Red");
		selectModeSwitch = newButton("selectMode", vert, "Select mode: " .. selectMode, function() if selectMode == "bonus" then selectMode = "territory"; else selectMode = "bonus"; end updateText(selectModeSwitch, "Select mode: " .. selectMode); getClick(); end, "Green");
		line = newHorizontalGroup(win .. "line2", vert);
		rem = newCheckbox("reverse", line, " ", false);
		newLabel("reverseLabel", line, "Remove structure instead of adding it", "Lime");
		terrLabel = newLabel("terrLabel", vert, str);
		if #terrList > 0 then
			updateTerrLabel();
		end
		getClick();
	end
end
function getClick();
	if selectMode == "bonus" then
		UI.InterceptNextBonusLinkClick(function(details) if selectMode == "bonus" then validateBonus(details) end end);
	else
		UI.InterceptNextTerritoryClick(function(details) if selectMode == "territory" then validateTerritory(details) end end);
	end
end

function validateBonus(details)
	if details == nil then return; end
	for _, terr in pairs(details.Territories) do
		addOrRemove(terrList, terr);
	end
	updateTerrLabel();
	getClick();
end

function validateTerritory(details)
	if details == nil then return; end
	addOrRemove(terrList, details.ID);
	updateTerrLabel();
	getClick();
end

function updateTerrLabel()
	local s = str;
	for _, v in pairs(terrList) do
		s = s .. Game.Map.Territories[v].Name .. ", ";
	end
	if getCurrentWindow() == "select" then updateText(terrLabel, s); end
end

function pickStructure()
	if #terrList < 1 then return; end
	local list = {};
	for i, v in pairs(WL.StructureType) do
		if type(v) ~= type(pickStructure) then
			local l = {};
			l["text"] = i;
			l["selected"] = function() createOrder(v) end
			table.insert(list, l);
		end
	end
	UI.PromptFromList("Pick a structure", list);
end

function createOrder(structure)
	local list = {};
	local s = "CustomScenarioStructures_";
	if getIsChecked(rem) then
		s = s .. "Remove_" .. structure;
	else
		s = s .. "Add_" .. structure;
	end
	table.insert(list, s);
	local count = 1;
	for _, terr in pairs(terrList) do
		if count == 100 then 
			count = 1;
			table.insert(list, s);
		end
		list[#list] = list[#list] .. "_" .. terr;
		count = count + 1;
	end
	orders = Game.Orders;
	if orders == nil then orders = {}; end
	for _, v in pairs(list) do
		local order = WL.GameOrderCustom.Create(Game.Us.ID, "added structures to some territories", v);
		table.insert(orders, order)
	end
	Game.Orders = orders;
	selectTerritories();
end

function addOrRemove(list, value)
	local bool = false;
	for i, v in pairs(list) do
		if v == value then
			list[i] = nil;
			bool = true;
			break;
		end
	end
	if not bool then table.insert(list, value); end
	return list;
end

function getDataString()
	local s = "[" .. Game.Map.ID .. "]{";
	for _, terr in pairs(Game.LatestStanding.Territories) do
		if terr.Structures ~= nil then
			s = s .. terr.ID .. "{";
			for i, v in pairs(terr.Structures) do
				s = s .. i .. "{" .. v .. "}";
			end
			s = s .. "}";
		end
	end
	s = s .. "}";
	print(s);
	local win = "showData";
	if windowExists(win) then
		destroyWindow(getCurrentWindow())
		restoreWindow(win)
		updateText(data, s);
	else
		destroyWindow(getCurrentWindow());
		window(win)
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "desc", vert, "Copy the text below and paste it into the mod configuration");
		data = newTextField("data", vert, " ", s, 0, true, 350, -1, 0, 0);
	end
end

