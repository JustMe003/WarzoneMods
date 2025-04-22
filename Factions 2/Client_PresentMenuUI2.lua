require("utilities2");

---@param rootParent any
---@param setMaxSize any
---@param setScrollable any
---@param Game GameClientHook
---@param close any
---@param calledFromGameRefresh any
function Client_PresentMenuUIMain(rootParent, setMaxSize, setScrollable, Game, close, calledFromGameRefresh)
	game = Game;
	if game.Us == nil then UI.Alert("You cannot use this mod since you're not playing in this game"); close(); return; end
	if game.Us.State ~= WL.GamePlayerState.Playing then UI.Alert("You cannot use this mod anymore since you're not playing anymore"); close(); return; end
	if game.Game.TurnNumber < 1 then UI.Alert("This mod can only be used after the distribution turn"); close(); return; end
	
	Close = function() pageHasClosed = true; close(); end;
	if Mod.PlayerGameData.PersonalSettings ~= nil then
		setMaxSize(Mod.PlayerGameData.PersonalSettings.WindowWidth, Mod.PlayerGameData.PersonalSettings.WindowHeight);
	else
		setMaxSize(500, 600);
	end
	if calledFromGameRefresh ~= nil then
		GetPreviousWindow();
	else
		showMenu();
	end
end

function showMenu()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showMenu);
	
	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Factions").SetColor(colors.Cyan).SetOnClick(showFactions);
	CreateButton(line).SetText("Offers").SetColor(colors.Yellow).SetOnClick(showPendingOffers).SetInteractable(Mod.PlayerGameData.PendingOffers ~= nil and getTableLength(Mod.PlayerGameData.PendingOffers) > 0);
	if Mod.PublicGameData.IsInFaction[game.Us.ID] and #Mod.PublicGameData.PlayerInFaction[game.Us.ID] > 0 then
		CreateButton(line).SetText("Chat").SetColor(colors.ElectricPurple).SetOnClick(showFactionChatOptions);
	end
	CreateButton(line).SetText("Events").SetColor(colors.Ivory).SetOnClick(showHistory);
	CreateButton(line).SetText("Settings").SetColor(colors.Green).SetOnClick(showPlayerSettings);
	CreateButton(line).SetText("Version").SetColor(colors.Red).SetOnClick(showRules);
	CreateEmpty(root).SetPreferredHeight(10);
	if game.Us.ID == 1311724 then
		CreateButton(root).SetText("ADMIN").SetOnClick(function() showAdmin(Mod.PlayerGameData, showMenu) end);
	end

	showPlayerPage(root);
end


function showAdmin(t, func)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));
	CreateButton(root).SetText("Go back").SetColor(colors.Orange).SetOnClick(func);
	for i, v in pairs(t) do
		if type(v) == type({}) then
			CreateButton(root).SetText(i).SetOnClick(function() showAdmin(v, function() showAdmin(t, func); end); end);
		else
			CreateLabel(root).SetText(i .. ": " .. tostring(v)).SetColor(colors.TextColor);
		end
	end
end

function showFactions()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showFactions);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);
	CreateButton(line).SetText("Create Faction").SetColor(colors.Aqua).SetOnClick(createFaction)
	
	CreateEmpty(root).SetPreferredHeight(10);

	if Mod.PublicGameData.IsInFaction[game.Us.ID] then
		CreateLabel(root).SetText("Your Faction(s): ").SetColor(colors.TextColor);
		for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) do
			CreateButton(root).SetText(faction).SetColor(game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor).SetOnClick(function()
				showFactionDetails(faction);
			end);
		end
	end

	CreateEmpty(root).SetPreferredHeight(10);

	if Mod.PublicGameData.IsInFaction[game.Us.ID] then
		CreateLabel(root).SetText("Other Factions").SetColor(colors.TextColor);
	else
		CreateLabel(root).SetText("Factions").SetColor(colors.TextColor);
	end
	for factionName, faction in pairs(Mod.PublicGameData.Factions) do
		if not valueInTable(Mod.PublicGameData.PlayerInFaction[game.Us.ID], factionName) then
			CreateButton(root).SetText(factionName).SetColor(game.Game.Players[faction.FactionLeader].Color.HtmlColor).SetOnClick(function()
				showFactionDetails(factionName);
			end);
		end
	end
end

