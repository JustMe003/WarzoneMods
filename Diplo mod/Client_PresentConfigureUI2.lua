require("UI");
require("utilities2");
require("ForcedRules");
function Client_PresentConfigureUIMain(rootParent)
	init(rootParent);

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
		settings.PlaySpyOnFactionMembers = true;
		settings.PlayersStartAtWar = false;
	end
	showSettings();
	showMain();
end

function showMain()
	local win = "showMain";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	local line = newHorizontalGroup(win .. "Line", vert);
	newButton(win .. "Settings", line, "Settings", showSettings, "Aqua");
	newButton(win .. "Config", line, "Configuration", showMainConfig, "Lime");
	newButton(win .. "ForcedRules", line, "Forced rules", function() forcedRulesInit(function() showMain(); end) end, "Royal Blue");
	newButton(win .. "ChangeVersion", line, "Change version", function() UI.Alert("Unfortunately, to do this you need to remove the mod from your game, and re-open the mod settings page.\n\n[!]Warning[!]\nThis will reset the entire configuration"); end, "Orange Red");
end

function showSettings()
	local win = "showSettings";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	newButton(win .. "return", vert, "Return", showMain, "Orange");
	local line = newHorizontalGroup("line1", vert);
	VisibleHistory = newCheckbox(win .. "VisibleHistory", line, " ", settings.VisibleHistory, true, function() settings.VisibleHistory = getIsChecked("showSettingsVisibleHistory"); end);
	newLabel(win .. "VisibleHistoryText", line, "Make all the events that happened public once the turn advances");
	line = newHorizontalGroup("line2", vert);
	FairFactions = newCheckbox(win .. "FairFactions", line, " ", settings.FairFactions, true, function() settings.FairFactions = getIsChecked("showSettingsFairFactions"); showSettings(); end);
	newLabel(win .. "FairFactionsText", line, "Make sure there is no faction that is way stronger than the other factions");
	if settings.FairFactions then
		newLabel(win .. "FairFactionsModifierText", vert, "This system is based on income. When a player tries to join a faction, it will calculate the total income of all players and the total income from all members from that faction. With a modifier of 0.5 a faction can not have more than half of the total income of all players, with a modifier of 0.25 a faction can not have more than a quarter of the total income of all players");
		FairFactionsModifier = newNumberField(win .. "FairFactionsModifier", vert, 0, 1, settings.FairFactionsModifier, true, false);
	end
	line = newHorizontalGroup("line3", vert);
	AICanDeclareOnAI = newCheckbox(win .. "AICanDeclareOnAI", line, " ", settings.AICanDeclareOnAI, true, function() settings.AICanDeclareOnAI = getIsChecked("showSettingsAICanDeclareOnAI"); end);
	newLabel(win .. "AICanDeclareOnAIText", line, "Allow AIs to declare on other AIs");
	line = newHorizontalGroup("line4", vert);
	AICanDeclareOnPlayer = newCheckbox(win .. "AICanDeclareOnPlayer", line, " ", settings.AICanDeclareOnPlayer, true, function() settings.AICanDeclareOnPlayer = getIsChecked("showSettingsAICanDeclareOnPlayer"); end);
	newLabel(win .. "AICanDeclareOnPlayerText", line, "Allow AIs to declare on players");
	line = newHorizontalGroup("line5", vert);
	ApproveFactionJoins = newCheckbox(win .. "ApproveFactionJoins", line, " ", settings.ApproveFactionJoins, true, function() settings.ApproveFactionJoins = getIsChecked("showSettingsApproveFactionJoins"); end);
	newLabel(win .. "ApproveFactionJoinsText", line, "Before a player joins a faction its request must be accepted by the faction leader");
	line = newHorizontalGroup("line6", vert);
	LockPreSetFactions = newCheckbox(win .. "LockPreSetFactions", line, " ", settings.LockPreSetFactions, true, function() settings.LockPreSetFactions = getIsChecked("showSettingsLockPreSetFactions"); end);
	newLabel(win .. "LockPreSetFactionsText", line, "Don't allow players to join factions created in this mod configuration");
	line = newHorizontalGroup("line7", vert);
	PlaySpyOnFactionMembers = newCheckbox(win .. "PlaySpyCard", line, " ", settings.PlaySpyOnFactionMembers, true, function() settings.PlaySpyOnFactionMembers = getIsChecked("showSettingsPlaySpyCard");  end);
	newLabel(win .. "PlaySpyCardText", line, "Play spy cards between every player if they are in the same faction");
	line = newHorizontalGroup("line8", vert);
	PlayersStartAtWar = newCheckbox(win .. "WarOrPeace", line, " ", settings.PlayersStartAtWar, true, function() settings.PlayersStartAtWar = getIsChecked("showSettingsWarOrPeace"); end);
	newLabel(win .. "WarOrPeaceText", line, "If a relation isn't set between players, then players start at war with eachother");
