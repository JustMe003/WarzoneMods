require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	
	local win = "main";
	local vert = newVerticalGroup("vert", "root");
	newLabel(win, vert, "VisibleHistory: " .. tostring(Mod.Settings.VisibleHistory));
	newLabel(win, vert, "AICanDeclareOnPlayer: " .. tostring(Mod.Settings.AICanDeclareOnPlayer));
	newLabel(win, vert, "AICanDeclareOnAI: " .. tostring(Mod.Settings.AICanDeclareOnAI));
	newLabel(win, vert, "ApproveFactionJoins: " .. tostring(Mod.Settings.ApproveFactionJoins));
	newLabel(win, vert, "LockPreSetFactions: " .. tostring(Mod.Settings.LockPreSetFactions));
	newLabel(win, vert, "FairFactions: " .. tostring(Mod.Settings.FairFactions));
	newLabel(win, vert, "FairFactionsModifier: " .. Mod.Settings.FairFactionsModifier)
end