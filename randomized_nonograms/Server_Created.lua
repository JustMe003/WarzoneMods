
function Server_Created(game, settings)
	local publicGameData = Mod.PublicGameData;
	overriddenBonuses, territoriesInBonus = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
	settings.OverriddenBonuses = overriddenBonuses;
	publicGameData.bonuses = territoriesInBonus;
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
	for i = 0, heigth do
		length = 0;
		bonusID = i * 20 + 1;
		for j = width, 0, -1 do
			if nonogramData[(i*20) + j] == 1 then
				length = length + 1;
			elseif nonogramData[(i*20) + j] == 0 and length ~= 0 then
				overrideBonuses[bonusID] = length;
				territoriesInBonus[bonusID] = getTerritories((i*20) + j - length,(i*20) + j - 1,1)
				length = 0
				bonusID = bonusID + 1
			end
		end
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			territoriesInBonus[bonusID] = getTerritories((i*20) + 1,(i*20) + length,1)
	end
	for i = 0, width do
		length = 0
		bonusID = (i*20) + 201
		for j = heigth - 1, -1, -1 do
			if nonogramData[(j*20) + i] == 1 then
				length = length + 1;
			elseif nonogramData[(j*20) + i] == 0 and length ~= 0 then
				overrideBonuses[bonusID] = length
				territoriesInBonus[bonusID] = getTerritories((j*20) + i - (length * 20), (j*20) + i - 20, 20)
				length = 0
				bonusID = bonusID + 1
			end
		end
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			territoriesInBonus[bonusID] = getTerritories((j*20) + 20, (j*20) , 20)
		end
	end
	return overrideBonuses, territoriesInBonus;
end

function getTerritories(start, ending, step)
	list = {};
	for i = start, ending + 1, step do
		table.insert(list, i);
		print(i);
	end
	return list;
end