end

function showMainConfig()
	local win = "showMainConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	if defaultFactionRelation == nil then defaultFactionRelation = false; end
	local vert = newVerticalGroup("Vert", "root");
	local line = newHorizontalGroup(win .. "line", vert);
	newButton(win .. "AddFaction", line, "Add Faction", addFaction, "Lime");
	newButton(win .. "AddSlotConfig", line, "Add slot", pickSlot, "Aqua");
	newButton(win .. "Return", line, "Return", showMain, "Orange");
	newLabel(win .. "EmptyAfterAddFaction", vert, " ");
	if defaultFactionRelation then
		newButton("defaultRelation", vert, "Default Faction relation: Peace", function() end, "Green");
	else
		newButton("defaultRelation", vert, "Default Faction relation: War", function() end, "Red");
	end
	local defaultRelationButton = getObject("defaultRelation");
	defaultRelationButton.SetOnClick(if getColor("defaultRelation") == getColorFromString("Green") then defaultRelationButton.SetText("Default Faction relation: War").SetColor(colors.Red); else defaultRelationButton.SetText("Default Faction relation: Peace").SetColor(colors.Green); end end)
	for i, _ in pairs(config.Factions) do
		newButton(win .. i, vert, i, function() showFactionConfig(i); end, getFactionColor(i));
	end
	newLabel(win .. "EmptyAfterFactions", vert, " ");
	for i, _ in pairs(config.Relations) do
		newButton(win .. i, vert, getSlotName(i), function() showSlotConfig(i); end, getSlotColor(i));
	end
end

function addFaction()
	local win = "addFaction";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	newButton(win .. "return", vert, "Return", showMainConfig, "Orange");
	newTextField(win .. "FactionName", vert, "Enter Faction name here", "", 50, true, 300, -1, 1, 1);
	newButton(win .. "CreateFaction", vert, "Create Faction", createFaction, "Lime");
end

function pickSlot()
	local payload = {};
	for i = 0, 49 do
		if config.Relations[i] == nil then
			table.insert(payload, {text=getSlotName(i), selected=function() showSlotConfig(i); end});
		end
	end
	UI.PromptFromList("Pick slot to configure", payload);
end

function showSlotConfig(slot)
	initSlotRelations(slot);
	local win = "showSlotConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	newButton(win .. "return", vert, "Return", showMainConfig, "Orange");
	newLabel(win .. "SlotName", vert, getSlotName(slot) .. " (Relation configuration)\n");
	if config.SlotInFaction[slot] ~= nil then
		newLabel(win .. "factionLabel", vert, "Factions: ");
		for _, faction in pairs(config.SlotInFaction[slot]) do
			newButton(win .. "factionButton", vert, faction, function() showFactionConfig(faction); end, getFactionColor(faction));
		end
	end
	for i, v in pairs(config.Relations[slot]) do
		local line = newHorizontalGroup(win .. i .. "line", vert);
		newButton(win .. i .. "slotName", line, getSlotName(i), function() showSlotConfig(i); end, getSlotColor(i));
		if v == "AtWar" then
			newButton(win .. i .. "Button", line, "War", function() config.Relations[slot][i] = "InPeace"; config.Relations[i][slot] = "InPeace"; showSlotConfig(slot); end, "Red", not(isFactionWar(slot, i)));
		elseif v == "InPeace" then
			newButton(win .. i .. "Button", line, "Peace", function() config.Relations[slot][i] = "AtWar"; config.Relations[i][slot] = "AtWar"; showSlotConfig(slot); end, "Green");
		else
			newButton(win .. i .. "Button", line, "In same faction", function() end, "Yellow", false);
		end
	end
