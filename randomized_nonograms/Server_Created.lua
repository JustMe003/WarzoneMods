
function Server_Created(game, settings)
	if settings.MapID == 103074 then
		createNonogram(game, settings, 10);
	end
end

function createNonogram(game, settings, n)
	local mat = {};
	local i = 1;
	while i <= n do
		mat[i] = {};
		local j = 1;
		while j <= n do
			mat[i][j] = getValue();
			print(i, j, mat[i][j]);
		end
	end
	local bonuses = {};
	local bonusData = {};
	local bonus = {};
	local rowSize = math.ceil(n / 2);
	local bonusSize = 0;
	local bonusNumber = 0;
	local i = n;
	local j = n;
	while (i > 0) do
		bonusNumber = rowSize * (i - 1) + 1;
		while (j > 0) do
			if mat[i][j] == 1 then
				bonusSize = bonusSize + 1;
				table.insert(bonus, i * n + j);
			elseif bonusSize > 0 then
				bonuses[bonusNumber] = bonusSize;
				bonusData[bonusNumber] = bonus;
				bonus = {};
				bonusNumber = bonusNumber + 1;
				bonusSize = 0;
			end
			j = j - 1;
		end
		if bonusSize > 0 then
			bonuses[bonusNumber] = bonusSize;
			bonusData[bonusNumber] = bonus;
			bonus = {};
			bonusNumber = bonusNumber + 1;
			bonusSize = 0;
		end
		i = i - 1;
	end
	i = n;
	j = n;
	while (j > 0) do
		bonusNumber = n * math.ceil(n / 2) + rowSize * (j - 0) + 1;
		while (i > 0) do
			if mat[j][i] == 1 then
				bonusSize = bonusSize + 1;
				table.insert(bonus, i * n + j);
			elseif bonusSize > 0 then
				bonuses[bonusNumber] = bonusSize;
				bonusData[bonusNumber] = bonus;
				bonus = {};
				bonusNumber = bonusNumber + 1;
				bonusSize = 0;
			end
			i = i - 1;
		end
		if bonusSize > 0 then
			bonuses[bonusNumber] = bonusSize;
			bonusData[bonusNumber] = bonus;
			bonus = {};
			bonusNumber = bonusNumber + 1;
			bonusSize = 0;
		end
		j = j - 1;
	end
	local s = settings;
	s.OverriddenBonuses = bonuses;
	settings = s;
	local data = Mod.PublicGameData;
	data.Map = mat;
	data.Bonuses = bonusData;
	Mod.PublicGameData = data;
end

function getValue()
	if math.random(10000) / 100 <= Mod.Settings.Density then
		return 1;
	end
	return 0;
end

function round(n)
	return math.floor(n + 0.5);
end