function showPlayerPage(root)
	local relations = getSortedRelationLists(game.Us.ID);

	if #relations.War > 0 then
		CreateLabel(root).SetText("You are at war with the following players").SetColor(colors.TextColor);
		for _, p in pairs(relations.War) do
			CreateButton(root).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(p.ID);
			end);
		end

		CreateEmpty(root).SetPreferredHeight(5);
	end

	if #relations.Peace > 0 then
		CreateLabel(root).SetText("You are at peace with the following players").SetColor(colors.TextColor);
		for _, p in pairs(relations.Peace) do
			CreateButton(root).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(p.ID);
			end);
		end
		
		CreateEmpty(root).SetPreferredHeight(5);
	end
	
	if #relations.Faction > 0 then
		CreateLabel(root).SetText("You are in a Faction with the following players").SetColor(colors.TextColor);
		for _, p in pairs(relations.Faction) do
			CreateButton(root).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(p.ID);
			end);
		end
	end
end

function showPendingOffers()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showPendingOffers);

	local line = CreateHorz(root).SetCenter(true);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);
	
	CreateEmpty(root).SetPreferredHeight(10);
	
	if Mod.PlayerGameData.PendingOffers and #Mod.PlayerGameData.PendingOffers > 0 then
		CreateLabel(root).SetText("The following players have send you a peace offer").SetColor(colors.TextColor);
		for i, v in pairs(Mod.PlayerGameData.PendingOffers) do
			CreateButton(root).SetText(game.Game.Players[v].DisplayName(nil, true)).SetColor(game.Game.Players[v].Color.HtmlColor).SetOnClick(function()
				confirmChoice("Do you wish to accept the peace offer from " .. game.Game.Players[v].DisplayName(nil, true) .. "?", function() 
					Close();
					AddToHistory(void);
					game.SendGameCustomMessage("Accepting peace offer...", {Type="acceptPeaceOffer", Index=i}, gameCustomMessageReturn); 
					showPlayerPage();
				end, function() 
					Close(); 
					AddToHistory(void);
					game.SendGameCustomMessage("Declining peace offer...", {Type="declinePeaceOffer", Index=i}, gameCustomMessageReturn); 
					showPendingOffers();
				end);
			end);
		end
	else
		CreateLabel(root).SetText("You have no pending peace offers at the moment").SetColor(colors.TextColor);
	end
end

