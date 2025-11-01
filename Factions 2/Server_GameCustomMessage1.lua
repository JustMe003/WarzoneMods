require("utilities1");
function Server_GameCustomMessageMain(game, playerID, payload, setReturn)
	data = Mod.PublicGameData;
	local functions = {};
	functions["CreateFaction"] = createFaction;
	functions["leaveFaction"] = leaveFaction;
	functions["5MinuteAlert"] = fiveMinuteAlert;
	functions["sendMessage"] = sendMessage;
	functions["joinFaction"] = joinFaction;
	functions["declareFactionWar"] = declareFactionWar;
	functions["offerFactionPeace"] = offerFactionPeace;
	functions["declareWar"] = declareWar;
	functions["peaceOffer"] = offerPeace;
	functions["openedChat"] = openedChat;
	functions["acceptFactionPeaceOffer"] = acceptFactionPeaceOffer;
	functions["acceptPeaceOffer"] = acceptPeaceOffer;
	functions["setFactionLeader"] = setFactionLeader;
	functions["kickPlayer"] = kickPlayer;
	functions["updateSettings"] = updateSettings;
	functions["requestCancel"] = requestCancel;
	functions["declineFactionPeaceOffer"] = declineFactionPeaceOffer
	functions["declinePeaceOffer"] = declinePeaceOffer;
	functions["DeclineJoinRequest"] = DeclineJoinRequest;
	functions["RefreshWindow"] = RefreshWindow;
	
	print(playerID, payload.Type);

	local playerData = Mod.PlayerGameData;
	for _, p in pairs(game.Game.Players) do
		if not p.IsAI then
			playerData[p.ID].Notifications.Messages = 0;
		end
	end

	
	playerData[playerID].NeedsRefresh = true;
	if payload.Type == "openedChat" then playerData[playerID].NeedsRefresh = nil; end
	Mod.PlayerGameData = playerData;
	
	functions[payload.Type](game, playerID, payload, setReturn);
	
	Mod.PublicGameData = data;
end

function createFaction(game, playerID, payload, setReturn);
	for i, _ in pairs(Mod.PublicGameData.Factions) do
		if i == payload.Name then
			local t = setReturnPayload("This name already exists! Try another name");
			t.Type = "Fail";
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
	t.Offers = {};
	t.AtWar = {};
	if Mod.Settings.GlobalSettings.ApproveFactionJoins then
		t.JoinRequests = {};
	end
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
	table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " created a new faction called '" .. payload.Name .. "'", playerID));
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
				data.Relations[v][playerID] = "InPeace";
				data.Relations[playerID][v] = "InPeace";
				if not game.Game.Players[v].IsAI then
					if playerData[v].Notifications == nil then playerData[v].Notifications = setPlayerNotifications(); end
					table.insert(playerData[v].Notifications.LeftPlayers, playerID);
				end
			end
		end
		table.remove(data.Factions[faction].FactionMembers, index);
		ret = setReturnPayload("Successfully left faction '" .. faction .. "'", "Success");
		table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " left the faction '" .. faction .. "'", playerID));
		if #factions[faction].FactionMembers <= 0 then
			factions[faction] = nil;
			ret.Message = ret.Message .. "\nSince you were the last member the faction was deleted";
			for i, _ in pairs(factions) do
				factions[i].AtWar[faction] = nil;
				for k, v in pairs(factions[i].PendingOffers) do
					if v == faction then
						table.remove(factions[i].PendingOffers, k);
						factions[i].Offers[faction] = nil;
						break;
					end
				end
			end
			if Mod.Settings.ApproveFactionJoins then
				for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
					if not p.IsAI then
						if playerData[p.ID].HasPendingRequest == faction then
							playerData[p.ID].HasPendingRequest = nil;
						end
					end
				end
			end
			table.insert(data.Events, createEvent("'" .. faction .. "' was deleted since it had no members", playerID));
		elseif data.Factions[faction].FactionLeader == playerID then
			factions[faction].FactionLeader = factions[faction].FactionMembers[1];
			ret.Message = ret.Message .. "\nThe new faction leader is now " .. game.ServerGame.Game.PlayingPlayers[factions[faction].FactionLeader].DisplayName(nil, false);
			setFactionLeader(game, playerID, {PlayerID=factions[faction].FactionLeader}, setReturn);
		end
		Mod.PlayerGameData = playerData;
		data.Factions = factions;
	else
		ret = setReturnPayload("You are not in a faction!", "Fail");
	end
	setReturn(ret);
end

