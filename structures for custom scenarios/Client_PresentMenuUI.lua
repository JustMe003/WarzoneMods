require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Settings.MultiPlayer then return; end
	Game = game;
	init(rootParent);
	local vert = newVerticalGroup("vert", "root");
	newButton("start", vert, "Start", selectTerritories, "Green");
	if terrList == nil then terrList = {}; end
	str = "currently selected territories: \n";
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
		newButton("chooseStructure", vert, "Choose structure", pickStructure, "Orange");
		newButton("Remove all selected", vert, "Remove all selected", function() terrList = {}; updateTerrLabel(); end, "Red");
		terrLabel = newLabel("terrLabel", vert, str);
		getClick();
		newButton("Stop", vert, "Get data", getDataString, "Orange Red");
	end
end
function getClick();
	UI.InterceptNextTerritoryClick(validateTerritory);
	UI.InterceptNextBonusLinkClick(validateBonus);
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
	updateText(terrLabel, s);
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
	local s = "CustomScenarioStructures_Add_" .. structure;
	table.insert(list, s);
	local count = 1;
	for _, terr in pairs(terrList) do
		if count == 20 then 
			count = 1;
			table.insert(list, s);
		end
		list[#list] = list[#list] .. "_" .. terr;
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
		data = newTextField("data", vert, " ", s);
	end
end

-- [34519]{ID:5{Structure:4{Amount:1}},ID:7{Structure:4{Amount:1}},ID:8{Structure:4{Amount:1}},ID:1444{Structure:4{Amount:1}}}