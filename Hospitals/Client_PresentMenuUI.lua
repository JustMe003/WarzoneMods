function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	game = Game;
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	UIObjects = {};
	
	
	showMenu();
end

function showMenu()
	destroyAll();
	
	local goToTerritoryInformation = UI.CreateButton(vert).SetText("Advanced territory information").SetColor("#00FF05").SetOnClick(getTerritory);
	table.insert(UIObjects, goToTerritoryInformation);
	local goToHospitalInformation = UI.CreateButton(vert).SetText("Hospital information").SetColor("#0000FF").SetOnClick(getHospital);
	table.insert(UIObjects, goToHospitalInformation);
end

function getHospital()
	destroyAll();
	local label = UI.CreateLabel(vert).SetText("Click a territory").SetColor("#00FF00");
	table.insert(UIObjects, label);
	UI.InterceptNextTerritoryClick(showHospitalInformation);
end

function getTerritory()
	destroyAll();
	local label = UI.CreateLabel(vert).SetText("Click a territory").SetColor("#00FF00");
	table.insert(UIObjects, label);
	UI.InterceptNextTerritoryClick(showTerritoryInformation);
end

function showTerritoryInformation(terrDetails)
	if terrDetails == nil then return; end
	destroyAll();
	local line = UI.CreateHorizontalLayoutGroup(vert);
	table.insert(UIObjects, line);
	table.insert(UIObjects, UI.CreateLabel(line).SetText("Territory name: ").SetColor("#CCCCCC"))
	table.insert(UIObjects, UI.CreateLabel(line).SetText(terrDetails.Name).SetColor("#DDDDDD"))
	if game.LatestStanding.Territories[terrDetails.ID].FogLevel < 4 then
		for hosID, hospital in pairs(Mod.PublicGameData.Hospitals) do
			if game.LatestStanding.Territories[hosID].FogLevel < 4 then
				if getValue(hospital.Territories[terrDetails.ID]) > 0 then
					local line = UI.CreateHorizontalLayoutGroup(vert);
					table.insert(UIObjects, line);
					table.insert(UIObjects, UI.CreateLabel(line).SetText(game.Map.Territories[hosID].Name .. ": ").SetColor(game.Game.Players[game.LatestStanding.Territories[terrDetails.ID].OwnerPlayerID].Color.HtmlColor));
					table.insert(UIObjects, UI.CreateLabel(line).SetText(getValue(hospital.Territories[terrDetails.ID]) .. "%").SetColor("#0000FF"));
					table.insert(UIObjects, UI.CreateButton(line).SetText("?").SetColor("#00FF05").SetOnClick(function() UI.Alert("The hospital at " .. game.Map.Territories[hosID].Name .. " will recover " .. getValue(hospital.Territories[terrDetails.ID]) .. "% of the lost armies"); end));
				end
			end
		end
	end
	table.insert(UIObjects, UI.CreateButton(vert).SetText("return").SetColor("#0000FF").SetOnClick(showMenu));
end

function showHospitalInformation(terrDetails)
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
				for i, v in pairs(Mod.PublicGameData.Hospitals[terrDetails.ID].Territories) do print(i, v); end
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
					table.insert(UIObjects, UI.CreateLabel(line).SetText(Mod.PublicGameData.Hospitals[terrDetails.ID].Progress .. " / " .. math.pow(Mod.Settings.amountOfLevels, Mod.PublicGameData.Hospitals[terrDetails.ID].Level)).SetColor("#0000CC"))
				end
			end
		end
	end
	table.insert(UIObjects, UI.CreateButton(vert).SetText("return").SetColor("#0000FF").SetOnClick(showMenu));
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
	if index == nil then return 0; end
	if Mod.PublicGameData.Values[index] ~= nil then return Mod.PublicGameData.Values[index]; end
	return 0;
end