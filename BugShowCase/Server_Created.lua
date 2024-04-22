
function Server_Created(game, settings)
	local data = Mod.PlayerGameData;
	local lastTable = data;		-- AI 1 has ID 1
	for i = 1, 100 do
		print("Level: " .. i);
		print("lastTable = " .. tostring(lastTable));
		local t = {};
		print("t = " .. tostring(t));
		table.insert(lastTable, t);
		print("lastTable[1] = " .. tostring(lastTable[1]));
		lastTable = t;
		print("lastTable = " .. tostring(lastTable));
		Mod.PlayerGameData = data;
		print("Saved");
	end

end