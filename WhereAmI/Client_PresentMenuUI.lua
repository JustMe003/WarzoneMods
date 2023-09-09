require("UI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init(rootParent);
    root = GetRoot();
	colors = GetColors();
    Game = game;
    showMenu();
end

function showMenu()
	CreateLabel(root).SetText("Where am I?").SetColor(colors.Orange);

	if Game.Us == nil then return; end
	for terrID, terr in pairs(Game.LatestStanding.Territories) do
		if terr.OwnerPlayerID == Game.Us.ID then
			local line = CreateHorz(root).SetFlexibleWidth(1);
			CreateLabel(line).SetText(Game.Map.Territories[terrID].Name).SetText(colors.TextColor);
			CreateEmpty(line).SetFlexibleWidth(1);
			CreateButton(line).SetText("Where?").SetColor(colors.Blue).SetOnClick(function() Game.HighlightTerritories({terrID}); Game.CreateLocatorCircle(Game.Map.Territories[terrID].MiddlePointX, Game.Map.Territories[terrID].MiddlePointY); end)
		end
	end
end