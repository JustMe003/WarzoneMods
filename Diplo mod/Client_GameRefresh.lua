require("utilities");
require("Client_PresentMenuUI");
function Client_GameRefresh(game)
	if game.Us == nil then return; end
	if Mod.PlayerGameData.NumberOfNotifications == nil then return; end
	print(game.Us.ID, game.Us.DisplayName(nil, false));
	if Mod.PlayerGameData.NumberOfNotifications ~= count(Mod.PlayerGameData.Notifications, function(t) return #t; end) and dateIsEarlier(dateToTable(Mod.PlayerGameData.LastMessage), dateToTable(game.Game.ServerTime)) then
		print("showAlert");
		showAlert(game);
		local payload = {};
		payload.Type = "5MinuteAlert";
		payload.NewTime = tableToDate(addTime(dateToTable(game.Game.ServerTime), "Seconds", 5));
		game.SendGameCustomMessage("Updating Factions mod...", payload, function(reply) end);
	end
	if Mod.PlayerGameData.NeedsRefresh ~= nil then
		game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, true); end);
		game.SendGameCustomMessage("Refreshing page...", {Type="RefreshWindow"}, function(reply) end);
	end
end

function showAlert(game)
	local playerData = Mod.PlayerGameData;
	if playerData.Notifications == nil then return; end
	local s = "";
	print(s, playerData.Notifications.GotKicked);
	if playerData.Notifications.GotKicked ~= nil then
		s = s .. "You were kicked from '" .. playerData.Notifications.GotKicked .. "'\n\n";
	end
	print(s, playerData.Notifications.JoinRequestApproved);
	if playerData.Notifications.JoinRequestApproved ~= nil then
		s = s .. "Your request to join '" .. playerData.Notifications.JoinRequestApproved .. "' was approved\n\n";
	end
	print(s, playerData.Notifications.JoinRequestRejected);
	if playerData.Notifications.JoinRequestRejected ~= nil then
		s = s .. "Your request to join '" .. playerData.Notifications.JoinRequestRejected .. "' was rejected\n\n";
	end
	print(s, playerData.Notifications.FactionWarDeclarations);
	if playerData.Notifications.FactionWarDeclarations ~= nil and #playerData.Notifications.FactionWarDeclarations > 0 then
		s = s .. "Your faction is now at war with the following factions:\n";
		for _, v in pairs(playerData.Notifications.FactionWarDeclarations) do
			s = s .. " - " .. v .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.WarDeclarations);
	if playerData.Notifications.WarDeclarations ~= nil and #playerData.Notifications.WarDeclarations > 0 then
		s = s .. "You're now at war with the following players:\n";
		for _, v in pairs(playerData.Notifications.WarDeclarations) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.FactionsPeaceOffers);
	if playerData.Notifications.FactionsPeaceOffers ~= nil and #playerData.Notifications.FactionsPeaceOffers > 0 then
		s = s .. "Your faction received the following peace offers from other factions:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceOffers) do
			s = s .. " - " .. v .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.PeaceOffers);
	if playerData.Notifications.PeaceOffers ~= nil and #playerData.Notifications.PeaceOffers > 0 then
		s = s .. "You received the following peace offers from players:\n";
		for _, v in pairs(playerData.Notifications.PeaceOffers) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.FactionsPendingJoins);
	if playerData.Notifications.FactionsPendingJoins ~= nil and #playerData.Notifications.FactionsPendingJoins > 0 then
		s = s .. "Your faction has the following join request from players:\n";
		for _, v in pairs(playerData.Notifications.FactionsPendingJoins) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.FactionsPeaceConfirmed);
	if playerData.Notifications.FactionsPeaceConfirmed ~= nil and #playerData.Notifications.FactionsPeaceConfirmed > 0 then
		s = s .. "You're faction is now in peace with the following factions:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceConfirmed) do
			s = s .. " - " .. v .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.FactionsPeaceDeclined);
	if playerData.Notifications.FactionsPeaceDeclined ~= nil and #playerData.Notifications.FactionsPeaceDeclined > 0 then
		s = s .. "The following faction peace offers were declined:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceDeclined) do
			s = s .. " - " .. v .. "\n";
		end
	end
	print(s, playerData.Notifications.PeaceConfirmed);
	if playerData.Notifications.PeaceConfirmed ~= nil and #playerData.Notifications.PeaceConfirmed > 0 then
		s = s .. "You're now in peace with the following players:\n";
		for _, v in pairs(playerData.Notifications.PeaceConfirmed) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.PeaceDeclines);
	if playerData.Notifications.PeaceDeclines ~= nil and #playerData.Notifications.PeaceDeclines > 0 then
		s = s .. "The following peace offers were declined:\n";
		for _, v in pairs(playerData.Notifications.PeaceDeclines) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.NewFactionLeader);
	if playerData.Notifications.NewFactionLeader ~= nil then
		if playerData.Notifications.NewFactionLeader == game.Us.ID then
			s = s .. "You're now the leader of your faction \n\n";
		else
			s = s .. "The leader of your faction is now " .. game.Game.Players[playerData.Notifications.NewFactionLeader].DisplayName(nil, false) .. "\n\n";
		end
	end
	print(s, playerData.Notifications.LeftPlayers);
	if playerData.Notifications.LeftPlayers ~= nil and #playerData.Notifications.LeftPlayers > 0 then
		s = s .. "The following players left the faction:\n";
		for _, v in pairs(playerData.Notifications.LeftPlayers) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.FactionsKicks);
	if playerData.Notifications.FactionsKicks ~= nil and #playerData.Notifications.FactionsKicks > 0 then
		s = s .. "The following players were kicked from your faction:\n";
		for _, v in pairs(playerData.Notifications.FactionsKicks) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.JoinedPlayers);
	if playerData.Notifications.JoinedPlayers ~= nil and #playerData.Notifications.JoinedPlayers > 0 then
		s = s .. "The following players joined the faction:\n";
		for _, v in pairs(playerData.Notifications.JoinedPlayers) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	print(s, playerData.Notifications.Messages);
	if playerData.Notifications.Messages ~= nil and #playerData.Notifications.Messages > 0 then
		s = s .. "You have " .. #playerData.Notifications.Messages .. " unread messages in the faction chat";
	end
	if #s > 0 then
		UI.Alert(s);
	end
	return s;
end

function getDateIndexList() return {"Year", "Month", "Day", "Hours", "Minutes", "Seconds", "MiliSeconds"}; end

function getDateRestraints() return {99999999, 12, 30, 24, 60, 60, 1000} end;

function dateToTable(s)
	print("dateToTable");
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
	print("dateIsEarlier");
	local list = getDateIndexList();
	print(1);
	for _, v in pairs(list) do
		print(v, date1[v], date2[v])
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