function showPlayerDetails(playerID)
	local player = game.Game.Players[playerID];
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showPlayerDetails, playerID);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);

	CreateEmpty(root).SetPreferredHeight(5);
	
	line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Details of ").SetColor(colors.TextColor);
	CreateButton(line).SetText(player.DisplayName(nil, true)).SetColor(player.Color.HtmlColor);
	
	CreateEmpty(root).SetPreferredHeight(10);

	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Your relation with this player: ").SetColor(colors.TextColor);
	local relLabel = CreateLabel(line);
	local relButton;
	if Mod.PublicGameData.Relations[playerID][game.Us.ID] == Relations.War then
		relLabel.SetText("Hostile").SetColor(colors.OrangeRed);
		CreateEmpty(line).SetFlexibleWidth(1);
		relButton = CreateButton(line).SetText("Offer peace").SetColor(colors.Yellow).SetOnClick(function()
			confirmChoice("Do you wish to send " .. game.Game.Players[playerID].DisplayName(nil, true) .. " a peace offer?", function()
				Close();
				AddToHistory(void);
				game.SendGameCustomMessage("Offering peace...", {Type="peaceOffer", Opponent=playerID}, gameCustomMessageReturn);
			end, function()
				showPlayerDetails(playerID);
			end);
		end).SetInteractable(not Mod.PlayerGameData.Offers[playerID]);
		if Mod.PlayerGameData.Offers[playerID] then
			if valueInTable(Mod.PlayerGameData.PendingOffers, playerID) then
				line = CreateHorz(root).SetFlexibleWidth(1);
				CreateLabel(line).SetText("You have a pending peace offer from this player").SetColor(colors.TextColor).SetFlexibleWidth(1).SetAlignment(WL.TextAlignmentOptions.Right);
				CreateButton(line).SetText("Resolve").SetColor(colors.Green).SetOnClick(function()
					confirmChoice("Do you wish to accept the peace offer from " .. player.DisplayName(nil, true); .. "?", function() 
						Close();
						AddToHistory(void);
						game.SendGameCustomMessage("Accepting peace offer...", {Type="acceptPeaceOffer", Index=i}, gameCustomMessageReturn); 
						showPlayerPage();
					end, function() 
						Close(); 
						AddToHistory(void);
						game.SendGameCustomMessage("Declining peace offer...", {Type="declinePeaceOffer", Index=i}, gameCustomMessageReturn); 
						showPendingOffers();
					end);
				end);
			else
				CreateLabel(root).SetText("You have send this player a peace offer").SetColor(colors.TextColor).SetFlexibleWidth(1).SetAlignment(WL.TextAlignmentOptions.Right);
			end
		end
	elseif Mod.PublicGameData.Relations[playerID][game.Us.ID] == Relations.Peace then
		relLabel.SetText("Peaceful").SetColor(colors.Yellow);
		CreateEmpty(line).SetFlexibleWidth(1);
		CreateButton(line).SetText("Declare war").SetColor(colors.Red).SetOnClick(function()
			confirmChoice("Do you wish to go to war with " .. game.Game.Players[playerID].DisplayName(nil, true) .. "?", function()
				Close();
				AddToHistory(void);
				game.SendGameCustomMessage("Picking up the battle-axe", {Type="declareWar", Opponent=playerID}, gameCustomMessageReturn);
			end, function()
				showPlayerDetails(playerID);
			end);
		end);
	else
		relLabel.SetText("Faction member").SetColor(colors.Green);
	end

	CreateEmpty(root).SetPreferredHeight(8);
	local isFactionWar = false;
	if Mod.PublicGameData.IsInFaction[playerID] then
		CreateInfoButtonLine(root, function(l)
			CreateLabel(l).SetText("Factions of player: ").SetColor(colors.TextColor);
		end, "The relation labels next to the factions indicate what your relation is with respect to that faction. These depend on the factions you are in. If you are also a member of that faction, you will see the label 'faction member'. If the faction is at war with at least one of your factions, you will see the label 'hostile' next to it. Otherwise the label will say 'peaceful'");
		for _, factionName in pairs(Mod.PublicGameData.PlayerInFaction[playerID]) do
			local t = Mod.PublicGameData.Factions[factionName];
			line = CreateHorz(root);
			CreateButton(line).SetText(factionName).SetColor(game.Game.Players[t.FactionLeader].Color.HtmlColor).SetOnClick(function()
				showFactionDetails(factionName);
			end);
			local rel = Relations.Peace;
			for _, usFactionName in pairs(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) do
				if factionName == usFactionName then
					rel = Relations.Faction;
					break;
				elseif t.AtWar[usFactionName] then
					rel = Relations.War;
					isFactionWar = true;
					break;
				end
			end
			local lab = CreateLabel(line);
			if rel == Relations.War then
				lab.SetText("Hostile").SetColor(colors.OrangeRed);
			elseif rel == Relations.Peace then
				lab.SetText("Peaceful").SetColor(colors.Yellow);
			else
				lab.SetText("Faction member").SetColor(colors.Green);
			end
		end
	else
		CreateLabel(root).SetText("This player is not in a Faction").SetColor(colors.TextColor);
	end

	if isFactionWar then
		relButton.SetInteractable(false);
	end

	CreateEmpty(root).SetPreferredHeight(5);
	
	if Mod.Settings.GlobalSettings.VisibleHistory then
		viewPlayerRelations(playerID, root);
	else
		CreateLabel(root).SetText("Since the settings 'Visible History' has been turned off, you cannot view the relations of this player").SetColor(colors.TextColor);
	end
end

function viewPlayerRelations(playerID, root)
	local relations = getSortedRelationLists(playerID);

	CreateLabel(root).SetText("Relations").SetColor(colors.TextColor);
	if #relations.War > 0 then
		CreateLabel(root).SetText("This player is at war with the following players").SetColor(colors.TextColor);
		for _, p in pairs(relations.War) do
			local line = CreateHorz(root);
			CreateButton(line).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(p.ID);
			end).SetInteractable(p.ID ~= game.Us.ID);
		end
		CreateEmpty(root).SetPreferredHeight(5);
	end

	if #relations.Peace > 0 then
		CreateLabel(root).SetText("This player is in peace with the following players").SetColor(colors.TextColor);
		for _, p in pairs(relations.Peace) do
			local line = CreateHorz(root);
			CreateButton(line).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(p.ID);
			end).SetInteractable(p.ID ~= game.Us.ID);
		end
		CreateEmpty(root).SetPreferredHeight(5);
	end

	if #relations.Faction > 0 then
		CreateLabel(root).SetText("This player is in a Faction with the following players").SetColor(colors.TextColor);
		for _, p in pairs(relations.Faction) do
			local line = CreateHorz(root);
			CreateButton(line).SetText(p.DisplayName(nil, true)).SetColor(p.Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(p.ID);
			end).SetInteractable(p.ID ~= game.Us.ID);
		end
		CreateEmpty(root).SetPreferredHeight(5);
	end
