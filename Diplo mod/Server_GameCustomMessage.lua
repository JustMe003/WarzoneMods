function Server_GameCustomMessage(game, playerID, payload, setReturn)
	data = Mod.PublicGameData;
	local functions = {};
	functions["CreateFaction"] = createFaction;
	functions["LeaveFaction"] = leaveFaction;
	functions["5MinuteAlert"] = fiveMinuteAlert;
	functions["sendMessage"] = sendMessage;
	functions["joinFaction"] = joinFaction;
	functions["declareFactionWar"] = declareFactionWar;
	functions["offerFactionPeace"] = offerFactionPeace;
	functions["declareWar"] = declareWar;
	functions["peaceOffer"] = offerPeace;
	functions["openedChat"] = openedChat;
	functions["acceptPeaceOffer"] = acceptPeaceOffer;
	
	print(payload.Type);
	
	functions[payload.Type](game, playerID, payload, setReturn);
	
	Mod.PublicGameData = data;
end

function createFaction(game, playerID, payload, setReturn);
	for i, _ in pairs(Mod.PublicGameData.Factions) do
		if i == payload.Name then
			local t = setReturnPayload("This name already exists! Try another name");
			t.Type = "Error";
			setReturn(t);
			return;
		end
	end
	local factions = data.Factions;
	local t = {};
	t.FactionLeader = playerID;
	t.FactionMembers = {};
	t.FactionChat = {};
	t.PendingOffers = {};
	t.AtWar = {};
	for i, _ in pairs(data.Factions) do
		if i ~= payload.Name then
			t.AtWar[i] = false;
			data.Factions[i].AtWar[payload.Name] = false;
		end
	end
	table.insert(t.FactionMembers, playerID);
	factions[payload.Name] = t;
	data.Factions = factions;
	data.IsInFaction[playerID] = true;
	data.PlayerInFaction[playerID] = payload.Name;
	print(data.PlayerInFaction[playerID])
	setReturn(setReturnPayload("Successfully created the faction '" .. payload.Name .. "'", "Success"));
end

function leaveFaction(game, playerID, payload, setReturn)
	local ret;
	if data.IsInFaction[playerID] then
		local factions = data.Factions;
		local faction = data.PlayerInFaction[playerID];
		data.IsInFaction[playerID] = false;
		data.PlayerInFaction[playerID] = nil;
		local index = 0;
		local playerData = Mod.PlayerGameData;
		for i, v in pairs(factions[faction].FactionMembers) do
			if v == playerID then
				index = i
			else
				if playerData[v].Notifications == nil then playerData[v].Notifications = setPlayerNotifications(); end
				table.insert(playerData[v].Notifications.LeftPlayers, playerID);
				playerData[v].Notifications.Messages = {};
			end
		end
		Mod.PlayerGameData = playerData;
		table.remove(data.Factions[faction].FactionMembers, index);
		ret = setReturnPayload("Successfully left faction '" .. faction .. "'", "Success");
		if #factions[faction].FactionMembers <= 0 then
			factions[faction] = nil;
			ret.Message = ret.Message .. "\nSince you were the last member the faction was deleted";
			for i, _ in pairs(factions) do
				factions[i].AtWar[faction] = nil;
				for k, v in pairs(factions[i].PendingOffers) do
					if v == faction then
						table.remove(factions[i].PendingOffers, k);
						break;
					end
				end
			end
		elseif data.Factions[faction].FactionLeader == playerID then
			factions[faction].FactionLeader = factions[faction].FactionMembers[1];
			ret.Message = ret.Message .. "\nThe new faction leader is now " .. game.ServerGame.Game.PlayingPlayers[factions[faction].FactionLeader].DisplayName(nil, false);
		end
		data.Factions = factions;
	else
		ret = setReturnPayload("You are not in a faction!", "Error");
	end
	setReturn(ret);
end

