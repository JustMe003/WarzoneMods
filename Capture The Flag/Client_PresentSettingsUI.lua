require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	window("showSettings");
	local vert = newVerticalGroup("vert", "root");
	newLabel("intro", vert, "This are the settings for this game", "Lime");
	local line = newHorizontalGroup("line1", vert);
	newLabel("nFlags", line, "Number of flags each team starts with: ", "Lime"); 
	newLabel("nFlagsInt", line, Mod.Settings.FlagsPerTeam, "Royal Blue");
	line = newHorizontalGroup("line2", vert);
	newLabel("nFlags", line, "Teams are eliminated after losing X flags: ", "Lime"); 
	newLabel("nFlagsInt", line, Mod.Settings.NFlagsForLose, "Royal Blue");
	line = newHorizontalGroup("line3", vert);
	newLabel("nFlags", line, "Players get X extra income on a flag capture: ", "Lime"); 
	newLabel("nFlagsInt", line, Mod.Settings.IncomeBoost, "Royal Blue");
end
