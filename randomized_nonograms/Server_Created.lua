
function Server_Created(game, settings)
	print("game started");
	local publicGameData = Mod.PublicGameData;
    publicGameData.nonogram = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
    local overriddenBonuses = setLeftBonuses(publicGameData.nonogram)
--	table.insert(overriddenBonuses, setTopBonuses(publicGameData.nonogram));
	local test = setTopBonuses(nonogram);
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
	for i, row in pairs(nonogram) do
		local counter = 0
		local bonusID = i * 10 + 1;
		for j, cell in pairs(row) do
			if cell == 1 then
				counter = counter + 1;
			elseif counter ~= 0 then
				leftBonuses[bonusID] = counter
				print(bonusID .. ": " .. leftBonuses[bonusID])
				bonusID = bonusID + 1;
				counter = 0
			end
		if counter ~= 0 then
			leftBonuses[bonusID] = counter;
		end
		end
	end
	return leftBonuses;
end

function setTopBonuses(nonogram)
	nonogram = unpack(nonogram);
	print(nonogram[1]);
	return nil;
end