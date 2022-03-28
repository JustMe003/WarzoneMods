require("UI");
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	local vert = newVerticalGroup("vert", "root");
	newLabel("desc", vert, "Paste the string you copied from singleplayer");
	local text = Mod.Settings.Data;
	if text == nil then text = ""; end
	data = newTextField("data", vert, " ", text);
	updatePreferredWidth(data, 800);
	local testing = Mod.Settings.Testing;
	if testing == nil then testing = false; end
	testingScenario = newCheckbox("testingCheckBox", vert, "Check this checkbox if you want to test your scenario", testing)
end