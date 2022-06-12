require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close, calledFromGameRefresh)
	init(rootParent);
	game = Game;
	if game.Us == nil then return; end
	if Close ~= nil and calledFromGameRefresh ~= nil then
		Close();
	end
	Close = close;
	setMaxSize(500, 600);

	showMenu();
end

function showMenu()
	local win = "showMenu";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		restoreWindow(win);
	else
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newButton(win .. "showFactions", vert, "Factions", showFactions, "Cyan", getTableLength(Mod.PublicGameData.Factions) > 0);
		newButton(win .. "showFactionChat", vert, "Faction chat", showFactionChat, "Orange", Mod.PublicGameData.IsInFaction[game.Us.ID]);
		newButton(win .. "createFactionButton", vert, "Create Faction", createFaction, "Lime", not(Mod.PublicGameData.IsInFaction[game.Us.ID]));
		newLabel(win .. "empty", vert, "\n");
		newButton(win .. "playerPage", vert, "Your relations", showPlayerPage, game.Us.Color.HtmlColor);
	end
end

function showFactions()
	local win = "showFactions";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	if Mod.PublicGameData.IsInFaction[game.Us.ID] then
		newLabel(win .. "PlayerFactionString", vert, "Your faction:");
		newButton(win .. "PlayerFaction", vert, Mod.PublicGameData.PlayerInFaction[game.Us.ID], function() showFactionDetails(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) end, game.Us.Color.HtmlColor);
		newLabel(win .. "EmptyAfterPlayerFaction", vert, "\n\nOther factions");
	end
	for factionName, faction in pairs(Mod.PublicGameData.Factions) do
		if factionName ~= Mod.PublicGameData.PlayerInFaction[game.Us.ID] then
			newButton(win .. factionName, vert, factionName, function() showFactionDetails(factionName) end, game.Game.PlayingPlayers[faction.FactionLeader].Color.HtmlColor);
		end
	end
end

function showPlayerPage()
	local win = "showPlayerPage";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "PendingOffers", vert, "Pending offers", showPendingOffers, "Cyan", Mod.PlayerGameData.PendingOffers ~= nil and getTableLength(Mod.PlayerGameData.PendingOffers) > 0);
	for i, p in pairs(game.Game.PlayingPlayers) do
		if i ~= game.Us.ID then
			newButton(win .. i, vert, p.DisplayName(nil, false), function() showPlayerDetails(i) end, p.Color.HtmlColor);
		end
	end
	newButton(win .. "Return", vert, "Return", showMenu, "Orange");
end

function showPendingOffers()
	local win = "showPendingOffers";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	for i, v in pairs(Mod.PlayerGameData.PendingOffers) do
		newButton(win .. i, vert, game.Game.Players[v].DisplayName(nil, false), function() confirmChoice("Do you wish to accept the peace offer from " .. game.Game.Players[v].DisplayName(nil, false) .. "?", function() game.SendGameCustomMessage("Accepting peace offer...", {Type="acceptPeaceOffer", Index=i}, gameCustomMessageReturn); showPlayerPage(); end, function() showPendingOffers(); end); end, game.Game.Players[v].Color.HtmlColor);
	end
	newButton(win .. "return", vert, "Return", showPlayerPage, "Orange");
end