function fiveMinuteAlert(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	if playerData[playerID] == nil then playerData[playerID] = {}; end
	playerData[playerID].LastMessage = payload.NewTime;
	playerData[playerID].Notifications = resetPlayerNotifications(playerData[playerID].Notifications);
	playerData[playerID].NumberOfNotifications = count(playerData[playerID].Notifications, function(t) 
		if type(t) == "table" then 
			return #t; 
		else 
			return t; 
		end
	end);
	Mod.PlayerGameData = playerData;
end

---comment
---@param game GameServerHook
---@param playerID any
---@param payload any
---@param setReturn any
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
		t.TimeStamp = payload.TimeStamp;
		table.insert(data.Factions[faction].FactionChat, t);
		local playerData = Mod.PlayerGameData;
		for _, i in pairs(data.Factions[faction].FactionMembers) do
			if i ~= playerID and not game.Game.Players[i].IsAI then
				if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
				if playerData[i].Notifications.Messages == nil or type(playerData[i].Notifications.Messages) == 'table' then playerData[i].Notifications.Messages = 0; end
				playerData[i].Notifications.Messages = playerData[i].Notifications.Messages + 1;
			end
		end
		Mod.PlayerGameData = playerData;
		ret = setReturnPayload("Successfully send message!", "Success");
		ret.Function = "showFactionChat";
	else
		ret = setReturnPayload("You are not in a faction!", "Fail");
	end
	setReturn(payload);
end

function joinFaction(game, playerID, payload, setReturn)		-- Create different function for accepting pending join request
	if data.PlayerInFaction[payload.PlayerID] == nil then
		local playerData = Mod.PlayerGameData;
		local relations = data.Relations;
		if not Mod.Settings.GlobalSettings.FairFactions or getFactionIncome(game, payload.Faction) + game.ServerGame.Game.PlayingPlayers[payload.PlayerID].Income(0, game.ServerGame.LatestTurnStanding, true, true).Total <= Mod.Settings.GlobalSettings.FairFactionsModifier * data.TotalIncomeOfAllPlayers then
			if Mod.Settings.GlobalSettings.ApproveFactionJoins then
				if payload.RequestApproved == nil then
					for _, p in pairs(data.Factions[payload.Faction].FactionMembers) do
						if data.Relations[payload.PlayerID][p] == "AtWar" then
							setReturn(setReturnPayload("You cannot request to join the faction while you're at war with one of the factionmembers (" .. game.ServerGame.Game.Players[p].DisplayName(nil, false) .. ")", "Fail"));
							return;
						end
					end
					if game.Game.Players[data.Factions[payload.Faction].FactionLeader].IsAIOrHumanTurnedIntoAI then
						payload.RequestApproved = true;
						joinFaction(game, playerID, payload, setReturn);
					else
						playerData[payload.PlayerID].HasPendingRequest = payload.Faction;
						table.insert(data.Factions[payload.Faction].JoinRequests, payload.PlayerID);
						if playerData[data.Factions[payload.Faction].FactionLeader].Notifications == nil then playerData[data.Factions[payload.Faction].FactionLeader].Notifications = setPlayerNotifications(); end
						table.insert(playerData[data.Factions[payload.Faction].FactionLeader].Notifications.FactionsPendingJoins, payload.PlayerID);
						table.insert(data.Events, createEvent(game.Game.Players[payload.PlayerID].DisplayName(nil, false) .. " requested to join '" .. payload.Faction .. "'", payload.PlayerID, getPlayerHashMap(data, payload.PlayerID, data.Factions[payload.Faction].FactionLeader)));
					end
				else
					playerData[payload.PlayerID].HasPendingRequest = nil;
					if game.ServerGame.Game.PlayingPlayers[payload.PlayerID] == nil then
						setReturn(setReturnPayload("This player is not in the game anymore", "Fail"));
						for i, v in pairs(data.Factions[payload.Faction].JoinRequests) do
							if v == payload.PlayerID then
								table.remove(data.Factions[payload.Faction].JoinRequests, i);
								break;
							end
						end
						return;
					end
					local relations = data.Relations;
					for _, p in pairs(data.Factions[payload.Faction].FactionMembers) do
						if data.Relations[payload.PlayerID][p] == "AtWar" then
							setReturn(setReturnPayload(game.ServerGame.Game.Players[payload.PlayerID].DisplayName(nil, false) .. " cannot join the faction since they are at war with one of the factionmembers (" .. game.ServerGame.Game.Players[p].DisplayName(nil, false) .. ")", "Fail"));
							return;
						end
						if not game.Game.Players[p].IsAI then
							if playerData[p].Notifications == nil then playerData[p].Notifications = setPlayerNotifications(); end
							table.insert(playerData[p].Notifications.JoinedPlayers, payload.PlayerID);
						end
						relations[payload.PlayerID][p] = "InFaction";
						relations[p][payload.PlayerID] = "InFaction";
					end
					data.Relations = relations;
					for i, bool in pairs(data.Factions[payload.Faction].AtWar) do
						if bool then
							for _, p in pairs(data.Factions[i].FactionMembers) do
								if data.Relations[p][payload.PlayerID] ~= "AtWar" then
									if not game.ServerGame.Game.Players[payload.PlayerID].IsAI then
										table.insert(playerData[payload.PlayerID].Notifications.WarDeclarations, p);
									end
									if not game.ServerGame.Game.Players[p].IsAI then
										table.insert(playerData[p].Notifications.WarDeclarations, payload.PlayerID);
									end
									data.Relations[p][payload.PlayerID] = "AtWar";
									data.Relations[payload.PlayerID][p] = "AtWar";
								end
							end
						end
					end
					table.insert(data.Factions[payload.Faction].FactionMembers, payload.PlayerID);
					for i, v in pairs(data.Factions[payload.Faction].JoinRequests) do
						if v == payload.PlayerID then
							table.remove(data.Factions[payload.Faction].JoinRequests, i);
							break;
						end
					end
					data.IsInFaction[payload.PlayerID] = true;
					data.PlayerInFaction[payload.PlayerID] = payload.Faction;
					if playerData[payload.PlayerID].Notifications == nil then playerData[payload.PlayerID].Notifications = setPlayerNotifications(); end
					playerData[payload.PlayerID].Notifications.JoinRequestApproved = payload.Faction;
					Mod.PlayerGameData = playerData;
					setReturn(setReturnPayload("Join request approved", "Success"));
					table.insert(data.Events, createEvent("Approved join request from " .. game.ServerGame.Game.Players[payload.PlayerID].DisplayName(nil, false), playerID));
				end
			else
				for _, p in pairs(data.Factions[payload.Faction].FactionMembers) do
					if data.Relations[payload.PlayerID][p] == "AtWar" then
						setReturn(setReturnPayload("You cannot join the faction while you're at war with one of the factionmembers (" .. game.ServerGame.Game.Players[p].DisplayName(nil, false) .. ")", "Fail"));
						return;
					end
					if not game.Game.Players[p].IsAI then
						if playerData[p].Notifications == nil then playerData[p].Notifications = setPlayerNotifications(); end
						table.insert(playerData[p].Notifications.JoinedPlayers, payload.PlayerID);
					end
					relations[payload.PlayerID][p] = "InFaction";
					relations[p][payload.PlayerID] = "InFaction";
				end
				data.Relations = relations;
				table.insert(data.Factions[payload.Faction].FactionMembers, payload.PlayerID);
				data.IsInFaction[payload.PlayerID] = true;
				data.PlayerInFaction[payload.PlayerID] = payload.Faction;
				for i, bool in pairs(data.Factions[payload.Faction].AtWar) do
					if bool then
						for _, p in pairs(data.Factions[i].FactionMembers) do
							if data.Relations[p][payload.PlayerID] ~= "AtWar" then
								table.insert(playerData[payload.PlayerID].Notifications.WarDeclarations, p);
								table.insert(playerData[p].Notifications.WarDeclarations, payload.PlayerID);
								data.Relations[p][payload.PlayerID] = "AtWar";
								data.Relations[payload.PlayerID][p] = "AtWar";
							end
						end
					end
				end
				setReturn(setReturnPayload("Successfully joined faction '" .. payload.Faction .. "'!", "Success"));
				table.insert(data.Events, createEvent(game.ServerGame.Game.Players[payload.PlayerID].DisplayName(nil, false) .. " joined the faction '" .. payload.Faction .. "'", payload.PlayerID));
			end
			Mod.PlayerGameData = playerData;
		else
			setReturn(setReturnPayload("You are not allowed to join this faction since it will disbalance the factions", "Fail"));
		end
	else
		setReturn(setReturnPayload("You're already in a Faction!", "Fail"));
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
					if not game.Game.Players[i].IsAI then
						if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
						table.insert(playerData[i].Notifications.FactionWarDeclarations, payload.OpponentFaction);
					end
					for _, p in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
						data.Relations[i][p] = "AtWar";
					end
				end
				for _, i in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
					if not game.Game.Players[i].IsAI then
						if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
						table.insert(playerData[i].Notifications.FactionWarDeclarations, payload.PlayerFaction);
					end
					for _, p in pairs(data.Factions[payload.PlayerFaction].FactionMembers) do
						data.Relations[i][p] = "AtWar";
					end
				end
				Mod.PlayerGameData = playerData;
				table.insert(data.Events, createEvent("'" .. payload.PlayerFaction .. "' declared war on '" .. payload.OpponentFaction .. "'", playerID, getPlayerHashMap(data, data.Factions[payload.PlayerFaction].FactionLeader, data.Factions[payload.OpponentFaction].FactionLeader)));
				setReturn(setReturnPayload("Successfully declared war on '" .. payload.OpponentFaction .. "'", "Success"));
			else
				setReturn(setReturnPayload("The '" .. payload.OpponentFaction .. "' opponent faction was not found", "Fail"));
			end
		else
			setReturn(setReturnPayload("This action can only be done by faction leaders, and you're not one of them.", "Fail"));
		end
	else
		setReturn(setReturnPayload("You're not in a faction!", "Fail"));
	end
end

function offerFactionPeace(game, playerID, payload, setReturn)
	if data.IsInFaction[playerID] and data.PlayerInFaction[playerID] == payload.PlayerFaction then
		if data.Factions[payload.PlayerFaction].FactionLeader == playerID then
			if data.Factions[payload.OpponentFaction] ~= nil then
				if data.Factions[payload.PlayerFaction].Offers[payload.OpponentFaction] == nil then
					if game.ServerGame.Game.Players[data.Factions[payload.OpponentFaction].FactionLeader].IsAIOrHumanTurnedIntoAI then
						data.Factions[payload.PlayerFaction].AtWar[payload.OpponentFaction] = false;
						data.Factions[payload.OpponentFaction].AtWar[payload.PlayerFaction] = false;
						local playerData = Mod.PlayerGameData;
						for _, i in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
							if not game.Game.Players[i].IsAI then
								if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
								if playerData[i].Notifications.FactionsPeaceOffers == nil then playerData[i].Notifications.FactionsPeaceOffers = {}; end
								table.insert(playerData[i].Notifications.FactionsPeaceConfirmed, payload.PlayerFaction);
							end
							for _, p in pairs(data.Factions[payload.PlayerFaction].FactionMembers) do
								data.Relations[i][p] = "InPeace";
								data.Relations[p][i] = "InPeace";
							end
						end
						for _, i in pairs(data.Factions[payload.PlayerFaction].FactionMembers) do
							if i ~= playerID and not game.Game.Players[i].IsAI then
								if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
								if playerData[i].Notifications.FactionsPeaceOffers == nil then playerData[i].Notifications.FactionsPeaceOffers = {}; end
								table.insert(playerData[i].Notifications.FactionsPeaceConfirmed, payload.OpponentFaction);
							end
						end
						Mod.PlayerGameData = playerData;
						setReturn(setReturnPayload("Since the faction leader of '" .. payload.OpponentFaction .. "' is an AI it automatically accepted the offer", "Success"));
						table.insert(data.Events, createEvent("'" .. payload.PlayerFaction .. "' offered peace to '" .. payload.OpponentFaction .. "', which was accepted directly", playerID, getPlayerHashMap(data, data.Factions[payload.PlayerFaction].FactionLeader, data.Factions[payload.OpponentFaction].FactionLeader)));
					else
						table.insert(data.Factions[payload.OpponentFaction].PendingOffers, payload.PlayerFaction);
						data.Factions[payload.PlayerFaction].Offers[payload.OpponentFaction] = true;
						data.Factions[payload.OpponentFaction].Offers[payload.PlayerFaction] = true;
						local playerData = Mod.PlayerGameData;
						for _, i in pairs(data.Factions[payload.OpponentFaction].FactionMembers) do
							if not game.Game.Players[i].IsAI then
								if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
								if playerData[i].Notifications.FactionsPeaceOffers == nil then playerData[i].Notifications.FactionsPeaceOffers = {}; end
								table.insert(playerData[i].Notifications.FactionsPeaceOffers, payload.PlayerFaction);
							end
						end
						for _, i in pairs(data.Factions[payload.PlayerFaction].FactionMembers) do
							if i ~= playerID and not game.Game.Players[i].IsAI then
								if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
								if playerData[i].Notifications.FactionsPeaceOffers == nil then playerData[i].Notifications.FactionsPeaceOffers = {}; end
								table.insert(playerData[i].Notifications.FactionsPeaceOffers, payload.PlayerFaction);
							end
						end
						Mod.PlayerGameData = playerData;
						setReturn(setReturnPayload("Successfully offered peace to '" .. payload.OpponentFaction .. "'", "Success"));
						table.insert(data.Events, createEvent("'" .. payload.PlayerFaction .. "' offered peace to '" .. payload.OpponentFaction .. "'", playerID, getPlayerHashMap(data, data.Factions[payload.PlayerFaction].FactionLeader, data.Factions[payload.OpponentFaction].FactionLeader)));
					end
				else
					setReturn(setReturnPayload("There already is a pending peace offer.", "Fail"));
				end
			else
				setReturn(setReturnPayload("The '" .. payload.OpponentFaction .. "' faction was not found", "Fail"));
			end
		else
			setReturn(setReturnPayload("This action can only be done by faction leaders, and you're not one of them.", "Fail"));
		end
	else
		setReturn(setReturnPayload("You're not in a faction!", "Fail"));
	end
end

function declareWar(game, playerID, payload, setReturn)
	if data.Relations[playerID][payload.Opponent] == "InPeace" then
		data.Relations[playerID][payload.Opponent] = "AtWar";
		data.Relations[payload.Opponent][playerID] = "AtWar";
		if not game.ServerGame.Game.Players[payload.Opponent].IsAI then
			if not game.Game.Players[payload.Opponent].IsAI then
				local playerData = Mod.PlayerGameData;
				if playerData[payload.Opponent].Notifications == nil then playerData[payload.Opponent].Notifications = setPlayerNotifications(); end
				table.insert(playerData[payload.Opponent].Notifications.WarDeclarations, playerID);
				Mod.PlayerGameData = playerData;
			end
		end
		table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " declared war on " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false), playerID, getPlayerHashMap(data, playerID, payload.Opponent)));
		setReturn(setReturnPayload("Successfully declared war on " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false), "Success"));
	else
		setReturn(setReturnPayload("You cannot declare war on " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false), "Fail"))
	end
