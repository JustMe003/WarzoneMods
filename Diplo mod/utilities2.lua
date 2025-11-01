
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
	t.NewFactionLeader = {};
	t.GotKicked = {};
	t.JoinRequestApproved = {};
	t.JoinRequestRejected = {};
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
	t.NewFactionLeader = {};
	t.GotKicked = {};
	t.JoinRequestApproved = {};
	t.JoinRequestRejected = {};
	t.Messages = {};
	return t;
end

function count(t, func)
	local c = 0;
	for _, v in pairs(t) do
		if func ~= nil then
			c = c + func(v);
		else
			c = c + 1;
		end
	end
	return c;
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
		for _, faction in pairs(data.PlayerInFaction[p]) do
			concatArrays(t, data.Factions[faction].FactionMembers);
		end
	else
		table.insert(t, p);
	end
	if data.IsInFaction[p2] then
		for _, faction in pairs(data.PlayerInFaction[p2]) do
			concatArrays(t, data.Factions[faction].FactionMembers);
		end
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

function getKeyFromValue(t, v)
	for i, v2 in pairs(t) do
		if v == v2 then return i; end
	end
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

function isFactionLeader(p)
	if Mod.PublicGameData.IsInFaction[p] then
		for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[p]) do
			if type(faction) == type(table) then
				for i, v in pairs(faction) do print(i, v); end
			end
			if Mod.PublicGameData.Factions[faction].FactionLeader == p then
				return true;
			end
		end
	end
	return false;
end

function showVersionDetails(showVersionChangeText)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMain);
	
	if showVersionChangeText then
		CreateEmpty(root).SetPreferredHeight(5);
		
		CreateLabel(root).SetText("To change the version of the mod, you have to remove the mod from the game unfortunately. This will mean that you will lose all configurations you have already made").SetColor(colors.OrangeRed);
	end
	
	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("In this version, the most notable difference is that players can be in multiple Factions at a time. This does come with some rules though").SetColor(colors.TextColor);
	CreateLabel(root).SetText("Players are free to join any Faction, unless one of the normal rules apply.").SetColor(colors.TextColor);
	CreateLabel(root).SetText("The main detail to note about players being in multiple Factions is that they can be automatically kicked out when a Faction starts a Faction war. If a player is in 2 Factions, and these Factions go to war against each other, that player will be kicked out of the Faction that started the Faction war.").SetColor(colors.TextColor);
end


