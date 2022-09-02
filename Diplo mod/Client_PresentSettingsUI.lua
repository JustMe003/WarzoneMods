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
	newButton(win .. "button", vert, "To slot configuration", function() UI.Alert("Coming soon!") end, "Orange");
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

function getLine(vert)
	counter = counter + 1;
	return newHorizontalGroup("line" .. counter, vert);
end