end

function offerPeace(game, playerID, payload, setReturn)
	if data.Relations[playerID][payload.Opponent] == "AtWar" then
		if game.ServerGame.Game.Players[payload.Opponent].IsAIOrHumanTurnedIntoAI then
			data.Relations[playerID][payload.Opponent] = "InPeace";
			data.Relations[payload.Opponent][playerID] = "InPeace";
			setReturn(setReturnPayload("The AI accepted your offer", "Success"));
			table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " offered peace to " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false) .. ", which was directly accepted", playerID, getPlayerHashMap(data, playerID, payload.Opponent)));
		else
			local playerData = Mod.PlayerGameData;
			if playerData[playerID].Offers[payload.Opponent] == nil then
				if playerData[payload.Opponent].Notifications == nil then playerData[payload.Opponent].Notifications = setPlayerNotifications(); end
				if playerData[payload.Opponent].Notifications.PeaceOffers == nil then playerData[payload.Opponent].Notifications.PeaceOffers = {}; end
				table.insert(playerData[payload.Opponent].Notifications.PeaceOffers, playerID);
				table.insert(playerData[payload.Opponent].PendingOffers, playerID);
				playerData[playerID].Offers[payload.Opponent] = true;
				playerData[payload.Opponent].Offers[playerID] = true;
				setReturn(setReturnPayload("Successfully offered peace to " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false), "Success"));
				table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " offered peace to " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false), playerID, getPlayerHashMap(data, playerID, payload.Opponent)));
			else
				setReturn(setReturnPayload("There already is a pending peace offer", "Fail"));
			end
			Mod.PlayerGameData = playerData;
			setReturn(setReturnPayload("Successfully offered peace to " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false), "Success"));
		end
	else
		setReturn(setReturnPayload("You cannot offer peace to " .. game.ServerGame.Game.Players[payload.Opponent].DisplayName(nil, false) .. " this player since you're not in war with them", "Fail"));
	end
