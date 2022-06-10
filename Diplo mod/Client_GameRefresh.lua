require("Client_PresentMenuUI");
function Client_GameRefresh(game)
	if game.Us == nil then return; end
	if Mod.PlayerGameData.NumberOfNotifications == nil then return; end
	if dateIsEarlier(dateToTable(Mod.PlayerGameData.LastMessage), dateToTable(game.Game.ServerTime)) and Mod.PlayerGameData.NumberOfNotifications ~= count(playerData.Notifications, function(t) return #t; end) then
		showAlert(game);
		local payload = {};
		payload.Type = "5MinuteAlert";
		payload.NewTime = tableToDate(addTime(dateToTable(game.Game.ServerTime), "Seconds", 5));
		game.SendGameCustomMessage("Updating Factions mod...", payload, function(reply) end);
	end
end

function showAlert(game)
	local playerData = Mod.PlayerGameData;
	if playerData.Notifications == nil then return; end
	local s = "";
	if playerData.Notifications.FactionWarDeclarations ~= nil and #playerData.Notifications.FactionWarDeclarations > 0 then
		s = s .. "Your faction is now at war with the following factions:\n";
		for _, v in pairs(playerData.Notifications.FactionWarDeclarations) do
			s = s .. " - " .. v .. "\n";
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
			s = s .. " - " .. v .. "\n";
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
	if playerData.Notifications.FactionsPeaceConfirmed ~= nil and #playerData.Notifications.FactionsPeaceConfirmed > 0 then
		s = s .. "You're faction is now in peace with the following factions:\n";
		for _, v in pairs(playerData.Notifications.FactionsPeaceConfirmed) do
			s = s .. " - " .. v .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.PeaceConfirmed ~= nil and #playerData.Notifications.PeaceConfirmed > 0 then
		s = s .. "You're now in peace with the following players:\n";
		for _, v in pairs(playerData.Notifications.PeaceConfirmed) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.LeftPlayers ~= nil and #playerData.Notifications.LeftPlayers > 0 then
		s = s .. "The following players left the faction:\n";
		for _, v in pairs(playerData.Notifications.LeftPlayers) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
	if playerData.Notifications.JoinedPlayers ~= nil and #playerData.Notifications.JoinedPlayers > 0 then
		s = s .. "The following players joined the faction:\n";
		for _, v in pairs(playerData.Notifications.JoinedPlayers) do
			s = s .. " - " .. game.Game.Players[v].DisplayName(nil, false) .. "\n";
		end
		s = s .. "\n";
	end
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