end


function showFactionDetails(factionName)
	if Mod.PublicGameData.Factions[factionName] == nil then showFactions(); return; end
	local faction = Mod.PublicGameData.Factions[factionName];
	
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));
	local playerIsInFaction = valueInTable(Mod.PublicGameData.PlayerInFaction[game.Us.ID], factionName);

	AddToHistory(showFactionDetails, factionName);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);
	if playerIsInFaction then
		CreateButton(line).SetText("Leave").SetColor(colors.Red).SetOnClick(function()
			confirmChoice("Are you sure you want to leave the '" .. factionName .. "' faction?", function() 
				Close(); 
				AddToHistory(void);
				game.SendGameCustomMessage("Leaving faction...", {Type="leaveFaction", Faction=factionName}, gameCustomMessageReturn); 
			end, function() 
				showFactionDetails(factionName);
			end);
		end);
		CreateButton(line).SetText("Chat").SetColor(colors.ElectricPurple).SetOnClick(function() showFactionChat(factionName) end)
	else
		CreateButton(line).SetText("Join").SetColor(colors.Green).SetOnClick(function()
			confirmChoice("Do you wish to join the '" .. factionName .. "' faction? If this faction is in war with any other faction you'll automatically declare war on them.", function() 
				Close();
				AddToHistory(void);
				game.SendGameCustomMessage("Joining faction...", {Type="joinFaction", PlayerID=game.Us.ID, Faction=factionName}, gameCustomMessageReturn); 
			end, function()
				showFactionDetails(factionName);
			end);
		end).SetInteractable((not faction.PreSetFaction or not Mod.Settings.GlobalSettings.LockPreSetFactions) and not (Mod.PlayerGameData.HasPendingRequest and Mod.PlayerGameData.HasPendingRequest[factionName]));
	end
	if faction.FactionLeader == game.Us.ID then
		CreateButton(line).SetText("Requests").SetColor(colors.Aqua).SetOnClick(function()
			factionSettings(factionName);
		end);
	end

	CreateEmpty(root).SetPreferredHeight(10);
	
	if faction.PreSetFaction ~= nil and Mod.Settings.GlobalSettings.LockPreSetFactions then
		CreateLabel(root).SetText("This faction was made by the game creator. They have configured this mod so that you cannot join this faction").SetColor(colors.TextColor);
		CreateEmpty(root).SetPreferredHeight(5);
	end

	if Mod.PlayerGameData.HasPendingRequest ~= nil and Mod.PlayerGameData.HasPendingRequest == factionName then
		CreateLabel(root).SetText("You currently have a pending join request for this faction").SetColor(colors.TextColor);
		CreateButton(root).SetText("Cancel request").SetColor(colors.OrangeRed).SetOnClick(function()
			confirmChoice("Do you want to cancel your join request?", function() 
				Close(); 
				AddToHistory(void);
				game.SendGameCustomMessage("Cancelling request...", {Type="requestCancel", Faction=factionName}, gameCustomMessageReturn); 
				showFactionDetails(factionName); 
			end, function() 
				showFactionDetails(factionName); 
			end); 
		end);
		CreateEmpty(root).SetPreferredHeight(5);
	end
	
	CreateLabel(root).SetText(factionName).SetColor(colors.TextColor);
	
	line = CreateHorz(root);
	CreateLabel(line).SetText("Faction leader: ").SetColor(colors.TextColor);
	CreateButton(line).SetText(game.Game.Players[faction.FactionLeader].DisplayName(nil, true)).SetColor(game.Game.Players[faction.FactionLeader].Color.HtmlColor).SetOnClick(function()
		showPlayerDetails(faction.FactionLeader);
	end);

	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("The following players are in this Faction: ").SetColor(colors.TextColor);
	for i, v in ipairs(faction.FactionMembers) do
		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText(i .. ". ").SetColor(colors.TextColor);
		CreateButton(line).SetText(game.Game.Players[v].DisplayName(nil, true)).SetColor(game.Game.Players[v].Color.HtmlColor).SetOnClick(function()
			showPlayerDetails(v);
		end);
		if Mod.PublicGameData.Factions[factionName].FactionLeader == game.Us.ID and v ~= game.Us.ID then
			CreateEmpty(line).SetFlexibleWidth(1).SetPreferredWidth(20);
			CreateButton(line).SetText("Kick").SetColor(colors.Red).SetOnClick(function()
				confirmChoice("Do you really wish to kick " .. game.Game.Players[v].DisplayName(nil, true) .. " from your faction?", function() 
					Close();
					AddToHistory(void);
					game.SendGameCustomMessage("Kicking player...", {Type="kickPlayer", Index=i, Player=v, Faction=factionName}, gameCustomMessageReturn);
				end, function() 
					showFactionDetails(factionName); 
				end); 
			end);
			CreateButton(line).SetText("Promote").SetColor(colors.Orange).SetOnClick(function()
				confirmChoice("Do you really wish to promote " .. game.Game.Players[v].DisplayName(nil, true) .. "? You will lose your role as faction leader", function() 
					Close();
					AddToHistory(void);
					game.SendGameCustomMessage("Promoting player...", {Type="setFactionLeader", PlayerID=v, Faction=factionName}, gameCustomMessageReturn); 
				end, function()
					showFactionDetails(factionName);
				end); 
			end);
		end
	end

	if getTableLength(Mod.PublicGameData.Factions) > 1 then
		CreateEmpty(root).SetPreferredHeight(5);

		CreateLabel(root).SetText("Relations of this Faction").SetColor(colors.TextColor);
		if playerIsInFaction and game.Us.ID ~= faction.FactionLeader then
			CreateLabel(root).SetText("Only the Faction leader can change the relation between this and another Faction").SetColor(colors.TextColor);
		end
		for name, otherFaction in pairs(Mod.PublicGameData.Factions) do
			if name ~= factionName then
				line = CreateHorz(root).SetFlexibleWidth(1);
				CreateButton(line).SetText(name).SetColor(game.Game.Players[otherFaction.FactionLeader].Color.HtmlColor).SetOnClick(function()
					showFactionDetails(name);
				end);
				local facRelLabel = CreateLabel(line);
				if faction.AtWar[name] then
					facRelLabel.SetText("Hostile").SetColor(colors.Red);
				else
					facRelLabel.SetText("Peaceful").SetColor(colors.Yellow);
				end
				if faction.FactionLeader == game.Us.ID then
					CreateEmpty(line).SetFlexibleWidth(1).SetPreferredWidth(20);
					local but = CreateButton(line);
					if faction.AtWar[name] then
						but.SetText("Offer peace").SetColor(colors.Yellow).SetOnClick(function()
							confirmChoice("Are you sure you want to offer peace to " .. name .. "? All your faction members will be forced in peace with all of the players in " .. name, function() 
								AddToHistory(void);
								Close(); 
								game.SendGameCustomMessage("Offering peace to " .. name .. "...", { Type="offerFactionPeace", OpponentFaction=name, PlayerFaction=factionName }, gameCustomMessageReturn); 	
							end, function() 
								showFactionDetails(factionName); 
							end)
						end).SetInteractable(not (faction.Offers and faction.Offers[name]));
					else
						but.SetText("Declare war").SetColor(colors.Red).SetOnClick(function()
							confirmChoice("Are you sure you want to declare war on " .. name .. "? All your faction members will be forced to declare war on all of the players in " .. name, function() 
								AddToHistory(void);
								Close(); 
								game.SendGameCustomMessage("Declaring war on " .. name .. "...", { Type="declareFactionWar", PlayerFaction=factionName, OpponentFaction=name }, gameCustomMessageReturn); 
							end, function() 
								showFactionDetails(factionName);
							end)
						end);
					end
				end
			end
		end
	end