end

function openedChat(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	Mod.PlayerGameData = playerData;
end

function acceptFactionPeaceOffer(game, playerID, payload, setReturn)
	local faction = data.PlayerInFaction[playerID];
	if payload.Index <= #data.Factions[faction].PendingOffers then
		local opponentFaction = data.Factions[faction].PendingOffers[payload.Index];
		if data.Factions[opponentFaction] ~= nil then
			table.remove(data.Factions[faction].PendingOffers, payload.Index);
			data.Factions[faction].AtWar[opponentFaction] = false;
			data.Factions[opponentFaction].AtWar[faction] = false;
			data.Factions[opponentFaction].Offers[faction] = nil;
			data.Factions[faction].Offers[opponentFaction] = nil;
			local playerData = Mod.PlayerGameData;
			for _, i in pairs(data.Factions[opponentFaction].FactionMembers) do
				if not game.Game.Players[i].IsAI then
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					if playerData[i].Notifications.FactionsPeaceConfirmed == nil then playerData[i].Notifications.FactionsPeaceConfirmed = {}; end
					table.insert(playerData[i].Notifications.FactionsPeaceConfirmed, faction);
				end
				for _, p in pairs(data.Factions[faction].FactionMembers) do
					data.Relations[i][p] = "InPeace";
					data.Relations[p][i] = "InPeace";
				end
			end
			for _, i in pairs(data.Factions[faction].FactionMembers) do
				if i ~= playerID and not game.Game.Players[i].IsAI then
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					if playerData[i].Notifications.FactionsPeaceConfirmed == nil then playerData[i].Notifications.FactionsPeaceConfirmed = {}; end
					table.insert(playerData[i].Notifications.FactionsPeaceConfirmed, opponentFaction);
					table.remove(playerData[i].Notifications.FactionsPeaceOffers, payload.Index);
				end
			end
			Mod.PlayerGameData = playerData;
			table.insert(data.Events, createEvent("'" .. faction .. "' accepted the peace offer from '" .. opponentFaction .. "'", playerID, getPlayerHashMap(data, playerID, data.Factions[opponentFaction].FactionLeader)));
			setReturn(setReturnPayload("Successfully accepted the offer", "Success"));
		else
			setReturn(setReturnPayload("The '" .. opponentFaction .. "' faction has not been found", "Fail"));
		end
	else
		setReturn(setReturnPayload("Something went wrong", "Fail"));
	end
end

function acceptPeaceOffer(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	if payload.Index <= #playerData[playerID].PendingOffers then
		local opponent = playerData[playerID].PendingOffers[payload.Index];
		if data.IsInFaction[playerID] and data.IsInFaction[opponent] then
			if not data.Factions[data.PlayerInFaction[playerID]].AtWar[data.PlayerInFaction[opponent]] then
				table.remove(playerData[playerID].PendingOffers, payload.Index);
				table.remove(playerData[playerID].Notifications.PeaceOffers, payload.Index);
				data.Relations[opponent][playerID] = "InPeace";
				data.Relations[playerID][opponent] = "InPeace";
				table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " accepted the peace offer from " .. game.ServerGame.Game.Players[opponent].DisplayName(nil, false), playerID, getPlayerHashMap(data, playerID, opponent)));
				setReturn(setReturnPayload("Successfully accepted the offer", "Success"));
			else
				setReturn(setReturnPayload("You cannot accept peace while your faction is in war with your opponents faction", "Fail"));
				return;
			end
		else
			table.remove(playerData[playerID].PendingOffers, payload.Index);
			table.remove(playerData[playerID].Notifications.PeaceOffers, payload.Index);
			playerData[playerID].Offers[opponent] = nil;
			playerData[opponent].Offers[playerID] = nil;
			data.Relations[opponent][playerID] = "InPeace";
			data.Relations[playerID][opponent] = "InPeace";
			table.insert(playerData[opponent].Notifications.PeaceConfirmed, playerID);
			table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " accepted the peace offer from " .. game.ServerGame.Game.Players[opponent].DisplayName(nil, false), playerID, getPlayerHashMap(data, playerID, opponent)));
			setReturn(setReturnPayload("Successfully accepted the offer", "Success"));
		end
	else
		setReturn(setReturnPayload("Something went wrong", "Fail"));
	end
	Mod.PlayerGameData = playerData;
