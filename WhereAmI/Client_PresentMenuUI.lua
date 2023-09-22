require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
	colors = GetColors();
	setMaxSize(500, 400);
    Game = game;
    showMenu();
end

function showMenu()
	if Game.Us == nil then UI.Alert("You are not in the game"); return; end
	
	if playerTerritories == nil or turnNumber ~= Game.Game.TurnNumber then
		turnNumber = Game.Game.TurnNumber;
		playerTerritories = {};
		
		for terrID, terr in pairs(Game.LatestStanding.Territories) do
			if terr.OwnerPlayerID == Game.Us.ID then
				table.insert(playerTerritories, {ID = terrID, Data = Game.Map.Territories[terrID], Standing = Game.LatestStanding.Territories[terrID]});
			end
		end
	end

	showNthPage(1)
end

function showNthPage(n)
	DestroyWindow();
	SetWindow("showTerritories");
	
	local title = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(title).SetText("Where am I?").SetColor(colors.Orange);
	CreateEmpty(title).SetFlexibleWidth(1);
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
	CreateEmpty(line).SetFlexibleWidth(0.1);
	CreateButton(line).SetText(">").SetColor(colors.Cyan).SetOnClick(function() showNthPage(n + 1); end).SetInteractable(#playerTerritories > n * 10);
	CreateEmpty(line).SetFlexibleWidth(0.45);
end

function selectSorting()
	DestroyWindow();
	SetWindow("SelectSorting");

	CreateLabel(root).SetText("Select your sorting method").SetColor(colors.TextColor);
	CreateEmpty(root).SetPreferredHeight(10);

	CreateButton(root).SetText("By name").SetColor(colors.Green).SetOnClick(function() quickSort(playerTerritories, 1, #playerTerritories, function(a, b) return b.Data.Name > a.Data.Name end); showNthPage(1); end)
end

function quickSort(arr, left, right, func)
    if left >= right then return; end
    local mid = left + math.floor((right - left) / 2);
    swap(arr, right, mid);
    local pivot = arr[right];
    local i = left;
    local j = left;
    while j <= right do
        if func(arr[j], pivot) then
            swap(arr, i, j);
            i = i + 1;
        end
        j = j + 1;
    end
    swap(arr, right, i);
    quickSort(arr, left, mid);
    quickSort(arr, mid + 1, right);
end

function swap(arr, x, y)
    local z = arr[x];
    arr[x] = arr[y];
    arr[y] = z;
end
