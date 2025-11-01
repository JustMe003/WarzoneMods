require("utilities2")

function Client_PresentSettingsUIMain()
	showMain();
end

function showMain()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetCenter(true));

	local header = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	if not tableIsEmpty(Mod.Settings.Configuration.Relations) then
		CreateButton(header).SetText("Slot Configuration").SetColor(colors.Orange).SetOnClick(showMainConfig);
	end
	CreateButton(header).SetText("Rules").SetColor(colors.Yellow).SetOnClick(function()
		showRules(showMain);
	end);
	CreateButton(header).SetText("Version").SetColor(colors.Red).SetOnClick(showVersionDetails);
	
	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Make all the events that happened public: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.VisibleHistory);
	end, "When on, every event (making peace, declaring war, joining a Faction) that occurs will be made visible for everyone. When off, only the events that the player, or a Faction member, participated in will be made visible");
	
	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Fair Factions: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.FairFactions);
	end, "When on, the mod will stop players from joining a Faction if this unbalances the game too much. When off, there is no restriction for players to join a Faction");

	if Mod.Settings.GlobalSettings.FairFactions then
		CreateInfoButtonLine(root, function(line)
			CreateEmpty(line).SetPreferredWidth(20);
			CreateLabel(line).SetText("Fair Factions modifier: ").SetColor(colors.TextColor);
			CreateLabel(line).SetText(math.floor((Mod.Settings.GlobalSettings.FairFactionsModifier * 10000 + 0.5) / 100) .. "%").SetColor(colors.Aqua);
		end, "To determine when a Faction is too strong, the mod calculates how much income the Faction members have combined and compares this to the total income of all players. When a player tries to join a Faction, the mod will check what the combined income of the Faction members + the player trying to join would be, and if this number is equal or higher than the percentage of the total income of all players, the player is not allowed to join the Faction");
	end

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("AIs can declare war on AIs: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.AICanDeclareOnAI);
	end, "When on, AIs can declare war on other AIs. When off they do not declare war on other AIs");

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("AIs can declare war on players: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.AICanDeclareOnPlayer);
	end, "When on, AIs can declare war on human players. When off, AIs cannot declare war on human players");

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Faction join requests must be approved: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.ApproveFactionJoins);
	end, "When on, players send a join request to a Faction. The Faction leader must then approve the join request. Only then the player is actually part of that Faction. When off, a player can immediately join a Faction");

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Lock pre-set Factions: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.LockPreSetFactions);
	end, "When on, any Faction that is created here in the mod configuration is locked. Players can always leave a locked Faction, but no one is able to join a locked Faction. When off, Factions created in the mod configuration are not locked and anyone can join them");

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Play spy card on all Faction members: ").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.PlaySpyOnFactionMembers);
	end, "When on, every turn the mod will automatically play a spy card for you on all players you are in a Faction with. When off, the mod will not play any spy card automatically");

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("All players start at war with each other").SetColor(colors.TextColor);
		createBoolLabel(line, Mod.Settings.GlobalSettings.PlayersStartAtWar);
	end, "Sets the default relation. When off, every player will start in peace with every other player. When on, every player will start at war with every other player. Note that the relations set in the configuration will have a higher priority than this value");
end

function showMainConfig()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetCenter(true).SetFlexibleWidth(1));

	AddToHistory(showMainConfig);

	CreateButton(root).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMain);

	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("NOTE: This dialog shows you the start configuration. If you want to see the current Factions/relations, you should use the mod menu").SetColor(colors.TextColor);
	
	CreateEmpty(root).SetPreferredHeight(5);

	if not tableIsEmpty(Mod.Settings.Configuration.Factions) then
		CreateLabel(root).SetText("Pre-set Factions").SetColor(colors.TextColor);
		for i, faction in pairs(Mod.Settings.Configuration.Factions) do
			CreateButton(root).SetText(i).SetColor(getColorFromList(faction.FactionLeader)).SetOnClick(function()
				showFactionConfig(i);
			end)
		end
	end

	CreateEmpty(root).SetPreferredHeight(5);

	if not tableIsEmpty(Mod.Settings.Configuration.Relations) then
		CreateLabel(root).SetText("Slots (non-listed slots all start with a peaceful relation with all players)").SetColor(colors.TextColor);
		line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
		local c = 0;
		for _, i in pairs(getSortedKeyList(Mod.Settings.Configuration.Relations)) do
			if c > 0 then
				CreateEmpty(line).SetPreferredWidth(10);
			end
			CreateButton(line).SetText(getSlotName(i)).SetColor(getColorFromList(i)).SetOnClick(function()
				showSlotConfig(i);
			end);
			c = c + 1;
			if c == 3 then
				line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
				c = 0;
			end
		end
	end