end

function setFactionLeader(game, playerID, payload, setReturn)
	if data.IsInFaction[playerID] then
		if data.Factions[data.PlayerInFaction[playerID]].FactionLeader == playerID then
			data.Factions[data.PlayerInFaction[playerID]].FactionLeader = payload.PlayerID;
			local playerData = Mod.PlayerGameData;
			for _, i in pairs(data.Factions[data.PlayerInFaction[playerID]].FactionMembers) do
				if i ~= playerID then
					if not game.Game.Players[i].IsAI then
						if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
						playerData[i].Notifications.NewFactionLeader = payload.PlayerID;
					end
				end
			end
			Mod.PlayerGameData = playerData;
			table.insert(data.Events, createEvent(game.ServerGame.Game.Players[payload.PlayerID].DisplayName(nil, false) .. " is the new Faction leader of '" .. data.PlayerInFaction[payload.PlayerID] .. "'", playerID));
			setReturn(setReturnPayload("Successfully made " .. game.ServerGame.Game.Players[payload.PlayerID].DisplayName(nil, false) .. " Faction leader", "Success"));
		else
			setReturn(setReturnPayload("This action can only be done by faction leaders", "Fail"));
		end
	else
		setReturn(setReturnPayload("You're not in a faction!", "Fail"));
	end
