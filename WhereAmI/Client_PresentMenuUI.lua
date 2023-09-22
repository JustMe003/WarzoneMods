require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init(rootParent);
    root = GetRoot();
	colors = GetColors();
    Game = game;
    showMenu();
end

function showMenu()
	if Game.Us == nil then UI.Alert("You are not in the game"); return; end
	CreateLabel(root).SetText("Where am I?").SetColor(colors.Orange);

	if playerTerritories == nil then
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
	CreateButton(line).SetText(">").SetColor(colors.Cyan).SetOnClick(function() showNthPage(n + 1); end).SetInteractable(#playerTerritories / 10 < n);
	CreateEmpty(line).SetFlexibleWidth(0.45);
end