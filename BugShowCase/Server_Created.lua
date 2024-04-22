
function Server_Created(game, settings)
	local data = Mod.PlayerGameData;
	local lastTable = data[1];		-- AI 1 has ID 1
	for i = 1, 100 do
		print("Level: " .. i);
		local t = {};
		table.insert(lastTable, t);
		lastTable = t;
		Mod.PlayerGameData = data;
	end

end