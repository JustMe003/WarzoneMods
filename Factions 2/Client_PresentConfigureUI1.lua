require("utilities1");


function Client_PresentConfigureUIMain()
	config = Mod.Settings.Configuration
	if config == nil then 
		config = {}; 
		config.Factions = {};
		config.SlotInFaction = {};
		config.Relations = {};
	end
	settings = Mod.Settings.GlobalSettings;
	if settings == nil then
		settings = {};
		settings.VisibleHistory = false;
		settings.AICanDeclareOnPlayer = false;
		settings.AICanDeclareOnAI = false;
		settings.FairFactions = false;
		settings.FairFactionsModifier = 0.5;
		settings.ApproveFactionJoins = false;
		settings.LockPreSetFactions = false;
	end
	showMain();
end

function showMain()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetCenter(true).SetFlexibleWidth(1));
	
	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Configuration").SetColor(colors.Lime).SetOnClick(function()
		saveSettings();
		showMainConfig();
	end);
	CreateButton(line).SetText("Rules").SetColor(colors.Yellow).SetOnClick(function()
		saveSettings();
		showRules(showMain);
	end);
	CreateButton(line).SetText("Version").SetColor(colors.OrangeRed).SetOnClick(function()
		saveSettings();
		showVersionDetails();
	end);

	showSettings(root);
end

function showSettings(root)
	CreateInfoButtonLine(root, function(line)
		VisibleHistory = CreateCheckBox(line).SetText(" ").SetIsChecked(settings.VisibleHistory);
		CreateLabel(line).SetText("Make all the events that happened public").SetColor(colors.TextColor);
	end, "When checked, every event (making peace, declaring war, joining a Faction) that occurs will be made visible for everyone. When not checked, only the events that the player, or a Faction member, participated in will be made visible");

	local fairFacMod = "fairFacMod";
	local fairFacLine;
	local fairFacFunc = function()
		if FairFactions.GetIsChecked() then
			local vert = CreateSubWindow(CreateVert(fairFacLine).SetFlexibleWidth(1), fairFacMod);

			CreateInfoButtonLine(vert, function(line2)
				CreateLabel(line2).SetText("Fair Factions modifier").SetColor(colors.TextColor);
			end, "To determine when a Faction is too strong, the mod calculates how much income the Faction members have combined and compares this to the total income of all players. When a player tries to join a Faction, the mod will check what the combined income of the Faction members + the player trying to join would be, and if this number is equal or higher than the percentage of the total income of all players, the player is not allowed to join the Faction");
			FairFactionsModifier = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(100).SetWholeNumbers(false).SetValue(settings.FairFactionsModifier * 100);
		else
			if canReadObject(FairFactionsModifier) then settings.FairFactionsModifier = FairFactionsModifier.GetValue() / 100; end
			DestroyWindow(fairFacMod);
		end
	end
	CreateInfoButtonLine(root, function(line)
		FairFactions = CreateCheckBox(line).SetText(" ").SetIsChecked(settings.FairFactions).SetOnValueChanged(fairFacFunc);
		CreateLabel(line).SetText("Fair Factions").SetColor(colors.TextColor);
	end, "When checked, the mod will stop players from joining a Faction if this unbalances the game too much. When not checked, there is no restriction for players to join a Faction");
	fairFacLine = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(fairFacLine).SetPreferredWidth(20);
	fairFacFunc();

	CreateInfoButtonLine(root, function(line)
		AICanDeclareOnAI = CreateCheckBox(line).SetText(" ").SetIsChecked(settings.AICanDeclareOnAI);
		CreateLabel(line).SetText("AIs can declare war on AIs").SetColor(colors.TextColor);
	end, "When checked, AIs can declare war on other AIs. When not checked they do not declare war on other AIs");

	CreateInfoButtonLine(root, function(line)
		AICanDeclareOnPlayer = CreateCheckBox(line).SetText(" ").SetIsChecked(settings.AICanDeclareOnPlayer);
		CreateLabel(line).SetText("AIs can declare war on players").SetColor(colors.TextColor);
	end, "When checked, AIs can declare war on human players. When not checked, AIs cannot declare war on human players");

	CreateInfoButtonLine(root, function(line)
		ApproveFactionJoins = CreateCheckBox(line).SetText(" ").SetIsChecked(settings.ApproveFactionJoins);
		CreateLabel(line).SetText("Faction join requests must be approved").SetColor(colors.TextColor);
	end, "When checked, players send a join request to a Faction. The Faction leader must then approve the join request. Only then the player is actually part of that Faction. When not checked, a player can immediately join a Faction");

	CreateInfoButtonLine(root, function(line)
		LockPreSetFactions = CreateCheckBox(line).SetText(" ").SetIsChecked(settings.LockPreSetFactions);
		CreateLabel(line).SetText("Lock pre-set Factions").SetColor(colors.TextColor);
	end, "When checked, any Faction that is created here in the mod configuration is locked. Players can always leave a locked Faction, but no one is able to join a locked Faction. When not checked, Factions created in the mod configuration are not locked and anyone can join them");