end

function kickPlayer(game, playerID, payload, setReturn)
	if data.Factions[payload.Faction] ~= nil then
		if data.Factions[payload.Faction].FactionLeader == playerID then
			if data.Factions[payload.Faction].FactionMembers[payload.Index] ~= nil then
				local player = data.Factions[payload.Faction].FactionMembers[payload.Index];
				if player == payload.Player then
					local playerData = Mod.PlayerGameData;
					table.remove(data.Factions[payload.Faction].FactionMembers, payload.Index);
					if not game.ServerGame.Game.Players[player].IsAI then
						if playerData[player].Notifications == nil then playerData[player].Notifications = setPlayerNotifications(); end
						playerData[player].Notifications.GotKicked = payload.Faction;
					end
					for _, v in pairs(data.Factions[payload.Faction].FactionMembers) do
						if v ~= playerID and not game.ServerGame.Game.Players[v].IsAI then
							if playerData[v].Notifications == nil then playerData[v].Notifications = setPlayerNotifications(); end
							table.insert(playerData[v].Notifications.FactionsKicks, player);
						end
						data.Relations[v][player] = "InPeace";
						data.Relations[player][v] = "InPeace";
					end
					data.IsInFaction[player] = false;
					data.PlayerInFaction[player] = nil;
					table.insert(data.Events, createEvent("Kicked " .. game.Game.Players[player].DisplayName(nil, false) .. " from '" .. payload.Faction .. "'", playerID));
					Mod.PlayerGameData = playerData;
				else
					setReturn(setReturnPayload("Something went wrong, please refresh the page and try again", "Fail"));
				end
			else
				setReturn(setReturnPayload("Something went wrong, please refresh the page and try again", "Fail"));
			end
		else
			setReturn(setReturnPayload("You are not the faction leader and cannot make do this", "Fail"));
		end
	else
		setReturn(setReturnPayload("Your faction doesn't exists anymore", "Fail"));
	end
