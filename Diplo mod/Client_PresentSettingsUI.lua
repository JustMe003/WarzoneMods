require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	
	local win = "main";
	local vert = newVerticalGroup("vert", "root");
	newLabel(win, vert, "VisibleHistory: " .. tostring(Mod.Settings.GlobalSettingsVisibleHistory));
	newLabel(win, vert, "AICanDeclareOnPlayer: " .. tostring(Mod.Settings.GlobalSettingsAICanDeclareOnPlayer));
	newLabel(win, vert, "AICanDeclareOnAI: " .. tostring(Mod.Settings.GlobalSettingsAICanDeclareOnAI));
	newLabel(win, vert, "ApproveFactionJoins: " .. tostring(Mod.Settings.GlobalSettingsApproveFactionJoins));
	newLabel(win, vert, "LockPreSetFactions: " .. tostring(Mod.Settings.GlobalSettingsLockPreSetFactions));
	newLabel(win, vert, "FairFactions: " .. tostring(Mod.Settings.GlobalSettingsFairFactions));
	newLabel(win, vert, "FairFactionsModifier: " .. Mod.Settings.GlobalSettingsFairFactionsModifier)
end