end

function saveSettings()
	if canReadObject(VisibleHistory) then settings.VisibleHistory = VisibleHistory.GetIsChecked(); end
	if canReadObject(AICanDeclareOnPlayer) then settings.AICanDeclareOnPlayer = AICanDeclareOnPlayer.GetIsChecked(); end
	if canReadObject(AICanDeclareOnAI) then settings.AICanDeclareOnAI = AICanDeclareOnAI.GetIsChecked(); end
	if canReadObject(FairFactions) then settings.FairFactions = FairFactions.GetIsChecked(); end
	if canReadObject(ApproveFactionJoins) then settings.ApproveFactionJoins = ApproveFactionJoins.GetIsChecked(); end
	if canReadObject(LockPreSetFactions) then settings.LockPreSetFactions = LockPreSetFactions.GetIsChecked(); end
	if canReadObject(FairFactionsModifier) then
		settings.FairFactionsModifier = math.min(math.max(FairFactionsModifier.GetValue() / 100, 0), 1);
	else
		settings.FairFactionsModifier = settings.FairFactionsModifier or 0.5;
	end
end

function showMainConfig()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showMainConfig);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Create Faction").SetColor(colors.Lime).SetOnClick(addFaction);
	CreateButton(line).SetText("Add slot").SetColor(colors.Aqua).SetOnClick(function()
		pickSlot(function(slot)
			initSlotRelations(slot);
			showSlotConfig(slot);
		end, showMainConfig)
	end);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMain);

	CreateEmpty(root).SetPreferredHeight(5);

	if getTableLength(config.Factions) > 0 then
		CreateLabel(root).SetText("Factions:").SetColor(colors.TextColor);
	end
	for name, faction in pairs(config.Factions) do
		CreateButton(root).SetText(name).SetColor(getColorFromList(faction.FactionLeader)).SetOnClick(function()
			showFactionConfig(name);
		end);
	end

	CreateEmpty(root).SetPreferredHeight(5);

	if getTableLength(config.Relations) > 0 then
		CreateLabel(root).SetText("Slots:").SetColor(colors.TextColor);
		line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
		local c = 0;
		for _, slot in pairs(getSortedKeyList(config.Relations)) do
			if c > 0 then
				CreateEmpty(line).SetPreferredWidth(10);
			end
			CreateButton(line).SetText(getSlotName(slot)).SetColor(getColorFromList(slot)).SetOnClick(function()
				showSlotConfig(slot);
			end);
			c = c + 1;
			if c >= 3 then
				line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
				c = 0;
			end
		end
	end
end

function addFaction()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
	
	CreateButton(root).SetText("Go back").SetColor(colors.Orange).SetOnClick(showMainConfig);
	
	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("Enter the name of the Faction").SetColor(colors.TextColor);
	local nameInput = CreateTextInputField(root).SetPlaceholderText("Enter Faction name").SetText("").SetCharacterLimit(50).SetPreferredWidth(300);
	CreateButton(CreateHorz(root).SetCenter(true)).SetText("Create Faction").SetColor(colors.Lime).SetOnClick(function()
		createFaction(nameInput.GetText());
	end);
end

function pickSlot(selectFun, cancelFun)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

	CreateButton(CreateHorz(root).SetCenter(true)).SetText("Go back").SetColor(colors.Orange).SetOnClick(cancelFun);

	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("Please enter the name of the slot").SetColor(colors.TextColor);
	local nameInput = CreateTextInputField(root).SetPlaceholderText("Enter slot name here").SetText("").SetCharacterLimit(10).SetPreferredWidth(200);
	CreateButton(CreateHorz(root).SetCenter(true)).SetText("Submit").SetColor(colors.Lime).SetOnClick(function()
		local name = nameInput.GetText();
		if validateSlotName(name) then
			selectFun(getSlotIndex(name));
		else
			UI.Alert("A slot name must contain only letters (a-z), without the word 'Slot' before it");
		end
	end);
