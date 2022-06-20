require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	
	local win = "main";
	local vert = newVerticalGroup("vert", "root");
	newLabel(win, vert, "VisibleHistory: " .. tostring(Mod.Settings.GlobalSettings.VisibleHistory));
	newLabel(win, vert, "AICanDeclareOnPlayer: " .. tostring(Mod.Settings.GlobalSettings.AICanDeclareOnPlayer));
	newLabel(win, vert, "AICanDeclareOnAI: " .. tostring(Mod.Settings.GlobalSettings.AICanDeclareOnAI));
	newLabel(win, vert, "ApproveFactionJoins: " .. tostring(Mod.Settings.GlobalSettings.ApproveFactionJoins));
	newLabel(win, vert, "LockPreSetFactions: " .. tostring(Mod.Settings.GlobalSettings.LockPreSetFactions));
	newLabel(win, vert, "FairFactions: " .. tostring(Mod.Settings.GlobalSettings.FairFactions));
	newLabel(win, vert, "FairFactionsModifier: " .. Mod.Settings.GlobalSettings.FairFactionsModifier)
end