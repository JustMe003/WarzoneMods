Relations = {
	War = "AtWar",
	Peace = "InPeace",
	Faction = "InFaction"
}

FactionRelations = {
	War = "War",
	Peace = "Peace"
}

MOD_VERSION_1 = 1.6;
MOD_VERSION_2 = 2.4;

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

function getSlotIndex(s)
    local c = 0;
	s = string.upper(s);
    for i = 1, #s do
        local b = string.byte(s, i, i);
        c = c + ((b - 64) * 26^(#s - i));
    end
    c = c - 1;
    return c;
end

function validateSlotName(s)
    if #s < 1 then return false; end
    for i = 1, #s do
        local b = string.byte(s, i, i);
        if not ((b < 91 and b > 64) or (b < 123 and b > 96)) then return false; end
    end
    return true;
end

function getSlotName(slot)
	local s = "";
	slot = slot + 1;
    while slot > 0 do
        local n = slot % 26;
        if n == 0 then
            -- slot % 26 == 26
            n = 26;
        end
        slot = (slot - n) / 26;
        s = string.char(n + 64) .. s;
    end
    return "Slot " .. s;
end

function getColorFromList(n)
	if not n then return "#FFFFFF"; end
    n = n % getTableLength(colors);
    for _, color in pairs(colors) do
        if n == 0 then return color; end
        n = n - 1;
    end
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

function getTableLength(t)
	local c = 0;
	for _, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end

function tableIsEmpty(t)
	for _, _ in pairs(t) do
		return false;
	end
	return true;
end

function getSortedKeyList(t)
	local l = {};
	for k, _ in pairs(t) do
		table.insert(l, k);
	end
	table.sort(l);
	return l;
end

function getSortedValueList(t)
	local l = {};
	for _, v in pairs(t) do
		table.insert(l, v);
	end
	table.sort(l);
	return l;
end

function showRules(func)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

	if not func then
		AddToHistory(showRules);
	end

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Go back").SetColor(colors.Orange).SetOnClick(func or GetPreviousWindow);

	CreateEmpty(root).SetPreferredHeight(5);
	
	CreateLabel(root).SetText("Here is an overview of the 'rules' that come with the mod").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(createBulletPoint(root)).SetText("This is a diplomacy mod, meaning that you have a certain status with every other player, called a 'relation'").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root)).SetText("You can only have 1 of the following 3 relations with a player:").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("You are 'at war' with the player. That means that you can attack them, and they can attack you. This is sometimes referred to as a 'hostile relation'").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("You are 'in peace' with the player. That means that you cannot attack them and they cannot attack you. This is sometimes referred to as a 'peaceful relation'").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("You and the player are in the same Faction. This is essentially the same as being 'in peace' with each other, but this relation is stronger. This is sometimes referred to as a 'friendly relation'").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root)).SetText("The mod will play a diplomacy card on you and every player that you cannot attack. This makes it visible with whom you are 'at war' and with whom not").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root)).SetText("When you are 'in peace' with another player, you can declare war to change this relation to 'at war'. This means that after the diplomacy card has wore off, you can attack them and they can attack you").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root)).SetText("When you are 'at war' with another player, you can send them a 'peace offer'. Your opponent must accept this offer to actually change the relation between you and them to a peaceful relation").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root)).SetText("This mod adds a new 'team' system to the game: Factions").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("A Faction exists out of 1 or more players. If a Faction becomes empty, the Faction is deleted").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("While you are in a Faction, you automatically have a friendly relation with all other Faction members. 2 players in the same Faction can never change this relation, until at least 1 of them steps out of the Faction").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("A player cannot join a Faction while they are at war with at least one of the Faction members").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("Each Faction has a relation with each other Faction. This is similar to the individual relations with some small differences").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("Each Faction is either 'in peace' or 'at war' with another Faction").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("When 2 Factions are 'at war' with each other, all Faction members of Faction 1 are forced to be 'at war' with all Faction members of Faction 2").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("To have a peaceful relation again between 2 Factions, one of the Factions has to send a peace offer to the other Faction, which the other Faction has to accept. Only then the relation between the Factions changes to 'in peace'").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("When you are in a Faction, and an opponent player is in another Faction, you can still declare war or send a peace offer to them as long as both Factions do not have a hostile relation").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("Every Faction has a leader. This leader can, depending on the settings, kick players out, decide who can join and who not, manage the Faction relations or make another player Faction leader").SetColor(colors.TextColor);
	CreateLabel(createBulletPoint(root, 1)).SetText("When the Faction leader leaves or gets eliminated, the mod will automatically assign a new Faction leader").SetColor(colors.TextColor);
end

function createBulletPoint(root, n)
	line = CreateHorz(root).SetFlexibleWidth(1);
	if n ~= nil then
		CreateEmpty(line).SetMinWidth(20 * n);
	end
	CreateLabel(line).SetText("*").SetColor(colors.TextColor).SetMinWidth(20).SetAlignment(WL.TextAlignmentOptions.Center);
	return line;
end

function void(...)
end