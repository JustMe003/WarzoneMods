require("utilities2");
require("Client_PresentMenuUI2");
function Client_GameRefreshMain(game)
	if game.Us == nil then return; end
	if Mod.PlayerGameData.NumberOfNotifications == nil then return; end
	if Mod.PublicGameData.VersionNumber == nil or Mod.PublicGameData.VersionNumber < 6 then
		UI.Alert("The mod has been updated to 2.0! Unfortunately you'll have to wait untill the game advances a turn before you can use it again");
		return;
	end
	if Mod.PublicGameData.VersionNumber ~= nil and Mod.PlayerGameData.HasSeenUpdateWindow == nil then
		game.CreateDialog(function(root, size, scroll, game, Close) local vert = UI.CreateVerticalLayoutGroup(root); UI.CreateLabel(vert).SetText("Factions 2.0!\n\n(Note: This game uses the old version. That is not a problem, but you won't be able to use the new features / settings)\n\nAfter 6 months of designing, decision making and a lot of rewriting code, I've finally released the biggest update a mod has ever seen. Seriously, this mod already was the biggest and now it got almost triple the amount of files it first has...\nThis does mean we've got new features! Most biggest change is that now you're able to join multiple Factions! Joining a lot of Factions might get you in trouble tho, and you still won't be able to attack any Faction member of yours. This mod is also the first mod ever to allow 2 versions of it to be used. Game creators can choose whether they use the newest version (and allow players to join multiple Factions) or the old one (force players to be either in 1 faction or none).\n\nUsing the new version does come with some extra forced rules. These rules are all documented in the game ettings, mod menu and mod configuration.").SetColor("#FFA500"); end);
		game.SendGameCustomMessage("Updating mod...", {Type="hasSeenUpdateWindow"}, function(t) end);
	end
	if Mod.PlayerGameData.NumberOfNotifications ~= count(Mod.PlayerGameData.Notifications, function(t) if type(t) == type({}) then return #t; else return 1; end end) and dateIsEarlier(dateToTable(Mod.PlayerGameData.LastMessage), dateToTable(game.Game.ServerTime)) then
		showAlert(game);
		local payload = {};
		payload.Type = "5MinuteAlert";
		payload.NewTime = tableToDate(addTime(dateToTable(game.Game.ServerTime), "Seconds", 5));
		game.SendGameCustomMessage("Updating Factions mod...", payload, function(reply) end);
	end
	if Mod.PlayerGameData.NeedsRefresh ~= nil then
		game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUIMain(a, b, c, d, e, true); end);
		game.SendGameCustomMessage("Refreshing page...", {Type="RefreshWindow"}, function(reply) end);
	end
end

