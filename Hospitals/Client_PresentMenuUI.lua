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
				line = UI.CreateHorizontalLayoutGroup(vert);
				table.insert(UIObjects, line)
				table.insert(UIObjects, UI.CreateButton(line).SetText("show territories").SetColor("#00FF05").SetOnClick(showRecoverTable));
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

function showRecoverTable(hospital)
	destroyAll();
	if Mod.Settings.upgradeSystem then
		local line = UI.CreateHorizontalLayoutGroup(vert);
		table.insert(UIObjects, line);
		local vertical = UI.CreateVerticalLayoutGroup(line);
		table.insert(UIObjects, vertical);
		table.insert(UIObjects, UI.CreateLabel(vertical).SetText("Level").SetColor("#CCCCCC"))
		for i = 1, Mod.Settings.maximumHospitalRange do
			vertical = UI.CreateVerticalLayoutGroup(line);
			table.insert(UIObjects, vertical);
			table.insert(UIObjects, UI.CreateLabel(vertical).SetText(i).SetColor("#3333CC"))
		end
		for i, v in pairs(hospital.Territories) do
			local line = UI.CreateHorizontalLayoutGroup(vert);
			table.insert(UIObjects, line);
			for j = 1, Mod.Settings.maximumHospitalRange do
				vertical = UI.CreateVerticalLayoutGroup(line);
				table.insert(UIObjects, vertical);
				table.insert(UIObjects, UI.CreateLabel(vertical).SetText(getValue(v - hospital.Level + j + 1)).SetColor("#0000CC"))
			end
			
		end
	else
		for i, v in pairs(hospital.Territories) do
			local line = UI.CreateHorizontalLayoutGroup(vert);
			table.insert(UIObjects, line);
			table.insert(UIObjects, UI.CreateLabel(line).SetText(game.Map.Territories[i].Name .. ": ").SetColor("#DDDDDD"))
			table.insert(UIObjects, UI.CreateLabel(line).SetText(Mod.PublicGameData.Values[v] .. "%").SetColor("#0000DD"))
		end
	end
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
	if Mod.PublicGameData.Values[index] ~= nil then return Mod.PublicGameData.Values[index]; end
	return 0;
end