function showPlayerDetails(playerID)
	local win = "showPlayerDetails" .. playerID;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local isAtWarFromFaction = false;
	newLabel(win .. "name", vert, game.Game.PlayingPlayers[playerID].DisplayName(nil, false));
	if Mod.PublicGameData.IsInFaction[playerID] then
		local line = newHorizontalGroup(win .. "line10", vert);
		newLabel(win .. "factionNameText", line, "Faction: ");
		newLabel(win .. "factionName", line, Mod.PublicGameData.PlayerInFaction[playerID], game.Game.Players[Mod.PublicGameData.Factions[Mod.PublicGameData.PlayerInFaction[playerID]].FactionLeader].Color.HtmlColor);
		if Mod.PublicGameData.IsInFaction[game.Us.ID] then
			local line = newHorizontalGroup(win .. "line", vert);
			newLabel(win .. "factionRelation", line, "Relation between faction: ");
			if Mod.PublicGameData.Relations[game.Us.ID][playerID] == "InFaction" or not Mod.PublicGameData.Factions[Mod.PublicGameData.PlayerInFaction[game.Us.ID]].AtWar[Mod.PublicGameData.PlayerInFaction[playerID]] then
				newLabel(win .. "factionRelationPeace", line, "Friendly", "Green");
			else
				newLabel(win .. "factionRelationWar", line, "Hostile", "Red");
				newLabel(win .. "peaceOfferExplanation", vert, "If you wish to be in peace with this player you have to first leave your faction or you're faction must be in peace with " .. Mod.PublicGameData.PlayerInFaction[playerID]);
				isAtWarFromFaction = true;
			end
		end
	else
		newLabel(win .. "isNotInFaction", vert, "This player is not in a faction", "Orange Red");
	end
	local line = newHorizontalGroup(win .. "line4", vert);
	newLabel(win .. "privateRelation", line, "Personal relation: ")
	if Mod.PublicGameData.Relations[game.Us.ID][playerID] == "AtWar" then
		newLabel(win .. "relationStatus", line, "Hostile", "Red");
	elseif Mod.PublicGameData.Relations[game.Us.ID][playerID] == "InPeace" then
		newLabel(win .. "relationStatus", line, "peaceful", "Yellow");
	else
		newLabel(win .. "relationStatus", line, "Friendly", "Green");
	end
	newLabel(win .. "EmptyAfterOpponentFaction", vert, "\n");
	local line = newHorizontalGroup(win .. "line2", vert);
	newButton(win .. "ToWar", line, "Declare war", function() confirmChoice("Do you really wish to go to war against" .. game.Game.Players[playerID].DisplayName(nil, false) .. "?", function() game.SendGameCustomMessage("Declaring war...", { Type="declareWar", Opponent=playerID }, gameCustomMessageReturn); showPlayerDetails(playerID); end, function() showPlayerDetails(playerID) end); end, "Red", Mod.PublicGameData.Relations[game.Us.ID][playerID] == "InPeace");
	newButton(win .. "offerPeace", line, "Offer peace", function() confirmChoice("Do you wish to offer peace to " .. game.Game.Players[playerID].DisplayName(nil, false) .. "?", function() game.SendGameCustomMessage("Offering peace...", { Type="peaceOffer", Opponent=playerID }, gameCustomMessageReturn); showPlayerDetails(playerID); end, function() showPlayerDetails(playerID); end); end, "Green", not(isAtWarFromFaction) and Mod.PublicGameData.Relations[game.Us.ID][playerID] == "AtWar" and Mod.PlayerGameData.Offers[playerID] == nil);
	newButton(win .. "return", vert, "Return", showPlayerPage, "Orange");
end

