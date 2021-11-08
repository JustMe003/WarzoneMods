
function Server_Created(game, settings)
--	We need to store the custom bonuses somewhere, so we call the PublicGameData of the mod
	local publicGameData = Mod.PublicGameData;
--	overriddenBonuses will override the bonuses that we need to show the nonogram to the user, territoriesInBonus contains tables with the territories in a bonus
	overriddenBonuses, territoriesInBonus = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
	settings.OverriddenBonuses = overriddenBonuses;
	publicGameData.Bonuses = territoriesInBonus;
	Mod.PublicGameData = publicGameData;

end

function createNonogram(width, heigth, density)
--	In here the nonogram gets created
	nonogramData = {};
	for i = 0, heigth - 1 do
		for j = 0, width - 1 do
			if math.random(100) < density then
				nonogramData[(i*20) + j + 1] = 1;
			else
				nonogramData[(i*20) + j + 1] = 0;
			end
		end
	end
--	So far creating the process of creating the data values of the nonogram, now we need to use it to set the rigth bonuses to their corresponding number
	overrideBonuses, territoriesInBonus = {}, {};
--	Bonus 401 (with the ID 401) will cancel out all other bonuses cos they all contain the exact same territory (400)
--	If we wouldn't, the player owning territory 400 will get a bonus equal to the maximum income of all the bonuses combined
	overrideBonuses[401] = 0;
	for i = 0, heigth - 1 do
		length = 0;
		bonusID = (i*10) + 1;
		for j = width, 1, -1 do
			if nonogramData[(i*20) + j] == 1 then
				length = length + 1;
			elseif nonogramData[(i*20) + j] == 0 and length ~= 0 then
				overrideBonuses[bonusID] = length;
				overrideBonuses[401] = overrideBonuses[401] - length
				territoriesInBonus[bonusID] = getTerritories((i*20) + j + 1,(i*20) + j + length,1)
				length = 0
				bonusID = bonusID + 1
			end
		end
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			overrideBonuses[401] = overrideBonuses[401] - length
			territoriesInBonus[bonusID] = getTerritories((i*20) + 1,(i*20) + length,1)
		end
	end
	overrideBonuses[401] = overrideBonuses[401] * 2
	for i = 1, width do
		length = 0
		bonusID = ((i-1)*10) + 201
		for j = heigth - 1, 0, -1 do
			if nonogramData[(j*20) + i] == 1 then
				length = length + 1;
			elseif nonogramData[(j*20) + i] == 0 and length ~= 0 then
				overrideBonuses[bonusID] = length
				territoriesInBonus[bonusID] = getTerritories((j*20) + i + 20, (j*20) + i + ((length)*20), 20)
				length = 0
				bonusID = bonusID + 1
			end
		end
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			territoriesInBonus[bonusID] = getTerritories(i, i + ((length-1)*20), 20)
		end
	end
	return overrideBonuses, territoriesInBonus;
end

function getTerritories(start, ending, step)
	list = {};
	for i = start, ending, step do
		table.insert(list, i);
	end
	return list;
end