function showAlert(game)
	local playerData = Mod.PlayerGameData;
	if playerData.Notifications == nil then return; end
	local s = "";
	if playerData.Notifications.GotKicked ~= nil and #playerData.Notifications.GotKicked > 0 then
		for _, v in pairs(playerData.Notifications.GotKicked) do
			s = s .. "You were kicked from '" .. v .. "'\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.JoinRequestApproved ~= nil and #playerData.Notifications.JoinRequestApproved > 0  then
		s = s .. "Your following join requests were approved:\n"
		for _, v in pairs(playerData.Notifications.JoinRequestApproved) do
			s = s .. " - '" .. v .. "'\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.JoinRequestRejected ~= nil and #playerData.Notifications.JoinRequestRejected > 0 then
		for _, v in pairs(playerData.Notifications.JoinRequestRejected) do
			s = s .. " - Your request to join '" .. v .. "' was rejected\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.FactionWarDeclarations ~= nil and #playerData.Notifications.FactionWarDeclarations > 0 then
		s = s .. "Your faction is now at war with the following factions:\n";
		for _, v in pairs(playerData.Notifications.FactionWarDeclarations) do
			s = s .. " - " .. v.PlayerFaction .. " and " .. v.OpponentFaction .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.WarDeclarations ~= nil and #playerData.Notifications.WarDeclarations > 0 then
		s = s .. "You're now at war with the following players:\n";
		for _, v in pairs(playerData.Notifications.WarDeclarations) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.FactionsPeaceOffers ~= nil and #playerData.Notifications.FactionsPeaceOffers > 0 then
		s = s .. "Your faction received the following peace offers from other factions:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceOffers) do
			s = s .. " - " .. v.PlayerFaction .. " and " .. v.OpponentFaction .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.PeaceOffers ~= nil and #playerData.Notifications.PeaceOffers > 0 then
		s = s .. "You received the following peace offers from players:\n";
		for _, v in pairs(playerData.Notifications.PeaceOffers) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.FactionsPendingJoins ~= nil and #playerData.Notifications.FactionsPendingJoins > 0 then
		s = s .. "Your faction has the following join request from players:\n";
		for _, v in pairs(playerData.Notifications.FactionsPendingJoins) do
			s = s .. " - " .. game.Game.Players[v.Player].DisplayName(nil, false) .. " ('" .. v.Faction .. "')\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.FactionsPeaceConfirmed ~= nil and #playerData.Notifications.FactionsPeaceConfirmed > 0 then
		s = s .. "You're faction is now in peace with the following factions:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceConfirmed) do
			s = s .. " - " .. v.PlayerFaction .. " and " .. v.OpponentFaction .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.FactionsPeaceDeclined ~= nil and #playerData.Notifications.FactionsPeaceDeclined > 0 then
		s = s .. "The following faction peace offers were declined:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceDeclined) do
			s = s .. " - " .. v.PlayerFaction .. " and " .. v.OpponentFaction .. "\n";
		end
	end
	if playerData.Notifications.PeaceConfirmed ~= nil and #playerData.Notifications.PeaceConfirmed > 0 then
		s = s .. "You're now in peace with the following players:\n";
		for _, v in pairs(playerData.Notifications.PeaceConfirmed) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.PeaceDeclines ~= nil and #playerData.Notifications.PeaceDeclines > 0 then
		s = s .. "The following peace offers were declined:\n";
		for _, v in pairs(playerData.Notifications.PeaceDeclines) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.NewFactionLeader ~= nil and #playerData.Notifications.NewFactionLeader > 0 then
		s = s .. "The following players are now Faction leaders:\n";
		for _, v in pairs(playerData.Notifications.NewFactionLeader) do
			if v.Player == game.Us.ID then
				s = s .. " - You're now the leader of '" .. v.Faction .. "'\n";
			else
				s = s .. " - The leader of '" .. v.Faction .. " is now " .. game.Game.Players[v.Player].DisplayName(nil, false) .. "\n\n";
			end
		end
	end
	if playerData.Notifications.LeftPlayers ~= nil and #playerData.Notifications.LeftPlayers > 0 then
		s = s .. "The following players left (one of) your faction(s):\n";
		for _, v in pairs(playerData.Notifications.LeftPlayers) do
			s = s .. " - " .. game.Game.Players[v.Player].DisplayName(nil, false) .. " (" .. v.Faction .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.FactionsKicks ~= nil and #playerData.Notifications.FactionsKicks > 0 then
		s = s .. "The following players were kicked from (one of) your faction(s):\n";
		for _, v in pairs(playerData.Notifications.FactionsKicks) do
			s = s .. " - " .. game.Game.Players[v.Player].DisplayName(nil, false) .. " from '" .. v.Faction .. "'\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.JoinedPlayers ~= nil and #playerData.Notifications.JoinedPlayers > 0 then
		s = s .. "The following players joined the faction:\n";
		for _, v in pairs(playerData.Notifications.JoinedPlayers) do
			s = s .. " - " .. game.Game.Players[v.Player].DisplayName(nil, false) .. " ('" .. v.Faction .. "')\n";
		end
		s = s .. "\n";
	end
	print(count(playerData.Notifications.Messages));
	if playerData.Notifications.Messages ~= nil and count(playerData.Notifications.Messages) > 0 then
		s = s .. "You have unread messages in faction chats";
	end
	if #s > 0 then
		UI.Alert(s);
	end
	return s;
end

function getDateIndexList() return {"Year", "Month", "Day", "Hours", "Minutes", "Seconds", "MiliSeconds"}; end

function getDateRestraints() return {99999999, 12, 30, 24, 60, 60, 1000} end;

function dateToTable(s)
	local list = getDateIndexList();
	local r = {};
	local i = 1;
	local buffer = "";
	local index = 1;
	while i <= string.len(s) do
		local c = string.sub(s, i, i);
		if c == "-" or c == " " or c == ":" then
			r[list[index]] = tonumber(buffer);
			buffer = "";
			index = index + 1;
		else
			buffer = buffer .. c;
		end
		i = i + 1;
	end
	r[list[index]] = tonumber(buffer);
	return r;
end

function tableToDate(t)
	return t.Year .. "-" .. addZeros("Month", t.Month) .. "-" .. addZeros("Day", t.Day) .. " " .. addZeros("Hours", t.Hours) .. ":" .. addZeros("Minutes", t.Minutes) .. ":" .. addZeros("Seconds", t.Seconds) .. ":" .. addZeros("MiliSeconds", t.MiliSeconds);
end

function addTime(t, field, i)
	local dateIndex = getDateIndexList();
	local restraint = getDateRestraints()[getTableKey(dateIndex, field)];
	t[field] = t[field] + i;
	if t[field] > restraint then
		t[field] = t[field] - restraint;
		addTime(t, dateIndex[getTableKey(dateIndex, field) - 1], 1);
	end
	return t;
end

function getTableKey(t, value)
	for i, v in pairs(t) do
		if value == v then return i; end
	end
end

function addZeros(field, i)
	if field == "MiliSeconds" then
		if i < 10 then
			return "00" .. i;
		elseif i < 100 then
			return "0" .. i;
		end
	else
		if i < 10 then
			return "0" .. i;
		end
	end
	return i;
end


function dateIsEarlier(date1, date2)
	local list = getDateIndexList();
	for _, v in pairs(list) do
		if v == "MiliSeconds" then return false; end
		if date1[v] ~= date2[v] then
			if date1[v] < date2[v] then
				return true;
			else
				return false;
			end
		end
	end
	return false;
end