function showFactionDetails(factionName)
	local win = "showFactionDetails" .. factionName;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup(win .. "line", vert);
	local bool = Mod.PublicGameData.PlayerInFaction[game.Us.ID] == factionName;
	local color;
	newButton(win .. "LeaveFaction", line, "Leave Faction", function() confirmChoice("Are you sure you want to leave the '" .. factionName .. "' faction?", function() game.SendGameCustomMessage("Leaving faction...", {Type="leaveFaction"}, gameCustomMessageReturn); Close(); end, function() showFactionDetails(factionName); end); end, "Red", bool);
	newButton(win .. "JoinFaction", line, "Join Faction", function() confirmChoice("Do you wish to join the '" .. factionName .. "' faction? If this faction is in war with any other faction you'll automatically declare war on them.", function() game.SendGameCustomMessage("Joining faction...", {Type="joinFaction", Faction=factionName}, gameCustomMessageReturn); Close(); end, function() showFactionDetails(factionName); end); end, "Green", Mod.PublicGameData.PlayerInFaction[game.Us.ID] == nil);
	newButton(win .. "return", line, "Return", showFactions, "Orange");
	if bool then 
		color = "Lime"; 
	else 
		color = "Orange Red"; 
	end
	newLabel(win .. "label", vert, factionName .. "\n", color);
	if game.Us.ID == Mod.PublicGameData.Factions[factionName].FactionLeader then
		newButton(win .. "FactionSettings", vert, "Faction settings", function() factionSettings(factionName) end, "Tyrian Purple");
		newLabel(win .. "EmptyAfterFactionsettings", vert, "\n");
	end
	newLabel(win .. "FactionLeader", vert, "Faction leader: " .. game.Game.Players[Mod.PublicGameData.Factions[factionName].FactionLeader].DisplayName(nil, false) .. "\n", game.Game.Players[Mod.PublicGameData.Factions[factionName].FactionLeader].Color.HtmlColor);
	newLabel(win .. "PlayersInFaction", vert, "The following players are in this faction: ");
	for i, v in pairs(Mod.PublicGameData.Factions[factionName].FactionMembers) do
		newLabel(win .. i .. v, vert, i .. ". " .. game.Game.Players[v].DisplayName(nil, false), game.Game.Players[v].Color.HtmlColor);
	end
end

function factionSettings(factionName)
	local win = "FactionSettings";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "DeclareWar", vert, "Declare war", function() declareFactionWar(factionName) end, "Red", getTableLength(Mod.PublicGameData.Factions[factionName].AtWar, function(v) return not(v); end) > 0);
	newButton(win .. "PeaceOffer", vert, "Offer peace", function() offerFactionPeace(factionName) end, "Green", getTableLength(Mod.PublicGameData.Factions[factionName].AtWar, function(v) return v and Mod.PublicGameData.Factions[factionName].Offers[v] == nil; end) > 0);
	newButton(win .. "pendingPeaceOffers", vert, "Pending offers", function() pendingFactionPeaceOffers(factionName) end, "Cyan", getTableLength(Mod.PublicGameData.Factions[factionName].PendingOffers) > 0);
	newButton(win .. "Return", vert, "Return", function() showFactionDetails(factionName) end, "Orange");
end

function declareFactionWar(factionName)
	local win = "declareFactionWar";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "text", vert, "Pick a faction to go to war with them:");
	for faction, bool in pairs(Mod.PublicGameData.Factions[factionName].AtWar) do
		if not(bool) then
			local line = newHorizontalGroup(faction .. "line", vert);
			newLabel(win .. faction .. "name", line, faction, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
			newButton(win .. faction .. "button", line, "War!", function() confirmChoice("Are you sure you want to declare war on " .. faction .. "? All your faction members will be forced to declare war on all of the players in " .. faction, function() game.SendGameCustomMessage("Declaring war on " .. faction .. "...", { Type="declareFactionWar", PlayerFaction=factionName, OpponentFaction=faction }, gameCustomMessageReturn); factionSettings(factionName); end, function() declareFactionWar(factionName); end) end, "Red");
		end
	end
end

function offerFactionPeace(factionName)
	local win = "offerFactionPeace";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "text", vert, "Pick a faction to ask for peace with them:");
	for faction, bool in pairs(Mod.PublicGameData.Factions[factionName].AtWar) do
		if bool and Mod.PublicGameData.Factions[factionName].Offers[faction] == nil then
			local line = newHorizontalGroup(faction .. "line", vert);
			newLabel(win .. faction .. "name", line, faction, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
			newButton(win .. faction .. "button", line, "Peace", function() confirmChoice("Are you sure you want to offer peace to " .. faction .. "? All your faction members will be forced in peace with all of the players in " .. faction, function() game.SendGameCustomMessage("Offering peace to " .. faction .. "...", { Type="offerFactionPeace", OpponentFaction=faction, PlayerFaction=factionName }, gameCustomMessageReturn); factionSettings(factionName); end, function() offerFactionPeace(factionName); end) end, "Green");
		end
	end
end

function pendingFactionPeaceOffers(factionName)
	local win = "pendingFactionPeaceOffers";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "n", vert, "You have " .. #Mod.PublicGameData.Factions[factionName].PendingOffers .. " peace offers");
	for i, v in pairs(Mod.PublicGameData.Factions[factionName].PendingOffers) do
		newButton(win .. i, vert, v, function() confirmChoice("Do you wish to accept the peace offer from the '" .. v .. "' faction?", function() game.SendGameCustomMessage("Accepting peace offer...", { Type="acceptFactionPeaceOffer", Index=i, PlayerFaction=factionName}, gameCustomMessageReturn); factionSettings(factionName); end, function() factionSettings(factionName); end); end, game.Game.Players[Mod.PublicGameData.Factions[v].FactionLeader].Color.HtmlColor);
	end
	newButton(win .. "Return", vert, "Return", function() factionSettings(factionName) end, "Orange");
end


function confirmChoice(message, yesFunc, noFunc)
	local win = "confirmOfferFactionPeace";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "text", vert, message);
	local line = newHorizontalGroup(win .. "line", vert);
	newButton(win .. "yes", line, "Yes!", yesFunc, "Green");
	newButton(win .. "no...", line, "No...", noFunc, "Red");
