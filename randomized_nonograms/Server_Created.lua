
function Server_Created(game, settings)
	print("game started");
	local publicGameData = Mod.PublicGameData;
    publicGameData.nonogram = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
    local overriddenBonuses = setLeftBonuses(publicGameData.nonogram)
	topBonuses = setTopBonuses(publicGameData.nonogram);
	settings.OverriddenBonuses = overriddenBonuses;

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
	return nonogram;
end

function setLeftBonuses(nonogram)
	local leftBonuses = {};
	leftBonuses[401] = 0
	for i, row in pairs(nonogram) do
		local counter = 0
		local index = 0
		local tempList = {};
		for j, cell in pairs(row) do
			if cell == 1 then
				counter = counter + 1;
			elseif counter ~= 0 and cell == 0 then
				tempList[index] = counter;
				index = index + 1;
				counter = 0;
			end
		end
		if counter ~= 0 then
			tempList[index] = counter;
			index = index + 1;
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
	return leftBonuses;
end

function setTopBonuses(nonogram)
	nonogram1 = table.unpack(nonogram);
	nonogram2 = table.unpack(nonogram1);
	print(nonogram2);
	local topBonuses = {};
	for i, row in pairs(nonogram) do
		local counter = 0
		local bonusID = i * 10 + 201;
		for j, cell in pairs(row) do
		end
	end
	return nil;
end


