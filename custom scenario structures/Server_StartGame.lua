function Server_StartGame(game, standing)
	if not game.Settings.AutomaticTerritoryDistribution then return; end
	if game.Settings.CustomScenario == nil then return; end
	local s = Mod.Settings.Data;
	if string.len(s) == 0 then return; end
	local startID = string.find(s, "%[");
	if startID ~= nil then
		startID = startID + 1;
	else
		return;
	end
	local endID = string.find(s, "%]");
	if endID ~= nil then
		endID = endID - 1;
	else
		return;
	end
	local mapID = tonumber(string.sub(s, startID, endID));
	if mapID ~= nil then
		print("valid ID")
	else
		return;
	end
	print(mapID);
	if game.Map.ID == mapID then
		print(game.Map.ID, mapID, game.Map.ID == mapID);
	else
		return;
	end
	
	s = string.sub(s, endID + 3, string.len(s))
	print(s);
	failSafe = 0
	local t = getTable(s);
	
	for i, v in pairs(t) do
		if standing.Territories[i] ~= nil then
			local structures = standing.Territories[i].Structures;
			if structures == nil then structures = {}; end
			for j, k in pairs(v) do
				if j > 0 and j < 19 then
					structures[j] = math.min(k[1], 100);
				end
			end
			standing.Territories[i].Structures = structures;
		end
	end
end



function foreach(t, layer)
	if layer == nil then layer = 0; end
	print("layer", layer)
	for i, v in pairs(t) do
		if type(v) == type(table) then
			foreach(v, layer + 1);
		else
			print(v);
		end
	end
end


function getTable(s, layer);
	local t = {};
	if layer == nil then layer = 1; end
	print(s, #s);
	local value = "";
	local i = 1;
	while i < #s do
		local c = string.sub(s, i, i);
		print(i, c)
		if c == "{" then
			if string.len(value) ~= 0 then
				t[tonumber(value)], index = getTable(string.sub(s, i + 1, string.len(s)), layer + 1);
				value = "";
			else
				t, index = getTable(string.sub(s, i + 1, string.len(s)), layer + 1);
			end
	--		if index == nil then break; end
			i = i + index;
		elseif c == "}" then
			if string.len(value) ~= 0 then
				table.insert(t, tonumber(value));
			end
			return t, i;
		else
			value = string.sub(s, i, i - 1 + string.len(string.match(s, "%d+", i)));
			i = i + string.len(value) - 1;
		end
		i = i + 1;
	end
	return t;
end