end

function showSlotConfig(slot)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showSlotConfig, slot);
	
	initSlotRelations(slot);

	local header = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(header).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(header).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);

	CreateEmpty(root).SetPreferredHeight(5);
	
	CreateLabel(root).SetText(getSlotName(slot) .. " configuration").SetColor(colors.TextColor);
	if config.SlotInFaction[slot] ~= nil then
		local line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Faction: ").SetColor(colors.TextColor);
		CreateButton(line).SetText(config.SlotInFaction[slot]).SetColor(getColorFromList(config.Factions[config.SlotInFaction[slot]].FactionLeader)).SetOnClick(function()
			showFactionConfig(config.SlotInFaction[slot]);
		end);
	end
	
	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("Relations:").SetColor(colors.TextColor);
	local slotRelations = config.Relations[slot];
	for _, i in pairs(getSortedKeyList(config.Relations[slot])) do
		local v = slotRelations[i];
		if i ~= slot then
			local line = CreateHorz(root).SetFlexibleWidth(1).SetPreferredWidth(200);
			CreateButton(line).SetText(getSlotName(i)).SetColor(getColorFromList(i)).SetOnClick(function()
				showSlotConfig(i);
			end);
	
			local but;
			local func = function()
				if config.Relations[slot][i] == Relations.War then
					config.Relations[slot][i] = Relations.Peace; 
					config.Relations[i][slot] = Relations.Peace;
	
					but.SetText("Peace").SetColor(colors.Yellow);
				elseif config.Relations[slot][i] == Relations.Peace then
					config.Relations[slot][i] = Relations.War; 
					config.Relations[i][slot] = Relations.War;
	
					but.SetText("War").SetColor(colors.Red);
				end
			end
			if v == Relations.War then
				but = CreateButton(line).SetText("War").SetColor(colors.Red).SetOnClick(func).SetInteractable(not isFactionWar(slot, i));
				if isFactionWar(slot, i) then
					CreateEmpty(line).SetFlexibleWidth(1);
					CreateButton(line).SetText("?").SetColor(colors.RoyalBlue).SetOnClick(function()
						UI.Alert("This relation cannot be changed because " .. getSlotName(slot) .. " and " .. getSlotName(i) .. " are in a Faction war. If a Faction is at war with another Faction, all members of those Factions are forced to have a hostile relationship");
					end);
				end
			elseif v == Relations.Peace then
				but = CreateButton(line).SetText("Peace").SetColor(colors.Yellow).SetOnClick(func);
			elseif v == Relations.Faction then
				but = CreateButton(line).SetText("In Faction").SetColor(colors.Green).SetInteractable(false);
				CreateEmpty(line).SetFlexibleWidth(1);
				CreateButton(line).SetText("?").SetColor(colors.RoyalBlue).SetOnClick(function()
					UI.Alert("This relation cannot be changed because " .. getSlotName(slot) .. " and " .. getSlotName(i) .. " are in the same Faction. When 2 players are in same Faction, they have a 'friendly' relationship which cannot change while they are in the same Faction");
				end);
			else
				CreateLabel(line).SetText("Something went wrong. Please contact the mod creater").SetColor(colors.Red);
			end
		end
	end
end

function createFaction(faction)
	if config.Factions[faction] ~= nil then
		UI.Alert(faction .. " already exists");
		addFaction();
	else
		local t = {}
		for i, _ in pairs(config.Factions) do
			t[i] = false;
			config.Factions[i].AtWar[faction] = false;
		end
		config.Factions[faction] = {};
		config.Factions[faction].FactionMembers = {};
		config.Factions[faction].AtWar = t;
		config.Factions[faction].PreSetFaction = true;
		showFactionConfig(faction);
	end
end

