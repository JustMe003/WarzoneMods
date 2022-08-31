function distributeStructure(game, standing, amountOfStructures, structure)
	local listOfTerr = getList(standing.Territories, function(terr) return terr.OwnerPlayerID == WL.PlayerID.Neutral end)
	
	amountOfStructures = math.min(amountOfStructures, math.floor(#listOfTerr / 4)) -- Make sure to never have more than 1 / 4 of the map covered with a certain structure type

	for i = 1, amountOfStructures do
		local rand = math.random(#listOfTerr);
		local structures = standing.Territories[listOfTerr[rand]].Structures;
		if structures == nil then 
			structures = {}; 
			structures[structure] = 1;
		else
			if structures[structure] == nil then
				structures[structure] = 1;
			else
				structures[structure] = structures[structure] + 1;
			end
		end
		standing.Territories[listOfTerr[rand]].Structures = structures;
		table.remove(listOfTerr, rand)
	end
	return structure;
end


function distributeStructuresOnePerTerr(game, standing, structuresTable);			-- key = WL.StructureType.ID		value = amount of structures to be distributed
	local listOfTerr = getList(standing.Territories, function(terr) return terr.OwnerPlayerID == WL.PlayerID.Neutral and terr.Structures == nil end);
	
	local amountOfStructures = 0;
	for _, v in pairs(structuresTable) do amountOfStructures = amountOfStructures + v; end
	
	local overflow = math.min(math.floor(#listOfTerr / 4) / amountOfStructures, 1);
	
	for i, v in pairs(structuresTable) do
		for j = 1, math.min(math.max(math.floor(v * overflow), 1), #listOfTerr) do
			local rand = math.random(#listOfTerr);
			local structure = {};
			structure[i] = 1;
			standing.Territories[listOfTerr[rand]].Structures = structure;
			table.remove(listOfTerr, rand);
		end
	end
end


function getList(list, func)
	local array = {};
	for i, v in pairs(list) do
		if func(v) then
			table.insert(array, i);
		end
	end
	return array;
end