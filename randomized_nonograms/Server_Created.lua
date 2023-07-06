
function Server_Created(game, settings)
	for i, v in pairs(game.Map.Readablekeys) do
		print(i, v);
	end
	data = Mod.PublicGameData;
	data.IsValid = false;
	data.Size = 0;
	if settings.MapID == 103187 then
		data.IsValid = true;
		data.Size = 5;
	elseif settings.MapID == 103184 then
		data.IsValid = true;
		data.Size = 10;
	end
	if data.Size > 0 then
		createNonogram(game, settings, data.Size);
	end
	Mod.PublicGameData = data;
end

function createNonogram(game, settings, n)
	local mat = {};
	local i = 1;
	while i <= n do
		mat[i] = {};
		local j = 1;
		while j <= n do
			mat[i][j] = getValue();
			j = j + 1;
		end
		i = i + 1;
	end
	local bonuses = {};
	local bonusData = {};
	local bonus = {};
	local rowSize = math.ceil(n / 2);
	local bonusSize = 0;
	local bonusNumber = 0;
	local cancelBonusNumber = 0;
	local solution = {};
	local i = n;
	while (i > 0) do
		bonusNumber = rowSize * (i - 1) + 1;
		cancelBonusNumber = math.ceil(n / 2) * n * 2 + i;
		bonuses[cancelBonusNumber] = 0;
		local j = n;
		while (j > 0) do
			if mat[i][j] == 1 then
				bonusSize = bonusSize + 1;
				table.insert(bonus, (i - 1) * n + j);
				table.insert(solution, (i - 1) * n + j);
			elseif bonusSize > 0 then
				bonuses[bonusNumber] = bonusSize;
				bonuses[cancelBonusNumber] = bonuses[cancelBonusNumber] - bonusSize;
				bonusData[bonusNumber] = bonus;
				bonus = {};
				bonusNumber = bonusNumber + 1;
				bonusSize = 0;
			end
			j = j - 1;
		end
		if bonusSize > 0 then
			bonuses[bonusNumber] = bonusSize;
			bonuses[cancelBonusNumber] = bonuses[cancelBonusNumber] - bonusSize;
			bonusData[bonusNumber] = bonus;
			bonus = {};
			bonusNumber = bonusNumber + 1;
			bonusSize = 0;
		end
		i = i - 1;
	end
	j = n;
	while (j > 0) do
		bonusNumber = (n * math.ceil(n / 2)) + rowSize * (j - 1) + 1;
		cancelBonusNumber = math.ceil(n / 2) * n * 2 + n + j;
		bonuses[cancelBonusNumber] = 0;
		i = n;
		while (i > 0) do
			if mat[i][j] == 1 then
				bonusSize = bonusSize + 1;
				table.insert(bonus, (i - 1) * n + j);
			elseif bonusSize > 0 then
				bonuses[bonusNumber] = bonusSize;
				bonuses[cancelBonusNumber] = bonuses[cancelBonusNumber] - bonusSize;
				bonusData[bonusNumber] = bonus;
				bonus = {};
				bonusNumber = bonusNumber + 1;
				bonusSize = 0;
			end
			i = i - 1;
		end
		if bonusSize > 0 then
			bonuses[bonusNumber] = bonusSize;
			bonuses[cancelBonusNumber] = bonuses[cancelBonusNumber] - bonusSize;
			bonusData[bonusNumber] = bonus;
			bonus = {};
			bonusNumber = bonusNumber + 1;
			bonusSize = 0;
		end
		j = j - 1;
	end
	bonusData[math.ceil(n / 2) * 2 * n + 2 * n + 1] = solution;
	bonuses[math.ceil(n / 2) * 2 * n + 2 * n + 1] = 1;
	local s = settings;
	s.OverriddenBonuses = bonuses;
	settings = s;
	data.Map = mat;
	data.Bonuses = bonusData;
end

function getValue()
	if math.random(10000) / 100 <= Mod.Settings.NonogramDensity then
		return 1;
	end
	return 0;
end

function round(n)
	return math.floor(n + 0.5);
end