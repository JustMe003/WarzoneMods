require("UI");
require("utilities2");
require("ForcedRules");
function Client_PresentMenuUIMain(rootParent, setMaxSize, setScrollable, Game, close, calledFromGameRefresh)
	init(rootParent);
	game = Game;
	if game.Us == nil then UI.Alert("You cannot use this mod since you're not playing in this game"); close(); return; end
--	if game.Us.State ~= WL.GamePlayerState.Playing then UI.Alert("You cannot use this mod anymore since you're not playing anymore"); close(); return; end
	if game.Game.TurnNumber < 1 then UI.Alert("This mod can only be used after the distribution turn"); close(); return; end
	if Mod.PublicGameData.VersionNumber == nil or Mod.PublicGameData.VersionNumber < 6 then UI.Alert("Hooray! An update! Unfortunately this game has to advance a turn first before you can use it again"); close(); return; end

	Close = function() pageHasClosed = true; close(); end;
	if Mod.PlayerGameData.PersonalSettings ~= nil then
		setMaxSize(Mod.PlayerGameData.PersonalSettings.WindowWidth, Mod.PlayerGameData.PersonalSettings.WindowHeight);
	else
		setMaxSize(500, 600);
	end
	if calledFromGameRefresh ~= nil then
		if func ~= nil and pageHasClosed ~= nil then
			func();
			func = nil;
			pageHasClosed = nil;
		else
			close();
		end
	else
		showMenu();
	end
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
		newButton(win .. "showFactionChat", vert, "Faction chat", showFactionChatOptions, "Orange", Mod.PublicGameData.IsInFaction[game.Us.ID]);
		newButton(win .. "createFactionButton", vert, "Create Faction", createFaction, "Lime", not(isFactionLeader(game.Us.ID)));
		newLabel(win .. "empty", vert, "\n");
		newButton(win .. "playerPage", vert, "Your relations", showPlayerPage, game.Us.Color.HtmlColor);
		newButton(win .. "ForcedRuls", vert, "Forced rules", function() forcedRulesInit(function() showMenu(); end) end, "Orange Red")
		newButton(win .. "ModHistory", vert, "History", showHistory, "Yellow");
		newButton(win .. "showPlayerSettings", vert, "Personal settings", showPlayerSettings, "Royal Blue");
		newButton(win .. "About", vert, "About", showAbout, "Lime");
		if game.Us.ID == 1311724 then
			newButton(win .. "ADMIN", vert, "ADMIN", function() showAdmin(Mod.PlayerGameData, showMenu) end, "Red");
		end
	end
end

