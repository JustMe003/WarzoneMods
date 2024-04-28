
function Server_Created(game, settings)
	local data = Mod.PublicGameData;
	for i = 1, 10 do
		local t = createRandomTable();
		print("Number of tables: " .. tostring(getNumberOfTables(t)));
		print("Deepness: " .. tostring(getMaxDeepness(t)));
		data.Test = t;
		print("data == " .. tostring(data));
		print("data.Test == " .. tostring(data.Test));
		print("Next line: Mod.PublicGameData = data");
		Mod.PublicGameData = data;
		print(tostring(Mod.PublicGameData));
		print("Mod.PublicGameData == " .. tostring(Mod.PublicGameData));
		if Mod.PublicGameData == nil then error("Mod.PublicGameData was nil"); end
	end

end

function createRandomTable(p)
	p = p or 1;
	local t = {};
	for _ = 0, 2 do
		if math.random() <= p then
			table.insert(t, createRandomTable(p - 0.08));
		end
	end
	return t;
end

function getNumberOfTables(t)
	local c = 1;
	for _, v in pairs(t) do
		c = c + getNumberOfTables(v);
	end
	return c;
end

function getMaxDeepness(t, level)
	level = level or 1;
	local max = level;
	for _, v in pairs(t) do
		max = math.max(max, getMaxDeepness(v, level + 1));
	end
	return max;
end