end

function factionSettings(factionName)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(factionSettings, factionName);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);
	
	CreateEmpty(root).SetPreferredHeight(10);

	if #Mod.PublicGameData.Factions[factionName].PendingOffers > 0 then
		CreateLabel(root).SetText("Your Faction has pending peace offers from the following Factions").SetColor(colors.TextColor);
		for i, name in pairs(Mod.PublicGameData.Factions[factionName].PendingOffers) do
			line = CreateHorz(root).SetFlexibleWidth(1);
			CreateButton(line).SetText(name).SetColor(game.Game.Players[Mod.PublicGameData.Factions[name].FactionLeader].Color.HtmlColor).SetOnClick(function()
				showFactionDetails(name);
			end);
			CreateEmpty(line).SetFlexibleWidth(1).SetPreferredWidth(20);
			CreateButton(line).SetText("Accept").SetColor(colors.Green).SetOnClick(function()
				confirmChoice("Do you wish to accept the peace offer from the '" .. name .. "' faction?", function() 
					AddToHistory(void);
					Close(); 
					game.SendGameCustomMessage("Accepting peace offer...", { Type="acceptFactionPeaceOffer", Index=i, PlayerFaction=factionName}, gameCustomMessageReturn); 
					factionSettings(factionName); 
				end, function() 
					factionSettings(factionName); 
				end); 
			end);
			CreateButton(line).SetText("Decline").SetColor(colors.Red).SetOnClick(function()
				confirmChoice("Do you wish to decline the peace offer from the '" .. name .. "' faction?", function() 
					AddToHistory(void);
					Close();
					game.SendGameCustomMessage("Declining peace offer...", {Type="declineFactionPeaceOffer", Index=i, PlayerFaction=factionName}, gameCustomMessageReturn); 
				end, function() 
					factionSettings(factionName); 
				end); 
			end);
		end
	else
		CreateLabel(root).SetText("Your Faction does not have any pending peace offers").SetColor(colors.TextColor);
	end

	CreateEmpty(root).SetPreferredHeight(5);

	if Mod.Settings.GlobalSettings.ApproveFactionJoins and #Mod.PublicGameData.Factions[factionName].JoinRequests > 0 then
		CreateLabel(root).SetText("Your Faction has the following join requests from players").SetColor(colors.TextColor);
		for index, i in pairs(Mod.PublicGameData.Factions[factionName].JoinRequests) do
			line = CreateHorz(root).SetFlexibleWidth(1);
			CreateButton(line).SetText(game.Game.Players[i].DisplayName(nil, true)).SetColor(game.Game.Players[i].Color.HtmlColor).SetOnClick(function()
				showPlayerDetails(i);
			end);
			CreateEmpty(line).SetFlexibleWidth(1).SetPreferredWidth(20);
			CreateButton(line).SetText("Accept").SetColor(colors.Green).SetOnClick(function()
				confirmChoice("Do you wish to accept the join request of " .. game.Game.Players[i].DisplayName(nil, true) .. "?", function()
					AddToHistory(void);
					Close();
					game.SendGameCustomMessage("Accepting join request...", {Type = "joinFaction", PlayerID = i, Faction = factionName, RequestApproved = true}, gameCustomMessageReturn);
				end, function()
					factionSettings(factionName);
				end);
			end);
			CreateButton(line).SetText("Reject").SetColor(colors.Red).SetOnClick(function()
				confirmChoice("Do you wish to reject the join request of " .. game.Game.Players[i].DisplayName(nil, true) .. "?", function()
					AddToHistory(void);
					Close();
					game.SendGameCustomMessage("Rejecting join request...", {Type = "DeclineJoinRequest", PlayerID = i, Faction = factionName, Index = index}, gameCustomMessageReturn);
				end, function()
					factionSettings(factionName);
				end);
			end);
		end
	end
