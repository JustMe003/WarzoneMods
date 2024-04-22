
function Server_Created(game, settings)
	local data = Mod.PublicGameData;
	local lastTable = data;		-- AI 1 has ID 1
	for i = 1, 100 do
		print("Level: " .. i);
		local t = {};
		table.insert(lastTable, t);
		lastTable = t;
		Mod.PublicGameData = data;
		print("Saved");
	end

end