end

function showSlotConfig(slot)
	if slot == nil then return; end
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showSlotConfig, slot);

	local header = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)
	CreateButton(header).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(header).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);

	CreateEmpty(root).SetPreferredHeight(5);
	
	CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText(getSlotName(slot) .. " relation configuration").SetColor(colors.TextColor);
	
	if Mod.Settings.Configuration.SlotInFaction[slot] ~= nil and not tableIsEmpty(Mod.Settings.Configuration.SlotInFaction[slot]) then
		CreateLabel(root).SetText("This slot starts in Factions: ").SetColor(colors.TextColor);
		for _, faction in pairs(Mod.Settings.Configuration.SlotInFaction[slot]) do
			CreateButton(root).SetText(faction).SetColor(getColorFromList(Mod.Settings.Configuration.Factions[faction].FactionLeader)).SetOnClick(function()
				showFactionConfig(faction);
			end);
		end
	else
		CreateLabel(root).SetText("This slot does not start in a Faction").SetColor(colors.TextColor);
	end
	
	CreateEmpty(root).SetPreferredHeight(10);

	CreateLabel(root).SetText("Slot relations").SetColor(colors.TextColor);
	for _, i in pairs(getSortedKeyList(Mod.Settings.Configuration.Relations[slot])) do
		if i ~= slot then
			local v = Mod.Settings.Configuration.Relations[slot][i];
			line = CreateHorz(root).SetFlexibleWidth(1);
			CreateButton(line).SetText(getSlotName(i)).SetColor(getColorFromList(i)).SetOnClick(function()
				showSlotConfig(i);
			end);
			
			if v == "AtWar" then
				CreateLabel(line).SetText("War").SetColor(colors.Red);
			elseif v == "InPeace" then
				CreateLabel(line).SetText("Peace").SetColor(colors.Yellow);
			else
				CreateLabel(line).SetText("In Faction").SetColor(colors.Green);
			end
		end
	end
end

function showFactionConfig(faction)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showFactionConfig, faction);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);
	
	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Name: " .. faction).SetColor(colors.TextColor);

	local factionTable = Mod.Settings.Configuration.Factions[faction];
	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Faction leader: ").SetColor(colors.TextColor);
	CreateButton(line).SetText(getFactionLeader(faction)).SetColor(getColorFromList(factionTable.FactionLeader)).SetOnClick(function()
		showSlotConfig(factionTable.FactionLeader);
	end).SetInteractable(factionTable.FactionLeader ~= nil);

	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Slots in Faction " .. faction).SetColor(colors.TextColor);
	line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	local c = 0;
	for _, slot in pairs(getSortedValueList(factionTable.FactionMembers)) do
		if c > 0 then
			CreateEmpty(line).SetPreferredWidth(10);
		end
		CreateButton(line).SetText(getSlotName(slot)).SetColor(getColorFromList(slot)).SetOnClick(function()
			showSlotConfig(slot);
		end);
		c = c + 1;
		if c == 3 then
			line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
			c = 0;
		end
	end

	CreateEmpty(root).SetPreferredHeight(10);

	showFactionRelationConfig(root, faction);
end

function showFactionRelationConfig(root, faction)
	CreateLabel(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText(faction .. " relation configuration").SetColor(colors.TextColor);
	for i, bool in pairs(Mod.Settings.Configuration.Factions[faction].AtWar) do
		if i ~= faction then
			local line = CreateHorz(root).SetFlexibleWidth(1);
			if bool then
				CreateLabel(line).SetText("War").SetColor(colors.Red);
			else
				CreateLabel(line).SetText("Peace").SetColor(colors.Yellow);
			end
			CreateButton(line).SetText(i).SetColor(getColorFromList(Mod.Settings.Configuration.Factions[i].FactionLeader)).SetOnClick(function()
				showFactionConfig(i);
			end);
		end
	end
end

function getFactionLeader(faction)
	if Mod.Settings.Configuration.Factions[faction].FactionLeader ~= nil then
		return getSlotName(Mod.Settings.Configuration.Factions[faction].FactionLeader);
	else
		return "???";
	end
end

function createBoolLabel(par, b)
	CreateLabel(par).SetText(getBoolText(b)).SetColor(getBoolColor(b));
end

function getBoolText(b)
	if b then return "Yes"; else return "No"; end
end

function getBoolColor(b)
	if b then return colors.Green; else return colors.OrangeRed; end
end