end


function confirmChoice(message, yesFunc, noFunc)
	DestroyWindow()
	local root = CreateWindow(CreateVert(GlobalRoot));

	CreateLabel(root).SetText(message).SetColor(colors.TextColor);
	
	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Yes!").SetColor(colors.Green).SetOnClick(yesFunc);
	CreateButton(line).SetText("No...").SetColor(colors.Red).SetOnClick(noFunc);
end


function showFactionChatOptions()
	if #Mod.PublicGameData.PlayerInFaction[game.Us.ID] == 1 then
		showFactionChat(Mod.PublicGameData.PlayerInFaction[game.Us.ID][1]);
		return;
	end

	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showFactionChatOptions);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);

	CreateLabel(root).SetText("Pick the faction you want to enter the chat from").SetColor(colors.TextColor);
	for _, faction in pairs(Mod.PublicGameData.PlayerInFaction[game.Us.ID]) do
		line = CreateHorz(root);
		CreateButton(line).SetText(faction).SetColor(game.Game.Players[Mod.PublicGameData.Factions[faction].FactionLeader].Color.HtmlColor).SetOnClick(function()
			showFactionChat(faction);
		end);
		CreateLabel(line).SetText(getAmountOfChatMessages(faction) .. " new messages").SetColor(colors.TextColor);
	end
end

