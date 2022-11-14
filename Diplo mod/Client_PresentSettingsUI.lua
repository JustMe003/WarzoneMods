function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local line = UI.CreateHorizontalLayoutGroup(vert);
    if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
		require("Client_PresentSettingsUI1");
		UI.CreateLabel(line).SetText("Version used: 1.5.2");
	else
		require("Client_PresentSettingsUI2");
		UI.CreateLabel(line).SetText("Version used: 2.3");
	end
    Client_PresentSettingsUIMain(vert);
end