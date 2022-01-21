function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	game = Game;
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	UIObjects = {};
	
	
	showMenu();
end

function showMenu()
	destroyAll();
	
	local goToTerritoryInformation = UI.CreateButton(vert).SetText("Advanced territory information").SetColor("#00FF00").SetOnClick(getTerritory);
	table.insert(UIObjects, goToTerritoryInformation);
end
function getTerritory()
	destroyAll();
	local label = UI.CreateLabel(vert).SetText("Click a territory").SetColor("#00FF00");
	table.insert(UIObjects, label);
	UI.InterceptNextTerritoryClick(showTerritoryInformation)
end

function showTerritoryInformation(terrDetails)
	if terrDetails == nil then return; end
	destroyAll();
	local line = UI.CreateHorizontalLayoutGroup(vert);
	table.insert(UIObjects, line)
	table.insert(UIObjects, UI.CreateLabel(line).SetText("Territory name: ").SetColor("#CCCCCC"))
	table.insert(UIObjects, UI.CreateLabel(line).SetText(terrDetails.Name).SetColor("#DDDDDD"))
	if game.LatestStanding.Territories[terrDetails.ID].FogLevel < 4 then
		line = UI.CreateHorizontalLayoutGroup(vert);
		table.insert(UIObjects, line)
		if game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID ~= WL.PlayerID.Neutral then
			table.insert(UIObjects, UI.CreateLabel(line).SetText("Territory Owner: ").SetColor("#CCCCCC"))
			table.insert(UIObjects, UI.CreateLabel(line).SetText(game.Game.Players[game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID].DisplayName(nil, false)).SetColor(game.Game.Players[game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID].Color.HtmlColor))
		else
			table.insert(UIObjects, UI.CreateLabel(line).SetText("Territory Owner: ").SetColor("#CCCCCC"))
			table.insert(UIObjects, UI.CreateLabel(line).SetText("Neutral").SetColor("#DDDDDD"))
		end
		if game.LatestStanding.Territories[terrDetails.ID].Structures ~= nil and game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID ~= WL.PlayerID.Neutral then
			if game.LatestStanding.Territories[terrDetails.ID].Structures[WL.StructureType.Hospital] ~= nil then
				hospital = terrDetails.ID;
				line = UI.CreateHorizontalLayoutGroup(vert);
				table.insert(UIObjects, line)
				table.insert(UIObjects, UI.CreateButton(line).SetText("show territories").SetColor("#00FF05").SetOnClick(function() UI.InterceptNextTerritoryClick(showRecoveryRate); end));
				line = UI.CreateHorizontalLayoutGroup(vert);
				table.insert(UIObjects, line)
				table.insert(UIObjects, UI.CreateLabel(line).SetText("Structure: ").SetColor("#CCCCCC"))
				table.insert(UIObjects, UI.CreateLabel(line).SetText("Hospital").SetColor("#DDDDDD"))
				line = UI.CreateHorizontalLayoutGroup(vert);
				table.insert(UIObjects, line)
				table.insert(UIObjects, UI.CreateLabel(line).SetText("Territories in range: ").SetColor("#CCCCCC"))
				table.insert(UIObjects, UI.CreateLabel(line).SetText(territoriesInRange(Mod.PublicGameData.Hospitals[terrDetails.ID].Territories)).SetColor("#0000CC"))
				if Mod.Settings.upgradeSystem then
					line = UI.CreateHorizontalLayoutGroup(vert);
					table.insert(UIObjects, line)
					table.insert(UIObjects, UI.CreateLabel(line).SetText("Hospital Level: ").SetColor("#CCCCCC"))
					table.insert(UIObjects, UI.CreateLabel(line).SetText(Mod.PublicGameData.Hospitals[terrDetails.ID].Level).SetColor("#0000CC"))
					line = UI.CreateHorizontalLayoutGroup(vert);
					table.insert(UIObjects, line)
					table.insert(UIObjects, UI.CreateLabel(line).SetText("Hospital level progress: ").SetColor("#CCCCCC"))
					table.insert(UIObjects, UI.CreateLabel(line).SetText(Mod.PublicGameData.Hospitals[terrDetails.ID].Progress).SetColor("#0000CC"))
				end
			end
		end
	end
	table.insert(UIObjects, UI.CreateButton(vert).SetText("return").SetColor("#0000FF").SetOnClick(getTerritory));
end

function showRecoveryRate(terrDetails)
	destroyAll();
	local line = UI.CreateHorizontalLayoutGroup(vert);
	table.insert(UIObjects, line);
	table.insert(UIObjects, UI.CreateLabel(line).SetText("hospital at ").SetColor("#CCCCCC"));
	table.insert(UIObjects, UI.CreateLabel(line).SetText(game.Map.Territories[hospital].Name).SetColor("#00FF05"));
	table.insert(UIObjects, UI.CreateLabel(line).SetText(" will recover ").SetColor("#CCCCCC"));
	table.insert(UIObjects, UI.CreateLabel(line).SetText(getValue(Mod.PublicGameData.Hospitals[hospital].Territories[terrDetails.ID]) .. "%").SetColor("#0000FF"));
	table.insert(UIObjects, UI.CreateLabel(line).SetText(" armies when it defends against an attack or attacks another territory").SetColor("#CCCCCC"));
end


function destroyAll()
	for _, v in pairs(UIObjects) do
		UI.Destroy(v);
	end
	UIObjects = {}
end

function territoriesInRange(listOfTerr)
	local int = 0;
	for i, v in pairs(listOfTerr) do
		if v > 0 then
			int = int + 1;
		end
	end
	return int;
end

function getValue(index)
	if index == nil return 0; end
	if Mod.PublicGameData.Values[index] ~= nil then return Mod.PublicGameData.Values[index]; end
	return 0;
end