function fiveMinuteAlert(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	if playerData[playerID] == nil then playerData[playerID] = {}; end
	playerData[playerID].LastMessage = payload.NewTime;
	playerData[playerID].Notifications = resetPlayerNotifications(playerData[playerID].Notifications);
	playerData[playerID].NumberOfNotifications = count(playerData[playerID].Notifications, function(t) return #t; end);
	Mod.PlayerGameData = playerData;
end

function sendMessage(game, playerID, payload, setReturn)
	local faction = data.PlayerInFaction[playerID];
	local ret;
	if faction ~= nil then
		local factionChat = data.Factions[faction].FactionChat;
		if #factionChat > 100 then
			table.remove(factionChat, 1);
		end
		local t = {};
		t.Text = payload.Text;
		t.Player = playerID;
		table.insert(data.Factions[faction].FactionChat, t);
		local playerData = Mod.PlayerGameData;
		for _, i in pairs(data.Factions[faction].FactionMembers) do
			if i ~= playerID then
				if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
				if playerData[i].Notifications.Messages == nil then playerData[i].Notifications.Messages = {}; end
				table.insert(playerData[i].Notifications.Messages, true);
			end
		end
		Mod.PlayerGameData = playerData;
		ret = setReturnPayload("Successfully send message!", "Success");
		ret.Function = "showFactionChat";
	else
		ret = setReturnPayload("You are not in a faction!", "Error");
	end
	setReturn(payload);
end

function joinFaction(game, playerID, payload, setReturn)
	if data.PlayerInFaction[playerID] == nil then
		local playerData = Mod.PlayerGameData;
		for _, p in pairs(data.Factions[payload.Faction].FactionMembers) do
			if data.Relations[playerID][p] == "AtWar" then
				setReturn(setReturnPayload("You cannot join the faction while you're at war with one of the factionmembers", "Error"));
				return;
			end
			if playerData[p].Notifications == nil then playerData[p].Notifications = setPlayerNotifications(); end
			table.insert(playerData[p].Notifications.JoinedPlayers, playerID);
		end
		Mod.PlayerGameData = playerData;
		table.insert(data.Factions[payload.Faction].FactionMembers, playerID);
		data.IsInFaction[playerID] = true;
		data.PlayerInFaction[playerID] = payload.Faction;
		setReturn(setReturnPayload("Successfully joined faction '" .. payload.Faction .. "'!", "Success"));
	else
		setReturn(setReturnPayload("You're already in a Faction!", "Error"));
	end
end

function setReturnPayload(m, t)
	return { Message=m, Type=t};
end

function declareFactionWar(game, playerID, payload, setReturn)
	if data.IsInFaction[playerID] and data.PlayerInFaction[playerID] == payload.PlayerFaction then
		if data.Factions[payload.PlayerFaction].FactionLeader == playerID then
			if data.Factions[payload.OpponentFaction] ~= nil then
				data.Factions[payload.PlayerFaction].AtWar[payload.OpponentFaction] = true;
				data.Factions[payload.OpponentFaction].AtWar[payload.PlayerFaction] = true;
				local playerData = Mod.PlayerGameData;
				for _, i in pairs(data.Factions[payload.PlayerFaction].FactionMembers) do
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					table.insert(playerData[i].Notifications.FactionWarDeclarations, payload.OpponentFaction);
					for _, p in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
						data.Relations[i][p] = "AtWar";
					end
				end
				for _, i in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					table.insert(playerData[i].Notifications.FactionWarDeclarations, payload.PlayerFaction);
					for _, p in pairs(data.Factions[payload.PlayerFaction].FactionMembers) do
						data.Relations[i][p] = "AtWar";
					end
				end
				Mod.PlayerGameData = playerData;
			else
				setReturn(setReturnPayload("The opponent faction was not found", "Error"));
			end
		else
			setReturn(setReturnPayload("This action can only be done by faction leaders, and you're not one of them.", "Error"));
		end
	else
		setReturn(setReturnPayload("You're not in a faction!", "Error"));
	end
end

function offerFactionPeace(game, playerID, payload, setReturn)
	if data.IsInFaction[playerID] and data.PlayerInFaction[playerID] == payload.PlayerFaction then
		if data.Factions[payload.PlayerFaction].FactionLeader == playerID then
			if data.Factions[payload.OpponentFaction] ~= nil then
				table.insert(data.Factions[payload.OpponentFaction].PendingOffers, payload.PlayerFaction);
				local playerData = Mod.PlayerGameData;
				for _, i in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					if playerData[i].Notifications.FactionsPeaceOffers == nil then playerData[i].Notifications.FactionsPeaceOffers = {}; end
					table.insert(playerData[i].Notifications.FactionsPeaceOffers, payload.PlayerFaction);
				end
				Mod.PlayerGameData = playerData;
			else
				setReturn(setReturnPayload("The opponent faction was not found", "Error"));
			end
		else
			setReturn(setReturnPayload("This action can only be done by faction leaders, and you're not one of them.", "Error"));
		end
	else
		setReturn(setReturnPayload("You're not in a faction!", "Error"));
	end
end

function declareWar(game, playerID, payload, setReturn)
	if data.Relations[playerID][payload.Opponent] == "InPeace" then
		data.Relations[playerID][payload.Opponent] = "AtWar";
		data.Relations[payload.Opponent][playerID] = "AtWar";
		if not game.ServerGame.Game.Players[payload.Opponent].IsAI then
			local playerData = Mod.PlayerGameData;
			if playerData[payload.Opponent].Notifications == nil then playerData[payload.Opponent].Notifications = setPlayerNotifications(); end
			table.insert(playerData[payload.Opponent].Notifications.WarDeclarations, playerID);
			Mod.PlayerGameData = playerData;
		end
		setReturn(setReturnPayload("Successfully declared war on this player", "Success"));
	else
		setReturn(setReturnPayload("You cannot declare war on this player", "Error"))
	end
end

function offerPeace(game, playerID, payload, setReturn)
	if data.Relations[playerID][payload.Opponent] == "AtWar" then
		if game.ServerGame.Game.Players[payload.Opponent].IsAIOrHumanTurnedIntoAI then
			data.Relations[playerID][payload.Opponent] = "InPeace";
			data.Relations[payload.Opponent][playerID] = "InPeace";
			setReturn(setReturnPayload("The AI accepted your offer", "Success"));
		else
			local playerData = Mod.PlayerGameData;
			if playerData[payload.Opponent].Notifications == nil then playerData[payload.Opponent].Notifications = setPlayerNotifications(); end
			table.insert(playerData[payload.Opponent].Notifications.WarDeclarations, playerID);
			Mod.PlayerGameData = playerData;
			setReturn(setReturnPayload("Successfully offered peace to this player", "Success"));
		end
	else
		setReturn(setReturnPayload("You cannot offer peace to this player since you're not in war with them", "Error"));
	end
end

function openedChat(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	playerData[playerID].Notifications.Messages = {};
	Mod.PlayerGameData = playerData;
end

function acceptPeaceOffer(game, playerID, payload, setReturn)
	local faction = data.PlayerInFaction[playerID];
	if payload.Index <= #data.Factions[data.PlayerInFaction[playerID]].PendingOffers then
		local opponentFaction = data.Factions[acceptPeaceOffer].PendingOffers[payload.Index];
		if data.Factions[opponentFaction] ~= nil then
			table.remove(data.Factions[opponentFaction].PendingOffers, payload.Index);
			data.Factions[faction].AtWar[opponentFaction] = false;
			data.Factions[opponentFaction].AtWar[faction] = false;
			local playerData = Mod.PlayerGameData;
			for _, i in pairs(data.Factions[opponentFaction].FactionMembers) do
				if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
				if playerData[i].Notifications.FactionsPeaceConfirmed == nil then playerData[i].Notifications.FactionsPeaceConfirmed = {}; end
				table.insert(playerData[i].Notifications.FactionsPeaceConfirmed, faction);
			end
			for _, i in pairs(data.Factions[faction].FactionMembers) do
				if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
				if playerData[i].Notifications.FactionsPeaceConfirmed == nil then playerData[i].Notifications.FactionsPeaceConfirmed = {}; end
				table.insert(playerData[i].Notifications.FactionsPeaceConfirmed, opponentFaction);
			end
			Mod.PlayerGameData = playerData;
		else
			setReturn(setReturnPayload("The '" .. opponentFaction .. "' faction has not been found", "Error"));
		end
	else
		setReturn(setReturnPayload("Something went wrong", "Error"));
	end
end

function setPlayerNotifications()
	local t = {};
	t.Messages = {};
	t.LeftPlayers = {};
	t.JoinedPlayers = {};
	t.FactionWarDeclarations = {};
	t.FactionsPeaceOffers = {};
	t.FactionsPeaceConfirmed = {};
	t.WarDeclarations = {};
	t.PeaceOffers = {};
	t.PeaceConfirmed = {};
	return t;
end

function resetPlayerNotifications(t)
	t.LeftPlayers = {};
	t.JoinedPlayers = {};
	t.FactionWarDeclarations = {};
	t.FactionsPeaceConfirmed = {};
	t.WarDeclarations = {};
	t.PeaceConfirmed = {};
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