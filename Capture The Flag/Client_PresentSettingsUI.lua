require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	window("showSettings");
	local vert = newVerticalroup("vert", "root");
	newLabel("intro", vert, "This are the settings for this game", "Lime");
	local line = newHorizontalGroup("line1", vert);
	newLabel("nFlags", line, "Number of flags each team starts with \n(note that this value might not be the true value)", "Lime"); 
	newLabel("nFlagsInt", line, Mod.Settings.NumberOfFlags, "Royal Blue");
end