function showFactionChat(faction)
	game.SendGameCustomMessage("updating mod...", { Type="openedChat", Faction=faction }, gameCustomMessageReturn);

	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showFactionChat, faction);

	local messageInput = CreateTextInputField(root).SetText("").SetPlaceholderText("Type here your message").SetCharacterLimit(300).SetPreferredWidth(300).SetFlexibleWidth(1);
	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Send").SetColor(colors.Blue).SetOnClick(function()
		if #messageInput.GetText() < 1 then
			UI.Alert("You must enter something to send as a chat message");
			return;
		end
		Close();
		AddToHistory(void);
		local payload = {
			Type = "sendMessage",
			Text = messageInput.GetText(),
			Faction = faction,
			TimeStamp = game.Game.ServerTime
		};
		game.SendGameCustomMessage("Sending message...", payload, gameCustomMessageReturn);
	end);
	CreateButton(line).SetText("Refresh").SetColor(colors.Green).SetOnClick(function()
		showFactionChat(faction);
	end);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);

	CreateEmpty(root).SetPreferredHeight(5);
	for i = #Mod.PublicGameData.Factions[faction].FactionChat, 1, -1 do
		local message = Mod.PublicGameData.Factions[faction].FactionChat[i];
		line = CreateHorz(root).SetFlexibleWidth(1);
		if message.TimeStamp then
			CreateLabel(line).SetText(string.sub(message.TimeStamp, 6, -8):gsub(" ", "\n")).SetColor(colors.TextColor).SetAlignment(WL.TextAlignmentOptions.Center).SetMinWidth(45);
		end
		CreateButton(line).SetText(shortenPlayerName(game.Game.Players[message.Player].DisplayName(nil, true))).SetColor(game.Game.Players[message.Player].Color.HtmlColor).SetMinWidth(33);
		CreateLabel(line).SetText(message.Text).SetColor(colors.TextColor);
	end
end

function shortenPlayerName(name)
	if #name > 3 then
		return string.sub(name, 1, 3);
	end
	return name;
end

function createFaction()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	
	local factionInput = CreateTextInputField(root).SetText("").SetPlaceholderText("Enter your faction name here").SetCharacterLimit(50).SetPreferredWidth(300).SetFlexibleWidth(1);
	local line = CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMenu);
	CreateButton(line).SetText("Create Faction").SetColor(colors.Green).SetOnClick(function()
		verifyFactionName(factionInput.GetText());
	end);
end

function showPlayerSettings()
	local settings = Mod.PlayerGameData.PersonalSettings;

	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMenu);
	local but = CreateButton(line).SetText("Update settings").SetColor(colors.Green);
	CreateButton(line).SetText("About").SetColor(colors.RoyalBlue).SetOnClick(showAbout);

	CreateLabel(root).SetText("Your preferred window width").SetColor(colors.TextColor);
	local windowWidth = CreateNumberInputField(root).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(settings.WindowWidth);
	CreateLabel(root).SetText("Your preferred window height").SetColor(colors.TextColor);
	local windowHeight = CreateNumberInputField(root).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(settings.WindowHeight);

	but.SetOnClick(function()
		Close(); 
		AddToHistory(void);
		game.SendGameCustomMessage("Updating Settings...", {Type="updateSettings", WindowHeight=windowHeight.GetValue(), WindowWidth=windowWidth.GetValue()}, gameCustomMessageReturn);
	end);
end

function showHistory()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMenu);
	
	CreateEmpty(root).SetPreferredHeight(10);

	if Mod.PublicGameData.VersionNumber ~= nil and Mod.PublicGameData.VersionNumber >= 5 then
		if Mod.Settings.GlobalSettings.VisibleHistory then
			CreateLabel(root).SetText("Here you can see all the events that took place between now and the previous turn.").SetColor(colors.TextColor);
		else
			CreateLabel(root).SetText("Here you can see the events that took place between now and the previous turn. You can only see the events that have effect on you of on one of your faction members (if you're in a faction)").SetColor(colors.TextColor);
		end
		CreateLabel(root).SetText("The events have the same color of the player who triggered them").SetColor(colors.TextColor);
		showEvents(root, Mod.PublicGameData.Events);
	else
		CreateLabel(root).SetText("Due to an update this feature is not available till the update is done and your game has advanced a turn").SetColor(colors.TextColor);
	end

	if Mod.PublicGameData.EventsHistory then
		local eventsHistory = Mod.PublicGameData.EventsHistory;
		CreateEmpty(root).SetPreferredHeight(10);
		CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Events history").SetColor(colors.RoyalBlue);
		CreateEmpty(root).SetPreferredHeight(5);
		CreateLabel(root).SetText("Select a turn below to see all the events in that turn").SetColor(colors.TextColor);

		local start = 999999;
		for turn, _ in pairs(eventsHistory) do
			start = math.min(start, turn);
		end

		for i = game.Game.TurnNumber - 1, start, -1 do
			local buttonLine = CreateHorz(root);
			local line = CreateHorz(root);
			CreateEmpty(line).SetMinWidth(20);
			local localRoot;
			local but = CreateButton(buttonLine).SetText("Show turn " .. i).SetColor(colors.Ivory);
			but.SetOnClick(function()
				if UI.IsDestroyed(localRoot) then
					but.SetText("Close turn " .. i);
					localRoot = CreateVert(line);
					CreateLabel(localRoot).SetText("Events in turn " .. i).SetColor(colors.TextColor);
					CreateEmpty(localRoot).SetPreferredHeight(5);
					showEvents(localRoot, eventsHistory[i]);
				else
					but.SetText("Show turn " .. i);
					UI.Destroy(localRoot);
				end
			end);
			CreateEmpty(buttonLine).SetPreferredWidth(5);
			CreateLabel(buttonLine).SetText(countEvents(eventsHistory[i]) .. " events");
		end
	end