end

function requestCancel(game, playerID, payload, setReturn)
	if data.Factions[payload.Faction] ~= nil then
		local playerData = Mod.PlayerGameData;
		if playerData[playerID].HasPendingRequest ~= nil and playerData[playerID].HasPendingRequest == payload.Faction then
			playerData[playerID].HasPendingRequest = nil;
			for i, p in pairs(data.Factions[payload.Faction].JoinRequests) do
				if p == playerID then
					table.remove(data.Factions[payload.Faction].JoinRequests, i);
					break;
				end
			end
			setReturn(setReturnPayload("Successfully cancelled join request", "Success"));
			table.insert(data.Events, createEvent(game.ServerGame.Game.PlayingPlayers[playerID].DisplayName(nil, false) .. " cancelled their join request by the '" .. payload.Faction .. "'", playerID, getPlayerHashMap(data, playerID, data.Factions[payload.Faction].FactionLeader)));
		else
			setReturn(setReturnPayload("You do not have a pending join request for this faction", "Fail"));
		end
		Mod.PlayerGameData = playerData;
	else
		setReturn(setReturnPayload("This faction doesn't exists anymore", "Fail"));
	end
end

function declineFactionPeaceOffer(game, playerID, payload, setReturn)
	local faction = data.PlayerInFaction[playerID];
	if payload.Index <= #data.Factions[faction].PendingOffers then
		local opponentFaction = data.Factions[faction].PendingOffers[payload.Index];
		if data.Factions[opponentFaction] ~= nil then
			table.remove(data.Factions[faction].PendingOffers, payload.Index);
			data.Factions[opponentFaction].Offers[faction] = nil;
			data.Factions[faction].Offers[opponentFaction] = nil;
			local playerData = Mod.PlayerGameData;
			for _, i in pairs(data.Factions[opponentFaction].FactionMembers) do
				if not game.Game.Players[i].IsAI then
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					if playerData[i].Notifications.FactionsPeaceDeclined == nil then playerData[i].Notifications.FactionsPeaceDeclined = {}; end
					table.insert(playerData[i].Notifications.FactionsPeaceDeclined, faction);
				end
			end
			for _, i in pairs(data.Factions[faction].FactionMembers) do
				if not game.Game.Players[i].IsAI then
					if playerData[i].Notifications == nil then playerData[i].Notifications = setPlayerNotifications(); end
					if playerData[i].Notifications.FactionsPeaceDeclined == nil then playerData[i].Notifications.FactionsPeaceDeclined = {}; end
					if i ~= playerID then
						table.insert(playerData[i].Notifications.FactionsPeaceDeclined, opponentFaction);
					end
					table.remove(playerData[i].Notifications.FactionsPeaceOffers, payload.Index);
				end
			end
			Mod.PlayerGameData = playerData;
			table.insert(data.Events, createEvent("'" .. faction .. "' declined the peace offer from '" .. opponentFaction .. "'", playerID, getPlayerHashMap(data, playerID, data.Factions[opponentFaction].FactionLeader)));
			setReturn(setReturnPayload("Successfully declined the offer", "Success"));
		else
			setReturn(setReturnPayload("The '" .. opponentFaction .. "' faction has not been found", "Fail"));
		end
	else
		setReturn(setReturnPayload("Something went wrong", "Fail"));
	end
