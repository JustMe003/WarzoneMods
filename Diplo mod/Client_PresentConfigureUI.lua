require("UI");
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	
	config = Mod.Settings.Configuration
	if config == nil then 
		config = {}; 
		config.Factions = {};
		config.SlotInFaction = {};
	end
	
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
	local line = newHorizontalGroup(win .. "line", vert);
	newButton(win .. "AddFaction", line, "Add Faction", addFaction, "Lime");
	newButton(win .. "AddSlotConfig", line, "Add slot", pickSlot, "Aqua");
	newLabel(win .. "EmptyAfterAddFaction", vert, " ");
	for i, _ in pairs(config.Factions) do
		newButton(win .. i, vert, i, function() showFactionConfig(i); end);
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
	newButton(win .. "return", vert, "Return", showMain, "Orange");
	newTextField(win .. "FactionName", vert, "", "Enter Faction name here", 50, true, 300, -1, 1, 1);
	newButton(win .. "CreateFaction", vert, "Create Faction", createFaction, "Lime");
end

function pickSlot()

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
		end
		config.Factions[faction] = {};
		config.Factions[faction].FactionMembers = {};
		config.Factions[faction].AtWar = t;
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
	newButton(win .. "return", vert, "Return", showMain, "Orange");
	newLabel(win .. "FactionName", vert, faction .. " (configuration)\n");
	local line = newHorizontalGroup(win .. "line", vert);
	newLabel(win .. "FactionLeaderString", line, "Faction leader: ");
	newButton(win .. "SetFactionLeader", line, getFactionLeader(faction), function() PickForFactionLeader(faction) end, "Yellow");
	newLabel(win .. "EmptyAfterFactionLeader", vert, "\nFaction members:");
	for i, v in pairs(config.Factions[faction].FactionMembers) do
		newLabel(win .. i .. "Slot", vert, getSlotName(v));
	end
	local line = newHorizontalGroup(win .. "line2", vert);
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
			if bool then
				newButton(win .. i .. "Button", line, "War", function() config.Factions[faction].AtWar[i] = false; showFactionRelationConfig(faction); end, "Red");
			else
				newButton(win .. i .. "Button", line, "Peace", function() config.Factions[faction].AtWar[i] = true; showFactionRelationConfig(faction); end, "Green");
			end
			newLabel(win .. i .. "text", line, i);
		end
	end
end

function PickToAddSlot(faction)
	local payload = {};
	for i = 0, 49 do
		if config.SlotInFaction[i] == nil and config.Factions[faction].FactionLeader ~= i then
			table.insert(payload, {text=getSlotName(i), selected=function() addSlotToFaction(faction, i); end});
		end
	end
	UI.PromptFromList("Choose which slot will be added to " .. faction, payload);
end

function addSlotToFaction(faction, slot)
	table.insert(config.Factions[faction].FactionMembers, slot);
	config.SlotInFaction[slot] = faction;
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
	config.SlotInFaction[slot] = nil;
	showFactionConfig(faction);
end

function PickForFactionLeader(faction)
	local payload = {};
	for i = 0, 49 do
		if config.SlotInFaction[i] == nil then
			table.insert(payload, {text=getSlotName(i), selected=function() config.SlotInFaction[i] = faction; config.Factions[faction].FactionLeader = i; table.insert(config.Factions[faction].FactionMembers, i); showFactionConfig(faction); end});
		end
	end
	UI.PromptFromList("Which slot will be Faction leader?", payload);
end

function getFactionLeader(faction)
	if config.Factions[faction].FactionLeader ~= nil then
		return getSlotName(config.Factions[faction].FactionLeader);
	else
		return "???";
	end
end

function getSlotName(i)
	local c = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	local s = "Slot ";
	if i > 26 then
		s = s .. c[math.floor(i / 26)];
		i = i - math.floor(i / 26);
	end
	return s .. c[i % 26 + 1];
end