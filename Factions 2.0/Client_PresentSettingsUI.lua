require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	showMain();
end

function showMain()
	local win = "main";
	if windowExists(win) then
		resetWindow(win);
	end
	destroyWindow(getCurrentWindow());
	counter = 0;
	local vert = newVerticalGroup("vert", "root");
	newButton(win .. "button", vert, "To slot configuration", showMainConfig, "Orange");
	local line = getLine(vert);
	newLabel(win .. line, line, "Visible history: " .. tostring(Mod.Settings.GlobalSettings.VisibleHistory));
	newButton(win .. line .. "button", line, "?", function() UI.Alert("If this settings is on (true), then all the events that happen between the turns will be visible for anyone. If this setting is off, then only the events that have impact on you or a factionmember will be visible. Events can be Faction creations, joins, declaration of war, etc"); end, "Blue");
	line = getLine(vert);
	newLabel(win .. line, line, "AIs can declare on players: " .. tostring(Mod.Settings.GlobalSettings.AICanDeclareOnPlayer));
	newButton(win .. line .. "button", line, "?", function() UI.Alert("If this setting is enabled any AI will declare war on a random player they border if they are not in any war. This way they will always have 1 player to attack if they are surrounded by players. Note that this settings is compatible with 'AIs can declare on AIs', if both settings are enabled the AI will either declare on another AI or player"); end, "Blue");
	line = getLine(vert);
	newLabel(win .. line, line, "AIs can declare on AIs: " .. tostring(Mod.Settings.GlobalSettings.AICanDeclareOnAI));
	newButton(win .. line .. "button", line, "?", function() UI.Alert("If this setting is enabled any AI will declare war on a random AI they border if they are not in any war. This way they will always have 1 AI to attack if they are surrounded by AIs. Note that this settings is compatible with 'AIs can declare on players', if both settings are enabled the AI will either declare on another player or AI"); end, "Blue");
	line = getLine(vert);
	newLabel(win .. line, line, "Approve Faction joins: " .. tostring(Mod.Settings.GlobalSettings.ApproveFactionJoins));
	newButton(win .. line .. "button", line, "?", function() UI.Alert("If enabled, Faction joins become Faction join proposals which the Faction leader has to permit or decline"); end, "Blue");
	line = getLine(vert);
	newLabel(win .. line, line, "Lock pre-set Factions: " .. tostring(Mod.Settings.GlobalSettings.LockPreSetFactions));
	newButton(win .. line .. "button", line, "?", function() UI.Alert("if enabled (and included) Factions made by the game creator in the mod configuration are locked. Players can leave them but not join them"); end, "Blue");
	line = getLine(vert);
	newLabel(win .. line, line, "Fair Factions: " .. tostring(Mod.Settings.GlobalSettings.FairFactions));
	newButton(win .. line .. "button", line, "?", function() UI.Alert("If enabled, the mod will stop a player from joining a Faction if they disbalance the game to much. See 'Fair Faction modifiers' for more if enabled"); end, "Blue");
	if Mod.Settings.GlobalSettings.FairFactions then
		line = getLine(vert);
		newLabel(win .. line, line, "Fair Factions modifier: " .. Mod.Settings.GlobalSettings.FairFactionsModifier);
		newButton(win .. line .. "button", line, "?", function() UI.Alert("This number indicates how much total income a Faction might have compared to the total income of every player in the game. This can prevent the biggest players from joining a Faction and steamroll the rest of the game"); end, "Blue");
	end
end

function showMainConfig()
	local win = "showMainConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	newLabel(win .. "warning", vert, "Note that this was the configuration for the start of the game, for the actual information check the mod menu", "Orange Red")
	newButton(win .. "Return", vert, "Return", showMain, "Orange");
	newLabel(win .. "EmptyAfterAddFaction", vert, " ");
	newLabel(win .. "factions", vert, "Factions:");
	for i, _ in pairs(Mod.Settings.Configuration.Factions) do
		newButton(win .. i, vert, i, function() showFactionConfig(i); end);
	end
	newLabel(win .. "EmptyAfterFactions", vert, " ");
	newLabel(win .. "Slots", vert, "Slots:")
	for i, _ in pairs(Mod.Settings.Configuration.Relations) do
		newButton(win .. i, vert, getSlotName(i), function() showSlotConfig(i); end);
	end
end

function showSlotConfig(slot)
	local win = "showSlotConfig";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	local vert = newVerticalGroup("Vert", "root");
	newButton(win .. "return", vert, "Return", showMainConfig, "Orange");
	newLabel(win .. "SlotName", vert, getSlotName(slot) .. " (Relation configuration)\n");
	if Mod.Settings.Configuration.SlotInFaction[slot] ~= nil then
		local line = newHorizontalGroup(win .. "line", vert);
		newLabel(win .. "factionLabel", line, "Faction: ");
		newButton(win .. "factionButton", line, Mod.Settings.Configuration.SlotInFaction[slot], function() showFactionConfig(Mod.Settings.Configuration.SlotInFaction[slot]); end);
	end
	for i, v in pairs(Mod.Settings.Configuration.Relations[slot]) do
		local line = newHorizontalGroup(win .. i .. "line", vert);
		newButton(win .. i .. "slotName", line, getSlotName(i), function() showSlotConfig(i); end);
		if v == "AtWar" then
			newLabel(win .. i .. "Button", line, "War", "Red");
		elseif v == "InPeace" then
			newLabel(win .. i .. "Button", line, "Peace", "Green");
		else
			newLabel(win .. i .. "Button", line, "In same faction", "Yellow");
		end
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
	newLabel(win .. "FactionName", vert, faction .. " (configuration)\n");
	local line = newHorizontalGroup(win .. "line", vert);
	newLabel(win .. "FactionLeaderString", line, "Faction leader: ");
	newLabel(win .. "SetFactionLeader", line, getFactionLeader(faction), "Yellow");
	newLabel(win .. "EmptyAfterFactionLeader", vert, "\nFaction members:");
	for i, v in pairs(Mod.Settings.Configuration.Factions[faction].FactionMembers) do
		newLabel(win .. i .. "Slot", vert, getSlotName(v));
	end
	local line = newHorizontalGroup(win .. "line2", vert);
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
	for i, bool in pairs(Mod.Settings.Configuration.Factions[faction].AtWar) do
		if i ~= faction then
			local line = newHorizontalGroup(win .. i .. "line", vert);
			if bool then
				newLabel(win .. i .. "Button", line, "War", "Red");
			else
				newLabel(win .. i .. "Button", line, "Peace", "Green");
			end
			newLabel(win .. i .. "text", line, i);
		end
	end
end

function getLine(vert)
	counter = counter + 1;
	return newHorizontalGroup("line" .. counter, vert);
end

function getFactionLeader(faction)
	if Mod.Settings.Configuration.Factions[faction].FactionLeader ~= nil then
		return getSlotName(Mod.Settings.Configuration.Factions[faction].FactionLeader);
	else
		return "???";
	end
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