end

function declinePeaceOffer(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	if payload.Index <= #playerData[playerID].PendingOffers then
		local opponent = playerData[playerID].PendingOffers[payload.Index];
		table.remove(playerData[playerID].PendingOffers, payload.Index);
		playerData[playerID].Offers[opponent] = nil;
		playerData[opponent].Offers[playerID] = nil;
		table.remove(playerData[playerID].Notifications.PeaceOffers, payload.Index);
		table.insert(playerData[opponent].Notifications.PeaceDeclines, playerID);
		setReturn(setReturnPayload("Successfully declined the offer", "Success"));
		table.insert(data.Events, createEvent(game.ServerGame.Game.Players[playerID].DisplayName(nil, false) .. " declined the peace offer from " .. game.ServerGame.Game.Players[opponent].DisplayName(nil, false), playerID, getPlayerHashMap(data, playerID, opponent)));
	else
		setReturn(setReturnPayload("Something went wrong", "Fail"));
	end
	Mod.PlayerGameData = playerData;
end

function DeclineJoinRequest(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	if data.Factions[payload.Faction] ~= nil then
		if payload.Index <= #data.Factions[payload.Faction].JoinRequests then
			if data.Factions[payload.Faction].JoinRequests[payload.Index] == payload.PlayerID then
				table.remove(data.Factions[payload.Faction].JoinRequests, payload.Index);
				if not game.ServerGame.Game.Players[payload.PlayerID].IsAI then
					if playerData[payload.PlayerID].Notifications == nil then playerData[payload.PlayerID].Notifications = setPlayerNotifications(); end
					playerData[payload.PlayerID].Notifications.JoinRequestRejected = payload.Faction;
					playerData[payload.PlayerID].HasPendingRequest = nil;
				end
			else
				setReturn(setReturnPayload("Something went wrong", "Fail"));
			end
		else
			setReturn(setReturnPayload("Something went wrong", "Fail"));
		end
	else
		setReturn(setReturnPayload("The faction doesn't exists anymore", "Fail"));
	end
	Mod.PlayerGameData = playerData;
end

function updateSettings(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData;
	playerData[playerID].PersonalSettings = {};
	playerData[playerID].PersonalSettings.WindowWidth = math.max(math.min(payload.WindowWidth, 1000), 300);
	playerData[playerID].PersonalSettings.WindowHeight = math.max(math.min(payload.WindowHeight, 1000), 300);
	setReturn(setReturnPayload("Successfully updated your settings. To apply your changes close and re-open the menu", "Success"));
	Mod.PlayerGameData = playerData;
end

function RefreshWindow(game, playerID, payload, setReturn)
	local playerData = Mod.PlayerGameData
	playerData[playerID].NeedsRefresh = nil;
	Mod.PlayerGameData = playerData
end

function getFactionIncome(game, faction)
	local count = 0;
	for _, i in pairs(data.Factions[faction].FactionMembers) do
		count = count + game.ServerGame.Game.PlayingPlayers[i].Income(0, game.ServerGame.LatestTurnStanding, true, true).Total;
	end
	return count;
end