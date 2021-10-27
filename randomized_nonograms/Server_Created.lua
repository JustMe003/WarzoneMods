
function Server_Created(game, settings)
	local publicGameData = Mod.PublicGameData;
	overriddenBonuses, territoriesInBonus = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
	settings.OverriddenBonuses = overriddenBonuses;
	publicGameData.Bonuses = territoriesInBonus;
	Mod.PublicGameData = publicGameData;

end

function createNonogram(width, heigth, density)
	nonogramData = {};
	for i = 0, heigth do
		for j = 0, width do
			if math.random(100) < density then
				nonogramData[(i*20) + j + 1] = 1;
			else
				nonogramData[(i*20) + j + 1] = 0;
			end
		end
	end
	overrideBonuses, territoriesInBonus = {}, {};
	for i = 0, heigth - 1 do
		length = 0;
		bonusID = (i*10) + 1;
		for j = width, 1, -1 do
			if nonogramData[(i*20) + j] == 1 then
				length = length + 1;
			elseif nonogramData[(i*20) + j] == 0 and length ~= 0 then
				overrideBonuses[bonusID] = length;
				territoriesInBonus[bonusID] = getTerritories((i*20) + j - length + 1,(i*20) + j,1)
				length = 0
				bonusID = bonusID + 1
			end
			--print(nonogramData[(i*20) + j], i, j)
		end
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			territoriesInBonus[bonusID] = getTerritories((i*20) + 1,(i*20) + length,1)
		end
	end
	for i = 1, width do
		length = 0
		bonusID = ((i-1)*10) + 201
		for j = heigth - 1, 0, -1 do
			if nonogramData[(j*20) + i] == 1 then
				length = length + 1;
			elseif nonogramData[(j*20) + i] == 0 and length ~= 0 then
				overrideBonuses[bonusID] = length
				territoriesInBonus[bonusID] = getTerritories((j*20) + i - (length * 20), (j*20) + i + 20, 20)
				length = 0
				bonusID = bonusID + 1
			end
			print(nonogramData[(j*20) + i], i, j, (j*20) + i, (j*20) + i - (length * 20), (j*20) + i - 20)
		end
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			territoriesInBonus[bonusID] = getTerritories(i, i + ((length-1)*20), 20)
			print(i, i + ((length-1)*20));
		end
	end
	return overrideBonuses, territoriesInBonus;
end

function getTerritories(start, ending, step)
	list = {};
	for i = start, ending + 1, step do
		table.insert(list, i);
	end
	return list;
end