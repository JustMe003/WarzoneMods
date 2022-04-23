require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	window("showSettings");
	local vert = newHorizontalGroup("vert", "root");
	newLabel("intro", vert, "This are the settings for this game", "Lime");
end
