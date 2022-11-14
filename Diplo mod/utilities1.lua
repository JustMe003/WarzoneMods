
function setPlayerNotifications()
	local t = {};
	t.Messages = {};
	t.LeftPlayers = {};
	t.JoinedPlayers = {};
	t.FactionWarDeclarations = {};
	t.FactionsPeaceOffers = {};
	t.FactionsPeaceConfirmed = {};
	t.FactionsPeaceDeclined = {};
	t.FactionsKicks = {};
	t.FactionsPendingJoins = {};
	t.WarDeclarations = {};
	t.PeaceOffers = {};
	t.PeaceDeclines = {};
	t.PeaceConfirmed = {};
	return t;
end

function resetPlayerNotifications(t)
	t.LeftPlayers = {};
	t.JoinedPlayers = {};
	t.FactionWarDeclarations = {};
	t.FactionsPeaceConfirmed = {};
	t.FactionsPeaceDeclined = {};
	t.FactionsKicks = {};
	t.FactionsPendingJoins = {};
	t.WarDeclarations = {};
	t.PeaceConfirmed = {};
	t.PeaceDeclines = {};
	t.NewFactionLeader = nil;
	t.GotKicked = nil;
	t.JoinRequestApproved = nil;
	t.JoinRequestRejected = nil;
	return t;
end

function count(t, func)
	local c = 0;
	for i, v in pairs(t) do
		if func ~= nil then
			c = c + func(v);
		else
			c = c + 1;
		end
	end
	return c;
end

function getSlotName(i)
	local c = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	local s = "Slot ";
	if i > 25 then
		s = s .. c[math.floor(i / 26)];
		i = i - math.floor(i / 26);
	end
	return s .. c[i % 26 + 1];
end

function concatArrays(t1, t2)
	for _, v in pairs(t2) do
		table.insert(t1, v);
	end
	return t1;
end

function filterDeadPlayers(game, array)
	if array == nil then return nil; end
	local toBeRemoved = {};
	for i = 1, #array do
		if game.ServerGame.Game.PlayingPlayers[array[i]] == nil then
			table.insert(toBeRemoved, i);
		end
	end
	for _, index in pairs(toBeRemoved) do
		table.remove(array, index);
	end
	return array;
end

function getPlayerHashMap(data, p, p2)
	local t = {};
	if data.IsInFaction[p] then
		concatArrays(t, data.Factions[data.PlayerInFaction[p]].FactionMembers);
	else
		table.insert(t, p);
	end
	if data.IsInFaction[p2] then
		concatArrays(t, data.Factions[data.PlayerInFaction[p2]].FactionMembers);
	else
		table.insert(t, p2);
	end
	return t;
end

function valueInTable(t, v)
	for _, v2 in pairs(t) do
		if v == v2 then return true; end
	end
	return false;
end

function getArrayOfAllPlayers(game)
	local t = {};
	for p, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		table.insert(t, p);
	end
	return t;
end

function createEvent(m, p, h);
	local t = {Message=m, PlayerID=p};
	if not Mod.Settings.GlobalSettings.VisibleHistory then
		t.VisibleTo = h;
	end
	return t;
end
