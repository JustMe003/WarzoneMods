require("UI");
require("utilities")

function Client_PresentSettingsUI(rootParent)
	Init();
	GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1).SetCenter(true);
	colors = GetColors();

    if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
		require("Client_PresentSettingsUI1");
	else
		require("Client_PresentSettingsUI2");
	end
    Client_PresentSettingsUIMain();
end