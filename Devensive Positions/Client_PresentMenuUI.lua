function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher("5.17")) then
		UI.Alert("You must update your app to the latest version to use the Build Fort mod");
		return;
	end

	Game = game;
	Close = close;
	
	setMaxSize(350, 350);

	vert = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1); --set flexible width so things don't jump around while we change InstructionLabel

	local numDevpos;
	if (Mod.PlayerGameData.NumDevpos == nil) then
		numDevpos = 0;
	else
		numDevpos = Mod.PlayerGameData.NumDevpos;
	end

	UI.CreateLabel(vert).SetText("You will earn a devensive position every " .. Mod.Settings.TurnsToGetDevPos .. " turns.");
	UI.CreateLabel(vert).SetText("Devensive positions you can place now: " .. numDevpos);
	UI.CreateLabel(vert).SetText("Note that devensive positiongs get built at the end of your turn, so use caution when building on a territory you may lose control of.");

	SelectTerritoryBtn = UI.CreateButton(vert).SetText("Select Territory").SetOnClick(SelectTerritoryClicked);
	SelectTerritoryBtn.SetInteractable(numDevpos > 0);
	TargetTerritoryInstructionLabel = UI.CreateLabel(vert).SetText("");

	BuildFortBtn = UI.CreateButton(vert).SetText("Build devensive position").SetOnClick(BuildFortClicked).SetInteractable(false);

end

function SelectTerritoryClicked()
	UI.InterceptNextTerritoryClick(TerritoryClicked);
	TargetTerritoryInstructionLabel.SetText("Please click on the territory you wish to build the devensive position on.  If needed, you can move this dialog out of the way.");
	SelectTerritoryBtn.SetInteractable(false);
end

function TerritoryClicked(terrDetails)
	SelectTerritoryBtn.SetInteractable(true);

	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		TargetTerritoryInstructionLabel.SetText("");
		SelectedTerritory = nil;
		BuildFortBtn.SetInteractable(false);
	else
		--Territory was clicked, remember it
		TargetTerritoryInstructionLabel.SetText("Selected territory: " .. terrDetails.Name);
		SelectedTerritory = terrDetails;
		BuildFortBtn.SetInteractable(true);
	end
end

function BuildFortClicked()
	local msg = 'Build a devensive position on ' .. SelectedTerritory.Name;
	local payload = 'buildDevPos_' .. SelectedTerritory.ID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;

	Close();
end