end

function showFactionChat()
	game.SendGameCustomMessage("updating mod...", { Type="openedChat" }, gameCustomMessageReturn);
	local win = "showFactionChat";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup("line", vert);
	newTextField(win .. "typeMessage", line, "", "Type here your message", 300);
	newButton(win .. "sendMessage", line, "Send", sendMessage, "Blue");
	newButton(win .. "refresh", line, "Refresh", showFactionChat, "Green");
	newLabel(win .. "empty", vert, "\n");
	for i = #Mod.PublicGameData.Factions[Mod.PublicGameData.PlayerInFaction[game.Us.ID]].FactionChat, 1, -1 do
		local message = Mod.PublicGameData.Factions[Mod.PublicGameData.PlayerInFaction[game.Us.ID]].FactionChat[i];
		local line = newHorizontalGroup("line" .. i, vert);
		newLabel(win .. "player" .. i, line, game.Game.Players[message.Player].DisplayName(nil, false) .. ": ", game.Game.Players[message.Player].Color.HtmlColor, 200);
		newLabel(win .. "text" .. i, line, message.Text, game.Game.Players[message.Player].Color.HtmlColor);
	end
end

function sendMessage()
	local payload = {};
	payload.Type = "sendMessage";
	payload.Text = getText("showFactionChattypeMessage");
	game.SendGameCustomMessage("Sending message...", payload, gameCustomMessageReturn);
end

function createFaction()
	if Mod.PublicGameData.IsInFaction[game.Us.ID] then
		UI.Alert("You're already in a faction! You can only be in 1 faction at the time");
		return;
	end
	local win = "createFaction";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newTextField(win .. "FactionName", vert, "", "Enter your faction name here", 50);
	newButton(win .. "CreateFaction", vert, "Create Faction", function() verifyFactionName(getText(win .. "FactionName")); end, "Lime");
	newButton(win .. "Return", vert, "Return", showMenu, "Orange");
end

function verifyFactionName(name)
	for i, _ in pairs(Mod.PublicGameData.Factions) do
		if i == name then
			UI.Alert("This faction name already exists! Try a different name");
			return;
		end
	end
	local payload = {};
	payload.Type = "CreateFaction";
	payload.Name = name;
	game.SendGameCustomMessage("Creating Faction...", payload, gameCustomMessageReturn);
	Close();
end

function gameCustomMessageReturn(payload)
	if payload.Type == "Error" or payload.Type == "Success" then
		UI.Alert(payload.Type .. "\n" .. payload.Message);
	end
	local functions = {};
	functions["showFactionChat"] = showFactionChat;
	
	if payload.Function ~= nil then
		functions[payload.Function]();
	end
end

function getTableLength(t, func)
	local c = 0;
	for i, v in pairs(t) do
		if func ~= nil then
			if func(v) then
				c = c + 1;			
			end
		else
			c = c + 1;
		end
	end
	return c;
end