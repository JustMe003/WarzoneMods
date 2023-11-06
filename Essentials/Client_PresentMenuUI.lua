require("UI");
require("utilities");
require("SpecialUnitsData");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, func)
	setMaxSize(500, 585)
	Close = close;
	Init(rootParent);
	root = GetRoot();
	root.SetFlexibleWidth(1);
	colors = GetColors();
	Path = "MAIN";
	Game = game;
	inspectToolInUse = false;
	Filters = {};

	-- permanent labels
	local line = CreateHorz(root);
	CreateLabel(line).SetText("Mod Author: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	line = CreateHorz(root);
	CreateLabel(line).SetText("Version: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText("2.0").SetColor(colors["Royal Blue"]);
	CreateEmpty(root).SetPreferredHeight(10);

	-- makes sure the lines above stay
	SetWindow("DummyWindow");
	--[[
	numOfClicks = 1;
	terrClicked = -1;
	UI.InterceptNextTerritoryClick(getTerritoryClickedTest);
	]]--
	if func == nil then
		showMainMenu();
	else
		func();
	end
end

function getTerritoryClickedTest(terrDetails)
	if terrDetails == nil then return WL.CancelClickIntercept; end
	if terrClicked == terrDetails.ID then
		numOfClicks = numOfClicks + 1;
	else
		numOfClicks = 1;
	end
	terrClicked = terrDetails.ID;
	if numOfClicks == 3 then
		local sps = Game.LatestStanding.Territories[terrDetails.ID].NumArmies.SpecialUnits;
		if not tableIsEmpty(sps) then
			if #sps > 1 then
				pickUnitOfList(sps);
			else
				inspectUnit(sps[1], inspectUnitMenu);
			end
		end
		numOfClicks = 0;
	end
	UI.InterceptNextTerritoryClick(getTerritoryClickedTest);
	return WL.CancelClickIntercept;
end

function showMainMenu()
	DestroyWindow();
	SetWindow("showMainMenu");
	CreateLabel(root).SetText("Main Menu").SetColor(colors.TextColor);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateButton(root).SetText("Mod Manuals").SetOnClick(function() showMods(1) end).SetColor(colors.Lime);
	CreateButton(root).SetText("Unit Inspector").SetColor(colors.Blue).SetOnClick(inspectUnitMenu);
	CreateButton(root).SetText("(Document) Links").SetColor(colors.Yellow).SetOnClick(showDocumentLinks);
	CreateButton(root).SetText("Order Finder").SetOnClick(function() orderFinderMain(1) end).SetColor(colors.Orange).SetInteractable(Game.Us ~= nil and Game.Us.ID == 1311724);
	CreateButton(root).SetText("Return").SetOnClick(function() Close() end).SetColor(colors["Green"]);
end

function showMods(n)
	DestroyWindow();
	SetWindow("showMods");
	local mods = getMods();
	for i = (n-1) * 10 + 1, n * 10 do
		if mods[i] ~= nil then
			CreateButton(root).SetText(mods[i]).SetOnClick(function() seeContents(mods[i]); end).SetColor(colors["Light Blue"]).SetInteractable(not (getContents(mods[i]) == nil)).SetFlexibleWidth(0);
		else
			break;
		end
	end
	pageControlButtons(showMods, n, math.ceil(#mods / 10));
	CreateButton(root).SetText("Return").SetOnClick(showMainMenu).SetColor(colors["Green"]);
end

function seeContents(path)
	Path = path;
	DestroyWindow();
	SetWindow(path);
	local contents = getContents(path);
	CreateLabel(root).SetText(path .. "\n\n").SetColor(colors.Lime);
	if type(contents) == type(table) then
		CreateLabel(root).SetText("Choose from one of the options").SetColor(colors["Orange"]);
		for i, v in pairs(contents) do
			CreateButton(root).SetText(i).SetOnClick(function() seeContents(path .. "/" .. i); end).SetColor(colors["Royal Blue"]);
		end
	elseif type(contents) == type("") then
		CreateLabel(root).SetText(contents).SetColor(colors.TextColor);
	else
		CreateLabel(root).SetText("It seems like this page does not exists. It is most likely that this page has not been implemented yet into the mod, stay tuned.").SetColor(colors["Orange"]);
	end
	if getSeeAlsoList(path) ~= nil then
		CreateButton(root).SetText("See also").SetOnClick(function() seeAlsoPages(path); end).SetColor(colors["Cyan"]);
	end
	CreateButton(root).SetText("Return").SetOnClick(routeBack).SetColor(colors["Green"]);
end

function seeAlsoPages(path)
	Path = path .. "/See also list";
	DestroyWindow();
	SetWindow(path);
	for _, v in pairs(getSeeAlsoList(path)) do
		local arrayOfPath = split(v, "/");
		CreateButton(root).SetText(arrayOfPath[#arrayOfPath]).SetOnClick(function() seeContents(v); end).SetColor(colors["Lime"]);
	end
	CreateButton(root).SetText("Return").SetOnClick(routeBack).SetColor(colors["Green"]);
end

function routeBack()
	local info = split(Path, "/");
	if #info == 1 then
		showMods(1);
	else
		info[#info] = nil;
		Path = table.concat(info, "/");
		seeContents(Path);
	end
end

function pageControlButtons(func, n, nPages)
	if nPages <= 1 then return; end
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	local previous = CreateButton(line).SetText("Previous").SetColor(colors.Blue).SetPreferredWidth(75);
	CreateLabel(line).SetText(n .. " / " .. nPages).SetColor(colors["Royal Blue"]);
	local next = CreateButton(line).SetText("Next").SetColor(colors.Blue).SetPreferredWidth(75);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	if n == 1 then
		previous.SetOnClick(function() func(nPages) end);
	else
		previous.SetOnClick(function() func(n - 1) end);
	end
	if n == nPages then
		next.SetOnClick(function() func(1) end);
	else
		next.SetOnClick(function() func(n + 1) end);
	end
end

function inspectUnitMenu()
	DestroyWindow();
	SetWindow("inspectUnitMenu");

	inspectToolInUse = true;
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() inspectToolInUse = false; showMainMenu(); end);
	CreateLabel(root).SetText("Click a territory with a special unit to inspect it").SetColor(colors.TextColor);
	UI.InterceptNextTerritoryClick(clickedTerr);
end

function clickedTerr(terrDetails)
	if terrDetails == nil or not inspectToolInUse then return WL.CancelClickIntercept; end
	local sps = Game.LatestStanding.Territories[terrDetails.ID].NumArmies.SpecialUnits;
	if not tableIsEmpty(sps) then
		if #sps > 1 then
			pickUnitOfList(sps);
		else
			inspectUnit(sps[1], inspectUnitMenu);
		end
	else
		DestroyWindow();
		SetWindow("NoUnitFound");
		
		CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() inspectToolInUse = false; showMainMenu(); end);
		CreateLabel(root).SetText("In order to use the special unit inspector, you must select a territory with at least 1 visible special unit").SetColor(colors.TextColor);
	end
end


function pickUnitOfList(list)
	DestroyWindow();
	SetWindow("PickUnitFromList");
	
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(inspectUnitMenu);
	CreateEmpty(root).SetPreferredHeight(5);
	for _, sp in pairs(list) do
		CreateButton(root).SetText(getUnitName(sp)).SetColor(getOwnerColor(sp)).SetOnClick(function() inspectUnit(sp, function() pickUnitOfList(list); end); end)
	end
end

function inspectUnit(sp, callback)
	DestroyWindow();
	SetWindow("inspectUnit");

	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(callback);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateButton(line).SetText("Combat Order").SetColor(colors.Orange).SetOnClick(function() showCombatOrder(function() inspectUnit(sp, callback); end, sp); end);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateEmpty(root).SetPreferredHeight(5);

	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Unit type: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText(getReadableString(sp.proxyType)).SetColor(colors.Tan);
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Owner: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText(getPlayerName(sp.OwnerID)).SetColor(colors.Tan);
	if sp.proxyType == "CustomSpecialUnit" then
		inspectCustomUnit(sp);
	else
		inspectNormalUnit(sp);
	end
end

function inspectCustomUnit(sp)

	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Name: ").SetColor(colors.TextColor);
	if sp.Name ~= nil then
		CreateLabel(line).SetText(sp.Name).SetColor(colors.Tan);
	else
		CreateLabel(line).SetText("None").SetColor(colors.Tan);
	end

	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Uses health: ").SetColor(colors.TextColor);
	if sp.Health ~= nil then
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Health remaining: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText(sp.Health).SetColor(colors.Cyan);

		
	else
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Damage needed to kill: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText(sp.DamageToKill).SetColor(colors.Cyan);

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Attack damage absorbed when taking damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText(sp.DamageAbsorbedWhenAttacked).SetColor(colors.Cyan);
		
	end
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Attack damage: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText(sp.AttackPower).SetColor(colors.Cyan);

	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("defense damage: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText(sp.DefensePower).SetColor(colors.Cyan);
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Attack damage modifiers: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText(math.floor((sp.AttackPowerPercentage * 10000) + 0.5) / 100 - 100 .. "%").SetColor(colors.Cyan);

	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("defense damage modifiers: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText(math.floor((sp.DefensePowerPercentage * 10000) + 0.5) / 100 - 100 .. "%").SetColor(colors.Cyan);
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Is visible for all players: ").SetColor(colors.TextColor);
	if sp.IsVisibleToAllPlayers then
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
	else
		CreateLabel(line).SetText("No").SetColor(colors.Red);
	end
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Can be airlifted to self: ").SetColor(colors.TextColor);
	if sp.CanBeAirliftedToSelf then
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
	else
		CreateLabel(line).SetText("No").SetColor(colors.Red);
	end
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Can be airlifted to teammates: ").SetColor(colors.TextColor);
	if sp.CanBeAirliftedToTeammate then
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
	else
		CreateLabel(line).SetText("No").SetColor(colors.Red);
	end
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Can be gifted with a gift card: ").SetColor(colors.TextColor);
	if sp.CanBeGiftedWithGiftCard then
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
	else
		CreateLabel(line).SetText("No").SetColor(colors.Red);
	end
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Can be transferred to teammates: ").SetColor(colors.TextColor);
	if sp.CanBeTransferredToTeammate then
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
	else
		CreateLabel(line).SetText("No").SetColor(colors.Red);
	end
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Description: ").SetColor(colors.TextColor);
	CreateLabel(root).SetText(getUnitDescription(sp)).SetColor(colors.Tan);

end

function inspectNormalUnit(sp)
	if sp.proxyType == "Commander" then
		local line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Attack damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("7").SetColor(colors.Cyan);

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("defense damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("7").SetColor(colors.Cyan);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Takes damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be airlifted: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be airlifted to teammates: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be transferred to teammates: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be gifted: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Is visible to all players: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Special features: ").SetColor(colors.TextColor);
		CreateLabel(root).SetText("When this unit dies, " .. getPlayerName(sp.OwnerID) .. " is eliminated immediately").SetColor(colors.Tan);
	
	elseif sp.proxyType == "Boss3" then
		
		local line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Stage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText(sp.Stage .. " / 3").SetColor(colors.Cyan);

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Attack damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText(sp.Power).SetColor(colors.Cyan);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("defense damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText(sp.Power).SetColor(colors.Cyan);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Takes damage: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be airlifted: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("Yes").SetColor(colors.Green);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be airlifted to teammates: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be transferred to teammates: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Can be gifted: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);
		
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Is visible to all players: ").SetColor(colors.TextColor);
		CreateLabel(line).SetText("No").SetColor(colors.Red);

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Special features: ").SetColor(colors.TextColor);
		if sp.Stage == 3 then
			CreateLabel(root).SetText("When this unit is killed in an attack, it will NOT split into 4 smaller bosses. This unit is in it's last stage").SetColor(colors.Tan);
		else
			CreateLabel(root).SetText("When this unit is killed in an attack, it will split into 4 bosses with " .. sp.Power - 10 .. " health. These 4 bosses are randomly spawned at nearby territories, no matter who controls it. Only territories with a commander immune for this").SetColor(colors.Tan);
		end
	else
		CreateLabel(root).SetText("This unit has not been implemented yet. Please contact me and tell me the unit type so I can implement it").SetColor(colors["Orange Red"]);
	end
end

function showCombatOrder(callback, sp)
	DestroyWindow();
	SetWindow("CombatOrder");
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(callback);

	local order = {};
	for _, terr in pairs(Game.LatestStanding.Territories) do
		if not tableIsEmpty(terr.NumArmies.SpecialUnits) then
			for _, unit in pairs(terr.NumArmies.SpecialUnits) do
				if order[unit.CombatOrder] == nil then order[unit.CombatOrder] = {}; order[unit.CombatOrder].Units = {}; order[unit.CombatOrder].Positions = {}; end
				table.insert(order[unit.CombatOrder].Units, unit);
				if not valueInTable(order[unit.CombatOrder], terr.ID) then
					table.insert(order[unit.CombatOrder].Positions, terr.ID);
				end
			end
		end
	end

	local cos = {};
	local t = {};
	table.insert(t, 1, "Army");
	table.insert(cos, 1, 0);
	for co, arr in pairs(order) do
		local i = 1;
		for i2, v in pairs(cos) do
			if v > co then
				break;
			end
			i = i + 1;
		end
		table.insert(cos, i, co);
		arr.CombatOrder = co;
		table.insert(t, i, arr);
	end
	order = t;

	CreateEmpty(root).SetPreferredHeight(10);
	CreateLabel(root).SetText("This is the order in which units take damage. Note that the units listed below are only the ones visible to you, there might be units hidden by the fog").SetColor(colors.TextColor);

	local c = 2;
	for _, arr in pairs(order) do
		local line = CreateHorz(root).SetFlexibleWidth(1);
		if arr.CombatOrder == sp.CombatOrder then
			CreateLabel(line).SetText(c .. ". ").SetColor(colors.Green);
		else
			CreateLabel(line).SetText(c .. ". ").SetColor(colors.TextColor);
		end
		
		local t = {};
		for _, unit in pairs(arr.Units) do
			if not valueInTable(t, getUnitName(unit)) then
				table.insert(t, getUnitName(unit));
			end
		end
		local label = CreateLabel(line).SetText(table.concat(t, "'s, ") .. "'s");
		if arr.CombatOrder == sp.CombatOrder then
			label.SetColor(colors.Green);
		else
			label.SetColor("#EEEEEE");
		end
		CreateEmpty(line).SetFlexibleWidth(1);
		CreateButton(line).SetText("Where?").SetColor(colors.Blue).SetOnClick(function() Game.HighlightTerritories(arr.Positions) for _, terrID in pairs(arr.Positions) do Game.CreateLocatorCircle(Game.Map.Territories[terrID].MiddlePointX, Game.Map.Territories[terrID].MiddlePointY); end; end);
		
		c = c + 1;
	end
end

function showDocumentLinks()
	DestroyWindow();
	SetWindow("showDocumentLinks");

	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMainMenu);
	CreateLabel(root).SetText("In here you can find all the (document) links that the game creator wants you to have access to. You can copy the links to open them in your desired browser")

	CreateEmpty(root).SetPreferredHeight(10);

	if Mod.Settings.Links == nil then
		CreateLabel(root).SetText("There are no links").SetColor(colors.TextColor);
	else
		for _, link in pairs(Mod.Settings.Links) do
			CreateLabel(root).SetText(link.Name).SetColor(colors.TextColor);
			CreateTextInputField(root).SetText(link.Link).SetFlexibleWidth(1);
			CreateEmpty(root).SetPreferredHeight(5);
		end
	end
end

function getUnitName(sp)
	if type(sp) == type("") then return sp; end
	if sp.proxyType == "CustomSpecialUnit" then
		return sp.Name or "[No name]";
	else 
		return getReadableString(sp.proxyType);
	end
end

function getOwnerColor(sp)
	if sp.OwnerID ~= WL.PlayerID.Neutral then
		return Game.Game.Players[sp.OwnerID].Color.HtmlColor;
	else
		return colors.TextColor;
	end
end

function getPlayerName(playerID)
	if playerID ~= WL.PlayerID.Neutral then
		return Game.Game.Players[playerID].DisplayName(nil, true);
	else
		return "Neutral";
	end
end

function getUnitDescription(sp)
	if sp.ModData ~= nil then
		print("Has mod data");
		local data = stringToData(sp.ModData);
		if data["UnitDescription"] ~= nil then
			return data["UnitDescription"];
		end
		print("Has no unit description")
	end
	return "This unit does not have a description. Please read the mod description of the mod that created this unit to get to know more about it";
end

function orderFinderMain(n)
	DestroyWindow()
	SetWindow("orderFinderMain");
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Order Finder").SetColor(colors.Orange);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateEmpty(root).SetPreferredHeight(5);
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Total filters:").SetColor(colors.TextColor);
	CreateButton(line).SetText(#Filters).SetColor(colors.Blue).SetOnClick(editFilters);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetOnClick(function() UI.Alert("Add filters to narrow down the search results. To add / remove a filter, press the blue button with the number"); end).SetColor(colors.Blue);

	CreateEmpty(root).SetPreferredHeight(5)
	local orders = {};
	for i, order in pairs(Game.Orders) do
		if passesAllFilters(order) then
			table.insert(orders, order);
		end
	end
	if #orders > 0 then
		CreateLabel(root).SetText("Orders found:").SetColor(colors.TextColor);
		for i = (n-1) * 10 + 1, math.min(n * 10, #orders) do
			CreateButton(root).SetText(orders[i].proxyType).SetColor(Game.Us.Color.HtmlColor);
		end
	else
		CreateLabel(root).SetText("No orders found").SetColor(colors["Orange Red"])
	end
	
	if #orders > 10 then
		pageControlButtons(orderFinderMain, n, math.ceil(#orders / 10));
	end
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateButton(line).SetText("Return").SetOnClick(showMainMenu).SetColor(colors.Green);
	CreateEmpty(line).SetFlexibleWidth(0.5);
end

function passesAllFilters(order)
	if #Filters == 0 then
		return true;
	end
end

function editFilters()
	DestroyWindow()
	SetWindow("editFilters");
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Edit Filters").SetColor(colors["Royal Blue"]);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("Filters in effect:").SetColor(colors.TextColor);
	if #Filters == 0 then
		CreateLabel(root).SetText("None").SetColor(colors["Orange Red"]);
	else
		for i, filter in pairs(Filters) do
			CreateButton(root).SetText(i).SetColor(colors.Lime).SetOnClick(function() table.remove(Filters, i); editFilters(); end)
		end
	end
	CreateEmpty(root).SetPreferredHeight(10);
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateButton(line).SetText("Add Filter").SetColor(colors.Lime).SetOnClick(addFilter);
	CreateButton(line).SetText("Remove Filter").SetColor(colors["Orange Red"]).SetInteractable(#Filters ~= 0);
	CreateButton(line).SetText("Remove All").SetColor(colors.Red).SetInteractable(#Filters ~= 0);
	CreateButton(line).SetText("Return").SetColor(colors.Green).SetOnClick(orderFinderMain)
	CreateEmpty(line).SetFlexibleWidth(0.5);
end

function addFilter()
	if EditFilter == nil then EditFilter = {}; EditFilter.InvertFilter = false; EditFilter.OrderTypes = {}; EditFilter.Territories = {}; EditFilter.Players = {}; end
	DestroyWindow()
	SetWindow("addFilter");
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Add Filter").SetColor(colors["Royal Blue"]);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("Choose your filters").SetColor(colors.TextColor);
	line = CreateHorz(root);
	CreateLabel(line).SetText("Ordertypes: ").SetColor(colors.TextColor).SetPreferredWidth(100);
	orderButton = CreateButton(line).SetOnClick(pickOrderType);
	line = CreateHorz(root);
	CreateLabel(line).SetText("Territories: ").SetColor(colors.TextColor).SetPreferredWidth(100);
	territoryButton = CreateButton(line).SetOnClick(pickTerritory);
	line = CreateHorz(root);
	CreateLabel(line).SetText("Players: ").SetColor(colors.TextColor).SetPreferredWidth(100);
	playerButton = CreateButton(line).SetOnClick(pickPlayer);
	line = CreateHorz(root).SetFlexibleWidth(1);
	invertBox = CreateCheckBox(line).SetText(" ").SetIsChecked(EditFilter.InvertFilter);
	CreateLabel(line).SetText("Invert Filter").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When unchecked, the filter will be set to 'Must Include'. If checked, the filter will be set to 'Must Not Include'"); end)
	CreateEmpty(root).SetPreferredHeight(5);
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateButton(line).SetText("Add Filter").SetColor(colors.Blue).SetOnClick(function() table.insert(Filters, EditFilter); EditFilter = nil; editFilters(); end);
	CreateButton(line).SetText("Return").SetColor(colors.Green).SetOnClick(editFilters);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	if #EditFilter.OrderTypes == 0 then
		orderButton.SetText("Any Ordertype").SetColor(colors.Tan);
	elseif #EditFilter.OrderTypes == 1 then
		orderButton.SetText(getReadableString(EditFilter.OrderTypes[1]:sub(10, -1))).SetColor(colors.Orange);
	else
		orderButton.SetText(getReadableString(EditFilter.OrderTypes[1]:sub(10, -1)) .. " + " .. #EditFilter.OrderTypes - 1 .. " more").SetColor(colors.Orange);
	end
	if #EditFilter.Territories == 0 then
		territoryButton.SetText("Any Territory").SetColor(colors.Tan);
	else 
		local s;
		if #EditFilter.Territories[1] > 50 then
			s = EditFilter.Territories[1]:sub(1, 50) .. "...";
		else
			s = #EditFilter.Territories[1];
		end
		if #EditFilter.Territories == 1 then
			territoryButton.SetText(s).SetColor(colors.Orange);
		else
			territoryButton.SetText(s .. " + " .. #EditFilter.Territories - 1 .. " more").SetColor(colors.Orange);
		end
	end
	if #EditFilter.Players == 0 then
		playerButton.SetText("Any Player").SetColor(colors.Tan);
	else 
		local s;
		if #EditFilter.Players[1] > 50 then
			s = EditFilter.Players[1]:sub(1, 50) .. "...";
		else
			s = #EditFilter.Players[1];
		end
		if #EditFilter.Players == 1 then
			playerButton.SetText(s).SetColor(colors.Orange);
		else
			playerButton.SetText(s .. " + " .. #EditFilter.Players - 1 .. " more").SetColor(colors.Orange);
		end
	end
end

function pickOrderType()
	EditFilter.InvertFilter = invertBox.GetIsChecked();
	DestroyWindow()
	SetWindow("addFilter");
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Pick Ordertype").SetColor(colors["Royal Blue"]);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateEmpty(root).SetPreferredHeight(5);
	if invertBox.GetIsChecked() then
		CreateLabel(root).SetText("Order MUST NOT be of type:").SetColor(colors["Orange Red"]);
	else
		CreateLabel(root).SetText("Order MUST be of type:").SetColor(colors.Lime);
	end
	if #EditFilter.OrderTypes == 0 then
		CreateLabel(root).SetText("Order can be of any type").SetColor(colors.TextColor);
	else
		for i, v in pairs(EditFilter.OrderTypes) do
			CreateButton(root).SetText(getReadableString(v:sub(10, -1))).SetOnClick(function() table.remove(EditFilter.OrderTypes, i); pickOrderType(); end).SetColor(colors.Orange);
		end
	end

	CreateEmpty(root).SetPreferredHeight(10);
	CreateLabel(root).SetText("Add Ordertype").SetColor(colors.TextColor);
	for i, v in ipairs({"GameOrderDeploy", "GameOrderAttackTransfer", "GameOrderCustom"}) do
		if not valueInTable(EditFilter.OrderTypes, v) then
			CreateButton(root).SetText(getReadableString(v:sub(10, -1))).SetColor(colors.Yellow).SetOnClick(function() table.insert(EditFilter.OrderTypes, v); pickOrderType(); end);
		end
	end

	CreateEmpty(root).SetPreferredHeight(5);
	local line = CreateHorz(root);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateButton(line).SetText("Return").SetColor(colors.Green).SetOnClick(addFilter);
end

function pickTerritory()
	EditFilter.InvertFilter = invertBox.GetIsChecked();
	DestroyWindow()
	SetWindow("addFilter");
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Pick Territories").SetColor(colors["Royal Blue"]);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateEmpty(root).SetPreferredHeight(5);
	if invertBox.GetIsChecked() then
		CreateLabel(root).SetText("Order MUST NOT include territories:").SetColor(colors["Orange Red"]);
	else
		CreateLabel(root).SetText("Order MUST include territories:").SetColor(colors.Lime);
	end
	if #EditFilter.OrderTypes == 0 then
		CreateLabel(root).SetText("Order can include any territory").SetColor(colors.TextColor);
	else
		for i, v in pairs(EditFilter.OrderTypes) do
			local s;
			if #v > 50 then
				s = v:sub(1, 50) .. "...";
			else
				s = v;
			end
			CreateButton(root).SetText().SetOnClick(function() table.remove(EditFilter.OrderTypes, i); pickOrderType(); end).SetColor(colors.Orange);
		end
	end

	CreateEmpty()
end

function pickPlayer()

end

function getReadableString(s)
	local ret = string.upper(string.sub(s, 1, 1));
	for i = 2, #s do
		local c = string.sub(s, i, i);
		if c ~= string.lower(c) or tonumber(c) ~= nil then
			ret = ret .. " " .. string.lower(c);
		else
			ret = ret .. c;
		end
	end
	return ret;
end

function valueInTable(t, v)
	for _, v2 in pairs(t) do
		if v == v2 then return true; end
	end
	return false;
end

function tableIsEmpty(t)
	for _, _ in pairs(t) do
		return false;
	end
	return true;
end

-- 	Order details:
--		Territories involved
--		Players involved
--		Order type