end

function createFaction()
	local faction = getText("addFactionFactionName");
	destroyWindow(getCurrentWindow());
	if config.Factions[faction] ~= nil then
		UI.Alert(faction .. " already exists");
		addFaction();
	else
		local t = {}
		for i, _ in pairs(config.Factions) do
			t[i] = false;
			config.Factions[i].AtWar[faction] = defaultFactionRelation;
		end
		config.Factions[faction] = {};
		config.Factions[faction].FactionMembers = {};
		config.Factions[faction].AtWar = t;
		config.Factions[faction].PreSetFaction = true;
		showFactionConfig(faction);
	end
end

function showFactionConfig(faction)
	local win = "showFactionConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	local line = newHorizontalGroup(win .. "line3", vert);
	newButton(win .. "return", line, "Return", showMainConfig, "Orange");
	newButton(win .. "Delete", line, "Delete Faction", function() confirmChoice("Do you wish to delele Faction " .. faction .. "?", function() deleteFaction(faction); showMainConfig(); end, function() showMainConfig(); end); end, "Red");
	newLabel(win .. "FactionName", vert, faction .. " (configuration)\n");
	line = newHorizontalGroup(win .. "line", vert);
	newLabel(win .. "FactionLeaderString", line, "Faction leader: ");
	newButton(win .. "SetFactionLeader", line, getFactionLeader(faction), function() PickForFactionLeader(faction) end, getFactionColor(faction));
	newLabel(win .. "EmptyAfterFactionLeader", vert, "\nFaction members:");
	for _, v in pairs(config.Factions[faction].FactionMembers) do
		newButton(win .. v .. "Slot", vert, getSlotName(v), function() showSlotConfig(v); end, getSlotColor(v));
	end
	line = newHorizontalGroup(win .. "line2", vert);
	newButton(win .. "AddSlots", line, "Add slot", function() PickToAddSlot(faction); end, "Green");
	newButton(win .. "RemoveSlots", line, "Remove slot", function() PickToRemoveSlot(faction); end, "Red");
	newLabel(win .. "EmptyAfterSlotsConfig", vert, " ");
	newButton(win .. "ShowFactionRelation", vert, "Relation configuration", function() showFactionRelationConfig(faction); end, "Aqua");
end

function showFactionRelationConfig(faction)
	local win = "showFactionConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	newButton(win .. "return", vert, "Return", function() showFactionConfig(faction); end, "Orange");
	newLabel(win .. "FactionName", vert, faction .. " (relation configuration)\n");
	for i, bool in pairs(config.Factions[faction].AtWar) do
		if i ~= faction then
			local line = newHorizontalGroup(win .. i .. "line", vert);
			newButton(win .. i .. "text", line, i, function() showFactionConfig(i); end, getFactionColor(i));
			if bool then
				newButton(win .. i .. "Button", line, "War", function() config.Factions[faction].AtWar[i] = false; config.Factions[i].AtWar[faction] = false; updateSlotRelation(faction, i, "Peace"); showFactionRelationConfig(faction); end, "Red");
			else
				newButton(win .. i .. "Button", line, "Peace", function() confirmChoice(getSlotKicksMessage(faction, i), function() config.Factions[faction].AtWar[i] = true; config.Factions[i].AtWar[faction] = true; updateSlotRelation(faction, i, "War"); showFactionRelationConfig(faction); end, function() showFactionRelationConfig(faction); end) end, "Green");
			end
		end
	end
end

function PickToAddSlot(faction)
	local payload = {};
	for i = 0, 49 do
		if (config.SlotInFaction[i] == nil or not valueInTable(config.SlotInFaction[i], faction)) and config.Factions[faction].FactionLeader ~= i then
			table.insert(payload, {text=getSlotName(i), selected=function() addSlotToFaction(faction, i); end});
		end
	end
	UI.PromptFromList("Choose which slot will be added to " .. faction, payload);