end

function showEvents(root, events)
	for _, event in ipairs(events) do
		if eventIsVisible(event) then
			local line = CreateHorz(root);
			CreateButton(line).SetText(" ").SetColor(getColorPlayerIsNotNeutral(event.PlayerID));
			CreateLabel(line).SetText(event.Message).SetColor(colors.TextColor);
		end
	end
end

function countEvents(events)
	local c = 0;
	for _, event in ipairs(events) do
		if eventIsVisible(event) then
			c = c + 1;
		end
	end
	return c;
end

function eventIsVisible(event)
	return Mod.Settings.GlobalSettings.VisibleHistory or event.VisibleTo == nil or valueInTable(event.VisibleTo, game.Us.ID) or game.Game.State == WL.GameState.Finished;
end

function showAbout()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMenu);

	CreateEmpty(root).SetPreferredHeight(10);

	CreateLabel(root).SetText("Welcome to the Factions mod!").SetColor(colors.TextColor);
	-- newLabel(win .. "Essentials", vert, "Essentials", "Lime");
	-- newLabel(win .. "text2", vert, "This mod is very large and can be complex for the first couple of times you use it. Luckily for you I've documented (almost) everyting, explaining how things work and how to use them. The easiest way to read the documentation is in the Essentials mod. The Essentials mod its only usage is the ability to read through mod manuals whenever you want. \n\nIs the Essentials mod not included in your game? You can help me and the community out by telling the game creator about it so they can included it into their next game. But I do have a link for you that will take you to a google document with the documentation for this mod");
	-- newTextField(win .. "ProjectELink", vert, "", "https://docs.google.com/document/d/1qbUxFYOrLL-ZN-yzUpEqNfQjePixV675zwZwXhfhhFU/edit#heading=h.u26jcdcpnsdn", 0, true, 300, -1, 1, 1);
	CreateLabel(root).SetText("If there is anything you want to contact me about (bugs, issues, questions, suggestions) you can message me via Warzone, with the link below:").SetColor(colors.TextColor);
	CreateTextInputField(root).SetText("https://www.warzone.com/Discussion/SendMail?PlayerID=1311724").SetPreferredWidth(300);
	CreateLabel(root).SetText("Here is also a shout out to all the wonderful players who helped me develop this mod throughout the years. \n - JK_3\n - KingEridani\n - UnFairerOrb76\n - Zazzlegut\n - Tread\n - krinid\n - Lord Hotdog\n - Samek\n - καλλιστηι\n - SirFalse\n - And you, for reading this ;)").SetColor(colors.TextColor);
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
				if type(Mod.PlayerGameData.Notifications.Messages[f]) == "table" then
					return #Mod.PlayerGameData.Notifications.Messages[f];
				else
					return Mod.PlayerGameData.Notifications.Messages[f];
				end
			end
		end
	end
	return 0;
end

function getSortedRelationLists(playerID)
	local t = {
		War = {};
		Peace = {};
		Faction = {};
	};

	for i, p in pairs(game.Game.PlayingPlayers) do
		if i ~= playerID then
			if Mod.PublicGameData.Relations[playerID][i] == Relations.War then
				table.insert(t.War, p);
			elseif Mod.PublicGameData.Relations[playerID][i] == Relations.Peace then
				table.insert(t.Peace, p);
			else
				table.insert(t.Faction, p);
			end
		end
	end

	local sortFunc = function(a, b)
		return a.DisplayName(nil, true) < b.DisplayName(nil, true);
	end;

	table.sort(t.War, sortFunc);
	table.sort(t.Peace, sortFunc);
	table.sort(t.Faction, sortFunc);

	return t;
end