function showFactionConfig(faction)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));

	AddToHistory(showFactionConfig, faction);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go back").SetColor(colors.Orange).SetOnClick(GetPreviousWindow);
	CreateButton(line).SetText("Home").SetColor(colors.Green).SetOnClick(GetFirstWindow);
	CreateButton(line).SetText("Delete").SetColor(colors.Red).SetOnClick(function()
		confirmChoice("Do you wish to delete Faction " .. faction .. "?", function() 
			deleteFaction(faction); 
			GetPreviousWindow();
		end, function()
			showFactionConfig(faction); 
		end);
	end);

	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText(faction .. " configuration").SetColor(colors.TextColor);

	line = CreateHorz(root).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Faction leader: ").SetColor(colors.TextColor);
	CreateButton(line).SetText(getFactionLeader(faction)).SetColor(getColorFromList(config.Factions[faction].FactionLeader)).SetOnClick(function()
		pickForFactionLeader(faction);
	end);

	CreateEmpty(root).SetPreferredHeight(5);

	CreateLabel(root).SetText("Faction members (click to remove a slot):").SetColor(colors.TextColor);
	line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	local c = 0;
	for i, v in pairs(config.Factions[faction].FactionMembers) do
		if c > 0 then
			CreateEmpty(line).SetPreferredWidth(10);
		end
		CreateButton(line).SetText(getSlotName(v)).SetColor(getColorFromList(v)).SetOnClick(function()
			removeSlotFromFaction(faction, i, v);
			showFactionConfig(faction);
		end);
		c = c + 1;
		if c == 3 then
			c = 0;
			line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
		end
	end

	CreateEmpty(root).SetPreferredHeight(5);

	line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Add slot").SetColor(colors.Green).SetOnClick(function()
		pickToAddSlot(faction);
	end);

	if getTableLength(config.Factions) > 1 then
		CreateEmpty(root).SetPreferredHeight(10);
	
		showFactionRelationConfig(faction, root);
	end
end

function showFactionRelationConfig(faction, root)
	CreateLabel(root).SetText(faction .. " relation configuration").SetColor(colors.TextColor);
	for i, bool in pairs(config.Factions[faction].AtWar) do
		if i ~= faction then
			local line = CreateHorz(root).SetFlexibleWidth(1);
			local but;
			but = CreateButton(line).SetOnClick(function()
				if config.Factions[faction].AtWar[i] then
					config.Factions[faction].AtWar[i] = false;
					config.Factions[i].AtWar[faction] = false; 
					updateSlotRelation(faction, i, FactionRelations.Peace);

					but.SetText(FactionRelations.Peace).SetColor(colors.Yellow);
				else
					config.Factions[faction].AtWar[i] = true; 
					config.Factions[i].AtWar[faction] = true; 
					updateSlotRelation(faction, i, FactionRelations.War);

					but.SetText(FactionRelations.War).SetColor(colors.Red);
				end
			end);
			if bool then
				but.SetText(FactionRelations.War).SetColor(colors.Red);
			else
				but.SetText(FactionRelations.Peace).SetColor(colors.Yellow);
			end
			CreateButton(line).SetText(i).SetColor(getColorFromList(config.Factions[i].FactionLeader)).SetOnClick(function()
				showFactionConfig(i);
			end);
		end
	end
end

function pickToAddSlot(faction)
	local selectFun;
	local cancelFun = function()
		showFactionConfig(faction);
	end
	selectFun = function(slot)
		if config.SlotInFaction[slot] ~= nil then
			UI.Alert(getSlotName(slot) .. " is already in a Faction. Please select a different slot");
			pickSlot(selectFun, cancelFun);
			return;
		end
		addSlotToFaction(faction, slot);
		showFactionConfig(faction);
	end
	pickSlot(selectFun, cancelFun);
end

function addSlotToFaction(faction, slot)
	table.insert(config.Factions[faction].FactionMembers, slot);
	config.SlotInFaction[slot] = faction;
	initSlotRelations(slot);
end

function removeSlotFromFaction(faction, index, slot)
	table.remove(config.Factions[faction].FactionMembers, index);
	if config.Factions[faction].FactionLeader ~= nil and config.Factions[faction].FactionLeader == slot then
		config.Factions[faction].FactionLeader = config.Factions[faction].FactionMembers[1];
	end
	config.SlotInFaction[slot] = nil;
	for _, v in pairs(config.Factions[faction].FactionMembers) do
		config.Relations[slot][v] = Relations.Peace;
		config.Relations[v][slot] = Relations.Peace;
	end
	for f, bool in pairs(config.Factions[faction].AtWar) do
		if bool then
			for _, v in pairs(config.Factions[f].FactionMembers) do
				config.Relations[slot][v] = Relations.Peace;
				config.Relations[v][slot] = Relations.Peace;
			end
		end
	end
	showFactionConfig(faction);