end

function addSlotToFaction(faction, slot)
	if config.SlotInFaction[slot] == nil then config.SlotInFaction[slot] = {}; end
	if not validFactionJoin(faction, slot) then
		UI.Alert(getSlotName(slot) .. " cannot join Faction '" .. faction .. "' because " .. getSlotName(slot) .. " is also in another Faction that is at war with '" .. faction .. "'");
		return false;
	end
	table.insert(config.Factions[faction].FactionMembers, slot);
	table.insert(config.SlotInFaction[slot], faction);
	initSlotRelations(slot);
	showFactionConfig(faction);
end

function PickToRemoveSlot(faction)
	local payload = {};
	for i, v in pairs(config.Factions[faction].FactionMembers) do
		if v ~= config.Factions[faction].FactionLeader then
			table.insert(payload, {text=getSlotName(v), selected=function() removeSlotFromFaction(faction, i, v); end});
		end
	end
	UI.PromptFromList("Choose which slot will be removed from " .. faction, payload);
end

function removeSlotFromFaction(faction, index, slot)
	table.remove(config.Factions[faction].FactionMembers, index);
	removeFactionFromSlot(faction, slot);
	for _, v in pairs(config.Factions[faction].FactionMembers) do
		config.Relations[slot][v] = "InPeace";
		config.Relations[v][slot] = "InPeace";
	end
	if config.Factions[faction].FactionLeader == slot then
		config.Factions[faction].FactionLeader = nil;
	end
	for f, bool in pairs(config.Factions[faction].AtWar) do
		if bool then
			for _, v in pairs(config.Factions[f].FactionMembers) do
				config.Relations[slot][v] = "InPeace";
				config.Relations[v][slot] = "InPeace";
			end
		end
	end
	showFactionConfig(faction);
end

function PickForFactionLeader(faction)
	local payload = {};
	for i = 0, 49 do
		if config.SlotInFaction[i] == nil or not valueInTable(config.SlotInFaction[i], faction) and not isFactionLeaderConfig(i, config) then
			table.insert(payload, {text=getSlotName(i), selected=function() if config.SlotInFaction[i] == nil then config.SlotInFaction[i] = {}; end; if validFactionJoin(faction, i) then config.Factions[faction].FactionLeader = i; addSlotToFaction(faction, i) else UI.Alert(getSlotName(i) .. " cannot join Faction '" .. faction .. "' because " .. getSlotName(i) .. " cannot be in both Factions while the Factions are at war with each other"); end; end});
		end
	end
	UI.PromptFromList("Which slot will be Faction leader?", payload);
end

function updateSlotRelation(faction, faction2, relation)
	if relation == "Peace" then
		for _, p in pairs(config.Factions[faction].FactionMembers) do
			for _, p2 in pairs(config.Factions[faction2].FactionMembers) do
				config.Relations[p][p2] = "InPeace";
				config.Relations[p2][p] = "InPeace";
			end
		end
	else
		local kicks = getSlotKicks(faction, faction2);
		for _, p in pairs(kicks) do
			print(p);
			if valueInTable(config.Factions[faction].FactionMembers, p) then
				removeSlotFromFaction(faction, getKeyFromValue(config.Factions[faction].FactionMembers, p), p);
			end
			if valueInTable(config.Factions[faction2].FactionMembers, p) then
				removeSlotFromFaction(faction2, getKeyFromValue(config.Factions[faction2].FactionMembers, p), p);
			end
		end
		for _, p in pairs(config.Factions[faction].FactionMembers) do
			for _, p2 in pairs(config.Factions[faction2].FactionMembers) do
				config.Relations[p][p2] = "AtWar";
				config.Relations[p2][p] = "AtWar";
			end
		end
	end
end

