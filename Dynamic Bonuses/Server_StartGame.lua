function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	local t = {};
	for terrID, _ in pairs(standing.Territories) do
		t[terrID] = 0;
	end
	data.WellBeingMultiplier = t;
	Mod.PublicGameData = data;
end

