function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	if data == nil then data = {}; end
	data.OneWayConnections = {};
	for _, terr in pairs(game.Map.Territories) do
		local value = captureValue(terr.Name);
		if value >= 1 then
			data.OneWayConnections[terr] = {};
			for _, conn in pairs(terr.ConnectedTo) do
				if captureValue(game.Map.Territories[conn].Name) > value then
					table.insert(data.OneWayConnections[terr], conn);
				end
			end
		end
	end
	Mod.PublicGameData = data;
end

function captureValue(str)
	local begin = string.find(str, "%[");
	local ending = string.find(str, "%]");
	if begin ~= nil and ending ~= nil then
		local value = tonumber(string.sub(str, begin + 1, ending - 1));
		if value ~= nil then return value; end
		return 0;
	end
	return 0;
end