end

function pickForFactionLeader(faction)
	local selectFun;
	local cancelFun = function()
		showFactionConfig(faction);
	end;
	selectFun = function(slot)
		if config.SlotInFaction[slot] ~= nil and config.SlotInFaction[slot] ~= faction then
			UI.Alert(getSlotName(slot) .. " is already in a different Faction. Please select a different slot");
			pickSlot(selectFun, cancelFun);
			return;
		elseif config.SlotInFaction[slot] ~= faction then
			config.SlotInFaction[slot] = faction; 
			initSlotRelations(slot); 
			table.insert(config.Factions[faction].FactionMembers, slot); 
		end

		config.Factions[faction].FactionLeader = slot;
		showFactionConfig(faction);
	end;
	pickSlot(selectFun, cancelFun);
end

function updateSlotRelation(faction, faction2, relation)
	if relation == FactionRelations.Peace then
		for _, p in pairs(config.Factions[faction].FactionMembers) do
			for _, p2 in pairs(config.Factions[faction2].FactionMembers) do
				config.Relations[p][p2] = Relations.Peace;
				config.Relations[p2][p] = Relations.Peace;
			end
		end
	else 
		for _, p in pairs(config.Factions[faction].FactionMembers) do
			for _, p2 in pairs(config.Factions[faction2].FactionMembers) do
				config.Relations[p][p2] = Relations.War;
				config.Relations[p2][p] = Relations.War;
			end
		end
	end
end

function deleteFaction(faction)
	for _, p in pairs(config.Factions[faction].FactionMembers) do
		config.SlotInFaction[p] = nil;
		for _, p2 in pairs(config.Factions[faction].FactionMembers) do
			config.Relations[p][p2] = Relations.Peace;
		end
	end
	for i, bool in pairs(config.Factions[faction].AtWar) do
		if bool then
			for _, p in pairs(config.Factions[faction].FactionMembers) do
				for _, p2 in pairs(config.Factions[i].FactionMembers) do
					config.Relations[p][p2] = Relations.Peace
					config.Relations[p2][p] = Relations.Peace
				end
			end
		end
		config.Factions[i].AtWar[faction] = nil;
	end
	config.Factions[faction] = nil;
end

function initSlotRelations(slot)
	if config.Relations[slot] == nil then
		config.Relations[slot] = {}; 
		if config.SlotInFaction[slot] ~= nil then
			for _, v in pairs(config.Factions[config.SlotInFaction[slot]].FactionMembers) do
				config.Relations[slot][v] = Relations.Faction;
				config.Relations[v][slot] = Relations.Faction;
			end
			for faction, bool in pairs(config.Factions[config.SlotInFaction[slot]].AtWar) do
				if bool then
					for _, v in pairs(config.Factions[faction].FactionMembers) do
						config.Relations[slot][v] = Relations.War;
						config.Relations[v][slot] = Relations.War;
					end
				end
			end
		end
		for i, _ in pairs(config.Relations) do
			if slot ~= i and config.Relations[slot][i] == nil then
				config.Relations[slot][i] = Relations.Peace;
				config.Relations[i][slot] = Relations.Peace;
			end
		end
	end
end

function getFactionLeader(faction)
	if config.Factions[faction].FactionLeader ~= nil then
		return getSlotName(config.Factions[faction].FactionLeader);
	else
		return "???";
	end
end

function isFactionWar(slot, slot2)
	if config.SlotInFaction[slot] ~= nil and config.SlotInFaction[slot2] ~= nil then
		if config.Factions[config.SlotInFaction[slot]].AtWar[config.SlotInFaction[slot2]] then
			return true;
		end
	end
	return false;
end


function confirmChoice(message, yesFunc, noFunc)
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

	CreateLabel(root).SetText(message).SetColor(colors.TextColor);

	local line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Yes!").SetColor(colors.Green).SetOnClick(yesFunc);
	CreateEmpty(line).SetPreferredWidth(20);
	CreateButton(line).SetText("No...").SetColor(colors.Red).SetOnClick(noFunc);
end
