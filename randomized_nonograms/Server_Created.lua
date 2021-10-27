
function Server_Created(game, settings)
	print("game started");
	local publicGameData = Mod.PublicGameData;
    publicGameData.nonogram, overriddenBonuses, publicGameData.Bonuses = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
	settings.OverriddenBonuses = overriddenBonuses;
	Mod.PublicGameData = publicGameData;

end

function createNonogram(width, heigth, density)
	local nonogram = {};
	print("creating nonogram")
	for i = 0, Mod.Settings.NonogramHeigth - 1 do
		local nonogram_row = {};
		for j = 0, Mod.Settings.NonogramWidth - 1 do
			if(math.random(1, 100) <= density) then
				nonogram_row[j] = 1;
			else
				nonogram_row[j] = 0;
			end
		end
		nonogram[i] = nonogram_row;
	end
	
	overriddenBonuses, territoriesInBonus = setLeftBonuses(nonogram);
	

	for i = 0, Mod.Settings.NonogramWidth - 1 do
		nonogramColumn = {};
		for j = 0, Mod.Settings.NonogramHeigth - 1 do
			nonogramColumn[Mod.Settings.NonogramHeigth - 1 - j] = nonogram[j][i]
		end
		topBonuses, territoriesInBonus = setTopBonuses(nonogramColumn, i, overriddenBonuses)
		for index, v in pairs(topBonuses) do 
			overriddenBonuses[index] = v;
		end
	end
	
	for index, value in pairs(overriddenBonuses) do
--		print(index, value)
	end
	
	return nonogram, overriddenBonuses, territoriesInBonus;
end

function setLeftBonuses(nonogram)
	local leftBonuses = {};
	local territoriesInBonus = {};
	leftBonuses[401] = 0
	for i, row in pairs(nonogram) do
		local counter = 0
		local index = 0
		local tempList = {};
		local startTerritory = i * 20 + 1;
		for j, cell in pairs(row) do
			if cell == 1 then
				counter = counter + 1;
			elseif counter ~= 0 and cell == 0 then
				tempList[index] = counter;
				index = index + 1;
				counter = 0;
				table.insert(territoriesInBonus, getTerritories(startTerritory, i * 20 + j, 1));
				startTerritory = i * 20 + j + 2;
			else
				startTerritory = i * 20 + j + 2;
			end
			print(cell, j, startTerritory);
		end
		print();
		if counter ~= 0 then
			tempList[index] = counter;
			index = index + 1;
			table.insert(territoriesInBonus, getTerritories(startTerritory, i * 20 + Mod.Settings.NonogramWidth, 1))
		end
		local bonusID = i * 10 + index;
		for _, value in pairs(tempList) do
			leftBonuses[bonusID] = value;
			bonusID = bonusID - 1;
			leftBonuses[401] = leftBonuses[401] - value;
		end
			
	end
	-- No need to keep track of the total bonus count in setTopBonuses
	leftBonuses[401] = leftBonuses[401] * 2;
	return leftBonuses, territoriesInBonus;
end

function setTopBonuses(column, columnNumber, territoriesInBonus)
	bonusColumn = {};
	counter = 0;
	bonusID = columnNumber * 10 + 201;
	territoryID = columnNumber;
	for _, value in pairs(column) do
		if value == 1 then
			counter = counter + 1;
		elseif counter ~= 0 then
			bonusColumn[bonusID] = counter;
			table.insert(territoriesInBonus, getTerritories(territoryID, territoryID + (counter * 20) - 20, 20));
			territoryID = territoryID + (counter * 20) - 20;
			counter = 0;
			bonusID = bonusID + 1;
		else
			territoryID = territoryID + 20;
		end
	end
	if counter ~= 0 then
		bonusColumn[bonusID] = counter;
		table.insert(territoriesInBonus, getTerritories(territoryID, territoryID + (counter * 20) - 20, 20));
	end
	return bonusColumn, territoriesInBonus;
end

function getTerritories(startInt, endInt, step)
	list = {};
--	print(startInt, endInt);
	for i = startInt, endInt, step do
		table.insert(list, i);
	end
	return list;
end