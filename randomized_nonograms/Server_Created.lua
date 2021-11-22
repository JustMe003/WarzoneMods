
function Server_Created(game, settings)
--	We need to store the custom bonuses somewhere, so we call the PublicGameData of the mod
	local publicGameData = Mod.PublicGameData;
--	overriddenBonuses will override the bonuses that we need to show the nonogram to the user, territoriesInBonus contains tables with the territories in a bonus
	overriddenBonuses, territoriesInBonus = createNonogram(Mod.Settings.NonogramWidth, Mod.Settings.NonogramHeigth, Mod.Settings.NonogramDensity);
	settings.OverriddenBonuses = overriddenBonuses;
	publicGameData.Bonuses = territoriesInBonus;
	Mod.PublicGameData = publicGameData;
	if Mod.Settings.CustomDistribution == true then 
		settings.AutomaticTerritoryDistribution = false;
		settings.NumberOfWastelands = 0;
		settings.WastelandSize = 0;
	end
	
	if Mod.Settings.LocalDeployments == false and settings.CommerceGame == false then
--		settings.CommerceGame, settings.CommerceArmyCostMultiplier, Settings.CommerceCityBaseCost = true, 0, 0;
	else
--		settings.Cards[WL.CardID.Reinforcement] = WL.CardGameReinforcement.Create(1, 0, 0, 0);
	end
	
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

	overrideBonuses, territoriesInBonus = {}, {};
--	Bonus 401 (with the ID 401) will cancel out all other bonuses cos they all contain the exact same territory (400)
--	If we wouldn't, the player owning territory 400 will get a bonus equal to the maximum income of all the bonuses combined
	overrideBonuses[401] = 0;
--	We use i here to calculate the bonusID, so it is important that i ranges from 0 - heigth excluding heigth itself
	for i = 0, heigth - 1 do
		length = 0;
--		The bonusID's are all in order, with on the left side of the map 20 rows of 10 bonuses (ID: 1 - 200)
--		Together with the fact that bonusID #1 is always the most right bonus, and #2 besides it and so on
--		Allows us to keep track of a variable to overwrite the correct bonus
		bonusID = (i*10) + 1;
--		Since the bonuses are from right to left, it is way easier to loop through the nonogram the same
--		Otherwise we only can assign the right bonus values to the right bonusID's after we're done looping through a rows
--		Since not all nonogram need 10 bonuses to show a row (in fact, this is the maximum count of sequences in a row / column for the size 20)
		for j = width, 1, -1 do
			if nonogramData[(i*20) + j] == 1 then
--				Update the length of the bonus
				length = length + 1;
			elseif nonogramData[(i*20) + j] == 0 and length ~= 0 then
--				We've reached the end of a bonus. Now we store the right value in the right bonusID and reset and update everything
				overrideBonuses[bonusID] = length;
				overrideBonuses[401] = overrideBonuses[401] - length
--				These 2 calculations make sure we take the right territories
				territoriesInBonus[bonusID] = getTerritories((i*20) + j + 1,(i*20) + j + length,1)
				length = 0
				bonusID = bonusID + 1
			end
		end
--		Quick check if length is not 0, if true we add the bonus and it's territories to the right variables
		if length ~= 0 then
			overrideBonuses[bonusID] = length
			overrideBonuses[401] = overrideBonuses[401] - length
			territoriesInBonus[bonusID] = getTerritories((i*20) + 1,(i*20) + length,1)
		end
	end
--	No need to keep track of the combined bonus values a second time
	overrideBonuses[401] = overrideBonuses[401] * 2
--	Now we do the same but for the top bonuses
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
--	Function to reduce code
function getTerritories(start, ending, step)
	list = {};
	for i = start, ending, step do
		table.insert(list, i);
	end
	return list;
end