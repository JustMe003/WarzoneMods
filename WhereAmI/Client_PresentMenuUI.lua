require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
	colors = GetColors();
	setMaxSize(400, 500);
    Game = game;
	sortingMethods = {
						ByName = (function(a, b) return b.Data.Name > a.Data.Name end), 
						ByArmies = (function(a, b) return (#b.Standing.NumArmies.SpecialUnits * 1000000 + b.Standing.NumArmies.NumArmies) < (#a.Standing.NumArmies.SpecialUnits * 1000000 + a.Standing.NumArmies.NumArmies); end),
						ByLocation = (function(a, b) return (b.Data.MiddlePointX^2 * b.Data.MiddlePointY^2) > (a.Data.MiddlePointX^2 * a.Data.MiddlePointY^2); end)
					}
	currentSort = sortingMethods.ByName;
    showMenu();
end

function showMenu()
	if Game.Us == nil then UI.Alert("You are not in the game"); return; end
	
	if playerTerritories == nil or turnNumber ~= Game.Game.TurnNumber then
		turnNumber = Game.Game.TurnNumber;
		territoriesOfPlayer = Game.Us;
		getTerritories();
	end

	showNthPage(1)
end

function showNthPage(n)
	DestroyWindow();
	SetWindow("showTerritories");
	
	local title = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(title).SetText("Where am I?").SetColor(colors.Orange);
	CreateEmpty(title).SetFlexibleWidth(1);
	CreateButton(title).SetText(territoriesOfPlayer.DisplayName(nil, true)).SetColor(colors.Blue).SetOnClick(selectPlayer);
	CreateButton(title).SetText("Sort").SetColor(colors.Green).SetOnClick(selectSorting);

	for i = 1, math.min(10, #playerTerritories - (10 * (n - 1))) do
		local terr = playerTerritories[10 * (n - 1) + i];
		local line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText(terr.Data.Name).SetColor(colors.TextColor);
		CreateEmpty(line).SetFlexibleWidth(1);
		CreateButton(line).SetText("Where?").SetColor(colors.Blue).SetOnClick(function() Game.HighlightTerritories({terr.ID}); Game.CreateLocatorCircle(terr.Data.MiddlePointX, terr.Data.MiddlePointY); end);
	end

	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.45);
	CreateButton(line).SetText("<").SetColor(colors.Cyan).SetOnClick(function() showNthPage(n - 1); end).SetInteractable(n > 1);
	CreateEmpty(line).SetFlexibleWidth(0.05);
	CreateLabel(line).SetText(n .. " / " .. math.ceil(#playerTerritories / 10)).SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(0.05);
	CreateButton(line).SetText(">").SetColor(colors.Cyan).SetOnClick(function() showNthPage(n + 1); end).SetInteractable(#playerTerritories > n * 10);
	CreateEmpty(line).SetFlexibleWidth(0.45);
end

function selectPlayer()
	DestroyWindow();
	SetWindow("SelectPlayer");

	CreateLabel(root).SetText("Select a player").SetColor(colors.TextColor);
	for _, p in pairs(Game.Game.PlayingPlayers) do
		CreateButton(root).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function() territoriesOfPlayer = p; getTerritories(); showNthPage(1); end);
	end
	
end

function selectSorting()
	DestroyWindow();
	SetWindow("SelectSorting");

	CreateLabel(root).SetText("Select your sorting method").SetColor(colors.TextColor);
	CreateEmpty(root).SetPreferredHeight(10);

	-- Sort by territory name
	local line = CreateHorz(root).SetFlexibleWidth(1);
	local vert = CreateVert(root);
	CreateButton(line).SetText("By name").SetColor(colors.Green).SetOnClick(function() sortTerritories(sortingMethods.ByName); end);
	CreateEmpty(line).SetFlexibleWidth(1);
	local button = CreateButton(line).SetText("?").SetColor(colors.Blue);
	button.SetOnClick(function() if button.GetText() == "?" then newSubWindow("ByName", showTextByName(vert)); button.SetText("^"); else DestroyWindow("ByName"); button.SetText("?") end; end);
	
	-- Sort by army count (priority given to special units)
	line = CreateHorz(root).SetFlexibleWidth(1);
	vert = CreateVert(root);
	CreateButton(line).SetText("By armies").SetColor(colors.Lime).SetOnClick(function() sortTerritories(sortingMethods.ByArmies); end);
	CreateEmpty(line).SetFlexibleWidth(1);
	button = CreateButton(line).SetText("?").SetColor(colors.Blue);
	button.SetOnClick(function() if button.GetText() == "?" then newSubWindow("ByArmies", showTextByArmies(vert)); button.SetText("^"); else DestroyWindow("ByArmies"); button.SetText("?") end; end);
	
	-- Sort by territory location, relative to (0,0)
	line = CreateHorz(root).SetFlexibleWidth(1);
	vert = CreateVert(root);
	CreateButton(line).SetText("By location").SetColor(colors["Army Green"]).SetOnClick(function() sortTerritories(sortingMethods.ByLocation); end);
	CreateEmpty(line).SetFlexibleWidth(1);
	button = CreateButton(line).SetText("?").SetColor(colors.Blue);
	button.SetOnClick(function() if button.GetText() == "?" then newSubWindow("ByLocation", showTextByLocation(vert)); button.SetText("^"); else DestroyWindow("ByLocation"); button.SetText("?") end; end);
end

function newSubWindow(name, func)
	local main = GetCurrentWindow();
	AddSubWindow(main, name);
	SetWindow(name);

	func();

	SetWindow(main);
end

function showTextByName(vert)
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetPreferredWidth(20);
	CreateLabel(line).SetText("This option will sort all territories by name alphabetically.").SetColor(colors.TextColor);
end

function showTextByArmies(vert)
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetPreferredWidth(20);
	CreateLabel(line).SetText("This option will sort all territories by the number of armies, with the highest first. Territories with special units will always get priority.").SetColor(colors.TextColor);
end

function showTextByLocation(vert)
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetPreferredWidth(20);
	CreateLabel(line).SetText("This option will sort all territories by their location, the closer a territory is to the top left of the map, the higher priority it will get. Note that the \"location\" of a territory is only determined by the middle point of it.").SetColor(colors.TextColor);
end

function sortTerritories(func)
	currentSort = func;
	table.sort(playerTerritories, currentSort); 
	showNthPage(1);
end

function getTerritories()
	playerTerritories = {};
		
	for terrID, terr in pairs(Game.LatestStanding.Territories) do
		if terr.OwnerPlayerID == territoriesOfPlayer.ID then
			table.insert(playerTerritories, {ID = terrID, Data = Game.Map.Territories[terrID], Standing = Game.LatestStanding.Territories[terrID]});
		end
	end
	table.sort(playerTerritories, currentSort);
end