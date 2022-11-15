function Client_PresentConfigureUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	if Mod.Settings.VersionNumber ~= nil then
		Version = Mod.Settings.VersionNumber;
		if Mod.Settings.VersionNumber == 1 then
			UI.CreateLabel(vert).SetText("Version: 1.5.2");
			require("Client_PresentConfigureUI1");
		else
			UI.CreateLabel(vert).SetText("Version: 2.3");
			require("Client_PresentConfigureUI2");
		end
		Client_PresentConfigureUIMain(vert);
	elseif Mod.Settings ~= nil and getTableLength(Mod.Settings) > 0 then
		Version = 1;
		require("Client_PresentConfigureUI1");
		UI.CreateLabel(vert).SetText("Version: 1.5.2");
		Client_PresentConfigureUIMain(vert);
	else
		showChoices(vert);
	end
end

function showChoices(vert)
	local t = {};
	table.insert(t, UI.CreateLabel(vert).SetText("Pick which mod version you want to use").SetColor("#FF4700"));
	table.insert(t, UI.CreateButton(vert).SetText("Version: 1.5").SetColor("#0000FF").SetOnClick(function() cleanUpWindow(t); require("Client_PresentConfigureUI1"); Version = 1; Client_PresentConfigureUIMain(vert); end));
	table.insert(t, UI.CreateButton(vert).SetText("Version: 2.3").SetColor("#0000FF").SetOnClick(function() cleanUpWindow(t); require("Client_PresentConfigureUI2"); Version = 2; Client_PresentConfigureUIMain(vert); end));
	table.insert(t, UI.CreateButton(vert).SetText("What's the difference?").SetColor("#FF4700").SetOnClick(function() cleanUpWindow(t); showDifference(vert); end))
end

function cleanUpWindow(t)
	for _, o in pairs(t) do
		UI.Destroy(o);
	end
end

function showDifference(vert)
	local t = {};
	table.insert(t, UI.CreateButton(vert).SetText("Return").SetColor("#FF7D00").SetOnClick(function() cleanUpWindow(t); showChoices(vert); end));
	table.insert(t, UI.CreateButton(vert).SetText("Main difference").SetColor("#0000FF").SetOnClick(function() cleanUpWindow(t); showMainDifference(vert); end))
	table.insert(t, UI.CreateButton(vert).SetText("Full difference list").SetColor("#FF4700").SetOnClick(function() cleanUpWindow(t); showFullDifferenceList(vert); end))
end

function showMainDifference(vert)
	local t = {};
	table.insert(t, UI.CreateButton(vert).SetText("Return").SetColor("#FF7D00").SetOnClick(function() cleanUpWindow(t); showDifference(vert); end));
	table.insert(t, UI.CreateLabel(vert).SetColor("#DDDDDD").SetText("The main difference is a change in a core mechanic, which is the reason why I cannot make it simply a setting.\n\nPrior to Factions 2.0, players were only able to join 1 faction. But, as you might can guess, nowadays players can join multiple Factions by using any version above 2.0. This comes with some extra forced rules by the mod to ensure the mod still has control over the diplomacy of the game.\n\nAll you and other players need to know, is that Factions 2.0 (and higher) is the newest version which is actively built on. You can read everything about the forced diplomacy rules in the mod configuration, mod menu or in the mod settings. Due to the extra rules, 2.0 and higher is a bit more complex than prior to the 2.0 version"))
end

function showFullDifferenceList(vert)
	local t = {};
	table.insert(t, UI.CreateButton(vert).SetText("Return").SetColor("#FF7D00").SetOnClick(function() cleanUpWindow(t); showDifference(vert); end));
	table.insert(t, UI.CreateLabel(vert).SetColor("#DDDDDD").SetText("Full changelog (from 1.6 --> 2.0 and higher)\n\n- Players can join multiple Factions instead of the usual 1\n- Diplomacy cards are now played at the end of the turn instead of the start (with some exceptions)\n- Added a new file which contains all the forced diplomacy rules and their explanations\n- Added a button in the mod configuration to read the forced diplomacy rules\n- Added a button in the mod settings to read the forced diplomacy rules\n- Added a button in the mod menu to read the forced diplomacy rules\n- Added a new setting to allow configuration of the normally standard 'playing spy cards on allies'\n- Players can now have pending join request for multiple Factions\n- Players can now read the Faction chat of every Faction they're in\n- Added a new pop up message for when a player opens their game for the first time, to tell them something about the new Factions version\n- Faction names must now be between 2 and 50 characters long\n- With the setting 'Visible History' set to true, players can see the Faction relation of any Faction\n- Removed the '1 Faction restriction' in the mod configuration when modifying which Faction a slot is in\n- Modified the text of A LOT of messages..."))
end

function getTableLength(t)
	local c = 0;
	for _, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end