function showAdmin(t, func)
	local win = "ADMIN";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "return", vert, "Return", func, "Orange");
	for i, v in pairs(t) do
		if type(v) == type({}) then
			newButton(win .. "table" .. i, vert, i, function() showAdmin(v, function() showAdmin(t, func); end); end, "Lime");
		else
			newLabel(win .. i, vert, i .. ": " .. tostring(v));
		end
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
	newButton(win .. "return", vert, "Return", showMenu, "Orange");
	newLabel(win .. "EmptyAfterReturn", vert, "");
	if Mod.PublicGameData.IsInFaction[game.Us.ID] then
		newLabel(win .. "PlayerFactionString", vert, "Your faction(s):");
		for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) do
			newButton(win .. "PF" .. faction, vert, faction, function() showFactionDetails(faction) end, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
		end
		newLabel(win .. "EmptyAfterPlayerFaction", vert, "\n\nOther factions");
	end
	for factionName, faction in pairs(Mod.PublicGameData.Factions) do
		if not valueInTable(Mod.PublicGameData.PlayerInFaction[game.Us.ID], factionName) then
			newButton(win .. factionName, vert, factionName, function() showFactionDetails(factionName) end, game.Game.Players[faction.FactionLeader].Color.HtmlColor);
		end
	end
end

function showPlayerPage(relation)
	local win = "showPlayerPage";
	if relation == nil then relation = "All"; end
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup(win .. "Line1", vert);
	newButton(win .. "PendingOffers", line, "Pending offers", showPendingOffers, "Cyan", Mod.PlayerGameData.PendingOffers ~= nil and getTableLength(Mod.PlayerGameData.PendingOffers) > 0);
	newButton(win .. "ChangeRelation", line, "Relation: " .. relation, function() showPlayerPage(changeRelationState(relation)); end, "Ivory");
	newButton(win .. "Return", line, "Return", showMenu, "Orange");
	newLabel(win .. "EmptyAfterReturn", vert, " ");
	for i, p in pairs(game.Game.PlayingPlayers) do
		if i ~= game.Us.ID then
			if (relation == "All") or (relation == "Hostile" and Mod.PublicGameData.Relations[game.Us.ID][i] == "AtWar") or (relation == "Peaceful" and Mod.PublicGameData.Relations[game.Us.ID][i] == "InPeace") or (relation == "Friendly" and Mod.PublicGameData.Relations[game.Us.ID][i] == "InFaction") then
				newButton(win .. i, vert, p.DisplayName(nil, false), function() showPlayerDetails(i) end, p.Color.HtmlColor);
			end
		end
	end
end

function showPendingOffers()
	local win = "showPendingOffers";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "return", vert, "Return", showPlayerPage, "Orange");
	newLabel(win .. "EmptyAfterReturn", vert, " ");
	for i, v in pairs(Mod.PlayerGameData.PendingOffers) do
		newButton(win .. i, vert, game.Game.Players[v].DisplayName(nil, false), function() func = function() showPendingOffers() end; confirmChoice("Do you wish to accept the peace offer from " .. game.Game.Players[v].DisplayName(nil, false) .. "?", function() Close(); game.SendGameCustomMessage("Accepting peace offer...", {Type="acceptPeaceOffer", Index=i}, gameCustomMessageReturn); showPlayerPage(); end, function() Close(); game.SendGameCustomMessage("Declining peace offer...", {Type="declinePeaceOffer", Index=i}, gameCustomMessageReturn); showPendingOffers(); end); end, game.Game.Players[v].Color.HtmlColor);
	end
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
	newLabel(win .. "name", vert, game.Game.PlayingPlayers[playerID].DisplayName(nil, false), game.Game.PlayingPlayers[playerID].Color.HtmlColor);
	if Mod.PublicGameData.IsInFaction[playerID] then
		newLabel(win .. "factionNameText", vert, "Faction(s): ");
		for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[playerID]) do
			newLabel(win .. "factionName", vert, faction, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
		end
		if Mod.PublicGameData.IsInFaction[game.Us.ID] then
			newLabel(win .. "factionRelation", vert, "Relation between factions: ");
			for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[playerID]) do
				for _, pFaction in pairs(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) do
					if faction ~= pFaction then
						local line = newHorizontalGroup(win .. "line" .. faction .. pFaction, vert);
						newButton(win .. "1" .. faction .. pFaction, line, faction, function() showFactionDetails(faction); end, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
						newLabel(win .. ":" .. faction .. pFaction, line, ": ");
						newButton(win .. "2" .. faction .. pFaction, line, pFaction, function() showFactionDetails(pFaction); end, game.Game.Players[Mod.PublicGameData.Factions[pFaction].FactionLeader].Color.HtmlColor);
						if Mod.PublicGameData.Factions[faction].AtWar[pFaction] then
							newLabel(win .. "factionRelationWar", line, "Hostile", "Red");
							isAtWarFromFaction = true;
						else
							newLabel(win .. "factionRelationPeace", line, "Peaceful", "Yellow");
						end
					end
				end
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
		newLabel(win .. "relationStatus", line, "Peaceful", "Yellow");
	else
		newLabel(win .. "relationStatus", line, "Friendly", "Green");
	end
	newLabel(win .. "EmptyAfterOpponentFaction", vert, "\n");
	if Mod.Settings.GlobalSettings.VisibleHistory then
		newButton(win .. "ViewPlayerRelations", vert, "View all relations of this player", function() viewPlayerRelations(playerID); end, "Royal Blue");
	end
	line = newHorizontalGroup(win .. "line2", vert);
	newButton(win .. "ToWar", line, "Declare war", function() confirmChoice("Do you really wish to go to war against " .. game.Game.Players[playerID].DisplayName(nil, false) .. "?", function() Close(); func = function() showPlayerDetails(playerID); end; game.SendGameCustomMessage("Declaring war...", { Type="declareWar", Opponent=playerID }, gameCustomMessageReturn); showPlayerDetails(playerID); end, function() showPlayerDetails(playerID) end); end, "Red", Mod.PublicGameData.Relations[game.Us.ID][playerID] == "InPeace" and (Mod.PlayerGameData.Cooldowns == nil or Mod.PlayerGameData.Cooldowns.WarDeclarations == nil or Mod.PlayerGameData.Cooldowns.WarDeclarations[playerID] == nil));
	newButton(win .. "offerPeace", line, "Offer peace", function() confirmChoice("Do you wish to offer peace to " .. game.Game.Players[playerID].DisplayName(nil, false) .. "?", function() Close(); func = function() showPlayerDetails(playerID); end; game.SendGameCustomMessage("Offering peace...", { Type="peaceOffer", Opponent=playerID }, gameCustomMessageReturn); showPlayerDetails(playerID); end, function() showPlayerDetails(playerID); end); end, "Green", not(isAtWarFromFaction) and Mod.PublicGameData.Relations[game.Us.ID][playerID] == "AtWar" and Mod.PlayerGameData.Offers[playerID] == nil);
	newButton(win .. "return", vert, "Return", showPlayerPage, "Orange");
end

function viewPlayerRelations(playerID, relation)
	local win = "viewPlayerRelations" .. playerID;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	if relation == nil then relation = "All"; end
	newLabel(win .. "exp", vert, "Here you can see every relation of " .. game.Game.Players[playerID].DisplayName(nil, false))
	local line = newHorizontalGroup("line0", vert);
	newButton(win .. "RelationFilter", line, "Relation: " .. relation, function() viewPlayerRelations(playerID, changeRelationState(relation)); end, "Ivory");
	newButton(win .. "return", line, "Return", function() showPlayerDetails(playerID); end, "Orange");
	newLabel(win .. "EmptyAfterReturn", vert, " ");
	for i, p in pairs(game.Game.PlayingPlayers) do
		if i ~= playerID then
			if (relation == "All") or (relation == "Hostile" and Mod.PublicGameData.Relations[playerID][i] == "AtWar") or (relation == "Peaceful" and Mod.PublicGameData.Relations[playerID][i] == "InPeace") or (relation == "Friendly" and Mod.PublicGameData.Relations[playerID][i] == "InFaction") then
				line = newHorizontalGroup("line" .. i, vert);
				newButton(win .. i, line, p.DisplayName(nil, false), function() showPlayerDetails(i) end, p.Color.HtmlColor);
				if Mod.PublicGameData.Relations[i][playerID] == "AtWar" then
					newLabel(win .. i .. "relationStatus", line, "\tHostile", "Red");
				elseif Mod.PublicGameData.Relations[i][playerID] == "InPeace" then
					newLabel(win .. i .. "relationStatus", line, "\tPeaceful", "Yellow");
				else
					newLabel(win .. i .. "relationStatus", line, "\tFriendly", "Green");
				end
			end
		end
	end
end

function showFactionDetails(factionName)
	if Mod.PublicGameData.Factions[factionName] == nil then showFactions(); return; end
	local win = "showFactionDetails" .. factionName;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup(win .. "line", vert);
	local bool = valueInTable(Mod.PublicGameData.PlayerInFaction[game.Us.ID], factionName);
	newButton(win .. "LeaveFaction", line, "Leave Faction", function() confirmChoice("Are you sure you want to leave the '" .. factionName .. "' faction?", function() Close(); func = function() showFactionDetails(factionName); end; game.SendGameCustomMessage("Leaving faction...", {Type="leaveFaction", Faction=factionName}, gameCustomMessageReturn); Close(); end, function() showFactionDetails(factionName); end); end, "Red", bool);
	newButton(win .. "JoinFaction", line, "Join Faction", function() confirmChoice("Do you wish to join the '" .. factionName .. "' faction? If this faction is in war with any other faction you'll automatically declare war on them.", function() Close(); func = function() showFactionDetails(factionName); end; game.SendGameCustomMessage("Joining faction...", {Type="joinFaction", PlayerID=game.Us.ID, Faction=factionName}, gameCustomMessageReturn); Close(); end, function() showFactionDetails(factionName); end); end, "Green", not valueInTable(Mod.PublicGameData.PlayerInFaction[game.Us.ID], factionName) and not (Mod.PlayerGameData.HasPendingRequest ~= nil and valueInTable(Mod.PlayerGameData.HasPendingRequest, factionName)) and not(Mod.Settings.GlobalSettings.LockPreSetFactions and Mod.PublicGameData.Factions[factionName].PreSetFaction ~= nil) and (Mod.PlayerGameData.Cooldowns == nil or Mod.PlayerGameData.Cooldowns.FactionJoins == nil or Mod.PlayerGameData.Cooldowns.FactionJoins[factionName] == nil));
	newButton(win .. "return", line, "Return", showFactions, "Orange");
	newLabel(win .. "EmptyAfterButtonLine", vert, " ");
	if Mod.PublicGameData.Factions[factionName].PreSetFaction ~= nil and Mod.Settings.GlobalSettings.LockPreSetFactions then
		newLabel(win .. "PreSetFactionText", vert, "This faction was made by the game creator. They have configured this mod so that you cannot join this faction");
	end
	if Mod.PlayerGameData.HasPendingRequest ~= nil and valueInTable(Mod.PlayerGameData.HasPendingRequest, factionName) then
		newLabel(win .. "HasPendingRequest", vert, "You currently have a pending join request for this faction");
		newButton(win .. "PendingRequestCancelButton", vert, "Cancel request", function() confirmChoice("Do you want to cancel your join request?", function() Close(); func = function() showFactionDetails(factionName); end; game.SendGameCustomMessage("Cancelling request...", {Type="requestCancel", Faction=factionName}, gameCustomMessageReturn); showFactionDetails(factionName); end, function() showFactionDetails(factionName); end); end, game.Us.Color.HtmlColor);
	end
	newLabel(win .. "label", vert, factionName, game.Game.Players[Mod.PublicGameData.Factions[factionName].FactionLeader].Color.HtmlColor);
	newLabel(win .. "EmptyAfterFactionName", vert, " ");
	newButton(win .. "ViewFactionRelations", vert, "View Faction relations", function() viewFactionRelations(factionName); end, "Orange Red");
	if game.Us.ID == Mod.PublicGameData.Factions[factionName].FactionLeader then
		newButton(win .. "FactionSettings", vert, "Faction settings", function() factionSettings(factionName) end, "Tyrian Purple");
		if Mod.Settings.GlobalSettings.ApproveFactionJoins then
			newButton(win .. "pendingJoinRequests", vert, "Join requests", function() pendingJoinRequests(factionName); end, "Royal Blue", #Mod.PublicGameData.Factions[factionName].JoinRequests > 0);
		end
		newLabel(win .. "EmptyAfterFactionsettings", vert, "\n");
	end
	newLabel(win .. "FactionLeader", vert, "Faction leader: " .. game.Game.Players[Mod.PublicGameData.Factions[factionName].FactionLeader].DisplayName(nil, false) .. "\n", game.Game.Players[Mod.PublicGameData.Factions[factionName].FactionLeader].Color.HtmlColor);
	newLabel(win .. "PlayersInFaction", vert, "The following players are in this faction: ");
	for i, v in ipairs(Mod.PublicGameData.Factions[factionName].FactionMembers) do
		line = newHorizontalGroup(win .. "line" .. i, vert);
		newLabel(win .. i .. v, line, i .. ". " .. game.Game.Players[v].DisplayName(nil, false), game.Game.Players[v].Color.HtmlColor);
		if Mod.PublicGameData.Factions[factionName].FactionLeader == game.Us.ID and v ~= game.Us.ID then
			newButton(win .. i .. "kick", line, "Kick", function() confirmChoice("Do you really wish to kick " .. game.Game.Players[v].DisplayName(nil, false) .. " from your faction?", function() Close(); func = function() showFactionDetails(factionName); end; game.SendGameCustomMessage("Kicking player...", {Type="kickPlayer", Index=i, Player=v, Faction=factionName}, gameCustomMessageReturn); showFactions(); end, function() showFactionDetails(factionName); end); end, "Red");
			newButton(win .. i .. "Promote", line, "Promote", function() confirmChoice("Do you really wish to promote " .. game.Game.Players[v].DisplayName(nil, false) .. "? You will lose your role as faction leader", function() Close(); func = function() showFactionDetails(factionName); end; game.SendGameCustomMessage("Promoting player...", {Type="setFactionLeader", PlayerID=v, Faction=factionName}, gameCustomMessageReturn); end, function() showFactionDetails(factionName); end); end, "Orange");
		end
	end
end

function viewFactionRelations(factionName)
	local win = "showFactionRelations" .. factionName;
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup("lineReturn", "vert");
	newButton(win .. "label", line, factionName, function() end, game.Game.Players[Mod.PublicGameData.Factions[factionName].FactionLeader].Color.HtmlColor);
	newButton(win .. "return", line, "Return", function() showFactionDetails(factionName); end, "Orange");
	newLabel(win .. "emptyAFterLabel", vert, "\n");
	for f, b in pairs(Mod.PublicGameData.Factions[factionName].AtWar) do
		line = newHorizontalGroup("line" .. f, vert);
		if b then
			newButton(win .. f .. "war", line, f, function() showFactionDetails(f); end, game.Game.Players[Mod.PublicGameData.Factions[f].FactionLeader].Color.HtmlColor);
			newLabel(win .. f .. "relation", line, "\tHostile", "Orange Red");
		else
			newButton(win .. f .. "war", line, f, function() showFactionDetails(f); end, game.Game.Players[Mod.PublicGameData.Factions[f].FactionLeader].Color.HtmlColor);
			newLabel(win .. f .. "relation", line, "\tPeaceful", "Yellow");
		end
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
	if Mod.Settings.GlobalSettings.ApproveFactionJoins then
		newButton(win .. "pendingJoinRequests", vert, "Join requests", function() pendingJoinRequests(factionName); end, "Royal Blue", #Mod.PublicGameData.Factions[factionName].JoinRequests > 0);
	end
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
	newButton(win .. "Return", vert, "Return", function() showFactionDetails(factionName); end, "Orange");
	newLabel(win .. "text", vert, "Pick a faction to go to war with them:");
	for faction, bool in pairs(Mod.PublicGameData.Factions[factionName].AtWar) do
		if not(bool) then
			local line = newHorizontalGroup(faction .. "line", vert);
			newButton(win .. faction .. "name", line, faction, function() showFactionDetails(faction); end, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
			newButton(win .. faction .. "button", line, "To War!", function() confirmChoice("Are you sure you want to declare war on " .. faction .. "? All your faction members will be forced to declare war on all of the players in " .. faction, function() Close(); func = function() declareFactionWar(factionName); end; game.SendGameCustomMessage("Declaring war on " .. faction .. "...", { Type="declareFactionWar", PlayerFaction=factionName, OpponentFaction=faction }, gameCustomMessageReturn); factionSettings(factionName); end, function() declareFactionWar(factionName); end) end, "Red", not valueInTable(Mod.PublicGameData.Factions[faction].FactionMembers, game.Us.ID));
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
	newButton(win .. "Return", vert, "Return", function() showFactionDetails(factionName); end, "Orange");
	newLabel(win .. "text", vert, "Pick a faction to ask for peace with them:");
	for faction, bool in pairs(Mod.PublicGameData.Factions[factionName].AtWar) do
		if bool and Mod.PublicGameData.Factions[factionName].Offers[faction] == nil then
			local line = newHorizontalGroup(faction .. "line", vert);
			newButton(win .. faction .. "name", line, faction, function() showFactionDetails(faction); end, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
			newButton(win .. faction .. "button", line, "Peace", function() confirmChoice("Are you sure you want to offer peace to " .. faction .. "? All your faction members will be forced in peace with all of the players in " .. faction, function() Close(); func = function() offerFactionPeace(factionName); end; game.SendGameCustomMessage("Offering peace to " .. faction .. "...", { Type="offerFactionPeace", OpponentFaction=faction, PlayerFaction=factionName }, gameCustomMessageReturn); factionSettings(factionName); end, function() offerFactionPeace(factionName); end) end, "Green");
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
	newButton(win .. "Return", vert, "Return", function() showFactionDetails(factionName); end, "Orange");
	newLabel(win .. "n", vert, "You have " .. #Mod.PublicGameData.Factions[factionName].PendingOffers .. " peace offers");
	for i, v in pairs(Mod.PublicGameData.Factions[factionName].PendingOffers) do
		newButton(win .. i, vert, v, function() func = function() pendingFactionPeaceOffers(factionName); end; confirmChoice("Do you wish to accept the peace offer from the '" .. v .. "' faction?", function() Close(); game.SendGameCustomMessage("Accepting peace offer...", { Type="acceptFactionPeaceOffer", Index=i, PlayerFaction=factionName, OfferFrom=v}, gameCustomMessageReturn); factionSettings(factionName); end, function() Close(); game.SendGameCustomMessage("Declining peace offer...", {Type="declineFactionPeaceOffer", Index=i, PlayerFaction=factionName, OfferFrom=v}, gameCustomMessageReturn); factionSettings(factionName); end); end, game.Game.Players[Mod.PublicGameData.Factions[v].FactionLeader].Color.HtmlColor);
	end
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

function showFactionChatOptions()
	local win = "showFactionChatOptions";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newLabel(win .. "pickFaction", vert, "Choose the faction you want to read the messages from");
	for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) do
		newButton(win .. faction, vert, faction .. " (" .. getAmountOfChatMessages(faction) .. ")", function() showFactionChat(faction); end, game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor);
	end
	newLabel(win .. "empty", vert, " ");
	newButton(win .. "Return", vert, "Return", showMenu, "Orange");
end

function showFactionChat(faction)
	local win = "showFactionChat";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup("line", vert);
	newTextField(win .. "typeMessage", line, "Type here your message", "", 300, true, 300, -1, 1, 0);
	newButton(win .. "sendMessage", line, "Send", function() sendMessage(faction); end, "Blue");
	newButton(win .. "refresh", line, "Refresh", function() showFactionChat(faction); end, "Green");
	newButton(win .. "Return", line, "Return", showFactionChatOptions, "Orange");
	newLabel(win .. "empty", vert, "\n");
	for i = #Mod.PublicGameData.Factions[faction].FactionChat, 1, -1 do
		local message = Mod.PublicGameData.Factions[faction].FactionChat[i];
		line = newHorizontalGroup("line" .. i, vert);
		newButton(win .. "player" .. i, line, game.Game.Players[message.Player].DisplayName(nil, false) .. ": ", function() end, game.Game.Players[message.Player].Color.HtmlColor, true, -1, -1, 1, 1);
		newLabel(win .. "text" .. i, line, message.Text);
	end
end

function pendingJoinRequests(factionName)
	local win = "pendingJoinRequests";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "Return", vert, "Return", function() factionSettings(factionName); end, "Orange");
	newLabel(win .. "EmptyAfterReturn", vert, "");
	for i, v in pairs(Mod.PublicGameData.Factions[factionName].JoinRequests) do
		newButton(win .. i, vert, game.Game.Players[v].DisplayName(nil, false), function() func = function() pendingJoinRequests(factionName); end; confirmChoice("Do you wish to let " .. game.Game.Players[v].DisplayName(nil, false) .. " join your faction?", function() Close(); game.SendGameCustomMessage("Accepting request...", {Type="joinFaction", PlayerID=v, Faction=factionName, RequestApproved=true}, gameCustomMessageReturn); factionSettings(factionName); end, function() Close(); game.SendGameCustomMessage("Declining request...", {Type="DeclineJoinRequest", Index=i, PlayerID=v, Faction=factionName}, gameCustomMessageReturn); factionSettings(factionName); end); end, game.Game.Players[v].Color.HtmlColor);
	end
end 

function sendMessage(faction)
	if objectsID["showFactionChattypeMessage"] ~= nil and objects[objectsID["showFactionChattypeMessage"]].Object ~= nil then
		local payload = {};
		payload.Type = "sendMessage";
		payload.Faction = faction;
		payload.Text = getText("showFactionChattypeMessage");
		if #payload.Text > 0 then
			Close();
			func = function() showFactionChat(faction); end;
			game.SendGameCustomMessage("Sending message...", payload, gameCustomMessageReturn);
		else
			UI.Alert("You cannot send an empty message!");
		end
	else
		UI.Alert("Something went wrong. Please re-open the chat to try again. If this message keeps popping up, please contact me");
	end
end

function createFaction()
	local win = "createFaction";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newTextField(win .. "FactionName", vert, "Enter your faction name here", "", 50, true, 300, -1, 1, 0);
	newButton(win .. "CreateFaction", vert, "Create Faction", function() verifyFactionName(getText(win .. "FactionName")); end, "Lime");
	newButton(win .. "Return", vert, "Return", showMenu, "Orange");
end

function showPlayerSettings()
	local settings = Mod.PlayerGameData.PersonalSettings;
	if settings == nil then
		settings = {};
		settings.WindowWidth = 500;
		settings.WindowHeight = 600;
	end
	local win = "showPlayerSettings";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "return", vert, "Return", showMenu, "Orange");
	newLabel(win .. "windowWidthText", vert, "Your preferred window width");
	local windowWidth = newNumberField(win .. "windowWidth", vert, 300, 1000, settings.WindowWidth);
	newLabel(win .. "windowHeigthText", vert, "Your preferred window height");
	local windowHeight = newNumberField(win .. "windowHeight", vert, 300, 1000, settings.WindowHeight);
	newButton(win .. "UpdateSettings", vert, "Update settings", function() Close(); func = function() showPlayerSettings(); end; game.SendGameCustomMessage("Updating Settings...", {Type="updateSettings", WindowHeight=getValue(windowHeight), WindowWidth=getValue(windowWidth)}, gameCustomMessageReturn); end, "Green");
end

function showHistory()
	local win = "showHistory";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "return", vert, "Return", showMenu, "Orange");
	if Mod.PublicGameData.VersionNumber ~= nil and Mod.PublicGameData.VersionNumber >= 5 then
		if Mod.Settings.GlobalSettings.VisibleHistory then
			newLabel(win .. "explanation", vert, "Here you can see all the events that took place between now and the previous turn.");
		else
			newLabel(win .. "explanation", vert, "Here you can see the events that took place between now and the previous turn. You can only see the events that have effect on you of on one of your faction members (if you're in a faction)");
		end
		newLabel(win .. "empty", vert, "The events have the same color of the player who triggered them\n");
		for i = 1, #Mod.PublicGameData.Events do
			if Mod.Settings.GlobalSettings.VisibleHistory or Mod.PublicGameData.Events[i].VisibleTo == nil or valueInTable(Mod.PublicGameData.Events[i].VisibleTo, game.Us.ID) then
				newLabel(win .. i, vert, Mod.PublicGameData.Events[i].Message, getColorPlayerIsNotNeutral(Mod.PublicGameData.Events[i].PlayerID));
			end
		end
	else
		newLabel(win .. "VersionToLow", vert, "Due to an update this feature is not available till the update is done and your game has advanced a turn.");
	end
end

function showAbout()
	local win = "showAbout";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "return", vert, "Return", showMenu, "Orange");
	newLabel(win .. "text1", vert, "Hello, good to see you've browsed to this page. Here you can find additional information about this mod, together with a bunch of other stuff.\n", "Orange");
	newLabel(win .. "Essentials", vert, "Essentials", "Lime");
	newLabel(win .. "text2", vert, "This mod is very large and can be complex for the first couple of times you use it. Luckily for you I've documented (almost) everyting, explaining how things work and how to use them. The easiest way to read the documentation is in the Essentials mod. The Essentials mod its only usage is the ability to read through mod manuals whenever you want. \n\nIs the Essentials mod not included in your game? You can help me and the community out by telling the game creator about it so they can included it into their next game. But I do have a link for you that will take you to a google document with the documentation for this mod");
	newTextField(win .. "ProjectELink", vert, "", "https://docs.google.com/document/d/1qbUxFYOrLL-ZN-yzUpEqNfQjePixV675zwZwXhfhhFU/edit#heading=h.u26jcdcpnsdn", 0, true, 300, -1, 1, 1);
	newLabel(win .. "text3", vert, "\nIf there is anything else you want to contact me about (bugs, issues, questions, suggestions) you can message me via Warzone, with the link below:");
	newTextField(win .. "SendMailToMe", vert, "", "https://www.warzone.com/Discussion/SendMail?PlayerID=1311724", 0, true, 300, -1, 1, 1);
	newLabel(win .. "text4", vert, "\nLastly, I want to shout out the players who helped me develop this mod. I couldn't do this without them:\n - JK_3\n - KingEridani\n - UnFairerOrb76\n - Zazzlegut\n - Tread\n - krinid\n - Lord Hotdog\n - Samek\n - καλλιστηι\n - SirFalse");
end

function verifyFactionName(name)
	for i, _ in pairs(Mod.PublicGameData.Factions) do
		if i == name then
			UI.Alert("This faction name already exists! Try a different name");
			return;
		end
	end
	if string.len(name) < 2 or string.len(name) > 50 then
		UI.Alert("'" .. name .. "' must be between 2 and 50 characters");
		return;
	end
	local payload = {};
	payload.Type = "CreateFaction";
	payload.Name = name;
	Close();
	func = function() showFactionDetails(name); end
	game.SendGameCustomMessage("Creating Faction...", payload, gameCustomMessageReturn);
end

function changeRelationState(relation)
	if relation == "All" then
		relation = "Hostile";
	elseif relation == "Hostile" then
		relation = "Peaceful"
	elseif relation == "Peaceful" then
		relation = "Friendly";
	else
		relation = "All";
	end
	return relation;
end

function gameCustomMessageReturn(payload)
	if payload.Type == "Fail" or payload.Type == "Success" then
		UI.Alert(payload.Type .. "\n" .. payload.Message);
	end
	local functions = {};
	functions["showFactionChat"] = showFactionChatOptions;
	
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

function getColorPlayerIsNotNeutral(p)
	if p == WL.PlayerID.Neutral then
		return "#DDDDDD";
	end
	return game.Game.Players[p].Color.HtmlColor
end

function getAmountOfChatMessages(f)
	if Mod.PlayerGameData.Notifications ~= nil then
		if Mod.PlayerGameData.Notifications.Messages ~= nil then
			if Mod.PlayerGameData.Notifications.Messages[f] ~= nil then
				return #Mod.PlayerGameData.Notifications.Messages[f];
			end
		end
	end
	return 0;
end