function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	local flags = {};
	local players = {};
	local income = {};
	data.Teams = {};
	local teamNumber = 0;
	for _, player in pairs(game.Game.PlayingPlayers) do
		players[player.ID] = {};
		income[player.ID] = {};
		if player.Team == -1 then
			data.Teams[player.ID] = teamNumber;
			teamNumber = teamNumber + 1;
		else
			if data.Teams[player.Team] == nil then
				data.Teams[player.Team] = {};
			end
			table.insert(data.Teams[player.Team], player.ID);
		end
	end

	for _, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
			table.insert(players[terr.OwnerPlayerID], terr.ID);
		end
	end
	local minTerritories = 100000;
	for p, team in pairs(data.Teams) do
		local teamTerrCount = 0;
		if type(team) == type(table) then
			for _, player in pairs(team) do
				teamTerrCount = teamTerrCount + #players[player];
			end
		else
			teamTerrCount = #players[p];
		end
		minTerritories = math.min(minTerritories, teamTerrCount);
	end
	data.Flags = {};
	data.FlagsLost = {};
	for n, team in pairs(data.Teams) do
		data.Flags[n] = {};
		if type(team) == type(table) then
			data.FlagsLost[n] = 0;
			local order = {};
			local shadowTeam = team;
			for i = 1, #team do
				local rand = math.random(#shadowTeam);
				table.insert(order, shadowTeam[rand]);
				table.remove(shadowTeam, rand)
			end
			local index = 1;
			for i = 1, math.min(Mod.Settings.FlagsPerTeam, minTerritories) do
				local rand = math.random(#players[order[index]]);
				flags[players[order[index]][rand]] = n;
				table.remove(players[order[index]], rand);
				index = index + 1;
				if index > #order then index = 1; end
			end
		else
			data.FlagsLost[n] = 0;
			for i = 1, math.min(Mod.Settings.FlagsPerTeam, minTerritories) do
				local rand = math.random(#players[n]);
				flags[players[n][rand]] = n;
				table.remove(players[n], rand);
			end
		end
	end
	local boundUp = 17;
	for i, v in pairs(flags) do
		local structure = standing.Territories[i].Structures;
		structure = {};
		structure[v % boundUp + 2] = 1;
		standing.Territories[i].Structures = structure;
		data.Flags[v][i] = true;
	end
	data.Income = income;
	Mod.PublicGameData = data;
end