function deleteFaction(faction)
	for _, p in pairs(config.Factions[faction].FactionMembers) do
		removeFactionFromSlot(faction, p);
		for _, p2 in pairs(config.Factions[faction].FactionMembers) do
			config.Relations[p][p2] = "InPeace";
		end
	end
	for i, bool in pairs(config.Factions[faction].AtWar) do
		if bool then
			for _, p in pairs(config.Factions[faction].FactionMembers) do
				for _, p2 in pairs(config.Factions[i].FactionMembers) do
					config.Relations[p][p2] = "InPeace"
					config.Relations[p2][p] = "InPeace"
				end
			end
		end
		config.Factions[i].AtWar[faction] = nil;
	end
	config.Factions[faction] = nil;
end

function initSlotRelations(slot)
	if config.Relations[slot] == nil then config.Relations[slot] = {}; end
	if config.SlotInFaction[slot] ~= nil then
		for _, slotFaction in pairs(config.SlotInFaction[slot]) do
			for faction, bool in pairs(config.Factions[slotFaction].AtWar) do
				if bool then
					for _, v in pairs(config.Factions[faction].FactionMembers) do
						config.Relations[slot][v] = "AtWar";
						config.Relations[v][slot] = "AtWar";
					end
				end
			end
			for _, v in pairs(config.Factions[slotFaction].FactionMembers) do
				if v ~= slot then
					config.Relations[slot][v] = "InFaction";
					config.Relations[v][slot] = "InFaction";
				end
			end
		end
	end
	for i, _ in pairs(config.Relations) do
		if slot ~= i and config.Relations[slot][i] == nil then
			config.Relations[slot][i] = "InPeace";
			config.Relations[i][slot] = "InPeace";
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

function validFactionJoin(faction, slot)
	for _, slotFaction in pairs(config.SlotInFaction[slot]) do
		if config.Factions[faction].AtWar[slotFaction] then return false; end
	end
	return true;
end

function isFactionWar(slot, slot2)
	if config.SlotInFaction[slot] ~= nil and config.SlotInFaction[slot2] ~= nil then
		for _, factionSlot in pairs(config.SlotInFaction[slot]) do
			for _, factionSlot2 in pairs(config.SlotInFaction[slot2]) do
				if config.Factions[factionSlot].AtWar[factionSlot2] then return true; end
			end
		end
	end
	return false
end

function removeFactionFromSlot(faction, slot)
	for i = 1, #config.SlotInFaction[slot] do
		if config.SlotInFaction[slot][i] == faction then
			table.remove(config.SlotInFaction[slot], i);
			break;
		end
	end
end

function getSlotKicksMessage(faction, faction2)
	local s = "Are you sure you want to set '" .. faction .. "' and '" .. faction2 .. "' at war?";
	local slotKicks = {};
	for _, p in pairs(config.Factions[faction].FactionMembers) do
		for _, p2 in pairs(config.Factions[faction2].FactionMembers) do
			if p == p2 then table.insert(slotKicks, p);
			end
		end
	end
	if #slotKicks > 0 then
		s = s .. " The following slots will be kicked from both Factions:\n";
		for _, p in pairs(slotKicks) do
			s = s .. getSlotName(p) .. "\n";
		end
	end
	return s;
end

function getSlotKicks(faction, faction2)
	local slotKicks = {};
	for _, p in pairs(config.Factions[faction].FactionMembers) do
		for _, p2 in pairs(config.Factions[faction2].FactionMembers) do
			if p == p2 then table.insert(slotKicks, p);
			end
		end
	end
	return slotKicks;
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

function getSlotName(i)
	local c = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	local s = "Slot ";
	if i > 25 then
		s = s .. c[math.floor(i / 26)];
		i = i - (26 * math.floor(i / 26));
	end
	return s .. c[i % 26 + 1];
end

function getFactionColor(faction)
	if config.Factions[faction].FactionLeader ~= nil then return getSlotColor(config.Factions[faction].FactionLeader); end
	return "Dark Gray";
end

function getSlotColor(slot)
	for _, color in pairs(colors) do
		if slot == 0 then return color; end
		slot = slot - 1;
	end
end

function isFactionLeaderConfig(slot)
	if config.SlotInFaction[slot] ~= nil and #config.SlotInFaction[slot] > 0 then
		for _, faction in pairs(config.SlotInFaction[slot]) do
			if config.Factions[faction].FactionLeader == p then
				return true;
			end
		end
	end
	return false;
end