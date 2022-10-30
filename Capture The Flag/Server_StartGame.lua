function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	local players = {};
	local isTeamGame = false;
	local cooldowns = {};
	data.Teams = {};
	for _, player in pairs(game.Game.PlayingPlayers) do
		players[player.ID] = {};
		if player.Team ~= -1 then
			if data.Teams[player.Team] == nil then
				isTeamGame = true;
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
	if isTeamGame then
		for _, team in pairs(data.Teams) do
			local teamTerrCount = 0;
			for _, player in pairs(team) do
				teamTerrCount = teamTerrCount + #players[player];
			end
			minTerritories = math.min(minTerritories, teamTerrCount);
		end
		for _, team in pairs(data.Teams) do
			for i = 1, math.min(minTerritories, Mod.Settings.FlagsPerTeam) do
				local rp = math.random(#team);
				while #players[team[rp]] < 1 do
					rp = math.random(#team);
				end
				local rand = math.random(#players[team[rp]]);
				local terr = standing.Territories[players[team[rp]][rand]];
				local sp = terr.NumArmies.SpecialUnits;
				local flag = getFlag(team[rp]);
				table.insert(sp, flag);
				if Mod.Settings.Cooldown > 0 then
					cooldowns[flag.ID] = Mod.Settings.Cooldown;
				end
				terr.NumArmies = WL.Armies.Create(terr.NumArmies.NumArmies, sp);
				standing.Territories[players[team[rp]][rand]] = terr;
				table.remove(players[team[rp]], rand);
			end
		end
	else
		for p, _ in pairs(game.Game.PlayingPlayers) do
			minTerritories = math.min(minTerritories, #players[p]);
		end
		for p, _ in pairs(game.Game.PlayingPlayers) do
			for i = 1, math.min(minTerritories, Mod.Settings.FlagsPerTeam) do
				local rand = math.random(#players[p]);
				local terr = standing.Territories[players[p][rand]];
				local sp = terr.NumArmies.SpecialUnits;
				local flag = getFlag(p);
				if Mod.Settings.Cooldown > 0 then
					cooldowns[flag.ID] = Mod.Settings.Cooldown;
				end
				table.insert(sp, flag);
				terr.NumArmies = WL.Armies.Create(terr.NumArmies.NumArmies, sp);
				standing.Territories[players[p][rand]] = terr;
				table.remove(players[p], rand);
			end
		end
	end
	data.NFlags = math.min(minTerritories, Mod.Settings.FlagsPerTeam)
	data.Teams = nil;
	data.Cooldowns = cooldowns;
	Mod.PublicGameData = data;
end

function getFlag(p)
	local builder = WL.CustomSpecialUnitBuilder.Create(p);
	builder.Name = 'Flag';
	builder.IncludeABeforeName = true;
	builder.ImageFilename = 'Flag.png';
	builder.AttackPower = 0;
	builder.DefensePower = 0;
	builder.DamageToKill = 0;
	builder.DamageAbsorbedWhenAttacked = 0;
	builder.CombatOrder = 0;
	builder.CanBeGiftedWithGiftCard = false;
	builder.CanBeTransferredToTeammate = true;
	builder.CanBeAirliftedToSelf = true;
	builder.CanBeAirliftedToTeammate = true;
	builder.IsVisibleToAllPlayers = false;
	return builder.Build();
end